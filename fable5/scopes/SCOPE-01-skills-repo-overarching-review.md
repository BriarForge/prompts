# Scope 01 — Implement Skills Repo Review (P1–P7)

**Drives from:** `fable5/skills-repo-overarching-review.md` →
`/Users/mike/Projects/KovaForge/skills/REVIEW-2026-06-11.md` (overall score 4.3/10)
**Goal:** Raise the KovaForge skills repo from 4.3/10 to ≈7.0/10 by
landing the prioritized plan (P1–P7) below. Verification: re-run the
audit parser; expect criteria 1, 2, 3, 7 to rise to 8+, criteria 4 and 5
to rise via the linter ratchet.
**Owner of this scope:** Aoife (registry/policy), Declan (lint build),
Mike (judgment calls on duplicate merges).

## Steps

### P1 — Build validate-skills linter + CI gate
1. `validate-skills.py` (Declan, ~½ day): walks the KovaForge repo,
   checks 8 axes from the audit's rubric (parseability, discoverability,
   connectedness, completeness, portability, freshness, model-fit,
   uniqueness). Run report-only for 2 weeks.
2. Wire as pre-commit hook in `KovaForge/skills/.git/hooks/pre-commit`.
3. Wire as a CI step in the repo (GitHub Actions on push; the repo has
   none today).
4. Promote to blocking at the 2-week gate only if false-positive rate
   <5% of flags; demote on 2 wrongful blocks.

### P2 — Mechanical fixes (~30 min each, in priority order)
1. Quote the 4 broken-YAML frontmatters (unquoted colon in description).
2. Strip stale `vladislava-` prefix from 39 dangling `related_skills`
   references.
3. Fix the 3 skills where folder name ≠ skill name.
4. Remove 10 stubs OR add `superseded_by:` tombstones to them.

### P3 — Merge the 5 duplicate pairs (Mike decision)
Order (contradictory first):
1. `bitwarden` + `bitwarden-secrets` — pick one, the other becomes
   `superseded_by:`. Mike decides which absorbs the other.
2. `delegation-research` + `research-delegation` — byte-identical
   descriptions, different routing tables (Milena/Nadia vs
   Mikhail/Declan/Viktor). Mike picks the correct routing.
3. `kovadoccontrol` + `kovaforge-doccontrol` — likely fixed already
   by the F4 openclaw-doctor auto-commit `7b06f1c`; verify.
4. `github-model-sync` (F6 PROPOSAL-003) — Mike confirms it's truly
   duplicate.
5. One more — verify against current HEAD of the skills repo.

### P4 — Unify tag schema
1. Audit: 54/58 skills use top-level `tags:`; 4 use
   `metadata.hermes.tags`. Pick top-level (majority).
2. Update `AGENTS.md` spec to match the chosen schema.
3. Migrate the 4 outliers with a one-off script.

### P5 — Portability pass (45/58 hardcoded `/Users/mike`)
1. Add an `AGENTS.md` rule: skill paths relative to the repo root
   unless they explicitly need an absolute path (and the `validate-skills`
   linter enforces it).
2. Migrate the 45 skills to relative paths or
   `~/.hermes/skills/<name>/` form.
3. Verify the linter has Axis-5 (portability) score = 0 violations.

### P6 — Stub backfill (deferred to skill-sustainer)
1. The 10 stubs become warnings in `validate-skills` (already covered by
   Axis-4 completeness).
2. `skill-sustainer --run` (Scope 06) will surface one per session.
   No dedicated work here.

### P7 — Per-profile skill audit (out of scope for this scope)
The 58-skill review is KovaForge canonical only. Per-profile skills
(5 resolution roots total) are covered by the ecosystem registry in
Scope 02 / Scope 03 (F2/F3) and by Scope 06 (skill-sustainer).

## Verification

- Re-run the audit parser: 4.3/10 → ≈7.0/10.
- `validate-skills` linter passes in CI; subsequent commits keep it
  there.
- 0 contradictions, 0 dangling refs, 0 broken YAML, 0 hardcoded
  `/Users/mike` paths, 0 stub-without-tombstone.

## Out of scope

- Per-profile skills (`~/.hermes/profiles/*/skills/`).
- Non-frontmatter content quality (the linter checks structure, not
  semantic correctness).
- Hermes internal resolution precedence (out of scope per the
  audit; needs a Hermes source read first; see Scope 02 step 1).

## Cross-scope

- **Scope 02 (translation layer)** — applies the rubric to *future*
  prompts; P1 here builds the *equivalent* linter for skills.
- **Scope 03 (antifragility F1)** — this P1 IS the F1 ecosystem
  resolution registry, scoped to the KovaForge repo only.
- **Scope 06 (skill-sustainer)** — runs P1's linter in audit-only
  mode; the linter's 8 axes are the same axes the sustainer
  detects.
