# Objective-to-Execution Translation Layer

**Category:** prompting  
**Tags:** [objectives, goals, fable-5, hermes-prime]

```text
Fable 5 one-shot mode (high effort, long-run scaffolding + git workflow enabled):

Objective: Build a reusable translation layer that converts high-level strategic objectives into the precise goal statements, success criteria, and verification methods that Fable 5 (and future Mythos models) can execute with minimal back-and-forth.

Reference these verified files for current conventions:
- Channel AGENTS.md: /Users/mike/Library/CloudStorage/OneDrive-Personal/AI/financial/AGENTS.md
- Project roots: /Users/mike/Projects/BriarForge/ and /Users/mike/Projects/KovaForge/

Use Fable 5 scaffolding:
1. First create an explicit rubric for "Fable-ready goal quality".
2. Maintain/update a persistent project memory file (CLAUDE.md style).
3. Decompose + self-verification loops on each translation.
4. Natural language + explicit structure with verification gates.

Git workflow (mandatory, use wrappers only):
- After every major section or significant change: progressively commit with `git-aoife commit -m "msg"`
- At the very end: final commit + `git-aoife push`

Done looks like: A prompt template + checklist that turns any objective into a Fable-ready /goal block, plus three real examples from recent work translated and validated. Verification: The resulting goal statements should allow Fable to produce finished, high-signal outcomes without requiring clarification on scope or “what done means.” End with rubric self-score.
```

## Notes
- Move from providing tasks to providing objectives.
- Describe what done looks like and how to verify it.