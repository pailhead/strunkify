# Strunkify Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A single-file skill plus a one-line global directive that make all Claude prose follow Strunk's rules, verified by a before/after demo.

**Architecture:** The repo holds the canonical skill (`skill/strunkify/SKILL.md`), an idempotent `install.sh` that symlinks the skill into `~/.claude/skills/` and appends one directive line to `~/.claude/CLAUDE.md`, and a `demo/` directory proving the effect: two subagents get the same review task, one plain and one with the rules; mechanical checks compare the outputs.

**Tech Stack:** Markdown, POSIX sh, grep/wc. No dependencies.

**Environment note:** `~/.claude/CLAUDE.md` does not exist yet on this machine; `install.sh` creates it via append. `~/.claude/skills/` may not exist; `install.sh` creates it.

---

### Task 1: The skill file

**Files:**
- Create: `skill/strunkify/SKILL.md`

- [ ] **Step 1: Write the skill file**

Create `skill/strunkify/SKILL.md` with exactly this content:

```markdown
---
name: strunkify
description: Use when writing any prose a human will read — feedback, reviews, explanations, summaries, docs, commit messages. Applies Strunk's rules to make it clear and brief.
---

# Strunkify

Eight rules govern all prose:

1. **Use active voice.** "The parser rejects empty input," not "empty input is rejected by the parser."
2. **Omit needless words.** Every word must tell. Cut "the fact that," "in order to," "it is worth noting that."
3. **Put statements in positive form.** Say what is, not what is not. "The cache misses" beats "the cache does not hit."
4. **Use definite, specific, concrete language.** "Retries three times, then fails" beats "attempts recovery several times."
5. **Place emphatic words at the end of the sentence.** The last word lands hardest.
6. **One paragraph per topic; open with the topic sentence.**
7. **Do not hedge.** Cut "might be worth considering," "could potentially," "it's important to note." State the fact, or state your actual uncertainty plainly.
8. **No filler openers.** Never "Great question!" or "Certainly!" Begin with the answer.

## Calibration

Before: "It might be worth considering that there could potentially be a performance issue with this loop."
After: "The loop iterates twice per element; once suffices."

Before: "This is a great start! However, it's important to note that error handling could be improved in several places."
After: "Three call sites swallow errors. Handle them or let them propagate."

Before: "The function is called by the scheduler and the results are stored in the cache."
After: "The scheduler calls the function and caches the results."
```

- [ ] **Step 2: Verify the token budget**

Run: `wc -w skill/strunkify/SKILL.md`
Expected: fewer than 300 words (≈400 tokens). If over, cut calibration examples until under.

- [ ] **Step 3: Commit**

```bash
git add skill/strunkify/SKILL.md
git commit -m "feat: add strunkify skill"
```

---

### Task 2: install.sh

**Files:**
- Create: `install.sh`

- [ ] **Step 1: Write the installer**

Create `install.sh` with exactly this content:

```sh
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
```

- [ ] **Step 2: Make it executable**

Run: `chmod +x install.sh`

- [ ] **Step 3: Test in a sandbox HOME**

Run:

```bash
SANDBOX=$(mktemp -d)
mkdir -p "$SANDBOX/.claude"
HOME="$SANDBOX" sh install.sh
HOME="$SANDBOX" sh install.sh
readlink "$SANDBOX/.claude/skills/strunkify"
grep -cF "strunkify skill holds the full rules" "$SANDBOX/.claude/CLAUDE.md"
rm -rf "$SANDBOX"
```

Expected: both runs print "linked"; first run prints "appended", second "already present"; readlink prints the repo skill path; grep count is exactly `1` (idempotent).

- [ ] **Step 4: Commit**

```bash
git add install.sh
git commit -m "feat: add idempotent installer"
```

---

### Task 3: Demo task file

**Files:**
- Create: `demo/task.md`

- [ ] **Step 1: Write the canned review task**

Create `demo/task.md` with exactly this content:

````markdown
# Review task

Review this function and write feedback for its author.

```python
def get_user_data(id):
    try:
        result = db.query("SELECT * FROM users WHERE id = " + str(id))
    except:
        result = None
    data = []
    for r in result:
        data.append(r)
    return data
```
````

- [ ] **Step 2: Commit**

```bash
git add demo/task.md
git commit -m "feat: add demo review task"
```

---

### Task 4: Generate before/after outputs

**Files:**
- Create: `demo/before.md`
- Create: `demo/after.md`

- [ ] **Step 1: Dispatch the "before" subagent**

Dispatch a general-purpose subagent with exactly this prompt (substituting the code block from `demo/task.md`):

> You are reviewing code for a colleague. Review the following function and write your feedback as you normally would. Return only the feedback text.
>
> [contents of demo/task.md]

Save its output verbatim to `demo/before.md`.

- [ ] **Step 2: Dispatch the "after" subagent**

Dispatch a general-purpose subagent with exactly this prompt:

> The following style rules govern everything you write.
>
> [full contents of skill/strunkify/SKILL.md, frontmatter removed]
>
> You are reviewing code for a colleague. Review the following function and write your feedback. Return only the feedback text.
>
> [contents of demo/task.md]

Save its output verbatim to `demo/after.md`.

- [ ] **Step 3: Commit**

```bash
git add demo/before.md demo/after.md
git commit -m "feat: capture before/after demo outputs"
```

---

### Task 5: Verification

**Files:**
- Create: `demo/verify.md`

- [ ] **Step 1: Run the mechanical checks**

Run:

```bash
wc -w demo/before.md demo/after.md
grep -ciE "might be worth|could potentially|it.s important to note|perhaps consider|you may want to|great question|certainly|worth noting" demo/after.md || echo "0 hedges"
grep -ciE "might be worth|could potentially|it.s important to note|perhaps consider|you may want to|great question|certainly|worth noting" demo/before.md || echo "0 hedges"
```

- [ ] **Step 2: Read both outputs**

Read `demo/before.md` and `demo/after.md`. Confirm `after.md` uses active voice throughout and opens with substance, not filler. Note any passive constructions found.

- [ ] **Step 3: Write demo/verify.md**

Create `demo/verify.md` recording the results in this format (fill in actual numbers):

```markdown
# Verification

| Check | before.md | after.md |
|---|---|---|
| Words | N | N (−X%) |
| Hedge/filler phrases | N | N |

Passive-voice read: [one sentence on what was found in after.md]

Success criteria: after.md is materially shorter, has zero hedge phrases,
zero filler openers, and reads in active voice. Result: PASS/FAIL.
```

If the result is FAIL (hedges present, or after.md not shorter), revise SKILL.md's rules or calibration examples, re-run Task 4 Step 2, and re-verify. Record the final passing run.

- [ ] **Step 4: Commit**

```bash
git add demo/verify.md
git commit -m "feat: add before/after verification results"
```

---

### Task 6: Live install

**Files:**
- Modify: `~/.claude/CLAUDE.md` (created if absent)
- Create: `~/.claude/skills/strunkify` (symlink)

- [ ] **Step 1: Run the installer for real**

Run: `sh install.sh`
Expected: "linked ..." and "directive appended ..." (CLAUDE.md does not exist yet on this machine, so both actions fire).

- [ ] **Step 2: Verify the install**

Run:

```bash
readlink ~/.claude/skills/strunkify
tail -2 ~/.claude/CLAUDE.md
```

Expected: symlink points into the repo; last line of CLAUDE.md is the directive.

- [ ] **Step 3: Report**

Show the user the tail of `~/.claude/CLAUDE.md` and note that the directive takes effect in new sessions.
