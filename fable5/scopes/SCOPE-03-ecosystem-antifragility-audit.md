# Scope — F3: Ecosystem Antifragility Audit

**Fable 5 prompt:** `ecosystem-antifragility-audit.md` (3rd in queue, 2026-06-11)
**Session id:** `38c06fb8-448e-49e0-a649-5568a02eb7ff`
**Outputs (in `fable5/antifragility/`):**
- `RUBRIC.md` (73 lines, 6-criterion 0-10 antifragile-quality rubric)
- `ASSESSMENT.md` (302 lines, full assessment, baseline system 4.0/10)
- `CLAUDE.md` (62 lines, project memory with intervention status table)
**Commits:** `1f15f95`, `2e890f6`, `bd64692`, `6e692de` (cross-link to F5)

---

## What was asked

"Produce a complete antifragility assessment of the current
KovaForge/OpenClaw/Hermes agent ecosystem using only these verified roots:
`/Users/mike/.hermes/protocols/`, the skills repo, `jobs.json`, Aoife
profile skills, and the Fable 5 queue runner." (Used "more than robust":
stressors should leave the system *structurally stronger*, not just
patched.)

## What it produced

- A 6-criterion rubric (failure visibility, stressor metabolism, redundancy
  with divergence control, reference & boundary integrity, concentration
  risk, optionality) scored 0-10. **Baseline system score: 4.0/10.**
- Top 5 fragility sources, ranked by (blast radius × likelihood × silence):
  - **F1** skill resolution fragmented across ≥5 roots with zero
    reference validation (evidence: 2 cron jobs reference skills that
    resolve nowhere; 39 dangling refs; 5 duplicate names with non-identical
    content).
  - **F2** zombie cron jobs: failures persist silently in "scheduled"
    state (evidence: PureMac + SpaceX jobs erroring on schedule, no
    mechanical enforcement of BRF-OPS-POL-002).
  - **F3** governance has duplicate IDs and no spec-to-reality
    enforcement (evidence: `BRF-OPS-POL-003` exists twice with different
    content; AGENTS.md mandates a frontmatter schema 60%+ of its own repo
    ignores).
  - **F4** single-node single-operator concentration with partial state
    durability (evidence: one Mac; one human consumer; SIGKILL destroyed
    one full run; `claude-auto` "Not logged in" failure previously silent).
  - **F5** (implicit, not given a separate section; surfaces in
    F4 sub-points): cron scheduler has no degraded mode, no auto-pause,
    no retry-with-backoff.
- For each, a concrete upgrade, an owner from BRF-ORG-POL-001
  (Aoife/Declan), rollback criteria, and measurable second-order effects.
- 4 of 5 failure simulations executed live during the audit; self-score
  8/10.

## Scope for follow-up action

**In scope (the audit covers):**
- The full agent ecosystem: protocols tree, skills repo (5 resolution
  roots), cron store, Aoife profile, the Fable 5 queue runner, all four
  active OpenClaw agents (Vladislava, Mikhail, Nadia, Viktor), and the
  two Hermes orgs (KovaForge and BriarForge).
- The BRF-ORG-POL-001 delegation matrix as the owner source.
- The Anti-Zombie Protocol (BRF-OPS-POL-002) as the policy source.
- A new cron health sentinel (F2 upgrade) and a new ecosystem resolution
  registry (F1 upgrade) — both natural follow-up builds.

**Out of scope:**
- Per-skill improvements (those are F1's REVIEW-2026-06-11.md).
- XerahS-specific operational issues (F4 has its own RELIABILITY-PLAN.md).
- Strategic planning / quarter roadmap (F5 has its own leverage map).
- Specific initiative definitions (F7 zero-zombie-OS will own that).

**Decide alone:** the F1 registry implementation (extending
`validate-skills` linter); the F2 sentinel's delivery channel
(natural choice: #bf-cron-jobs, but should be confirmed); the F4
backup manifest item list.

**Don't decide alone:** the F2 auto-pause threshold (proposed N≥5
consecutive failures, but this is a UX call); the F4 weekly→daily
sync change (one-line cron change but operational implications);
whether the cron sentinel should be a new meta-job or an extension of
the existing `cron-load-balancer`; cross-org ownership for
interventions that touch both KovaForge and BriarForge.

## What the deliverables made possible

- **F5 (leverage-point-mapping)** cross-linked each F1-F5 finding to one
  of L1-L4 absorption changes (commit `6e692de`); the antifragility
  audit's fragility sources *are* the leverage map's input set.
- **F7 (zero-zombie-OS)** is a direct response to F2 ("zombie cron
  jobs: failures persist silently") and F3 ("no spec-to-reality
  enforcement") — F2 in the antifragility assessment = the same
  problem F7 was scoped to solve.
- **F4 (xerahs-pipeline-reliability)** addresses F4 sub-points
  (state durability, recovery runbook) for one specific workflow
  family.

## Headline metric

Baseline system score: 4.0/10. Each F1-F5 upgrade is paired with a
measurable second-order effect (count, ratio, mean-time-to-detect).
Running the same audit again after upgrades would yield the delta;
no re-run scheduled.

## Current status

**Complete and committed.** All 5 fragility sources have an owner, a
rollback criterion, and a measurable second-order effect. No upgrade
has been *built*; the audit produced a plan, not actions. Two of the
5 upgrades were effectively repeated as separate Fable 5 prompts
(F4 → F4, F2 → F7) — see "deliverables made possible" above.
