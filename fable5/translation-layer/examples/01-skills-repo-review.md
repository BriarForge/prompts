# Example 1 — KovaForge Skills Repository Review

**Source:** `fable5/skills-repo-overarching-review.md` (ran 2026-06-11, sessions
`e2486379…` and `74abbb81…`). Real outcome data: first attempt SIGKILLed by
session timeout; rerun produced `/Users/mike/Projects/KovaForge/skills/REVIEW-2026-06-11.md`
(58 skills audited, 4 broken YAML, 39 dangling related_skills refs, tag schema
split 34/20/4).

## What the original got right and wrong

The original ran successfully, but the run itself exposed the gaps:

- **No output location.** "Done looks like: a clear summary…" never said *where*.
  The agent chose `REVIEW-2026-06-11.md` in the skills repo root — a reasonable
  guess the human never ratified. Rubric 3: 1/2.
- **No commit cadence.** The first attempt was SIGKILLed and all work was lost,
  forcing a requeue (see `progress.json` history). Rubric 6: 0/2.
- **No decision authority.** "Improvement plan" vs. "apply improvements" was
  ambiguous; the agent could have started rewriting 58 skills. Rubric 5: 1/2.
- Original rubric score: **9/14 with one zero → not Fable-ready** (it cost a
  full lost session to learn that).

## Fable-ready translation

```text
Fable 5 one-shot mode (high effort, long-run scaffolding + git workflow enabled):

Objective: A prioritized, evidence-backed improvement plan for the KovaForge
skills repository exists at /Users/mike/Projects/KovaForge/skills/REVIEW-2026-06-11.md,
actionable enough that executing its top 5-7 items measurably lifts skill
quality and reduces manual maintenance.

Grounding (verified 2026-06-11):
- /Users/mike/Projects/KovaForge/skills/ — the repo under review (58 skill dirs, git)
- /Users/mike/Projects/KovaForge/skills/AGENTS.md — governance spec the audit scores against

Scope:
- In: read every SKILL.md; write the single review file; update this queue's memory file.
- Out: do NOT modify any skill in this run; do NOT touch other KovaForge repos.
- Decide alone: rubric criteria definitions, scoring, prioritization order.
- Surface, don't act: any skill deletions/merges (list them; the human deletes).

Workflow contract:
- Commit progressively with `git-aoife commit -m "msg"` after each completed
  review section — the previous attempt was SIGKILLed and lost everything.
- Final step: `git-aoife push`. Wrappers only.
- Output: /Users/mike/Projects/KovaForge/skills/REVIEW-2026-06-11.md

Done looks like:
1. REVIEW-2026-06-11.md exists with: per-criterion rubric scores (1-10) and
   evidence, a current-state summary covering all 58 skills, a prioritized
   improvement list tagged by effort/impact, governance-rule recommendations,
   and a top-fix shortlist of named skills.
2. Every numeric claim in the review (counts of broken YAML, dangling refs,
   schema split) is reproducible from a stated parser/grep over HEAD.
3. The review is committed and pushed via git-aoife.

Verification:
- Item 1 → section-by-section presence check against this list.
- Item 2 → rerun the stated greps; numbers must match the review text.
- Item 3 → `git log --oneline -1` shows the review commit; push exit 0.
- End with rubric self-score per RUBRIC.md with one line of evidence each.

If blocked:
- A SKILL.md is unparseable → record it as a finding (that IS the audit), continue.
- Governance spec ambiguous on a criterion → adopt the stricter reading, note it.
```

## Validation

Rubric (RUBRIC.md): 1: **2** (artifact + path + consumer). 2: **2** (both paths
verified today; skills dir and AGENTS.md exist). 3: **2** (three binary items).
4: **2** (reproducible-numbers check is a real test, not a restatement).
5: **2** (read-only run; merge/delete decisions surfaced). 6: **2** (cadence,
wrapper, output path; motivated by the actual SIGKILL). 7: **2** (the two
realistic failure modes named with fallbacks). **Total: 14/14 — Fable-ready.**

Simulated-question test — every question the real run actually raised is now
answered in-block: "Where does the plan go?" (Objective/Workflow), "Do I fix
skills or just report?" (Scope: Out), "What if YAML won't parse?" (If blocked),
"How do I survive a timeout?" (commit cadence).
