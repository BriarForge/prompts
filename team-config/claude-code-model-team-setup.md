---
tags: [claude-code, advisor, fable, opus, sonnet, haiku, subagents, model-config, cost, reusable]
category: team-config
version: 1
last-used: 2026-11-15
---

# Claude Code model team: Fable advises, Sonnet builds, Opus reviews, Haiku searches

Paste into Claude Code on any machine. It sets up, at user level (all projects):

| Model | Role | Mechanism |
|---|---|---|
| Sonnet | Main model; writes all the code | `"model": "sonnet"` |
| Fable | Advisor; never writes code, consulted at decision points | `"advisorModel": "fable"` (advisor tool) |
| Haiku | Default model for subagents doing search and research | `env.CLAUDE_CODE_SUBAGENT_MODEL=haiku` |
| Opus | Independent reviewer before commit/merge/deploy | `~/.claude/agents/reviewer.md` with `model: opus` |
| (rule) | Tells Sonnet *when* to consult Fable, delegate, review | `~/.claude/rules/model-team.md` |

```text
Set up a cost-saving model team for Claude Code at the USER level so it applies to every project on this machine. Fable advises, Sonnet builds, Opus reviews, Haiku searches. Follow these steps in order and do not skip the checks.

## 0. Ground rules
- Do not trust this prompt's claims blindly. Before changing anything, read the official docs and confirm each mechanism still exists and works as described:
  - https://code.claude.com/docs/en/advisor
  - https://code.claude.com/docs/en/model-config
  - https://code.claude.com/docs/en/sub-agents (section "Choose a model")
  - https://code.claude.com/docs/en/env-vars (rows CLAUDE_CODE_SUBAGENT_MODEL, CLAUDE_CODE_DISABLE_ADVISOR_TOOL, and "Features that need feature-flag fetching")
  - https://code.claude.com/docs/en/memory (section on user-level rules in ~/.claude/rules/)
  If a doc contradicts this prompt, the doc wins: adapt, and tell me what differed.
- Merge into existing config. Never drop keys that are already there (permissions, hooks, plugins, env, and so on).
- Keep JSON valid and keep non-ASCII characters as they are (no \u escaping that creates a noisy diff).

## 1. Preflight checks (report each result)
1. `claude --version`. Fable 5.2 as advisor needs v2.1.321 or later; Haiku 5.5 as main or advisor needs v2.1.293 or later. If older, tell me to run `claude update` and stop.
2. Provider: the advisor works only on the Anthropic API (subscription or API key), Claude Platform on AWS, or Claude Models on Google Cloud (Anthropic managed). It does NOT work on Amazon Bedrock, Google Cloud's Agent Platform (Vertex), or Microsoft Foundry. Check env and settings for CLAUDE_CODE_USE_BEDROCK / CLAUDE_CODE_USE_VERTEX / CLAUDE_CODE_USE_FOUNDRY and ANTHROPIC_BASE_URL (a gateway may strip the advisor tool). Report what you find.
3. Feature flags: the advisor needs feature-flag fetching. Check the shell env and the settings `env` block for CLAUDE_CODE_DISABLE_FEATURE_FLAGS, DISABLE_GROWTHBOOK, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC, DISABLE_TELEMETRY, and CLAUDE_CODE_DISABLE_ADVISOR_TOOL. If any is set, tell me it blocks the advisor and ask before removing it.
4. Fable access: ask me whether this account has Fable. If not, use `opus` as the advisor instead of `fable` everywhere below (Sonnet 5.5 accepts Opus 5+ as advisor).
5. Look at ~/.claude/settings.json, ~/.claude/CLAUDE.md (note if it is a symlink to a file shared with other agents), ~/.claude/rules/, and ~/.claude/agents/. Report anything that already sets `model`, `advisorModel`, `CLAUDE_CODE_SUBAGENT_MODEL`, or an agent named `reviewer`.

## 2. Back up, show the diff, then apply
1. Copy ~/.claude/settings.json to ~/.claude/settings.json.bak-<YYYYMMDD-HHMMSS> (create an empty `{}` settings file first if none exists).
2. Add or set exactly these keys, leaving every other key alone:
   - "model": "sonnet"
   - "advisorModel": "fable"   (or "opus" if no Fable access)
   - "env": { ...existing env..., "CLAUDE_CODE_SUBAGENT_MODEL": "haiku" }
3. Show me `diff <backup> ~/.claude/settings.json`. The diff must contain only these additions. If it shows anything else, fix it before going on.

Facts to respect:
- Aliases (sonnet, fable, opus, haiku) resolve to Claude Code's built-in default version of each family and advance with releases. Use full IDs (for example claude-sonnet-5-5) only if I ask to pin.
- The advisor must rank at or above the main model. With Sonnet 5.5 as main, accepted advisors are Fable, Opus 5 or later, and Sonnet 5.5. Haiku 4.5 cannot be an advisor.
- CLAUDE_CODE_SUBAGENT_MODEL is only a default (since v2.1.251). A model Claude passes when spawning an agent, or a `model:` field in an agent definition (including `inherit`), takes precedence. Do NOT set CLAUDE_CODE_SUBAGENT_MODEL_FORCE, because it would pull the Opus reviewer down to Haiku.
- Subagents inherit the configured advisor and pass the same pairing check against their own model, so Haiku 5.5 subagents can call Fable too.

## 3. Create the Opus reviewer agent
Write ~/.claude/agents/reviewer.md (if one exists, show it to me and ask before replacing):

---
name: reviewer
description: Independent Opus review of a finished change before it is reported done or committed. Reads the diff (or the files named), hunts for correctness bugs, missed requirements, broken edge cases and risky side effects, and returns a short ranked list of findings with file:line. Use after any non-trivial code change, before a commit, merge or deploy, or when the user asks for a review.
model: opus
tools: Read, Grep, Glob, Bash
---

You are the reviewer. A cheaper model (usually Sonnet) wrote the change; your job is to catch what it missed before the work is called done. You do not edit files.

1. Work out what changed: `git diff`, `git diff --staged`, or the paths you were given. Read enough surrounding code to judge it in context.
2. Check the change against what was asked. Missing pieces count as findings.
3. Look for real defects: wrong logic, unhandled errors or edge cases, broken callers, security problems, data loss, races, leftover debug code, tests that don't test the change.
4. Run cheap read-only checks when they settle a question (type-check, existing tests, `grep` for other callers). Do not install, push, deploy or modify anything.

Report findings most severe first, each as: `path:line` — what is wrong — the concrete scenario that breaks. Say plainly which you verified and which are suspicions. If you find nothing worth fixing, say "No blocking issues" and stop. Skip style nitpicks.

## 4. Write the behaviour rule (the line that makes the advisor fire)
The advisor's timing is model-driven: no setting forces or caps calls. Without an explicit instruction, the main model may rarely consult it. Put the rule in ~/.claude/rules/model-team.md (user-level rules load in every project). Use ~/.claude/rules/ rather than ~/.claude/CLAUDE.md, especially when CLAUDE.md is a symlink to an AGENTS.md shared with non-Claude agents, because this rule only makes sense in Claude Code. Content:

# Model team

This Claude Code setup runs Sonnet as the main model, Fable as the advisor tool, Haiku as the default subagent model, and an Opus `reviewer` subagent.

## Sonnet (main model): builds
- Writes all the code and makes all the edits. Owns the conversation with the user.
- Does not hand implementation to Haiku subagents; their output is research, not code.

## Fable (advisor): decides, never writes code
Consult the advisor, when the advisor tool is available, at these points, and do not skip them on non-trivial tasks:
1. Before committing to a plan or approach for anything beyond a small, obvious edit.
2. When the same error or failing test comes back after two fix attempts.
3. Before declaring a multi-step task done, merged, or deployed.
Do not consult it for routine steps (reading files, simple edits, running commands). When its advice conflicts with evidence you have (a file's contents, a command's result), say so instead of following it blindly.

## Haiku (subagents): searches and researches
- Send broad codebase searches, documentation lookups and web research to subagents (Explore, general-purpose), which run on Haiku by default. Launch independent ones in parallel.
- Give each a narrow question and ask for a short answer with file paths or URLs, so raw output stays out of the main context.
- Subagents doing search or research do not consult the advisor.

## Opus (reviewer subagent): checks before it ships
- After a non-trivial code change, and before any commit, merge or deploy, run the `reviewer` subagent on the diff.
- Fix what it confirms. Re-run it only when the fixes were substantial.
- Skip it for one-line or docs-only changes.

## 5. Fable consent and verification
1. Tell me: on some plans Fable usage bills to usage credits and needs a one-time consent. If a new session shows a notice pointing to `/model fable`, run `/model fable`, accept, then `/model sonnet` to switch the main model back (because `/model fable` also makes Fable the main model). Then run `/advisor fable` if the advisor did not stick.
2. Settings, rules and agents load at startup. The current session will not change; I must start a new one, or resume an old one with `claude --resume` / `claude -c` and run `/model sonnet` then `/advisor fable` (switching the model in an old session drops its prompt cache, so the first turn costs more).
3. Verification checklist for the new session:
   - `/status` shows Sonnet as model.
   - Startup shows "Advisor Tool (experimental) is on and may use more tokens · /advisor".
   - `/agents` lists `reviewer` (opus).
   - On a real task, an "Advising <model>" line appears at plan time; Ctrl+O shows the guidance. "Advisor unavailable (<code>)" means a provider or flag problem from step 1.
   - `/usage` shows advisor tokens separately.

## 6. Report
Summarise: version, provider, the settings diff, the files you created (full paths), the backup path, anything you could not do, and how to revert:
- `/advisor off` (or `CLAUDE_CODE_DISABLE_ADVISOR_TOOL=1` to disable the tool entirely)
- `/model opus` (or remove "model" from settings)
- restore the settings backup, delete ~/.claude/agents/reviewer.md and ~/.claude/rules/model-team.md
Also say plainly that every plain `claude` launch now defaults to Sonnet, including scripts and agents that don't pass --model.
```

# Notes

- What is real (checked against code.claude.com docs, 2026-11-15): the advisor tool (`/advisor`, `advisorModel`, `--advisor`, which `claude --help` does not list), the pairing table, `CLAUDE_CODE_SUBAGENT_MODEL`, agent `model:` frontmatter, user-level `~/.claude/rules/`.
- What is not a built-in feature, despite the viral "Fable thinks, Sonnet builds, Opus reviews, Haiku coordinates" post: there is no Haiku coordinator mode (Sonnet stays the main model and spawns Haiku subagents), and no Opus reviewer setting (it is a custom agent). The post's "3.4x cheaper" and "198 cases" numbers could not be found in Anthropic's docs.
- Cost model: each advisor call re-reads the full transcript at the advisor's rates (not cached), so the rule restricts calls to the three decision points. Toggling `/advisor` does not invalidate the main model's prompt cache; switching `/model` does.
- No Fable access: use `opus` as the advisor. Same rule file, just with "Opus (advisor)" in place of "Fable (advisor)".
