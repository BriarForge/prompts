---
tags: [xerahs, sweep, code-review, agent-agnostic]
category: coding
version: 4
last-used: 2026-07-11
---

# XerahS Sweep Prompt (agent-agnostic, no placeholders)

Launch a XerahS review sweep via the `xerahs-hourly-sweep` skill, scoped to a single area, with a clear primary target and ranked fallbacks. The skill folder is named `hourly-sweep` but in practice runs happen on demand — do not promise a fixed cadence.

This prompt contains **no fill-in-the-blanks placeholders**. It pins the repo, branch, and skill name to fixed values; operator identity (name + git wrapper + remote) is discovered at run time via `git-<name> whoami`. Open the file and run it as-is.

**Who runs this prompt.** Mcored names the operator in his request message. That operator drives end-to-end and posts the sweep summary. Other agents should not start a parallel sweep on the same state file — they would race on `hourly_review_state.json` updates. If Mcored has not named you, do not pick up unilaterally; either ask in #xerahs or wait for a direct ping.

**Branch discipline (hard rule, no exceptions).** All work happens on the **existing `develop` branch** of the XerahS repo (`/Users/mike/Projects/KovaForge/xerahs`). The operator MUST NOT create a new branch, worktree, fork scope, or personal integration branch for this sweep. No `git checkout -b`, no `git switch -c`, no `git worktree add`, no `git push <remote> HEAD:<new-branch>`, no creating `aoife/master`, `vladislava/develop`, or any other named branch — push to your wrapper's `develop` only. If you find yourself wanting a branch you don't have, you are misreading the prompt — re-read this section and use the existing `develop`. The same rule applies to investigation work: use local scratch files under `/tmp/xerahs-review/` and the agent's local stash, not git branches. This rule comes from the XerahS root `AGENTS.md` ("do not create branches or GitHub issues unless asked") and from the BriarForge parent `AGENTS.md` ("No creating branches without explicit permission"); both are upstream of this file and override anything in this prompt that conflicts with them.

## Run-time identity discovery (do this BEFORE anything else)

Do not assume your wrapper or remote. Discover both in the prompts session and again inside the XerahS repo.

1. Run your per-person wrapper's `whoami` and capture **name**, **email**, **push remote**, and **SSH host**:
   ```bash
   git-aoife whoami       # or: git-declan | git-mikhail | git-milena | git-nadia | git-vladislava
   ```
   Use the wrapper Mcored assigned to you. If Mcored didn't assign one, ask in #xerahs — never pick a different agent's wrapper.
2. From inside `/Users/mike/Projects/KovaForge/xerahs`, confirm `git remote -v` shows the push remote that `whoami` reported:
   ```bash
   git remote -v
   ```
   Every wrapper (`aoife`, `declan`, `mikhail`, `milena`, `nadia`, `vladislava`) has its own SSH key and its own `git@github-<agent>:KovaForge/XerahS.git` remote in this repo. If your remote is missing, your SSH key wasn't added to GitHub yet — STOP and ping Mcored; do not commit under a different identity.
3. Use the wrapper's own `REMOTE=` value as your remote everywhere below. Do not hardcode `origin`.

## Pre-flight check (run BEFORE you touch anything)

Do not start a sweep until every line below is green. If any check fails, STOP and post to #xerahs with the failing line — do not improvise.

1. `git-<your-wrapper> whoami` returns a non-empty `NAME=...` line with your identity, plus a `push remote: <your-agent> (git@github-<your-agent>:KovaForge/XerahS.git)` line.
2. From inside `/Users/mike/Projects/KovaForge/xerahs`, `git remote -v` shows your wrapper's remote for both fetch and push.
3. `git-<your-wrapper> ls-remote <your-agent> develop` returns a real SHA (not empty / not "could not read").
4. Local branch `develop` exists: `git branch --list develop` is non-empty (or `git show-ref --verify --quiet refs/heads/develop` exits 0). If `develop` is missing locally but `git-<your-wrapper> ls-remote <your-agent> develop` has a SHA, materialize it with `git-<your-wrapper> fetch <your-agent> develop` followed by `git-<your-wrapper> checkout develop` (use `git branch --set-upstream-to=<your-agent>/develop develop` if upstream tracking needs to be re-established). Do NOT create `<your-agent>/develop`, `aoife/master`, or any personal / per-wrapper local branch (`-b` / `-c` forbidden). The remote-tracking ref `<your-agent>/develop` may exist as the upstream of your local `develop`, but your local branch name must always be `develop`. If `develop` is missing on the remote at all for some reason, STOP and ping Mcored.
5. You are sitting on `develop` before any edit: `git branch --show-current` must equal `develop`. If you are on `master`, on `HEAD` detached, or on any other ref, run `git-<your-wrapper> checkout develop` first. Never `checkout -b`, never `switch -c`.
6. The `xerahs-hourly-sweep` skill's `SKILL.md` exists at its current consolidation path under openclaw-config / `.ai` (it has moved across PRs — verify against the skill's own consolidation note). Read it end to end before touching anything else.
7. `next_candidates` in `/Users/mike/Projects/KovaForge/xerahs/docs/reports/hourly_review_state.json` is non-empty. If it is empty, the sweep queue is exhausted; STOP and ping Mcored.
8. No other agent has posted a "starting, HEAD = <sha>" to #xerahs in the last 30 minutes. If someone did, ping them in-thread to confirm whether they finished or stalled before you start.

## Picking the target

There are no placeholder slots for the target. Pull them from the live state file at run time:

- **Primary target**: the top entry in `next_candidates`. If Mcored named an area in his request message, that overrides `next_candidates` and becomes primary; document the override in the summary.
- **Fallbacks**: the next two entries in `next_candidates`, in order.
- **Likely file hint**: take from the candidate's `file_hint` field if present; if absent, say so explicitly in the summary rather than guessing.
- **Prior fix note**: read the most recent entry in `last_runs` (or the candidate's `prior_fix` pointer if set) so the agent does not re-do it.
- **Pre-existing failures**: bullet list of unrelated, pre-existing test failures to document but not touch. Pull from the most recent `last_runs` entry's `result` field and the current `areas[].last_outcome` lines — do not paste from a prior summary (which may be stale by several runs).

## Prompt

Only send the body below to the operator AFTER the pre-flight check is fully green and the picking rules above have been resolved against the live state file.

```text
You are running a XerahS review sweep. Use the `xerahs-hourly-sweep` skill as your procedure; do not invent steps.

WORKSPACE
- Repo:    /Users/mike/Projects/KovaForge/xerahs
- Branch:  ALL work happens on the existing `develop` branch. You MUST NOT create a new branch, worktree, or fork scope for this sweep. No `git checkout -b`, no `git switch -c`, no `git worktree add`, no `git push <remote> HEAD:<new-branch>`, no `aoife/master`, no `vladislava/develop`, no personal integration branch. If you are not already on `develop` (verified by `git branch --show-current`), `git-<your-wrapper> checkout develop` and only then continue.
- Git:     use your own per-person wrapper for every commit, fetch, push, and ls-remote — never raw `git`. Valid wrappers are `git-aoife`, `git-declan`, `git-mikhail`, `git-milena`, `git-nadia`, `git-vladislava`. Your wrapper pins your NAME, REMOTE, and SSH_HOST. If `git-<your-wrapper> whoami` does not show a `push remote: <your-agent> (git@github-<your-agent>:KovaForge/XerahS.git)` line, STOP — you are in the wrong repo or the wrapper is misconfigured. Bare `git` will leak the host user.email and push to the wrong remote; never use it.
- Skill:   read the `xerahs-hourly-sweep` SKILL.md FIRST, end to end. Treat any consolidation note in that file as authoritative for the canonical path. It has moved across PRs; do not hardcode the path.
- State:   /Users/mike/Projects/KovaForge/xerahs/docs/reports/hourly_review_state.json
- Tracker: /Users/mike/Projects/KovaForge/xerahs/docs/reports/hourly_review_tracker.md

DO NOT RE-DO
- The most recent prior fix recorded in `last_runs` (or the candidate's `prior_fix` pointer). Skip it even if `next_candidates` still lists it.
- Any area flagged "deferred, recent churn" by the most recent two sweeps — re-flag and move on.
- The pre-existing test failures unrelated to any single area (pulled from the most recent `last_runs[].result` and `areas[].last_outcome` lines). Document them in the summary; do NOT touch them in this run. They have their own XIP.

PICK (in this priority)
Primary target — top of `next_candidates` (or Mcored's named area if he overrode it in his request):
  - Why now: the most recent prior fix is already in `last_runs`; the new finding is a related but distinct facet — read the previous fix first so you do not regress it.
  - Success shape: a regression test that covers the new facet without throwing on the old path, plus the smallest code change that surfaces the new symptom correctly.

Fallback if primary is clean or already covered — the next two entries in `next_candidates`, in order.

DISCIPLINE
- Stay on `develop` for the entire sweep. Do not create a new branch off it. Do not detach HEAD. Do not `rebase --onto` to a synthetic base. Do not push to `master`, to a personal integration branch, or to any non-`develop` ref. If you need parallel investigation, use the agent's local stash / scratch files under `/tmp/xerahs-review/`, not git branches.
- Step 3.5 clawpatch ingest runs the skill's global dedupe — let it run, do not skip.
- Atomic commit: one commit per fix containing code + version bump + state JSON update + tracker entry. No multi-commit fixes. Push via `git-<your-wrapper> push` (not raw git).
- Version bump in `Directory.Build.props`: read the current `<Version>` value, then patch+1 for the next commit prefix. (If HEAD has moved between read and commit, re-read and recompute.)
- Do NOT `git-<your-wrapper> push --force` under any circumstance. If `develop` is behind, fetch + rebase or fast-forward only.

SELF-CHECK BEFORE COMMITTING
0. Branch: `git branch --show-current` MUST equal `develop`. If it does not, STOP. Do not commit on a different branch, do not cherry-pick the changes onto `develop` to "fix" the situation, just stop and ping Mcored.
1. Build: `dotnet build --configuration Release -m:1` scoped to the touched csproj if the full solution times out at 60 s. Capture the log to /tmp/xerahs-review/build-<yyyymmdd>-<hhmmss>.log.
2. Tests: `dotnet test --filter "FullyQualifiedName~<TouchedArea>"` first; if green, run full XerahS.Tests. Record counts (passed/failed/skipped). Pre-existing failures must NOT be counted against your fix.
3. `git-<your-wrapper> ls-remote <your-agent> develop` and `git-<your-wrapper> rev-parse HEAD` — paste both in the summary so Mcored can verify origin == local without leaving Discord.

OUTPUT (post to #xerahs as your final message)
A single summary block, in this exact shape:
  ## XerahS Sweep — <YYYY-MM-DD HH:MM AWST> (<your-operator-name>)
  - HEAD: <sha> on develop
  - Branch check: git branch --show-current == develop (yes/no)
  - Area: <one line, with file:line>
  - Status: Fixed | Reviewed (clean) | Reviewed (deferred)
  - Files: <list>
  - Build/test: <counts + log paths>
  - Version: <bump or "no bump">
  - Commit: <sha or "none">
  - Pushed to develop on <your-agent>: yes/no (with ls-remote evidence)
  - next_candidates: <count before> → <count after>; top 3 for next sweep
  - Errors/blockers: <none, or list with file path + log path>
  - Step 10 skill note: <none, or one paragraph>

STOP CONDITIONS
- Sandbox exec silently drops output → do NOT fabricate numbers. Post the partial summary with `Errors/blockers: exec host returned empty for chained commands targeting /Users/mike/Projects/KovaForge/xerahs` and stop. Do not commit.
- Two consecutive build failures on the same area → mark "deferred", commit nothing, push nothing, post the summary anyway.
- `develop` on your wrapper's remote is ahead of `origin/develop` in a way that requires non-fast-forward → STOP and ping Mcored in #xerahs before touching the remote.
- Another agent posts a sweep summary to #xerahs while you are mid-run → STOP, compare HEADs, post which one wins. Do not commit a competing fix to the same finding.
- Pre-flight check #2 fails (your wrapper's remote is missing in `git remote -v`) → do NOT use a different agent's remote, do NOT use `origin`, do NOT add a remote yourself. Post the failing check to #xerahs and STOP.
- You create a new branch, worktree, or push a non-`develop` ref (including `aoife/master`, `vladislava/develop`, or any personal integration branch) at any point (caught or uncaught) → STOP. Undo the local branch (`git branch -D <new-branch>`) without pushing it. If you already pushed a non-`develop` ref by accident, ping Mcored immediately and DO NOT touch the remote again until told to. Post the offending command and the offending ref name in `Errors/blockers`.
- You find yourself wanting to do work that requires a branch you don't have → STOP. Re-read the branch-discipline rule at the top of this prompt. The work fits on `develop` or it is out of scope for this sweep.

Begin by reading the SKILL.md, then `git-<your-wrapper> fetch --all` to confirm where `develop` actually is. Post a one-line "starting, HEAD = <sha>, branch = develop" to #xerahs so Mcored sees you moving.
```

# Notes

- **Origin.** First used 2026-07-07 to run Declan's review sweep at Mcored's request (`#xerahs` message 1524013641802977393, four-part follow-up chain ending at 1524013654377234494). That run produced `f38372f2` — FileDownloader early-EOF path, Reviewed (clean), no version bump.
- **Version 4 (2026-07-11).** Mcored's directive: "this prompt doesnt require placeholders." Removed every `[SCREAMING_SNAKE]` operational token. Hardcoded the repo path to `/Users/mike/Projects/KovaForge/xerahs` and the branch to `develop`. Operator identity (name, wrapper, remote) is now discovered at run time via `git-<your-wrapper> whoami` rather than filled in. Skill path is no longer a placeholder either — the prompt names the skill (`xerahs-hourly-sweep`) and tells the operator to read its SKILL.md wherever the consolidation note currently puts it. Picking rules reference the live state file (`next_candidates`, `last_runs`, `areas[].last_outcome`) instead of fixed slots. Branch discipline now explicitly forbids `aoife/master` and any personal integration branch. Frontmatter `version: 3 → 4`; `last-used: 2026-07-11` (revision date, not a sweep run — update again on the next actual sweep).
- **Version 3 (2026-07-09).** One clarification added after Mcored's follow-up: "the prompt must prevent any agent creating a branch to undertake the works and work on the existing develop branch." The branch discipline is now (a) a top-level hard rule in the intro, (b) covered in pre-flight checks #4 (local `develop` exists with upstream tracking on the wrapper's remote) and #5 (operator is sitting on it before any edit), (c) restated in the WORKSPACE block of the prompt body, (d) a DISCIPLINE bullet forbidding new branches, worktrees, detached HEAD, or synthetic rebase, (e) a self-check #0 before any commit (`git branch --show-current` MUST equal `develop`), (f) a new line in the OUTPUT summary template so Mcored sees the branch check pass, and (g) two STOP CONDITIONS covering accidental branch creation and wanting-a-branch-you-don't-have. The rule itself already lives upstream in the XerahS root `AGENTS.md` and the BriarForge parent `AGENTS.md`; this version just makes it impossible to soft-pedal inside the sweep.
- **Version 2 (2026-07-09).** Three clarifications added after the 2026-07-08 run cycle:
  1. **Pre-flight check section.** A previous run had a false "no vladislava remote" blocker raised in #xerahs; in fact all six agent remotes are pre-configured in the XerahS repo. The pre-flight check makes the operator verify their wrapper + remote exist before starting, so nobody wastes a turn posting a wrong blocker or, worse, committing under a different identity.
  2. **Who-runs-this rule.** Mcored told the analyst to run it; the cron operator picked it up anyway and started in parallel. The "Who runs this prompt" intro now names the dispatch protocol so a third agent doesn't race on `hourly_review_state.json`.
  3. **Pre-existing failures source.** Explicit instruction to pull the pre-existing-failures list from the most recent `last_runs[].result` and `areas[].last_outcome` lines instead of pasting from prior summaries (which may be stale by several runs).
- **Cadence.** The skill folder is `xerahs-hourly-sweep` and the state file is `docs/reports/hourly_review_state.json`, but the actual cadence is whatever you decide — runs are scheduled on demand, not strictly every hour. Do not rename those files; just don't promise a 1h cadence in the prompt itself.
- **Agent-agnostic by design.** This prompt is not a fill-in template. It is fixed at the level Mcored cares about (repo path + branch) and runtime-resolved at the level that genuinely varies per operator (identity + wrapper + remote). Valid wrappers: `git-aoife`, `git-declan`, `git-mikhail`, `git-milena`, `git-nadia`, `git-vladislava`. All six agents have remotes in the XerahS repo — confirmed 2026-07-08: `aoife`, `declan`, `mikhail`, `milena`, `nadia`, `vladislava`, all with SSH keys and matching remotes (`git@github-<agent>:KovaForge/XerahS.git`). The wrapper identity (`git-<agent>`) maps to the remote (`<agent>`) deterministically; if your wrapper's `REMOTE=` does not match a remote in the repo, something is misconfigured upstream, not in the repo.
- **When to update.** Bump the prompt's `version` whenever the procedure changes (e.g. skill consolidation, new Step 3.5 sub-step, output format change). Update `last-used` each time you actually run a sweep from it (not on prompt-only edits).
- **SKILL.md path is the volatile one.** The skill has moved across PRs in KovaForge/openclaw-config. Always read whatever SKILL.md the current consolidation note points to instead of trusting any path you remember.
- **Do not commit under the wrong wrapper.** The `prompts/` repo is owned by `git-aoife`'s remote; this file is committed via `git-aoife` because that's the configured push remote for the repo. For the XerahS repo itself, always use the operator's own wrapper (`git-aoife`, `git-declan`, `git-mikhail`, `git-milena`, `git-nadia`, `git-vladislava`) — never bare `git push`, never cross-identity.