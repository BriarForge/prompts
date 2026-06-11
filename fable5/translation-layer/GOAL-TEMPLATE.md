# Objective → Fable-Ready /goal Translation Layer

Turns a high-level strategic objective into a goal block Fable 5 / Mythos can
execute one-shot, with no clarification on scope or what done means.

Companion files: [RUBRIC.md](RUBRIC.md) (quality gate), [examples/](examples/)
(three validated translations from real work).

---

## The /goal block template

Copy, fill, delete what doesn't apply. Every section maps to a rubric criterion
(noted in parentheses — delete those too).

````text
Fable 5 one-shot mode (high effort, long-run scaffolding + git workflow enabled):

Objective: <ONE sentence in outcome form: "X exists / works / is decided, such
that Y". No bare activity verbs.>                                    (rubric 1)

Grounding (verified <YYYY-MM-DD>):                                   (rubric 2)
- /absolute/path/one — <what it is, one line>
- /absolute/path/two — <what it is>
<every path checked with ls/git at translation time; no placeholders>

Scope:                                                               (rubric 5)
- In: <the surface the agent may change>
- Out: <do NOT touch ...; do NOT decide ...>
- Decide alone: <choices the agent owns>
- Surface, don't act: <choices to record in the deliverable for the human>

Workflow contract:                                                   (rubric 6)
- Commit progressively with `git-aoife commit -m "msg"` after every major
  section (runs can be killed; committed work survives).
- Final step: `git-aoife push`. Use wrappers only, never bare git push.
- Outputs go to: <absolute path(s)>
- Conventions: <formatting rules the consumer requires>

Done looks like:                                                     (rubric 3)
1. <artifact/condition, binary-checkable, with its location>
2. <...>
<each item answerable true/false by a third party>

Verification:                                                        (rubric 4)
- <done item 1> → <command / gate / simulation that proves it>
- <done item 2> → <...>
- End with a rubric self-score (cite RUBRIC.md criteria) and one line of
  evidence per criterion.

If blocked:                                                          (rubric 7)
- <named failure mode> → <fallback, default: record the gap in the deliverable
  and continue; never stall waiting for input>
````

Notes on the template:

- **One objective sentence.** If you need two, you have two goals — split them.
- **Grounding is verified, not transcribed.** Run `ls`/`git log` on every path
  while writing the block, and date the verification. Paths rot.
- **"Surface, don't act" is the cheapest insurance.** Most one-shot overreach
  comes from the agent resolving a fork the human wanted to own. Name those forks.
- **If the block is machine-extracted** (like this queue's
  `sed -n '/```text/,/```/p'`), the text must contain no inner triple-backtick
  fences, and exactly one opening and one closing fence. Lint before queueing.

---

## Translation checklist

Work through all six phases. Phase 6 is a hard gate — loop until it passes.

### Phase 1 — Extract the outcome
- [ ] State the underlying intent in one sentence: what is true about the world
      when this succeeds?
- [ ] Rewrite any activity verb (review, investigate, explore, improve) as the
      artifact it should produce.
- [ ] Name the consumer of the result and where they will look for it.

### Phase 2 — Ground every reference
- [ ] List every file/repo/system/dataset the goal touches.
- [ ] Verify each exists, right now, by command — not memory. Convert relative
      paths to absolute.
- [ ] Replace every placeholder ("the usual repo", "(listed in original)") with
      the real value or delete the reference.
- [ ] Date the grounding section.

### Phase 3 — Define done, testably
- [ ] Enumerate the artifacts/conditions. Numbers, paths, counts — not adjectives.
- [ ] For each item ask: could a third party check this true/false without
      contacting the author? If no, rewrite.
- [ ] Check coverage: if all done items are true, is the objective actually
      achieved? If not, add the missing item.

### Phase 4 — Bound scope and authority
- [ ] Write the Out list: adjacent things the agent must not touch.
- [ ] Split decisions: decide-alone vs. surface-only.
- [ ] Add stop conditions for open-ended work ("at most N", "stop when X").

### Phase 5 — Set the workflow contract
- [ ] Commit cadence and wrapper (here: `git-aoife`, progressive commits, final
      push).
- [ ] Output locations (absolute) and formatting conventions the consumer
      requires (e.g. financial channel: no markdown tables, no em dashes).
- [ ] Session-survival: anything that must survive a kill goes in a progressive
      commit or a persistent memory file.

### Phase 6 — Self-verification gate (loop until pass)
- [ ] Score the block against RUBRIC.md: ≥ 12/14, no zeros.
- [ ] Simulated-question test: list every question Fable could ask mid-run;
      each must be answered by a line in the block. Any unanswered question →
      revise → rescore.
- [ ] Mechanical lint (for machine-extracted queues):
      - exactly one ```text opening fence and one closing fence,
      - no inner triple-backtick fences,
      - exactly one "Done looks like" and one "Verification" section,
      - extraction dry-run: `sed -n '/```text/,/```/p' FILE | sed '1d;$d'`
        returns the full prompt.

---

## Anti-patterns (all observed in this queue)

| Anti-pattern | Why it fails | Fix |
|---|---|---|
| Activity objective ("review the repo") | Agent decides what the deliverable is | Name the artifact and its path |
| Placeholder grounding ("(listed in original)") | Agent guesses or stalls | Verify and inline the real values |
| Adjective done ("significantly more antifragile") | Unfalsifiable; run never converges | Counts, paths, passing gates |
| Verification = restated done list | Proves nothing was checked | Command/gate/simulation per item |
| Two "Done looks like" sections | Conflicting definitions; agent picks one silently | Exactly one; lint for duplicates |
| Broken fence in machine-extracted prompt | Runner silently truncates the goal | Extraction dry-run before queueing |
| No commit cadence on long runs | SIGKILL erases hours of work | Progressive `git-aoife commit` per section |
