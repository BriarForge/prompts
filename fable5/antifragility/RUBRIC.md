# Antifragile System Quality — Rubric

Scoring rubric for the KovaForge/OpenClaw/Hermes agent ecosystem. Created
2026-06-12 by the ecosystem-antifragility-audit run. Each criterion is scored
0–10 with anchors below; the system score is the unweighted mean.

"Antifragile" here means more than robust: stressors (failures, incidents,
drift) should leave the system *structurally stronger* — new lints, new
sentinels, dead failure classes — not just patched instances or added
redundancy.

## Criteria

### C1. Failure visibility
When something breaks, the system surfaces it loudly, quickly, and in a place
someone actually looks.
- **0–2** Failures persist silently; error state visible only by inspecting raw state files.
- **5** Failures logged and delivered somewhere, but to scattered/wrong channels; no aggregation; detection depends on a human noticing.
- **8** Single ops digest of all failures; consecutive-failure escalation; misrouted delivery detected.
- **10** Failures page proportionally to blast radius; zero zombie jobs possible by construction.

### C2. Stressor metabolism (learning loop)
Incidents convert into permanent structural upgrades, not just fixes.
- **0–2** Same failure recurs; no record incidents happened.
- **5** Post-incident fixes happen and are durable (code/process), but conversion is ad hoc and depends on one person/agent remembering.
- **8** Incident → new automated check is the default path; an incident log exists and each entry points to the control it produced.
- **10** Every failure class observed once is mechanically impossible to repeat unnoticed.

### C3. Redundancy with divergence control
Backups, fallbacks, and copies exist — and cannot silently contradict each other.
- **0–2** No backups/fallbacks, or uncontrolled copies routinely contradict.
- **5** Good backup/fallback coverage, but duplicated content (skills, policies, prompt-embedded procedures) drifts with no detector.
- **8** Every duplicate is either generated from a single source or covered by a divergence check.
- **10** Redundancy is exercised (failover tested), and divergence is structurally impossible.

### C4. Reference & boundary integrity
Names resolve; the seams between subsystems (cron→skill, skill→skill,
index→file, prompt→runner) are validated.
- **0–2** Dangling references throughout; no validation at any seam.
- **5** References mostly resolve; validation exists at some seams but not the load-bearing ones.
- **8** CI/lint validates all cross-references on change; dangling ref blocks merge/schedule.
- **10** References are resolved through a registry, so dangling refs cannot be created.

### C5. Concentration risk (SPOF exposure)
How much dies if one machine, account, person, or file is lost.
- **0–2** Single machine, single account, no backups, no recovery path.
- **5** Key state backed up on a schedule; identity has a fallback; but compute, scheduling, and operations all concentrate on one node/person.
- **8** State recoverable to a fresh machine in <1 day from documented runbook; no unbacked critical file.
- **10** No single loss event can destroy more than one day of work or any unique state.

### C6. Optionality & graceful degradation
When a dependency fails, there is a cheaper/weaker path that still works.
- **0–2** Hard dependencies everywhere; one upstream failure stops the system.
- **5** Fallback models/accounts/dry-run modes exist for several components, but core orchestrators have no degraded mode.
- **8** Every scheduled/queued workload has a defined behavior under dependency failure (retry, degrade, park-with-reason).
- **10** The system sheds load gracefully and exploits cheap options opportunistically.

## Current scores (2026-06-12 baseline)

Evidence for each score is in `ASSESSMENT.md` §2.

| Criterion | Score | One-line basis |
|---|---|---|
| C1 Failure visibility | 3 | Two cron jobs in error state for days, state still "scheduled", errors visible only in jobs.json; one delivers to an unrelated investing thread |
| C2 Stressor metabolism | 6 | SIGKILL incident → success gate + translation layer (real metabolism), but conversion is ad hoc, no incident log |
| C3 Redundancy/divergence | 3 | Daily config backup + model fallbacks exist, but 5 contradictory skill pairs, divergent duplicate policy ID, skill text duplicated into cron prompts |
| C4 Reference integrity | 2 | 39 dangling skill refs, 2 cron jobs referencing skills that resolve nowhere, 1 resolving only in another profile; zero validation at any seam |
| C5 Concentration risk | 4 | One Mac runs everything; profile backed up daily; skills repo pushed weekly; one human consumer |
| C6 Optionality | 6 | 8 unique primary models all with fallbacks, gh account fallback, dry-run modes; but runner and cron scheduler have no degraded mode |

**System score: 4.0 / 10** — robust in spots, antifragile almost nowhere yet;
the learning loop (C2) is the strongest asset and the integrity seams (C4) the
weakest.
