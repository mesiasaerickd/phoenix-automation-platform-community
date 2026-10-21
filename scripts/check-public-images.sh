#!/usr/bin/env bash
set -euo pipefail

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$BASE/releases/required-images-public.txt"

if command -v skopeo >/dev/null 2>&1; then
    echo "Verificando imagenes publicas GHCR"

    while IFS= read -r image; do
        [ -n "$image" ] || continue

        echo "IMAGE: $image"

        if skopeo inspect \
            --no-creds \
            "docker://${image}:latest" \
            >/dev/null 2>&1; then
            echo "PUBLIC: $image"
        else
            echo "NO DISPONIBLE PUBLICAMENTE: $image"
            exit 1
        fi
    done < "$MANIFEST"

else
    echo "ERROR: skopeo no instalado"
    exit 1
fi
