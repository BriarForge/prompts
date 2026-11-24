---
tags: [claude-code, antigravity, agy, gemini-4-neon, builder, reviewer, subagents, planner, opus, sonnet, model-config, reusable]
category: team-config
version: 1
last-used: 2026-11-25
---

# Claude Code Neon lane: Gemini 4 Neon builds and reviews through the Antigravity CLI

Add-on to [claude-code-opus-glm-planner-builders-setup](claude-code-opus-glm-planner-builders-setup.md). That prompt gives Claude Code an Opus planner, a Sonnet `builder`, a GLM 5.3 `glm-builder` and an Opus `reviewer`. This one adds a Gemini 4 Neon lane through the Antigravity CLI (`agy`), on a Google plan and with no API key:

| Role | Mechanism |
|---|---|
| `agy-run` | A small wrapper script (`~/.claude/agy/agy-run`) that runs one briefed job through `agy` and prints one JSON envelope with fixed exit codes, `--dry-run`, `--usage` and `--resume`. |
| `agy-builder` subagent | Haiku wrapper around `agy-run build`: Neon edits the files it owns and may run only allowed build and test commands. |
| `agy-reviewer` subagent | Haiku wrapper around `agy-run review`: Neon reads the diff and returns structured findings. A cheaper first pass before the Opus `reviewer`. |
| `agy` skill | `~/.claude/skills/agy/SKILL.md`: how to use `agy-run`. |
| Permission profiles and schemas | `~/.claude/agy/*.json`: allow and deny rules for headless `agy`, and the JSON schemas for the build report and the review. |
| Rule section | "Neon lane" appended to `~/.claude/rules/model-team.md`. |

Pipeline this enables: Opus (main) plans and writes briefs; the Sonnet `builder` builds and can call the Opus advisor; `agy-reviewer` (Neon) reviews the diff; confirmed findings go back to the builder; the Opus `reviewer` still checks anything risky (security, auth, migrations, public API).

Why not the Gemini API CLI (`google-gemini/gemini-api-cli`): it needs a Gemini API key and bills per token. Only a Google plan is used here, so it is not used. Its design ideas are kept: a machine-readable `--usage`, `--dry-run`, one JSON envelope, fixed exit codes, resumable IDs.

````text
Add a Gemini 4 Neon lane to this Claude Code setup at the USER level, using the Antigravity CLI (`agy`) on my Google plan. Follow the steps in order and do not skip the checks. Do not use an API key, and never use `--dangerously-skip-permissions`.

## 0. Ground rules
- The facts below were checked on 25 Nov 2026 with agy 1.5.16. If `agy --help`, the settings docs (https://antigravity.google/docs/settings.md and https://antigravity.google/docs/permissions.md) or a command's behaviour differ, the product wins: adapt, and tell me what differed.
- Never print secret values. None of these files contains one.
- Do not overwrite an existing file that differs without showing me the difference first.
- Replace `/home/mike` below with the real home directory (the permission profiles use absolute paths).

## 1. Preflight (one line per result)
1. `agy --version`, and `command -v agy`. If missing, tell me how to install it and stop.
2. `agy models | grep -i neon`: pick the Neon model. Default `gemini-4-neon-high` (also: `-medium`, `-low`, `-xhigh`). If none is listed, my plan does not include it: stop and tell me.
3. One tiny call: `agy --model gemini-4-neon-high -p "Reply with exactly: ok"` must print `ok`. If it fails (auth, quota), report the exact error and stop.
4. Check that the team from claude-code-opus-glm-planner-builders-setup exists (`~/.claude/agents/builder.md`, `reviewer.md`). If not, say so: this prompt only adds a lane.
5. `python3` (standard library only) is all the wrapper needs.

## 2. What was learned about headless agy (why the profiles look like this)
- Print mode (`-p`) cannot ask permission. A command with no allow rule is auto-denied and the whole run ends with exit code 0, status `SUCCESS` and no output. The JSON envelope then has `denied_actions` and the structured output is null; the wrapper turns that into exit code 4. A command matching a deny rule is blocked with a message and the run continues.
- `--mode auto` was not available on my account; `--mode accept-edits` lets agy edit files, and the allow rules below let it run chosen commands.
- Rules go in a settings file passed with `--settings FILE` (session only, never saved), shaped `{"permissions": {"allow": [...], "deny": [...]}}`. Rule syntax is `command(prefix)`: whole-word token prefix, so `command(cargo test)` covers `cargo test -p x --offline`. `*` works only alone (`command(cargo *)` does NOT work). Deny beats allow. Add `read_file(dir)` and `write_file(dir)` rules for paths outside the workspace that a build needs.
- The agy sandbox has no network and allows the workspace and temp dirs only. Rust builds worked with `read_file(~/.cargo)`, `read_file(~/.rustup)` and `write_file(~/.cargo/.package-cache)`, using `cargo ... --offline`.
- `--output-format json` returns `conversation_id`, `status`, `response`, `structured_output` (with `--json-schema FILE`), `denied_actions`, `usage` and `duration_seconds`. `--conversation ID` resumes an earlier run, so a fix round does not need the brief again.
- A read-only reviewer must be told not to run cargo or any build: the first command outside the allow list ends its run.
- `git -C <path> ...` never matches a `command(git status)` style rule, and it would also slip past a `command(git push)` deny rule (`git -C . push`). Allow no `git -C`; put `git -C`, `git --git-dir` and `git --work-tree` on the deny list. A denied command only blocks (agy then retries without it), while an unlisted one aborts the run, so deny the commands you expect it to try but do not want to allow. Also tell agy in the prompt to run git plainly in the current directory and not to chain commands with `&&`.
- When parsing `git status --porcelain`, do not strip the output as a whole: the first line starts with a space and losing it cuts a character off the first path (this made the git guard report a false violation once).

## 3. Create the files
Create ~/.claude/agy/ and write these files (mode 600 for the JSON, 755 for agy-run).

### ~/.claude/agy/build-permissions.json
```json
{
  "permissions": {
    "allow": [
      "command(cargo check)",
      "command(cargo test)",
      "command(cargo build)",
      "command(cargo clippy)",
      "command(cargo fmt)",
      "command(git status)",
      "command(git diff)",
      "command(git log)",
      "command(git branch --show-current)",
      "command(ls)",
      "command(cat)",
      "command(head)",
      "command(tail)",
      "command(wc)",
      "command(grep)",
      "command(rg)",
      "command(find)",
      "command(sed)",
      "command(awk)",
      "command(sort)",
      "command(uniq)",
      "command(diff)",
      "command(cut)",
      "command(tr)",
      "command(echo)",
      "command(pwd)",
      "command(file)",
      "command(stat)",
      "command(basename)",
      "command(dirname)",
      "command(tree)",
      "command(git --no-pager)",
      "command(git ls-files)",
      "command(git blame)",
      "command(git rev-parse)",
      "command(git show)",
      "read_file(/home/mike/.cargo)",
      "read_file(/home/mike/.rustup)",
      "write_file(/home/mike/.cargo/.package-cache)"
    ],
    "deny": [
      "command(git push)",
      "command(git commit)",
      "command(git checkout)",
      "command(git switch)",
      "command(git reset)",
      "command(git restore)",
      "command(git stash)",
      "command(git merge)",
      "command(git rebase)",
      "command(git clean)",
      "command(git worktree)",
      "command(gh)",
      "command(rm)",
      "command(sudo)",
      "command(pkexec)",
      "command(curl)",
      "command(wget)",
      "command(git -C)",
      "command(git --git-dir)",
      "command(git --work-tree)"
    ]
  }
}
```

### ~/.claude/agy/readonly-permissions.json
```json
{
  "permissions": {
    "allow": [
      "command(git status)",
      "command(git diff)",
      "command(git log)",
      "command(git show)",
      "command(ls)",
      "command(cat)",
      "command(head)",
      "command(tail)",
      "command(wc)",
      "command(grep)",
      "command(rg)",
      "command(find)",
      "command(sed)",
      "command(awk)",
      "command(sort)",
      "command(uniq)",
      "command(diff)",
      "command(cut)",
      "command(tr)",
      "command(echo)",
      "command(pwd)",
      "command(file)",
      "command(stat)",
      "command(basename)",
      "command(dirname)",
      "command(tree)",
      "command(git --no-pager)",
      "command(git ls-files)",
      "command(git blame)",
      "command(git rev-parse)",
      "read_file(/home/mike/.cargo)",
      "read_file(/home/mike/.rustup)"
    ],
    "deny": [
      "write_file(*)",
      "command(git push)",
      "command(git commit)",
      "command(git checkout)",
      "command(git switch)",
      "command(git reset)",
      "command(git restore)",
      "command(git stash)",
      "command(gh)",
      "command(rm)",
      "command(sudo)",
      "command(pkexec)",
      "command(curl)",
      "command(wget)",
      "command(git -C)",
      "command(git --git-dir)",
      "command(git --work-tree)"
    ]
  }
}
```

### ~/.claude/agy/report-schema.json
```json
{
  "type": "object",
  "additionalProperties": false,
  "required": ["files_changed", "commands_run", "tests", "unverified", "questions"],
  "properties": {
    "files_changed": { "type": "array", "items": { "type": "string" } },
    "commands_run": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["command", "result"],
        "properties": { "command": { "type": "string" }, "result": { "type": "string" } }
      }
    },
    "tests": { "type": "string" },
    "unverified": { "type": "array", "items": { "type": "string" } },
    "questions": { "type": "array", "items": { "type": "string" } }
  }
}
```

### ~/.claude/agy/review-schema.json
```json
{
  "type": "object",
  "additionalProperties": false,
  "required": ["findings", "verdict", "unverified"],
  "properties": {
    "findings": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["severity", "location", "problem", "scenario", "verified"],
        "properties": {
          "severity": { "type": "string", "enum": ["blocking", "important", "minor"] },
          "location": { "type": "string" },
          "problem": { "type": "string" },
          "scenario": { "type": "string" },
          "verified": { "type": "boolean" }
        }
      }
    },
    "verdict": { "type": "string", "enum": ["merge", "fix-first", "reject"] },
    "unverified": { "type": "array", "items": { "type": "string" } }
  }
}
```

### ~/.claude/agy/agy-run
```python
#!/usr/bin/env python3
"""agy-run: run one briefed piece of work through the Antigravity CLI (`agy`) and return a machine-readable result.

Ideas borrowed from the gemini-api CLI (self-describing --usage, --dry-run, one JSON envelope, fixed exit codes), but it
calls `agy` on a Google plan, not the Gemini API: no API key anywhere.

  agy-run doctor
  agy-run build  --brief FILE [--owns PATH ...] [--allow CMD ...] [options]    edits files, may run the allowed commands
  agy-run review --brief FILE [options]                                        read-only, returns structured findings
  agy-run ask    --brief FILE [options]                                        read-only, free-form answer
  agy-run --usage                                                              machine-readable usage (JSON)

options: --cwd DIR (default .)  --model ID (default gemini-4-neon-high)  --resume CONVERSATION_ID  --timeout SECONDS (1800)
         --add-dir DIR (repeatable)  --allow "cargo test" (repeatable, build only; token-prefix match)  --dry-run
exit codes: 0 ok | 1 agy failed | 2 usage error | 3 auth, quota or model problem | 4 a command was denied or nothing came back
            5 git guard: commit, branch change or a changed file outside --owns
Stdout is always one JSON object. Secrets are never printed.
"""
import argparse, fnmatch, json, os, subprocess, sys, tempfile, time

HOME = os.path.expanduser('~/.claude/agy')
DEFAULT_MODEL = 'gemini-4-neon-high'
PROFILE = {'build': 'build-permissions.json', 'review': 'readonly-permissions.json', 'ask': 'readonly-permissions.json'}
SCHEMA = {'build': 'report-schema.json', 'review': 'review-schema.json', 'ask': None}

USAGE = {
    'name': 'agy-run', 'default_model': DEFAULT_MODEL,
    'commands': {
        'doctor': 'check agy, the model and one tiny call',
        'build': 'edit files for a brief; flags: --brief --owns --allow --cwd --model --resume --timeout --add-dir --dry-run',
        'review': 'read-only review, structured findings (review-schema.json)',
        'ask': 'read-only question, free-form answer',
    },
    'exit_codes': {'0': 'ok', '1': 'agy failed', '2': 'usage error', '3': 'auth, quota or model problem',
                   '4': 'a command was denied or nothing came back', '5': 'git guard violation'},
    'envelope': ['ok', 'code', 'mode', 'model', 'conversation_id', 'status', 'report', 'response', 'denied_actions',
                 'git', 'usage', 'duration_seconds', 'hint'],
    'notes': ['agy has no shell in headless mode unless allow rules grant it; a denied command ends the run with status SUCCESS and no output, this tool turns that into code 4',
              'resume a conversation with --resume <conversation_id> instead of re-briefing',
              'build runs inside the agy sandbox: no network, workspace and temp dirs only; use cargo --offline'],
}


def out(env, code):
    env['code'] = code
    env['ok'] = code == 0
    print(json.dumps(env, indent=2))
    sys.exit(code)


def git(cwd, *a, raw=False):
    r = subprocess.run(['git', '-C', cwd, *a], capture_output=True, text=True)
    if r.returncode != 0: return ''
    return r.stdout if raw else r.stdout.strip()


def git_state(cwd):
    return {'head': git(cwd, 'rev-parse', 'HEAD'), 'branch': git(cwd, 'branch', '--show-current'),
            'changed': sorted(l[3:].split(' -> ')[-1] for l in git(cwd, 'status', '--porcelain', raw=True).splitlines() if len(l) > 3)}


def main():
    ap = argparse.ArgumentParser(add_help=False)
    ap.add_argument('mode', nargs='?')
    ap.add_argument('--usage', action='store_true'); ap.add_argument('--help', '-h', action='store_true')
    ap.add_argument('--brief'); ap.add_argument('--cwd', default='.'); ap.add_argument('--model', default=DEFAULT_MODEL)
    ap.add_argument('--resume'); ap.add_argument('--timeout', type=int, default=1800)
    ap.add_argument('--owns', nargs='*', default=[]); ap.add_argument('--allow', action='append', default=[])
    ap.add_argument('--add-dir', action='append', default=[]); ap.add_argument('--dry-run', action='store_true')
    a, extra = ap.parse_known_args()
    if a.usage or a.help or not a.mode:
        print(json.dumps(USAGE, indent=2)); sys.exit(0 if (a.usage or a.help) else 2)
    if extra or a.mode not in ('doctor', 'build', 'review', 'ask'):
        out({'mode': a.mode, 'hint': f'unknown argument(s) {extra} or mode; see --usage'}, 2)
    cwd = os.path.abspath(a.cwd)
    env = {'mode': a.mode, 'model': a.model, 'cwd': cwd}

    if a.mode == 'doctor':
        v = subprocess.run(['agy', '--version'], capture_output=True, text=True)
        env['agy_version'] = v.stdout.strip()
        models = subprocess.run(['agy', 'models'], capture_output=True, text=True, timeout=120).stdout
        env['model_listed'] = a.model in models
        if not env['model_listed']:
            env['hint'] = f'model {a.model} not in `agy models`'; out(env, 3)
        r = subprocess.run(['agy', '--model', a.model, '-p', 'Reply with exactly: ok'], capture_output=True, text=True, timeout=300)
        env['reply'] = r.stdout.strip()[:40]
        out(env, 0 if r.returncode == 0 and 'ok' in r.stdout.lower() else 3)

    if not a.brief or not os.path.isfile(a.brief):
        out({**env, 'hint': '--brief FILE is required and must exist'}, 2)
    if a.allow and a.mode != 'build':
        out({**env, 'hint': '--allow is only for build'}, 2)
    brief = os.path.abspath(a.brief)

    settings = json.load(open(os.path.join(HOME, PROFILE[a.mode])))
    for c in a.allow:
        settings['permissions']['allow'].append(f'command({c})')
    tmp = tempfile.NamedTemporaryFile('w', suffix='.json', prefix='agy-settings-', delete=False)
    json.dump(settings, tmp); tmp.close(); os.chmod(tmp.name, 0o600)

    rules = {
        'build': 'Run git commands plainly in the current directory (no git -C, no chaining with &&). You edit files. Edit only the files the brief says you own. You may run only the allowed build and test commands (cargo with --offline). Never commit, push, switch branches or create worktrees. Finish with the required structured report.',
        'review': 'Run git commands plainly in the current directory (no git -C, no chaining with &&). You are read-only: do NOT run cargo or any build or test command; use git show, git diff, grep and cat only. Report findings in the required structure, most severe first, each with a concrete failing scenario; say which you verified.',
        'ask': 'You are read-only. Answer from the files; do not run build or test commands.',
    }[a.mode]
    prompt = f'Read the brief at {brief} and do what it describes. {rules}'
    cmd = ['agy', '--model', a.model, '--mode', 'accept-edits', '--settings', tmp.name, '--output-format', 'json',
           '--add-dir', os.path.dirname(brief), '--add-dir', HOME]
    for d in a.add_dir: cmd += ['--add-dir', d]
    if SCHEMA[a.mode]: cmd += ['--json-schema', os.path.join(HOME, SCHEMA[a.mode])]
    if a.resume: cmd += ['--conversation', a.resume]
    cmd += ['-p', prompt]

    if a.dry_run:
        os.unlink(tmp.name)
        print(json.dumps({'dry_run': True, 'cwd': cwd, 'command': cmd, 'settings': settings,
                          'schema': SCHEMA[a.mode], 'note': 'nothing was sent'}, indent=2)); sys.exit(0)

    before = git_state(cwd)
    t0 = time.time()
    try:
        r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=a.timeout)
    except subprocess.TimeoutExpired:
        os.unlink(tmp.name); out({**env, 'hint': f'timed out after {a.timeout}s'}, 1)
    os.unlink(tmp.name)
    env['duration_seconds'] = round(time.time() - t0, 1)
    try: j = json.loads(r.stdout)
    except Exception:
        j = None
    err = (r.stderr or '').strip()
    if j is None:
        low = (err + r.stdout).lower()
        env['hint'] = (err or r.stdout)[:300]
        out(env, 3 if any(w in low for w in ('auth', 'login', 'quota', 'rate limit', 'unauthor', 'model not', 'unknown model')) else 1)
    env.update({'conversation_id': j.get('conversation_id'), 'status': j.get('status'), 'num_turns': j.get('num_turns'),
                'usage': j.get('usage'), 'response': (j.get('response') or '')[:4000], 'denied_actions': j.get('denied_actions') or []})
    env['report'] = j.get('structured_output')
    after = git_state(cwd)
    g = {'head_changed': before['head'] != after['head'], 'branch_changed': before['branch'] != after['branch'],
         'changed_files': [f for f in after['changed'] if f not in before['changed']]}
    if a.mode == 'build' and a.owns:
        g['out_of_scope'] = [f for f in after['changed'] if f not in before['changed'] and not any(fnmatch.fnmatch(f, p) or f.startswith(p.rstrip('/') + '/') for p in a.owns)]
    if a.mode != 'build':
        g['read_only_violation'] = [f for f in after['changed'] if f not in before['changed']]
    env['git'] = g
    if env['denied_actions'] or (SCHEMA[a.mode] and not env['report']):
        env['hint'] = ('a command was denied in headless mode and the run stopped: ' + (err[:200] or 'no output') +
                       ' . Add an --allow rule for it (token prefix, e.g. "cargo test") or take it out of the brief.')
        out(env, 4)
    if g['head_changed'] or g['branch_changed'] or g.get('out_of_scope') or g.get('read_only_violation'):
        env['hint'] = 'git guard: a commit, branch change or file outside the brief changed; nothing was reverted'
        out(env, 5)
    out(env, 0)


if __name__ == '__main__':
    main()
```

### ~/.claude/agents/agy-builder.md
```markdown
---
name: agy-builder
description: Antigravity builder, default model Gemini 4 Neon. Implements one well-briefed piece of a task through `agy-run build` (agy edits the files and may run only the allowed build and test commands in its sandbox), then checks the result and reports. Use for self-contained pieces with a clear spec: tests, boilerplate, mechanical refactors, docs, ports of existing code. The brief must name the files it owns, the commands it may run and what done means.
model: haiku
tools: Read, Grep, Glob, Bash
---

You are a thin wrapper around `~/.claude/agy/agy-run` (the Antigravity CLI wrapper). Gemini 4 Neon writes the code, not you. You hand it the brief, check what it did, and report. You do not write the code and you do not call the advisor.

1. Save the brief to a file outside the repository, `${TMPDIR:-/tmp}/agy-brief-<short-name>.md`. Never put a secret in it. The brief must list the owned files; if it does not, stop and say so.
2. Run from the repository root, in the foreground, with a long Bash timeout:
   `~/.claude/agy/agy-run build --brief <file> --owns <path> [<path> ...] --allow "cargo test" --allow "cargo check" [--model <id>] [--resume <conversation_id>]`
   `--owns` lists the files the brief owns (paths or directories). `--allow` is one rule per command group (token prefix match, so `cargo test` covers `cargo test -p x --offline`). The sandbox has no network: tell agy to use `cargo ... --offline`. The default model is `gemini-4-neon-high`; use another only if the brief says so. Add `--dry-run` first if you are unsure what will be sent.
3. Read the JSON envelope on stdout (never the raw agy output):
   - `code` 0: continue to step 4.
   - 3 (auth, quota, model): report the exact `hint` and stop; do not retry with another model.
   - 4: a command was denied or nothing came back. Report `denied_actions` and `hint`; you may rerun once with the missing command added to `--allow` if it is a build or test command named in the brief, using `--resume <conversation_id>`. Otherwise stop.
   - 5: git guard violation (commit, branch change, a file outside `--owns`). Report the files; do not revert anything.
   - 1 or 2: report the `hint`.
4. Check the result yourself, read-only: `git status`, `git diff`, and confirm that every changed file is one the brief owns. Run the build and tests named in the brief yourself; agy's own report says what it ran but you do not trust it.
5. Report like the Sonnet builder: files changed, what agy did (`report`), the commands you ran with results, `conversation_id` (so a fix round can use `--resume`), what failed or was left undone, open questions, and which results are only agy's claim.
```

### ~/.claude/agents/agy-reviewer.md
```markdown
---
name: agy-reviewer
description: Gemini 4 Neon review of a finished change through `agy-run review` (read-only, structured findings). A cheaper first pass before, or instead of, the Opus reviewer. Use after builders finish and before a commit or merge. The brief names what changed (diff, commit or files), what it should do, and what to look for.
model: haiku
tools: Read, Grep, Glob, Bash
---

You are a thin wrapper around `~/.claude/agy/agy-run review`. Gemini 4 Neon reviews; you run it and relay the result. You do not review the code yourself and you do not edit anything.

1. Write the brief to `${TMPDIR:-/tmp}/agy-review-<short-name>.md`: what the change is meant to do, how to see it (`git diff`, `git diff --staged`, `git show <commit>`, or file paths), the repo rules that matter (AGENTS.md), and what is risky. Say plainly that agy is read-only and must not run cargo or any build or test command.
2. Run from the repository root: `~/.claude/agy/agy-run review --brief <file>` (add `--model gemini-4-neon-xhigh` for hard changes). Allow several minutes; a review of a normal PR takes about four.
3. Read the JSON envelope. `code` 0: relay `report` (findings, verdict, unverified), most severe first, with file:line. `code` 4: agy tried a command; say which, and rerun once with the brief rewritten to forbid it. `code` 5: it changed a file (it must not); say which. `code` 3: report the `hint` and stop.
4. Spot-check the two highest-severity findings against the code (read the lines) and mark each `confirmed` or `not confirmed`. Do not drop a finding because you disagree; say you disagree.
5. Finish with: verdict, findings (severity, location, problem, scenario, confirmed or not), what Neon could not verify, `conversation_id` for a follow-up with `--resume`.
```

### ~/.claude/skills/agy/SKILL.md
```markdown
---
name: agy
description: Use the Antigravity CLI (agy, Gemini 4 Neon on a Google plan, no API key) as a builder or a reviewer through ~/.claude/agy/agy-run. Use when asked to build with agy or Neon, to have Neon review a diff, to run a cheap first-pass review before the Opus reviewer, or to resume an earlier agy conversation.
---

# agy through `agy-run`

`~/.claude/agy/agy-run` runs one briefed job through `agy` and prints one JSON envelope. Start with `agy-run --usage` (machine-readable) and `agy-run doctor` (agy, the model, one tiny call). Use `--dry-run` to see exactly what would be sent.

| Job | Command | agy may |
|---|---|---|
| Build | `agy-run build --brief FILE --owns PATH... --allow "cargo test" --allow "cargo check"` | edit files; run only the allowed commands (sandbox, no network: `cargo --offline`) |
| Review | `agy-run review --brief FILE` | read only; returns `findings`, `verdict`, `unverified` |
| Ask | `agy-run ask --brief FILE` | read only; free-form answer |

Always: write the brief to a file outside the repo (no secrets), say which files are owned, say what "done" means. Default model `gemini-4-neon-high`; `gemini-4-neon-xhigh` for hard work. Fix rounds: `--resume <conversation_id>` instead of re-briefing.

Exit codes: 0 ok, 1 agy failed, 2 usage, 3 auth/quota/model, 4 a command was denied or nothing came back (an unlisted command ends a headless run with status SUCCESS and no output: this is how to tell), 5 git guard (commit, branch change, file outside `--owns`; nothing is reverted).

Rules: deny rules (git push, commit, checkout, rm, curl...) block and the run continues; unlisted commands abort the run. agy never commits or pushes here. Neon sees the repo, not the conversation. Do not use `--dangerously-skip-permissions`. The profiles live in `~/.claude/agy/build-permissions.json` and `readonly-permissions.json`; the schemas in `report-schema.json` and `review-schema.json`.

Agents: `agy-builder` and `agy-reviewer` wrap this for the Opus-main team (see `~/.claude/rules/model-team.md`, "Neon lane").
```

### Append this section to ~/.claude/rules/model-team.md (replace an earlier "Neon lane" section if there is one)
## Neon lane (Gemini 4 Neon through `agy-run`, no API key: Google plan only)
- `agy-builder` and `agy-reviewer` call `~/.claude/agy/agy-run`, which wraps the Antigravity CLI: one JSON envelope back, fixed exit codes (0 ok, 3 auth or quota, 4 a command was denied or nothing came back, 5 git guard), session-only permission profiles in `~/.claude/agy/*.json`, `--resume <conversation_id>` for fix rounds, `--dry-run` to see what would be sent.
- **Opus plans and advises, Sonnet builds, Neon reviews:** Opus (main) splits the work and writes briefs; the Sonnet `builder` builds and may call the Opus advisor; then Opus starts `agy-reviewer` on the finished diff. Send Neon's confirmed findings to the Sonnet builder to fix. Neon is a first pass, not the final word: for security, auth, migrations, public API or anything irreversible still run the Opus `reviewer` after it, and always look at the actual command output yourself.
- A reviewer run is read-only and takes minutes; run it in the background while doing something else. It sees the repository, not the conversation, so the brief has to say what the change is for.
- `agy` headless cannot ask permission: an unlisted command ends the run with no output (the wrapper reports code 4). Build runs use `--allow` for the build and test commands, offline.

## 4. Verification
1. `~/.claude/agy/agy-run doctor` prints `"ok": true`.
2. `~/.claude/agy/agy-run build --brief <any small brief> --dry-run` prints the resolved command and the merged rules and sends nothing.
3. In a scratch git repo: a build brief that creates one file with `--owns thatfile` exits 0; one that also creates a second file exits 5; a brief that makes agy run a command with no rule (not on the deny list) exits 4. Check that `git status` shows nothing was committed or pushed.
4. Start a new Claude Code session (agents load at startup): `/agents` lists `agy-builder` and `agy-reviewer`. Smoke test: ask Opus to plan a trivial change, have the Sonnet `builder` build it, then run `agy-reviewer` on the diff.

## 5. Report
List: agy version, the Neon model chosen and the result of the `ok` call, each file created or replaced (full paths), what differed from this prompt, the results of the verification checks, and how to remove it: delete ~/.claude/agy/, ~/.claude/agents/agy-*.md, ~/.claude/skills/agy/ and the "Neon lane" section of the rule.
````

# Notes

- **Checked on this machine (25 Nov 2026, agy 1.5.16):** `agy-run doctor`; a clean build (exit 0); a build that created an extra file (exit 5, file left in place); a `curl` blocked by a deny rule while the run carried on; `cargo check` and `cargo test` run by agy inside its sandbox with the allow rules above; a read-only structured review of a real commit (about four minutes, 90,000 tokens); `--conversation` resume; `write_file(*)` denied in the read-only profile.
- **First real use (25 Nov 2026):** a small ShareX-Rust bug (the Image resizer spinner buttons, issue 288) was built by `agy-run build` in 110 seconds (66,000 tokens), its own tests passed, the diff matched the brief, and a Neon review of it came back clean in about three minutes. The run found the two profile and parsing problems described in section 2.
- **Not verified:** how agy behaves at quota exhaustion (the wrapper maps auth, quota and model errors to exit code 3 by matching the message, which is untested), a large multi-file build, `--effort`, and how `--settings` combines with an existing `permissions` block in `~/.gemini/antigravity-cli/settings.json` (there was none here).
- **Neon is a first-pass reviewer.** Its findings need a spot check (it once flagged an intentional design choice as a weakening). Keep the Opus `reviewer` for security, auth, migrations, public API and anything irreversible.
- **Why the wrapper agents are Haiku:** they only run `agy-run`, read the JSON envelope and check `git status`. Neon writes or reviews the code.
- **Related:** [antigravity-swarm-argon-neon-hydrogen](antigravity-swarm-argon-neon-hydrogen.md) is the Gemini-only alternative, where Antigravity's own `/swarm` runs the whole team.
