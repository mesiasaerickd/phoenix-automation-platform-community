#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:?Uso: install-common.sh online}"
NAMESPACE="${2:-pap-acceptance}"

if [[ "$MODE" != "online" ]]; then
    echo "ERROR: modo invalido"
    exit 1
fi

if command -v kubectl >/dev/null 2>&1; then
    K=(kubectl)
elif command -v k3s >/dev/null 2>&1; then
    K=(k3s kubectl)
else
    echo "ERROR: Kubernetes/K3s no encontrado"
    exit 1
fi

echo "===== PREFLIGHT READ-ONLY ====="
"$ROOT/scripts/preflight.sh" "$NAMESPACE" pre

echo "===== VALIDAR CLUSTER ====="

"${K[@]}" get --raw=/readyz >/dev/null

if "${K[@]}" get crd awxs.awx.ansible.com >/dev/null 2>&1; then
    echo "ERROR: CRD AWX existente. Instalacion bloqueada."
    exit 1
fi

if "${K[@]}" get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "ERROR: namespace existente. Instalacion bloqueada."
    exit 1
fi

echo "===== DETECTAR CIDR ====="

CIDR="$(
    "${K[@]}" get nodes -o json |
    python3 -c '
import json,sys,ipaddress
nodes=json.load(sys.stdin)["items"]
cidrs=set()
for node in nodes:
    spec=node.get("spec",{})
    for cidr in spec.get("podCIDRs",[]):
        network=ipaddress.ip_network(cidr)
        if network.version==4:
            cidrs.add(str(network))
if len(cidrs)!=1:
    raise SystemExit("ERROR: CIDR IPv4 unico no encontrado")
print(next(iter(cidrs)))
'
)"

echo "CIDR=$CIDR"

OUT="$(mktemp -d)"

python3 "$ROOT/scripts/configure-installation.py" \
    "$NAMESPACE" "$CIDR" "$OUT"

python3 "$ROOT/scripts/configure-images.py" \
    "$MODE" "$OUT"

echo "===== MANIFIESTOS GENERADOS ====="

ls -lh "$OUT"

echo "===== REGISTRO GHCR PUBLICO ====="
echo "No se requieren credenciales personales."

echo "===== PREPARAR NAMESPACE ====="

"${K[@]}" create namespace "$NAMESPACE"

echo "===== IMAGENES PUBLICAS GHCR ====="

echo "===== INSTALAR CRD Y OPERADOR ====="

"${K[@]}" apply -f "$OUT/operator.yaml"

echo "===== ESPERAR CRD ====="

"${K[@]}" wait     --for=condition=Established     crd/awxs.awx.ansible.com     --timeout=180s

echo "===== ESPERAR OPERADOR ====="

"${K[@]}" rollout status     deployment/awx-operator-controller-manager     -n "$NAMESPACE"     --timeout=300s

echo "===== INSTALAR POLITICAS ====="

"${K[@]}" apply -f "$OUT/resource-policies.yaml"

echo "===== INSTALAR PAP ====="

"${K[@]}" apply -f "$OUT/awx.yaml"

echo "MANIFEST_DIR=$OUT"
echo "PAP_INSTALL_COMMON=COMPLETE"
