#!/usr/bin/env bash
# Intentionally prints the secret only to an interactive local terminal.
set -uo pipefail
NS="${1:-pap-acceptance}"
AWX="${2:-pap-security}"
if [[ ! -t 1 ]]; then
  echo "ERROR: requiere terminal interactiva; no redirigir la contraseña a logs o CI" >&2
  exit 2
fi
if command -v k3s >/dev/null 2>&1; then K=(k3s kubectl)
elif command -v kubectl >/dev/null 2>&1; then K=(kubectl)
else echo "ERROR: kubectl o k3s no disponible" >&2; exit 2
fi
set +x
data=$("${K[@]}" get secret "$AWX-admin-password" -n "$NS" -o jsonpath='{.data.password}') || exit 1
if [[ -z "$data" ]]; then echo "ERROR: clave password vacia/no encontrada" >&2; exit 1; fi
echo "Administrador predeterminado: admin"
printf 'Contraseña inicial: '
printf '%s' "$data" | base64 --decode
printf '\n'
unset data
echo "Tratar como credencial sensible; cambiarla tras primer acceso y no compartirla en tickets o chats."
