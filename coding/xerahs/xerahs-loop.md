---
tags: [xerahs, loop, agent-agnostic, codex, claude, minimax, grok, reusable]
category: coding
version: 1
last-used: 2026-10-24
---

# XerahS loop prompt (agent-agnostic)

One slice per run; any agent CLI can run it repeatedly. Example:
`while true; do codex exec -C /home/mike/Work/BriarForge/XerahS --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check - < <this-file>; grep -q "waiting on Mike" ~/.local/state/xerahs-loop/STATE.md && break; done`

````markdown
You are one iteration of a loop that keeps building native XerahS until the English Product Contract is fully implemented on Linux. You may be Codex, Claude, MiniMax Code, Grok or another agent CLI. Do exactly ONE coherent slice per iteration: claim it, build it, review it, test it, push it, record it, release the claim, exit. The next iteration starts fresh and reads only the files below, so leave the state file accurate.

## Paths
| What | Path |
|---|---|
| Repository (main checkout, Mike's; never edit it or touch its uncommitted changes) | `/home/mike/Work/BriarForge/XerahS` |
| Your worktree | `/home/mike/Work/BriarForge/XerahS/worktrees/<agent>` (see Identity) |
| Linux app | `<worktree>/platforms/linux/linux-qt` |
| Product Contract (source of truth) | `<worktree>/product-contract/` (`manifest.yaml`, `capabilities/<ID>/SPEC.md`, `SCENARIOS.feature`, vectors) |
| Rules | `<worktree>/AGENTS.md`, `platforms/AGENTS.md`, `platforms/linux/AGENTS.md`, `product-contract/AGENTS.md` |
| Linux status | `<worktree>/platforms/linux/linux-qt/traceability/*.json`, `CONTRACT-AUDIT.md`, `IMPLEMENTATION.md`, `README.md` |
| Behavioural reference (read the source only; never build or run it) | `/home/mike/Work/ShareX/ShareX/` (`ShareX.ImageEditor/`, `ShareX.ImageEffectsLib/`, and so on) |
| Shared loop state (all agents) | `~/.local/state/xerahs-loop/` |
| State file: backlog, done, blocked, claims | `~/.local/state/xerahs-loop/STATE.md` |
| Iteration log, one line per push | `~/.local/state/xerahs-loop/progress.log` |
| Push gate script (create it if missing; text below) | `~/.local/state/xerahs-loop/gated-push.sh` |
| Workspace layout rules | `/home/mike/Work/AGENTS.md` |

## Identity (pick your row; the `XERAHS_AGENT` environment variable overrides)
| Agent CLI | `<agent>` worktree | Git wrapper | Commit trailer |
|---|---|---|---|
| Claude (Opus) | `claude` | `git-aoife` | `Co-Authored-By: Claude <noreply@anthropic.com>` |
| Claude (Sonnet) | `sonnet` | `git-viktor` | `Co-Authored-By: Claude Sonnet <noreply@anthropic.com>` |
| Codex | `codex` | `git-declan` | `Co-Authored-By: Codex <noreply@openai.com>` |
| Grok (grok-4.7 only, never a fast model) | `grok` | `git-sofia` | `Co-Authored-By: Grok <noreply@x.ai>` |
| MiniMax Code (`mcode`) | `minimax` | `git-nadia` | `Co-Authored-By: MiniMax <noreply@minimax.io>` |

- Never use `git-milena`. Push with `git-<name> push <name> HEAD:main`, through the gate only.
- If your wrapper's push is rejected for authentication, follow the McoreD fallback in `/home/mike/Work/AGENTS.md` and say so in the commit message.

## Each iteration
1. **Sync.** If your worktree is missing, create it with `git -C /home/mike/Work/BriarForge/XerahS worktree add --detach worktrees/<agent> origin/main`. `/worktrees/` is already ignored. Then:
   - If the worktree has uncommitted changes from a previous iteration of yours, read `STATE.md` for your claim and finish that slice instead of starting a new one.
   - Otherwise run `git -C <worktree> fetch -q && git -C <worktree> checkout -q --detach origin/main`.
2. **Read the state.** Read `STATE.md`. If it is missing or older than main by more than 20 commits, rebuild the backlog first (step 3) and make that the slice.
3. **Backlog (when rebuilding).**
   - Audit every capability in `manifest.yaml` against the code and tests that exist now. Don't trust old traceability text.
   - Classify each requirement as `implemented` (has an automated test), `partial`, `not-started`, or `blocked: <reason>`.
   - Update `traceability/*.json` honestly and commit them.
   - Write `STATE.md` with sections `## Backlog` (ranked by user value: core user flows first, then breadth, then release gates), `## Blocked on Mike`, `## Done`, `## Claims`.
4. **Claim.** Take the top unclaimed backlog item that is small enough for one iteration and doesn't overlap any other claim (no shared files). Add `- <agent> <ISO time>: <slice> | files: <globs>` under `## Claims`, edit with a short atomic rewrite. Ignore claims older than 6 hours (stale).
5. **Build.** Read the contract requirement text first. Then implement, with tests, following the rules below.
6. **Self-review.** Read your whole diff as if a stranger wrote it. Check:
   - **Risky areas:** untrusted input, writes (atomic, never truncate before success), threads and lifetimes (nothing emitted from destructors, no late callback into a dead owner), persisted state (old files still load, newer ones are never overwritten), secrets.
   - **Bugs:** for every one you find and fix, add a regression test and prove it fails without the fix.
   - **Traceability:** update the matching `traceability/<CAPABILITY>.json` rows in the same commit.
7. **Commit.** `git-<name> commit`. The subject is `[Linux] <what users can now do>`. The body is plain English: what changed, the contract IDs, what remains. End with your trailer.
8. **Push.** Run `~/.local/state/xerahs-loop/gated-push.sh <worktree> <name>`.
   - On a rebase conflict, read every hunk and resolve it deliberately (never blind-delete markers). Then rerun the gate.
   - Never push around the gate.
   - `editor-window-*` tests can flake under load; the gate reruns failures alone. A test that fails twice is real: fix it.
9. **Record.**
   - Append `<ISO time> <agent> <hash> <slice> | tests N` to `progress.log`.
   - Move the item to `## Done` and remove your claim.
   - Add newly discovered work or blockers to `STATE.md`.
   - Exit.

## Rules (every agent, every iteration)
- **The contract decides behaviour.** If it doesn't decide something, add it to `## Blocked on Mike` with the exact question (ROOT-ESCALATE-001). Never edit the contract to fit code. Never derive expected test values from your own implementation.
- **Waiting on Mike; do not build, keep marked blocked:**
  - `remove_background` (needs an approved local model);
  - QR scanning and OCR (zxing-cpp and Tesseract are unapproved dependencies);
  - the scroll alignment threshold value (`kScrollAlignmentThreshold` is a placeholder);
  - human security review of the `.sxie` import and the Secret Service credential store;
  - any release, signing, contract change, waiver or security-posture change.
- **Architecture:**
  - Blocking work starts through `app/OwnedWork.h` only. Never block or nest an event loop on the GUI thread.
  - Private JSON state uses `src/storage/PrivateJsonFile.h`.
  - Secrets go only through `uploads::CredentialStore`, never into JSON, logs, errors or tests.
  - Commands register through `app/CommandRegistry` in an `app/features/*` installer; `main.cpp` gets one line.
  - User-visible failures carry a stable kebab-case code plus plain English.
  - Effects use `Effect.h` and `EffectSupport`: no clamping, seed-only randomness, no duplicated helpers.
- **Foundation, then features, then guards.** No policy docs or audit write-ups without the real feature. Restructure when friction demands it, without changing behaviour (ROOT-IMPROVE-001), and prove it with tests.
- **Dependencies and licence:** no new third-party dependency. GPLv3, with Qt linked dynamically.
- **Build and test** from `platforms/linux/linux-qt`: `cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug && cmake --build build -j8 && ctest --test-dir build -j6 --output-on-failure`. Every test must pass. Never disable or weaken a test.
- **Git:** branch `main` only, pushed from your detached worktree as `HEAD:main`. Never force-push, rewrite history, create branches, bypass hooks, or touch another agent's worktree.

## Loop stop condition
If `## Backlog` contains only blocked items, or items that need a live desktop session to verify, do this:
- write `## Loop status: waiting on Mike` at the top of `STATE.md`, with the list;
- make no code changes;
- exit.

## ~/.local/state/xerahs-loop/gated-push.sh (create if missing, then `chmod +x`)
```bash
#!/usr/bin/env bash
# Pushes HEAD to main only if the rebased tree builds and passes the full suite.
set -euo pipefail
wt=$1; who=$2; mkdir -p ~/.local/state/xerahs-loop; log=~/.local/state/xerahs-loop/gated-$who.log
cd "$wt"
[ -z "$(git status --porcelain --untracked-files=no)" ] || { echo "REFUSED: uncommitted tracked changes"; exit 1; }
git fetch -q origin
git rebase -q origin/main || { echo "REFUSED: rebase conflict; resolve it, then rerun"; exit 1; }
base=$(git rev-parse origin/main)
cd platforms/linux/linux-qt
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug >"$log" 2>&1 || { echo "REFUSED: configure failed"; exit 1; }
cmake --build build -j8 >>"$log" 2>&1 || { echo "REFUSED: build failed"; grep -m5 error "$log"; exit 1; }
if ! ctest --test-dir build -j6 >>"$log" 2>&1; then
  ctest --test-dir build --rerun-failed --output-on-failure >>"$log" 2>&1 || { echo "REFUSED: tests failed on isolated rerun"; exit 1; }
fi
cd "$wt"; git fetch -q origin
[ "$(git rev-parse origin/main)" = "$base" ] || { echo "REFUSED: origin/main moved during testing; rerun"; exit 1; }
"git-$who" push "$who" HEAD:main 2>&1 | tail -1
echo "PUSHED $(git log --format='%h %an %s' -1)"
```
````

# Notes
- Shared state in ~/.local/state/xerahs-loop/ lets several agent loops run side by side without editing the same files.
- Companion prompts: xerahs-multi-agent-orchestrator.md (Opus lead), grok-leads-codex.md, codex-solo is the one-agent variant.
