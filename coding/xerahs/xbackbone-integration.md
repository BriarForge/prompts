---
tags: [xerahs, xbackbone, amazon-s3, integration, reusable]
category: xerahs
version: 2
---

# XerahS xbackbone destination (mirror Amazon S3) + auto-copy

```text
You are adding a first-class xbackbone destination to XerahS the same way Amazon S3 is already implemented, plus ShareX-style copy-link-after-upload if that path already exists. Repo: /Users/mike/Projects/KovaForge/xerahs. Stay on existing develop. Follow root AGENTS.md. No new branches or issues. Verify with the narrowest relevant tests + dotnet build.

User request (verbatim):
"Summary
In the continuation of shareX an integration with xbackbone would be a must have. The feature with the automatic link copy after upload is also a cool feature from sharex.

Use Case
I think all users from xbackbone who are on macos or on linux will benefits of this.

Benefit
Remove the need of custom config for xbackbone integration."

Implementation rule (user): add xbackbone the way Amazon S3 is implemented.

Goal: S3-parity destination (settings, auth/config, upload, returned URL) with no custom-uploader config. Reuse existing post-upload clipboard copy if present. No scope creep.

Investigate first:
1. Map the Amazon S3 destination end-to-end and treat it as the template. Do not invent type/file names.
2. xbackbone URL/token/auth/path from primary docs or in-repo usage only.
3. Whether S3 or any destination already copies the uploaded URL; reuse that path.
4. List assumptions + unknowns. Do not invent xbackbone endpoints.

Deliver:
- S3-vs-xbackbone map (what clones, what must differ)
- Config/auth shape (no secrets in repo)
- Files / diff summary
- Verify steps (macOS + Linux) + expected result
- Residual risk / open questions

Constraints: clone the S3 destination pattern; reuse uploader/clipboard abstractions; behavior-preserving elsewhere; no architecture rewrite; no ShareX clone. Code only after the S3 map is written.
```

# Notes
- v2: user named Amazon S3 as the reference. Same file, in-place edit (no new SW-style ID).
- 1739 chars in the fenced body (under the 2k paste cap).
- Feature, not bug. Borrowed shape from `first-party-cli-or-plugin` (discovery -> smallest v1 -> config -> verify) without its generic host placeholders.
- Verbatim user request preserved.
- Do not invent xbackbone API endpoints, auth scheme, or XerahS class names; investigate first.
- Auto-copy is kept; reuse the existing path if S3 (or another destination) already copies the URL. Do not build a second clipboard system.
- XerahS-specific: stays under `coding/xerahs/` until explicitly generalized.