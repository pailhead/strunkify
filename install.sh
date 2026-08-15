#!/bin/sh
set -eu

SKILL_SRC="$(cd "$(dirname "$0")" && pwd)/skill/strunkify"
SKILL_DEST="$HOME/.claude/skills/strunkify"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
DIRECTIVE="Write all prose in Strunk's style: active voice, omit needless words, concrete language, no hedging or filler. The strunkify skill holds the full rules; they govern every response."

[ -d "$HOME/.claude" ] || { echo "error: ~/.claude not found — is Claude Code installed?" >&2; exit 1; }

[ -d "$SKILL_SRC" ] || { echo "error: $SKILL_SRC not found — run install.sh from its repo" >&2; exit 1; }

mkdir -p "$HOME/.claude/skills"
ln -sfn "$SKILL_SRC" "$SKILL_DEST"
echo "linked $SKILL_DEST -> $SKILL_SRC"

if [ -f "$CLAUDE_MD" ] && grep -qF "strunkify skill holds the full rules" "$CLAUDE_MD"; then
  echo "directive already present in $CLAUDE_MD"
else
  printf '\n%s\n' "$DIRECTIVE" >> "$CLAUDE_MD"
  echo "directive appended to $CLAUDE_MD"
fi
