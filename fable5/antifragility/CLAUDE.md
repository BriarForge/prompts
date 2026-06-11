# Antifragility Workstream — Project Memory

Persistent memory for the ecosystem-antifragility workstream. Update whenever
an intervention lands or a new fragility class is observed. Keep short; loaded
into context by future runs.

## What this is

`RUBRIC.md` — 6-criterion antifragile-quality rubric (0–10 each, anchored).
`ASSESSMENT.md` — 2026-06-12 baseline assessment: system score **4.0/10**,
top-5 fragility sources (F1–F5), ranked interventions, executed simulations.

## Baseline facts a future run should NOT re-derive (verified 2026-06-12)

- Skill resolution spans ≥5 roots: KovaForge repo (58), `~/.hermes/skills/`,
  bundled `hermes-agent/skills/`+`optional-skills/` (symlinked into profiles),
  per-profile dirs (aoife: 9 authored), inline cron-prompt copies.
- Live defects at baseline: cron refs `hermes-fork-release-tag-autoupdate` and
  `crypto-analyst-youtube-monitor` resolve nowhere; `financial-report` only in
  declan's profile; PureMac job missing `puremac-clean.sh` (errors, delivers to
  #investing); SpaceX IPO job `no_agent=True` without script (errors daily);
  `BRF-OPS-POL-003` duplicated with divergent content (root + policies/).
- Re-scoring is deterministic: the §2 evidence queries in ASSESSMENT.md are
  all runnable commands (jq sentinel, find resolver, ID-collision grep,
  extraction lint).

## Intervention status

| ID | Intervention | Owner | Status |
|---|---|---|---|
| F1 | Resolution registry + seam lint (`validate-ecosystem.py`) | Aoife/Declan | designed, not built |
| F2 | Cron health sentinel (extend cron-load-balancer) | Declan | designed, not built |
| F3 | Protocol ID/index integrity check + POL-003 merge | Aoife | designed, not built |
| F4 | State durability pass + RECOVERY.md rehearsal | Declan/Viktor | designed, not built |
| F5 | Runner extraction lint + retranslate 4 pre-rubric prompts | Aoife | designed, not built |

When one lands: flip status, rerun the relevant §2 query, record the metric
delta here.

2026-06-12: F1–F5 absorbed into the 90-day plan in
`fable5/leverage-map/LEVERAGE-MAP.md` (L1=F5+F4c, L2=F1+KovaForge P1–P5,
L3=F2+F4a/b, L4=F3+F4d). Track rollout there; record metric deltas here.

## Operating rules for this workstream

1. Every new incident must name its fragility class (F1–F5 or a new F6+) and
   end with either a new check or a written reason why not. (C2 metabolism.)
2. Interventions ship report-only first; promotion to blocking follows the
   rollback criteria written in ASSESSMENT.md §3 — don't improvise new ones.
3. Strength test for any proposed fix: does it add a copy (redundancy) or kill
   a class (antifragility)? Prefer the latter; if adding a copy, add the
   divergence check in the same change.

## Open questions

- Hermes' actual skill-resolution precedence (which root wins on name
  collision) — inferred from filesystem only; read Hermes source before
  building F1's registry semantics.
- Whether cross-profile skill use (aoife job → declan skill) is a feature or
  an accident; affects F1's cross-profile rule.
- OpenClaw's own machine/state was out of scope (verified roots only) — F4's
  Viktor mirror task needs its own evidence pass.
