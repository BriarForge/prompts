---
tags: [refactoring, extract-function, readability, reusable]
category: improve
version: 1
last-used: 2026-11-16
---

# Split long functions

```text
Find functions that are too long and split them with Extract Function.
```

# Notes
- Symptom: one function is too long to read in one go.
- Refactoring: Extract Function. Behaviour must not change; run the tests before and after.
