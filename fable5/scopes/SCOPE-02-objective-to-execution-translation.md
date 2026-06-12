# Scope — F2: Objective-to-Execution Translation Layer

**Fable 5 prompt:** `objective-to-execution-translation.md` (2nd in queue, 2026-06-11)
**Session id:** `b0d6b11e-e3e0-48a6-a649-ec637964afa7`
**Outputs (all in `fable5/translation-layer/`):**
- `README.md` (27 lines, index)
- `RUBRIC.md` (116 lines, 7-criterion 0-2 score)
- `GOAL-TEMPLATE.md` (132 lines, the `/goal` block template)
- `CLAUDE.md` (57 lines, project memory)
- `examples/01-skills-repo-review.md` (validated example)
- `examples/02-xerahs-pipeline-reliability.md` (validated example + used to repair a broken queue prompt)
- `examples/03-monthly-financial-report.md` (validated example)
**Commits:** `4806cbc`, `e23935f`, `4d88176`, `2d9cac3`, `7a4f407`

---

## What was asked

"Build a reusable translation layer that converts high-level strategic
objectives into the precise goal statements, success criteria, and
verification methods that Fable 5 (and future Mythos models) can execute
with minimal back-and-forth."

## What it produced

A self-contained translation layer, not a single artifact:

1. **RUBRIC.md** — 7-criterion scoring (outcome-over-activity, grounded
   references, no-ambiguity, scope-explicit, success-criteria, verification
   method, failure-mode-aware) each scored 0-2. **Fable-ready threshold:**
   ≥12/14 with no criterion at 0. A single 0 means a predictable
   clarification round-trip or a silent wrong turn — fix before queueing.
2. **GOAL-TEMPLATE.md** — copy-paste `/goal` block template with all 7
   sections mapped to rubric criteria; 6-phase translation checklist
   (parse objective → ground references → extract scope → write success
   criteria → define verification → simulate the model taking it).
3. **examples/01..03** — three validated translations of real prompts
   (skills-repo review, xerahs pipeline, monthly financial report), each
   scored against the rubric.
4. **Side effect:** the broken `xerahs-pipeline-reliability-autonomy.md`
   queue prompt (early-closing fence, duplicate "Done" sections, placeholder
   skill list) was repaired *using* example 02 as the source of truth.

## Scope for follow-up action

**In scope (where the layer applies):**
- Every future Fable 5 / Mythos prompt before it enters the queue.
- The 4 remaining thin prompts in this queue (openclaw-doctor,
  skill-sustainer, xerahs, zero-zombie) which were flagged as pre-rubric.
- Any `/goal`-style goal block used elsewhere in the system (OpenClaw
  cron, Lobster workflows, agent handoffs).

**Out of scope:**
- The translation layer itself is not a runtime system — it does not
  auto-translate; it documents the method and provides the template.
  Operationalizing it (a script that takes a goal block and scores it
  against the rubric, blocking the queue if <12) was not built.
- The existing Fable 5 queue mechanics (still uses
  `run-next-fable5.sh` + `progress.json`).
- Non-Fable prompts (Codex exec, Lobster, etc.) — the rubric is
  Fable-class-specific.

**Decide alone:** the rubric's threshold (12/14) and the per-criterion
anchors; the 6-phase checklist order; the example set's coverage.

**Don't decide alone:** the gate behavior (is it advisory or blocking?),
who runs the translation (the queue agent itself, a separate pre-flight
cron, or a human in the loop), how the layer relates to OpenClaw's
existing `/goal` skill (if any).

## What the deliverables made possible

- F6 (skill-sustainer) used this layer's *form* to score each detected
  finding — `propose_patches.py` and the rubric are shaped the same way.
- F3 (antifragility) explicitly references "translation layer
  (`fable5/translation-layer/`)" as part of the memory/learning layer.
- The 4 remaining pre-rubric prompts can be retro-translated by hand
  (or by another Fable 5 run with `skill: translation-layer`).

## Headline metric

Translation round-trips per Fable 5 prompt, before vs after: before =
unmeasured, but the 4 pre-rubric prompts demonstrate the failure mode
(8-line extractions, `~/.hermes/` placeholders never verified). After =
no metrics yet, but the rubric is now defined and one prompt (xerahs)
was already repaired against it.

## Current status

**Complete and committed.** The 4 remaining pre-rubric prompts in the
queue are *not* retro-translated; they ran as-is. Translation layer is
passive documentation, not a gate.
