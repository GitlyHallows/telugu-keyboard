#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

swift build
swift run telugu-keyboard-smoke-tests
swift run telugu-keyboard-quality-tests
