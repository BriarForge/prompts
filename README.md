# Prompts

Central library for recurring prompts used across Hermes, OpenClaw, and agent workflows.

## Purpose

Store reusable, high-value prompts in a structured, version-controlled Markdown format so they can be referenced, iterated, and reused without re-pasting.

## Structure

- One `.md` file per prompt at the repo root
- Each file uses kebab-case naming (e.g. `financial-report-roast.md`)
- Files contain the prompt plus optional metadata and usage guidance

## Adding a prompt

Tell any agent (Aoife, Declan, etc.):

> "Save this prompt as financial-report-roast"

The agent will create the Markdown file following the rules in `AGENTS.md`, commit it, and push.

## Conventions

- Keep prompts self-contained and copy-paste ready
- Use frontmatter for tags and categorization when helpful
- Update `last-used` date on reuse if desired
- Never store secrets, tokens, or environment-specific values in prompts

## License

Internal BriarForge use only.