---
tags: [refactoring, naming, readability, reusable]
category: improve
version: 1
last-used: 2026-11-16
---

# Rename unclear names

```text
Find names that don't say what they mean and rename them.
```

# Notes
- Symptom: you can't tell what something does from its name.
- Refactoring: Rename. Update every reference; check for string-based uses (config keys, reflection, docs).
