---
tags: [xerahs, hourly-sweep, code-review, agent-agnostic]
category: coding
version: 1
last-used: 2026-07-07
---

# XerahS Hourly Sweep Prompt (agent-agnostic)

Launch the XerahS hourly-review sweep via the `xerahs-hourly-sweep` skill, scoped to a single area, with a clear primary target and ranked fallbacks. The prompt is parameterized so any per-person git wrapper can drive it.

## Placeholders to fill before sending

- `[AGENT_NAME]` — operator display name (e.g. `Declan Murphy`, `Milena Petrova`, `Nadia Valeva`)
- `[GIT_WRAPPER]` — operator's per-person wrapper (e.g. `git-declan`, `git-milena`, `git-nadia`)
- `[AGENT_REMOTE]` — matching remote name (e.g. `declan`, `milena`, `nadia`)
- `[AGENT_BRANCH]` — operator's working branch (typically `[AGENT_REMOTE]/develop`)
- `[CURRENT_VERSION]` — current version in `Directory.Build.props` (e.g. `0.23.127`)
- `[NEXT_VERSION]` — patch+1 of `[CURRENT_VERSION]` (e.g. `0.23.128`)
- `[PRIOR_FIX_NOTE]` — one-line note describing the most recent prior fix (area + commit + version) so the agent does not re-do it
- `[PRIMARY_INDEX]` / `[PRIMARY_SUMMARY]` / `[PRIMARY_FILE_HINT]` — top pick from `next_candidates`
- `[FALLBACK_1_INDEX]` / `[FALLBACK_1_SUMMARY]` / `[FALLBACK_1_NOTE]` — second pick
- `[FALLBACK_2_INDEX]` / `[FALLBACK_2_SUMMARY]` / `[FALLBACK_2_NOTE]` — third pick
- `[PRE_EXISTING_FAILURES]` — bullet list of unrelated, pre-existing test failures to document but not touch
- `[SKILL_PATH]` — canonical path to the skill's `SKILL.md` (verify with the repo's current consolidation note)
- `[REPO_PATH]` — local clone of the XerahS repo (typically `/Users/mike/Projects/KovaForge/xerahs`)
- `[STATE_JSON]` — `docs/reports/hourly_review_state.json` inside `[REPO_PATH]`
- `[TRACKER_MD]` — `docs/reports/hourly_review_tracker.md` inside `[REPO_PATH]`

## Prompt

```text
You are [AGENT_NAME] running the XerahS hourly-review sweep. Use the `xerahs-hourly-sweep` skill as your procedure; do not invent steps.

WORKSPACE
- Repo:   [REPO_PATH]
- Git:    use `[GIT_WRAPPER]` (NOT raw git) for every commit, fetch, push, and ls-remote. It pins you to NAME="[AGENT_NAME]", REMOTE="[AGENT_REMOTE]", SSH_HOST="github-[AGENT_REMOTE]". Verify with `[GIT_WRAPPER] whoami` before touching anything.
- Skill:  read [SKILL_PATH] FIRST, end to end. Treat any consolidation note in that file as authoritative for the canonical path.
- State:  [STATE_JSON]
- Tracker:[TRACKER_MD]

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
- Step 3.5 clawpatch ingest runs the skill's global dedupe — let it run, do not skip.
- Atomic commit: one commit per fix containing code + version bump + state JSON update + tracker entry. No multi-commit fixes. Push via `[GIT_WRAPPER] push` (not raw git).
- Version bump in Directory.Build.props: [CURRENT_VERSION] → [NEXT_VERSION] (or patch+1 from current HEAD if HEAD has moved).
- Do NOT `[GIT_WRAPPER] push --force` under any circumstance. If [AGENT_BRANCH] is behind, fetch + rebase or fast-forward only.
- Step 10: only emit a skill-improvement note if you hit a real efficiency blocker (loop, duplicate effort, dead branch). Do not force it.

SELF-CHECK BEFORE COMMITTING
1. Build: `dotnet build --configuration Release -m:1` scoped to the touched csproj if the full solution times out at 60 s. Capture the log to /tmp/xerahs-review/build-<yyyymmdd>-<hhmmss>.log.
2. Tests: `dotnet test --filter "FullyQualifiedName~<TouchedArea>"` first; if green, run full XerahS.Tests. Record counts (passed/failed/skipped). Pre-existing failures must NOT be counted against your fix.
3. `[GIT_WRAPPER] ls-remote [AGENT_REMOTE] [AGENT_BRANCH]` and `[GIT_WRAPPER] rev-parse HEAD` — paste both in the summary so Mcored can verify origin == local without leaving Discord.

OUTPUT (post to #xerahs as your final message)
A single summary block, in this exact shape:
  ## XerahS Hourly Sweep — <YYYY-MM-DD HH:MM AWST> ([AGENT_NAME])
  - HEAD: <sha> on [AGENT_BRANCH]
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

Begin by reading the SKILL.md, then `[GIT_WRAPPER] fetch --all` to confirm where [AGENT_BRANCH] actually is. Post a one-line "starting, HEAD = <sha>" to #xerahs so Mcored sees you moving.
```

# Notes

- **Origin.** First used 2026-07-07 to run Declan's hourly sweep at Mcored's request (`#xerahs` message 1524013641802977393, four-part follow-up chain ending at 1524013654377234494). That run produced `f38372f2` — FileDownloader early-EOF path, Reviewed (clean), no version bump.
- **Agent-agnostic by design.** The hardcoded `git-declan` references from the original were replaced with `[GIT_WRAPPER]` / `[AGENT_BRANCH]` / `[AGENT_REMOTE]` placeholders, per Mcored's 2026-07-06 directive: "The skill should be runnable by any agent... if Milena runs it, `git-milena` can git commit, if Nadia runs it then `git-nadia` can git commit." The same template now drives any wrapper.
- **When to update.** Bump the prompt's `version` whenever the procedure changes (e.g. skill consolidation, new Step 3.5 sub-step, output format change). Update `last-used` each time you actually run a sweep from it.
- **Tunables per run.** The three pick slots (primary + two fallbacks) are the variables that change most often. Pull them from the current top of `next_candidates` and confirm against the SKILL.md pick rules before pasting into the prompt body.
- **SKILL.md path is the volatile one.** Verify `[SKILL_PATH]` against the skill's current consolidation note before each run; KovaForge/openclaw-config has moved it across PRs.
- **Do not commit under the wrong wrapper.** The `prompts/` repo is owned by `git-aoife`'s remote; this file is committed via `git-aoife` because that's the configured push remote for the repo. For the XerahS repo itself, always use the operator's own wrapper (`git-declan`, `git-milena`, `git-nadia`, etc.) — never bare `git push`, never cross-identity.
