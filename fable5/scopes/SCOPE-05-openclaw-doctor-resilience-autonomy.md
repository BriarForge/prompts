# Scope 05 — Verify Doctor Auto-Repairs + Complete the Missing Subsystem Design

**Drives from:** `fable5/openclaw-doctor-resilience-autonomy.md` ran
thin and was absorbed by side-effect into the skills repo
(commit `7b06f1c`, 34 files, 2518+ line changes). No deliverable
file was produced; the prompt's stated "Done looks like" (concrete
improvements + ownership + verification + rubric self-score) was
not met.
**Goal:** Two things — (a) verify the 14 side-effect changes are
intended and don't break the doctor path; (b) actually do the
doctor subsystem work the prompt was supposed to do.
**Owner of this scope:** Aoife (subsystem design) + Declan
(verification) + Mike (sign-off on commits touching doctor).

## Steps

### Part A — Verify the side-effect commits (~½ day, Declan)
1. Read commit `7b06f1c` diff fully. Catalog the 34 files into:
   - **Intended repairs** (resolve F1 P1–P3 or other known audit
     items): mark green, no further action.
   - **New skills** (`bitwarden-bsm-migration`, `puremac-disk-hygiene`):
     verify SKILL.md frontmatter passes the validate-skills linter
     (Scope 01 P1) and the skill-sustainer (Scope 06) picks them up
     on next `--run`.
   - **Removed** (`financial-report` SKILL.md, `generate.js`):
     verify no cron job or skill still references them. The
     F1 audit's `financial-report` cross-profile finding is
     therefore in scope to re-examine (is the canonical home now
     `reports/` or `AI/financial/reports/`?).
   - **Rewrites** (`doccontrol`, `bitwarden`, `bitwarden-secrets`,
     `cmc-cli`, etc.): verify the new content is loadable (open
     the file, ensure no broken sections) and check that any
     consuming cron job or skill still points at the same paths.
2. Run `validate-skills` (Scope 01 P1, or the equivalent ad-hoc
   linter if it doesn't exist yet) over the entire repo after the
   commit lands; report violations.
3. Verify no Fable 5 cron entry or the `cron-load-balancer` references
   the deleted `financial-report` skill.
4. **Output:** one PR with a "doctor-side-effect verification" report
   listing green/red per change, plus a rollup commit if any change
   needs reverting.

### Part B — Actually do the doctor subsystem work (~1 day, Aoife)
The prompt asked for a "doctor resilience quality" rubric, two
realistic failure scenarios walked end-to-end, and a prioritized
improvement plan. None of these were produced. Re-do them now
*using* the F2 translation-layer template:

1. Write the doctor-resilience rubric (parallel to the
   translation-layer rubric; 6–7 criteria, 0–2 scoring, threshold
   for "Fable-ready"). Save to
   `fable5/openclaw-doctor/RUBRIC.md`.
2. Score the current doctor subsystem against the rubric. Save to
   `fable5/openclaw-doctor/ASSESSMENT.md`.
3. Walk two failure scenarios end-to-end (per the prompt):
   - **Scenario 1: agent config drift.** Today: detected by
     `cron-load-balancer` weekly, surfaced as a digest. With
     proposed upgrades: detected within 1h by an in-agent
     self-check, with auto-remediation via the per-person
     `git-<person>` wrapper.
   - **Scenario 2: gateway connectivity loss.** Today: surfaced
     by the F2 cron sentinel (Scope 03) only after the run fails.
     With proposed upgrades: gateway emits a structured event
     on disconnect; doctor ingests it within 5 min; if the
     gateway does not reconnect within 10 min, doctor opens a
     `paused` job with `paused_reason` set.
4. Prioritize the upgrades with owner, rollback, second-order
   effect (parallel to F3 F1–F5).
5. **Output:** one PR with the rubric, assessment, two scenarios,
   and the prioritized plan.

### Part C — Mike sign-off (~½ day, Mike)
- Review the Part-A rollup.
- Review the Part-B design.
- Sign-off on (or amend) any upgrade touching the doctor
  subsystem.

## Verification

- Part A: `git diff <before-7b06f1c>..7b06f1c` reviewed; no
  unintended breakage; `validate-skills` clean.
- Part B: rubric, assessment, 2 scenarios, prioritized plan all
  committed under `fable5/openclaw-doctor/`. Self-score from the
  prompt's own rubric ≥7/14.
- Part C: Mike's approval recorded in the commit message or
  follow-up.

## Out of scope

- The Fable 5 prompt's *literal* execution — that ship has
  sailed; we are recovering the lost work, not re-running the
  prompt.
- Per-agent health monitoring beyond the two scenarios — the
  doctor subsystem is the framing; one set of scenarios is
  enough to prove the design.
- Per-skill deep dives — that is Scope 01 / Scope 06.

## Cross-scope

- **Scope 02 (translation layer)** — Part B uses the rubric
  template.
- **Scope 03 (antifragility)** — Part A verifies the F1 P3
  duplicate-pair merges that this prompt's side-effect
  consumed.
- **Scope 06 (skill-sustainer)** — picks up the new skills
  (`bitwarden-bsm-migration`, `puremac-disk-hygiene`) on next
  run; any drift will be filed as a proposal.
- **Scope 07 (xerahs)** — the gateway-connectivity scenario is
  the same failure class as the xerahs liveness watchdog
  (Scope 07 U3).
