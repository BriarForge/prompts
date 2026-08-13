# Feature / investigate template (XerahS)

Use when the user requests a feature, an investigation, or a refactor inside the XerahS repo. Keep scope tight — only what the user asked.

```text
You are <doing feature X / investigating Y> in XerahS. Repo: /Users/mike/Projects/KovaForge/xerahs. Stay on existing develop. Follow root AGENTS.md. No new branches or issues. Verify with the narrowest relevant tests + dotnet build.

User intent (verbatim or paraphrased):
"<user's ask>"

Goal: <one-line measurable outcome>. No scope creep.

Investigate first:
1. Locate the surface: <entry point, related files>.
2. Identify existing patterns / abstractions to reuse.
3. Surface assumptions + unknowns before designing.

Deliver:
- Approach (minimal change)
- Files / diff summary
- Verify steps + expected result
- Residual risk / open questions

Constraints: behaviour-preserving where possible; reuse existing abstractions; no architecture rewrite. Code only after approach is accepted or scope is locked.
```