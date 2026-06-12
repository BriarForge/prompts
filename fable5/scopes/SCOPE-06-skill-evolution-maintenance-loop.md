# Scope — F6: Skill Evolution & Maintenance Loop (skill-sustainer)

**Fable 5 prompt:** `skill-evolution-maintenance-loop.md` (6th in queue, 2026-06-12)
**Session id:** `e2628908-d240-459b-878f-ffd58bbcbc55` (final successful run; the Fable 5 queuer's first attempt at this prompt earlier in the run history failed with `claude-auto exit=1: Not logged in`)
**Outputs:**
- System at `/Users/mike/Projects/KovaForge/skills/skill-sustainer/` (created by this run)
- `RUN-REPORT-2026-06-12.md` in `fable5/skill-sustainer/` (83 lines)
- Commits in KovaForge/skills: `0689ae9` (rubric + model registry + detection engine), `3768cbd` (proposal generator + orchestrator + SKILL.md), `ab19f94` (first proposal batch: 13 patches + 2 merge proposals)

---

## What was asked

"Create a self-sustaining skill improvement system that detects when loaded
skills are stale, incomplete, or mismatched to Fable-class models, then
generates precise patches or new skills. The system must minimize manual
curator work while maintaining high signal." Grounded in
`/Users/mike/Projects/KovaForge/skills/`, `~/.hermes/`, and the Fable 5
model class.

## What it produced

A detection → proposal → approval-gate loop, fully built and verified:

1. **Rubric** (`references/RUBRIC.md`) — 8 mechanical axes (parseability,
   discoverability, connectedness, completeness, portability, freshness,
   model-fit, uniqueness), each with 0-10 anchors. High-signal proposal
   policy: severity/confidence floors, hard cap 5 proposals/run, dismissed
   fingerprints never re-proposed.
2. **Model registry** (`references/models.yaml`) — curator-maintained
   current/deprecated/never-existed Anthropic ids; Axis-7 ("Fable-class
   mismatch") lints against it. This is the "Fable-readiness" axis the
   translation layer (F2) implicitly defined.
3. **Detection engine** (`scripts/skill_audit.py`) — dependency-free
   (no PyYAML on this machine), walks both roots **following symlinks** (the
   Aoife profile links 32 hermes-agent category bundles — naive `find`
   misses 103 of 162 skills), 9 detectors, per-root policy profiles (strict
   AGENTS.md for KovaForge, looser for profile skills).
4. **Proposal generator** (`scripts/propose_patches.py`) — mechanical
   fixes become `git apply`-able unified diffs targeting the
   *real* (symlink-resolved) repo; judgment calls (duplicate merges) become
   PROPOSAL.md docs. Persistent state in
   `~/.hermes/skills-data/skill-sustainer/state.json` (fingerprints: open
   → proposed → fixed/dismissed; per-run score history with regression
   flag).
5. **Orchestrator** (`scripts/sustain.sh`) — `--run`, `--reconcile`,
   `--dismiss`, `--audit-only`.
6. **Approval gate** — *nothing* in the system edits a SKILL.md, commits,
   or pushes. The curator's only work is: read proposal → `git apply` →
   commit (or `--dismiss <id>`).

## First-run numbers (from RUN-REPORT)

- 162 skills scanned (59 KovaForge canonical, 103 profile/hermes-agent),
  **230 findings**: 3 critical, 45 high, 106 medium, 76 low. Repo rubric
  overall: **9.0/10** (mean-diluted; weak axes visible per-skill in
  `report.md`).
- Three consecutive runs emitted proposals 001-015 with **zero repeats**
  and a descending eligible backlog (153 → 148 → 143): the state memory
  works.
- All 13 generated patches pass `git apply --check` from their named repo
  roots (KovaForge/skills, BriarForge/hermes-agent, ~/.hermes).
- First 3 patches surfaced (pending curator approval):
  1. `001-todo-issue-updater-broken-yaml.patch` — critical, unquoted-colon
     description.
  2. `004-agy-links.patch` — dangling `related_skills: antigravity`.
  3. `005-architecture-diagram-links.patch` — dangling `concept-diagrams`
     ref in a symlinked hermes-agent bundle (patch correctly targets the
     real repo).

## Scope for follow-up action

**In scope (the system is built and verified, but not running on a
schedule):**
- The 13 pending `.patch` files in
  `/Users/mike/Projects/KovaForge/skills/skill-sustainer/proposals/pending/`
  awaiting curator review.
- 2 PROPOSAL.md docs in the same directory for judgment-call merges
  (`002-delegation-research-duplicate.PROPOSAL.md`,
  `003-github-model-sync-duplicate.PROPOSAL.md`).
- A cron entry to run `sustain.sh --run` on a daily or weekly cadence.
- A briefing skill/agent that surfaces the 13 patches to Mike for
  approval (or self-applies high-confidence ones).
- A pull-request generator that opens a PR per batch (so the approval
  gate is git-native rather than agent-native).

**Out of scope:**
- The detection engine's coverage of the *content* of skills (it lints
  structure, not semantics — a skill that follows the schema but gives
  wrong advice passes).
- Auto-merge for the 5 contradictory/duplicate pairs (F1 P3) — those
  need Mike's call on which side is correct.
- Re-translation of the 4 remaining pre-rubric Fable 5 prompts (F5
  observation) — this is a separate pipeline.
- F1 lint+CI (the validate-skills linter proper, which would *enforce*
  what the sustainer *detects*). They are different artifacts; the
  sustainer is proposal-based, the linter is CI-blocked.

**Decide alone:** proposal policy tuning (severity/confidence floors,
5-cap), cron cadence for `sustain.sh --run`, model registry maintenance
(curator role).

**Don't decide alone:** whether to auto-apply high-confidence patches
(safety implication: agent modifies SKILL.md files); whether to
deprecate 002/003 merge proposals (Mike has the contradictory-routing
context); whether to wire this into the F1 validate-skills linter
project or treat them as parallel systems.

## What the deliverables made possible

- **F1 P1 (validate-skills lint + CI)** has a working prototype in the
  sustainer; promoting the detection engine to a CI-blocking linter
  is a natural follow-up.
- **F1 P2 (fix 4 broken-YAML frontmatters)** has 1 critical patch
  pending in the proposal queue (`001`).
- **F1 P3 (merge 5 duplicate pairs)** has 2 PROPOSAL.md docs pending
  (002, 003).
- **F3 F1 (skill resolution registry)** can re-use the detection
  engine's "follows symlinks" approach to walk all 5 roots
  consistently.
- **F2 (translation layer) Axis-7** is now backed by a model registry
  that any future proposal can lint against.

## Headline metric

- **230 findings** on first run (162 skills scanned).
- **Repo rubric: 9.0/10** (post-F1-audit lift; the audit said 4.3, the
  sustainer says 9.0 — the methodologies are different, see RUN-REPORT
  for the per-axis breakdown).
- **Zero repeat proposals** across 3 runs: state memory works.
- **13 patches pending** curator review (approval-gate not yet
  exercised by Mike).

## Current status

**Complete, verified, and committed. Awaiting curator (Mike) review.**
This is the only Fable 5 prompt of the 8 that produced a working
*system* (not a report). The sustainer runs on demand via
`bash /Users/mike/Projects/KovaForge/skills/skill-sustainer/scripts/sustain.sh --run`.
The 13 patches are uncommitted (curator gate). Self-score: **9.5/10**
(per the Fable 5 run report).
