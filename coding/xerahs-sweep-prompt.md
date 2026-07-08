---
tags: [xerahs, sweep, code-review, agent-agnostic]
category: coding
version: 3
last-used: 2026-07-07
---

# XerahS Sweep Prompt (agent-agnostic)

Launch a XerahS review sweep via the `xerahs-hourly-sweep` skill, scoped to a single area, with a clear primary target and ranked fallbacks. The prompt is parameterized so any per-person git wrapper can drive it, and the cadence is whatever the operator wants — the skill folder is named `hourly-sweep` but in practice runs happen on demand (e.g. 22h gap between the 2026-07-06 21:18 and 2026-07-07 19:35 AWST sweeps).

**Who runs this prompt.** Mcored names the operator in his request message. That operator drives end-to-end and posts the sweep summary. Other agents should not start a parallel sweep on the same state file — they would race on `hourly_review_state.json` updates. If Mcored has not named you, do not pick up unilaterally; either ask in #xerahs or wait for a direct ping.

**Branch discipline (hard rule, no exceptions).** All work happens on the existing `[AGENT_BRANCH]` (typically `[AGENT_REMOTE]/develop`, the long-lived per-agent integration branch). The operator MUST NOT create a new branch, worktree, or fork scope for this sweep. No `git checkout -b`, no `git switch -c`, no `git worktree add`, no `git push origin HEAD:<new-branch>`. If you find yourself wanting a branch you don't have, you are misreading the prompt — re-read this section and use the existing `[AGENT_BRANCH]`. The same rule applies to investigation work: use local scratch files under `/tmp/xerahs-review/` and the agent's local stash, not git branches. This rule comes from the XerahS root `AGENTS.md` ("do not create branches or GitHub issues unless asked") and from the BriarForge parent `AGENTS.md` ("No creating branches without explicit permission"); both are upstream of this file and override anything in this prompt that conflicts with them.

## Pre-flight check (run BEFORE you fill any placeholders)

Do not start a sweep until every line below is green. If any check fails, STOP and post to #xerahs with the failing line — do not improvise.

1. `[GIT_WRAPPER] whoami` returns `NAME="[AGENT_NAME]" EMAIL="<id>+<handle>-<suffix>@users.noreply.github.com" push remote: [AGENT_REMOTE] (git@github-[AGENT_REMOTE]:KovaForge/XerahS.git)`.
2. From inside `[REPO_PATH]`, `git remote -v` shows `[AGENT_REMOTE]	git@github-[AGENT_REMOTE]:KovaForge/XerahS.git (fetch)` AND `(push)`. All six agents (`aoife`, `declan`, `mikhail`, `milena`, `nadia`, `vladislava`) have their own SSH key and their own remote in this repo. If your `[AGENT_REMOTE]` is missing, your SSH key was not added to GitHub yet — STOP and ping Mcored; do not commit under a different identity.
3. `[GIT_WRAPPER] ls-remote [AGENT_REMOTE] [AGENT_BRANCH]` returns a real SHA (not empty / not "could not read").
4. `[AGENT_BRANCH]` exists as a tracking branch locally: `git branch --list [AGENT_REMOTE]/[AGENT_BRANCH]` is non-empty. If only the remote-tracking ref exists, run `[GIT_WRAPPER] fetch [AGENT_REMOTE] [AGENT_REMOTE]/[AGENT_BRANCH]:[AGENT_REMOTE]/[AGENT_BRANCH]` to materialize the local tracking branch. Do NOT create a new branch with `-b` or `-c`. If the branch does not exist on the remote at all for some reason, STOP and ping Mcored.
5. You are sitting on `[AGENT_BRANCH]` before any edit: `git branch --show-current` must equal `[AGENT_BRANCH]` (the local tracking form, e.g. `vladislava/develop`). If you are on `main`, on `HEAD` detached, or on any other ref, run `[GIT_WRAPPER] checkout [AGENT_BRANCH]` first. Never `checkout -b`, never `switch -c`.
6. `[SKILL_PATH]` exists. Read it end to end before touching anything else.
7. `next_candidates` in `[STATE_JSON]` is non-empty. If it is empty, the sweep queue is exhausted; STOP and ping Mcored.
8. No other agent has posted a "starting, HEAD = <sha>" to #xerahs in the last 30 minutes. If someone did, ping them in-thread to confirm whether they finished or stalled before you start.

## Placeholders to fill before sending

Fill these AFTER the pre-flight check passes.

- `[AGENT_NAME]` — operator display name. Current canonical names: `Vladislava Kova`, `Declan Murphy`, `Mikhail Orlov`, `Milena Petrova`, `Nadia Valeva`, `Aoife Brennan`. Use exactly one of these — not a short form.
- `[GIT_WRAPPER]` — operator's per-person wrapper (e.g. `git-vladislava`, `git-declan`, `git-milena`, `git-nadia`).
- `[AGENT_REMOTE]` — matching remote name (e.g. `vladislava`, `declan`, `milena`, `nadia`). Must match the wrapper's `REMOTE=` value (run `[GIT_WRAPPER] whoami`).
- `[AGENT_BRANCH]` — operator's existing working branch (typically `[AGENT_REMOTE]/develop`). Verify with `git branch -r | grep [AGENT_REMOTE]/[AGENT_BRANCH_BASE]`. This branch already exists on the remote; you check it out, you do not create it. If the branch does not exist yet on the remote for some reason, STOP and ping Mcored — do not create it yourself.
- `[CURRENT_VERSION]` — current version in `Directory.Build.props` (e.g. `0.23.127`). Read the file; do not guess.
- `[NEXT_VERSION]` — patch+1 of `[CURRENT_VERSION]` (e.g. `0.23.128`).
- `[PRIOR_FIX_NOTE]` — one-line note describing the most recent prior fix (area + commit + version) so the agent does not re-do it.
- `[PRIMARY_INDEX]` / `[PRIMARY_SUMMARY]` / `[PRIMARY_FILE_HINT]` — top pick from `next_candidates`. PRIMARY_FILE_HINT may be empty if the finding has no obvious file — say so explicitly rather than guessing.
- `[FALLBACK_1_INDEX]` / `[FALLBACK_1_SUMMARY]` / `[FALLBACK_1_NOTE]` — second pick.
- `[FALLBACK_2_INDEX]` / `[FALLBACK_2_SUMMARY]` / `[FALLBACK_2_NOTE]` — third pick.
- `[PRE_EXISTING_FAILURES]` — bullet list of unrelated, pre-existing test failures to document but not touch. Pull from the most recent `last_runs` entry's `result` field and the current `areas[].last_outcome` lines.
- `[SKILL_PATH]` — canonical path to the skill's `SKILL.md`. Verify against the skill's current consolidation note; KovaForge/openclaw-config has moved it across PRs.
- `[REPO_PATH]` — local clone of the XerahS repo (typically `/Users/mike/Projects/KovaForge/xerahs`).
- `[STATE_JSON]` — `docs/reports/hourly_review_state.json` inside `[REPO_PATH]`.
- `[TRACKER_MD]` — `docs/reports/hourly_review_tracker.md` inside `[REPO_PATH]`.

## Prompt

Only send the body below to the operator AFTER the pre-flight check is fully green and all placeholders above are filled.

```text
You are [AGENT_NAME] running a XerahS review sweep. Use the `xerahs-hourly-sweep` skill as your procedure; do not invent steps.

WORKSPACE
- Repo:   [REPO_PATH]
- Git:    use `[GIT_WRAPPER]` (NOT raw git) for every commit, fetch, push, and ls-remote. It pins you to NAME="[AGENT_NAME]", REMOTE="[AGENT_REMOTE]", SSH_HOST="github-[AGENT_REMOTE]". If `[GIT_WRAPPER] whoami` does not show `[AGENT_REMOTE]` as the push remote, STOP — you are in the wrong repo or the wrapper is misconfigured. Bare `git` will leak the host user.email and push to the wrong remote; never use it.
- Skill:  read [SKILL_PATH] FIRST, end to end. Treat any consolidation note in that file as authoritative for the canonical path.
- State:  [STATE_JSON]
- Tracker:[TRACKER_MD]
- Branch:  ALL work happens on the already-existing `[AGENT_BRANCH]`. You MUST NOT create a new branch, worktree, or fork scope for this sweep. No `git checkout -b`, no `git switch -c`, no `git worktree add`, no `git push origin HEAD:<new-branch>`. If you are not already on `[AGENT_BRANCH]` (verified by `git branch --show-current`), `[GIT_WRAPPER] checkout [AGENT_BRANCH]` and only then continue.

DO NOT RE-DO
- [PRIOR_FIX_NOTE]. Skip it even if next_candidates still lists it.
- Any area flagged "deferred, recent churn" by the most recent two sweeps — re-flag and move on.
- The pre-existing test failures unrelated to any single area:
  [PRE_EXISTING_FAILURES]
  Document them in the summary; do NOT touch them in this run. They have their own XIP.

PICK (in this priority)
Primary target — finding index [PRIMARY_INDEX] in next_candidates:
  "[PRIMARY_SUMMARY]"
  - Likely file: [PRIMARY_FILE_HINT]
  - Why now: [PRIOR_FIX_NOTE]. The new finding is a related but distinct facet — read the previous fix first so you do not regress it.
  - Success shape: a regression test that covers the new facet without throwing on the old path, plus the smallest code change that surfaces the new symptom correctly.

Fallback if primary is clean or already covered:
  - Index [FALLBACK_1_INDEX] "[FALLBACK_1_SUMMARY]" — [FALLBACK_1_NOTE]
  - Index [FALLBACK_2_INDEX] "[FALLBACK_2_SUMMARY]" — [FALLBACK_2_NOTE]

DISCIPLINE
- Stay on `[AGENT_BRANCH]` for the entire sweep. Do not create a new branch off it. Do not detach HEAD. Do not `rebase --onto` to a synthetic base. If you need parallel investigation, use the agent's local stash / scratch files under `/tmp/xerahs-review/`, not git branches.
- Step 3.5 clawpatch ingest runs the skill's global dedupe — let it run, do not skip.
- Atomic commit: one commit per fix containing code + version bump + state JSON update + tracker entry. No multi-commit fixes. Push via `[GIT_WRAPPER] push` (not raw git).
- Version bump in Directory.Build.props: [CURRENT_VERSION] → [NEXT_VERSION] (or patch+1 from current HEAD if HEAD has moved).
- Do NOT `[GIT_WRAPPER] push --force` under any circumstance. If [AGENT_BRANCH] is behind, fetch + rebase or fast-forward only.
- Step 10: only emit a skill-improvement note if you hit a real efficiency blocker (loop, duplicate effort, dead branch). Do not force it.

SELF-CHECK BEFORE COMMITTING
0. Branch: `git branch --show-current` MUST equal `[AGENT_BRANCH]` (the local tracking form, e.g. `vladislava/develop`). If it does not, STOP. Do not commit on a different branch, do not cherry-pick the changes onto `[AGENT_BRANCH]` to "fix" the situation, just stop and ping Mcored.
1. Build: `dotnet build --configuration Release -m:1` scoped to the touched csproj if the full solution times out at 60 s. Capture the log to /tmp/xerahs-review/build-<yyyymmdd>-<hhmmss>.log.
2. Tests: `dotnet test --filter "FullyQualifiedName~<TouchedArea>"` first; if green, run full XerahS.Tests. Record counts (passed/failed/skipped). Pre-existing failures must NOT be counted against your fix.
3. `[GIT_WRAPPER] ls-remote [AGENT_REMOTE] [AGENT_BRANCH]` and `[GIT_WRAPPER] rev-parse HEAD` — paste both in the summary so Mcored can verify origin == local without leaving Discord.

OUTPUT (post to #xerahs as your final message)
A single summary block, in this exact shape:
  ## XerahS Sweep — <YYYY-MM-DD HH:MM AWST> ([AGENT_NAME])
  - HEAD: <sha> on [AGENT_BRANCH]
  - Branch check: git branch --show-current == [AGENT_BRANCH] (yes/no)
  - Area: <one line, with file:line>
  - Status: Fixed | Reviewed (clean) | Reviewed (deferred)
  - Files: <list>
  - Build/test: <counts + log paths>
  - Version: <bump or "no bump">
  - Commit: <sha or "none">
  - Pushed to [AGENT_BRANCH]: yes/no (with ls-remote evidence)
  - next_candidates: <count before> → <count after>; top 3 for next sweep
  - Errors/blockers: <none, or list with file path + log path>
  - Step 10 skill note: <none, or one paragraph>

STOP CONDITIONS
- Sandbox exec silently drops output → do NOT fabricate numbers. Post the partial summary with `Errors/blockers: exec host returned empty for chained commands targeting [REPO_PATH]` and stop. Do not commit.
- Two consecutive build failures on the same area → mark "deferred", commit nothing, push nothing, post the summary anyway.
- `[AGENT_BRANCH]` is ahead of `origin/develop` in a way that requires non-fast-forward → STOP and ping Mcored in #xerahs before touching the remote.
- Another agent posts a sweep summary to #xerahs while you are mid-run → STOP, compare HEADs, post which one wins. Do not commit a competing fix to the same finding.
- Pre-flight check #2 fails (your `[AGENT_REMOTE]` is missing in `git remote -v`) → do NOT use a different agent's remote, do NOT use `origin`, do NOT add a remote yourself. Post the failing check to #xerahs and STOP.
- You create a new branch, worktree, or push a non-`[AGENT_BRANCH]` ref at any point (caught or uncaught) → STOP. Undo the local branch (`git branch -D <new-branch>`) without pushing it. If you already pushed a non-`[AGENT_REMOTE]`/non-`[AGENT_BRANCH]` ref by accident, ping Mcored immediately and DO NOT touch the remote again until told to. Post the offending command and the offending ref name in `Errors/blockers`.
- You find yourself wanting to do work that requires a branch you don't have → STOP. Re-read the branch-discipline rule at the top of this prompt. The work fits on `[AGENT_BRANCH]` or it is out of scope for this sweep.

Begin by reading the SKILL.md, then `[GIT_WRAPPER] fetch --all` to confirm where [AGENT_BRANCH] actually is. Post a one-line "starting, HEAD = <sha>, branch = [AGENT_BRANCH]" to #xerahs so Mcored sees you moving.
```

# Notes

- **Origin.** First used 2026-07-07 to run Declan's review sweep at Mcored's request (`#xerahs` message 1524013641802977393, four-part follow-up chain ending at 1524013654377234494). That run produced `f38372f2` — FileDownloader early-EOF path, Reviewed (clean), no version bump.
- **Version 3 (2026-07-09).** One clarification added after Mcored's follow-up: "the prompt must prevent any agent creating a branch to undertake the works and work on the existing develop branch." The branch discipline is now (a) a top-level hard rule in the intro, (b) covered in pre-flight checks #4 (local tracking branch exists) and #5 (operator is sitting on it before any edit), (c) restated in the WORKSPACE block of the prompt body, (d) a DISCIPLINE bullet forbidding new branches, worktrees, detached HEAD, or synthetic rebase, (e) a self-check #0 before any commit (`git branch --show-current` MUST equal `[AGENT_BRANCH]`), (f) a new line in the OUTPUT summary template so Mcored sees the branch check pass, and (g) two STOP CONDITIONS covering accidental branch creation and wanting-a-branch-you-don't-have. The rule itself already lives upstream in the XerahS root `AGENTS.md` and the BriarForge parent `AGENTS.md`; this version just makes it impossible to soft-pedal inside the sweep.
- **Version 2 (2026-07-09).** Three clarifications added after the 2026-07-08 run cycle:
  1. **Pre-flight check section.** A previous run had a false "no vladislava remote" blocker raised in #xerahs; in fact all six agent remotes are pre-configured in the XerahS repo. The pre-flight check makes the operator verify their wrapper + remote exist before starting, so nobody wastes a turn posting a wrong blocker or, worse, committing under a different identity.
  2. **Who-runs-this rule.** Mcored told the analyst to run it; the cron operator picked it up anyway and started in parallel. The "Who runs this prompt" intro now names the dispatch protocol so a third agent doesn't race on `hourly_review_state.json`.
  3. **Pre-existing failures source.** Explicit instruction to pull the pre-existing-failures list from the most recent `last_runs[].result` and `areas[].last_outcome` lines instead of pasting from prior summaries (which may be stale by several runs).
- **Cadence.** The skill folder is `xerahs-hourly-sweep` and the state file is `docs/reports/hourly_review_state.json`, but the actual cadence is whatever you decide — runs are scheduled on demand, not strictly every hour. Do not rename those files; just don't promise a 1h cadence in the prompt itself.
- **Agent-agnostic by design.** The hardcoded `git-declan` references from the original were replaced with `[GIT_WRAPPER]` / `[AGENT_BRANCH]` / `[AGENT_REMOTE]` placeholders, per Mcored's 2026-07-06 directive: "The skill should be runnable by any agent... if Milena runs it, `git-milena` can git commit, if Nadia runs it then `git-nadia` can git commit." The same template now drives any wrapper. `git-vladislava` is also a valid wrapper; she was added to the canonical-names list in version 2 after the 2026-07-08 run.
- **All six agents have remotes in the XerahS repo.** Confirmed 2026-07-08: `aoife`, `declan`, `mikhail`, `milena`, `nadia`, `vladislava` — all have SSH keys and matching remotes (`git@github-<agent>:KovaForge/XerahS.git`). The wrapper identity (`git-<agent>`) maps to the remote (`<agent>`) deterministically; if your wrapper's `REMOTE=` does not match a remote in the repo, something is misconfigured upstream, not in the repo.
- **When to update.** Bump the prompt's `version` whenever the procedure changes (e.g. skill consolidation, new Step 3.5 sub-step, output format change). Update `last-used` each time you actually run a sweep from it.
- **Tunables per run.** The three pick slots (primary + two fallbacks) are the variables that change most often. Pull them from the current top of `next_candidates` and confirm against the SKILL.md pick rules before pasting into the prompt body.
- **SKILL.md path is the volatile one.** Verify `[SKILL_PATH]` against the skill's current consolidation note before each run; KovaForge/openclaw-config has moved it across PRs.
- **Do not commit under the wrong wrapper.** The `prompts/` repo is owned by `git-aoife`'s remote; this file is committed via `git-aoife` because that's the configured push remote for the repo. For the XerahS repo itself, always use the operator's own wrapper (`git-declan`, `git-milena`, `git-nadia`, `git-vladislava`, etc.) — never bare `git push`, never cross-identity.
