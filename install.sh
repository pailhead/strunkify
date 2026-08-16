#!/bin/sh
set -eu

SKILL_SRC="$(cd "$(dirname "$0")" && pwd)/skill/strunkify"
DIRECTIVE="Write all prose in Strunk's style: active voice, omit needless words, concrete language, no hedging or filler. The strunkify skill holds the full rules; they govern every response."

[ -d "$SKILL_SRC" ] || { echo "error: $SKILL_SRC not found — run install.sh from its repo" >&2; exit 1; }

# install_into <agent config dir> <instructions filename>
install_into() {
  dir="$1"; md="$1/$2"
  mkdir -p "$dir/skills"
  ln -sfn "$SKILL_SRC" "$dir/skills/strunkify"
  echo "linked $dir/skills/strunkify -> $SKILL_SRC"
  if [ -f "$md" ] && grep -qF "strunkify skill holds the full rules" "$md"; then
    echo "directive already present in $md"
  else
    printf '\n%s\n' "$DIRECTIVE" >> "$md"
    echo "directive appended to $md"
  fi
}

found=0
[ -d "$HOME/.claude" ] && { install_into "$HOME/.claude" "CLAUDE.md"; found=1; }
[ -d "$HOME/.codex" ] && { install_into "$HOME/.codex" "AGENTS.md"; found=1; }

[ "$found" -eq 1 ] || { echo "error: neither ~/.claude nor ~/.codex found — install Claude Code or Codex first" >&2; exit 1; }
