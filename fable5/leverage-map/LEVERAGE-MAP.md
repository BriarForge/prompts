# Leverage-Point Map — Next 90 Days

**Date:** 2026-06-12 · **Author:** Fable 5 (leverage-point-mapping run)
**Inputs (all verified live this run or in the two prior audited runs):**
KovaForge skills (`/Users/mike/Projects/KovaForge/skills/`, 58 skills, audit
`REVIEW-2026-06-11.md`), Aoife skills (`~/.hermes/profiles/aoife/skills/`),
protocols (`/Users/mike/.hermes/protocols/`), antifragility baseline
(`fable5/antifragility/ASSESSMENT.md`, system 4.0/10), queue state
(`progress.json`, `runs.log`).

**Optimization target (from the brief):** reduce future user steering and
increase autonomous execution quality over 90 days. Every change below is
verified against the principle *"this should make the system require less
explicit direction, not more"* — including the failure mode where it would
add direction, and the mitigation.

---

## 0. What "steering" measurably is here

Before picking leverage points, the thing being minimized needs a unit.
A **steering event** = any time a human (Mike, or a reconciling agent acting
on his behalf) must intervene in work the system was supposed to do alone:
repairing a goal, requeueing a run, reconciling state, noticing a failure,
or correcting an agent that followed wrong guidance.

Measured baseline, last ~48h, autonomous pipeline only (each verified):

| # | Steering event | Evidence |
|---|---|---|
| 1 | Manual SIGKILL + requeue of skills-review run | `runs.log` 2026-06-11 12:50Z |
| 2 | Manual repair of truncated xerahs queue prompt (broken code fence) | translation-layer memory |
| 3 | Manual reconciliation of `progress.json` after runner killed pre-mark-done | `progress.json` notes (Vladislava, 2026-06-12 04:05) |
| 4 | Two runs had to *guess* output paths (antifragility run, this run) — latent steering each time a guess is wrong | ASSESSMENT.md §3-F5; this prompt names no output path |
| 5 | Two zombie cron jobs failing silently, awaiting a human to notice | PureMac + SpaceX, jobs.json (live) |

**Baseline: ≥5 steering events / 48h** on the autonomous pipeline, plus
unbounded latent debt (the zombies). Historical confirmation that steering is
the system's scaling limit: the `high-agency-execution` skill (Aoife, v1.1) is
a fossil record of repeated user-frustration corrections ("You aren't
proactive enough", "create the damn fork") that had to be hand-crystallized
into rules. The capture mechanism exists (`self-improving-agent` skill) but
fires only when a session remembers to invoke it — i.e., *after* frustration.

**90-day target: ≤1 steering event per 30 days** on the autonomous pipeline,
with each remaining event consumed by the metabolism loop (L4) exactly once.

## 1. The four changes (minimal set)

Selection logic: of everything found across the three roots (KovaForge P1–P7
plan, antifragility F1–F5, protocol gaps), these four are the subset where
each change removes a *class* of steering rather than an instance, and the
rest of the findings either hang off one of these four as line items or were
deliberately excluded (§5). They map to the four seams where direction
currently leaks in: goals, knowledge, failures, and learning.

---

### L1. Validated goal contract at the execution seam

*Absorbs: antifragility F5 + F4(c) runner preflight; builds on the existing
translation layer.*

**The bottleneck.** The runner executes whatever `sed` extracts. One broken
fence already truncated a goal silently; 4 of 8 queue prompts predate the
goal rubric; this very prompt extracts to 8 lines with no output path, no
commit cadence, no failure contract — so the run *must* guess, and every
guess is deferred steering. Steering events #1–#4 above all live at this seam.

**The change.**
(a) `run-next-fable5.sh` validates the *extracted* goal (non-empty, exactly
one "Done looks like", names an output path, contains a commit-cadence
contract for long runs); on failure marks the prompt `needs-repair` in
`progress.json` and moves to the next instead of executing half a goal.
(b) `claude-auto` auth preflight before extraction; park queue with visible
reason on failure (the documented past failure mode was silent).
(c) Retranslate the 4 remaining pre-rubric prompts
(`openclaw-doctor-resilience-autonomy`, `skill-evolution-maintenance-loop`,
`xerahs-pipeline-reliability-autonomy`, `zero-zombie-initiative-os`) through
`translation-layer/GOAL-TEMPLATE.md` before their turn.

| Metric | Before | After (day 30) |
|---|---|---|
| Pre-rubric prompts in queue | 4/8 | 0 |
| Truncated/half-executed goals possible at runner seam | yes (1 incident) | structurally no (check runs on what executes) |
| Runs forced to guess scope/output path | 2 of last 3 | 0 (template requires it; runner enforces) |
| Queue failure mode | silent lie / manual reconcile | parked with reason |

**Less-direction check.** Risk of *more* direction: the template makes Mike
fill 6 phases per goal. Mitigation/verdict: that is one front-loaded
authoring pass replacing N mid-run interventions and post-run reconciliations
— measured by the count of "guessed/invented" notes in run results (currently
≥1 per run; target 0). Direction moves earlier and shrinks; it does not grow.

**Owner:** Aoife. **Effort:** ~1 day. **Dependencies:** translation layer
(done). **Rollback:** the runner check is ~10 guarded lines; one-strike
revert if it parks a prompt a human judges well-formed.

---

### L2. One source of truth for capability knowledge

*Absorbs: antifragility F1 + KovaForge plan P1–P5 (CI lint, YAML fixes,
duplicate merges, single tag schema).*

**The bottleneck.** Skill resolution spans ≥5 roots with zero validation.
Two cron jobs reference skills that resolve **nowhere**; one resolves only in
another profile; 39 dangling `related_skills`; 4 YAML-broken frontmatters;
5 duplicate pairs of which 2 give **contradictory** guidance (bitwarden pair
disagrees on secret handling; the two delegation skills carry different
routing tables under byte-identical descriptions). A contradictory skill pair
is a steering generator: whichever copy an agent loads, roughly half its
actions will need human correction — and the correction never propagates,
because nothing connects the two copies.

**The change.**
(a) `validate-ecosystem.py`: registry of every skill name → path(s) across
all five roots; fails on unresolvable/cross-profile cron refs, duplicate
names with divergent content, dangling `related_skills`. Run pre-commit, as a
weekly cron, and at schedule time (job referencing an unresolvable skill is
created paused with reason).
(b) One-time cleanup it then keeps fixed: quote the 4 broken YAML
descriptions, merge the 5 duplicate pairs (contradictory two first, tombstone
with `superseded_by:`), script-strip stale `vladislava-` prefixes, migrate to
the majority top-level `tags:` schema and update AGENTS.md to match.
(c) **Precondition:** read Hermes source to learn actual resolution
precedence (which root wins on name collision) before fixing registry
semantics — currently inferred from filesystem only (open question in
antifragility CLAUDE.md).

| Metric | Before | After (day 60) |
|---|---|---|
| Cron skill refs resolving nowhere | 2 (+1 cross-profile) | 0, held at 0 by weekly lint |
| Contradictory duplicate pairs | 2 (5 dup pairs total) | 0; creation path closed by lint dup-gate |
| Dangling related_skills | 39 | 0 |
| YAML-invisible skills | 4 | 0 |
| Enforcement runs | none | pre-commit + CI + schedule-time + weekly |
| KovaForge repo rubric | 4.3/10 | ≈7/10 (rerun audit parser) |

**Less-direction check.** Risk: a blocking lint that false-positives becomes
a new chore (human overrides = steering). Mitigation: report-only for 2
weeks, promote to blocking only if false-positive rate <5% of flags, demote
on two wrongful blocks (criteria already written in ASSESSMENT §3-F1 — reuse,
don't improvise). Verdict: agents stop needing a human to arbitrate which of
two contradictory instructions is real; authoring gains a duplicate gate so
the class stops being created. Direction strictly decreases.

**Owner:** Aoife (registry/policy) + Declan (implementation). **Effort:**
~1.5 days. **Dependencies:** Hermes-precedence read (c) gates registry
semantics; nothing else.

---

### L3. Closed-loop failure handling

*Absorbs: antifragility F2 + F4(a,b) (backup manifest, daily skills sync).*

**The bottleneck.** Failure detection is currently "Mike happens to look."
Both failing cron jobs are enabled, "scheduled", and erroring — one daily —
and the PureMac job delivers disk-hygiene errors to *#investing / 4 year
journey*. The Anti-Zombie Protocol (BRF-OPS-POL-002) exists on paper with no
mechanical enforcement on the Hermes side. Mean time-to-detect is unbounded;
every detection that does happen is a steering event. Vladislava's
`coo-self-audit` already does exactly this every 3 days **for OpenClaw** —
the Hermes/Aoife side has no equivalent.

**The change.**
(a) Cron health sentinel — extend the existing `cron-load-balancer` (it
already parses `jobs.json`): flag `last_status==error`, N≥3 consecutive
failures, refs that don't resolve (reuses L2's resolver in phase 2),
delivery-channel mismatch. One daily digest to a single ops channel.
(b) Phase 2 after 2 weeks of accurate digests: auto-pause at N≥5 consecutive
failures with `paused_reason` set (fields already in schema).
(c) Durability line items: skills-repo sync weekly→daily (one-line cron
change); backup job fails loudly if a manifest item (`jobs.json`, profile
skills, scripts, `.curator_state`) is missing.
(d) Fix the two live zombies and the PureMac channel misroute as the
sentinel's first verified catches.

| Metric | Before | After (day 60) |
|---|---|---|
| MTTD for a failing cron job | unbounded (SpaceX failing daily, unnoticed) | <24h (digest); measured as now−first_error_run |
| Live zombie jobs | 2 | 0; recurrence auto-paused with reason |
| Ops signal surface Mike must scan | ~14 Discord channels | 1 digest |
| Machine-local unpushed skill work | up to 7 days | ≤1 day |
| Human role in failure triage | detector + triager | reader of pre-triaged digest |

**Less-direction check.** Risk: auto-pause creates unpause chores; the digest
becomes a 15th channel to ignore. Mitigation: one-strike rollback on wrongful
auto-pause (per ASSESSMENT §3-F2); the digest *replaces* 14-channel scanning
rather than adding to it — net attention demand drops. Verdict: failures
self-surface and self-quarantine; the human stops being the monitoring
system. Direction decreases.

**Owner:** Declan (operator lane), escalation per BRF-OPS-POL-002.
**Effort:** ~1 day. **Dependencies:** phase 1 is independent (jq over
jobs.json); phase 2 ref-checking depends on L2's resolver.

---

### L4. Mechanical incident→control metabolism

*Absorbs: antifragility F3 + F4(d) recovery rehearsal; carriers already
exist: `self-improving-agent` (Aoife), `coo-self-audit` (Vladislava/OpenClaw).*

**The bottleneck.** This is the leverage point above the other three: the
rate at which steering events get *permanently consumed*. The system has
metabolized stress exactly once well (SIGKILL → success gate + translation
layer), but ad hoc: no incident log, no rule that an incident must yield a
control, governance that nothing executes (duplicate `BRF-OPS-POL-003` IDs
with divergent content; 0/8 policies machine-checked; AGENTS.md ignored by
60% of its own repo). Without this change, L1–L3 are one-time cleanups that
decay the way AGENTS.md did; with it, every future steering event becomes a
rule and the steering rate trends down structurally.

**The change.**
(a) Protocol integrity lint (lives beside L2's): doc-ID uniqueness,
index↔filesystem reconciliation, required header block. Immediate cleanup:
merge/renumber the POL-003 pair, index the survivor.
(b) Incident log (`fable5/antifragility/CLAUDE.md` already has the operating
rule — make it a file with one row per incident: date, fragility class F1–F6+,
resulting check or written reason why not).
(c) Standing rule: a policy PR containing a machine-checkable clause ships
the check or records why not — target 4/8 policies checked by day 90.
(d) Weekly Aoife self-audit cron — the Hermes mirror of `coo-self-audit` —
whose input is L3's digests and the incident log, and whose output is patches
via `self-improving-agent`'s existing workflow (it already mandates "patch
the skill immediately"; this gives it a scheduled trigger instead of relying
on in-session recall).
(e) `RECOVERY.md` fresh-machine restore runbook, rehearsed once (the
rehearsal is the verification).

| Metric | Before | After (day 90) |
|---|---|---|
| Incident→control conversion | ad hoc (1 ever, human-driven) | mechanical: every logged incident → check or written waiver |
| Policies with automated checks | 0/8 | 4/8 |
| Duplicate protocol IDs | 1 (POL-003) | 0; class killed by edit-time uniqueness check |
| Self-improvement trigger | in-session recall (after user frustration) | scheduled weekly + digest-fed (before frustration) |
| Machine-loss event | unbounded, unrehearsed | bounded, measured restore time |

**Less-direction check.** Risk: "every policy ships a check" becomes
bureaucracy that slows changes (process = direction overhead). Mitigation:
the "written reason why not" escape valve; revert to advisory if it stalls
more than one policy change per month (per ASSESSMENT §3-F3). Verdict: this
is the only change whose *output* is reduced future direction — it converts
each remaining steering event into a permanent rule, so the other three
changes compound instead of decaying. Direction decreases over time by
construction.

**Owner:** Aoife (governance lane) + Viktor (OpenClaw mirror of the
durability pass). **Effort:** ~1.5 days spread across the quarter.
**Dependencies:** needs L1–L3's enforcement surfaces to attach new checks to;
incident log + POL-003 merge can start day 1.

## 2. Dependency map

```
Hermes-source precedence read ──► L2 registry semantics
                                      │
translation layer (done) ──► L1 runner lint ──► queue retranslation (4 prompts)
                                      │
                    L2 resolver ──────┼──► L3 phase-2 ref checks
                                      │
L3 phase-1 digest (independent) ──────┤
                                      ▼
            L2 lint infra ──► L4 protocol/policy checks (same CI home)
            L3 digest + incident log ──► L4 weekly self-audit (its feed)
            L1+L2+L3 enforcement surfaces ──► L4 metabolism has somewhere
                                              to put each new rule
```

Critical path: **L2's resolver** (feeds L3 phase 2 and shares lint
infrastructure with L4). **L1 and L3 phase 1 have no upstream dependencies**
— they start immediately and remove the two currently-live steering sources
(malformed goals, zombie jobs).

Interaction with the remaining queue: the four pending prompts overlap this
map (`zero-zombie-initiative-os` ≈ L3, `skill-evolution-maintenance-loop` ≈
L4, `openclaw-doctor-resilience-autonomy` ≈ L4's Viktor mirror,
`xerahs-pipeline-reliability-autonomy` ≈ L1 patterns applied to xerahs).
Retranslating them (L1c) should scope each one as *executing its slice of
this map* rather than re-auditing — that is itself a steering reduction:
four future runs inherit their direction from this document instead of
guessing.

## 3. 30/60/90-day rollout

**Days 0–30 — close the live leaks, everything report-only.**
- L1 complete: runner lint + auth preflight + retranslate 4 prompts (~1 day).
- L2: Hermes-precedence read; `validate-ecosystem.py` report-only; 4 YAML
  fixes; merge the 2 contradictory pairs (bitwarden, delegation).
- L3 phase 1: sentinel digest live to one ops channel; fix both zombies +
  PureMac misroute; skills sync daily; backup manifest check.
- L4: incident log exists; POL-003 merged; protocol integrity lint running.
- *Gate to next phase:* 2 weeks of digest accuracy; lint FP rate measured.

**Days 31–60 — promote to blocking, finish unification.**
- L2: pre-commit + CI + schedule-time gate blocking (if FP <5%); remaining 3
  dup merges; `vladislava-` ref fix; tag-schema migration + AGENTS.md update.
- L3 phase 2: auto-pause at N≥5; resolver-backed ref checks in sentinel.
- L4: first 2 policy checks shipped (Git Policy wrapper check, Secrets Policy
  scan — both named machine-checkable in ASSESSMENT); weekly Aoife self-audit
  cron live.
- *Gate:* KovaForge audit parser rerun — expect ≥6.5/10.

**Days 61–90 — make it compound, then measure.**
- L4: policy-PR-ships-check rule active; 4/8 policies checked; RECOVERY.md
  rehearsed once on a clean environment.
- Re-measure everything (all deterministic, commands already exist):
  KovaForge rubric rerun (target ≥7/10), antifragility §2 queries (target
  system ≥7.0/10), steering-event count over trailing 30 days (target ≤1,
  each one logged with a resulting control).

Total new build effort: **~5 days spread over the quarter**, all owned within
the existing BRF-ORG-POL-001 role matrix; no new infrastructure, no new
machines, no new agents.

## 4. The principle check, summarized

| Change | Where direction decreases | Where it could increase | Mitigation (pre-committed) |
|---|---|---|---|
| L1 goal contract | no mid-run guessing, no post-run reconciling | template authoring burden | one front-load replaces N interventions; one-strike runner-lint revert |
| L2 knowledge unification | no human arbitration of contradictory guidance | lint false-positives | report-only→<5% FP gate→blocking; demote on 2 wrongful blocks |
| L3 failure loop | human stops being the monitor; 14 channels→1 digest | unpause chores; digest fatigue | one-strike auto-pause rollback; digest replaces, not adds |
| L4 metabolism | each steering event consumed once, permanently | check-shipping bureaucracy | written-waiver escape valve; revert-to-advisory threshold |

## 5. Deliberately excluded (minimality)

- **Stub backfill + path-portability sweep (KovaForge P6–P7):** quality
  improvements, but a stub rarely *generates steering* — it just fails to
  help. The L2 linter's warning tier ratchets these on new skills for free.
- **Multi-machine redundancy:** the single-Mac/single-human concentration
  (F4 core) is a structural ceiling a 90-day process change can't lift;
  L3(c)+L4(e) cap its blast radius instead.
- **Discord channel re-architecture:** only the ops-digest channel matters
  for steering; reorganizing the other ~13 is cosmetic.
- **New orchestration tooling:** every change above lands inside files and
  jobs that already exist (`run-next-fable5.sh`, `cron-load-balancer`,
  `jobs.json`, protocols tree, CI on the skills repo). Adding new
  infrastructure would itself create direction demand.

---
*Self-check against the brief: 4 changes (≤4 ✓), each with before/after
metrics (✓), dependency map (§2 ✓), 30/60/90 sequence (§3 ✓), per-change
verification of the less-direction principle including failure modes (§1
blocks + §4 ✓). Steering defined as a measurable unit (§0) so the 90-day
claim is falsifiable.*
