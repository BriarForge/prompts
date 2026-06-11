# Ecosystem Antifragility Assessment — KovaForge / OpenClaw / Hermes

**Date:** 2026-06-12 · **Author:** Fable 5 (ecosystem-antifragility-audit run)
**Rubric:** `RUBRIC.md` (same directory) · **Baseline system score: 4.0/10**

Verified roots examined (everything below was read or executed against these,
nothing is assumed):

- Protocols: `/Users/mike/.hermes/protocols/` (11 indexed docs + 1 stray)
- External skills: `/Users/mike/Projects/KovaForge/skills/` (58 skills; baseline audit of 2026-06-11 re-used and spot-reverified)
- Cron: `~/.hermes/profiles/aoife/cron/jobs.json` (20 jobs)
- Aoife skills: `~/.hermes/profiles/aoife/skills/` (9 profile-authored skills, ~36 symlinked bundled categories, `.hub` quarantine + curator machinery)
- Orchestration: `fable5/run-next-fable5.sh` queue runner + `git-aoife` wrapper + Discord-delivered cron

## 1. System inventory and how the pieces couple

The ecosystem is one Mac running Hermes with per-agent profiles (Aoife is the
COO/scheduler profile), plus OpenClaw agents, coordinated through:

1. **Protocol layer** — 11 governance docs (charter, policies, processes) indexed in `protocols/README.md`, plus an 8-agent model-allocation table with unique primaries and fallbacks.
2. **Skill layer** — at least **five** distinct resolution roots: the external KovaForge repo (58 skills), the global `~/.hermes/skills/`, the bundled `~/.hermes/hermes-agent/skills/` + `optional-skills/` (symlinked into the profile), per-profile dirs (aoife, declan, sofia), and **skill procedures pasted inline into cron prompts**.
3. **Scheduling layer** — 20 cron jobs in `jobs.json` (sync jobs, monitors, reports, reminders), delivering to ~14 different Discord channels/threads; plus the Fable 5 prompt queue (`progress.json` + `run-next-fable5.sh`, 4.5h timeout, JSON success gate).
4. **Memory/learning layer** — translation layer (`fable5/translation-layer/`), per-session auto-memory, daily `hermes-config-backup`, curator with quarantine.

The coupling that matters: **cron prompts name skills by bare string**, the
skill layer has no unified namespace, and nothing validates the seam. The
governance layer describes rules that no machine checks. These two facts
generate most of the fragility found below.

## 2. Rubric scoring evidence

**C1 Failure visibility = 3.** Verified live: `SpaceX IPO Hello Stake Monitor`
last status `error` ("no_agent=True but no script is set") yet state
"scheduled"/enabled — it has been misconfigured while appearing healthy;
`PureMac Weekly Cleanup` errors on a nonexistent script
(`aoife/scripts/puremac-clean.sh` — the scripts dir contains no such file) and
delivers to *"#investing / 4 year journey"*, a channel unrelated to disk
hygiene, so even a delivered error lands where nobody looks for ops signals.
Errors live only in `jobs.json` fields. Positive: the queue runner now tees
full JSON results to `runs.log` and reverts failed prompts to `pending`.

**C2 Stressor metabolism = 6.** This is the system's genuine strength: the
2026-06-11 SIGKILL incident produced (a) the runner's success gate + race-free
settle loop (visible in `run-next-fable5.sh` with the incident documented in
comments), (b) the entire translation layer with rubric + extraction lint, (c)
durable memory entries. Stress made the system stronger — once. The conversion
is ad hoc: no incident log, no rule that an incident must yield a control, and
KovaForge's AGENTS.md spec shows what happens without enforcement (low
compliance, recurring defect classes).

**C3 Redundancy with divergence control = 3.** Redundancy exists: daily config
backup (33 completed runs, last status ok), every agent has a fallback model, gh identity
fallback (aoife→declan). Divergence control does not: 5 duplicate skill pairs
of which 2 are *contradictory* (bitwarden pair disagrees on whether `bw` CLI is
deprecated; the two delegation skills have different routing tables);
`BRF-OPS-POL-003` exists twice with the same ID and different content (verified
by diff: root copy is "Clone/Fork Path Conventions", policies copy is
"Workspace Organization"); the weekly-hermes-release-sync cron prompt embeds a
full copy of its skill's procedure, so prompt and skill can drift apart
independently.

**C4 Reference & boundary integrity = 2.** Verified by resolution scan: of 13
distinct skill names referenced by cron jobs, `hermes-fork-release-tag-autoupdate`
and `crypto-analyst-youtube-monitor` resolve in **no** skills root on the
machine (`find` across `~/.hermes` depth 5 + KovaForge repo), and
`financial-report` resolves only inside *Declan's* profile while the job runs
under Aoife. Inside the KovaForge repo: 39 dangling `related_skills` refs, 4
YAML-broken frontmatters, two competing tag schemas (2026-06-11 audit,
re-verified at HEAD that evening). No CI, no pre-commit, no schedule-time
validation anywhere.

**C5 Concentration risk = 4.** Single Mac runs scheduler, runner, all agents;
single human consumer (Mike) for every output; `jobs.json` is one mutable file
(covered by the daily profile backup — mitigating); the skills repo syncs to
GitHub weekly (so up to 7 days of skill edits are machine-local); the queue
runner depends on a logged-in `claude-auto` (a past silent "Not logged in"
failure is documented in the runner's comments). Mitigations are real but
partial.

**C6 Optionality = 6.** Unique primary model per agent with declared fallbacks
(protocols README), gh account fallback for workflow-scope pushes, dry-run /
report-only modes in cron-load-balancer, release-tag-only update policy
(refuses risky upstream/main). Gaps: the runner and cron scheduler themselves
have no degraded mode; a failing job just stays failed (no auto-pause,
no retry-with-backoff, no park-with-reason).

## 3. Top 5 sources of fragility, ranked

Ranked by (blast radius × likelihood × silence). Each comes with a concrete
upgrade, an owner from the BRF-ORG-POL-001 role matrix, rollback criteria, and
measurable second-order effects.

---

### F1. Skill resolution is fragmented across ≥5 roots with zero reference validation

**Evidence.** Two cron jobs reference skills that exist nowhere; one reaches
across profile boundaries; 39 dangling refs inside KovaForge; the same skill
name can exist in multiple roots with different content (`plan` exists in 3
places). A renamed or moved skill breaks consumers silently — the
`vladislava-*` mass rename already demonstrated this at scale.

**Upgrade — ecosystem resolution registry + seam lint.** One script
(`validate-ecosystem.py`, natural extension of the already-planned
`validate-skills` linter) that: builds a map of every skill name → path(s)
across all five roots; fails on (a) cron skill refs that resolve nowhere or
only cross-profile, (b) duplicate names with non-identical content, (c)
dangling `related_skills`. Run it three ways: pre-commit in the skills repo,
weekly as a cron job, and at *schedule time* — a job referencing an
unresolvable skill is created paused with a reason.

- **Owner:** Aoife (registry/policy) + Declan (implementation), per the Role Delegation Matrix.
- **Rollback criteria:** lint runs report-only for 2 weeks; promote to blocking only if false-positive rate over those 2 weeks is <5% of flags; demote back to report-only if a legitimate job/skill is blocked twice.
- **Second-order effects (measurable):** unresolvable cron skill refs 2→0 and *stays* 0 (the metric is the count at weekly lint, not the one-time fix); dangling refs 39→0; duplicate-name-divergent-content count 5→0; new-skill authoring gets a free duplicate gate, which removes the *creation* path for contradictory pairs — the second-order effect is that the contradictory-duplicate class stops being produced, not just cleaned.

### F2. Zombie cron jobs: failures persist silently in "scheduled" state

**Evidence.** Both failing jobs (PureMac, SpaceX) are enabled, "scheduled",
and erroring — SpaceX dies on the same config error on a daily schedule.
The Anti-Zombie Protocol (BRF-OPS-POL-002) exists *on paper* with no
mechanical enforcement for cron. Misrouted delivery (disk-hygiene errors into
an investing thread) means even surfaced errors are invisible.

**Upgrade — cron health sentinel.** A daily meta-job (or an extension of the
existing `cron-load-balancer`, which already parses `jobs.json`) that flags:
`last_status == error`, N≥3 consecutive failures, skill/script refs that don't
resolve (reusing F1's resolver), and delivery-channel mismatch heuristics. One
digest to a single ops channel (#bf-cron-jobs). Phase 2: auto-pause any job at
N≥5 consecutive failures with `paused_reason` set — the fields already exist
in the schema.

- **Owner:** Declan (Operator); escalation per BRF-OPS-POL-002 to Aoife.
- **Rollback criteria:** report-only first; enable auto-pause only after 2 weeks of accurate digests; disable auto-pause immediately if it ever pauses a job that subsequently would have succeeded (one strike).
- **Second-order effects:** mean-time-to-detect a failing job: currently unbounded (SpaceX has failed repeatedly with nobody acting) → <24h, measured as `now − first_error_run` at digest time; failure-pattern table grows one entry per new error string, so each *novel* failure improves the sentinel's classification — the system learns from every incident class exactly once.

### F3. Governance has duplicate IDs and no spec-to-reality enforcement

**Evidence.** Two files claim `BRF-OPS-POL-003` with different titles and
content; one of them is not in the README index at all. KovaForge's AGENTS.md
mandates a frontmatter schema that 60%+ of its own repo ignores. Policies are
prose; nothing executes them; drift between "what the docs say" and "what
agents do" is unbounded and currently undetectable.

**Upgrade — protocol integrity check + checkable-rule extraction.** Small lint
(can live beside F1's): doc-ID uniqueness across the protocols tree,
index↔filesystem reconciliation (every file indexed, every index row exists),
required header block (ID, owner, last-review date). Then a standing rule:
when a policy contains a machine-checkable clause (e.g. Git Policy's wrapper
requirement, Secrets Policy's commit scanning), the policy PR must ship the
check or explicitly record why not. Immediate cleanup: merge/renumber the
POL-003 pair and index the survivor.

- **Owner:** Aoife (governance is the COO lane).
- **Rollback criteria:** the integrity lint is read-only by nature; the "ship the check" rule rolls back by reverting to advisory if it stalls more than one policy change per month.
- **Second-order effects:** duplicate-ID count 1→0 and structurally cannot recur (uniqueness is checked at edit time); ratio of policies with at least one automated check 0/8 → target 4/8 in a quarter — each policy edit now *adds* enforcement surface, so governance strengthens as a side effect of normal churn.

### F4. Single-node, single-operator concentration with partial state durability

**Evidence.** One Mac is scheduler + runner + all profiles. The skills repo
pushes weekly (up to 7 days of local-only changes); a session SIGKILL already
destroyed one full run's work before progressive commits were mandated; the
runner requires a live `claude-auto` login and previously failed silently
without one. All outputs flow to one human with no acknowledgment loop.

**Upgrade — state durability pass + recovery runbook.** (a) Confirm and pin
the daily backup's coverage manifest: `jobs.json`, profile skills, scripts,
`.curator_state` — backup job fails loudly if a manifest item is missing.
(b) Skills repo sync weekly→daily (one-line cron change). (c) Runner preflight:
`claude-auto` auth check before extracting the prompt, park the queue with a
visible reason on failure. (d) A tested `RECOVERY.md`: fresh-machine
restore from backups + git remotes, exercised once (that exercise is the
verification).

- **Owner:** Declan (execution), Viktor (OpenClaw-side mirror of the same pass).
- **Rollback criteria:** all four items are independently revertible one-line/one-file changes; rollback any item that adds >5 min to a daily cycle or produces false-alarm backup failures twice.
- **Second-order effects:** maximum machine-local unpushed work 7 days→1 day (measured: `git log origin/master..master` age in the skills repo at daily sync time); queue failure mode changes from "silently lied to progress.json" (the documented old bug) to "parked with reason" — and the recovery runbook converts the *next* hardware loss from an unbounded incident into a measured restore time, which is the antifragile inversion: the failure mode now has a rehearsed exploit path.

### F5. Brittle prompt-queue contract: pre-rubric goals + extraction-fragile runner

**Evidence.** The runner extracts goal text with `sed -n '/```text/,/```/p'` —
one early-closing fence silently truncates a goal (happened to the xerahs
prompt; its Done/Verification sections were dropped until repaired). Four
pending prompts still predate the translation-layer rubric;
`leverage-point-mapping.md` extracts to just 8 lines with no output path, no
commit cadence, no failure-handling contract. This very audit ran from a
pre-rubric prompt that named no output path — it guessed one (this directory).

**Upgrade — move the lint into the runner + retranslate the queue.** (a)
`run-next-fable5.sh` validates after extraction: non-empty, contains exactly
one "Done looks like", contains a `git-aoife` commit contract for long runs;
on failure marks the prompt `needs-repair` in `progress.json` (new status) and
moves on instead of executing half a goal. (b) Run the 4 remaining pre-rubric
prompts through `translation-layer/GOAL-TEMPLATE.md` before their turn.

- **Owner:** Aoife (owns the translation layer and the queue).
- **Rollback criteria:** the runner check is ~10 lines guarded by a single `if`; revert if it ever blocks a prompt that a human review judges well-formed (one strike, since the queue is low-volume).
- **Second-order effects:** silently-truncated-goal incidents become structurally impossible at the runner seam (the check runs on *what will actually execute*, not on the file); pre-rubric prompt count 4→0; downstream, runs launched from rubric-validated goals need less steering — measurable as the rate of "invented output path / guessed scope" notes in run results, which this very run had to log.

---

### Ranked intervention list (summary)

| Rank | Intervention | Owner | Effort | Primary metric | Second-order metric |
|---|---|---|---|---|---|
| 1 | F1 Resolution registry + seam lint | Aoife/Declan | ~1 day | unresolvable cron refs 2→0, dangling refs 39→0 | contradictory-duplicate creation rate →0 |
| 2 | F2 Cron health sentinel | Declan | ~½ day | MTTD failing job ∞→<24h | failure-pattern table grows per novel error |
| 3 | F3 Protocol integrity check | Aoife | ~½ day | dup IDs 1→0, index drift 1→0 | policies with automated checks 0→4/8 |
| 4 | F4 State durability + runbook | Declan/Viktor | ~1 day | unpushed-work window 7d→1d | rehearsed restore time replaces unbounded loss |
| 5 | F5 Runner lint + queue retranslation | Aoife | ~½ day | pre-rubric prompts 4→0 | truncated-goal class impossible at execution seam |

Order rationale: F1 and F2 share the resolver and remove the two *currently
live* failure conditions; F3 is cheap and stops governance rot at the source;
F4 caps blast radius; F5 hardens the channel through which all future
autonomous work arrives.

## 4. Failure-mode simulations (one per intervention, executed where possible)

The brief requires confirming each upgrade makes the system **stronger, not
merely more redundant**. Four of five simulations were executed live this run;
one is a code-path verification.

**S1 (F1) — "a cron job references a skill that doesn't exist."** Executed: a
13-name resolution scan across KovaForge, profile, global, and bundled roots.
It caught both real instances (`hermes-fork-release-tag-autoupdate`,
`crypto-analyst-youtube-monitor`) plus the cross-profile `financial-report`.
*Stronger, not redundant:* the registry doesn't add a second copy of any skill
(that would be redundancy and more divergence); it kills the failure class by
making the reference seam observable, and each newly observed mis-resolution
pattern becomes a permanent lint rule.

**S2 (F2) — "a job fails repeatedly while appearing healthy."** Executed: the
sentinel's core query (`jq` over `jobs.json` for `last_status=="error"`)
flagged both live zombies with their error strings and exposed the PureMac
delivery misroute in the same pass. *Stronger:* today the SpaceX job fails
daily and teaches the system nothing; under F2 the same failure increments a
consecutive-failure counter, lands in a digest, auto-pauses with a recorded
reason, and adds its error signature to the pattern table. The identical
stressor now produces structure instead of log entropy.

**S3 (F3) — "two policies claim the same ID."** Executed: the ID-collision
detector over the protocols tree returned exactly `BRF-OPS-POL-003` — the
real, pre-existing collision — and the index reconciliation caught the stray
root file. *Stronger:* the fix isn't keeping both copies in sync (redundancy);
it's a uniqueness invariant checked at edit time, so the collision class dies.

**S4 (F4) — "the session is SIGKILLed mid-run / the machine dies."** Code-path
verification + this run's own behavior: `run-next-fable5.sh` lines 65–82
revert a failed prompt to `pending` and commit the failure trail; this
assessment committed progressively (rubric committed before this file was
written), so a kill at any point loses at most one section. The remaining gap
this simulation exposes is exactly F4's target: a machine-loss event today has
no rehearsed restore, only raw backups. *Stronger:* progressive commits + a
rehearsed runbook turn a kill event into a bounded, measured cost — and the
2026-06-11 SIGKILL already demonstrated the metabolism: the incident produced
the success gate and the commit-cadence rule that protected this very run.

**S5 (F5) — "a queue prompt is silently truncated."** Executed: the extraction
dry-run over all 8 queue prompts — all extract non-empty with exactly one
"Done looks like" (confirming the xerahs repair held), while line counts
exposed `leverage-point-mapping.md` (8 lines) as contract-thin. *Stronger:*
moving this check into the runner means the next malformed prompt cannot
execute half a goal; it gets parked as `needs-repair` with the evidence
attached. The xerahs incident thereby becomes the last of its class rather
than the first of many.

**Cross-check against "merely more redundant":** none of the five
interventions adds a copy of anything. Three add *invariant checks at seams*
(F1, F3, F5), one adds *observation + escalation* (F2), one adds *rehearsal +
preflight* (F4). Each converts a stressor class into either an impossibility
or a signal — the definition of antifragile gain used in the rubric.

## 5. Expected rubric movement

| Criterion | Now | After F1–F5 | Driver |
|---|---|---|---|
| C1 Failure visibility | 3 | 8 | sentinel digest + auto-pause + runner park-with-reason |
| C2 Stressor metabolism | 6 | 8 | incident→control becomes the mechanical default at three seams |
| C3 Redundancy/divergence | 3 | 6 | divergence detectors; full 8 needs the KovaForge dup merges to land |
| C4 Reference integrity | 2 | 7 | registry + lint at commit, schedule, and run time |
| C5 Concentration risk | 4 | 6 | daily sync + runbook; still one machine, one human — structural ceiling |
| C6 Optionality | 6 | 7 | parked/degraded modes for runner and cron |

System: **4.0 → ~7.0**, re-measurable by rerunning the scoring queries in §2
(all are deterministic commands over the same files).

## 6. Self-score on this assessment: **8/10**

Grounding for the score, per the brief's own criteria:

- **Ranked list with ownership, rollback, second-order metrics:** present for all five; owners come from the actual Role Delegation Matrix, every metric is a count obtainable from a command shown in this run. ✔
- **One failure simulation per intervention:** 4 of 5 executed live against real state (and each caught a *real* pre-existing defect, not a synthetic one); 1 (machine loss) verified by code path + this run's own progressive-commit behavior. ✔
- **Stronger-not-redundant confirmed:** argued per-simulation and cross-checked as a class (§4). ✔

What holds it at 8: (a) the interventions are designed and verified-by-
simulation but **not implemented** — the registry, sentinel, and runner lint
remain ~2 days of build work, and an assessment that shipped the three small
lints would deserve the 9; (b) skill resolution order inside Hermes itself
(which root wins when names collide) was inferred from filesystem evidence,
not from Hermes source — the cross-profile `financial-report` case may be
intended behavior; (c) the OpenClaw side of the ecosystem was assessed only
through its protocol/skill footprint on this machine, since the verified roots
don't include OpenClaw's own state.
