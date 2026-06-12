# Fable 5 Queue — Per-Prompt Scope Documents

Created 2026-06-12 17:50 AWST by Vladislava. One scope per Fable 5 prompt
in the order they ran. Each scope records: what was asked, what was
produced, what's in/out of scope for follow-up, what the deliverables
made possible, headline metric, and current status.

| # | Scope | Prompt | Status | Output file |
|---|-------|--------|--------|-------------|
| 1 | [SCOPE-01](SCOPE-01-skills-repo-overarching-review.md) | skills-repo-overarching-review | Audit complete, plan unactioned | `KovaForge/skills/REVIEW-2026-06-11.md` |
| 2 | [SCOPE-02](SCOPE-02-objective-to-execution-translation.md) | objective-to-execution-translation | Complete, committed, passive | `fable5/translation-layer/` |
| 3 | [SCOPE-03](SCOPE-03-ecosystem-antifragility-audit.md) | ecosystem-antifragility-audit | Complete, committed, plan unactioned | `fable5/antifragility/ASSESSMENT.md` |
| 4 | [SCOPE-04](SCOPE-04-leverage-point-mapping.md) | leverage-point-mapping | Complete, committed, plan unactioned | `fable5/leverage-map/LEVERAGE-MAP.md` |
| 5 | [SCOPE-05](SCOPE-05-openclaw-doctor-resilience-autonomy.md) | openclaw-doctor-resilience-autonomy | Side-effect execution (skills-repo repair) | none in fable5/; KovaForge/skills commit `7b06f1c` |
| 6 | [SCOPE-06](SCOPE-06-skill-evolution-maintenance-loop.md) | skill-evolution-maintenance-loop | **Complete system built + verified** | `KovaForge/skills/skill-sustainer/` + RUN-REPORT |
| 7 | [SCOPE-07](SCOPE-07-xerahs-pipeline-reliability-autonomy.md) | xerahs-pipeline-reliability-autonomy | Plan complete, 0/10 upgrades executed | `xerahs/docs/RELIABILITY-PLAN.md` |
| 8 | [SCOPE-08](SCOPE-08-zero-zombie-initiative-os.md) | zero-zombie-initiative-os | **No artifact; debt record** | none |

## Cross-scope read

Three of eight prompts produced real systems or strong plans with
clear execution paths (F2, F3, F5, F6, F7-of-xerahs — i.e. translation
layer, antifragility assessment, leverage map, skill-sustainer, and
the xerahs reliability plan).

Two prompts (F1 skills review, F3 antifragility) produced strong
plans that are **unactioned** — Mike's standing question.

Two prompts (F4 openclaw-doctor, F7 zero-zombie) hit the
pre-rubric-thin-extraction problem F2 was designed to fix; F4
recovered via side-effects (skills-repo repair), F7 produced
nothing.

The most leveraged single follow-up is to **retro-translate the 4
pre-rubric prompts** (openclaw-doctor, xerahs, zero-zombie, and
arguably skills-review) and re-run them with explicit "Output:"
clauses. That is F5 L1 in action.

The most leveraged runner change is to **tighten the success gate**
from `is_error: false` to "deliverable file written + committed
with the prompt's stated output path." That would have caught F7
at runtime. That is F5 F1.5.
