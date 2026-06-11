# Example 2 — XerahS Pipeline Reliability & Autonomy

**Source:** `fable5/xerahs-pipeline-reliability-autonomy.md` (queued, pending).
This one is the cautionary tale: the file was **structurally broken** before this
translation.

## Defects found in the original (2026-06-11)

1. **Early-closing fence.** Line 26 began with ``` glued to prose, so the
   runner's extraction (`sed -n '/```text/,/```/p' | sed '1d;$d'`) would cut the
   prompt at line 25 — silently dropping the real "Done looks like" and the
   entire Verification section. Fable would have run on a truncated goal.
2. **Two conflicting "Done looks like" sections** — a condensed paste-over left
   both the stub ("Prioritized upgrades with ownership and verification") and
   the full original.
3. **Placeholder grounding:** "Core skills: (listed in original)". Rubric 2: 0/2.
4. Adjective done: "significantly more antifragile" — unfalsifiable.

Original rubric score: **6/14 with a zero → not Fable-ready**, and the fence bug
made even that optimistic.

## Fable-ready translation

```text
Fable 5 one-shot mode (high effort, long-run scaffolding + git workflow enabled):

Objective: A prioritized reliability-and-autonomy upgrade plan for the XerahS
ecosystem exists at /Users/mike/Projects/KovaForge/xerahs/docs/RELIABILITY-PLAN.md,
covering the pre-release, publishing, issue-monitoring, and hourly-sweep
workflows, with each upgrade carrying implementation steps, success criteria,
and a rollback plan.

Grounding (verified 2026-06-11):
- /Users/mike/Projects/KovaForge/xerahs/ — main XerahS repo (git)
- The five pipeline skills, all in /Users/mike/Projects/KovaForge/skills/:
  xerahs-prerelease-pipeline, xerahs-url-publishing, xerahs-issue-monitor,
  xerahs-hourly-sweep, xerahs-kfip-pipeline

Scope:
- In: read the xerahs repo and the five skills; write the plan document;
  small illustrative patches are allowed ONLY inside the plan as diffs, not applied.
- Out: do NOT apply changes to xerahs source or the skills in this run;
  do NOT touch release/publishing credentials or trigger any pipeline.
- Decide alone: prioritization, failure-mode taxonomy, plan structure.
- Surface, don't act: anything that changes published-URL behavior or release
  cadence (list as "needs human sign-off" in the plan).

Workflow contract:
- Commit progressively with `git-aoife commit -m "msg"` after each major plan
  section. Final step: `git-aoife push`. Wrappers only.
- Output: /Users/mike/Projects/KovaForge/xerahs/docs/RELIABILITY-PLAN.md

Done looks like:
1. RELIABILITY-PLAN.md exists with a prioritized upgrade list; every upgrade has
   implementation steps, a binary success criterion, an owner (human or cron),
   a timeout/checkpoint rule, and a rollback plan.
2. A failure-mode table maps each of the 4 workflows to its top observed or
   plausible failure modes and the upgrade that addresses each.
3. Two simulated failure scenarios are written up (network blip mid-upload;
   upstream API contract change), each showing the system self-recovering or
   failing safely with clear diagnostics under the proposed upgrades.
4. The plan is committed and pushed via git-aoife.

Verification:
- Item 1 → field-presence check: no upgrade entry missing any of the 5 fields.
- Item 2 → coverage check: 4/4 workflows appear in the table.
- Item 3 → walk each scenario step-by-step against the upgraded design; the
  walk must end in "recovered" or "failed safely + diagnostic emitted".
- End with rubric self-score per RUBRIC.md with evidence.

If blocked:
- A skill's SKILL.md contradicts the xerahs repo's actual behavior → trust the
  repo, record the drift as a finding.
- A workflow has no observable failure history → use plausible modes, mark them
  "hypothesized" so the plan separates evidence from speculation.
```

## Validation

Rubric: 1: **2** (named artifact at a path). 2: **2** (repo + all five skills
verified by `ls` on 2026-06-11; placeholder eliminated). 3: **2** (four binary
items; "antifragile" adjective replaced by field/coverage/scenario checks).
4: **2** (presence, coverage, and scenario-walk checks are executable). 5: **2**
(plan-only run; credential/pipeline exclusions; sign-off list). 6: **2**.
7: **2** (doc-drift and no-history fallbacks). **Total: 14/14 — Fable-ready.**

Simulated-question test: "Which five skills?" (grounded), "Do I implement or
just plan?" (Scope: In/Out), "Where does the plan live?" (Objective), "What if
docs and code disagree?" (If blocked) — all answered in-block.

**Queue file repaired:** the broken original was replaced in place with this
translation (single well-formed fence, one Done section), and the extraction
dry-run now returns the full prompt. See commit history.
