---
tags: [sharex, loop, cross-platform, agent-agnostic, reusable]
category: coding
version: 2
last-used: 2026-11-04
---

# ShareX cross-platform loop prompt

One slice per run, adapted from `coding/xerahs/xerahs-loop.md`. Any agent CLI can run it repeatedly, or a scheduler can resume one session and inject it again. Example:
`while true; do claude -p "$(cat <this-file>)"; grep -q "waiting on Mike" ~/.local/state/sharex-loop/STATE.md && break; done`

````markdown
You are one iteration of a loop that keeps ShareX's `cross-platform` branch complete on Windows, Linux and macOS and up to date with `develop`. Do exactly ONE coherent slice per iteration: claim it, build it, review it, test it, push it, record it, release the claim, exit. If this session was resumed, keep the context you have; do not redo a finished slice. The files below are the source of truth.

## Paths
| What | Path |
|---|---|
| Repository and branch | `/home/mike/Work/ShareX/ShareX`, branch `cross-platform` (ShareX/ShareX) |
| Rules | `<repo>/AGENTS.md` (architecture, scope, forbidden code in shared projects) |
| Progress | `<repo>/README.md` (cross-platform section), `<repo>/docs/cross-platform-roadmap.md` |
| Architecture | `<repo>/docs/cross-platform.md` |
| Real-Mac test procedures and reports | `<repo>/docs/<yyyymmdd>-macos-*.md`; reports arrive in `~/Downloads/<yyyymmdd>-macos-*-report.md` |
| Upstream to keep merged | `origin/develop` (Jaex's releases; he no longer works on `cross-platform`) |
| Loop state: backlog, blocked, done, claims | `~/.local/state/sharex-loop/STATE.md` |
| Iteration log, one line per push | `~/.local/state/sharex-loop/progress.log` |
| Push gate | `~/.local/state/sharex-loop/gated-push.sh <repo> <agent>` |
| Decision log (append-only TSV) | `~/.local/state/sharex-loop/decisions.tsv`, append with `~/.local/state/sharex-loop/log.sh <log> <phase> <decision> <why> <evidence> <result>` |
| Engineering method | the `pstack-engineering` skill (`~/.claude/skills/pstack-engineering`, also linked for Codex, Hermes and OpenClaw): playbooks in `references/playbooks/`, principles in `references/principles/` |
| Workspace rules | `/home/mike/Work/AGENTS.md` |

## Each iteration
1. **Sync.** `git -C <repo> fetch -q`, check `git status -sb`. If there are uncommitted changes you did not make, read them and the claims before touching anything; never discard someone else's work. Then `git pull --rebase`.
2. **Upstream first.** If `git log --oneline HEAD..origin/develop` is not empty, the slice is merging `develop`: keep both sides of every conflict, and move any new Windows-only code (P/Invoke, COM, WinRT, Vortice, registry, GDI+, `OperatingSystem.Is…` branches) behind a `ShareX.Platform` service implemented in `ShareX.Platform.Windows`, with reasoned `NotSupported` stubs or real implementations on Linux and macOS.
3. **Read the state.** Read `STATE.md` and the last rows of `decisions.tsv`. If this run adds to rows another run wrote, log a `start` row first (see the skill's `references/decision-log.md`). If it is missing or the backlog is stale, rebuild it from the README, the roadmap, open macOS report findings and `git log`, and make that the slice.
4. **Claim.** Take the top unclaimed backlog item small enough for one iteration that does not overlap another claim. Add `- <agent> <ISO time>: <slice> | files: <globs>` under `## Claims`. Claims older than 6 hours are stale.
5. **Build with a pstack playbook.** Pick the one that fits the slice and read it: a macOS or Linux report finding is **bug-fix** (reproduce, root cause, regression test that fails first); a new platform service or capability is **feature** (settle the contract and data shape first); moving code behind `ShareX.Platform` or merging `develop` is **refactoring** (pin behaviour with tests, migrate callers, then delete the old path); a question is **investigation**. Read only the principles the playbook names. Follow AGENTS.md: OS behaviour only through `PlatformServices.Current`; Windows behaves as `develop`; Linux and macOS get every feature their system supports; optional programs are detected at run time, never bundled or installed.
6. **Verify, then self-review.** Run the skill's **verification** playbook against the real artifact: native code is exercised against the real library or window (a probe, or an opt-in test such as `SHAREX_GSTREAMER_WINDOW_TEST=1`), not only compiled; say plainly what could not be checked (a real Mac, a Windows desktop). Then read your whole diff as a stranger. Risky areas: untrusted input, writes (atomic, never truncate before success), threads and native callbacks (UI thread only, nothing late into a disposed owner), persisted settings (old files load), secrets (never plain text). For every bug you fix, add a regression test and check it fails without the fix.
7. **Commit.** Subject in plain English (what users can now do). Body: what changed, what remains. End with your agent's trailer.
8. **Push** only through `gated-push.sh`. On a rebase conflict, resolve every hunk deliberately and rerun. Never force-push or rewrite pushed history.
9. **Record.** Log the slice's decisions to `decisions.tsv` (forks, pivots, verification results, each with an evidence pointer) and audit them against what happened; append `<ISO time> <agent> <hash> <slice> | tests N` to `progress.log`; turn any lesson into structure (a test, an AGENTS.md rule, a line in `docs/cross-platform-learnings.md`); move the item to `## Done`; add new work or blockers to `STATE.md`; update the README progress section when a system's status changes. Exit.

## Rules
- Never send real user data to third-party upload services; test uploads against a local HTTP server.
- ShareX and XerahS are different apps; never install one over the other. Do not change the desktop or compositor configuration.
- Root goes through one `pkexec` (see the workspace AGENTS.md), never `sudo`.
- Do not drive GUI automation on Mike's live desktop while he uses it.
- Anything that needs a real Mac, Apple credentials, a release decision or a new dependency goes under `## Blocked on Mike` with the exact question.

## Stop condition
If `## Backlog` holds only blocked items or items needing a live desktop or a Mac, write `## Loop status: waiting on Mike` at the top of `STATE.md` with the list, make no code changes, and exit.
````

# Notes
- State lives outside the repo so several agent loops can share it.
- The gate builds `ShareX.sln -c Release -p:Platform=x64` with no warnings allowed and runs the five test projects, rerunning a failing project once.
