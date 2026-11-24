# Prompts

Central library for recurring prompts used across Hermes, OpenClaw, and agent workflows.

## Purpose

Store reusable, high-value prompts in a structured, version-controlled Markdown format so they can be referenced, iterated, and reused without re-pasting.

## Structure

Folders answer "what do I want the agent to do?" first, and "for which product?" second.

- `coding/build/`: start or add something new (app, system, UI components, CLI/plugin, scoping before a build)
- `coding/improve/`: work on existing code (debug, optimise, refactor, understand)
- `coding/autonomous/`: hand the agent standing ownership of a repo (it decides, audits and keeps improving)
- `coding/orchestration/`: one agent coordinating others (coordinator/worker, delegation, review)
- `coding/xerahs/`, `coding/sharex/`: anything that names that product or its repo, whatever the task type
- `team-config/`: prompts about the agent team itself (model inventory, cron jobs, standing agent jobs, plugin review)
- `finance/`: stock and investment analysis
- `writing/`: rewriting and tone
- `skills/`: skills that help author prompts for this library
- `fable5/`: the Fable 5 queue (runner script, progress file, scopes, run outputs). Not a prompt category; do not move files, the runner reads fixed paths here.

Rules:

- One `.md` file per prompt, kebab-case filename.
- `category:` in the frontmatter is the name of the folder the file sits in (`build`, `orchestration`, `xerahs`, `finance`, ...).
- A prompt goes in a product folder only when it names that product or its repo; otherwise it goes in the task folder.
- Add every new prompt to the catalog below in the same commit.

## Catalog

### coding/build
| Prompt | Use when |
|---|---|
| [Build complete app from scratch](coding/build/build-complete-app-from-scratch.md) | New production app: architecture first, then the minimal scalable version |
| [Design and build a scalable system](coding/build/design-and-build-scalable-system.md) | Systems-architect design for a product, then the minimal production build |
| [Build production UI components](coding/build/build-production-ui-components.md) | Reusable, accessible frontend components |
| [First-party CLI or plugin](coding/build/first-party-cli-or-plugin.md) | Integrate a host product with OpenClaw, Hermes or another agent as a CLI or plugin |
| [SW### Scope-Until-Build](coding/build/sw-scope-until-build.md) | Scope a new project in conversation; building stays gated until scope is agreed |

### coding/improve
| Prompt | Use when |
|---|---|
| [Debug like a senior engineer](coding/improve/debug-like-a-senior-engineer.md) | Production bug: step-by-step root cause, then the fix |
| [Optimize for performance](coding/improve/optimize-for-performance.md) | Speed, memory and scale work on existing code |
| [Rebuild with clean architecture](coding/improve/rebuild-with-clean-architecture.md) | Refactor toward clean architecture |
| [Understand and refactor unfamiliar code](coding/improve/understand-and-refactor-unfamiliar-code.md) | Map a large unfamiliar codebase before changing it |
| [Split long functions](coding/improve/split-long-functions.md) | One function is too long: split it with Extract Function |
| [Merge duplicated code](coding/improve/merge-duplicated-code.md) | You make the same fix in several places: merge into one function |
| [Rename unclear names](coding/improve/rename-unclear-names.md) | You cannot tell what something does from its name: rename it |

### coding/autonomous
| Prompt | Use when |
|---|---|
| [The codebase is yours](coding/autonomous/codebase-ownership.md) | Give the agent ownership of a repo's purpose and design |
| [Find implicit state machines](coding/autonomous/find-implicit-state-machines.md) | Find and make explicit the hidden state machines in an app |
| [Full project audit](coding/autonomous/full-project-audit.md) | Read everything, fix what is certain, list the rest |
| [Own it, find the state machines, fix what's sure](coding/autonomous/ownership-state-machine-audit.md) | One maintenance session combining the three above |

### coding/orchestration
| Prompt | Use when |
|---|---|
| [Frontier scaffolds, weaker worker fills](coding/orchestration/frontier-scaffolds-weaker-worker-fills.md) | A strong model writes stubs and tests; MiniMax or another cheaper agent fills the bodies (skill: `scaffold-delegate`) |
| [Opus orchestrator with MiniMax-first explorer](coding/orchestration/opus-orchestrator-mcode-explorer.md) | Opus plans and signs off; search via `mcode`, fixer and checker subagents |
| [Claude Code coordinator with thread workers](coding/orchestration/claude-code-coordinator-threads.md) | Opus coordinator, parallel Sonnet threads, one PR each |
| [Codex coordinator with Grok workers](coding/orchestration/codex-coordinator-grok-workers.md) | Codex coordinates real Grok subagents in T3 Code |
| [Multi-agent workflow](coding/orchestration/multi-agent-workflow.md) | One model role-plays architect, engineer, reviewer and optimiser in sequence |

### coding/xerahs
| Prompt | Use when |
|---|---|
| [Codex coordinates XerahS, house first](coding/xerahs/codex-coordinator-xerahs-house-first.md) | Codex leads the Linux implementation with MiniMax workers, foundation first |
| [XerahS multi-agent orchestrator](coding/xerahs/xerahs-multi-agent-orchestrator.md) | Opus leads XerahS development with worker agents |
| [Grok leads Codex on XerahS](coding/xerahs/grok-leads-codex.md) | Grok supervises Codex slices on a 30-minute cycle |
| [XerahS loop](coding/xerahs/xerahs-loop.md) | Agent-agnostic one-slice-per-run loop |
| [XerahS sweep](coding/xerahs/xerahs-sweep-prompt.md) | Review sweep driven by the `xerahs-hourly-sweep` skill |
| [Derive /goal from session](coding/xerahs/derive-goal-from-session.md) | Turn a session's intent into a self-contained `/goal` prompt |
| [Feature work: systems-thinking](coding/xerahs/feature-systems-thinking.md) | Research, compare approaches and write a proposal before building a feature |
| [Extend XerahS Cloud to mobile](coding/xerahs/extend-cloud-to-mobile.md) | Bring Cloud features to the iOS and Android apps |
| [Improve Amazon S3](coding/xerahs/improve-amazon-s3.md) | Improve the existing S3/AWS uploader |
| [xbackbone integration](coding/xerahs/xbackbone-integration.md) | Add an xbackbone destination modelled on S3 |
| [First-party CLI or plugin (XerahS)](coding/xerahs/first-party-cli-or-plugin.md) | XerahS variant of the generic CLI/plugin prompt |
| [ShareX.VideoEditor end-to-end restructure](coding/xerahs/sharex-videoeditor-e2e-restructure.md) | Make the video editor submodule work end to end inside XerahS |
| [Startup-minimize bug fix](coding/xerahs/startup-minimize-bug-fix.md) | Worked example of a bug report turned into a fix prompt |

### coding/sharex
| Prompt | Use when |
|---|---|
| [ShareX cross-platform loop](coding/sharex/sharex-loop.md) | One slice per run on the ShareX cross-platform branch |

### team-config
| Prompt | Use when |
|---|---|
| [Agent model inventory](team-config/agent-model-inventory.md) | List each agent's provider and model from its config |
| [List agent cron jobs by frequency](team-config/list-agent-cron-jobs-by-frequency.md) | Inventory an agent's cron jobs by schedule |
| [Migrate cronjobs to skill-first](team-config/migrate-cronjobs-to-skill-first.md) | Move cron job logic into skills |
| [Review and adopt a coding plugin](team-config/review-and-adopt-coding-plugin.md) | Vet a plugin, install it if safe, explain the effect |
| [AI breaking news lane](team-config/ai-breaking-news-lane.md) | Source of the standing news-watch cron job |
| [Claude Code model team, Fable advisor](team-config/claude-code-fable-advisor-setup.md) | Set up Fable advisor, Sonnet main, Haiku subagents and an Opus reviewer at user level on any machine |
| [Claude Code model team, Opus advisor](team-config/claude-code-opus-advisor-setup.md) | Same team with Opus as advisor: no Fable access, no usage-credits billing, or lower cost. Reviewer takes the done-check so Opus isn't paid twice |
| [Claude Code model team, Opus plans, Sonnet and GLM 5.3 build](team-config/claude-code-opus-glm-planner-builders-setup.md) | Opus main model plans and never codes; a Sonnet `builder` and a GLM 5.3 `glm-builder` (OpenCode CLI) do the legwork as subagents; the Sonnet builder can call the Opus advisor; an Opus reviewer checks the diff |
| [Claude Code Neon lane, Gemini 4 Neon builds and reviews through agy](team-config/claude-code-opus-neon-agy-lane-setup.md) | Add-on to the Opus, Sonnet and GLM team: a Gemini 4 Neon builder and reviewer through the Antigravity CLI on a Google plan, no API key. A small `agy-run` wrapper gives one JSON result, fixed exit codes, session-only permission profiles, a git guard, `--dry-run` and `--resume`; `agy-builder` and `agy-reviewer` subagents and an `agy` skill. Opus plans, Sonnet builds, Neon reviews |
| [Antigravity swarm, Argon coordinates, Hydrogen builds, Neon reviews](team-config/antigravity-swarm-argon-neon-hydrogen.md) | Team charter for Antigravity's `/swarm`: Gemini 4 Argon as coordinator, Hydrogen workers, a Neon verifier. The Antigravity counterpart of the Claude Code model team |

### finance
| Prompt | Use when |
|---|---|
| [Comprehensive stock analysis](finance/comprehensive-stock-analysis.md) | Full single-stock review |
| [Detailed financial analysis](finance/detailed-financial-analysis.md) | Statements and ratios in depth |
| [Earnings report analysis](finance/earnings-report-analysis.md) | Read a quarterly or annual result |
| [Stock valuation](finance/stock-valuation.md) | Estimate intrinsic value |
| [Growth potential analysis](finance/growth-potential-analysis.md) | Growth drivers and runway |
| [Competitive advantage analysis](finance/competitive-advantage-analysis.md) | Moat assessment |
| [Investment risk analysis](finance/investment-risk-analysis.md) | Downside and risk factors |
| [Institutional investor perspective](finance/institutional-investor-perspective.md) | How a fund manager would view it |
| [Optimistic vs pessimistic analyst debate](finance/optimistic-pessimistic-analyst-debate.md) | Bull and bear case side by side |

### writing
| Prompt | Use when |
|---|---|
| [Rewrite as human](writing/rewrite-as-human.md) | Make text sound like a person wrote it |
| [Rewrite so it no longer reads like AI](writing/rewrite-no-longer-reads-like-ai.md) | Strip AI tells from a draft |

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