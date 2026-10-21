#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAMESPACE="${1:-pap-acceptance}"

echo "PAP ONLINE INSTALLATION"
echo "Using public Phoenix GHCR images; no personal token required."

exec "$ROOT/scripts/install-common.sh" online "$NAMESPACE"
