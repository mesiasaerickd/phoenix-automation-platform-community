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

# Online private images: verify the PAT before creating Kubernetes resources.
echo "===== VALIDAR TOKEN GHCR (ANTES DE INSTALAR) ====="
    set +x
    if [[ ! -r /dev/tty ]]; then
        echo "BLOCKED: GHCR_TOKEN_REQUIRES_TTY"
        exit 1
    fi
    echo "Instalacion privada: introduce el PAT classic con read:packages."
    read -r -s -p "PAP_INSTALL_READONLY (pegar token y Enter): " TOKEN </dev/tty
    echo
    if [[ -z "$TOKEN" ]]; then echo "BLOCKED: TOKEN_EMPTY"; exit 1; fi
    export TOKEN
    trap 'unset TOKEN' EXIT
    if ! python3 - <<'PYGHCR'
import json, os, urllib.error, urllib.request
token = os.environ["TOKEN"]
req = urllib.request.Request("https://api.github.com/user",
    headers={"Authorization":"Bearer "+token,
             "Accept":"application/vnd.github+json",
             "X-GitHub-Api-Version":"2022-11-28"})
try:
    with urllib.request.urlopen(req, timeout=20) as res:
        user = json.load(res).get("login")
        scopes = {s.strip() for s in res.headers.get("X-OAuth-Scopes","").split(",")}
        if user != "mesiasaerickd" or "read:packages" not in scopes:
            print("BLOCKED: GHCR_TOKEN_OWNER_OR_SCOPE_INVALID")
            raise SystemExit(1)
except (urllib.error.URLError, TimeoutError) as exc:
    print("BLOCKED: GHCR_TOKEN_VALIDATION_FAILED:", type(exc).__name__)
    raise SystemExit(1)
print("GHCR_PAT_VALID=PASS")
PYGHCR
    then
        unset TOKEN
        exit 1
    fi

echo "===== PREPARAR NAMESPACE ====="

"${K[@]}" create namespace "$NAMESPACE"

echo "===== CONFIGURAR GHCR ====="
"$ROOT/scripts/configure-ghcr.sh" "$NAMESPACE"
unset TOKEN

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
