# Scope 08 — Build the Cron Sentinel (the L3 / F7-Z Absorption)

**Drives from:** `fable5/zero-zombie-initiative-os.md` ran thin and
produced **no artifact on disk** (no `fable5/zero-zombie/`
directory, no deliverable file). The prompt is marked `done` in
`progress.json` but is the queue's clearest miss. F5 (leverage map)
identifies this scope's actual content as the L3 "closed-loop
failure handling" absorption; F3 (antifragility F2) names the
same problem.
**Goal:** Build the cron health sentinel that the prompt was
*supposed* to describe but didn't, and tighten the runner's
success gate so this class of miss can't recur.
**Owner of this scope:** Declan (sentinel build) + Aoife (runner
gate) + Mike (judgment call on auto-pause thresholds).

## Steps

### 1. Retro-translate the original prompt (½ day, Aoife)
- Use `translation-layer/GOAL-TEMPLATE.md` to write a proper
  version of the prompt. Key additions the original lacked:
  - Explicit `Output:` path: `fable5/zero-zombie-initiative/
    OPERATING-SYSTEM.md` (the original guessed nothing).
  - Explicit `Done looks like:` clause listing the deliverable
    sections (rubric, assessment, scenario walkthroughs,
    prioritized upgrades, sign-off table — parallel to F3
    antifragility's structure).
  - Commit cadence: progressive commits per section, final
    commit at end.
- Score the translation against the rubric: target ≥12/14
  with no criterion at 0.
- Store the translated prompt as
  `fable5/zero-zombie-initiative/GOAL.translated.md`.

### 2. Build the cron health sentinel (1 day, Declan)
This is the actual artifact the prompt was supposed to produce.
- Extend the existing `cron-load-balancer` skill (it already
  parses `jobs.json`):
  - **Phase 1 (days 0–30, report-only):** daily digest to one
    ops channel. Flag `last_status==error`, N≥3 consecutive
    failures, refs that don't resolve (reuse the F1 resolver
    from Scope 03), delivery-channel mismatch heuristics.
  - **Phase 2 (days 31–60, blocking):** auto-pause at N≥5
    consecutive failures with `paused_reason` set. Fields
    already exist in the schema.
- One-strike rollback on wrongful auto-pause (per F3 F2
  rollback criterion).
- **Verify:** with the live PureMac + SpaceX zombies (the
  sentinel's first catches), the digest emits both
  within 24h; the second digest shows the same set; after
  Mike fixes them, the third digest shows zero.

### 3. Tighten the Fable 5 runner success gate (½ day, Aoife)
The current gate is `is_error: false`, which let the
zero-zombie prompt mark itself done with no artifact. The
new gate:
- After a run: check that `progress.json[prompt].artifacts`
  contains ≥1 file path that exists on disk AND that file's
  first non-blank line contains either `Output:`, a heading,
  or matches the prompt's `Done looks like:` clause.
- If the gate fails: revert status to `pending`, mark the
  prompt as `needs-repair`, write a one-line note to
  `runs.log` explaining which check failed.
- **Rollback:** one-strike — if the gate ever blocks a
  prompt a human reviews as well-formed, revert.
- **Verify:** the F7 zero-zombie run, replayed against the
  new gate, is correctly marked `needs-repair` with the
  evidence: "no artifact file written".

### 4. Add the per-initiative enforcement hook (½ day, Aoife)
The prompt's intent was a per-initiative OS (owner, timeout,
checkpoint, zombie-kill triggers). Operationalize the core
four fields:
- **Owner:** pull from `BRF-ORG-POL-001` role matrix.
- **Timeout:** mandate on all cron jobs and Fable 5 prompts
  (`timeoutSeconds` in the cron schema).
- **Checkpoint:** progressive commits at every major section
  for Fable 5; atomic state writes for cron jobs.
- **Zombie-kill trigger:** the sentinel (step 2) + the runner
  gate (step 3) provide mechanical enforcement; everything
  else is policy and is checked by the F3 protocol integrity
  lint (Scope 03 F3).
- **Output:** a 1-page reference at
  `fable5/zero-zombie-initiative/OPERATING-SYSTEM.md` (the
  path the retro-translated prompt in step 1 will write to).

## Verification

- Sentinel digest lives in one ops channel; first 7 daily
  digests accurate (no false positives, both real zombies
  caught).
- Live PureMac + SpaceX zombie jobs fixed; sentinel emits
  zero after.
- Runner gate: a synthetic Fable 5 run with a deliberately
  empty output produces a `needs-repair` entry in
  `progress.json` and a one-line note in `runs.log`.
- `OPERATING-SYSTEM.md` exists at
  `fable5/zero-zombie-initiative/` and contains the four
  enforcement hooks with concrete examples (1 cron, 1 Fable 5
  prompt, 1 skill-sustainer proposal).

## Out of scope

- A new initiative-management tool — this scope integrates
  with the existing cron, runner, and protocol infrastructure.
- Per-initiative content — this is meta, the OS above the
  initiatives.
- Multi-machine redundancy — F3 F5 ceiling; this scope caps
  blast radius, doesn't lift it.
- Re-running the F7 prompt with the new translation (the
  deliverable from step 1 *is* the retro-translation; running
  it is a separate decision).

## Cross-scope

- **Scope 02 (translation layer)** — step 1 uses the rubric
  template; step 3 IS the F5 runner lint + retranslation
  (the L1 absorption).
- **Scope 03 (antifragility F2)** — step 2 IS the cron health
  sentinel.
- **Scope 04 (leverage map L3)** — this scope is the L3
  absorption; the running tally of steering-event reductions
  lives in `fable5/antifragility/INCIDENTS.md` (created by
  Scope 04 L4).
- **Scope 05 (openclaw-doctor)** — Part B's doctor subsystem
  design (gateway-connectivity scenario) is the same
  failure class this sentinel catches.
- **Scope 07 (xerahs)** — U3 in xerahs is the xerahs-specific
  version of step 2.
