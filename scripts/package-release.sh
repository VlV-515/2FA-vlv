#!/usr/bin/env bash
# Builds dist/2FA-vlv-<version>-macos-unsigned.zip plus its sha256 file.
set -euo pipefail

APP_NAME="2FA-vlv"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
VERSION="${1:-1.0.0}"
BUILD="${BUILD_NUMBER:-1}"
ARCHIVE_NAME="$APP_NAME-$VERSION-macos-unsigned.zip"
ARCHIVE_PATH="$DIST_DIR/$ARCHIVE_NAME"

APP_VERSION="$VERSION" APP_BUILD="$BUILD" "$ROOT_DIR/scripts/package-app.sh"

rm -f "$ARCHIVE_PATH" "$ARCHIVE_PATH.sha256"
(cd "$DIST_DIR" && ditto -c -k --keepParent "$APP_NAME.app" "$ARCHIVE_NAME")
(cd "$DIST_DIR" && shasum -a 256 "$ARCHIVE_NAME" > "$ARCHIVE_NAME.sha256")

echo "Created $ARCHIVE_PATH"
echo "Created $ARCHIVE_PATH.sha256"
