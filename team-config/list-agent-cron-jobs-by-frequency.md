# List Agent Cron Jobs by Frequency

```text
List every cron job for [AGENT_NAME] grouped by schedule type (one-shot, every, daily, weekly, fortnightly, disabled). For each job provide: the GUID in a code block, the name, the exact schedule (interval or cron expression in AWST), and any ⚠️ error indicator if it has consecutive failures. One GUID per code block. Group headings only, no code block around the list itself.
```

## Notes

- Replace `[AGENT_NAME]` with the target agent name (e.g. `vladislava`, `mikhail`, `nadia`, `viktor`).
- Requires the `cron` tool with `list` and individual `get` actions to resolve full schedule details.
- AWST = Australia/Western Standard Time (UTC+8).
