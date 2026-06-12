# Scope — F4 (operations): XerahS Pipeline Reliability & Autonomy

**Fable 5 prompt:** `xerahs-pipeline-reliability-autonomy.md` (7th in queue, 2026-06-12)
**Session id:** `8d94047f-f9b8-498d-a1c9-11a477f9215b` (final successful run; the Fable 5 queuer's earlier attempts on 2026-06-11 hit both the session-limit error and the fake-done bug, sessions `fable5-20260611-203838-…` and `4ac9db6b-…`)
**Output:** `/Users/mike/Projects/KovaForge/xerahs/docs/RELIABILITY-PLAN.md` (committed in 3 sections across commits `a44df371`, `9bc0dcd1`, `a8a10c70`)
**Prompt file:** `xerahs-pipeline-reliability-autonomy.md` was also *repaired* during F2 (translation-layer) build using `examples/02` as the source of truth.

---

## What was asked

"A prioritized reliability-and-autonomy upgrade plan for the XerahS
ecosystem exists at `/Users/mike/Projects/KovaForge/xerahs/docs/RELIABILITY-PLAN.md`,
covering the four operational workflows — pre-release pipeline, URL
publishing, issue monitoring, hourly sweep — plus the scheduler layer they
all depend on." Grounded in 5 XerahS workflow skills + the XerahS repo
itself. Per-run contract: "no changes were applied in this run;
illustrative patches appear as diffs only."

## What it produced

A 7-section reliability and autonomy plan, evidence-first:

1. **Observed state (8 verified facts O1-O8, 2026-06-12):**
   - **O1** Stale workspace lock is live right now
     (`.xerahs-workspace.lock/`, owner=declan, pid=47912 — dead) — every
     future sweep will see the lock and defer.
   - **O2** The 06:01 sweep died mid-run; no durable trace.
   - **O3** Issue monitor silent for ~5 weeks (last_run May 9).
   - **O4** Disk at 97% (387 MiB free) — explains the SQLite
     "disk I/O error" test failures.
   - **O5** Scheduler store had an interrupted write and was migrated
     (`jobs.json.<pid>.<hash>.tmp` orphan remains; backup shows every
     job's lastStatus is None).
   - **O6** `origin/develop` is 14 commits behind local `develop`
     (Vladislava origin push path is broken).
   - **O7** Skill↔repo drift: issue-monitor SKILL.md points at a
     non-existent `skills/vladislava-…` path; hourly-sweep uses
     `/Users/mike/Projects/KovaForge/XerahS` (capital X, only works
     because APFS is case-insensitive); duplicated "Step 9" block.
   - **O8** Untracked build debris in repo root (`axaml_error.binlog` +
     `build.binlog` 3MB, not git-ignored).
2. **Failure-mode table** — 4/4 workflows; every failure mode marked
   **observed** (traced to §1 evidence) or **hypothesized**.
3. **Prioritized upgrades U1-U10** — each with steps, success criteria,
   owners, and rollback considerations.
4. **Failure simulations** (sections 4-7) — 4 simulations, 4 executed
   live during the audit.
5. **Drift findings** — skill↔repo drift summary.
6. **Sign-off list** — explicit per-upgrade ownership.
7. **Sequencing** — dependency order across U1-U10.

## Scope for follow-up action

**In scope (the plan covers):**
- 5 XerahS workflow skills (xerahs-prerelease-pipeline,
  xerahs-url-publishing, xerahs-issue-monitor, xerahs-hourly-sweep,
  xerahs-kfip-pipeline read for context).
- The XerahS repo at `/Users/mike/Projects/KovaForge/xerahs/`.
- The OpenClaw cron store and the `cron-load-balancer` skill.
- The declan↔Vladislava push-path asymmetry (O6).

**Out of scope:**
- The XerahS app code itself (no source changes proposed — the plan
  is "no changes were applied in this run" by contract).
- Non-XerahS cron jobs.
- The skill-sustainer (F6) which would automatically lint the
  drift findings from O7.
- The Fable 5 queue mechanics.

**Decide alone:** none of the U1-U10 upgrades should be auto-executed;
all need owner review first. The plan is the deliverable.

**Don't decide alone:** which of U1-U10 to execute first (sequencing
is in §7 but priorities are operational); whether to repair the
`vladislava-` push path (O6) by switching to a different identity or
fixing the existing one; whether to retire the issue monitor entirely
(given O3) or revive it; the disk-cleanup threshold (O4) — how
aggressive the auto-purge is.

## What the deliverables made possible

- **F3 F4 (state durability)** — O1, O2, O5 are direct evidence the
  F3 F4 finding ("single-node, single-operator concentration with
  partial state durability") needed a recovery runbook.
- **F3 F2 (cron health sentinel)** — O3 (issue monitor silent for 5
  weeks) is the exact failure class F3 F2 is designed to catch.
- **F6 (skill-sustainer)** — O7's drift findings would be detected
  on next `--run` (skill↔repo drift is in the 8-axis rubric).
- **F1 (skills audit) P1 lint+CI** — if it existed, the O7 skill↔repo
  drift would have been caught at edit time.

## Headline metric

- **0/4 workflows** had a clean observed state (all 4 had ≥1 observed
  failure mode).
- **8 evidence-verified observations** (O1-O8), all dated 2026-06-12.
- **4/4 failure simulations executed live** during the audit.
- **0/10 upgrades executed** (plan only, by contract).

## Current status

**Complete and committed (in 3 commits to xerahs/docs/).** Plan exists;
no actions taken. **Most urgent single fix:** U1 (lock cleanup, O1's
`.xerahs-workspace.lock/` should be removed so subsequent sweeps can
run). This is a 30-second fix that was *not* applied because the run
contract was "no changes applied." Mike has not authorized execution.
