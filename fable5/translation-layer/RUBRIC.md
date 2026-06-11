# Fable-Ready Goal Quality Rubric

Scores a goal block on whether Fable 5 (or a future Mythos model) can take it and
produce a finished, high-signal outcome **without asking what done means**.

Seven criteria, scored 0–2 each. Maximum 14.

**Fable-ready threshold: ≥ 12/14 with no criterion at 0.**
A single 0 means a predictable clarification round-trip or a silent wrong turn —
fix it before queueing, regardless of total score.

---

## 1. Outcome over activity

The objective names an end state or artifact set, not a list of verbs.
"Review X" and "investigate Y" are activities; "a prioritized plan for X exists at
PATH" is an outcome.

- **0** — Pure activity ("look into", "review", "explore") with no artifact implied.
- **1** — Outcome implied but the artifact, its location, or its form is left to guess.
- **2** — End state is explicit: what exists afterward, where it lives, who consumes it.

## 2. Grounded references

Every file, repo, system, or dataset the goal mentions is named by absolute path
(or exact URL/ID) and was **verified to exist at translation time**. No "somewhere
in the project", no placeholder like "(listed in original)".

- **0** — At least one reference is a placeholder, relative, or known-stale.
- **1** — Paths are absolute but were not verified; or one minor reference is vague.
- **2** — All references absolute, verified (state the verification date), with a
  one-line note of what each one is.

## 3. Testable done

"Done looks like" is an enumerated list of artifacts/conditions a third party could
check true/false without talking to the author. "Significantly better" is not
testable; "all 4 broken YAML frontmatter blocks parse" is.

- **0** — Done is absent, or stated only as a quality adjective.
- **1** — Done is enumerated but ≥1 item is unverifiable as written.
- **2** — Every done item is binary-checkable, and together they cover the objective.

## 4. Executable verification

The goal says **how** to prove each done item — commands to run, gates to pass,
scenarios to simulate — not merely what done is. A verification section that
restates the done list is a 1, not a 2.

- **0** — No verification method.
- **1** — Verification stated but vague, or it just paraphrases the done list.
- **2** — Concrete method per done item (command, test, gate, fire-drill) plus a
  required end-of-run rubric self-score.

## 5. Scope and authority boundaries

Explicit exclusions ("do NOT touch X"), stop conditions, and decision authority:
what the agent may decide alone vs. what it must surface in the deliverable instead
of acting on.

- **0** — No boundaries; agent must guess where the work ends.
- **1** — Some exclusions, but ambiguous edges remain that the agent will hit.
- **2** — Exclusions, stop conditions, and a decide-alone / surface-only split are
  all stated.

## 6. Workflow contract

Operational rules of the run: commit cadence and wrapper (e.g. `git-aoife` only),
output locations, formatting conventions (e.g. "no markdown tables in report
output"), session-survival measures (progressive commits for runs that may be
killed).

- **0** — No workflow guidance; outputs could land anywhere in any form.
- **1** — Partial: commits xor conventions xor locations covered.
- **2** — Commit cadence + tooling, output paths, and formatting conventions all
  explicit.

## 7. Failure and edge handling

What to do when blocked: missing reference, failing verification, tool error,
ambiguous fork. The right default is almost always "record the gap in the
deliverable and continue" — but the goal must say so, or the agent may stall or
ask.

- **0** — Nothing; any surprise becomes a clarification request or a stall.
- **1** — Generic "use judgment" without naming the likely failure points.
- **2** — Named fallback behavior for the predictable failure modes of this
  specific goal.

---

## Scoring procedure

1. Score each criterion with one line of evidence (quote the goal text that earns
   the score).
2. Sum. If < 12 or any criterion is 0, revise the goal and rescore. Loop until it
   passes.
3. Run the **simulated-question test** (the strongest single check): list every
   question Fable could plausibly ask during the run — about scope, location, form,
   conflict resolution, or stopping. The goal is ready only when each question is
   answerable by pointing at a line in the block.

## Known real-world failure modes this rubric exists to catch

Observed in this queue (BriarForge/prompts, June 2026):

- **Truncated machine extraction** — `xerahs-pipeline-reliability-autonomy.md` had
  an early-closing code fence; the runner's `sed -n '/```text/,/```/p'` extraction
  would silently drop the real Done/Verification sections. Lint the fenced block.
- **Placeholder references** — same file said "Core skills: (listed in original)".
  Criterion 2 score: 0.
- **Duplicate, conflicting "Done looks like" sections** — a condensed paste-over
  left two done definitions in one file. Exactly one wins; the agent shouldn't pick.
- **Session-timeout SIGKILL** — `skills-repo-overarching-review.md` lost a run to a
  timeout before progressive commits were mandated. Criterion 6 covers this.
