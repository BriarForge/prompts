# Scope 03 — Execute the 5 Antifragility Upgrades (F1–F5)

**Drives from:** `fable5/antifragility/ASSESSMENT.md` (system baseline
4.0/10, 5 ranked fragility sources F1–F5, each with owner, rollback
criterion, measurable second-order effect).
**Goal:** Move system score 4.0 → ≈7.0/10 by landing F1–F5. Re-score
deterministically by rerunning §2 queries in the assessment.
**Owner of this scope:** Per-intervention owners below (mirrors
BRF-ORG-POL-001).

## Steps

### F1 — Ecosystem resolution registry + seam lint (1 day)
**Owner:** Aoife (registry/policy) + Declan (implementation).
- Build `validate-ecosystem.py` — natural extension of
  `validate-skills` (Scope 01 P1) — that walks all 5 skill roots
  (`/Users/mike/Projects/KovaForge/skills/`,
  `~/.hermes/profiles/aoife/skills/`, `~/.hermes/skills`,
  `~/.hermes/hermes-agent/skills`, plus profile-internal bundles),
  builds `name → path(s)` map, fails on:
  - cron skill refs that resolve nowhere
  - cron skill refs that resolve cross-profile (e.g. `financial-report`
    in Declan only)
  - duplicate names with non-identical content
  - dangling `related_skills`
- Run pre-commit, as a weekly cron, and at schedule-time (a job
  referencing an unresolvable skill is created paused with a reason).
- **Rollback:** report-only 2 weeks; promote blocking only if FP
  rate <5%; demote on 2 wrongful blocks.
- **Metric:** cron refs resolving nowhere 2→0, cross-profile 1→0;
  duplicate-divergent-content 5→0; dangling refs 39→0.

### F2 — Cron health sentinel (½ day)
**Owner:** Declan.
- Extend existing `cron-load-balancer` (it already parses `jobs.json`).
  Daily digest to one ops channel (`#bf-cron-jobs` proposed) that
  flags: `last_status==error`, N≥3 consecutive failures, unresolvable
  refs (F1's resolver), delivery-channel mismatch.
- Phase 2 (after 2 weeks of accurate digests): auto-pause at N≥5
  consecutive failures, set `paused_reason`.
- First-iteration hits: PureMac and SpaceX zombie jobs (live today).
- **Rollback:** one-strike on wrongful auto-pause.
- **Metric:** MTTD for a failing cron job: unbounded → <24h.

### F3 — Protocol integrity check + checkable-rule extraction (½ day)
**Owner:** Aoife.
- Small lint (lives beside F1's): doc-ID uniqueness across the
  protocols tree, index↔filesystem reconciliation, required header
  block (ID, owner, last-review date).
- Immediate cleanup: merge/renumber the `BRF-OPS-POL-003` pair
  (verified: same ID, two files, different titles and content).
- Standing rule: a policy PR containing a machine-checkable clause
  ships the check or records why not. Target 4/8 policies with checks
  in 90 days.
- **Rollback:** read-only by nature; "ship the check" rule reverts
  to advisory if it stalls more than one policy change per month.
- **Metric:** duplicate IDs 1→0 (structurally cannot recur);
  policies with at least one automated check 0/8 → 4/8 in Q3.

### F4 — State durability + recovery runbook (1 day)
**Owner:** Declan (execution), Viktor (OpenClaw-side mirror).
- (a) Pin the daily backup's coverage manifest:
  `jobs.json`, profile skills, scripts, `.curator_state`. Backup
  job fails loudly if any item is missing.
- (b) Skills repo sync weekly→daily (one-line cron change).
- (c) Runner preflight: `claude-auto` auth check before extracting
  the prompt, park queue with visible reason on failure (already
  partial via Scope 02 step 3).
- (d) `RECOVERY.md` — fresh-machine restore from backups + git
  remotes, exercised once (the exercise is the verification).
- **Rollback:** all four are one-line/one-file changes; revert any
  that adds >5 min to a daily cycle or false-alarms twice.
- **Metric:** machine-local unpushed work window 7d→1d; runner
  failure mode changes from "silently lied to progress.json" to
  "parked with reason".

### F5 — Move lint into the runner + retranslate the queue (½ day)
**Owner:** Aoife.
- (a) Runner validation post-extraction (this is Scope 02 step 2
  duplicated; consolidate the change into one commit).
- (b) Retro-translate the 4 pre-rubric prompts (this is Scope 02
  step 4; consolidate).
- **Metric:** pre-rubric prompts 4→0; truncated-goal class becomes
  structurally impossible at the runner seam.

## Verification

- Re-run §2 queries of `ASSESSMENT.md` against current state
  (deterministic commands). Expected:
  - C1 Failure visibility: 3 → 8
  - C2 Stressor metabolism: 6 → 8
  - C3 Redundancy/divergence: 3 → 6 (full 8 needs the KovaForge
    dup merges from Scope 01 P3 to land)
  - C4 Reference integrity: 2 → 7
  - C5 Concentration risk: 4 → 6
  - C6 Optionality: 6 → 7
  - System: 4.0 → ~7.0

## Out of scope

- Multi-machine redundancy (the single-Mac/single-human ceiling is
  structural; F4 caps blast radius instead of lifting it).
- Skill *content* quality (semantic correctness, not structure).
- A new governance tool — all five land in existing files and
  jobs.

## Cross-scope

- **Scope 01** — F1 = P1 of the skills review.
- **Scope 02** — F5 = the runner lint + retranslation.
- **Scope 04 (leverage map)** — F1–F5 = L2 + L3 + L4 of the
  quarter plan; L1 is Scope 02.
- **Scope 05 (openclaw-doctor)** — addresses the doctor subsystem
  redesign; F2/F3 are complementary (cron + governance), not
  duplicative.
- **Scope 07 (xerahs reliability)** — F4's state-durability pass
  is the general-case version of what U1–U3 in xerahs already
  targets.
