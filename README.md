# strunkify

Make your coding agents write like Strunk - plain, direct, and short.

One 260 word skill file and a one-line directive.

## Install

```sh
git clone https://github.com/pailhead/strunkify
sh strunkify/install.sh
```

The installer detects Claude Code (`~/.claude`) and Codex (`~/.codex`) and, for each:

- symlinks [skill/strunkify](skill/strunkify) into its `skills/` directory;
- appends one line to its global instructions (`CLAUDE.md` / `AGENTS.md`):

> Write all prose in Strunk's style: active voice, omit needless words, concrete language, no hedging or filler.

Idempotent — run it twice, nothing doubles. New sessions pick it up; open ones keep their old rules.

## What you get

**Always on.** The directive governs every response the agent writes - explanations, reviews, summaries.

**On demand.** `/strunkify <text>` invokes the full eight rules and calibration examples on any prose you paste.

## Does it work?

Maybe, try it out. [demo/](demo/) holds a controlled comparison: two identical agents reviewed the same flawed function, one plain, one under the rules. The plain one opens:

> Thanks for sharing this — the function is straightforward, but there are a few issues worth fixing before it ships…

The governed one opens:

> Four problems, one of them severe.

Same four findings, 45% fewer words. Numbers in [demo/verify.md](demo/verify.md).

Run your own A/B:

```sh
sh demo/compare.sh "your prompt here"
```

It runs the prompt twice through fresh `claude -p` sessions — directive stripped, then restored — and prints both answers with word counts.

## Uninstall

```sh
rm ~/.claude/skills/strunkify ~/.codex/skills/strunkify
```

Then delete the "Write all prose in Strunk's style…" line from `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`.
