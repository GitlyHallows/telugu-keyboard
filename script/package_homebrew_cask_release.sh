#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${CONFIG:-release}"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT/Resources/Info.plist")"
BUILD_ROOT="$ROOT/dist/homebrew"
ZIP_PATH="$BUILD_ROOT/TeluguKeyboard-$VERSION.zip"

mkdir -p "$BUILD_ROOT"

APP_PATH="$(CONFIG="$CONFIG" "$ROOT/script/stage_app.sh")"

swift build -c "$CONFIG" --product telugu-keyboard-installer >/dev/null
BIN_DIR="$(swift build -c "$CONFIG" --show-bin-path)"
HELPER_SOURCE="$BIN_DIR/telugu-keyboard-installer"
HELPER_DEST="$APP_PATH/Contents/Resources/telugu-keyboard-installer"
cp "$HELPER_SOURCE" "$HELPER_DEST"
chmod +x "$HELPER_DEST"

# This is intentionally ad-hoc signed. It is for unsigned Homebrew beta
# distribution when Developer ID signing is not available.
codesign --force --sign - "$HELPER_DEST" >/dev/null
codesign --force --sign - "$APP_PATH" >/dev/null

rm -f "$ZIP_PATH" "$ZIP_PATH.sha256"
/usr/bin/ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"
shasum -a 256 "$ZIP_PATH" >"$ZIP_PATH.sha256"

cat <<EOF
Created: $ZIP_PATH
SHA256: $(awk '{print $1}' "$ZIP_PATH.sha256")

Use this SHA256 in Casks/telugu-keyboard.rb after uploading
the zip to a GitHub release.
EOF
