#!/bin/sh
# A/B one prompt: directive off, then on. Same model, fresh session each run.
set -eu

PROMPT="${1:?usage: compare.sh \"<prompt>\"}"
MD="$HOME/.claude/CLAUDE.md"
MARK="Write all prose in Strunk's style"
OUT_OFF=$(mktemp) OUT_ON=$(mktemp)

[ -f "$MD" ] && grep -qF "$MARK" "$MD" || { echo "error: directive not installed — run install.sh first" >&2; exit 1; }

cp "$MD" "$MD.bak"
trap '[ -f "$MD.bak" ] && mv "$MD.bak" "$MD"; rm -f "$OUT_OFF" "$OUT_ON"' EXIT INT TERM

grep -vF "$MARK" "$MD.bak" > "$MD" || true
echo "=== OFF: directive removed ==="
claude -p "$PROMPT" | tee "$OUT_OFF"

mv "$MD.bak" "$MD"
echo
echo "=== ON: directive restored ==="
claude -p "$PROMPT" | tee "$OUT_ON"

echo
echo "=== word counts ==="
printf 'off: %s\non:  %s\n' "$(wc -w < "$OUT_OFF" | tr -d ' ')" "$(wc -w < "$OUT_ON" | tr -d ' ')"
