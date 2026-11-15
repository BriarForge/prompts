---
tags: [refactoring, duplication, dry, reusable]
category: improve
version: 1
last-used: 2026-11-16
---

# Merge duplicated code

```text
Find duplicated code and merge it into one function.
```

# Notes
- Symptom: you make the same fix in several places.
- Refactoring: pull the repeated logic into one function and call it from each place.
