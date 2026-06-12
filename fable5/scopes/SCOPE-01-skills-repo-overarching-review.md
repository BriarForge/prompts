# Scope — F1: Skills Repository Overarching Review

**Fable 5 prompt:** `skills-repo-overarching-review.md` (1st in queue, 2026-06-11)
**Session id:** `74abbb81-55ae-4497-8885-6c6086be9eda` (re-run; original `e2486379-…` was SIGKILLed)
**Output:** `/Users/mike/Projects/KovaForge/skills/REVIEW-2026-06-11.md` (65 lines, untracked)
**Commits it touched:** `0b05ec4` (audit doc), `857526f` (quote YAML), `f937715` (strip vladislava- prefix), `3768cbd`/`0689ae9` (skill-sustainer, downstream)

---

## What was asked

"Conduct a comprehensive, overarching review of the entire KovaForge skills
repository and produce a prioritized improvement plan that raises the overall
quality, consistency, discoverability, and maintainability of the skill
ecosystem." (Reviewed 58 skills in `/Users/mike/Projects/KovaForge/skills/`
against the governance spec in `AGENTS.md`.)

## What it produced

- A 7-criterion, 0-10 rubric applied to all 58 skills → **overall repo score
  4.3/10** (spec is good; compliance is low because nothing enforces it).
- Headline findings: 4 invisible-to-discovery skills (broken YAML), 5
  duplicate pairs of which 2 are *actively contradictory* (`bitwarden`/
  `bitwarden-secrets` on `bw` CLI deprecation; `delegation-research`/
  `research-delegation` with byte-identical descriptions and different routing
  tables), 39 dangling `related_skills` (mostly stale `vladislava-` prefix
  from a past mass rename), 10 stubs, 45/58 hardcoded `/Users/mike` paths,
  zero CI/lint.
- P1-P7 prioritized plan with effort + impact estimates, plus a governance
  rules section to prevent recurrence, plus a "highest-value individual
  skill patches" sub-list (bitwarden merge first, delegation merge second,
  then the four broken-YAML one-liners, etc.).

## Scope for follow-up action

**In scope (this is what the audit was about):**
- The KovaForge skills repo at `/Users/mike/Projects/KovaForge/skills/`.
- 58 skills, AGENTS.md spec, scripts/ and references/ assets.
- Owner decisions on the 3 contradictory/duplicate merges that require
  human judgment (bitwarden pair, delegation pair, doccontrol pair).

**Out of scope (the audit explicitly didn't touch):**
- Per-profile skills under `~/.hermes/profiles/*/skills/` (covered by
  F4 ecosystem-antifragility and F6 skill-sustainer).
- Cron jobs referencing skills (covered by F2 cron-sentinel from the
  antifragility audit).
- Hermes/OneDrive backup config (covered by F4 state-durability pass).
- The Fable 5 prompt queue mechanics (covered separately).

**Decide alone:** minor mechanical fixes — quoting YAML descriptions with
embedded colons, stripping stale `vladislava-` prefixes from `related_skills`,
writing `superseded_by:` tombstones for merged duplicates.

**Don't decide alone:** which routing table is correct in
`delegation-research` vs `research-delegation` (contradictory on
Milena/Nadia vs Mikhail/Declan/Viktor; needs Mike to pick); whether `bw`
CLI is deprecated and which skill should absorb the other (Mike has the
real Bitwarden usage history); which tag schema wins
(top-level `tags:` vs `metadata.hermes.tags`; affects 54 skills).

## What the deliverables made possible

- **F6 (skill-sustainer) could be designed against the same 8 axes** the
  audit used (parseability, discoverability, connectedness, completeness,
  portability, freshness, model-fit, uniqueness) — the audit's rubric is
  the spec the sustainer enforces.
- **F4 (antifragility) F1 finding** "skill resolution is fragmented" was
  quantified by this audit (39 dangling refs, 5 duplicate pairs,
  2 contradictory).
- **P1 lint+CI upgrade** from the audit became a natural follow-up;
  not yet actioned.

## Headline metric

Repo overall score: 4.3/10 → target ≈7.0/10 (criteria 1, 2, 3, 7 all rise to
8+; criteria 4 and 5 rise via the linter ratchet) after P1-P5 are
executed. Estimated effort: two short sessions of work.

## Current status

**Audit complete; P1-P7 plan uncommitted to action.** REVIEW-2026-06-11.md
sits in `/Users/mike/Projects/KovaForge/skills/` uncommitted. The
mechanical P2-P4 fixes (broken YAML, dangling refs, name≠folder) have
*not* been applied to disk. Mike asked: "Audit actions?" — answer
remains: plan exists, plan not actioned.
