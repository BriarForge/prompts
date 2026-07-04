# XerahS Native Cross-Platform App Scope & ImageEditor Merge

**Category:** architecture  
**Tags:** [xerahs, native, cross-platform, winui, avalonia, imageeditor, hermes-prime]

```text
Fable 5 one-shot mode (high effort, long-run scaffolding + git workflow enabled):

Objective: Produce a detailed, actionable scope document for re-architecting XerahS as a true native cross-platform application (Windows + macOS + Linux) while maintaining a single shared settings and configuration architecture. The scope must also incorporate the planned merge of the ImageEditor submodule into the main repository.

Grounding (verified paths):
- XerahS repo root: /Users/mike/Projects/KovaForge/xerahs
- Submodule: ShareX.ImageEditor (currently external)
- Existing architecture docs: docs/architecture/PORTING_GUIDE.md, docs/architecture/xerahs_architecture_map.md, Directory.Build.props, .sln structure
- Current state: Avalonia-based with heavy Windows target (net10.0-windows10.0.26100.0)

Scope (in this run):
- In: Full analysis of current architecture, settings storage, plugin system, capture pipeline, editor components, and how they can be unified under native UI frameworks per platform while sharing the same settings model.
- Primary output: /Users/mike/Projects/KovaForge/xerahs/docs/NATIVE-CROSS-PLATFORM-SCOPE.md
- Allowed: Create the scope document with concrete recommendations, high-level architecture diagrams (Mermaid or ASCII), migration phases, risk assessment, and a dedicated section on the ImageEditor submodule merge.
- Out: Do not perform the actual merge or any code changes in this run. Do not trigger builds or release pipelines.
- Decide alone: Recommended native UI technology per platform (e.g. WinUI 3 / Windows App SDK for Windows, AppKit/SwiftUI interop or Avalonia for macOS, GTK4 or Avalonia for Linux), settings abstraction layer, plugin compatibility strategy, and migration sequencing.
- Surface for human sign-off: Any decision that would require new signing/notarization infrastructure, breaking changes to the .sln structure, or significant dependency additions.

Key areas the scope must cover:
1. Native UI strategy per platform (WinUI 3 recommended for Windows; justification for macOS and Linux choices)
2. Unified settings and configuration architecture (single source of truth, serialization, migration, per-platform overrides)
3. ImageEditor submodule merge plan (how to fold it into the main repo, namespace changes, build integration, removal of submodule)
4. Capture, editing, and upload pipeline abstraction (platform-native where beneficial, shared core)
5. Plugin and extension compatibility across native boundaries
6. Build, packaging, and distribution strategy for three platforms
7. Phased migration roadmap with clear milestones and rollback points
8. Risk register (technical debt, maintenance burden, contributor onboarding)

Workflow contract:
- Use git-aoife for all commits and final push.
- Commit progressively after each major section.
- Output primary artifact: /Users/mike/Projects/KovaForge/xerahs/docs/NATIVE-CROSS-PLATFORM-SCOPE.md
- Include: executive summary, detailed recommendations, Mermaid architecture diagrams, phased timeline, and explicit success criteria.

Done looks like:
1. NATIVE-CROSS-PLATFORM-SCOPE.md exists and is comprehensive.
2. The ImageEditor merge is treated as a first-class workstream inside the scope with concrete steps.
3. Settings architecture is defined such that all three native apps consume the same configuration model.
4. The document is committed and pushed via git-aoife.
5. Final rubric self-score per /Users/mike/Projects/BriarForge/prompts/fable5/translation-layer/RUBRIC.md with evidence.

Verification:
- The scope must be detailed enough that a team could begin implementation without further high-level research.
- All recommendations must be grounded in the current XerahS codebase.
- End with explicit "Recommended native stack: Windows=..., macOS=..., Linux=..." statement.

If blocked:
- Submodule merge conflicts with existing .sln structure → propose cleanest integration path.
- WinUI vs Avalonia decision points → provide clear trade-off analysis.
```

## Notes
- This prompt is additive to the previous XerahS Linux, macOS, and pipeline prompts.
- Treat the native re-architecture as a long-term strategic direction, not a quick port.
- The ImageEditor merge should be presented as an enabler for tighter editor integration across platforms.
```