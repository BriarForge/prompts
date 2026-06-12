# Scope 06 — Operate the Skill-Sustainer + Land the 13 Pending Patches

**Drives from:** `KovaForge/skills/skill-sustainer/` (built and
verified by the Fable 5 run; 13 mechanical `.patch` files + 2
judgment-call `PROPOSAL.md` docs in `proposals/pending/`; 230
findings on first scan across 162 skills, 9.0/10 mean).
**Goal:** Curate (Mike) the 15 pending items, wire the sustainer
into a daily cron, and confirm the loop is self-sustaining.
**Owner of this scope:** Mike (curator gate) + Aoife (sustainer
maintenance).

## Steps

### 1. Curator review of the 15 pending items (Mike, ~1 hour)
Read each file in `KovaForge/skills/skill-sustainer/proposals/pending/`:

**Patches (13, mechanical, apply directly):**
- `001-todo-issue-updater-broken-yaml.patch` — critical, unquoted
  colon. Apply.
- `004-agy-links.patch` — dangling `related_skills: antigravity`.
  Apply.
- `005-architecture-diagram-links.patch` — dangling
  `concept-diagrams` ref in a symlinked hermes-agent bundle.
  Apply (target = real repo, patch already does).
- `006-audiocraft-schema.patch` — review, apply if correct.
- `007-bank-statement-bookkeeping-links.patch` — apply.
- `008-cmc-cli-links.patch` — apply.
- `009-comfyui-links.patch` — apply.
- `010-delegation-claude-code-schema.patch` — review (touches
  delegation family; cross-refs Scope 01 P3).
- `011-delegation-codex-schema.patch` — same.
- `012-finance-investment-report-links.patch` — apply.
- `013-gmail-monitor-links.patch` — apply.
- `014-godmode-links.patch` — apply.
- `015-hermes-openclaw-ops-schema.patch` — review (touches the
  cross-org boundary).

For each: `cd <target-repo> && git apply <patch>` → verify with
`git diff` → `git-aoife commit -m "skill-sustainer: apply <NNN>"`.

**PROPOSAL.md docs (2, judgment calls — Mike only):**
- `002-delegation-research-duplicate.PROPOSAL.md` — Mike picks
  the correct routing table (cross-refs Scope 01 P3 step 2).
  Either way, the loser becomes `superseded_by:`.
- `003-github-model-sync-duplicate.PROPOSAL.md` — Mike confirms
  it's truly duplicate; merge or close.

### 2. Wire sustainer into daily cron (½ day, Aoife)
- Add OpenClaw cron entry: daily 03:00 AWST, runs
  `bash /Users/mike/Projects/KovaForge/skills/skill-sustainer/scripts/sustain.sh --run`.
- Output digest to one ops channel (`#bf-skill-sustainer` or
  similar — Mike to pick the channel; the F3 ops channel is the
  precedent).
- Cron preflight: verify `claude-auto` is logged in
  (Scope 02 step 3) before running.
- State durability: `~/.hermes/skills-data/skill-sustainer/state.json`
  joins the backup manifest (Scope 03 F4 a).

### 3. Validate the loop self-sustains (1 week observation, Aoife)
- After 7 daily runs:
  - Eligible backlog count must be strictly decreasing or stable
    (state memory works → no repeat proposals).
  - Per-day proposal count ≤5 (the hard cap).
  - False-positive rate <5% (otherwise: adjust severity/confidence
    floors in `scripts/propose_patches.py` and re-run).

### 4. Promote to weekly auto-merge (deferred, after step 3 passes)
- Add a `--high-confidence-auto-apply` flag that applies patches
  with `severity=critical AND confidence>0.95 AND no related_skills
  touched` without curator review.
- **Rollback:** one-strike (if a high-confidence patch breaks a
  skill, disable the flag, re-curate the broken change).
- **Pre-condition:** 30 days of clean daily runs.

## Verification

- All 15 pending items resolved (applied, dismissed with reason,
  or escalated to Scope 01 P3).
- 7-day daily cron produces strictly decreasing or stable
  eligible-backlog count.
- `~/.hermes/skills-data/skill-sustainer/state.json` is in the
  backup manifest and survives a test backup-restore.
- Self-score from the Fable 5 run report: 9.5/10 confirmed
  after curator pass (no regressions from the 13 patches).

## Out of scope

- Detection of skill *content* (semantic) errors — sustainer
  lints structure, not advice.
- Auto-merge of the 5 contradictory/duplicate pairs from
  Scope 01 P3 (the 2 PROPOSAL.md docs are the start; the
  remaining 3 are Scope 01's job).
- Retro-translation of pre-rubric Fable 5 prompts (Scope 02).
- Promotion of the sustainer to a CI-blocking linter (Scope 01
  P1 is the linter; sustainer is the propose-only complement).

## Cross-scope

- **Scope 01 P1 (validate-skills linter)** — sustainer's
  detection engine is the prototype for that linter; promote
  it to a blocking CI step after Scope 01 P1 lands.
- **Scope 01 P3 (merge duplicate pairs)** — the 2 PROPOSAL.md
  docs in pending/ feed into that scope.
- **Scope 02 (translation layer)** — sustainer's
  `references/models.yaml` (Axis-7 model-fit lint) implements
  the Fable-readiness check.
- **Scope 03 (antifragility F1)** — sustainer runs on the
  resolved registry once F1 lands.
- **Scope 07 (xerahs)** — U9 in xerahs extends the sustainer
  with xerahs-specific drift checks.
