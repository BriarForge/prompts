---
tags: [autonomy, ownership, state-machine, audit, ux, dx, ax, reusable]
category: autonomous
version: 1
last-used: 2026-11-11
---

# Own it, find the state machines, fix what's sure

```text
This codebase is yours: what it's for and how it's built are your call, and you'll keep building on it. You own it so you can remove illegal and duplicate state you would trip over next time.

Read the whole project before you edit. Infer what it is for from the code. Preserve every behavior a person can already reach. When the docs and the code disagree, follow the code and record the disagreement.

Find the implicit state machines. A flow is one when its phases live in scattered booleans, enums, nulls, refs, and conditions, and nothing declares the legal states and transitions. That is where the project is broken, inconsistent, inefficient, or no longer needed. Count a finding when you see a combination the interface cannot draw, two flags for one phase, a transition that double-applies or drops work, state kept in sync by hand, or a flag nothing reads.

Also note broken, inconsistent, inefficient, or unused code that is not a state machine. Rank a state a person can hit above a dead file. Rank the next agent's likely new flag above a dead file too.

Raise all three with any change, and lower none. UX: a person reaches only states the interface can explain, and no transition double-fires, drops work, or strands them. DX: the legal states and transitions sit in one place a person can read. AX: the next agent sees those states and extends the machine, and does not add another flag.

Change one only when you can show all four: the files and the flags, the defect in one sentence, a change that removes the defect with no new guard, and a check you ran that every reachable behavior still holds. Prefer one status field, a discriminated union, or the pattern this repo already uses.

Add a test only when it fails on the illegal combination and passes after the fix. Add no docs. Leave auth, billing, migrations, persisted formats, and public APIs on the list, even when you are sure. A new behavior, chosen among several the code allows, goes on the list. If a fix changes a behavior a person can already reach, revert that part and list it.

Apply the changes that meet the bar, highest rank first. Stop while one person can review the diff. Mark every sure fix you skipped as ready. Run the tests this repo already has. If you cannot run them, say so, and do not call the fix verified.

List everything you did not change: the place, the states or the waste, which of UX, DX, and AX it hurts, why you left it, and the change you would make if told to.

Close in four parts, in order, and name every file you touched: what the product is; the machines and the other findings, ranked; the changes and the checks you ran; the list. A summary that skips a file is incomplete.
```

# Notes
- One maintenance session. Merges the three prompts in this folder: [The codebase is yours](codebase-ownership.md), [Find implicit state machines](find-implicit-state-machines.md), and [Full project audit](full-project-audit.md).
- You own the code so you can remove illegal and duplicate state. A later "don't refactor" line does not cancel the ownership sentence, so the boundary is written into that sentence.
- Leave this out of AGENTS.md and CLAUDE.md. A standing ownership line keeps firing on ordinary edits.
- Review the diff. The closing file list is the record; the model's summary often skips small edits.
- Leave auth, billing, migrations, persisted formats, and public APIs on the review list.
- On a large repo, add one line: read-only search, one directory per helper.
- Run from the project root in a coding agent session.
