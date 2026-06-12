# XerahS Linux Support Significant Improvement

**Category:** platform-support  
**Tags:** [xerahs, linux, avalonia, cross-platform, hermes-prime]

```text
Fable 5 one-shot mode (high effort, long-run scaffolding + git workflow enabled):

Objective: Deliver a substantial, production-grade improvement to XerahS Linux support so that the Avalonia-based ShareX fork runs reliably and feature-parity on Linux (Ubuntu 24.04+ / Fedora / Arch as primary targets), with documented build/run instructions, known gaps closed where feasible, and a clear remaining-roadmap.

Grounding (verified paths):
- XerahS repo root: /Users/mike/Projects/KovaForge/xerahs
- Existing Linux-related files: flatpak/, native/, docs/architecture/PORTING_GUIDE.md, KNOWN_ISSUES.md, scripts/
- Build system: Avalonia + .NET 10, SkiaSharp 3.119.3-preview
- Current Windows-centric target: net10.0-windows10.0.26100.0

Scope (in this run):
- In: full read of repo structure, PORTING_GUIDE.md, KNOWN_ISSUES.md, Avalonia Linux specifics, existing Linux packaging (flatpak, AppImage attempts if any), hotkey/input handling, clipboard, file watchers, notification integration, Wayland vs X11 differences.
- Allowed: create or heavily expand a LINUX-SUPPORT.md or update PORTING_GUIDE.md with concrete implementation steps; produce small, reviewable patches/diffs that demonstrate fixes (but do not apply them unless explicitly safe and isolated).
- Out: do NOT perform full builds that would exceed time/credit limits; do NOT touch release pipelines or credentials; do NOT claim "Linux is now fully supported" without evidence.
- Decide alone: prioritization of Linux pain points (hotkeys, global capture, tray icon, notifications, file associations, Wayland compatibility, packaging).
- Surface for human: any change that would alter Windows behavior or require new native dependencies.

Key improvement areas to address:
1. Input/hotkey handling on Linux (global shortcuts, especially under Wayland)
2. Screen capture / region selection reliability
3. Clipboard and drag-drop fidelity
4. System tray / notification integration (libnotify, StatusNotifierItem)
5. Packaging & distribution (Flatpak, AppImage, .deb/.rpm)
6. File system watchers and upload triggers
7. Font rendering, HiDPI, theme integration with Avalonia
8. Any SkiaSharp or native interop issues on Linux

Workflow contract:
- Use git-aoife for all commits and final push.
- Commit progressively after each major section or verified finding.
- Output primary artifact: /Users/mike/Projects/KovaForge/xerahs/docs/LINUX-IMPROVEMENT-PLAN.md (or equivalent high-signal document)
- Include: prioritized backlog with effort/impact, concrete code sketches or diffs for top 3-5 items, build/run verification commands for Linux, success criteria, and remaining gaps explicitly listed.

Done looks like:
1. A detailed, actionable LINUX-IMPROVEMENT-PLAN.md exists with prioritized items, each having implementation outline, verification steps, and rollback notes.
2. At least 3-5 high-impact Linux-specific issues have concrete patch proposals or code examples included.
3. Clear instructions for building and running XerahS on Linux from source are present and tested conceptually against the repo.
4. The plan is committed and pushed via git-aoife.
5. Final rubric self-score per /Users/mike/Projects/BriarForge/prompts/fable5/translation-layer/RUBRIC.md with evidence.

Verification:
- Plan must be specific enough that a competent developer could execute the top items without further research.
- All claims about current Linux state must be backed by repo inspection (not assumption).
- End with explicit "Linux support level after proposed changes: X/10" self-assessment.

If blocked:
- Conflicting build targets or Avalonia version issues → record exact error and propose minimal viable change.
- Wayland vs X11 ambiguity → provide separate paths or detection logic recommendation.
```

## Notes
- Treat Linux support as a first-class platform, not an afterthought.
- Focus on closing the gap with the existing Windows implementation rather than adding new features.
- Reference the existing xerahs-pipeline-reliability-autonomy work where relevant for release/publishing implications on Linux.
- This prompt is additive to the previous XerahS pipeline prompt; the two should be complementary.