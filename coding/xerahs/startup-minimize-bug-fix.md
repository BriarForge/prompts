---
tags: [xerahs, bug-fix, windows, startup, reusable]
category: xerahs
version: 1
---

# XerahS startup-minimize bug fix

```text
You are fixing a real XerahS production bug on Windows. Stay on the existing `develop` branch of `/Users/mike/Projects/KovaForge/xerahs`. Follow root AGENTS.md. No new branches, issues, or scope creep. Verify with the narrowest relevant tests + `dotnet build`.

## User feedback (verbatim)
"So I do see the setting for Xerahs to minimize on startup, but for some reason it always shows up on windows startup. I’ve tried unchecking and rechecking it, but it seems to still always pop-up rather than being minimized."

## Goal
Find root cause of "minimize on startup" being ignored on Windows boot/login, then ship a real fix. No band-aids.

## Investigate first
1. Map startup path: Windows Run/Startup registration -> process launch -> settings load -> window show/hide/minimize -> tray behavior.
2. Locate the setting key, defaults, persistence (file/registry/config), and every read/write site.
3. Trace cold start vs manual launch vs "start with Windows" paths - note any path that skips the minimize flag.
4. Check race/order bugs: window shown before settings load; Show()/Activate() after Minimize(); multi-instance restore; WinUI/WPF/WinForms ShowInTaskbar, WindowState, Visibility, tray init.
5. Check installer/autostart args (e.g. `--minimized`, `--autostart`) and whether autostart entry passes them.
6. Reproduce matrix: setting on/off, fresh login, reboot, already-running instance, first-run defaults.

## Deliver
- What the code does on startup
- What's broken + why (root cause, not symptom)
- Edge cases missed (first run, upgrade, multi-monitor, tray disabled, slow disk)
- Minimal fix that preserves behavior elsewhere
- Exact files/diff summary
- How to verify on Windows (steps + expected result)
- Residual risk

## Constraints
- Keep functionality identical except this bug
- Prefer fixing the real show/minimize ordering or autostart arg plumbing over UI copy changes
- If it's a settings bind/persist bug, fix persist + load, not only the checkbox
- Do not rewrite architecture

Work step-by-step. Fix only after root cause is identified.
```

# Notes
- ~1650 chars, under the 2000 cap.
- Verbatim user feedback preserved as the brief.
- `category: xerahs` matches the new `coding/xerahs/` home; frontmatter tag `xerahs` joins the others.