#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PATH="$("$ROOT/script/stage_app.sh")"
DEST_DIR="$HOME/Library/Input Methods"
DEST_PATH="$DEST_DIR/TeluguKeyboard.app"
CONFIG="${CONFIG:-debug}"

mkdir -p "$DEST_DIR"
rm -rf "$DEST_PATH"
cp -R "$APP_PATH" "$DEST_PATH"

killall TeluguKeyboard 2>/dev/null || true
open "$DEST_PATH" || true
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$DEST_PATH" >/dev/null 2>&1 || true

swift build -c "$CONFIG" --product telugu-keyboard-installer >/dev/null
BIN_DIR="$(swift build -c "$CONFIG" --show-bin-path)"
INSTALLER="$BIN_DIR/telugu-keyboard-installer"
"$INSTALLER" register "$DEST_PATH" >/dev/null
"$INSTALLER" select >/dev/null

echo "Installed: $DEST_PATH"
"$INSTALLER" status
