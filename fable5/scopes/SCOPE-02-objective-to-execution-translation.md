# Scope 02 — Adopt the Translation Layer as a Gate

**Drives from:** `fable5/translation-layer/` (RUBRIC, GOAL-TEMPLATE,
examples 01–03, CLAUDE.md, README) — already built and committed.
**Goal:** Make the 7-criterion rubric a *blocking gate* at the Fable 5
runner seam so future prompts cannot execute at <12/14 with any
criterion at 0. Retro-translate the 4 pre-rubric prompts in the
current queue before any future run.
**Owner of this scope:** Aoife (owns the layer + the queue).

## Steps

### 1. Hermes resolution-precedence read (½ day, Aoife)
- Read Hermes source to learn the actual skill-name collision rule
  (which root wins). The ecosystem registry in Scope 03 step 1
  cannot fix semantics without this.
- Output: one-paragraph rule written to
  `fable5/translation-layer/REFERENCES.md`.

### 2. Runner-side validation in `run-next-fable5.sh` (½ day, Aoife)
- Insert post-extraction check (~10 guarded lines):
  - non-empty
  - exactly one "Done looks like:" clause
  - names an `Output:` path (fence or path glob)
  - contains a commit-cadence contract for runs > 5 min
- On failure: mark prompt `needs-repair` in `progress.json` (new
  status) and move to next prompt instead of executing half a goal.

### 3. Auth preflight in runner (½ day, Aoife)
- Check `claude-auto` auth *before* extracting the goal.
- On auth failure: park queue with a visible reason; do not mark
  the prompt as `done`.

### 4. Retro-translate the 4 pre-rubric prompts (1 day, Aoife)
The 4 prompts in the current queue that predate the rubric:
- `openclaw-doctor-resilience-autonomy.md` (5th in queue)
- `skill-evolution-maintenance-loop.md` (6th)
- `xerahs-pipeline-reliability-autonomy.md` (7th) — already repaired
  structurally using example 02; re-score against the full rubric.
- `zero-zombie-initiative-os.md` (8th) — produced no artifact;
  retro-translate and re-queue with explicit `Output:` clause.

For each: walk the 6-phase checklist in
`translation-layer/GOAL-TEMPLATE.md`, write the translated goal to
a sibling `*.translated.md`, score against the rubric, store the
score in `progress.json` (new field `rubric_score`).

### 5. Examples set expansion (½ day, Aoife)
- Add example 04 covering the antifragility prompt (which had to
  invent its own output path).
- Add example 05 covering a `needs-repair` outcome (negative example).

## Verification

- `bash /Users/mike/Projects/BriarForge/prompts/fable5/run-next-fable5.sh --dry-run`
  on a copy of the queue with a deliberately malformed prompt:
  runner refuses to execute and marks `needs-repair`.
- `jq '.[] | .rubric_score' fable5/progress.json` — all 8 prompts
  have a score, the 4 retro-translated ones are ≥12/14.
- One Fable 5 run that previously produced no artifact (F7
  zero-zombie pattern) now produces a marked deliverable at the
  stated `Output:` path.

## Out of scope

- The translation layer's UX (no editor, no `/translate` skill).
- Re-scoring the 4 filesystem-deliverable prompts (F1, F2, F3, F5)
  that already produced strong artifacts.
- Auto-translation: the layer stays human-in-the-loop; the runner
  validates, it does not write goals.

## Cross-scope

- **Scope 03 (antifragility F5)** — this scope IS the F5 upgrade
  (runner lint + retranslation).
- **Scope 04 (leverage map L1)** — this scope delivers L1
  (validated goal contract at the execution seam).
- **Scope 06 (skill-sustainer)** — uses the same Axis-7 model-fit
  check (lints future prompts via `references/models.yaml`).
