# XerahS macOS Support Significant Improvement

**Category:** platform-support  
**Tags:** [xerahs, macos, avalonia, cross-platform, hermes-prime]

```text
Fable 5 one-shot mode (high effort, long-run scaffolding + git workflow enabled):

Objective: Deliver a substantial, production-grade improvement to XerahS macOS support so that the Avalonia-based ShareX fork runs reliably and with strong feature parity on macOS (Sequoia / Sonoma primary targets), including proper entitlements, notarization readiness, menu bar behavior, global hotkeys, screen capture under TCC, and clear distribution paths.

Grounding (verified paths):
- XerahS repo root: /Users/mike/Projects/KovaForge/xerahs
- Existing macOS-related files: flatpak/ (limited), native/, docs/architecture/PORTING_GUIDE.md, KNOWN_ISSUES.md, scripts/, Directory.Build.props (target framework notes)
- Build system: Avalonia + .NET 10, SkiaSharp 3.119.3-preview
- Current Windows-centric target: net10.0-windows10.0.26100.0

Scope (in this run):
- In: full read of repo structure, PORTING_GUIDE.md, KNOWN_ISSUES.md, Avalonia macOS specifics, entitlements, Info.plist requirements, screen capture / CGWindow / ScreenCaptureKit integration, global hotkey handling under macOS, menu bar / status item behavior, file watchers, clipboard, notifications, notarization & code-signing considerations.
- Allowed: create or heavily expand a MACOS-SUPPORT.md or update PORTING_GUIDE.md with concrete implementation steps; produce small, reviewable patches/diffs that demonstrate fixes (but do not apply them unless explicitly safe and isolated).
- Out: do NOT perform full builds that would exceed time/credit limits; do NOT touch release pipelines or credentials; do NOT claim "macOS is now fully supported" without evidence.
- Decide alone: prioritization of macOS pain points (TCC prompts, hotkeys, capture permissions, menu bar, distribution/notarization).
- Surface for human: any change that would alter Windows or Linux behavior or require new native dependencies or signing infrastructure.

Key improvement areas to address:
1. macOS entitlements, Info.plist, and App Sandbox / hardened runtime configuration
2. Screen capture permissions and modern ScreenCaptureKit vs legacy CG APIs
3. Global hotkey / accessibility permission handling
4. Menu bar / status item integration and tray icon behavior
5. Clipboard, drag & drop, and file association fidelity
6. File system watchers and upload triggers on APFS
7. Font rendering, HiDPI, dark mode, and Avalonia theme integration
8. Notarization, code signing, and distribution (direct vs App Store) considerations
9. Any SkiaSharp or native interop issues on Apple Silicon / Intel

Workflow contract:
- Use git-aoife for all commits and final push.
- Commit progressively after each major section or verified finding.
- Output primary artifact: /Users/mike/Projects/KovaForge/xerahs/docs/MACOS-IMPROVEMENT-PLAN.md (or equivalent high-signal document)
- Include: prioritized backlog with effort/impact, concrete code sketches or diffs for top 3-5 items, build/run verification commands for macOS, success criteria, and remaining gaps explicitly listed.

Done looks like:
1. A detailed, actionable MACOS-IMPROVEMENT-PLAN.md exists with prioritized items, each having implementation outline, verification steps, and rollback notes.
2. At least 3-5 high-impact macOS-specific issues have concrete patch proposals or code examples included.
3. Clear instructions for building and running XerahS on macOS from source are present and tested conceptually against the repo.
4. The plan is committed and pushed via git-aoife.
5. Final rubric self-score per /Users/mike/Projects/BriarForge/prompts/fable5/translation-layer/RUBRIC.md with evidence.

Verification:
- Plan must be specific enough that a competent developer could execute the top items without further research.
- All claims about current macOS state must be backed by repo inspection (not assumption).
- End with explicit "macOS support level after proposed changes: X/10" self-assessment.

If blocked:
- Entitlements or TCC prompt issues → record exact requirements and propose minimal viable change.
- ScreenCaptureKit vs legacy API ambiguity → provide recommended modern path with fallback.
```

## Notes
- Treat macOS support as a first-class platform, not an afterthought.
- Focus on closing the gap with the existing Windows implementation rather than adding new features.
- Reference the existing xerahs-pipeline-reliability-autonomy and xerahs-linux-support-improvement work where relevant for cross-platform consistency and release/publishing implications.
- This prompt is additive to the previous XerahS prompts; all three should be complementary.
```