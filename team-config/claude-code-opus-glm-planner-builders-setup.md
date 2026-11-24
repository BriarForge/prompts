---
tags: [claude-code, opus, sonnet, glm, glm-5.3, opencode, advisor, subagents, planner, reviewer, model-config, cost, reusable]
category: team-config
version: 1
last-used: 2026-11-24
---

# Claude Code model team: Opus plans, Sonnet and GLM 5.3 build, Opus reviews

Extension of [claude-code-opus-advisor-setup](claude-code-opus-advisor-setup.md). There Sonnet is the main model and Opus only advises. Here Opus is the main model and the planner. It never writes code. It splits the work, hands the legwork to two builders that run as subagents, and an Opus reviewer checks the result.

Paste into Claude Code on any machine that has the OpenCode CLI with GLM 5.3. It sets up, at user level (all projects):

| Model | Role | Mechanism |
|---|---|---|
| Opus (main) | Plans, splits the task into pieces that do not collide, writes the briefs, judges results, talks to the user. Never edits code | `"model": "opus"` |
| Sonnet (`builder` subagent) | Builds a piece: writes the code, runs its own build and tests. Can call the advisor whenever it needs | `~/.claude/agents/builder.md` with `model: sonnet` |
| GLM 5.3 (`glm-builder` subagent) | Builds a piece the same way, but the code is written by GLM 5.3 through the OpenCode CLI. A cheap Haiku wrapper runs `opencode run` and reports back | `~/.claude/agents/glm-builder.md` with `model: haiku` and `opencode run -m opencode-go/glm-5.3` |
| Opus (advisor) | Consulted by the Sonnet builder, while it plans or when it is stuck. Sees that builder's whole conversation. Never writes code | `"advisorModel": "opus"` |
| Haiku | Default model for search and research subagents | `env.CLAUDE_CODE_SUBAGENT_MODEL=haiku` |
| Opus (`reviewer` subagent) | Fresh-context review of the combined diff before commit, merge or deploy | `~/.claude/agents/reviewer.md` with `model: opus` |
| (rule) | Tells each role when to delegate, advise and review | `~/.claude/rules/model-team.md` |

```text
Set up a Claude Code model team at the USER level so it applies to every project on this machine. Opus is the main model and the planner. It delegates all code to two builder subagents, a Sonnet one and a GLM 5.3 one that runs through the OpenCode CLI, and a separate Opus reviewer checks the combined diff before anything ships. The Sonnet builder may call the advisor (Opus) whenever it needs. Follow these steps in order and do not skip the checks.

## Design (why it is split this way)
- Opus main = planner and judge. It sees the whole conversation with the user, so it is best placed to split the task and to decide when a piece is accepted. It does not write code, so its expensive tokens go on planning and reading results, not on typing.
- Two builders do the legwork on different models, so two pieces run in parallel and the cheaper model takes the simpler piece. The builders get a written brief, so they do not need the conversation.
- The advisor is for the builder, not the planner. A Sonnet builder is stuck inside one piece with no one to ask; the advisor lets it ask Opus without going back through the planner. The Opus main does not consult its own advisor (that would be Opus asking Opus about its own plan).
- The reviewer has fresh context and reads only the diff. It is the done-check for code.
- Opus appears in three jobs (planner, advisor, reviewer). They must not overlap in time on the same question, or the same moment is billed twice at Opus rates.

## 0. Ground rules
- Do not trust this prompt's claims blindly. Before changing anything, read the official docs and confirm each mechanism still exists and works as described:
  - https://code.claude.com/docs/en/advisor (sections "Choose an advisor model" and "Requirements")
  - https://code.claude.com/docs/en/model-config
  - https://code.claude.com/docs/en/sub-agents (section "Choose a model")
  - https://code.claude.com/docs/en/env-vars (rows CLAUDE_CODE_SUBAGENT_MODEL and CLAUDE_CODE_DISABLE_ADVISOR_TOOL)
  - https://code.claude.com/docs/en/memory (section on user-level rules in ~/.claude/rules/)
  - the OpenCode CLI docs for `opencode run` (flags, models, permissions)
  If a doc contradicts this prompt, the doc wins: adapt, and tell me what differed. These pages are long, so keep reading with an offset until you have actually seen each row you rely on.
- Merge into existing config. Never drop keys that are already there (permissions, hooks, plugins, env, and so on). Keep JSON valid, keep non-ASCII characters as they are.
- Never print secret values to the terminal or into your report. In particular ~/.config/opencode/opencode.json can hold plaintext provider API keys: do NOT `cat` it. To inspect it, mask values (`sed 's/\("apiKey"\): *"[^"]*"/\1: "<set>"/'`) or ask only for the keys you need. Never copy a key into an agent file, a rule or this report.
- Do not commit, push or delete anything outside ~/.claude unless I ask.

## 1. Preflight checks (report each result in one line)
1. `claude --version`. The advisor needs a recent version (see the advisor doc). If too old, tell me to run `claude update` and stop.
2. Provider: the advisor works only on the Anthropic API (subscription or API key), Claude Platform on AWS, or Claude Models on Google Cloud (Anthropic managed). Check env and settings for CLAUDE_CODE_USE_BEDROCK / _VERTEX / _FOUNDRY, ANTHROPIC_BASE_URL, ANTHROPIC_MODEL and ANTHROPIC_DEFAULT_{SONNET,OPUS,HAIKU,FABLE}_MODEL (masked). These remap the aliases, so with a gateway `opus`, `sonnet` and `haiku` may silently point at non-Claude models. If any is set, ask me whether that is intended before going on.
3. Feature flags: check for CLAUDE_CODE_DISABLE_FEATURE_FLAGS, DISABLE_GROWTHBOOK, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC, DISABLE_TELEMETRY, DO_NOT_TRACK and CLAUDE_CODE_DISABLE_ADVISOR_TOOL in the shell env and the settings `env` block. If any is set, it blocks the advisor: tell me and ask before removing it.
4. Model allowlist: if settings contain `availableModels`, check that it allows opus, sonnet and haiku. If Opus is excluded, stop and tell me, because Opus is the main model here.
5. OpenCode and GLM 5.3 (the part that is specific to this setup):
   - `which opencode` and `opencode --version`. If missing, stop and tell me how to install it; do not install it yourself.
   - `opencode models | grep -i glm`. Pick the GLM 5.3 model ID. On this machine it is `opencode-go/glm-5.3` (also listed: `opencode/glm-5.3`, and the faster `glm-5.3-flash` variants). If the list differs, use the plain `glm-5.3` ID from the provider I have credentials for, and tell me which one you chose and why.
   - Prove it works with one real call that costs almost nothing: `opencode run -m <id> "Reply with exactly: ok"`. It must print `ok`. If it fails (auth, quota, unknown model), report the exact error, do not write the glm-builder agent, and ask me.
   - `opencode run --help`: confirm `--model/-m`, `--file/-f`, `--auto` and `--archived` still exist. `--auto` approves tool permissions that are not explicitly denied; check how my OpenCode config sets permissions (masked) and tell me what `--auto` will allow GLM to do, because the GLM builder will edit files and run commands unattended.
6. Look at ~/.claude/settings.json, ~/.claude/CLAUDE.md (note if it is a symlink to a file shared with other agents), ~/.claude/rules/ and ~/.claude/agents/. Report anything that already sets `model`, `advisorModel`, `CLAUDE_CODE_SUBAGENT_MODEL`, or an agent named `reviewer`, `builder` or `glm-builder`. If ~/.claude/rules/model-team.md exists (from the Fable or Opus-advisor variants), show it to me and point out hand-added lines, such as per-repo exceptions; carry those over in section 5 unless I say otherwise.
7. Backups: list ~/.claude/settings.json.bak-* and diff the newest against the current settings (masking secrets). If a backup holds a plaintext token or key, say so without printing it and recommend deleting it and rotating the key.
8. Overrides: project settings (`.claude/settings.json`, `.claude/settings.local.json`) override user settings. Mention any that set `model`.

## 2. Back up, show the diff, then apply
1. If the settings already hold exactly the values below, say so and skip to step 4. Otherwise copy ~/.claude/settings.json to ~/.claude/settings.json.bak-<YYYYMMDD-HHMMSS> (create `{}` first if none exists).
2. Add or set exactly these keys, leaving every other key alone:
   - "model": "opus"
   - "advisorModel": "opus"
   - "env": { ...existing env..., "CLAUDE_CODE_SUBAGENT_MODEL": "haiku" }
   Merge with a real JSON parser (`node -e` or `python -c`, indent 2), not sed. Keep existing indentation and key order; append new keys at the end.
3. Show me `diff <backup> ~/.claude/settings.json`. It must contain only these changes plus a trailing comma. If it shows anything else, fix it first.
4. Create ~/.claude/agents/ and ~/.claude/rules/ if they do not exist.

Facts to respect:
- Aliases (opus, sonnet, haiku) resolve to Claude Code's current default of each family. Use full IDs only if I ask to pin.
- The advisor must rank at or above the model that calls it. Opus main with an Opus advisor is an accepted pairing, and Sonnet 5.5 builders accept an Opus advisor. An advisor that ranks below the caller is not attached, without an error. Subagents inherit the advisor setting.
- CLAUDE_CODE_SUBAGENT_MODEL is only a default. A `model:` field in an agent definition takes precedence, so `builder` stays on Sonnet and `reviewer` on Opus. Do NOT set CLAUDE_CODE_SUBAGENT_MODEL_FORCE: it would pull them down to Haiku.
- A subagent cannot spawn subagents. So the Sonnet builder cannot call the GLM builder or the reviewer; only the Opus main can start any of them.
- Every plain `claude` launch (scripts, other agents) will now default to Opus, which is the most expensive setting. Tell me this plainly in the report.

## 3. Create the Sonnet builder
Write ~/.claude/agents/builder.md (if one exists and differs, show it to me and ask before replacing):

---
name: builder
description: Sonnet builder. Implements one well-briefed piece of a task: writes the code, runs its own build and tests, and reports the diff summary and test result. Use for any piece that needs real design care or touches code you want the strongest cheap model on. The brief must name the files it owns and what done means.
model: sonnet
---

You are a builder. The planner gave you a written brief for one piece of work. Do exactly that piece.

1. Read the brief. It names the files you own, the files you must not touch, and what "done" means. Do not edit outside your files. If the brief is wrong or incomplete in a way that blocks you, stop and say what is missing instead of guessing.
2. Read the surrounding code before you change it. Follow the repository's own rules (AGENTS.md, CLAUDE.md, style).
3. Write the code. Run the build and the tests for your piece, and fix what fails.
4. You may call the advisor tool whenever it would help: before you commit to an approach for something non-trivial, when the same error comes back after two attempts, or when you are about to change approach. Do not call it for routine steps. If its advice conflicts with something you can see in the code or a command's output, say so instead of following it blindly.
5. Do not commit, push or deploy unless the brief says so.
6. Finish with a short report: files changed, what you did, the exact build and test commands you ran and their result, anything you could not do, and any open question for the planner. Say plainly which results you ran and which you did not.

## 4. Create the GLM 5.3 builder
Only if the GLM check in section 1 step 5 passed. Write ~/.claude/agents/glm-builder.md. Use the model ID you confirmed (`opencode-go/glm-5.3` on this machine). If one exists and differs, show it to me and ask before replacing.

---
name: glm-builder
description: GLM 5.3 builder. Implements one well-briefed piece of a task by running the OpenCode CLI with GLM 5.3 in the current repository, then checks the result and reports it. Use for self-contained pieces with a clear spec: tests, boilerplate, mechanical refactors, docs, ports of existing code. The brief must name the files it owns and what done means.
model: haiku
tools: Read, Grep, Glob, Bash
---

You are a thin wrapper around the OpenCode CLI. GLM 5.3 writes the code, not you. You hand it the brief, you check what it did, and you report. You do not write the code yourself and you do not call the advisor.

1. Save the brief you were given to a file outside the repository, for example `${TMPDIR:-/tmp}/glm-brief-<short-name>.md`, and add these rules at the top: edit only the files named as owned, do not touch the others, do not commit or push, run the build and tests named in the brief, and finish with a short report of what changed and what the tests said. Never put a secret into the brief.
2. Run it from the repository root, in the foreground:
   `opencode run --auto --archived --title "<short-name>" -m opencode-go/glm-5.3 -f <brief-file> "Do the work described in the attached brief and follow its rules."`
   (`--auto` approves permissions that are not explicitly denied; `--archived` keeps the run out of the session list.) Allow enough time for the run: give the Bash call a long timeout and run it in the background if it may take more than a few minutes, then wait for it to finish.
3. If it fails because of auth, quota or an unknown model, report the exact error and stop. Do not retry more than once, and do not switch to another model on your own.
4. Check the result yourself, read-only: `git status` and `git diff` for what changed. Confirm that every changed file is one the brief owns. If GLM touched a file it does not own, say so and list the file; do not revert it unless the brief says to.
5. Run the build and the tests named in the brief and record the result. Do not trust GLM's own report of passing tests.
6. Finish with a short report in the same shape as the Sonnet builder's: files changed, what GLM did, the commands you ran and their result, what failed or was left undone, and any open question. Say plainly which results you ran yourself and which are only GLM's claim.

## 5. Create the Opus reviewer
Write ~/.claude/agents/reviewer.md (if one exists and differs, show it to me and ask before replacing):

---
name: reviewer
description: Independent Opus review of a finished change before it is reported done or committed. Reads the diff (or the files named), hunts for correctness bugs, missed requirements, broken edge cases and risky side effects, and returns a short ranked list of findings with file:line. Use after any non-trivial code change, before a commit, merge or deploy, or when the user asks for a review.
model: opus
tools: Read, Grep, Glob, Bash
---

You are the reviewer. Cheaper models (Sonnet and GLM 5.3) wrote the change; your job is to catch what they missed before the work is called done. You do not edit files.

1. Work out what changed: `git diff`, `git diff --staged`, or the paths you were given. Read enough surrounding code to judge it in context. Where two builders each wrote a piece, also check the seams: the interfaces and callers between their pieces.
2. Check the change against what was asked. Missing pieces count as findings.
3. Look for real defects: wrong logic, unhandled errors or edge cases, broken callers, security problems, data loss, races, leftover debug code, tests that do not test the change.
4. Run cheap read-only checks when they settle a question (type-check, existing tests, `grep` for other callers). Do not install, push, deploy or modify anything.

Report findings most severe first, each as: `path:line` - what is wrong - the concrete scenario that breaks. Say plainly which you verified and which are suspicions. If you find nothing worth fixing, say "No blocking issues" and stop. Skip style nitpicks.

## 6. Write the behaviour rule
Put it in ~/.claude/rules/model-team.md (user-level rules load in every project; use rules/ rather than CLAUDE.md, especially when CLAUDE.md is a symlink to a file shared with non-Claude agents). Replace any earlier version, keeping hand-added lines found in section 1 step 6. Content:

# Model team

This Claude Code setup runs Opus as the main model and planner, with `builder` (Sonnet) and `glm-builder` (GLM 5.3 through OpenCode) subagents doing the legwork, Haiku as the default model for search subagents, and an Opus `reviewer`. The advisor tool is Opus and is for the builders.

**Exception: a session whose main model is not Opus** (a repo that sets `model` in project settings, or `/model` was changed). Then the main model builds its own code and uses the advisor and `reviewer` as in the Opus-advisor setup.

## Opus (main): plans and judges, never writes code
- Splits the task into pieces that do not collide, writes a brief for each, starts the builders, reads their results and decides what is accepted. Owns the conversation with the user.
- Does not edit code files itself. Tiny edits to non-code files (a note, a config line) are fine.
- A brief says: the goal of the piece, the files it owns, the files it must not touch, how to build and test it, what done means, and the repo rules to follow. Two builders never own the same file. If two pieces depend on each other, run them one after the other.
- Does not consult the advisor tool for its own plan: it is itself Opus. When truly stuck on a decision, say what the options are and recommend one.
- Keeps the team small: at most two builders at a time unless the user asks for more.

## Choosing the builder
- `builder` (Sonnet): design-sensitive code, anything touching security, data or public APIs, work that needs judgement, and anything where a wrong guess is costly.
- `glm-builder` (GLM 5.3): self-contained pieces with a clear spec: tests, boilerplate, mechanical refactors, docs, ports of existing code, repetitive edits across many files. Do not use it for secrets handling, auth, migrations or anything irreversible.
- Independent pieces can run in parallel (one of each).
- If `glm-builder` is unavailable or fails twice (auth, quota), give its piece to `builder` and tell the user.
- Do not send implementation to the Haiku search subagents: their output is research, not code.

## Sonnet builder: asks the advisor whenever it needs
- The `builder` may call the advisor tool (Opus) before committing to an approach for something non-trivial, when the same error comes back after two attempts, or when changing approach. Not for routine steps. If advice conflicts with evidence in the code or a command's output, it says so.
- The `glm-builder` wrapper does not call the advisor.

## Haiku (subagents): searches and researches
- Send broad codebase searches, documentation lookups and web research to subagents. general-purpose subagents run on Haiku by default (CLAUDE_CODE_SUBAGENT_MODEL); the built-in Explore and Plan agents keep their own model unless you pass `model: "haiku"`. Launch independent ones in parallel.
- Give each a narrow question and ask for a short answer with file paths or URLs. Search subagents do not consult the advisor.

## Opus (reviewer subagent): checks before it ships
- After the builders finish, and before any commit, merge or deploy, run the `reviewer` subagent once on the combined diff. It is the done-check for code.
- Send each confirmed finding back to the builder that owns the file. Re-run the reviewer only when the fixes were substantial.
- Skip it for one-line or docs-only changes. For a non-code task (research, writing, operations) there is no reviewer step: check the result yourself.
- Never accept a piece because a builder says its tests pass: look at the command it ran and its output.

## 7. Verification
1. Settings, rules and agents load at startup. The current session will not change. I must start a new one (or resume with `claude --resume` and run `/model opus`).
2. Checklist for the new session:
   - `/status` shows Opus as the model.
   - `/advisor` with no argument shows Opus.
   - `/agents` lists `builder` (sonnet), `glm-builder` (haiku) and `reviewer` (opus).
   - Smoke test, small and cheap: ask for a trivial change in a scratch directory (add a function and a test). Opus should write briefs and start `builder` and `glm-builder` on separate files, not edit code itself. For `glm-builder`, check that `opencode run` was launched, GLM's diff is visible in `git diff`, and the wrapper ran the tests itself. Then the `reviewer` should run on the combined diff.
   - `/usage` shows Opus, Sonnet and Haiku usage, and advisor tokens separately. GLM usage is billed by its provider, not shown here.

## 8. Report
Summarise: version, provider, the GLM model ID you chose and the result of the `ok` test call, what `--auto` allows, the settings diff (or "already set"), the files you created or replaced (full paths), the backup path, hand-added rule lines carried over, where the docs differed from this prompt, any backup or config that holds a secret (path only, never the value), anything you could not do, and how to revert:
- set "model" back to "sonnet" (or remove it) in ~/.claude/settings.json, or restore the settings backup
- `/advisor off` (or `CLAUDE_CODE_DISABLE_ADVISOR_TOOL=1`)
- delete ~/.claude/agents/builder.md, ~/.claude/agents/glm-builder.md and ~/.claude/rules/model-team.md; keep reviewer.md if you still use the other setups
- to go back to Sonnet as main: run the claude-code-opus-advisor-setup prompt.
Also say plainly that every plain `claude` launch now defaults to Opus, including scripts and agents that do not pass --model.
```

# Notes

- **Why Opus as planner instead of Sonnet:** the planner decides how the work is split and which builder gets which piece, so a wrong split costs more than a wrong line of code. The builders get a written brief, so the planner's context stays small if it does not read all the code itself.
- **Why the advisor is for the Sonnet builder:** the main model already is Opus, so an advisor call from it would be Opus asking Opus. The builder works alone on a piece and has no one to ask. Subagents inherit the advisor setting, and the pairing check passes for Sonnet 5.5 with an Opus advisor. This is the documented behaviour I relied on, not something I ran end to end; the verification section checks it.
- **Why GLM goes through a Haiku wrapper:** Claude Code subagents run on Claude models only. A wrapper agent that shells out to `opencode run` is the way to make GLM a "subagent" of Claude Code. The wrapper only runs the command and checks the result, so Haiku is enough. The cost is one extra hop and the fact that GLM does not see the conversation, only the brief.
- **What was checked on this machine (24 Nov 2026):** OpenCode v2.4.1 is installed (mise). `opencode models` lists `opencode-go/glm-5.3`, `opencode-go/glm-5.3-flash`, `opencode/glm-5.3` and `opencode/glm-5.3-flash`. `opencode run -m opencode-go/glm-5.3 "Reply with exactly: ok"` printed `ok`. Not run: a real multi-file edit by GLM, the `--auto` behaviour on this OpenCode config, and the full team on a task.
- **Risk to know about:** `opencode run --auto` lets GLM edit files and run commands without asking. The brief's "files you own" rule is an instruction, not a sandbox, and the wrapper's `git diff` check only notices a violation after the fact. Use it in a repository where changes are recoverable, with a clean tree before the run.
- **Secrets:** `~/.config/opencode/opencode.json` on this machine holds a plaintext provider key. This prompt tells the agent never to `cat` it. Rotating that key is worth doing if it was ever printed into a transcript.
- **Repos with their own rules:** repos like ShareX-Rust forbid git worktrees and require one task per branch. The brief must say which branch to work on and not to create worktrees. GLM does not read Claude Code's rules files, so anything it must follow goes in the brief.
- **A third lane:** [claude-code-opus-neon-agy-lane-setup](claude-code-opus-neon-agy-lane-setup.md) adds Gemini 4 Neon through the Antigravity CLI (`agy-builder`, `agy-reviewer`) on top of this team, with no API key.
- **Cost model:** Opus main bills for every planning turn and for reading the builders' reports. Keep briefs short and ask for short reports. The Opus reviewer and advisor are separate Opus calls on top, so the rule keeps each to one moment per piece.
