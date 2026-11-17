---
tags: [claude-code, advisor, opus, sonnet, haiku, subagents, model-config, cost, reusable]
category: team-config
version: 1
last-used: 2026-11-18
---

# Claude Code model team: Opus advises, Sonnet builds, Haiku searches, Opus reviews

Variant of [claude-code-model-team-setup](claude-code-model-team-setup.md) (Fable advisor) for accounts without Fable, plans where Fable bills to usage credits, or when you want lower advisor cost. Same files, so running either prompt switches a machine cleanly between the two setups.

Paste into Claude Code on any machine. It sets up, at user level (all projects):

| Model | Role | Mechanism |
|---|---|---|
| Sonnet | Main model; writes all the code | `"model": "sonnet"` |
| Opus (advisor) | Consulted while planning and when stuck; sees the whole conversation; never writes code | `"advisorModel": "opus"` (advisor tool) |
| Haiku | Default model for subagents doing search and research (general-purpose and custom agents without `model:`; built-in Explore/Plan keep their own model unless spawned with `model: "haiku"`) | `env.CLAUDE_CODE_SUBAGENT_MODEL=haiku` |
| Opus (reviewer) | Fresh-context review of the diff before commit/merge/deploy | `~/.claude/agents/reviewer.md` with `model: opus` |
| (rule) | Tells Sonnet when to consult the advisor, delegate, and review, without paying Opus twice for the same moment | `~/.claude/rules/model-team.md` |

```text
Set up a cost-saving model team for Claude Code at the USER level so it applies to every project on this machine. Opus advises, Sonnet builds, Haiku searches, and a separate Opus reviewer checks diffs before they ship. Follow these steps in order and do not skip the checks.

## Design (why it is split this way)
Opus has two jobs here, and they must not overlap, or the same moment gets billed twice at Opus rates:
- Opus ADVISOR (advisor tool): sees the whole conversation. Best at judging the approach. Used before committing to a plan and when stuck.
- Opus REVIEWER (subagent): starts with fresh context and reads only the diff. Best at catching what the conversation glossed over. Used before commit, merge or deploy.
For code changes, the reviewer replaces the advisor's "is this done?" check. The advisor gets the "done" question only for non-code tasks.

## 0. Ground rules
- Do not trust this prompt's claims blindly. Before changing anything, read the official docs and confirm each mechanism still exists and works as described:
  - https://code.claude.com/docs/en/advisor (sections "Choose an advisor model" and "Requirements")
  - https://code.claude.com/docs/en/model-config
  - https://code.claude.com/docs/en/sub-agents (section "Choose a model")
  - https://code.claude.com/docs/en/env-vars (rows CLAUDE_CODE_SUBAGENT_MODEL, CLAUDE_CODE_DISABLE_ADVISOR_TOOL, and "Features that need feature-flag fetching")
  - https://code.claude.com/docs/en/memory (section on user-level rules in ~/.claude/rules/)
  If a doc contradicts this prompt, the doc wins: adapt, and tell me what differed.
  These pages are long (env-vars is ~190 KB) and a fetch tool may return only the first part. Keep reading with an offset, or search the saved output for the exact row names, until you have actually seen each row listed above. Do not report a row as confirmed if you only saw a summary of it.
- Merge into existing config. Never drop keys that are already there (permissions, hooks, plugins, env, and so on).
- Keep JSON valid and keep non-ASCII characters as they are (no \u escaping that creates a noisy diff).
- Never print secret values (ANTHROPIC_API_KEY, ANTHROPIC_AUTH_TOKEN, any `*_TOKEN`/`*_KEY`) to the terminal or into your report. Mask them: show only whether the key is set. Use commands like `grep ... | sed 's/=.*/=<set>/'` rather than `env` or `cat` on files that may hold them, and do the same when diffing old backups.

## 1. Preflight checks (report each result)
1. `claude --version`. The advisor itself works on recent versions; Haiku 5.5 as main model or advisor needs v2.1.293 or later; on Claude Platform on AWS or Claude Models on Google Cloud (Anthropic managed) the advisor needs v2.1.300 or later. If too old, tell me to run `claude update` and stop.
2. Provider: the advisor works only on the Anthropic API (subscription or API key), Claude Platform on AWS, or Claude Models on Google Cloud (Anthropic managed). It does NOT work on Amazon Bedrock, Google Cloud's Agent Platform (Vertex), or Microsoft Foundry. Check env and settings for CLAUDE_CODE_USE_BEDROCK / CLAUDE_CODE_USE_VERTEX / CLAUDE_CODE_USE_FOUNDRY and ANTHROPIC_BASE_URL (a gateway may strip the advisor tool). Also check ANTHROPIC_MODEL and ANTHROPIC_DEFAULT_SONNET_MODEL / _OPUS_MODEL / _HAIKU_MODEL / _FABLE_MODEL: these remap the aliases, so with a non-Anthropic gateway `sonnet`, `opus` and `haiku` silently point at non-Claude models and the whole team setup is meaningless. Report what you find (masked); if any are set, ask me whether that is intended before going on.
3. Feature flags: the advisor needs feature-flag fetching. Check the shell env and the settings `env` block for CLAUDE_CODE_DISABLE_FEATURE_FLAGS, DISABLE_GROWTHBOOK, CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC, DISABLE_TELEMETRY, DO_NOT_TRACK, and CLAUDE_CODE_DISABLE_ADVISOR_TOOL. If any is set, tell me it blocks the advisor and ask before removing it. The fetch is also skipped on third-party providers and in Claude apps gateway sessions.
4. Model allowlist: if settings contain `availableModels` (often set by an organization), check that it allows sonnet, opus and haiku. Claude Code will not invoke an advisor the allowlist excludes. If Opus is excluded, use `sonnet` as the advisor instead (Sonnet 5.5 accepts Sonnet 5.5 as advisor) and tell me.
5. Look at ~/.claude/settings.json, ~/.claude/CLAUDE.md (note if it is a symlink to a file shared with other agents), ~/.claude/rules/, and ~/.claude/agents/. Report anything that already sets `model`, `advisorModel`, `CLAUDE_CODE_SUBAGENT_MODEL`, or an agent named `reviewer`. If ~/.claude/rules/model-team.md exists (for example from the Fable variant of this prompt), show it to me and point out any lines that were added by hand, such as per-repo exceptions; carry those over in section 4 unless I say otherwise.
6. Existing backups: list ~/.claude/settings.json.bak-* and diff the newest against the current settings (masking secrets as in step 0). A recent backup that differs a lot usually means someone changed the setup by hand shortly before. Tell me what changed and ask whether it is intended. If any backup holds a plaintext token or API key, say so (without printing it) and recommend deleting that backup and rotating the key.
7. Overrides: project settings (`.claude/settings.json`, `.claude/settings.local.json`) override user settings, so a repo that sets `model` will not use Sonnet. Mention any you find in the current directory, plus a stray `~/.claude/.claude/settings.json` (created when Claude Code is run with ~/.claude as the working directory; harmless elsewhere).

## 2. Back up, show the diff, then apply
1. If the settings already hold exactly the values below, say so, skip steps 1–3 of this section (no backup, no diff), and continue at step 4. Otherwise copy ~/.claude/settings.json to ~/.claude/settings.json.bak-<YYYYMMDD-HHMMSS> (create an empty `{}` settings file first if none exists).
2. Add or set exactly these keys, leaving every other key alone:
   - "model": "sonnet"
   - "advisorModel": "opus"
   - "env": { ...existing env..., "CLAUDE_CODE_SUBAGENT_MODEL": "haiku" }
   Merge with a real JSON parser, not sed. `jq` is often missing (especially on Windows); `node -e` or `python -c` with json load/dump at indent 2 works everywhere. Keep the existing indentation and key order; append new keys at the end.
3. Show me `diff <backup> ~/.claude/settings.json`. The diff must contain only these changes, plus a trailing comma added to the line that used to be last. If it shows anything else (reordered keys, re-escaped characters, a changed indent), fix it before going on.
4. Create ~/.claude/agents/ and ~/.claude/rules/ if they don't exist (they don't on a fresh install).

Facts to respect:
- Aliases (sonnet, opus, haiku) resolve to Claude Code's built-in default version of each family and advance with releases. Use full IDs (for example claude-opus-5-5) only if I ask to pin.
- The advisor must rank at or above the main model. Accepted Opus pairings (check the doc's table for the current list):
  - Sonnet 5.5 main: Opus 5 or later (also Fable, or Sonnet 5.5).
  - Opus 5 / 5.5 main: Opus 5 or later (a second Opus checks the first).
  - Haiku 5.5 main: Opus 4.7 or later.
  - A Fable main model does NOT accept an Opus advisor; Claude Code just runs without one.
- An advisor that ranks below the main model is not attached, without an error. Haiku 4.5 cannot be an advisor at all.
- CLAUDE_CODE_SUBAGENT_MODEL does not change the built-in Explore and Plan agents; they keep their own model unless Claude passes `model` when spawning them. It does apply to general-purpose, custom agents without `model:`, agent-team teammates and workflow agents.
- CLAUDE_CODE_SUBAGENT_MODEL is only a default (since v2.1.251). A model Claude passes when spawning an agent, or a `model:` field in an agent definition (including `inherit`), takes precedence. Do NOT set CLAUDE_CODE_SUBAGENT_MODEL_FORCE, because it would pull the Opus reviewer down to Haiku.
- Subagents inherit the configured advisor and pass the same pairing check against their own model, so Haiku 5.5 subagents can call Opus too. The rule below tells them not to.

## 3. Create the Opus reviewer agent
Write ~/.claude/agents/reviewer.md (if one exists and differs, show it to me and ask before replacing):

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

## 4. Write the behaviour rule
The advisor's timing is model-driven: no setting forces or caps calls, and the advisor tool's own instructions push the model to call it before declaring done. This rule biases that behaviour; it cannot forbid a call. Put it in ~/.claude/rules/model-team.md (user-level rules load in every project). Use ~/.claude/rules/ rather than ~/.claude/CLAUDE.md, especially when CLAUDE.md is a symlink to an AGENTS.md shared with non-Claude agents, because this rule only makes sense in Claude Code. Replace any earlier version of the file, keeping hand-added lines found in step 1.5. Content:

# Model team

This Claude Code setup runs Sonnet as the main model, Opus as the advisor tool, Haiku as the default subagent model, and an Opus `reviewer` subagent. Opus has two separate jobs; do not pay for both at the same moment.

## Sonnet (main model): builds
- Writes all the code and makes all the edits. Owns the conversation with the user.
- Does not hand implementation to Haiku subagents; their output is research, not code.

## Opus (advisor): plans and unsticks, never writes code
Consult the advisor, when the advisor tool is available, at these points, and do not skip them on non-trivial tasks:
1. Before committing to a plan or approach for anything beyond a small, obvious edit.
2. When the same error or failing test comes back after two fix attempts, or when considering a change of approach.
3. Before declaring a task done ONLY when it is not a code change (config, research, writing, operations). For code changes, the `reviewer` subagent does the done-check instead; do not also ask the advisor "is this done?".
Do not consult it for routine steps (reading files, simple edits, running commands). When its advice conflicts with evidence you have (a file's contents, a command's result), say so instead of following it blindly.
If the main model is itself Opus (a repo that sets `model` in project settings), the advisor is a second Opus: use it only for point 1.

## Haiku (subagents): searches and researches
- Send broad codebase searches, documentation lookups and web research to subagents. general-purpose subagents run on Haiku by default (CLAUDE_CODE_SUBAGENT_MODEL); the built-in Explore and Plan agents keep their own model unless you pass `model: "haiku"` when spawning them. Launch independent ones in parallel.
- Give each a narrow question and ask for a short answer with file paths or URLs, so raw output stays out of the main context.
- Subagents doing search or research do not consult the advisor.

## Opus (reviewer subagent): checks before it ships
- After a non-trivial code change, and before any commit, merge or deploy, run the `reviewer` subagent on the diff. This is the done-check for code; it replaces the advisor's.
- Fix what it confirms. Re-run it only when the fixes were substantial.
- Skip it for one-line or docs-only changes.

## 5. Verification
1. Settings, rules and agents load at startup. The current session will not change; I must start a new one, or resume an old one with `claude --resume` / `claude -c` and run `/model sonnet` then `/advisor opus` (switching the model in an old session drops its prompt cache, so the first turn costs more; toggling the advisor does not).
2. Checklist for the new session:
   - `/status` shows Sonnet as model.
   - Startup shows "Advisor Tool (experimental) is on and may use more tokens · /advisor".
   - `/advisor` with no argument shows Opus.
   - `/agents` lists `reviewer` (opus).
   - On a real coding task: an "Advising <model>" line appears at plan time (Ctrl+O shows the guidance), and the `reviewer` subagent runs before the commit. "Advisor unavailable (<code>)" means a provider or flag problem from step 1. A notice that the advisor is less capable than the main model means a project setting picked a Fable main model.
   - `/usage` shows advisor tokens separately.

## 6. Report
Summarise: version, provider, the settings diff (or "already set"), the files you created or replaced (full paths), the backup path, hand-added rule lines you carried over, where the docs differed from this prompt, any backup that holds a secret (path only), anything you could not do, and how to revert:
- `/advisor off` (or `CLAUDE_CODE_DISABLE_ADVISOR_TOOL=1` to disable the tool entirely)
- `/model opus` (or remove "model" from settings)
- restore the settings backup, delete ~/.claude/agents/reviewer.md and ~/.claude/rules/model-team.md
- to switch to the Fable advisor instead, run the claude-code-model-team-setup prompt.
Also say plainly that every plain `claude` launch now defaults to Sonnet, including scripts and agents that don't pass --model.
```

# Notes

- **Why not just swap Fable for Opus in the original prompt:** with Opus in both the advisor and reviewer roles, the original rule pays Opus twice at the end of every task (advisor "done?" call and reviewer). This variant gives the done-check for code to the reviewer, which has fresh context and reads only the diff, and keeps the advisor for planning, recurring errors and non-code completion.
- **What the rule can and cannot do:** the advisor tool's built-in instructions tell the model to call it before declaring done. The rule only biases this; expect an occasional extra advisor call. There is no setting to cap calls.
- **Cost model:** each advisor call re-reads the full transcript at Opus rates (not cached). Opus costs less per token than Fable, but the call count matters more than the rate, so the rule keeps it to the planning and stuck points.
- **Variants the pairing rules allow:**
  - *Opus main + Opus advisor*: for repos where you already run Opus (project `.claude/settings.local.json` with `"model": "opus"`). The rule limits the advisor to the planning point there.
  - *Haiku main + Opus advisor*: cheapest; Anthropic lists it as a common pairing. Fine for routine or high-volume work, risky for complex changes. Set `"model": "haiku"` (Haiku 5.5, v2.1.293+).
  - *Sonnet advisor*: fallback when an `availableModels` allowlist excludes Opus.
  - *Fable for one hard session*: `/advisor fable` (needs Fable access, maybe usage-credits consent); `/advisor opus` to go back.
- **Switching between the Fable and Opus setups:** both prompts write the same `advisorModel` key, `reviewer.md` and `rules/model-team.md`, so whichever ran last wins and only one rule is ever loaded.
