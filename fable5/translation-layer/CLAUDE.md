# Translation Layer — Project Memory

Persistent memory for the objective→/goal translation layer. Update this file
whenever a translation teaches something new (failed run, surprising
clarification, new lint). Keep it short; this is loaded into context.

## What this is

A reusable layer that converts strategic objectives into Fable-ready /goal
blocks. Files:

- `RUBRIC.md` — 7 criteria, 0–2 each; ready = ≥12/14 with no zeros.
- `GOAL-TEMPLATE.md` — the /goal block template + 6-phase checklist + lints.
- `examples/01..03` — validated translations (audit goal, reliability-plan
  goal, recurring-ops goal).

## Operating rules learned from real runs (do not relearn these)

1. **Always mandate progressive `git-aoife` commits in long-run goals.** The
   2026-06-11 skills-review run was SIGKILLed by session timeout and lost all
   work; the rerun cost a full session. (Criterion 6.)
2. **Lint machine-extracted prompts before queueing.** The runner extracts with
   `sed -n '/```text/,/```/p'`; the xerahs prompt's early-closing fence silently
   dropped its Done/Verification sections. Dry-run extraction is now a Phase 6
   checklist item.
3. **Verify grounding by command at translation time, and date it.** The
   placeholder "(listed in original)" shipped to the queue once.
4. **Name the output path in the objective sentence.** The skills review
   invented `REVIEW-2026-06-11.md` because no path was given; it guessed well,
   but that's luck, not design.
5. **Wrappers only:** `git-aoife commit` / `git-aoife push`, never bare git
   push, in this and all KovaForge/BriarForge goal blocks.
6. Financial-channel outputs: no markdown tables, no em dashes; SMSF never
   mixes into personal cash flow; Playwright gate blocks uploads.

## Queue context (BriarForge/prompts/fable5)

- `run-next-fable5.sh` runs pending prompts via claude-auto, 4.5h timeout,
  success-gated on JSON `is_error`, reverts to pending on failure.
- `progress.json` is owned by the runner — goal runs should not edit it.
- Remaining pending prompts (as of 2026-06-12) that would benefit from
  retranslation through this layer before they run:
  `leverage-point-mapping.md` (extracts to only 8 lines — thinnest contract),
  `openclaw-doctor-resilience-autonomy.md`, `skill-evolution-maintenance-loop.md`,
  `zero-zombie-initiative-os.md`. (xerahs repaired 2026-06-11;
  ecosystem-antifragility-audit ran un-retranslated 2026-06-12 — it had to
  invent its output path, confirming rule 4. Its F5 intervention proposes
  moving the Phase-6 extraction lint into the runner itself; see
  `fable5/antifragility/ASSESSMENT.md`.)

## Open questions / next iterations

- Should Phase 6 lint become a pre-queue git hook or a runner check instead of
  a manual checklist item?
- Examples cover audit/plan/ops goal shapes; no example yet for a pure
  code-change goal (implement + tests green). Add one when the next real case
  appears.
