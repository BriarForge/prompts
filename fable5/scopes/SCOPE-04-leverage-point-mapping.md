# Scope 04 — Execute the 30/60/90 Lever Plan (L1–L4)

**Drives from:** `fable5/leverage-map/LEVERAGE-MAP.md` (4 leverage
points L1–L4 with before/after metrics, dependency map, 30/60/90
rollout). Baseline: ≥5 steering events / 48h on the autonomous
pipeline. Target: ≤1 steering event / 30d at day 90.
**Goal:** Land L1–L4 sequentially and reduce steering events
measurably.
**Owner of this scope:** Per-leverage owners below.

## Steps

### Days 0–30 — close the live leaks, everything report-only

**L1 (Aoife, 1 day) — Validated goal contract at the execution seam**
- Runner lint + auth preflight + retranslate 4 pre-rubric prompts.
- This scope IS Scope 02 steps 2–4. Implement once, track here.
- **Day-30 metric:** pre-rubric prompts 4/8 → 0; truncated/half-
  executed goals structurally impossible; runs forced to guess
  output path 2-of-last-3 → 0.

**L2 (Aoife + Declan, 1.5 days) — One source of truth for capability knowledge**
- Hermes resolution-precedence read (precondition for registry
  semantics; this is Scope 02 step 1).
- `validate-ecosystem.py` in report-only mode (Scope 03 F1 phase 1).
- 4 YAML fixes + merge the 2 contradictory pairs (bitwarden,
  delegation — Scope 01 P2/P3).
- **Day-30 metric:** cron skill refs resolving nowhere 2→0 (held by
  weekly lint); contradictory duplicate pairs 2→0.

**L3 phase 1 (Declan, 1 day) — Closed-loop failure handling**
- Cron health sentinel digest live to one ops channel
  (Scope 03 F2 phase 1).
- Fix both live zombies (PureMac, SpaceX) + PureMac delivery
  misroute.
- Skills sync weekly→daily (Scope 03 F4 b).
- Backup manifest check live (Scope 03 F4 a).
- **Day-30 metric:** MTTD for failing cron job ∞ → <24h; live
  zombie jobs 2→0; machine-local unpushed skill work 7d→1d.

**L4 (Aoife + Viktor, ~1 day in days 0–30) — Mechanical
incident→control metabolism, start**
- Incident log file at `fable5/antifragility/INCIDENTS.md` (one row
  per incident, fragility class F1–F6+, resulting check or written
  waiver).
- `BRF-OPS-POL-003` pair merged, survivor indexed.
- Protocol integrity lint running report-only (Scope 03 F3).
- **Day-30 metric:** incident→control conversion ad-hoc → mechanical;
  duplicate protocol IDs 1→0; policies with automated checks 0/8
  (start, target 4/8 by day 90).

### Gate to day-31
- 2 weeks of L3 digest accuracy.
- L2 lint FP rate measured.
- L1 runner lint never blocked a human-judged-well-formed prompt.

### Days 31–60 — promote to blocking, finish unification

**L2 (Declan, 0.5 day) — promote to blocking**
- Pre-commit + CI + schedule-time gate blocking (if FP <5%).
- Remaining 3 duplicate-pair merges (Scope 01 P3).
- `vladislava-` ref fix (Scope 01 P2).
- Tag-schema migration + AGENTS.md update (Scope 01 P4).
- **Day-60 metric:** KovaForge repo rubric 4.3/10 → ≈7/10.

**L3 phase 2 (Declan, 0.5 day) — auto-pause**
- N≥5 consecutive failures → auto-pause with `paused_reason`.
- Resolver-backed ref checks in sentinel (uses L2's resolver).
- **Day-60 metric:** zero zombie recurrence; MTTD stays <24h.

**L4 (Aoife, 0.5 day) — first 2 policy checks**
- Git Policy wrapper check (already partially enforced by
  `git-aoife`/`git-mikhail` etc.; formalize the check).
- Secrets Policy scan (currently in the pre-commit layer in some
  repos; ship the lint).
- Weekly Aoife self-audit cron live (Hermes mirror of
  `coo-self-audit`).
- **Day-60 metric:** policies with automated checks 0/8 → 2/8;
  self-improvement trigger in-session recall → scheduled weekly
  (before user frustration).

### Days 61–90 — make it compound, then measure

**L4 (Aoife + Viktor, 0.5 day) — policy-PR-ships-check rule + runbook**
- Active rule: every policy PR ships a check or records why not.
- 4/8 policies with automated checks.
- `RECOVERY.md` fresh-machine restore runbook rehearsed once on
  a clean environment.
- **Day-90 metric:** machine-loss event bounded to measured restore
  time; policies with automated checks 4/8.

**Final measurement pass (Aoife, ½ day)**
- Re-run all deterministic queries from the leverage map and the
  antifragility assessment.
- **Day-90 metric:** steering events over trailing 30 days ≤1;
  KovaForge rubric ≥7/10; system ≥7.0/10.

## Verification

- All §1 metrics in `LEVERAGE-MAP.md` pass at the day-30/60/90
  gate.
- 30-day trailing steering-event count ≤1 (each one logged in
  `INCIDENTS.md` with a resulting control).
- Each remaining steering event consumed by L4's metabolism loop
  exactly once (i.e., logged incident → control fired within 7
  days).

## Out of scope

- Stub backfill (KovaForge P6/P7) — ratchets for free via L2
  linter warnings.
- Multi-machine redundancy — structural ceiling; L3 + L4 cap
  blast radius.
- Discord channel re-architecture — only the ops-digest channel
  matters for steering.
- New orchestration tooling — every change lands in files that
  already exist.

## Cross-scope

- **Scope 01** — L2 (KovaForge portion).
- **Scope 02** — L1.
- **Scope 03** — F1–F5 = L2 + L3 + L4 (L1 is Scope 02).
- **Scope 06 (skill-sustainer)** — runs L2's lint in audit-only
  mode after L2 lands.
- **Scope 07 (xerahs reliability)** — L1 patterns applied to
  xerahs; L3's liveness watchdog is a generalization of U3 in
  xerahs.
