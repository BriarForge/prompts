---
tags: [goal, session, reusable]
category: meta
version: 1
---

# Derive /goal from session

```text
Read this repo, analyze deeply the exact intent and goals we are looking to achieve here, then write me the /goal prompt for one of the goals that you believe we must focus on.

Make sure to dig into history and docs we have to be 100% clear.

If you are not sure about certain parts, or want to ask me a few questions to clarify certain goals further, don't hesitate.

Output requirements:
- Return only the final prompt text unless clarification is needed first.
- Start the final prompt with `/goal`.
- Make the prompt self-contained enough that Codex can continue in this session and repo nonstop until completion.
- Include concrete goals, constraints, relevant history/docs to inspect, implementation expectations, verification expectations, and completion criteria.
- Preserve XerahS repository rules: stay on `main` unless explicitly told otherwise, follow root `AGENTS.md`, do not create branches or GitHub issues unless asked, and verify with the narrowest relevant tests plus `dotnet build` when required.
```

# Notes
- Paste this into Codex from the session you want to convert.
- If the returned prompt does not start with `/goal`, prefix it manually.
