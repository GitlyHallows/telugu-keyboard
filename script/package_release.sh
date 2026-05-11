#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${CONFIG:-release}"
APP_IDENTITY="${DEVELOPER_ID_APPLICATION:-}"
INSTALLER_IDENTITY="${DEVELOPER_ID_INSTALLER:-}"
NOTARY_PROFILE="${NOTARY_PROFILE:-}"
BUNDLE_ID="org.telugukeyboard.inputmethod.TeluguKeyboard"

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require_identity() {
  local identity="$1"
  local label="$2"

  [[ -n "$identity" ]] || die "$label is required"
  security find-identity -p codesigning -v | grep -F "$identity" >/dev/null \
    || die "$label not found in the login keychain: $identity"
}

require_identity "$APP_IDENTITY" "DEVELOPER_ID_APPLICATION"
require_identity "$INSTALLER_IDENTITY" "DEVELOPER_ID_INSTALLER"

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT/Resources/Info.plist")"
BUILD_ROOT="$ROOT/dist/release"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/telugu-keyboard-release.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

mkdir -p "$BUILD_ROOT"

APP_PATH="$(CONFIG="$CONFIG" "$ROOT/script/stage_app.sh")"

swift build -c "$CONFIG" --product telugu-keyboard-installer >/dev/null
BIN_DIR="$(swift build -c "$CONFIG" --show-bin-path)"
HELPER_SOURCE="$BIN_DIR/telugu-keyboard-installer"
HELPER_DEST="$APP_PATH/Contents/Resources/telugu-keyboard-installer"
cp "$HELPER_SOURCE" "$HELPER_DEST"
chmod +x "$HELPER_DEST"

codesign --force --options runtime --timestamp --sign "$APP_IDENTITY" "$HELPER_DEST"
codesign --force --options runtime --timestamp --sign "$APP_IDENTITY" "$APP_PATH"
codesign --verify --strict --verbose=2 "$APP_PATH"

PAYLOAD_ROOT="$WORK_DIR/payload"
PAYLOAD_DIR="$PAYLOAD_ROOT/private/tmp/TeluguKeyboardInstaller"
SCRIPTS_DIR="$WORK_DIR/scripts"
mkdir -p "$PAYLOAD_DIR" "$SCRIPTS_DIR"
cp -R "$APP_PATH" "$PAYLOAD_DIR/TeluguKeyboard.app"

cat >"$SCRIPTS_DIR/postinstall" <<'POSTINSTALL'
#!/usr/bin/env bash
set -euo pipefail

PAYLOAD_APP="/private/tmp/TeluguKeyboardInstaller/TeluguKeyboard.app"
PAYLOAD_DIR="/private/tmp/TeluguKeyboardInstaller"
CONSOLE_USER="$(/usr/bin/stat -f %Su /dev/console)"

if [[ -z "$CONSOLE_USER" || "$CONSOLE_USER" == "root" ]]; then
  echo "Could not find the active macOS user." >&2
  exit 1
fi

USER_HOME="$(/usr/bin/dscl . -read "/Users/$CONSOLE_USER" NFSHomeDirectory | /usr/bin/awk '{print $2}')"
USER_ID="$(/usr/bin/id -u "$CONSOLE_USER")"
DEST_DIR="$USER_HOME/Library/Input Methods"
DEST_APP="$DEST_DIR/TeluguKeyboard.app"
HELPER="$DEST_APP/Contents/Resources/telugu-keyboard-installer"

if [[ ! -d "$PAYLOAD_APP" ]]; then
  echo "Installer payload is missing: $PAYLOAD_APP" >&2
  exit 1
fi

/bin/mkdir -p "$DEST_DIR"
/bin/rm -rf "$DEST_APP"
/bin/cp -R "$PAYLOAD_APP" "$DEST_APP"
/usr/sbin/chown -R "$CONSOLE_USER":staff "$DEST_APP"
/bin/rm -rf "$PAYLOAD_DIR"

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$DEST_APP" >/dev/null 2>&1 || true
/bin/launchctl asuser "$USER_ID" /usr/bin/open "$DEST_APP" >/dev/null 2>&1 || true

if [[ -x "$HELPER" ]]; then
  /bin/launchctl asuser "$USER_ID" "$HELPER" register "$DEST_APP" >/dev/null 2>&1 || true
  /bin/launchctl asuser "$USER_ID" "$HELPER" enable-and-select >/dev/null 2>&1 || true
fi

exit 0
POSTINSTALL
chmod +x "$SCRIPTS_DIR/postinstall"

COMPONENT_PKG="$WORK_DIR/TeluguKeyboard-component.pkg"
PKG_PATH="$BUILD_ROOT/TeluguKeyboard-$VERSION.pkg"

pkgbuild \
  --root "$PAYLOAD_ROOT" \
  --scripts "$SCRIPTS_DIR" \
  --identifier "$BUNDLE_ID.pkg" \
  --version "$VERSION" \
  "$COMPONENT_PKG"

productsign --sign "$INSTALLER_IDENTITY" "$COMPONENT_PKG" "$PKG_PATH"

if [[ -n "$NOTARY_PROFILE" ]]; then
  xcrun notarytool submit "$PKG_PATH" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple "$PKG_PATH"
fi

shasum -a 256 "$PKG_PATH" >"$PKG_PATH.sha256"

printf 'Created %s\n' "$PKG_PATH"
printf 'Checksum %s\n' "$PKG_PATH.sha256"
