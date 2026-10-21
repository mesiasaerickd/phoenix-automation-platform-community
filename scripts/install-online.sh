#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAMESPACE="${1:-pap-acceptance}"

echo "PAP ONLINE INSTALLATION"
echo "Requires authorized access to GHCR if packages are private."

exec "$ROOT/scripts/install-common.sh" online "$NAMESPACE"
