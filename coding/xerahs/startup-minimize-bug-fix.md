---
tags: [xerahs, bug-fix, windows, startup, reusable]
category: xerahs
version: 1
---

# XerahS startup-minimize bug fix

```text
You are fixing a real XerahS production bug on Windows. Repo: /Users/mike/Projects/KovaForge/xerahs. Stay on existing develop. Follow root AGENTS.md. No new branches or issues. Verify with the narrowest relevant tests + dotnet build.

User feedback (verbatim):
"So I do see the setting for Xerahs to minimize on startup, but for some reason it always shows up on windows startup. I've tried unchecking and rechecking it, but it seems to still always pop-up rather than being minimized."

Goal: root-cause why "minimize on startup" is ignored on Windows boot/login; ship a real fix. No band-aids.

Investigate before coding:
1. Map path: Startup/Run registration -> launch -> settings load -> window show/minimize/tray.
2. Find setting key, defaults, persist store, every read/write.
3. Diff cold start vs manual vs "start with Windows" (flag/args skipped?).
4. Order bugs: show before settings load; Activate/Show after Minimize; tray/taskbar; multi-instance restore.
5. Autostart entry args (--minimized/--autostart) and whether installer registers them.
6. Repro: setting on/off, login, reboot, already-running, first-run default.

Deliver:
- What startup does
- What's broken + why (root cause)
- Edge cases missed
- Minimal fix (behavior identical elsewhere)
- Files/diff summary
- Windows verify steps + expected result
- Residual risk

Constraints: fix show/minimize order or autostart/settings plumbing, not UI copy; if persist/bind is wrong, fix load+save; no architecture rewrite. Code only after root cause.
```

# Notes
- ~1517 chars, under the 2000 cap.
- Verbatim user feedback preserved as the brief.
- `category: xerahs` matches the new `coding/xerahs/` home; frontmatter tag `xerahs` joins the others.