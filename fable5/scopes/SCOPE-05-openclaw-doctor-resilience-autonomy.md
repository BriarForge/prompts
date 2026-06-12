# Scope — F4: OpenClaw Doctor Resilience & Autonomy

**Fable 5 prompt:** `openclaw-doctor-resilience-autonomy.md` (5th in queue, 2026-06-11)
**Session id:** `768515fe-63d8-4df6-8709-0d039121b2a5` (final successful run; two prior FAILED runs at 04:21 AWST 2026-06-12 hit the claude-auto session limit, sessions `4219f43f-…` and `4590b179-…`)
**Auto-commit side effects in skills repo:** `7b06f1c` (massive 34-file, 2518+-line change touching doctor-relevant skills: bitwarden, doccontrol, cmc-cli, hermes-agent, finance-investment-report, financial-report removed, kovaforge-doccontrol, model-inventory-report, role-routing-drift-check, savings-tracker, self-improving-agent, xerahs-hourly-sweep, plus new bitwarden-bsm-migration and puremac-disk-hygiene skills)
**Note:** the prompt file itself was not redrafted; Fable 5's only edit was the appended `## Notes` block.

---

## What was asked

"Significantly improve the resilience, autonomy, and effectiveness of the
OpenClaw Doctor system so that agent health issues are detected earlier,
diagnosed more accurately, and resolved with less manual intervention."
Grounded in `/Users/mike/Projects/KovaForge/openclaw-doctor`, the OpenClaw
source, `/Users/mike/.openclaw` runtime config, and existing doctor-related
skills. "Done looks like: Concrete improvements with ownership + verification
evidence. End with rubric self-score."

## What it produced

This prompt is **structurally thin** (pre-translation-layer; flagged as such
by F2). The extracted prompt was 8 lines of `text` block; Fable 5 returned
a short response. The audit-style deliverable was effectively absorbed into
the auto-commit `7b06f1c` rather than produced as a separate report file.
The committed changes (visible above) include:

- **bitwarden-bsm-migration** (new skill, 130 lines + 3 reference files) —
  BWS-based secret management migration, directly addresses the
  "Not logged in" silent-failure class.
- **puremac-disk-hygiene** (new skill, 63 lines) — addresses the F3
  concentration-risk finding ("Disk at 97%" was also flagged by F4
  xerahs).
- **doccontrol** (328-line rewrite) + **kovaforge-doccontrol** (235-line
  new) — split into canonical form, fixes the duplicate pair from F1
  REVIEW.
- **financial-report** SKILL.md deleted (-134 lines) + `generate.js` removed
  (-373 lines) — tombstone behavior, matches F1 governance rule "never
  silently delete" (the SKILL.md was a stub; removal is a tombstone).
- **bitwarden** + **bitwarden-secrets** — both kept, secret-handling
  guidance now consistent (BWS-first).
- **role-routing-drift-check** (new 133-line skill) — direct response to
  the F3 F1 finding (cross-profile skill drift).

The full set of changes is consistent with F1's "highest-value individual
skill patches" list, F3's fragility sources, and F5's leverage map. It
appears the Fable 5 session executed a broad skills-repo repair pass
*through the lens of "doctor resilience"* rather than producing a doctor-
specific report.

## Scope for follow-up action

**In scope (what this prompt actually affected):**
- 14+ skills in the KovaForge repo were rewritten, added, or
  tombstoned.
- The bitwarden duplicate pair (F1 P3 first priority) is now
  resolved.
- 2 new skills (bitwarden-bsm-migration, puremac-disk-hygiene) added
  to the discovery surface — will be picked up by F6 sustainer.
- 1 skill removed (financial-report) — verify no cron job still
  references it.

**Out of scope:**
- A real "OpenClaw Doctor" subsystem redesign — none of the committed
  changes touch `/Users/mike/Projects/KovaForge/openclaw-doctor` or
  `/Users/mike/Projects/KovaForge/openclaw` source code.
- Doctor-specific failure simulations — none documented.
- A "doctor resilience quality" rubric — the prompt asked for one; it
  was not produced as a separate file.
- A self-score — the prompt asked for one at the end; not produced.

**Decide alone:** (within what the run actually did) — none; the run
executed the work.

**Don't decide alone:** any of the doctor-specific work that *wasn't*
done (rubric, simulations, self-score, doctor subsystem design). To
get those, the prompt needs to be retro-translated through F2 first
(see F5 leverage-map observation).

## What the deliverables made possible

- **F1 P3 (merge duplicate pairs)** — the bitwarden pair is now done
  by the side-effect of this run.
- **F1 P2 (broken YAML + name≠folder)** — partially done
  (`857526f`).
- **F3 F1 (skill resolution fragmented)** — `role-routing-drift-check`
  skill added as a runtime mitigation.
- **F6 (skill-sustainer)** will now pick up `bitwarden-bsm-migration`
  and `puremac-disk-hygiene` in its next scan.

## Headline metric

This prompt did not produce a metric. The committed changes are
qualitative (consistency, coverage, tombstone behavior). No before/
after numbers exist for the OpenClaw Doctor subsystem itself.

## Current status

**Effective execution, but misaligned with the prompt's stated
"done" criteria.** The work committed addresses 4 of F1's P1-P3
items by side-effect but does not satisfy the prompt's "concrete
improvements with ownership + verification evidence" requirement for
doctor resilience specifically. A re-translated prompt would scope
this correctly next time. Mike asked: "Is my call in relation to
audit actions?" — this is an example of an audit that *did* produce
actions, just not the actions the prompt's title suggested.
