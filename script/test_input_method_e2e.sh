#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_SUPPORT="$HOME/Library/Application Support/TeluguKeyboard"
SETTINGS_PATH="$APP_SUPPORT/settings.json"
BACKUP_DIR="$(mktemp -d)"

restore_settings() {
    if [[ -f "$BACKUP_DIR/settings.json" ]]; then
        mkdir -p "$APP_SUPPORT"
        cp "$BACKUP_DIR/settings.json" "$SETTINGS_PATH"
    else
        rm -f "$SETTINGS_PATH"
    fi
    rm -rf "$BACKUP_DIR"
    "$ROOT/script/install_input_method.sh" >/dev/null 2>&1 || true
}

mkdir -p "$APP_SUPPORT"
if [[ -f "$SETTINGS_PATH" ]]; then
    cp "$SETTINGS_PATH" "$BACKUP_DIR/settings.json"
fi
trap restore_settings EXIT

printf '{"localLearningEnabled":false,"privateModeEnabled":false}\n' > "$SETTINGS_PATH"

"$ROOT/script/install_input_method.sh" >/dev/null

result="$(osascript <<'OSA'
set failures to {}
set testDocument to missing value

tell application "TextEdit"
    launch
    activate
end tell

set testCases to {¬
    {"padaku", "పడకు "}, ¬
    {"ela unnav", "ఎలా ఉన్నావ్ "}, ¬
    {"em chestunnav", "ఏం చేస్తున్నావ్ "}, ¬
    {"naake", "నాకే "}, ¬
    {"bagundi kani ilaa", "బాగుంది కానీ ఇలా "}, ¬
    {"yellappudoo", "యెల్లప్పుడూ "}, ¬
    {"ardham ayyinda", "అర్థం అయ్యిందా "}, ¬
    {"vachadu", "వచ్చాడు "}, ¬
    {"pothundo", "పోతుందో "}, ¬
    {"kooda", "కూడా "}, ¬
    {"padaa", "పదా "}, ¬
    {"pettuko", "పెట్టుకో "}, ¬
    {"puchukunte", "పుచ్చుకుంటే "}, ¬
    {"choosko", "చూస్కో "}, ¬
    {"veltunnavo", "వెళ్తున్నావో "}, ¬
    {"lekunna", "లేకున్నా "}, ¬
    {"lekapoina", "లేకపోయినా "}, ¬
    {"poina sari", "పోయిన సారి "}, ¬
    {"elagaina sare", "ఎలాగైనా సరే "}, ¬
    {"ivvana", "ఇవ్వనా "}, ¬
    {"isthunna", "ఇస్తున్నా "}, ¬
    {"ichi", "ఇచ్చి "}, ¬
    {"ichanu", "ఇచ్చాను "}, ¬
    {"ichindi", "ఇచ్చింది "}, ¬
    {"puchindi", "పుచ్చింది "}, ¬
    {"pichi", "పిచ్చి "}, ¬
    {"pachi", "పచ్చి "}, ¬
    {"ichana vadiki", "ఇచ్చిన వాడికి "} ¬
}

repeat with testCase in testCases
    set romanInput to item 1 of testCase
    set expectedText to item 2 of testCase
    tell application "TextEdit"
        activate
        set testDocument to make new document
        set text of testDocument to ""
        try
            set index of window 1 to 1
        end try
    end tell
    tell application "System Events"
        tell process "TextEdit"
            set frontmost to true
            try
                perform action "AXRaise" of window 1
            end try
            try
                click text area 1 of scroll area 1 of window 1
            end try
        end tell
    end tell
    delay 0.5
    tell application "System Events"
        keystroke (romanInput & " ")
    end tell
    delay 1
    tell application "TextEdit"
        set actualText to text of testDocument
    end tell
    if actualText is not expectedText then
        set end of failures to romanInput & tab & expectedText & tab & actualText
    end if
    tell application "TextEdit"
        if testDocument is not missing value then
            close testDocument saving no
        end if
    end tell
    set testDocument to missing value
end repeat

tell application "TextEdit"
    if testDocument is not missing value then
        close testDocument saving no
    end if
end tell

if (count of failures) is 0 then
    return "OK"
end if
return item 1 of failures
OSA
)"

if [[ "$result" != "OK" ]]; then
    IFS=$'\t' read -r roman expected actual <<< "$result"
    printf 'IME end-to-end test failed for "%s"\n' "$roman" >&2
    printf 'expected: %s\n' "$expected" >&2
    printf 'actual:   %s\n' "$actual" >&2
    exit 1
fi

echo "IME end-to-end tests passed"
