---
tags: [xerahs, xbackbone, integration, sharex, reusable]
category: xerahs
version: 1
---

# XerahS xbackbone destination + auto-copy link

```text
You are adding a first-class xbackbone destination to XerahS, plus ShareX-style copy-link-after-upload. Repo: /Users/mike/Projects/KovaForge/xerahs. Stay on existing develop. Follow root AGENTS.md. No new branches or issues. Verify with the narrowest relevant tests + dotnet build.

User request (verbatim):
"Summary
In the continuation of shareX an integration with xbackbone would be a must have. The feature with the automatic link copy after upload is also a cool feature from sharex.

Use Case
I think all users from xbackbone who are on macos or on linux will benefits of this.

Benefit
Remove the need of custom config for xbackbone integration."

Goal: first-class xbackbone destination (no custom uploader config) and copy the uploaded URL to the clipboard after success. No scope creep.

Investigate first:
1. Existing upload destinations / custom-uploader surface; closest pattern to reuse.
2. How xbackbone is configured today (URL, token/auth, path); treat API/auth as unknown until primary docs or in-repo usage prove it.
3. Post-upload clipboard copy: does any destination already do this? Per-OS clipboard path.
4. Assumptions + unknowns before design. Do not invent xbackbone endpoints.

Deliver:
- Approach (smallest v1: destination + auto-copy)
- Config/auth shape (no secrets in repo)
- Files / diff summary
- Verify steps (macOS + Linux) + expected result
- Residual risk / open questions

Constraints: reuse existing destination/uploader abstractions; behavior-preserving elsewhere; no architecture rewrite; no ShareX clone. Code only after approach is locked.
```

# Notes
- Feature, not bug. Borrowed shape from `first-party-cli-or-plugin` (discovery -> smallest v1 -> config -> verify) without its generic host placeholders.
- 1582 chars in the fenced body (under any default 2k paste cap).
- Verbatim user request preserved.
- Do not invent xbackbone API endpoints, auth scheme, or XerahS class names; investigate first.
- XerahS-specific: stays under `coding/xerahs/` until explicitly generalized.