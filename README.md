# Prompts

Central library for recurring prompts used across Hermes, OpenClaw, and agent workflows.

## Purpose

Store reusable, high-value prompts in a structured, version-controlled Markdown format so they can be referenced, iterated, and reused without re-pasting.

## Structure

Every folder is a category, and a prompt's `category:` frontmatter matches its top-level folder (`xerahs` for `coding/xerahs/`).

- `coding/`: generic build, review, debug and refactor prompts for any repo
  - `coding/orchestration/`: multi-agent and coordinator/worker prompts
  - `coding/autonomous/`: prompts that hand the agent standing ownership of a repo or app (it decides what to build and how, audits the whole project, and keeps improving it)
  - `coding/xerahs/`: XerahS-specific prompts (bug fixes, features, loops, sweeps)
  - `coding/sharex/`: ShareX-specific prompts
- `team-config/`: prompts about the agent team itself (model inventory, cron jobs, plugin review, architecture migrations)
- `finance/`: stock and investment analysis prompts
- `writing/`: rewriting and tone prompts
- `skills/`: skills that help author prompts for this library
- `fable5/`: the Fable 5 queue (runner script, progress file, scopes). Not a prompt category; do not move files, a cron-driven runner reads fixed paths here.

One `.md` file per prompt, kebab-case filename. Generic prompts live in `coding/`; put a prompt in a product folder only when it names that product.

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