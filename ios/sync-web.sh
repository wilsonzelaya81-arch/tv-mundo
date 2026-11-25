#!/usr/bin/env bash
# Copia la versión actual del sitio web (raíz del repo) dentro de la app iOS.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/ios/TVMundo/Web"
mkdir -p "$DEST"
for f in index.html manifest.json sw.js icon-192.png icon-512.png; do
  cp "$ROOT/$f" "$DEST/$f"
done
echo "Web actualizada en $DEST"
