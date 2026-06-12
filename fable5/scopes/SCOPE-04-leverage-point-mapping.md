# Scope — F5: Leverage-Point Mapping for Next Quarter

**Fable 5 prompt:** `leverage-point-mapping.md` (4th in queue, 2026-06-11)
**Session id:** `89218505-d198-41ec-8ae0-1213f383b141`
**Output:** `/Users/mike/Projects/BriarForge/prompts/fable5/leverage-map/LEVERAGE-MAP.md` (347 lines, 19 KiB)
**Commits:** `8934896`, `6e692de` (cross-link to antifragility F1-F5)

---

## What was asked

"Map the highest-leverage intervention points across active strategic
threads" using KovaForge skills, Aoife skills, protocols, the antifragility
baseline, and the queue state — with the goal of reducing future user
steering and increasing autonomous execution quality over 90 days.

## What it produced

- A precise definition of **"steering event"** = any time a human
  (Mike, or a reconciling agent) must intervene in work the system was
  supposed to do alone: repairing a goal, requeueing a run, reconciling
  state, noticing a failure, correcting an agent that followed wrong
  guidance. **Measured baseline: ≥5 steering events in the last 48h**
  (verified one-by-one in the document).
- **4 ranked leverage points** (L1-L4), each with before/after metrics,
  dependency map, 30/60/90 rollout:
  - **L1** Validated goal contract — apply the translation-layer rubric
    *as a gate* to every Fable 5 prompt before queueing. Target: 0
    pre-rubric prompts in the queue by day 30.
  - **L2** One source of truth for capability knowledge — make the
    ecosystem resolution registry (F3 F1 upgrade) the only place an
    agent looks up a skill. Target: 39→0 dangling refs and 5→0
    contradictory duplicates by day 60.
  - **L3** Closed-loop failure handling — build the cron health sentinel
    (F3 F2 upgrade) and integrate with the Anti-Zombie Protocol. Target:
    mean-time-to-detect from unbounded to <24h by day 45.
  - **L4** Mechanical incident→control metabolism — every incident class
    observed once becomes mechanically impossible to repeat unnoticed
    (the F1 validate-skills linter applied to all 5 skills roots).
    Target: by day 90, every new incident in the prior 30 days
    corresponds to a control that fired.
- Observation: the **4 remaining pending prompts** in the queue
  (openclaw-doctor, skill-sustainer, xerahs, zero-zombie) *each map
  to a slice of this map* — so executing the queue IS executing
  L1-L4 by construction, and their thin extractions will produce
  lower leverage than re-translating them first.

## Scope for follow-up action

**In scope (the map covers):**
- The Fable 5 prompt queue, the translation layer, the skills repo
  (all 5 resolution roots), the cron store, the antifragility
  assessment F1-F5.
- 90-day horizon from 2026-06-12.
- The cross-Fable-5 cross-link table: which Fable 5 outputs address
  which leverage point.

**Out of scope:**
- Beyond-90-day strategic work (this is a quarter plan, not annual).
- The 4 pending prompts' *content* (they get re-translated or run
  as-is, not redrafted).
- Direct CEO/people decisions (L1-L4 all operate at the system
  level, not the headcount level).

**Decide alone:** the L1 gate mechanism (cron-blocked vs
advisory); the L2 registry's canonical name (likely
`validate-ecosystem.py` per the F3 plan); the L3 sentinel's
delivery channel; the L4 "mechanically impossible to repeat"
ratchet metric (likely "lint failures per commit" on the skills
repo).

**Don't decide alone:** the order of L1-L4 (the map ranks them
L1<L2<L3<L4 by leverage, but execution order is a Mike call —
L4 is highest-leverage but highest-effort); whether to
retro-translate the 4 thin prompts before running them
(costs 1 Fable 5 window per prompt to re-translate); the
90-day horizon extension to 6 months if any L* slips.

## What the deliverables made possible

- **Direct absorption of F3** — the F1-F5 fragility sources from
  the antifragility audit are explicitly addressed by L1-L4.
- **The cron sentinel's design** — L3's "closed-loop failure
  handling" inherits the F3 F2 owner (Declan) and rollback
  criteria verbatim.
- **A re-translation queue** — the document's observation about
  the 4 thin prompts is now a known planning input for any
  future Fable 5 run scheduling.

## Headline metric

Steering events per 30d, baseline vs target:
- **Baseline:** ≥5 per 48h = ~75 per 30d.
- **Target after 90 days:** ≤1 per 30d (L1+L2+L3+L4 all landed).
- **Stretch:** 0 (if L4's "mechanical impossibility" claim holds).

## Current status

**Complete and committed.** 4 leverage points ranked and cross-linked
to F3. The first absorption (F7 zero-zombie-OS = L3's closed-loop
failure handling) was already triggered as a separate Fable 5 prompt
the same day. F2 (cron-sentinel) and F4 (validate-ecosystem) not yet
built; F1 (gate) not yet built.
