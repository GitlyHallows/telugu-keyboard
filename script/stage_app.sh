#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${CONFIG:-debug}"
APP_PATH="$ROOT/dist/TeluguKeyboard.app"

swift build -c "$CONFIG" --product TeluguKeyboardIME >/dev/null
BIN_DIR="$(swift build -c "$CONFIG" --show-bin-path)"

rm -rf "$APP_PATH"
mkdir -p "$APP_PATH/Contents/MacOS" "$APP_PATH/Contents/Resources"

cp "$BIN_DIR/TeluguKeyboardIME" "$APP_PATH/Contents/MacOS/TeluguKeyboard"
cp "$ROOT/Resources/Info.plist" "$APP_PATH/Contents/Info.plist"
find "$BIN_DIR" -maxdepth 1 -name '*.bundle' -exec cp -R {} "$APP_PATH/Contents/Resources/" \;
chmod +x "$APP_PATH/Contents/MacOS/TeluguKeyboard"

codesign --force --sign - "$APP_PATH" >/dev/null

echo "$APP_PATH"
