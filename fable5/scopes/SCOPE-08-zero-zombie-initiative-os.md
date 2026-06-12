# Scope — F7: Zero-Zombie Initiative Operating System

**Fable 5 prompt:** `zero-zombie-initiative-os.md` (8th and last in queue, 2026-06-12)
**Session id:** `0ad016e1-51c7-4bb0-bce7-e2d165522176`
**Outputs:** **None on disk** in the Fable 5 prompt repo (no `zero-zombie/` directory, no deliverable file). The prompt file itself was not redrafted; Fable 5's only edit was the appended `## Notes` block.
**Commit:** `28953ac` "fable5: ran zero-zombie-initiative-os.md" (auto-generated runner mark-done; contains no deliverable).

---

## What was asked

"Design a lightweight but rigorous operating system for all strategic
initiatives that enforces clear ownership, timeout, checkpoint cadence,
and automatic zombie-kill triggers. It must integrate with existing
Hermes tooling without adding ceremony." Grounded in
`/Users/mike/.hermes/protocols/`, the agents table, cron store, and
the Fable 5 queue mechanics.

## What it produced

Effectively nothing. The prompt is **structurally thin** (pre-
translation-layer; flagged as such by F2). The extracted prompt was
~12 lines of `text` block. The Fable 5 session likely returned a
short response that the runner did not persist to a deliverable
file, and the auto-commit captured only the runner's bookkeeping.

This is the second prompt in the queue (after F4 openclaw-doctor)
where the "thin prompt" pattern produced no observable deliverable.
The runner's success gate (`is_error: false`) was satisfied, so the
status was marked `done`, but no artifact exists.

## Scope for follow-up action

**In scope (the prompt's intent, not its delivery):**
- The Anti-Zombie Protocol (`BRF-OPS-POL-002`) as the policy source —
  currently exists on paper with no mechanical enforcement.
- All strategic initiatives currently running (Mission Control,
  XerahS refactor, MPC, Financial Report, TasteTrail, the Fable 5
  queue itself).
- The cron store's zombie-class jobs (2 already known to be
  erroring silently per F3 evidence).
- The Fable 5 queue's own state-tracking bug (F3 NOTE 2026-06-12).

**Out of scope (per the prompt):**
- A new tool — the brief says "integrate with existing Hermes
  tooling without adding ceremony."
- Per-initiative content — this is meta, the OS above the
  initiatives.
- A philosophical take on initiative management — this is
  operational, not strategic.

**Decide alone:** none — no deliverable was produced.

**Don't decide alone:** without a deliverable, there is nothing to
decide on. This scope is a *debt record*: the prompt is marked done
in `progress.json` but produced no artifact.

## What the deliverables made possible

- **Nothing yet.** The cron health sentinel (F3 F2 / F5 L3) is the
  mechanical implementation of "zombie-kill triggers"; it is still
  unbuilt. The Fable 5 queue's own zombie-kill for stuck
  `running` entries was *hand-implemented* by Vladislava
  (commit `e4de4d0` reconciling `ecosystem-antifragility-audit.md`,
  commit `878ea79` reconciling `leverage-point-mapping.md`, plus
  the payload-level reconciliation note added to the cron job
  `1ebe8e1b-…`).

## Headline metric

**Deliverables produced: 0.**
**Status in progress.json: done.**
**Lasting impact: none yet observable.**

This is the queue's clearest miss. The Fable 5 success gate
(`is_error: false`) was satisfied but the prompt was so thin that
"success" means "ran without erroring," not "produced an artifact."

## Current status

**Marked done; no artifact; debt.** To get the actual initiative OS,
the prompt needs to be retro-translated through F2 (translation
layer) and re-queued, with a clear "Output: PATH" clause so the
runner has somewhere to put the deliverable. The F5 leverage map
explicitly identifies this as the absorption point for L3
("closed-loop failure handling") — i.e. the cron sentinel and the
zombie-kill triggers are *the same artifact* this prompt was
supposed to produce. Without F7, L3 is not absorbable.

Mike's standing question "Is my call in relation to audit actions?"
applies here most acutely: this is an audit that produced no plan
and no actions, and yet was marked complete.

## Recommendation

The Fable 5 queue's `success gate` is currently `is_error: false`,
which is a too-loose definition of "done." A more honest gate
would require: (a) a deliverable file written, (b) deliverable
committed, (c) deliverable's first non-blank line contains
"Output:" or a heading matching the prompt's stated "Done looks
like:" clause. This is a runner change, not a Fable 5 prompt
change, and would be F1.5 (runner hardening) in the leverage map.
