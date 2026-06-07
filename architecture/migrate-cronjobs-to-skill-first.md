---
tags: [cron, skills, migration, architecture]
category: architecture
version: 1
---

# Migrate cronjobs to skill-first architecture

```text
You are migrating your cronjobs to a skill-first architecture.

Goal: Every cronjob must load one or more skills. No raw scripts or `no_agent=true` jobs allowed.

Steps:
1. Call `cronjob list` (all jobs).
2. For each job:
   - If it has `script` or `no_agent=true`, or runs a bare prompt: create a new skill (or reuse/extend existing) in the appropriate skills directory.
   - Skill must follow the exact `SKILL.md` template (frontmatter: name, description, version, author, tags, related_skills; required sections: Overview, Execution Instructions, Environment Variables table, Verification Checklist, Known Pitfalls).
   - Move any `.sh`/`.py` files into the skill's `scripts/` folder.
   - Update the cronjob using `cronjob update`: set `skills=[new-skill]`, remove `script`/`no_agent`, and write a clear prompt that invokes the skill.
3. Use environment variables for all paths. Tags must cover all domains touched.
4. Process in batches. Start with jobs that have `last_status=error`.
5. After each migration, verify the job definition no longer references raw scripts.

Output: list of migrated job_ids + skill names. Ask for decisions only on ambiguous cases.
```

# Notes
- Generalize the skills directory path as needed for the target environment.
- Prefer extending existing skills over creating new ones when logical.
