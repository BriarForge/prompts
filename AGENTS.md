# AGENTS.md

## Git identity and wrappers (mandatory)

All git activity in this repo MUST go through a per-person wrapper. No bare `git push`.

| Agent | Wrapper |
|---|---|
| Aoife | `git-aoife` |
| Declan | `git-declan` |
| Milena | `git-milena` (not yet installed) |
| Sofia | `git-sofia` (not yet installed) |

Whoever pushes uses their own wrapper. Example: Declan pushes with `git-declan push`, Aoife with `git-aoife push`. Wrappers set committer identity and route the push to the correct per-person remote on the matching `github-<person>` SSH host.

Run `git-<person> whoami` to confirm before pushing.

## Source of truth

Inherited from `/Users/mike/Projects/BriarForge/AGENTS.md`. When this file and the parent conflict, the parent wins until this file is updated to match.

## Security Rules (mandatory for public repo)

- Never commit or push real secrets, tokens, API keys, passwords, or private keys.
- File paths such as `/Users/mike/*`, `/Users/mike/.hermes/*`, or similar local paths are considered low-risk and acceptable.
- If any prompt or note contains potentially sensitive values, redact them before saving.

## Prompt saving workflow

When the user asks to "save a prompt" (or equivalent phrasing such as "store this prompt", "save this as a recurring prompt", "add this prompt to the library"):

1. Create a new Markdown file inside the appropriate category subfolder (e.g. `coding/`, `team-config/`) using `<kebab-case-name>.md`.
2. The filename should be a concise kebab-case version of the prompt's purpose or title.
3. File contents should be a clean, self-contained Markdown document containing:
   - A level-1 heading with the prompt title
   - Optional YAML frontmatter for `tags`, `category`, `last-used`, `version`
   - The full prompt text in a fenced code block or as the main body
   - Optional "Usage notes" or "Examples" section
4. Do not overwrite existing files unless the user explicitly requests an update.
5. After creating the file, stage and commit using the correct wrapper (`git-aoife commit -m "prompt: add <name>"` or similar) and push.
6. Report the created file path and commit summary back to the user.

This keeps the library organized, searchable, and version-controlled for recurring prompts.