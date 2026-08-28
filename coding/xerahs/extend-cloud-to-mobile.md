---
tags: [xerahs, mobile, ios, android, cloud, reusable]
category: xerahs
version: 1
---

# Extend XerahS Cloud to iOS + Android

```text
You are extending XerahS Cloud functionality to the production iOS and Android apps. Host: /Users/mike/Projects/KovaForge/xerahs. Mobile lives under src/mobile/ (NOT src/mobile-experimental/ - that is the MAUI/Avalonia spike with its own .sln; do not touch). Stay on existing develop. Follow root AGENTS.md. No new branches or issues. Verify with narrowest tests, Xcode build for iOS, Android .gradlew assembleDebug.

User intent: extend XerahS Cloud to iOS + Android apps at src/mobile/.

Goal: smallest usable v1 of XerahS Cloud features in both production mobile apps, end-to-end. Reuse each platform's existing architecture. No new UI stack.

Investigate first:
- Existing Cloud surface: endpoints, auth, payload contracts, upload/history/account flows. Map from primary sources; do not invent endpoints.
- Android shape: src/mobile/android (clean-arch: core/{common,data,domain}, feature/{settings,history,upload}); reuse where Cloud fits.
- iOS shape: src/mobile/ios/XerahSMobile (Core/Features/Assets/Navigation) + ShareExtension; reuse where Cloud fits.
- Confirm "Cloud" scope for v1 with the user before building if ambiguous.
- mobile-experimental out of scope; surface reusable Mobile.Core bits only if already proven.

Deliver (mobile clients):
- API surface used (endpoint, auth, error shape per call)
- Auth + token storage per platform (secure store; never secrets in repo)
- Feature breakdown: history, upload, settings, account - one flow per feature, end-to-end
- Offline behaviour (queue + retry, or online-only) - decide and call it out
- Per-platform implementation notes (files cited as they exist)
- Verify: Android Gradle build, iOS Xcode build, narrowest tests, one happy-path per feature per platform
- Residual risk / open questions

Constraints: reuse each platform's architecture; src/mobile only; behaviour-preserving elsewhere; no secrets in repo, no shared key file, no second UI stack; build only after the API surface and feature list are locked with the user.
```

# Notes
- Blends patterns from coding/{build-complete-app-from-scratch, design-and-build-scalable-system, build-production-ui-components, multi-agent-workflow, xerahs-prompt-creator}.
- Production mobile = src/mobile/. Experimental = src/mobile-experimental/. Out of scope.
- 1995 chars in the fenced body (under the 2k paste cap).
- Stays under coding/xerahs/ (repo path, develop, AGENTS.md, no new branches).