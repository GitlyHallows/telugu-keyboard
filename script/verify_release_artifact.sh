#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage:
  script/verify_release_artifact.sh <TeluguKeyboard.app|TeluguKeyboard.pkg> [...]

Verifies bundle structure, Developer ID signing, notarization stapling, and
Gatekeeper assessment for release artifacts.
USAGE
}

[[ $# -gt 0 ]] || {
  usage
  exit 2
}

verify_app() {
  local app="$1"
  local plist="$app/Contents/Info.plist"
  local executable="$app/Contents/MacOS/TeluguKeyboard"

  [[ -d "$app" ]] || {
    echo "error: app does not exist: $app" >&2
    return 1
  }
  [[ -f "$plist" ]] || {
    echo "error: missing Info.plist: $plist" >&2
    return 1
  }
  [[ -x "$executable" ]] || {
    echo "error: missing executable: $executable" >&2
    return 1
  }

  local bundle_id
  bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$plist")"
  [[ "$bundle_id" == "org.telugukeyboard.inputmethod.TeluguKeyboard" ]] || {
    echo "error: unexpected bundle id: $bundle_id" >&2
    return 1
  }

  codesign --verify --strict --verbose=2 "$app"
  codesign -dv --verbose=4 "$app" 2>&1 | grep -E 'Authority=Developer ID Application|Authority=Apple Root CA' >/dev/null
  xcrun stapler validate "$app"
  spctl --assess --type execute -vv "$app"
}

verify_pkg() {
  local pkg="$1"

  [[ -f "$pkg" ]] || {
    echo "error: package does not exist: $pkg" >&2
    return 1
  }

  pkgutil --check-signature "$pkg" | grep -E 'Developer ID Installer|Status: signed by a developer certificate' >/dev/null
  xcrun stapler validate "$pkg"
  spctl --assess --type install -vv "$pkg"
}

for artifact in "$@"; do
  case "$artifact" in
    *.app)
      echo "Verifying app: $artifact"
      verify_app "$artifact"
      ;;
    *.pkg)
      echo "Verifying package: $artifact"
      verify_pkg "$artifact"
      ;;
    *)
      echo "error: unsupported artifact: $artifact" >&2
      exit 2
      ;;
  esac
done

echo "Release artifact verification passed"
