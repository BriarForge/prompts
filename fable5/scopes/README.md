# Fable 5 Queue — Implementation Scopes

Created 2026-06-12 17:50 AWST, rewritten 17:55. One scope per Fable 5
prompt. **Each scope describes the implementation work the prompt
points at** — not the prompt's output, but what needs to be built,
merged, or wired up to action what the prompt produced.

Per Mike: "for example with the very first prompt that ran fable
created a review document. So the scope is to implement the items
found from that review." That is the framing for all 8.

| # | Scope | Drives from | End state | Effort |
|---|-------|-------------|-----------|--------|
| 1 | [SCOPE-01](SCOPE-01-skills-repo-overarching-review.md) | REVIEW-2026-06-11.md (P1–P7) | Repo 4.3 → 7.0/10; lint+CI live; 5 dups merged | ~3 days |
| 2 | [SCOPE-02](SCOPE-02-objective-to-execution-translation.md) | `translation-layer/` rubric + template | Rubric blocks the runner; 4 pre-rubric prompts retro-translated | ~2 days |
| 3 | [SCOPE-03](SCOPE-03-ecosystem-antifragility-audit.md) | `antifragility/ASSESSMENT.md` (F1–F5) | System 4.0 → 7.0/10; 5 upgrades live | ~3 days |
| 4 | [SCOPE-04](SCOPE-04-leverage-point-mapping.md) | `leverage-map/LEVERAGE-MAP.md` (L1–L4) | Steering events 5/48h → ≤1/30d at day 90 | ~5 days / 90 |
| 5 | [SCOPE-05](SCOPE-05-openclaw-doctor-resilience-autonomy.md) | `7b06f1c` (14 skill changes, no doctor redesign) | Side-effects verified; doctor rubric + 2 scenarios + plan | ~2 days |
| 6 | [SCOPE-06](SCOPE-06-skill-evolution-maintenance-loop.md) | `skill-sustainer/` (built; 13 patches + 2 PROPOSAL pending) | 15 items curated; daily cron live; loop self-sustaining | ~1 day curator + cron |
| 7 | [SCOPE-07](SCOPE-07-xerahs-pipeline-reliability-autonomy.md) | `xerahs/docs/RELIABILITY-PLAN.md` (U1–U10, 5 human actions) | 0/8 observations live; U1–U10 landed | ~3 weeks |
| 8 | [SCOPE-08](SCOPE-08-zero-zombie-initiative-os.md) | (no artifact — pre-rubric extraction miss) | Sentinel built; runner gate tightened; 4 enforcement hooks | ~2 days |

## Reading order

The 8 scopes overlap heavily. The cross-scope sections in each file
name the others explicitly; here is the shortest path through them:

1. **Scope 02** (translation layer gate) — the meta-fix; everything
   downstream benefits from it.
2. **Scope 04** (L1–L4 30/60/90) — the quarter plan; tells you
   when each scope's work lands in the sequence.
3. **Scope 03** (F1–F5) — the antifragility upgrades. F5 is Scope 02
   restated; F1–F4 are the meaty work.
4. **Scope 01** (skills review P1–P7) — F1 of F3 = P1 of this scope.
5. **Scope 06** (skill-sustainer curate + cron) — runs after Scope 01
   P1's linter lands.
6. **Scope 07** (xerahs U1–U10) — independent; can start week 1
   alongside anything else.
7. **Scope 05** (verify doctor repairs + complete doctor design) —
   independent; can start any time.
8. **Scope 08** (cron sentinel + runner gate) — partially Scope 03
   F2 and partially Scope 02's runner gate; the "absorb the missed
   prompt" view.

## Recommended starting points for Mike

Two unblocks (10 min + 1 hr):

1. **Scope 07 step 0** — clear the live stale lock
   (`.xerahs-workspace.lock/`, pid 47912 dead) and free 387 MiB of
   disk. The XerahS hourly sweep is blocked *right now*; the disk
   is below every pipeline's safe floor.
2. **Scope 06 step 1** — curate the 13 patches + 2 PROPOSAL.md docs
   in `KovaForge/skills/skill-sustainer/proposals/pending/`. 11
   patches are mechanical; the 2 PROPOSAL.md docs are judgment
   calls (delegation routing table; github-model-sync duplicate).

Once those two are out of the way, the Fable 5 queue's downstream
state is clean: xerahs sweep runs, skill-sustainer is in
known-good state, and every other scope can begin with its
preconditions satisfied.

## The "no artifact" scope (8)

Scope 08 is the debt record. The F7 zero-zombie prompt was marked
`done` but produced no file on disk. Scope 08 fixes the
underlying problem (cron sentinel + runner gate), and the prompt
itself remains as a retro-translation exercise. The
runner-gate tightening is the single most leveraged runner
change in the whole set — it would have caught the F7 miss at
runtime and will catch any future Fable 5 prompt that promises
a deliverable and doesn't produce one.

## Total effort (sum of scopes)

- Minimum (Scope 02 + Scope 03 + Scope 04 + Scope 06 + Scope 07):
  ~12 days of build work spread over a quarter.
- With Scope 01 (skills review) and Scope 05 (doctor) and Scope
  08 (zero-zombie): ~16 days.
- All owned within existing BRF-ORG-POL-001 role matrix; no new
  agents, no new infrastructure, no new machines.
