# Security Policy

## Supported Versions

Security fixes are provided for the latest public release. Older releases may receive fixes at maintainer discretion.

## Reporting A Vulnerability

Please do not open a public issue for a vulnerability that could put users at risk.

Report privately through GitHub Security Advisories once the repository is public. Include:

- a short summary;
- affected version or commit;
- reproduction steps;
- logs, screenshots, or proof of concept if available;
- whether the issue could expose typed text, learned words, or local settings.

## Privacy-Sensitive Areas

The most sensitive parts of this project are:

- macOS input method routing;
- candidate learning stored under `~/Library/Application Support/TeluguKeyboard/`;
- installer scripts and permissions;
- any code path that might introduce network access.

Runtime typing must remain local-only.
