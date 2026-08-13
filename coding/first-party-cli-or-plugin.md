---
tags: [cli, plugin, integration, reusable]
category: coding
version: 2
---

# First-party CLI or plugin

```text
Create a first-party [CLI/plugin] integration from [host product] to [target: OpenClaw/Hermes/other].

Treat this as production work in the host repo, not a prototype. Stay on the current branch unless explicitly told otherwise. Follow root AGENTS.md (build, test, commit-message, branch rules).

Target:
- Host product / repo: [name + path]
- Integration target: [OpenClaw/Hermes/other]
- Upstream repo or docs: [URL or local path]
- Integration type: [CLI/plugin/both]
- Primary user workflow: [action the end user should complete]
- Required commands or plugin capabilities: [commands, actions, settings, UI entry points]
- Auth / configuration: [none/API key/OAuth/local path/env vars/etc.]
- Output expectations: [JSON/text/files/domain objects/etc.]

Discovery:
1. Inspect existing host CLI/plugin patterns before designing anything new.
2. Identify the closest first-party implementation as the style reference.
3. Read the target's official docs or source (prefer primary sources).
4. Note runtime, packaging, licensing, platform, and security constraints.
5. List assumptions and unknowns before implementation.

Design:
1. Smallest useful v1 only.
2. Command names / plugin IDs using the host's naming conventions.
3. Stable inputs/outputs; for CLI, error shape + exit codes.
4. How credentials/config are stored or passed.
5. How this hooks host domain concepts (history, workflows, settings, etc.) if relevant.
6. Explicitly defer anything post-v1.

Implementation:
1. Focused, idiomatic changes that match host architecture.
2. Reuse existing abstractions, SDKs, service boundaries, serializers, UI patterns.
3. Tests: parsing, config validation, client behavior, failure cases.
4. No embedded secrets, vendor hacks, or brittle parsing when structured APIs exist.
5. Update docs/dev guidance when maintainers will need it.

Verification:
1. Narrowest relevant tests first.
2. Run the host's standard build/test gate from AGENTS.md before finishing.
3. CLI: example invocations + expected output.
4. UI/plugin: registration/discovery + primary workflow.
5. Residual risks + any manual setup not verified locally.
```

# Notes
- Fill bracketed placeholders before use.
- Host-agnostic: works for XerahS or any other app repo.
- v2: generalized out of `coding/xerahs/`; was XerahS-specific.