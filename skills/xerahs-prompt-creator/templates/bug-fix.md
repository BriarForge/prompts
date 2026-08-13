# Bug-fix template (XerahS)

Use when the user reports a reproducible or production bug.

```text
You are fixing a real XerahS production bug [on <platform>]. Repo: /Users/mike/Projects/KovaForge/xerahs. Stay on existing develop. Follow root AGENTS.md. No new branches or issues. Verify with the narrowest relevant tests + dotnet build.

User feedback (verbatim):
"<paste user feedback unchanged>"

Goal: root-cause <one-line symptom>; ship a real fix. No band-aids.

Investigate before coding:
1. Map path: <entry point> -> <next hop> -> ... -> <failing surface>.
2. Find setting key / config / persist store and every read/write.
3. Diff cold start vs manual vs <other relevant modes>.
4. Order / race bugs: <specific ordering suspects for this bug>.
5. Installer / autostart args / feature flags touched.
6. Repro matrix: <states to test>.

Deliver:
- What the code does
- What's broken + why (root cause)
- Edge cases missed
- Minimal fix (behavior identical elsewhere)
- Files / diff summary
- Verify steps + expected result
- Residual risk

Constraints: fix root cause, not UI copy; fix persist/bind if it's wrong; no architecture rewrite. Code only after root cause.
```