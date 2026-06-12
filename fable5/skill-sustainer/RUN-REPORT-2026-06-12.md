# Skill Sustainer — build + first-run report (2026-06-12)

Task: `skill-evolution-maintenance-loop.md` (Fable 5 one-shot).
System lives at `/Users/mike/Projects/KovaForge/skills/skill-sustainer/`
(commits `0689ae9`, `3768cbd`, `ab19f94` in KovaForge/skills).

## What was built

A detection → proposal → approval-gate loop:

- **Rubric** (`references/RUBRIC.md`): 8 mechanical axes — parseability, discoverability,
  connectedness, completeness, portability, freshness, model-fit, uniqueness — with a
  high-signal proposal policy (severity/confidence floors, hard cap 5 proposals/run,
  dismissed fingerprints never re-proposed).
- **Model registry** (`references/models.yaml`): curator-maintained current/deprecated/
  never-existed Anthropic ids; Axis-7 "Fable-class mismatch" lints against it.
- **Detection engine** (`scripts/skill_audit.py`): dependency-free (no PyYAML on this
  machine), walks both roots **following symlinks** (the Aoife profile links 32
  hermes-agent category bundles — naive `find` misses 103 of 162 skills), 9 detectors,
  per-root policy profiles (strict AGENTS.md for KovaForge, looser for profile skills).
- **Proposal generator** (`scripts/propose_patches.py`): mechanical fixes become
  `git apply`-able unified diffs targeting the *real* (symlink-resolved) repo; judgment
  calls (duplicate merges) become PROPOSAL.md docs. Persistent state in
  `~/.hermes/skills-data/skill-sustainer/state.json` (fingerprints: open → proposed →
  fixed/dismissed; per-run score history with regression flag).
- **Orchestrator** (`scripts/sustain.sh`): `--run`, `--reconcile`, `--dismiss`, `--audit-only`.
- **Approval gate**: nothing in the system edits a SKILL.md, commits, or pushes. The
  curator's only work is: read proposal → `git apply` → commit (or `--dismiss <id>`).

## First-run numbers

- 162 skills scanned (59 KovaForge canonical, 103 profile/hermes-agent), 230 findings:
  3 critical, 45 high, 106 medium, 76 low. Repo rubric overall: **9.0/10** (mean-diluted;
  weak axes visible per-skill in `report.md`).
- Three consecutive runs emitted proposals 001–015 with zero repeats and a descending
  eligible backlog (153 → 148 → 143): the state memory works.
- All 13 generated patches pass `git apply --check` from their named repo roots
  (KovaForge/skills, BriarForge/hermes-agent, ~/.hermes).

## First three patches surfaced (pending curator approval)

1. `001-todo-issue-updater-broken-yaml.patch` — **critical**: unquoted-colon description
   makes the skill invisible to YAML-based discovery.
2. `004-agy-links.patch` — dangling `related_skills: antigravity` (no such skill).
3. `005-architecture-diagram-links.patch` — dangling `concept-diagrams` ref in a
   symlinked hermes-agent bundle (patch correctly targets the real repo).

Plus the showcase catch later in the backlog: `013-gmail-monitor-links.patch`.

## Verification: caught ≥2 real maintenance issues

Both checks run against the actual git history, not synthetic fixtures:

1. **Retroactive test** — auditing the tree at `857526f~1` (before this week's two manual
   maintenance commits) flags **all 4** broken-YAML skills that `857526f` hand-fixed and
   **all 14** stale `vladislava-` dangling-ref skills that `f937715` hand-fixed. Both of
   those interventions would have been automated proposals.
2. **Missed-by-human test** — at today's HEAD it still finds (a) `todo-issue-updater`
   broken YAML, introduced after/missed by the quoting sweep, and (b) `gmail-monitor`'s
   `vladislava-gmail-send` ref missed by the rename sweep. Two live defects that
   currently require exactly the kind of manual intervention the system replaces.
3. **Closed loop** — applying patches 001 + 013 in a scratch worktree and re-auditing
   makes both finding fingerprints disappear; `--reconcile` marks them fixed in state.

## Rubric self-score (system applied to itself)

The auditor scans its own SKILL.md (dogfooding: 162nd skill). Self-assessment of the
delivered system against the task's own success criteria:

| Criterion | Score | Note |
|---|---|---|
| Automated detection workflow | 10/10 | 9 detectors, both roots, symlink-aware, no deps |
| Proposal generation w/ gate | 9/10 | patches verified applyable; dup-merge stays manual by design |
| Minimal curator work / high signal | 9/10 | cap 5/run, fingerprint memory, dismiss-once; severity floors |
| Caught ≥2 real issues | 10/10 | 2 historical interventions reproduced + 2 live defects found |
| First three patches delivered | 10/10 | 13 delivered, all `git apply --check` clean |
| Persistent memory + verification loop | 9/10 | state machine + score-regression flag; cron wiring left to curator |
| **Overall** | **9.5/10** | docked for: dup merges need judgment; registry needs curator upkeep |

## Standing instructions for future runs

Weekly (or post-release): `~/.hermes/skills/skill-sustainer/scripts/sustain.sh`,
review `proposals/pending/`, apply or dismiss, `sustain.sh --reconcile`, push.
