---
tags: [xerahs, video-editor, restructure, review, e2e, reusable]
category: xerahs
version: 1
---

# ShareX.VideoEditor end-to-end restructure (review, revamp, re-architecture)

```text
You are reviewing and restructuring ShareX.VideoEditor so its advertised surface works end-to-end. Host: /Users/mike/Projects/KovaForge/xerahs. ShareX.VideoEditor is a gitlink submodule — do not branch/worktree it; call out any pointer move first. Stay on host develop. Follow root AGENTS.md. No new branches or issues. Narrowest tests + dotnet build.

User intent: review / revamp / re-architecture / restructure so ShareX.VideoEditor works end-to-end.

Advertised surface only: trim, crop, format conversion, watermarking via Photino + React UI + FFmpeg. Host entry: VideoEditorOptions / VideoEditorEvents -> VideoEditorHost.ShowEditor / ShowEditorDialog. Sibling ShareX.ImageEditor (Avalonia) is out of scope.

Goal: E2E works — host launches editor -> UI mounts -> FFmpeg export -> host events/callback. Re-architecture OK; keep stack and host API.

Investigate first:
1. Map: host -> VideoEditorHost -> bridge -> React UI -> FFmpeg -> export service -> events/callback. Name files as they exist.
2. Reuse existing host tests that launch/automate the video editor before adding new ones.
3. Confirm host consumes the assembly and launch matches ShowEditor.
4. Backend/Core (export, thumbnails) vs Hosting (host, bridge, automation, validator); frontend React/TS/Vite + embedded dist; scripts/ensure-webui-deps.mjs.

Deliver:
- Architecture summary (current vs target)
- Broken / incomplete E2E paths (files + line ranges)
- Restructure plan (smallest diffs that close E2E; preserve host API)
- Implemented diffs (per-file)
- Verify: dotnet build, existing host editor tests, manual ShowEditor, one run per advertised op
- Residual risk / open questions

Constraints: keep stack + host API; behavior-preserving elsewhere; no ImageEditor; no second UI stack; code only after map + plan.
```

# Notes
- Feature + restructure, not a bug-fix prompt. Blends `feature-or-investigate`, `understand-and-refactor-unfamiliar-code`, and `rebuild-with-clean-architecture`.
- Drops the usual "no architecture rewrite" line because the user explicitly asked for re-architecture.
- User's meta-request (asking Aoife for a prompt) is **not** quoted as product feedback; the implementing agent only sees the user's intent.
- Submodule has its own .git; submodule pointer moves call it out, never invented.
- Stays under `coding/xerahs/` (repo path, develop, AGENTS.md, `dotnet build`).
- 1788 chars in the fenced body (under the 2k paste cap).