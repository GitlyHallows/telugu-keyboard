# Contributing

Thank you for helping make Telugu easier to write in Telugu script on macOS.

## Start With An Issue

Open or find an issue before opening a pull request. This keeps fixes focused and makes it easier to review transliteration changes.

Use the issue templates for:

- wrong transliteration;
- install problems;
- feature requests.

One pull request should solve one issue.

## Local Setup

Requirements:

- macOS 14 or newer;
- Swift 6 or newer;
- Xcode command line tools.

Run the full regression suite before opening a pull request:

```sh
script/ci.sh
```

The suite runs:

- `swift build`
- `swift run telugu-keyboard-smoke-tests`
- `swift run telugu-keyboard-quality-tests`

For real macOS input routing changes, also run:

```sh
script/test_input_method_e2e.sh
```

That script must close only its own TextEdit test document.

## Transliteration Corrections

Every user-confirmed transliteration correction must be recorded in `data/correction_ledger.tsv` using the categories in `docs/CORRECTION_PROCESS.md`.

Do not add a mapping blindly. Classify each correction as one of:

- exact common word;
- generalized suffix or pattern;
- candidate-ranking feature;
- local user-learning case.

Add or update tests so the correction cannot regress.

## Privacy Rules

Runtime typing must stay local to the Mac.

- Do not add runtime calls to any network transliteration service.
- Do not send typed text, candidate selections, learned words, or settings over the internet.
- Keep development-only benchmark scripts separate from runtime code.
- Keep user learning under `~/Library/Application Support/TeluguKeyboard/`.

## Pull Request Checklist

Before marking a PR ready for review:

- link the issue it fixes;
- run `script/ci.sh` locally;
- update tests for behavior changes;
- update `data/correction_ledger.tsv` for transliteration corrections;
- update docs for install, privacy, or contributor-facing behavior changes;
- include screenshots or recordings for installer or user-facing UI changes.

## Maintainer Review

The `master` branch should require:

- `Telugu Keyboard CI / Swift regression suite`;
- at least one approval;
- code-owner review;
- stale approval dismissal after new commits;
- no direct pushes.

GitHub allows contributors to open pull requests before checks pass. Branch protection prevents merging until checks and reviews pass.
