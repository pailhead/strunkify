#!/bin/sh
set -eu

SKILL_SRC="$(cd "$(dirname "$0")" && pwd)/skill/strunkify"
DIRECTIVE="Write all prose in Strunk's style: active voice, omit needless words, concrete language, no hedging or filler."

[ -d "$SKILL_SRC" ] || { echo "error: $SKILL_SRC not found — run install.sh from its repo" >&2; exit 1; }

found=0

# install_into <name> <agent config dir> [instructions filename]
# Skips agents whose config dir is absent. Symlinks the skill into
# <dir>/skills/; appends the directive to the instructions file, if the
# agent has one.
install_into() {
  name="$1"; dir="$2"; md="${3:-}"
  [ -d "$dir" ] || return 0
  found=1
  mkdir -p "$dir/skills"
  ln -sfn "$SKILL_SRC" "$dir/skills/strunkify"
  echo "$name: linked $dir/skills/strunkify"
  [ -n "$md" ] || return 0
  if [ -f "$dir/$md" ] && grep -qF "Write all prose in Strunk's style" "$dir/$md"; then
    echo "$name: directive already present in $dir/$md"
  else
    printf '\n%s\n' "$DIRECTIVE" >> "$dir/$md"
    echo "$name: directive appended to $dir/$md"
  fi
}

install_into "Claude Code" "${CLAUDE_CONFIG_DIR:-$HOME/.claude}" CLAUDE.md
install_into "Codex"       "${CODEX_HOME:-$HOME/.codex}"         AGENTS.md
install_into "Gemini CLI"  "$HOME/.gemini"                       GEMINI.md
install_into "Copilot CLI" "${COPILOT_HOME:-$HOME/.copilot}"     copilot-instructions.md
install_into "OpenCode"    "${XDG_CONFIG_HOME:-$HOME/.config}/opencode" AGENTS.md
install_into "Cursor"      "$HOME/.cursor"   # no global instructions file; skill only
install_into "agents.md standard" "$HOME/.agents"   # shared skills dir read by Cursor, OpenCode, Copilot, Gemini

[ "$found" -eq 1 ] || { echo "error: no supported agent found — install Claude Code, Codex, Gemini CLI, Copilot CLI, OpenCode, or Cursor first" >&2; exit 1; }
