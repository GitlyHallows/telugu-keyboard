#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -ne 1 ]]; then
    echo "usage: script/import_accepted_review_rows.sh <review.tsv>" >&2
    exit 2
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REVIEW="$1"
COMMON_CHAT_TSV="${COMMON_CHAT_TSV:-$ROOT/Sources/TeluguKeyboardCore/Resources/common_chat.tsv}"
IMPORT_SCORE="${IMPORT_SCORE:-300}"

if [[ ! -f "$REVIEW" ]]; then
    echo "review file not found: $REVIEW" >&2
    exit 2
fi

if [[ ! -f "$COMMON_CHAT_TSV" ]]; then
    echo "common chat TSV not found: $COMMON_CHAT_TSV" >&2
    exit 2
fi

python3 - "$REVIEW" "$COMMON_CHAT_TSV" "$IMPORT_SCORE" <<'PY'
import csv
import os
import re
import sys
import tempfile

review_path, common_path, import_score = sys.argv[1:4]

def normalize(value):
    return value.strip().lower().replace("'", "").replace("-", "")

with open(common_path, encoding="utf-8", newline="") as handle:
    common_lines = handle.read().splitlines()

kept_lines = []
index_by_key = {}
for line in common_lines:
    if not line or line.startswith("#"):
        kept_lines.append(line)
        continue
    columns = line.split("\t")
    key = normalize(columns[0]) if columns else ""
    if not key or key in index_by_key:
        continue
    index_by_key[key] = len(kept_lines)
    kept_lines.append(line)

accepted = 0
replaced = 0
skipped = 0

with open(review_path, encoding="utf-8", newline="") as handle:
    reader = csv.DictReader(handle, delimiter="\t")
    required = {"roman", "candidate_top", "status"}
    if not reader.fieldnames or not required.issubset(set(reader.fieldnames)):
        print("review TSV must include roman, candidate_top, and status columns", file=sys.stderr)
        sys.exit(2)

    for row in reader:
        roman = (row.get("roman") or "").strip()
        candidate_top = (row.get("candidate_top") or "").strip()
        status = (row.get("status") or "").strip().lower()
        key = normalize(roman)

        if status not in {"accepted", "replace"}:
            skipped += 1
            continue
        if not roman or not candidate_top:
            skipped += 1
            continue
        if re.search(r"\s", roman):
            print(f"Skipping phrase row; common_chat.tsv stores word mappings only: {roman}", file=sys.stderr)
            skipped += 1
            continue

        line = f"{key}\t{candidate_top}\t{import_score}"
        if key in index_by_key:
            if status == "replace":
                kept_lines[index_by_key[key]] = line
                replaced += 1
            else:
                skipped += 1
            continue

        index_by_key[key] = len(kept_lines)
        kept_lines.append(line)
        accepted += 1

directory = os.path.dirname(common_path) or "."
fd, temp_path = tempfile.mkstemp(prefix=".common_chat.", suffix=".tmp", dir=directory, text=True)
with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as handle:
    handle.write("\n".join(kept_lines))
    handle.write("\n")
os.replace(temp_path, common_path)

print(f"Imported review rows: accepted={accepted} replaced={replaced} skipped={skipped}")
PY
