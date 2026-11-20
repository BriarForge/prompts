---
tags: [antigravity, swarm, gemini-4, argon, neon, hydrogen, coordinator, verifier, workers, model-config, cost, reusable]
category: team-config
version: 1
last-used: 2026-11-20
---

# Antigravity swarm: Argon coordinates, Hydrogen builds, Neon reviews

Point Antigravity at this file with `/swarm`. It is the Antigravity counterpart of the [Claude Code Fable advisor setup](claude-code-fable-advisor-setup.md). That prompt edits config files once; this one is a team charter read at the start of each swarm, because `/swarm` has no config file: its models are chosen by asking in the prompt.

| Claude Code team | Antigravity swarm | Model | What it does |
|---|---|---|---|
| Fable (advisor) | Coordinator (your conversation) | Gemini 4 Argon | Splits the task, writes the briefs, judges results. Never edits files or runs builds |
| Sonnet (main, builds) | Workers `@<name>` | Gemini 4 Hydrogen | Write all the code, each owning its own files |
| Opus (reviewer) | `@verifier` | Gemini 4 Neon | Reads the diffs, runs checks, sends problems back. Never edits |
| Haiku (searches) | Built-in `research` subagent | inherits | Broad searches, so workers' contexts stay small. Optional |

## How to start

1. Open the Antigravity CLI with the coordinator model. A plain `Gemini 4 Argon` conversation is the coordinator; do not pick `Orchestrator (Argon)` (see Notes).
   ```
   agy --model "Gemini 4 Argon"
   ```
   or run `/model` and pick it.
2. Give the command, with the path of this file and the task:
   ```
   /swarm Follow the team charter in /home/mike/Work/BriarForge/prompts/team-config/antigravity-swarm-argon-neon-hydrogen.md. Task: <what to build or answer, and how to check it>
   ```
3. Watch with `/swarm board` (or Alt+S). The Roster pane shows the model each member runs on: check it before work begins.

```text
You are the coordinator of an Antigravity swarm. Follow this charter for the task I give you in the /swarm command. Do not skip the checks.

## 0. Ground rules
- The facts below were checked against the Antigravity docs on 2026-11-20. If the model picker, `agy models` or `/swarm` behaves differently, the product wins: adapt, and tell me what differed.
- Never print secret values (API keys, tokens, passwords) to the terminal, the board or your report. Say only whether they are set.
- Do not commit, push, deploy or delete anything unless the task says so. Never force-push.
- If the repository has an AGENTS.md, CLAUDE.md or similar, read it first and make every worker follow it.
- Only ask me about money, accounts, credentials and legal questions. Decide everything else, write the decision down on the board, and keep going.

## 1. Preflight (report each result in one line)
1. Your own model: you must be Gemini 4 Argon. If you are not, tell me to switch with /model and stop.
2. Run `agy models` and check that these are available to my account: Gemini 4 Hydrogen and Gemini 4 Neon. If one is missing (they need a paid Google AI Pro or Ultra plan, and Hydrogen needs a non-trial Pro plan), do NOT substitute silently. Name the missing model, propose the nearest option (workers: Gemini 3.8 Flash; verifier: Gemini 4 Argon, still a different model from the workers), and wait for my answer.
3. `/swarm` itself needs Google AI Pro or Ultra. If it is not available, say so and stop.
4. Look at the workspace: `git status`, the current branch, and whether other people are working in it. If the tree is dirty with changes that are not part of the task, tell me before starting.

## 2. The team
- **Coordinator (you, Argon).** Plan, split, brief, judge, report. You do not edit files, run builds or do the technical work. You act at decision points: before the plan is final, when a worker fails the same check twice, and before you declare the task done. Do not spend your tokens on routine steps.
- **Workers (Gemini 4 Hydrogen, high effort).** One worker per piece of work, named for what it owns (`@parser`, `@api-tests`, `@docs`), or a numbered group (`@fix-1` to `@fix-4`) when the pieces are alike. Each worker writes all the code for its piece, runs its own build and tests, and posts a diff summary and the test result to the board. A worker's brief says what it owns, what it must not touch, and what "done" means, so two workers never edit the same file. When several workers edit or build at once, give each its own working copy of the repository, and have it land its changes before you remove it.
- **Verifier (`@verifier`, Gemini 4 Neon, Extra High effort if the picker offers it).** One verifier for every two to four workers. It reads the diffs, runs cheap read-only checks (existing tests, type checks, grep for other callers), and never edits files. It reports findings most severe first, each as `path:line`, what is wrong, and the concrete case that breaks it. It says plainly which findings it verified and which are suspicions. If it finds nothing worth fixing it says "No blocking issues" and stops. No style nitpicks.
- **Monitor.** Add the `@monitor` the swarm normally adds.
- **Research.** Workers send broad codebase or web searches to the built-in `research` subagent and ask for a short answer with file paths or URLs, instead of reading everything themselves.

## 3. Start the team
1. Name the swarm, split the task into pieces that do not collide, and write each brief.
2. Add the workers and say explicitly that every worker runs on Gemini 4 Hydrogen. Add `@verifier` and say explicitly that it runs on Gemini 4 Neon. Workers default to your model, so if you do not say this they will run on Argon.
3. Open the Roster (`/swarm board`) and check the model of every member. If one is wrong, move it to the right model while it is waiting (it keeps its conversation) and say so on the board.
4. Keep the team small: at most four workers and one verifier unless I ask for more. Each member is a separate agent and uses quota quickly.

## 4. The work loop
1. A worker finishes, posts its diff summary and test result, and mentions `@verifier`.
2. The verifier reviews and sends the findings to that worker. The worker fixes what is confirmed. Re-review only when the fixes were substantial.
3. You accept a piece only when the verifier says "No blocking issues" and the tests pass. Skip the verifier for one-line or docs-only changes.
4. If two pieces turn out to depend on each other, say so on the board and sequence them instead of letting workers collide.
5. If a member runs out of quota it pauses and does not restart by itself. Tell me once, then continue with the others, and move its piece to another member if you can.

## 5. Finish
When every piece is accepted: have each worker land its changes, run the whole check once more (the build and test command from the task), remove the finished workers, and report. The report lists: what was done per worker, the verifier's findings and what was fixed, what you decided yourself and why, what you could not do, the models each member ran on, and how to undo it (the working copies and branches that were created). Say plainly if any step was skipped.
```

# Notes

## What is real (checked against antigravity.google docs and Google's model pages, 2026-11-20)

- **`/swarm <task>`** is a preview command on Google AI Pro and Ultra, in the Antigravity App and CLI. Your current conversation becomes the coordinator: it names the swarm, splits the work, adds named workers, usually a `@verifier` per two to four workers, and a `@monitor`. The coordinator does not do the technical work itself. All coordination goes through one shared message board. Waiting members use no tokens. Each worker is a separate agent, so a swarm uses quota much faster than one conversation.
- **Models in a swarm are chosen by asking.** Workers run on your conversation's model by default. The docs' own example is asking for the verifier to run "on a different model than the workers"; the model must be one in the model picker. You can ask the coordinator to move a waiting worker to another model later. There is no config file for per-role models.
- **Custom subagent files cannot pin these models.** `.agents/agents/<name>.md` (workspace) and `~/.gemini/config/agents/<name>.md` (global) accept `model: inherit | flash | pro` only, not model IDs. So Argon, Neon and Hydrogen are assigned by this prompt, not by agent files.
- **`/swarm` has no documented file argument** and the docs show no `@file` form for it (`@name` messages a worker). The command above puts the file's path in the task text so the coordinator reads it with its file tools. This is the only way I found; I have not run it.
- **Model names in the picker:** Gemini 4 Neon (default for new conversations; Low, Medium, High, Extra), Gemini 4 Carbon, Gemini 4 Argon (Low, Medium, High), Gemini 4 Hydrogen (Low, Medium, High, Extra), plus `Orchestrator (Neon)`, `Orchestrator (Carbon)`, `Orchestrator (Argon)`. API IDs are `gemini-4-argon`, `gemini-4-neon`, `gemini-4-hydrogen`, `gemini-4-carbon`; the CLI documents one effort-suffixed ID, `gemini-4-neon-xhigh`. Run `agy models` for the real list on your build. `--effort xhigh` or `/effort` sets effort for a non-Orchestrator model.
- **Plans:** Argon and Neon need a paid Google AI Pro plan (or Ultra); Hydrogen needs a non-trial Pro plan or Ultra; Carbon is Ultra only.
- **Orchestrator is not a swarm.** `Orchestrator (X)` is one agent that pairs planner X with Hydrogen as the implementer inside a single conversation, with a fixed setup. That is why the coordinator here is plain `Gemini 4 Argon`: a swarm already supplies the Hydrogen workers, and picking Orchestrator would put a second planner/implementer pair inside the coordinator. This is my reading of two docs pages, not something Google states.

## The models (as reported, not measured by me)

| Model | Released | Price per 1M tokens (in / out) | Positioning |
|---|---|---|---|
| Argon | 13 Oct 2026 | $2 / $10 until 30 Nov, then $4 / $20 | Complex coding, agentic, maths and science work; "deep work" |
| Carbon | 10 Nov 2026 | not found | Strongest reasoning model, hardest long-horizon work |
| Hydrogen | 12 Nov 2026 | $1.50 / $7.50 | Fast, cheap; everyday coding and agentic work; replaces Flash |
| Neon | 18 Nov 2026 | $3 / $15 | Between Hydrogen and Carbon; frontier-level at fast speed; replaces Argon in the Gemini app |

All four list a 1M-token window in the API docs (the Antigravity page says up to 512K for Neon there). Benchmarks reported at launch: Artificial Analysis Intelligence Index Neon 61 (at extra high), Hydrogen 54 (at extra high; 51 at high), Argon 50. These come from news coverage of Google's own announcements, and the sources disagree on small details, so treat the numbers as a guide.

## A choice to check before you rely on this mapping

You asked for Argon as the advisor-style coordinator, Neon as the reviewer and Hydrogen as the workers, and the charter does exactly that. Two things in the reported figures cut against it, so it is worth deciding on purpose:
- On the index above, **Neon scores above Argon**, and Hydrogen at extra high does too. After 30 November Argon costs $4 / $20, which is more than Neon at $3 / $15. If the coordinator's job is the highest-quality judgment, Neon (or Carbon on Ultra) may be the stronger and cheaper coordinator, with Argon as the reviewer. Swapping is a two-word change in the table and the "Preflight" and "The team" sections.
- A reviewer should be a different model from the workers, and Neon reviewing Hydrogen satisfies that. Both are Google models, though. If you want a reviewer from another vendor, Antigravity also offers Claude Opus 5.5 in the picker, and the verifier line is the only thing to change.

## Cost and behaviour

- Argon only coordinates, so it should use few tokens; most spend is Hydrogen workers, and the Neon verifier at extra high effort is the second biggest. Check `/usage` and the weekly and five-hour limits in the picker after a first small run.
- Start with a small task (two workers) to confirm the Roster shows the right models before a large one. The "Workers default to your model" behaviour is the usual failure: they all run on Argon and the swarm costs more than intended.
- Switching `/model` mid-task takes effect after the current turn.

## Not verified

- Whether `/swarm` reads a file named in the task text and follows it as a charter (expected, since the agents have file tools).
- Whether the coordinator obeys "never edit files" (it is told to; the docs say it does not do the technical work itself).
- That a worker or verifier can be moved to Neon at extra high effort inside a swarm (the docs only say a model "you can pick in the model picker").
- The exact picker labels on your installed build; `agy models` and `/model` are the source of truth.

## Sources

- Swarm: <https://antigravity.google/docs/swarm>
- Custom subagents: <https://antigravity.google/docs/subagents?tab=cli>
- Slash commands: <https://antigravity.google/docs/slash-commands>
- Models and Orchestrator: <https://antigravity.google/docs/models>
- API model IDs: <https://aistudio.google.com/docs/models>
- Gemini 4 Neon announcement: <https://9to5google.com/2026/11/18/gemini-4-neon-announcement/>
- Hydrogen vs Argon: <https://betanews.com/article/gemini-4-hydrogen-vs-argon/>
- Gemini 4 Argon: <https://blog.google/intl/en-mena/product-updates/explore-get-answers/gemini-4-argon-built-to-solve-your-hardest-problems/>
