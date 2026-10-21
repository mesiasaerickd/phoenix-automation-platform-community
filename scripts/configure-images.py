#!/usr/bin/env python3
"""Configure online images; registry pull and AWX EE secrets are distinct."""
import json
import re
import sys
from pathlib import Path
import yaml

if len(sys.argv) != 3:
    raise SystemExit("Uso: configure-images.py online DIRECTORIO_RENDERIZADO")
mode = sys.argv[1]
if mode != "online":
    raise SystemExit("Modo invalido")
root = Path(__file__).resolve().parent.parent
output = Path(sys.argv[2]).resolve()
awx_file = output / "awx.yaml"
operator_file = output / "operator.yaml"
if not awx_file.is_file() or not operator_file.is_file():
    raise SystemExit("Primero ejecutar configure-installation.py")

awx = json.loads(awx_file.read_text())
operator = list(yaml.safe_load_all(operator_file.read_text()))
spec = awx["spec"]

if mode == "online":
    refs = [s.strip() for s in (root / "releases/ghcr-digests-dev.txt").read_text().splitlines() if s.strip() and not s.startswith("#")]
    if len(refs) != 6 or len(set(refs)) != 6:
        raise SystemExit("Inventario GHCR invalido: se esperan seis referencias unicas")

    def parse_ref(ref):
        # Versions used by the AWX operator are appended with ':'; use tags,
        # not @sha256 in *_image_version fields.
        match = re.fullmatch(r"(.+):([^/:@]+)(?:@(sha256:[0-9a-f]{64}))?", ref)
        if not match:
            raise SystemExit(f"Referencia OCI invalida: {ref}")
        return match.group(1), match.group(2), match.group(3)

    images = [parse_ref(ref) for ref in refs]
    if len({x[0] for x in images}) != 6:
        raise SystemExit("Se esperan seis repositorios de imagen distintos")
    for image_key, version_key, idx in (
        ("image", "image_version", 1),
        ("postgres_image", "postgres_image_version", 2),
        ("redis_image", "redis_image_version", 3),
        ("init_container_image", "init_container_image_version", 4),
    ):
        spec[image_key], spec[version_key] = images[idx][:2]
    spec["control_plane_ee_image"] = refs[4]
    spec["ee_images"] = [{"name": "PAP EE Core", "image": refs[5]}]
    spec["image_pull_policy"] = "IfNotPresent"
    spec["image_pull_secrets"] = ["pap-ghcr"]
    # Dockerconfigjson (Kubernetes imagePullSecret) is NOT a valid AWX
    # ee_pull_credentials_secret (expects username/password/url keys).
    spec.pop("ee_pull_credentials_secret", None)
    spec.pop("image_pull_secret", None)
    operator_image = refs[0]

for obj in operator:
    if obj and obj.get("kind") == "Deployment" and obj["metadata"]["name"] == "awx-operator-controller-manager":
        pod = obj["spec"]["template"]["spec"]
        pod["imagePullSecrets"] = [{"name": "pap-ghcr"}]
        for container in pod["containers"]:
            if container["name"] == "awx-manager":
                if operator_image:
                    container["image"] = operator_image
                container["imagePullPolicy"] = "IfNotPresent"

awx_file.write_text(json.dumps(awx, indent=2) + "\n")
operator_file.write_text(yaml.safe_dump_all(operator, sort_keys=False))
print(f"PAP_IMAGE_MODE={mode}")
print("PAP_IMAGE_CONFIGURATION=PASS")
