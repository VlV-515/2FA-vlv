#!/usr/bin/env bash
# Regenerates Assets/AppIcon-1024.png, the .iconset and AppIcon.icns from scripts/make-icon.swift.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSETS="$ROOT_DIR/Assets"
ICONSET="$ASSETS/AppIcon.iconset"
MASTER="$ASSETS/AppIcon-1024.png"

mkdir -p "$ASSETS" "$ROOT_DIR/docs/images"
swift "$ROOT_DIR/scripts/make-icon.swift" "$MASTER"

rm -rf "$ICONSET"
mkdir -p "$ICONSET"
for size in 16 32 128 256 512; do
  sips -z "$size" "$size" "$MASTER" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
  double=$((size * 2))
  sips -z "$double" "$double" "$MASTER" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done

iconutil -c icns "$ICONSET" -o "$ASSETS/AppIcon.icns"
sips -z 256 256 "$MASTER" --out "$ROOT_DIR/docs/images/app-icon.png" >/dev/null
echo "Icon assets updated in $ASSETS"
