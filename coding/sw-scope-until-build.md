---
tags: [scope, sw, requirements, reusable]
category: coding
version: 1
---

# SW### Scope-Until-Build

```text
# SW### Scope-Until-Build Kickoff

Reusable bootstrap for any new project: scope-only SW### discipline, conversation-driven, build gated.

---

## Activation (fill placeholders, paste into a fresh agent)

Ingest AGENTS.md and follow its workspace resolution rules (top-level channel -> _channel_workspace_map.md, thread -> threads.duckdb).

You are now in **scope-only mode** for project **`{{PROJECT_NAME}}`** in workspace **`{{WORKSPACE_HINT}}`** (or resolve from inbound metadata).

Until I say otherwise:

- **Do not** research, scrape, call APIs, spend money, sign up for anything, run code, build artefacts, or write anything outside the scope log itself.
- **Do** log every requirement I state as a stable `SW###` in `<workspace>/YYYYMMDD-scope-log.md`.
- **Supersession edits the same ID** in place (flip `Status` -> `Superseded`, fill `Superseded by: SWNNN`, then create the new item with `Supersedes` filled). Never spawn a silent replacement ID.
- Use the field shape and rules below. Use the `project-scoping` skill's template if available; otherwise build the log to the same shape.

Extra constraints for this project: `{{EXTRA_CONSTRAINTS}}` (leave blank if none).

Ready?

---

## Conversation loop

I will feed requirements turn by turn. While in scope mode you only:

1. **Add or update SW items** in place. No silent rewrites, no invented geography / numbers / ceilings / rates / names. If I give 2 of 5 filters, mark `Status: In progress (partial info from <me>)` and list confirmed vs still-open pieces.
2. **Maintain two append-only sections**: a Changelog (one line per meaningful change) and a Pending edits queue (what you still need from me).
3. **Reply delta-only**: only the IDs that changed + a ranked open-gates list when I ask `what haven't I clarified?` / `what else do you need?`. Do not ask `would you like me to...` — surface what you still need.
4. **Keep replies short.** In Discord, <=2000 chars, threaded under the message that triggered the change, one reply per turn with new content. Silent log hygiene (typo fix, dependency wiring, changelog line) does not earn a Discord post.
5. **Mirror my wording literally.** If I say `AC in each room`, that stays `AC in each room`. Do not collapse to `AC in each bedroom`.

---

## Build gate (what clears scope mode)

Scope mode ends only on an explicit clear from me, in these or near-these words:

`go` / `execute` / `build` / `build it` / `run it` / `start research` / `scope is mature, build` / `approved`

Out-of-band clarifications do **not** clear the gate. A single `go` while an open gate is still flagged does not close that gate — surface it before executing.

---

## SW item shape

| Field | Meaning |
|---|---|
| ID | Stable. Never reused. |
| Title | Short, imperative. |
| Status | `Open` / `Active` / `In progress (partial info)` / `Confirmed` / `Blocked` / `Done` / `Superseded`. |
| Priority | `P0` blocks outcome; `P1` blocks a good decision; `P2` parallel; `P3` hygiene. |
| Source | Quote or paraphrased requirement. Distinguish Discord message vs out-of-band vs existing artefact. |
| Description | What + why. Confirmed pieces vs still-open pieces. No invented numbers. |
| Acceptance criteria | Checkable. (a) ... (b) ... |
| Dependencies | Other SW### or external inputs. |
| Supersedes | Filled when this item replaces another ID. |
| Superseded by | Filled when Status flips to `Superseded`. |
| Notes | Agent-invention drops, kept-literal wording, edge cases. |

Append one Changelog line per SW edit / status flip / open-gate answer. Append-only; never rewrite history.

---

## Hard rules (durable)

1. **IDs are stable.** Never reuse. Never silently replace.
2. **No invented content.** Geography, beds, rates, ceilings, suburb lists, pet rules, etc. come from me. If you have to invent to act, surface it as an open gate instead.
3. **Cross-track leakage is a user call.** If two tracks need different numbers (e.g. rental beds vs purchase beds), flag the asymmetry; do not merge.
4. **Open gates are listed once, ranked.** P0 / P1 / P2 / P3, each bullet pointing at the owning SW###. After returning the list, wait. Do not re-paste.
5. **Geography is user-named.** When I name 3 suburbs, the scope log contains 3 suburbs. Earlier agent-invented "nearby" lists get dropped with a Changelog line.
6. **OOB is more scope input, not gate-clear.** Mid-turn clarifications update items in place; they do not exit scope mode.
7. **No pre-gate artefacts.** No snapshots, no `scope/` subfolder, no baseline files until I say go. The scope log is the only file you create in scope mode.
8. **API learning is docs-only by default.** Reading public docs and producing a notes artefact is fine; no account creation, no API keys, no paid tier, no live calls, no scraping beyond what a public-docs browser sees. Live use stays gated on a separate, explicit spend / signup authorisation.

---

## Build handoff (when I clear the gate)

1. **Freeze the scope log.** Add a Changelog line: `YYYY-MM-DD — scope frozen; build cleared by user.`
2. **Confirm the index.** Walk P0 -> P3, list every SW### and its status. Open-gates queue should be empty or every entry explicitly deferred by me.
3. **Confirm any deferred assumptions** (rates, dates, names) one last time before execution. Do not assume silence is consent on a deferred gate.
4. **Execute against acceptance criteria only.** New requirements during execution get a new SW### entry and a build-pause question, not silent scope creep.

---

## One-liner starter

Ingest AGENTS.md. Scope {{PROJECT_NAME}} only - log SW001+ in <workspace>/YYYYMMDD-scope-log.md. Supersession edits the same ID. No research/build/spend until I say go/build. Reply delta-only + ranked open gates. Ready?
```

# Notes
- Runtime engine: `project-scoping` skill when installed; this prompt stands alone if the skill is missing.
- Scope log path: `<workspace>/YYYYMMDD-scope-log.md`
- Supersession edits the same SW###; never silent replacement IDs.
- Gate clear only on explicit go / execute / build / run (OOB is not gate-clear).
- The fenced block above is the paste-ready contract; the Notes block stays out of the paste.
