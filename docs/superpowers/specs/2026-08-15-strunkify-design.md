# Strunkify — Design

Date: 2026-08-15
Status: Approved approach (A); spec pending user review

## Purpose

Make all prose Claude and its subagents write — feedback, reviews, explanations, summaries — follow William Strunk Jr.'s *The Elements of Style*. Coverage is always-on, not per-invocation. The skill stays as light as possible: one file, no reference documents.

## Problem

LLM feedback runs long: hedges, filler openers, passive constructions, abstract language. Two constraints shape the fix:

1. The skill must stay light — a distilled rule sheet, not the full *Elements of Style* text. Loading thousands of tokens of reference material to write a paragraph defeats the purpose.
2. Skills fire only when invoked. "All output, always" needs an always-on directive.

## Architecture

Two parts: a tiny skill (the rulebook) and a one-line global directive (the enforcement).

```
~/projects/strunkify/            # this repo: canonical source + demo
├── skill/strunkify/SKILL.md     # the skill, single file
├── demo/
│   ├── task.md                  # canned review task given to both agents
│   ├── before.md                # plain agent output
│   ├── after.md                 # output from agent given the skill rules
│   └── verify.md                # word counts, hedge count, passive check
├── install.sh                   # symlink skill + append directive
└── docs/superpowers/specs/      # this spec

~/.claude/skills/strunkify       # symlink → repo skill/strunkify
~/.claude/CLAUDE.md              # + one directive line
```

## Components

### SKILL.md

- Frontmatter: `name: strunkify`; description triggers on writing any prose for humans — feedback, reviews, explanations, docs, commit messages.
- Body budget: **under 400 tokens.** Eight rules, three before/after pairs, nothing else.
- The eight rules (Strunk's composition rules, selected for what actually fixes LLM prose):
  1. Use active voice.
  2. Omit needless words.
  3. Put statements in positive form.
  4. Use definite, specific, concrete language.
  5. Place emphatic words at the end of the sentence.
  6. One paragraph per topic; begin with a topic sentence.
  7. Do not hedge ("might be worth considering", "it's important to note") unless the uncertainty is real.
  8. No filler openers ("Great question!", "Certainly!") or throat-clearing.
- Three calibration pairs: short bloated-LLM-prose excerpts with their strunkified rewrites.

### Global directive

One line appended to `~/.claude/CLAUDE.md`:

> Write all prose in Strunk's style: active voice, omit needless words, concrete language, no hedging or filler. The strunkify skill holds the full rules; they govern every response.

Global CLAUDE.md reaches subagents, which gives "all agents" coverage without hooks.

### install.sh

Idempotent: creates the symlink if absent; appends the directive only if not already present. No other side effects.

## Verification

Before/after demo, committed to the repo:

1. `demo/task.md`: a realistic task that elicits feedback prose (review a short code sample).
2. Dispatch two subagents with identical tasks: one plain (`before.md`), one with the SKILL.md rules prepended (`after.md`).
3. `demo/verify.md` records mechanical checks on the pair:
   - word count of each, and percent reduction;
   - hedge-phrase count in `after.md` (target: 0) — grep for "might be worth", "it's important to note", "could potentially", "perhaps consider", "you may want to";
   - passive-voice spot check (manual read; no dependency on a grammar tool).
4. Success criteria: `after.md` is materially shorter, contains zero hedge phrases and zero filler openers, and reads in active voice.

## Error handling

Minimal by design. install.sh fails loudly if `~/.claude` does not exist; re-running it is safe. Nothing else can fail at runtime — the skill is inert text.

## Out of scope

- Hook-based enforcement (rejected as Approach C).
- Automated grammar tooling; verification is grep + human read.
