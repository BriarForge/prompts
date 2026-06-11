# Example 3 — Monthly Financial Health Report

**Source:** the recurring objective embedded in the financial channel's
`AGENTS.md` (`/Users/mike/Library/CloudStorage/OneDrive-Personal/AI/financial/AGENTS.md`).
Unlike examples 1–2, this objective has never lived as a goal block at all — it
exists as scattered rules ("run the report", a Playwright gate, an SMSF rule,
output conventions) that an agent must assemble per run. The translation layer's
job here is consolidation, not repair.

## What the scattered form costs

Every run re-derives the same sequence from six AGENTS.md sections, and the
documented failure mode ("If SMSF shows $0 values, the DATA block is stale")
exists precisely because agents have edited the template and uploaded without
regenerating. The verification gate is documented but nothing forces an agent
to treat it as blocking. As an implicit goal it scores roughly **7/14**
(grounding is excellent, done/verification are spread across sections, no
failure fallbacks beyond one warning).

## Fable-ready translation

```text
Fable 5 one-shot mode (high effort):

Objective: The current month's personal financial health report is regenerated
from live data, passes the Playwright smoke gate, and is published via xerahs,
with the share URL reported back.

Grounding (verified 2026-06-11):
- /Users/mike/Projects/KovaForge/financial-report/generate.js — generator (git, Path 1)
- /Users/mike/Library/CloudStorage/OneDrive-Personal/AI/financial/financial.duckdb — ledger
- /Users/mike/Library/CloudStorage/OneDrive-Personal/AI/financial/reports/financial-health-report.html — template
- /Users/mike/Library/CloudStorage/OneDrive-Personal/AI/investing/context/goals.md — read BEFORE generating
- Full Playwright script: /Users/mike/Projects/KovaForge/financial-report/SKILL.md

Scope:
- In: template edits if needed, regeneration, smoke test, upload.
- Out: NEVER mix SMSF transactions into personal cash-flow sections; do NOT
  hand-edit generated output and upload (regenerate instead); do NOT remove the
  .page flex wrapper; do NOT commit the DuckDB file (gitignored).
- Decide alone: cosmetic template fixes required to pass the gate.
- Surface, don't act: any change to category exclusion rules or report structure.

Workflow contract:
- Order is fixed: edit template (if needed) → node generate.js → Playwright
  smoke test → xerahs upload. Never skip or reorder.
- Conventions for report text: no markdown tables, no em dashes.
- Output: AI/financial/reports/YYYYMM-financial-health-report.html
- Path 1 changes committed via git-aoife; Paths 2/3 are OneDrive, not git.

Done looks like:
1. reports/YYYYMM-financial-health-report.html exists for the current month
   with a generation timestamp from this run.
2. Playwright smoke test passed: title loads, scorecard populated, nav switches
   sections, FY selector works, zero console errors.
3. SMSF section shows non-zero values (stale-DATA-block canary).
4. `xerahs upload ... --as-file --json` succeeded; share URL captured in the
   run summary.

Verification:
- Item 1 → file mtime is during this run.
- Item 2 → the Playwright script from SKILL.md exits 0; paste its output.
- Item 3 → grep the generated HTML's DATA block for SMSF totals != 0.
- Item 4 → upload JSON response contains the URL; URL returns HTTP 200.

If blocked:
- Playwright fails → fix template, regenerate, retest; loop. NEVER upload on a
  red gate; if unfixable, stop and report the failing assertion with output.
- DuckDB missing/locked → stop and report; do not synthesize data.
```

## Validation

Rubric: 1: **2** (regenerated + gated + published + URL reported). 2: **2** (all
five paths copied from AGENTS.md, which declares them verified; spot-checked the
project root today). 3: **2** (four binary items; item 3 turns the documented $0
failure mode into a canary check). 4: **2** (mtime, exit code, grep, HTTP 200).
5: **2** (SMSF rule, no-hand-edit rule, .page rule all promoted from prose to
hard exclusions). 6: **2** (fixed ordering, conventions, output path, git split
between Paths). 7: **2** (red-gate loop with a hard stop; locked-DB stop).
**Total: 14/14 — Fable-ready.**

Simulated-question test: "Which FY/month?" (current month, from objective +
output filename pattern), "Can I just tweak the HTML and upload?" (Scope: Out),
"What does the smoke test check?" (Done item 2 + SKILL.md pointer), "What if
the gate keeps failing?" (If blocked) — all answered in-block.

This example shows the third use of the layer: not writing new goals and not
repairing broken ones, but **compiling standing documentation into a runnable
goal block** so each recurring run starts from the same contract.
