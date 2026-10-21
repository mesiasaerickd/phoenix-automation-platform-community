#!/usr/bin/env bash
# Read-only post-install helper. Never prints or logs the admin password.
set -uo pipefail
NS="${1:-pap-acceptance}"
AWX="${2:-pap-security}"
if command -v k3s >/dev/null 2>&1; then K=(k3s kubectl)
elif command -v kubectl >/dev/null 2>&1; then K=(kubectl)
else echo "ERROR: kubectl o k3s no disponible" >&2; exit 2
fi
echo "PAP POST-INSTALL: namespace=$NS instance=$AWX"
"${K[@]}" get pods -n "$NS"
"${K[@]}" get svc "$AWX-service" -n "$NS"
echo "Administrador esperado: admin (AWX predeterminado; comprobar configuración de la instancia)"
SECRET="$AWX-admin-password"
if "${K[@]}" get secret "$SECRET" -n "$NS" >/dev/null 2>&1; then
  echo "ADMIN_SECRET=FOUND ($SECRET)"
  echo "Para consultar la contraseña sin imprimirla en este reporte:"
  echo "  scripts/show-admin-password.sh $NS $AWX"
else
  echo "ADMIN_SECRET=NOT_FOUND; revisar reconciliación y secretos sin crear contraseñas por defecto"
fi
echo "Para acceso local, en otra terminal del servidor:"
echo "  k3s kubectl -n $NS port-forward svc/$AWX-service 18080:80 --address=127.0.0.1"
echo "Abrir http://127.0.0.1:18080 desde el mismo servidor, o crear un tunel SSH para un cliente remoto."
