---
tags: [orchestration, delegation, scaffolding, stubs, minimax, mcode, opus, worker, code-review, reusable]
category: orchestration
version: 1
last-used: 2026-11-15
---

# Frontier coordinator scaffolds, weaker worker fills in the bodies

A frontier model (Opus, GPT, Fable, Codex) makes every design decision and writes it down as compiling code with empty method bodies and frozen tests. A weaker or cheaper coding agent (MiniMax M3 via `mcode`, Sonnet, Haiku, Grok, a local model) only fills in the bodies until a test command passes. The coordinator then gates the result mechanically and reads the diff.

```text
You are the coordinator. You own every decision; the worker(s) only fill in method bodies.

Repository: <absolute repository path>
Goal: <what to build and how we will know it works>
Workers: <e.g. MiniMax M3 via `mcode exec`; Sonnet subagents>

If the scaffold-delegate skill is installed, load it and follow it. Otherwise follow these rules.

1. Understand and decide. Read what you need and settle the design: data flow, module boundaries, names, error model, which existing APIs to reuse. Resolve ambiguity with me now, not through a worker.

2. Scaffold in real code. Write types, interfaces, constants and error types in full. For every function a worker will write: the final signature, a contract docstring (purpose, args, returns, errors, pre/postconditions, one worked example, performance bound if it matters) and a body that fails loudly with the marker WORKER-TODO. Wire callers to the stubs so the project compiles. Where the language allows, put interfaces in files the worker may not edit (headers, .d.ts, Protocols, traits) and bodies in files it may.

3. Write the tests first. Visible table-driven tests for the worker, covering the happy path, each documented error and the edge cases. A few holdout tests outside the worker's working directory, never mentioned to it, to catch hard-coded answers. Run the suite: it must fail only with WORKER-TODO. If anything else fails, fix the scaffold before delegating.

4. Delegate only what fits: a unit whose contract fits in a signature plus a docstring, that a command can prove correct, touching 1-3 files and about 20-200 new lines. Keep architecture, shared files, concurrency, security, credentials, migrations, dependencies, and anything untestable for yourself. Parallel workers never share an editable file.

5. Brief each unit with a complete work order: one-sentence goal; stubs to implement; files it may edit, may read, must not touch; the exact signatures of existing APIs it must use (pasted, never "the usual helper"); one short house-style example; the visible tests; the exact verify command; forbidden moves; known pitfalls for this worker; and a required report (STATUS, FILES CHANGED, VERIFY command and result, NOTES). Give focused context, not the repository.

6. Forbid explicitly: editing, skipping or deleting tests; changing signatures, types or docstrings; new dependencies or invented APIs; broad catches that return defaults; hard-coding test values; leaving WORKER-TODO, TODO or pass; refactoring outside the stubs; any git write.

7. Dispatch with a timeout, a step cap, the narrowest permission that can edit and run the verify command, and no git writes. For MiniMax:
   mcode exec --cwd <repo> --prompt-mode coding --permission smart --timeout 15m --max-steps 80 -o <out.txt> --input - < <work-order.md>

8. Gate it yourself; a worker's "tests pass" is a claim. Fail the unit if any file outside its list changed, any test or interface changed, any WORKER-TODO is left, any skip/ignore/disable marker was added, or the visible or holdout tests fail. (The skill's scripts/gate.sh does all of this.) Then read every changed line for what tests miss: swallowed errors, hard-coded values, duplicated helpers, needless options or abstraction, behaviour that matches the tests but not the docstring.

9. Correct or escalate. Send one precise correction per round to the same worker session, quoting the failure and the exact expected behaviour. After two failed rounds, stop: split the unit into smaller stubs, add pseudocode or the test that shows the trap, and delegate once more, or write it yourself. Fix one- or two-line problems yourself.

10. Keep a field guide of about 30 lines: mistakes each worker model actually made here and the brief line that prevented them. Paste the relevant lines into every new work order.

Done means: the gate passes on your own run including holdout tests, you have read every changed line, the full build and tests pass after integration, no WORKER-TODO remains anywhere, and your report says which units each worker wrote, which were escalated and what was verified.
```

# Notes

- Full method, templates and the gate script live in the public skill `scaffold-delegate` in `BriarForge/skills` (`SKILL.md`, `references/work-order.md`, `references/scaffold-patterns.md`, `references/worker-adapters.md`, `references/research.md`, `scripts/gate.sh`). This prompt is the self-contained version for coordinators without the skill installed (Codex, T3 Code, Hermes).
- Basis: Cursor's planner/worker swarm (cheap workers match frontier results when intent is specified precisely), Planning-after-Trial (cheap model tries first, strong model plans only on failure), Anthropic's subagent-brief findings, Aider architect/editor results. Sources in the skill's `references/research.md`.
- Tested 2026-11-15 with MiniMax M3 (`mcode` 0.7.4): two stubs plus 17 visible tests, done in about 5 minutes, passed the gate and the unseen holdout tests; diff review still found unrequested float/bool coercion, which is why step 8 asks for a full read.
- Related: [Opus orchestrator with MiniMax-first explorer](opus-orchestrator-mcode-explorer.md), [Codex coordinator with Grok workers](codex-coordinator-grok-workers.md), [Codex coordinates XerahS, house first](../xerahs/codex-coordinator-xerahs-house-first.md) (its MiniMax role is the same idea in brief).
