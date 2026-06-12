# Scope 07 — Execute the XerahS Reliability Plan (U1–U10 + 5 Human Actions)

**Drives from:** `/Users/mike/Projects/KovaForge/xerahs/docs/RELIABILITY-PLAN.md`
(7 sections, 8 evidence-verified observations O1–O8, 19 failure
modes mapped, 10 upgrades U1–U10, 6 drift findings D1–D6, 2 failure
simulations walked, 3-week sequencing).
**Goal:** Land U1–U10 in the sequenced order and execute the 5
human-action items in §5 of the plan. Verification: re-run §1
evidence commands; expect 0/8 observations live.
**Owner of this scope:** Per-upgrade owners (mostly cron + Aoife
for SKILL.md edits); 3 items need Mike sign-off per §5.

## Steps

### 0. Immediate human actions (today, ~10 min, Mike)
1. **Remove the stale lock (O1).** Per the protocol only a human
   removes another run's lock:
   `rm -rf /Users/mike/Projects/KovaForge/xerahs/.xerahs-workspace.lock`
   (pid 47912 verified dead 2026-06-12 14:30 AWST).
2. **Free disk space (O4).** 387 MiB free is below the safe
   operating floor. Delete the repo-root binlogs (`axaml_error.binlog`,
   `build.binlog`, 3 MB) and the 228 KiB release-run log after
   confirming no open investigation references them. Prune
   `~/.openclaw/tmp` (507 entries).

### 1. Week 1 — unblock + see (3 upgrades, Aoife + cron)
**U1 (P0) — Stale-lock detection and safe self-recovery**
- Owner: Aoife (SKILL.md edit), cron (the sweep executes the
  recovery).
- Edit `xerahs-hourly-sweep/SKILL.md` step 1 with the diff in
  §3 of the plan: parse `owner` + `pid`, rename to
  `.xerahs-workspace.lock.stale-<UTC-ts>` if `owner=declan`
  AND pid dead AND started_utc > 8h ago.
- Mike sign-off required (lock protocol is shared with
  Mikhail's manual-review workflow; 8h expiry needs Mikhail's
  confirmation).
- **Verify:** synthetic dead-pid lock older than 8h is
  quarantined; mikhail file-lock still defers (both
  demonstrated in a dry-run).

**U2 (P0) — Disk-space preflight gate for all four workflows**
- Owner: cron (the gate executes in-pipeline).
- Add shared preflight snippet (`skills/_shared/preflight-disk.sh`
  or inline): `df -k /`; abort with `PREFLIGHT_DISK_LOW <free>`
  if free < 2 GiB.
- Wire as step 0 of: hourly sweep, pre-release, KFIP, issue
  monitor. For URL publishing, gate only uploads of files
  larger than remaining free space.
- Wire U3's watchdog to count consecutive disk-aborts and
  escalate to Discord after 2.
- **Verify:** simulated `df` reporting <2 GiB aborts at step 0;
  ≥2 GiB proceeds.

**U3 (P0) — Pipeline liveness watchdog**
- Owner: Aoife (script), cron (daily schedule), Mike (Discord
  channel ID).
- New `scripts/xerahs-liveness-watchdog.py` with manifest:
  - `~/.openclaw/state/xerahs-issue-monitor.json` → max 8 days
  - `docs/reports/hourly_review_state.json` → max 12 h
  - `git log -1 --format=%ct` of `origin/develop` vs local
    → alert if origin >7d AND >10 commits behind
  - newest `/tmp/xerahs-prerelease-pipeline/build-*.log` → max 8d
- Discord post on breach (dedupe via atomic state file, same
  pattern as U4).
- **Verify:** with the May-9 state file as-is, manual run emits
  exactly one issue-monitor staleness alert; after touching
  the file, emits none.

### 2. Week 2 — stop the silent class (3 upgrades, Aoife + cron)
**U4 (P1) — Issue-monitor state durability + path repair**
- Owner: Aoife (script + SKILL.md fix), cron (unchanged cadence).
- Fix SKILL.md execution path to
  `…/skills/xerahs-issue-monitor/scripts/xerahs-issue-monitor.py`
  (verified to exist 2026-06-12).
- Atomic state writes (`json.dump` to `.tmp` + `os.replace()`),
  keep 3 rotated copies.
- Restore newest parseable rotation on load failure; reset
  only if all rotations fail, then emit
  `XERAHS_ISSUE_MONITOR_STATE_RESET`.
- GitHub token preflight; fail fast with
  `XERAHS_ISSUE_MONITOR_FAILED: no-auth` rather than burning
  the 60/h anonymous quota.
- **Verify:** truncated state file → restore from rotation,
  no mass re-escalation. SKILL.md command runs as pasted.

**U5 (P1) — Upload retry with verification (URL publishing)**
- Owner: Aoife (SKILL.md edit), Declan (ReClip `app.py` edit).
  Mike sign-off required (touches the automated publish path
  that produces published URLs).
- Wrap upload in 3-attempt retry, backoff 5s/20s.
- After any reported success: parse JSON strictly (U6) +
  `curl -sI` the URL expecting HTTP 200 + approved-host check.
- On final failure: `status=failed` in ReClip job JSON +
  diagnostic, never pending.
- **Verify:** network dropped after attempt 1, restored before
  attempt 2 → verified URL. Network down throughout → `failed`
  + diagnostic, no pending job remains.

**U6 (P1) — Contract validation at every external boundary**
- Owner: Aoife (validators), cron (validators run inside
  pipelines).
- URL publishing: parse `--json` strictly; non-empty `url`,
  https, extension in `filename`.
- Issue monitor: validate `number`, `updated_at`, `comments`,
  `labels[].name`, `user.login` before classification; on
  missing field → `ContractError`, skip state write so `seen`
  is preserved.
- Pre-release/sweep: bound NETSDK1004/CS0006/restore retries
  (one per class); `dotnet test` non-zero with zero parsed
  results = "runner crash", not "tests failed".
- Document each boundary in
  `docs/technical/external-contracts.md`.
- **Verify:** fixture with `labels` as objects-missing-`name` →
  `XERAHS_ISSUE_MONITOR_FAILED: contract …`, unchanged state
  file, Discord failure alert.

### 3. Week 3+ — harden + tidy (4 upgrades, Aoife + cron)
**U7 (P2) — Remote/identity matrix + standardized push verification**
- Owner: Aoife (matrix doc), cron (verify-push.sh call).
- `docs/technical/remote-identity-matrix.md`: one row per agent
  (wrapper, remote, SSH host alias, ref to verify, "fetch
  before compare" rule).
- `scripts/verify-push.sh <remote> <branch>`: fetches,
  compares `HEAD` to `refs/remotes/<remote>/<branch>`, prints
  `PUSH_VERIFIED` or `PUSH_NOT_VERIFIED <details>`.
- Reference from all four pipeline SKILL.mds.
- Classify `Permission denied (publickey)` as a hard blocker
  in all skills.
- **Verify:** `verify-push.sh declan develop` → `PUSH_VERIFIED`
  today; `verify-push.sh origin develop` → `PUSH_NOT_VERIFIED`
  (14 behind).

**U8 (P2) — Durable-write hygiene**
- Owner: Aoife (helpers), cron (hooks run inside commits).
- `scripts/append-md.sh <file>`: reads stdin, appends, then
  re-reads and fails loudly on mismatch.
- `.githooks/pre-commit`: if
  `docs/reports/hourly_review_state.json` is staged, run
  `python3 -m json.tool` and verify `last_runs` length did
  not shrink by >1 vs HEAD.
- Make the quoted-heredoc rule a hard rule with the helper as
  the default.
- **Verify:** invalid state JSON rejected; valid passes.

**U9 (P2) — Skill↔repo drift lint (wire into skill-sustainer)**
- Owner: Aoife (sustain config), Mike (proposal approval).
- Add 5 checks to the sustainer for the xerahs skills:
  (a) every absolute path in SKILL.md exists on disk
  (allowlist `/tmp/...` templates);
  (b) no duplicated H3 headings;
  (c) workspace paths are byte-exact `…/KovaForge/xerahs`
  (case-sensitivity portability);
  (d) schedule words in name/description match declared
  cadence.
- File the four known O7 defects as sustainer proposals
  immediately (two are one-line fixes: path + dedupe).
- Sustainer remains propose-only.
- **Verify:** sustainer run flags exactly the four O7 defects
  on current skills, zero after fixes.

**U10 (P3) — Artifact hygiene**
- Owner: Mike (one-off deletes + .gitignore), cron (rotation).
- Add `*.binlog` and `release-run-*.log` to `.gitignore`.
- Mike deletes `axaml_error.binlog`, `build.binlog`,
  `release-run-25249540090-job-74039372317.log` (cross-ref
  step 0.2 above).
- Sweep's step 1: prune `/tmp/xerahs-hourly-sweep/` and
  `/tmp/xerahs-prerelease-pipeline/` files older than 14 days
  (strictly scoped).
- U3 watchdog reports count/size of `/tmp/xerahs-*`.
- **Verify:** `git status` clean; sweep prunes 15-day-old
  files.

### 4. Drift reconciliation (D5, Mike)
- Reconcile the release-cadence discrepancy: pre-release SKILL.md
  says "Weekly Wednesday 20:00 Perth"; `jobs.json.bak` shows
  `0 18 * * 6` (Saturday 18:00). Mike picks. Edit whichever
  is wrong to match the other; update the watchdog threshold
  in U3 if the cadence changes.

## Verification

- All 8 observations O1–O8 re-checked on completion:
  - O1: `ls .xerahs-workspace.lock` → no such file.
  - O2: `cat docs/reports/hourly_review_state.json` →
    `last_updated` within 12 h of now.
  - O3: `cat ~/.openclaw/state/xerahs-issue-monitor.json` →
    `last_run_at` within 8 days.
  - O4: `df -h /` → ≥ 5 GiB free.
  - O5: `ls ~/.openclaw/cron/` → no `*.tmp` orphans.
  - O6: `git rev-list --count origin/develop..develop` → 0.
  - O7: 4 drift findings fixed (U9 verification).
  - O8: `du -sh build.binlog axaml_error.binlog` → no such file.
- §2 failure-mode table: every "observed" row now has a
  corresponding U1–U10 upgrade that prevents recurrence.
- Mike sign-off on U1, U5, and the drift reconciliation in D5.

## Out of scope

- The XerahS app code itself (no source changes proposed in the
  plan; the run contract was "no changes applied").
- Non-XerahS cron jobs (covered by Scope 03 F2).
- Per-skill quality beyond the U9 sustainer checks.
- The skill-sustainer itself (Scope 06; U9 extends it but the
  build is in Scope 06's scope).

## Cross-scope

- **Scope 02 (translation layer)** — U1, U4, U5, U6 are exactly
  the kind of prompt contracts the layer scores.
- **Scope 03 (antifragility)** — U3 is the xerahs-specific
  instance of L3's closed-loop failure handling. F4 (state
  durability) generalizes U2's disk gate.
- **Scope 06 (skill-sustainer)** — U9 extends the sustainer.
  Apply U9's 4 O7 patches as part of the curator pass in
  Scope 06 step 1.
- **Scope 04 (leverage map L1)** — the prompt-repair pattern
  from the translation layer (xerahs prompt was repaired using
  example 02) is the L1 form of this scope.
