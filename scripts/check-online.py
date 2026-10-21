#!/usr/bin/env python3
"""Read-only validations for PAP online manifests and host firewall state."""
import json
import shutil
import subprocess
import sys
from pathlib import Path
import yaml

if len(sys.argv) != 2:
    raise SystemExit("Uso: check-online.py DIRECTORIO_RENDERIZADO")
p = Path(sys.argv[1])
awx = json.loads((p / "awx.yaml").read_text())
docs = list(yaml.safe_load_all((p / "operator.yaml").read_text()))
spec = awx["spec"]
assert not spec.get("image_pull_secrets"), "Las imagenes publicas no requieren image_pull_secrets"
assert spec.get("image") == "ghcr.io/phoenix-automation-platform/pap-web-task"
assert spec.get("image_version") == "dev-20261020"
assert not spec.get("ee_pull_credentials_secret"), "No usar un dockerconfigjson como credencial AWX EE"
assert spec.get("image_pull_policy") == "IfNotPresent"
assert len(spec.get("ee_images", [])) >= 1
operator = next(d for d in docs if d and d.get("kind") == "Deployment"
                and d["metadata"]["name"] == "awx-operator-controller-manager")
pod = operator["spec"]["template"]["spec"]
assert not pod.get("imagePullSecrets"), "El operador publico no requiere imagePullSecrets"
manager = next(c for c in pod["containers"] if c["name"] == "awx-manager")
assert manager["args"][0] == "run"
env = {e["name"]: e for e in manager["env"]}
assert env["WATCH_NAMESPACE"].get("valueFrom", {}).get("fieldRef", {}).get("fieldPath") == "metadata.namespace"
assert "value" not in env["WATCH_NAMESPACE"]
assert "ANSIBLE_ROLES_PATH" in env

def service_state(name):
    if not shutil.which("systemctl"):
        return "unknown"
    proc = subprocess.run(["systemctl", "is-active", name], capture_output=True, text=True, check=False)
    return proc.stdout.strip() or "unknown"

if shutil.which("firewall-cmd"):
    state = service_state("firewalld")
    print("FIREWALLD=" + state)
    if state == "active":
        zone = subprocess.run(["firewall-cmd", "--get-active-zones"], capture_output=True, text=True)
        print("FIREWALLD_ACTIVE_ZONES=" + " ".join(zone.stdout.splitlines())[:500])
        print("FIREWALLD_POLICY=READ_ONLY_MANUAL_APPROVAL_REQUIRED")
else:
    print("FIREWALLD=not_installed")
print("PAP_ONLINE_PREFLIGHT=PASS")
