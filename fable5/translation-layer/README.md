# Objective → Fable-Ready Goal Translation Layer

Converts high-level strategic objectives into /goal blocks that Fable 5 (and
future Mythos models) can execute one-shot, without clarification on scope or
what done means.

## How to use it

1. Write the raw objective down, however vague.
2. Work through the 6-phase checklist in **[GOAL-TEMPLATE.md](GOAL-TEMPLATE.md)**,
   filling the template as you go.
3. Gate with **[RUBRIC.md](RUBRIC.md)**: ≥12/14, no zeros, and every question
   Fable could ask is answerable from the block.
4. If the goal is queued for `run-next-fable5.sh`, run the extraction dry-run
   lint before committing.
5. After the run, fold any new lesson into **[CLAUDE.md](CLAUDE.md)**.

## Examples (real work, validated)

- [01 — skills repo review](examples/01-skills-repo-review.md): retranslation of
  a goal that ran but lost a session to SIGKILL; 9/14 → 14/14.
- [02 — xerahs pipeline reliability](examples/02-xerahs-pipeline-reliability.md):
  repair of a structurally broken queue prompt (fence truncation); 6/14 → 14/14.
  The live queue file was fixed in place.
- [03 — monthly financial report](examples/03-monthly-financial-report.md):
  compiling standing AGENTS.md documentation into a runnable recurring goal;
  ~7/14 implicit → 14/14.
