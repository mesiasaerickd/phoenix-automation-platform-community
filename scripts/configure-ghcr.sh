#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${1:?Uso: configure-ghcr.sh NAMESPACE}"

if command -v kubectl >/dev/null 2>&1; then
    K=(kubectl)
elif command -v k3s >/dev/null 2>&1; then
    K=(k3s kubectl)
else
    echo "ERROR: Kubernetes/K3s no encontrado"
    exit 1
fi

if ! "${K[@]}" get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "ERROR: namespace inexistente: $NAMESPACE"
    exit 1
fi

if [[ -z "${TOKEN:-}" ]]; then
    read -r -s -p "PAP_INSTALL_READONLY (GHCR): " TOKEN </dev/tty
    echo
fi

test -n "$TOKEN" || {
    echo "ERROR: token vacio"
    exit 1
}

export TOKEN

python3 - <<'INNER' | "${K[@]}" -n "$NAMESPACE" apply -f -
import os, json, base64

auth=base64.b64encode(
    ("mesiasaerickd:"+os.environ["TOKEN"]).encode()
).decode()

config={
    "auths":{
        "ghcr.io":{
            "auth":auth
        }
    }
}

secret={
    "apiVersion":"v1",
    "kind":"Secret",
    "metadata":{"name":"pap-ghcr"},
    "type":"kubernetes.io/dockerconfigjson",
    "data":{
        ".dockerconfigjson":base64.b64encode(
            json.dumps(config).encode()
        ).decode()
    }
}

print(json.dumps(secret))
INNER

unset TOKEN

"${K[@]}" -n "$NAMESPACE" patch serviceaccount default \
    --type=merge \
    -p '{"imagePullSecrets":[{"name":"pap-ghcr"}]}'

echo "PAP_GHCR_SECRET=PASS"
