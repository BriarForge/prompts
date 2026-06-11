#!/bin/bash
# fable5/run-next-fable5.sh
# Runs the next pending Fable 5 prompt via claude-auto (zero-interaction)
# Updates progress.json and commits with git-aoife

set -euo pipefail

PROMPTS_DIR="/Users/mike/Projects/BriarForge/prompts/fable5"
PROGRESS_FILE="$PROMPTS_DIR/progress.json"
RUNNER_LOG="$PROMPTS_DIR/runs.log"

cd "$PROMPTS_DIR"

# Find next pending prompt
NEXT_PROMPT=$(jq -r '.prompts[] | select(.status == "pending") | .file' "$PROGRESS_FILE" | head -1)

if [[ -z "$NEXT_PROMPT" ]]; then
  echo "[$(date)] No more pending Fable 5 prompts." | tee -a "$RUNNER_LOG"
  exit 0
fi

echo "[$(date)] Starting next Fable 5 prompt: $NEXT_PROMPT" | tee -a "$RUNNER_LOG"

# Mark as running; record start epoch for the safety-net race fix below.
RUN_START_EPOCH=$(date +%s)
RUN_START_ISO=$(date -u +%Y-%m-%dT%H:%M:%SZ)
jq --arg file "$NEXT_PROMPT" \
   --arg time "$RUN_START_ISO" \
   '.prompts = (.prompts | map(if .file == $file then .status = "running" | .last_run = $time else . end))' \
   "$PROGRESS_FILE" > "$PROGRESS_FILE.tmp" && mv "$PROGRESS_FILE.tmp" "$PROGRESS_FILE"

# Run via claude-auto (Fable 5 + fully automatic)
PROMPT_CONTENT=$(cat "$NEXT_PROMPT" | sed -n '/```text/,/```/p' | sed '1d;$d')

if [[ -z "$PROMPT_CONTENT" ]]; then
  echo "ERROR: Could not extract prompt text from $NEXT_PROMPT" | tee -a "$RUNNER_LOG"
  exit 1
fi

# Execute with JSON output for reliable parsing (timeout ~4.5 hours).
# Capture exit code separately so we can distinguish "claude ran but errored"
# from "claude never ran at all" (e.g. missing binary, OOM kill, timeout).
# We do NOT use `||` to mask the error: the JSON `is_error` field is the
# authoritative signal, but the exit code is the cheap primary check.
set +e
OUTPUT=$(timeout 16200 claude-auto --output-format json "$PROMPT_CONTENT" 2>&1)
CLAUDE_EXIT=$?
set -e

# Fallback session identifier (Claude JSON output parsing is unreliable via wrapper)
SESSION_ID="fable5-$(date +%Y%m%d-%H%M%S)-${NEXT_PROMPT%.md}"

echo "$OUTPUT" >> "$RUNNER_LOG"

# === Success Gate: refuse to mark a prompt "done" unless Claude actually succeeded.
# This is the fix for the silent-failure bug: previously `|| true` swallowed the
# "Not logged in" / missing-binary errors and the script lied to progress.json. ===
IS_ERROR=$(echo "$OUTPUT" | jq -r 'select(.type=="result") | .is_error' 2>/dev/null | tail -1)
RESULT_TEXT=$(echo "$OUTPUT" | jq -r 'select(.type=="result") | .result' 2>/dev/null | tail -1)
REAL_SESSION_ID=$(echo "$OUTPUT" | jq -r 'select(.type=="result") | .session_id' 2>/dev/null | tail -1)
if [[ -n "$REAL_SESSION_ID" && "$REAL_SESSION_ID" != "null" ]]; then
  SESSION_ID="$REAL_SESSION_ID"
fi

if [[ "$IS_ERROR" == "true" || -z "$IS_ERROR" || "$CLAUDE_EXIT" -ne 0 ]]; then
  FAIL_REASON="${RESULT_TEXT:-no parseable JSON result}"
  if [[ "$CLAUDE_EXIT" -ne 0 ]]; then
    FAIL_REASON="claude-auto exit=$CLAUDE_EXIT: $FAIL_REASON"
  fi
  echo "[$(date)] FAILED: claude-auto did not return a successful result for $NEXT_PROMPT" | tee -a "$RUNNER_LOG"
  echo "[$(date)]   reason: $FAIL_REASON" | tee -a "$RUNNER_LOG"
  # Revert status back to pending so the next cron tick retries.
  jq --arg file "$NEXT_PROMPT" \
     --arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
     --arg note "failed: $FAIL_REASON" \
     '.prompts = (.prompts | map(if .file == $file then .status = "pending" | .last_run = $time | .notes = $note else . end))' \
     "$PROGRESS_FILE" > "$PROGRESS_FILE.tmp" && mv "$PROGRESS_FILE.tmp" "$PROGRESS_FILE"
  git-aoife add progress.json runs.log
  git-aoife commit -m "fable5: FAILED $NEXT_PROMPT (session: $SESSION_ID)" || true
  git-aoife push || true
  exit 1
fi

# === Safety Net: Commit any changes Claude made to the skills repo.
# RACE-FREE: claude-auto may finish writing artifacts a few hundred ms after the
# process exits. We (1) sleep 5s, (2) loop up to 6 times waiting for the working
# tree to actually settle, (3) also force-include any *.md file newer than the
# run start in case the diff --quiet check beat the write. ===
SKILLS_DIR="/Users/mike/Projects/KovaForge/skills"
SKILLS_GIT_FLAGS=(--git-dir="$SKILLS_DIR/.git" --work-tree="$SKILLS_DIR")
if [ -d "$SKILLS_DIR" ]; then
  cd "$PROMPTS_DIR"  # stay in prompts dir for log writes
  sleep 5  # initial settle
  for attempt in 1 2 3 4 5 6; do
    CHANGES=$(git "${SKILLS_GIT_FLAGS[@]}" status --porcelain 2>/dev/null)
    LATE_WRITES=$(find "$SKILLS_DIR" -name "*.md" -newermt "@$RUN_START_EPOCH" -not -path "*/.git/*" 2>/dev/null)
    if [ -z "$LATE_WRITES" ] && [ -z "$CHANGES" ]; then
      echo "[$(date)] Skills repo clean (attempt $attempt) — nothing to commit" | tee -a "$RUNNER_LOG"
      break
    fi
    if [ -n "$LATE_WRITES" ]; then
      echo "[$(date)] Late writes detected on attempt $attempt: $(echo $LATE_WRITES | tr '\n' ' ')" | tee -a "$RUNNER_LOG"
    elif [ -n "$CHANGES" ]; then
      echo "[$(date)] Working tree changes detected on attempt $attempt: $(echo $CHANGES | tr '\n' '|')" | tee -a "$RUNNER_LOG"
    fi
    if [ "$attempt" -eq 6 ]; then
      # Final commit pass after the last wait.
      cd "$SKILLS_DIR"
      echo "[$(date)] Final commit pass for skills repo (after 6 attempts)" | tee -a "$RUNNER_LOG"
      git-aoife add -A
      git-aoife commit -m "fable5: auto-commit from $NEXT_PROMPT (session: $SESSION_ID)" || true
      git-aoife push || true
      cd "$PROMPTS_DIR"
    else
      sleep 1
    fi
  done
fi

# Mark as done
jq --arg file "$NEXT_PROMPT" \
   --arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg sid "$SESSION_ID" \
   '.prompts = (.prompts | map(if .file == $file then .status = "done" | .last_run = $time | .session_id = $sid else . end)) | .last_updated = $time' \
   "$PROGRESS_FILE" > "$PROGRESS_FILE.tmp" && mv "$PROGRESS_FILE.tmp" "$PROGRESS_FILE"

# Commit progress tracking
git-aoife add progress.json runs.log
git-aoife commit -m "fable5: ran $NEXT_PROMPT (session: $SESSION_ID)" || true
git-aoife push || true

echo "[$(date)] Completed: $NEXT_PROMPT" | tee -a "$RUNNER_LOG"
