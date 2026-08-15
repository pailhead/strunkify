# Verification

| Check | before.md | after.md |
|---|---|---|
| Words | 348 | 190 (−45%) |
| Hedge/filler phrases (grep) | 0 | 0 |

The hedge grep (`might be worth|could potentially|it's important to note|perhaps consider|you may want to|great question|certainly|worth noting`) caught nothing in either file. The manual read caught what the grep missed in before.md: a filler opener ("Thanks for sharing this —"), softeners ("worth fixing," "maybe the function should," "would help"), and a closing pleasantry ("Happy to look at the calling code if you want"). after.md contains none of these.

Passive-voice read: after.md is active throughout — every sentence leads with its actor ("The query concatenates," "Bare `except` catches," "The loop copies"). It opens with substance: "Four problems, one of them severe."

Success criteria: after.md is materially shorter, has zero hedge phrases,
zero filler openers, and reads in active voice. Result: PASS.
