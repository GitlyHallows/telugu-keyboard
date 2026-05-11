# Release Checklist

Use this checklist before announcing Telugu Keyboard to non-technical users.

## Repository

- The public repository is initialized from the project directory only, not from any parent workspace.
- Internal planning and local workspace-context files listed in `.gitignore` are ignored.
- `README.md`, `CONTRIBUTING.md`, issue templates, PR template, license, notices, and security policy are present.
- GitHub `main` is protected by a ruleset or branch protection rule.

## CI And Review Gate

- Required status check: `Telugu Keyboard CI / Swift regression suite`.
- At least one approving review is required.
- Code-owner review is required.
- Stale approvals are dismissed when new commits are pushed.
- Direct pushes to `main` are blocked.

## Signing Prerequisites

Before creating a public installer, install:

- Developer ID Application certificate.
- Developer ID Installer certificate.
- Notary credentials saved with `xcrun notarytool store-credentials`.

## Build And Verify

```sh
script/ci.sh
DEVELOPER_ID_APPLICATION="Developer ID Application: Example (TEAMID)" \
DEVELOPER_ID_INSTALLER="Developer ID Installer: Example (TEAMID)" \
NOTARY_PROFILE="telugu-keyboard-notary" \
script/package_release.sh
script/verify_release_artifact.sh dist/release/TeluguKeyboard-*.pkg
```

## Unsigned Homebrew Beta

- Run `script/package_homebrew_cask_release.sh`.
- Upload `dist/homebrew/TeluguKeyboard-<version>.zip` to a GitHub release.
- Replace the owner, repo, and SHA256 placeholders in `Casks/telugu-keyboard.rb`.
- Test with `brew tap telugu-keyboard/local /path/to/telugu-keyboard && brew install --cask telugu-keyboard/local/telugu-keyboard`.
- Keep this documented as beta until Developer ID signing is available.

## Manual Install Check

Test on a clean macOS user account:

- Install from the downloaded package.
- Allow the macOS input-source permission.
- Switch using `fn` or globe.
- Type `padaku ` and confirm `పడకు `.
- Type `ela unnav ` and confirm `ఎలా ఉన్నావ్ `.
- Type `em chestunnav ` and confirm `ఏం చేస్తున్నావ్ `.
- Reinstall and confirm there is still only one **Telugu Keyboard** input source.
