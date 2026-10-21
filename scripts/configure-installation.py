#!/usr/bin/env python3
"""Render isolated PAP manifests without changing cluster state."""
import ipaddress
import json
import re
import sys
from pathlib import Path
import yaml

if len(sys.argv) != 4:
    raise SystemExit("Uso: configure-installation.py NAMESPACE POD_CIDR OUTPUT_DIR")

namespace, cidr, output = sys.argv[1:]
root = Path(__file__).resolve().parent.parent
out = Path(output).resolve()

if not re.fullmatch(r"[a-z0-9]([-a-z0-9]*[a-z0-9])?", namespace) or len(namespace) > 63:
    raise SystemExit("Namespace invalido")
network = ipaddress.ip_network(cidr, strict=True)
if network.version != 4 or network.prefixlen == 0:
    raise SystemExit("CIDR IPv4 invalido")

operator = list(yaml.safe_load_all((root / "k8s/operator.yaml").read_text()))
for doc in operator:
    if not doc:
        continue
    kind = doc["kind"]
    metadata = doc.setdefault("metadata", {})
    if kind == "Namespace":
        metadata["name"] = namespace
    elif kind not in ("CustomResourceDefinition", "ClusterRole", "ClusterRoleBinding"):
        metadata["namespace"] = namespace
    if kind in ("RoleBinding", "ClusterRoleBinding"):
        for subject in doc.get("subjects", []):
            if subject.get("kind") == "ServiceAccount":
                subject["namespace"] = namespace
    if kind == "Deployment" and metadata["name"] == "awx-operator-controller-manager":
        for container in doc["spec"]["template"]["spec"]["containers"]:
            for env in container.get("env", []):
                if env.get("name") == "WATCH_NAMESPACE":
                    env.pop("value", None)
                    env["valueFrom"] = {"fieldRef": {"fieldPath": "metadata.namespace"}}

awx = json.loads((root / "k8s/awx.yaml").read_text())
awx["metadata"]["namespace"] = namespace
awx["spec"]["pap_postgres_allowed_cidr"] = str(network)
policies = json.loads((root / "k8s/resource-policies.yaml").read_text())
for item in policies["items"]:
    item["metadata"]["namespace"] = namespace
    if item["kind"] == "ResourceQuota":
        item["metadata"]["name"] = f"{namespace}-quota"
    elif item["kind"] == "LimitRange":
        item["metadata"]["name"] = f"{namespace}-container-defaults"

out.mkdir(parents=True, exist_ok=True)
(out / "operator.yaml").write_text(yaml.safe_dump_all(operator, sort_keys=False))
(out / "awx.yaml").write_text(json.dumps(awx, indent=2) + "\n")
(out / "resource-policies.yaml").write_text(json.dumps(policies, indent=2) + "\n")
print(f"NAMESPACE={namespace}")
print(f"POSTGRES_CIDR={network}")
print("PORTABLE_MANIFESTS=PASS")
