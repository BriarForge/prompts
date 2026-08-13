---
name: xerahs-prompt-creator
description: Enhance raw XerahS feedback into paste-ready prompts under coding/xerahs/.
version: 1.0.0
tags: [xerahs, prompts, bug-fix, reusable]
---

# xerahs-prompt-creator

Turn raw XerahS user feedback, bug reports, or feature asks into paste-ready reusable prompts. Save under the canonical XerahS subfolder, commit via the wrapper, and reply with the fenced body when the user asked for copy/paste. Complements `reusable-prompt-files` (library shape and char-cap measurement) by owning the XerahS-specific enhance procedure.

## When to use

- User says: "prompt for this XerahS feedback", "enhance this bug report", "make a paste-ready XerahS prompt", "turn this into a reusable prompt".
- Input is raw feedback / bug / feature ask that needs to become a reusable, fenced prompt under `coding/xerahs/`.
- Not for: skills (use `hermes-agent-skill-authoring`); single-shot chat replies with no intent to save; prompts about other products (drop into flat `coding/`); moving out of `coding/xerahs/` without explicit user direction.

## Inputs

- **Feedback text** (verbatim, quoted inside the prompt).
- **Char cap** when stated (default none; common caps: ≤2000 chars for a Discord paste).
- **Bug vs feature hint** when the user hints at it.
- **Optional extras**: log snippets, repro steps, expected vs actual (use only what the user gave).

## Library conventions

- Canonical home: `/Users/mike/Projects/BriarForge/prompts/`. Chat workspace `AI/...` is for artefacts only — never save prompts there.
- Product-specific XerahS prompts go under `coding/xerahs/<kebab>.md`. Only generalize to flat `coding/` when the user says it's reusable beyond XerahS.
- File shape: frontmatter (`tags`, `category: xerahs`, `version`) → H1 title → fenced ` ```text ` body → `# Notes` outside the fence. See `reusable-prompt-files` for the full library rules.
- Char cap applies to the **fenced body only**. Frontmatter and `# Notes` do not count. After trim, update the size hint in `# Notes` to match.

## XerahS defaults to bake in (when in scope)

- Repo: `/Users/mike/Projects/KovaForge/xerahs`.
- Stay on existing `develop`. No new branches, issues, worktrees, or personal integration branches.
- Follow root `AGENTS.md`. Verify with the narrowest relevant tests + `dotnet build` before finishing.
- If the prompt will drive git activity in the XerahS repo, mention the per-person `git-*` wrapper discipline and `git-<name> whoami` discovery.

## Procedure

1. **Classify.** Decide bug-fix / investigate / feature / docs. Kebab-case the filename (e.g. `startup-minimize-bug-fix.md`).
2. **Draft the prompt body.** Keep feedback verbatim in quotes. Blend senior-dev discipline (root-cause, no band-aids, deliverables, constraints) with XerahS-specific gates (repo, branch, AGENTS.md, `dotnet build`, wrapper). Do not invent scope, stack, or symptoms the user didn't state.
3. **Length-gate.** If the user gave a cap, measure `text.split("```text",1)[1].split("```",1)[0].strip()`. Trim until under cap, then update the size hint in `# Notes`.
4. **Write the file.** Frontmatter, H1, fenced body, `# Notes` outside the fence. Use the templates below.
5. **Commit via wrapper, exact paths only.** `git-aoife add coding/xerahs/<name>.md` (or `git add coding/<name>.md` for generalized prompts). Inspect `git-aoife status --short` and leave unrelated dirty files alone (`fable5/runs.log`, `team-config/*`). Commit `prompt: add <name>`, push, verify with `git-aoife log -1 --name-status` before claiming the SHA.
6. **Reply once.** Short message: path + commit SHA. Include the fenced body in chat only if the user asked for a paste.

## Templates

- **Bug fix** — see `templates/bug-fix.md`.
- **Feature / investigate** — see `templates/feature-or-investigate.md`.

## Worked example (path only — not frozen product truth)

- `coding/xerahs/startup-minimize-bug-fix.md` — Windows startup-minimize bug from real user feedback. Treat the path as a shape reference; the body is per-bug context, not a template to copy verbatim.

## Related

- `reusable-prompt-files` — library shape (frontmatter, fence, Notes, char-cap measurement, subfolder conventions). This skill layers XerahS-specific defaults and the feedback→enhanced-prompt flow on top of it.
- Flat `coding/` holds generic senior-dev shapes (`debug-like-a-senior-engineer.md`, `optimize-for-performance.md`, etc.). Blend their tone into XerahS-specific prompts when relevant.

## Pitfalls

- **Verbatim drift.** Paraphrasing the user's feedback changes the brief. Quote it unchanged inside the prompt.
- **Inventing repro.** Only use symptoms, logs, and steps the user actually provided. Open gates for unknowns.
- **Wrong home.** Dropping a XerahS prompt into `AI/prompts/` or flat `coding/` instead of `coding/xerahs/` (until the user says it's reusable beyond XerahS).
- **Char count on the wrong span.** Counting the whole file instead of the fenced body. Frontmatter + `# Notes` don't count toward a paste cap.
- **Staging noise.** `git-aoife add .` pulls `fable5/runs.log` and `team-config/*` into the commit. Stage explicit paths only.
- **Claiming a SHA before push.** Always verify with `git-aoife log -1 --name-status` before telling the user the commit landed.
- **Generalizing out of `coding/xerahs/` without being asked.** Only move to flat `coding/` when the user explicitly says it's reusable beyond XerahS.
- **Discord spam.** Multiple replies, edit/delete loops, or paste blocks before the commit lands. One reply, after `git log` proves the commit, with the fenced body only if a paste was requested.

## Verification

- File exists at `coding/xerahs/<name>.md` (or flat `coding/<name>.md` if generalized).
- Frontmatter parses; fenced body is the only copy-pasteable region; `# Notes` is outside the fence.
- Char count (fenced body) under any cap the user gave; size hint in `# Notes` matches reality.
- `git-aoife log -1 --name-status` shows only the new prompt path under `coding/`.
- Push succeeded; one Discord reply sent with path + SHA (and the fence if a paste was requested).