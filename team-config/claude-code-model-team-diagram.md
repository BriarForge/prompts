---
tags: [claude-code, model-team, diagram, swimlane, diagram-design, xerahs, opus, sonnet, haiku, glm, neon, reusable]
category: team-config
version: 2
last-used: 2026-11-25
---

# Draw the Claude Code model team as one diagram, and publish it through XerahS

Draws how Opus, Haiku, Sonnet, GLM 5.3 and Gemini Neon work as one integrated system (planning, researching, building, advising, reviewing) as one self-contained HTML page with two SVG diagrams, using the [diagram-design](https://github.com/KovaForge/diagram-design) skill, then uploads it with the XerahS CLI. It documents the team set up by [claude-code-opus-advisor-setup](claude-code-opus-advisor-setup.md) (Haiku as the default search and research subagent), [claude-code-opus-glm-planner-builders-setup](claude-code-opus-glm-planner-builders-setup.md) and [claude-code-opus-neon-agy-lane-setup](claude-code-opus-neon-agy-lane-setup.md) (Haiku as the thin wrapper around the GLM and Neon CLIs); redraw it whenever the roles change.

What the diagrams say. Overview: Opus (main) plans, writes the briefs and judges, and never writes code. Haiku researches for it. Sonnet, GLM 5.3 and Neon build in parallel on separate files. Sonnet may ask the Opus advisor. Neon reads the combined diff first and returns findings. Opus judges and merges, and calls the Opus reviewer only for risky changes (security, auth, migrations, public API). Fix rounds go back to the builder that owns the file. Detail: a Haiku wrapper saves the brief, runs the GLM or Neon CLI, reads the result, checks the diff against the owned files, runs the build and tests itself, and reports, stopping early on an auth, quota, denied-command or git-guard failure.

````text
Draw the Claude Code model team as one page with two swimlane-family diagrams using the diagram-design skill, check them, look at them, and publish the page. Do not skip the checks.

## 0. Ground rules
- Facts below were checked on 25 Nov 2026. If the skill or a CLI behaves differently, the tool wins: adapt and say what differed.
- The diagrams hold no secrets, paths, hostnames or account names. Do not add any.
- Upload only to a destination I own, and only after the checks pass.
- Read the team from my real setup first (`~/.claude/rules/model-team.md`, `~/.claude/agents/*.md`) and draw what is there, not what this prompt remembers. If a lane or rule differs, change section 2 first.

## 1. Get the skill
1. If `diagram-design` is not installed as a skill (`~/.claude/skills/diagram-design`), clone it for reference: `gh repo clone KovaForge/diagram-design /tmp/dd -- --depth 1`. The skill is `skills/diagram-design/` (SKILL.md, references/, scripts/, assets/).
2. Read SKILL.md fully, then `references/type-swimlane.md`, `references/primitives-core.md` (the six mandatory connector rules), `references/output-spec.md` (size presets, type ramp) and `references/layout-budget.md`. Budget per diagram: at most 9 nodes, 12 arrows, 2 coral elements, 2 callouts, 5 swimlane lanes. More than that means split into an overview and a detail diagram.
3. First-diagram gate: the skill asks whether to customise the style guide. Keep the default skin unless I say otherwise, and say that you did.

## 2. The plan (state it before drawing)
Overview: type swimlane, size preset `doc-wide`, viewBox `0 0 1280 700`, `min-width: 1280px` inside a local `overflow-x: auto` wrapper, minimal light variant.
- Lanes, top to bottom (5, the maximum): OPUS (main, advisor and reviewer are one lane, ordered by column); HAIKU (research and the CLI wrappers); SONNET (builder subagent); GLM 5.3 (builder via OpenCode); NEON (builder and reviewer via agy). Merging the Opus roles into one lane is what makes room for Haiku.
- Columns: PLAN, BUILD AND ADVISE, REVIEW, JUDGE.
- Nodes (9, the maximum): Plan and brief, Advise (optional, dashed), Final review (optional, dashed) and Judge and merge (the focal coral node) in the Opus lane; Research in the Haiku lane; Build in each of the Sonnet, GLM and Neon lanes; First-pass review in the Neon lane.
- Arrows (10), all orthogonal, none crossing: Research to Plan (FACTS); Plan to each Build, leaving the bottom of Plan at three separate points (BRIEFS on one); Sonnet Build to Advise, dashed (ASKS); Neon Build, GLM Build and Sonnet Build to First-pass review (DIFF on the straight one; GLM and Sonnet enter its top edge at separate points); First-pass review to Judge and merge, coral (FINDINGS, the headline handoff, the second coral element); Judge and merge to Final review, dashed (RISKY).
- Callouts (2, italic serif): "Haiku also wraps GLM and Neon: it runs the CLI, checks the diff and the tests, then reports." and "Fix rounds go back to the builder that owns the file, resumed, not a new one."
- Legend strip along the bottom: Step, Decision, Optional step, Handoff, Optional handoff, Headline handoff.
Detail: a second SVG on the same page below the overview, viewBox `0 0 1280 324`, six steps in a row (Save brief, Run the CLI, Read result, Check diff as the one coral step, Run tests, Report) and a dashed Stop and report box under Read result and Check diff with two dashed failure arrows (EXIT 3 4 5, OUTSIDE FILES); one italic callout: it never trusts the builder's own claim that tests passed.
Cut on purpose: tests inside each builder and the git guard internals (the detail diagram covers the wrapper's own checks), and the Opus advisor's two consumers other than Sonnet (the wrappers do not call it).

## 3. Draw
Start from the skill's `assets/example-swimlane.html`. Use the reference implementation below as the layout: it already passes every check. Rules to keep when you change anything: arrows drawn before boxes; each arrow label on an opaque `fill="#f5f5f5"` mask 6 to 10 px from its stroke and never sitting on a lane divider or a node; fan attach points 12 px or more apart; structure on the 4 px grid; each SVG has `role="img"`, `aria-labelledby`, `<title>` as its first child, and IDs `<slug>-title` and `<slug>-desc`, with distinct slugs per SVG (`integrated-model-team`, `haiku-wrapper`) and distinct marker and pattern IDs.

## 4. Check (all must pass), then look
1. The checker scripts assume one diagram per file and share one coordinate space, so a page with two SVGs gives false positives (a label "clipped by a node declared later" that belongs to the other SVG). Check each SVG on its own: write each SVG into its own copy of the page head, named after its slug (`integrated-model-team.html`, `haiku-wrapper.html`), then run on each: `python3 scripts/self_check.py <file>` must print `OK`, and `python3 scripts/verify_geometry.py <file>` must report `0 finding(s)`. Ship the combined page.
2. Render the whole page and look at the picture yourself. `scripts/export_png.py` needs Playwright; if it is missing use the browser: `google-chrome-stable --headless=new --disable-gpu --no-sandbox --hide-scrollbars --window-size=1400,1500 --screenshot=<png> file://<html>`, and crop with ImageMagick to inspect each diagram at real size. Check: no crossings, no label touching its stroke, a lane divider or a node, nothing clipped, coral on two elements only in the overview and one in the detail.

## 5. Publish through XerahS
1. Do not run `xerahs` itself (it starts the GUI). Use the CLI `omaxerahs`.
2. `omaxerahs doctor --json` must report the destination ready. If it does not, stop and tell me; do not write uploader secrets.
3. `omaxerahs upload <file>` only accepts images (`unsupported_type` for HTML). For any other file use a named File destination: `omaxerahs upload --destination "<display name from doctor>" --json -- <file>`. It keeps the file name and returns the URL.
4. `omaxerahs upload --destination` keeps the source file name on purpose (it sets `KeepSourceFileName`, which skips the task's name pattern and its random `%ra{10}` suffix; the normal upload path applies it so different files never share one URL). Behind a CDN (Cloudflare here) the same name keeps serving the cached old copy, and a cache-busting query string can redirect. So add the random suffix yourself: copy the page to a scratch folder as `<name>-<10 random lowercase letters and digits>.html` and upload that copy. Say that the old URL will refresh later.
5. Confirm the new URL serves it: `curl -sI <url>` shows HTTP 200 and `content-type: text/html`, and `curl -s <url> | grep -c haiku-wrapper-title` is not 0.
6. Report: the URL, the checks and their results, and what you decided (skin, size, lanes merged, what was cut).

## 6. Reference implementation (each SVG passes self_check and verify_geometry on its own)
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>One model team · Swimlane</title>
  <link href="https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Geist:wght@400;500;600&family=Geist+Mono:wght@400;500;600&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
      --color-paper:   #f5f5f5;
      --color-ink:     #2d3142;
      --color-muted:   #4f5d75;
      --color-accent:  #bf4520;
      --font-sans:     'Geist', system-ui, sans-serif;
      --font-serif:    'Instrument Serif', serif;
      --font-mono:     'Geist Mono', ui-monospace, monospace;
    }

    body {
      font-family: var(--font-sans);
      background: var(--color-paper);
      color: var(--color-ink);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 3rem 2rem;
    }

    .frame { max-width: 1320px; width: 100%; min-width: 0; }

    .eyebrow {
      font-family: var(--font-mono);
      font-size: 0.66rem;
      font-weight: 500;
      letter-spacing: 0.18em;
      text-transform: uppercase;
      color: var(--color-muted);
      margin-bottom: 0.5rem;
    }

    h1 {
      font-family: var(--font-serif);
      font-size: clamp(1.5rem, 2.4vw + 0.75rem, 2rem);
      font-weight: 400;
      letter-spacing: -0.02em;
      line-height: 1.15;
      color: var(--color-ink);
      margin-bottom: 1.5rem;
    }

    h2 {
      font-family: var(--font-serif);
      font-size: clamp(1.25rem, 1.6vw + 0.75rem, 1.6rem);
      font-weight: 400;
      letter-spacing: -0.02em;
      line-height: 1.15;
      color: var(--color-ink);
      margin: 3rem 0 1.25rem;
    }

    .diagram-container { width: 100%; overflow-x: auto; }
    svg { width: 100%; min-width: 1280px; display: block; }

    @media print {
      .diagram-container { overflow-x: visible; }
      svg { min-width: 0; }
    }
  </style>
</head>
<body>
  <div class="frame">
    <p class="eyebrow">Swimlane · Claude Code model team</p>
    <h1>One team: Opus plans and judges, Haiku researches, three models build, Neon reviews first, Opus reviews what is risky</h1>

    <div class="diagram-container">
    <svg viewBox="0 0 1280 700" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="integrated-model-team-title integrated-model-team-desc">
      <title id="integrated-model-team-title">One model team: plan, research, build, advise, review</title>
      <desc id="integrated-model-team-desc">Swimlane diagram of how Opus, Haiku, Sonnet, GLM 5.3 and Gemini Neon work as one system: Haiku research feeds Opus planning, Opus briefs Sonnet, GLM and Neon who build in parallel, Sonnet may ask the Opus advisor, Neon reviews the combined diff first, and Opus judges, merges and calls the Opus reviewer only for risky changes.</desc>
      <defs>
        <pattern id="integrated-model-team-dots" width="22" height="22" patternUnits="userSpaceOnUse">
          <circle cx="1" cy="1" r="0.9" fill="rgba(45,49,66,0.10)"/>
        </pattern>
        <marker id="integrated-model-team-arrow" markerWidth="8" markerHeight="6" refX="7" refY="3" orient="auto"><polygon points="0 0, 8 3, 0 6" fill="#4f5d75"/></marker>
        <marker id="integrated-model-team-arrow-accent" markerWidth="8" markerHeight="6" refX="7" refY="3" orient="auto"><polygon points="0 0, 8 3, 0 6" fill="#bf4520"/></marker>
      </defs>

      <rect width="100%" height="100%" fill="#f5f5f5"/>
      <rect width="100%" height="100%" fill="url(#integrated-model-team-dots)" opacity="0.55"/>

      <!-- Column eyebrows -->
      <text x="320" y="88" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.18em">PLAN</text>
      <text x="560" y="88" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.18em">BUILD AND ADVISE</text>
      <text x="800" y="88" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.18em">REVIEW</text>
      <text x="1040" y="88" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.18em">JUDGE</text>

      <!-- Lane dividers -->
      <line x1="40" y1="100" x2="1240" y2="100" stroke="rgba(45,49,66,0.22)" stroke-width="1"/>
      <line x1="40" y1="200" x2="1240" y2="200" stroke="rgba(45,49,66,0.10)" stroke-width="1"/>
      <line x1="40" y1="300" x2="1240" y2="300" stroke="rgba(45,49,66,0.10)" stroke-width="1"/>
      <line x1="40" y1="400" x2="1240" y2="400" stroke="rgba(45,49,66,0.10)" stroke-width="1"/>
      <line x1="40" y1="500" x2="1240" y2="500" stroke="rgba(45,49,66,0.10)" stroke-width="1"/>
      <line x1="40" y1="600" x2="1240" y2="600" stroke="rgba(45,49,66,0.22)" stroke-width="1"/>
      <line x1="200" y1="100" x2="200" y2="600" stroke="rgba(45,49,66,0.22)" stroke-width="1"/>

      <!-- Lane labels -->
      <text x="60" y="146" fill="#2d3142" font-size="9" font-weight="600" font-family="'Geist Mono', monospace" letter-spacing="0.18em">OPUS</text>
      <text x="60" y="160" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace">plans, advises, reviews</text>
      <text x="60" y="246" fill="#2d3142" font-size="9" font-weight="600" font-family="'Geist Mono', monospace" letter-spacing="0.18em">HAIKU</text>
      <text x="60" y="260" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace">research, CLI wrappers</text>
      <text x="60" y="346" fill="#2d3142" font-size="9" font-weight="600" font-family="'Geist Mono', monospace" letter-spacing="0.18em">SONNET</text>
      <text x="60" y="360" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace">builder subagent</text>
      <text x="60" y="446" fill="#2d3142" font-size="9" font-weight="600" font-family="'Geist Mono', monospace" letter-spacing="0.18em">GLM 5.3</text>
      <text x="60" y="460" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace">builder, via OpenCode</text>
      <text x="60" y="546" fill="#2d3142" font-size="9" font-weight="600" font-family="'Geist Mono', monospace" letter-spacing="0.18em">NEON</text>
      <text x="60" y="560" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace">builder, reviewer, via agy</text>

      <!-- Arrows (drawn first) -->
      <line x1="280" y1="226" x2="280" y2="174" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#integrated-model-team-arrow)"/>
      <path d="M 384,174 V 342 Q 384,350 392,350 H 480" fill="none" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#integrated-model-team-arrow)"/>
      <path d="M 364,174 V 442 Q 364,450 372,450 H 480" fill="none" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#integrated-model-team-arrow)"/>
      <path d="M 344,174 V 542 Q 344,550 352,550 H 480" fill="none" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#integrated-model-team-arrow)"/>
      <line x1="560" y1="326" x2="560" y2="174" stroke="#4f5d75" stroke-width="1.2" stroke-dasharray="5,4" marker-end="url(#integrated-model-team-arrow)"/>
      <line x1="640" y1="550" x2="720" y2="550" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#integrated-model-team-arrow)"/>
      <path d="M 640,450 H 764 Q 772,450 772,458 V 526" fill="none" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#integrated-model-team-arrow)"/>
      <path d="M 640,350 H 820 Q 828,350 828,358 V 526" fill="none" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#integrated-model-team-arrow)"/>
      <path d="M 880,550 H 1032 Q 1040,550 1040,542 V 174" fill="none" stroke="#bf4520" stroke-width="1.4" marker-end="url(#integrated-model-team-arrow-accent)"/>
      <line x1="960" y1="150" x2="880" y2="150" stroke="#4f5d75" stroke-width="1.2" stroke-dasharray="5,4" marker-end="url(#integrated-model-team-arrow)"/>

      <!-- Arrow labels -->
      <rect x="288" y="204" width="44" height="12" rx="2" fill="#f5f5f5"/>
      <text x="310" y="213" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.12em">FACTS</text>

      <rect x="412" y="332" width="48" height="12" rx="2" fill="#f5f5f5"/>
      <text x="436" y="341" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.12em">BRIEFS</text>

      <rect x="568" y="236" width="36" height="12" rx="2" fill="#f5f5f5"/>
      <text x="586" y="245" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.12em">ASKS</text>

      <rect x="662" y="532" width="36" height="12" rx="2" fill="#f5f5f5"/>
      <text x="680" y="541" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.12em">DIFF</text>

      <rect x="1048" y="354" width="68" height="12" rx="2" fill="#f5f5f5"/>
      <text x="1082" y="363" fill="#bf4520" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.12em">FINDINGS</text>

      <rect x="902" y="132" width="36" height="12" rx="2" fill="#f5f5f5"/>
      <text x="920" y="141" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.12em">RISKY</text>

      <!-- Nodes -->
      <rect x="240" y="126" width="160" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="320" y="148" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Plan and brief</text>
      <text x="320" y="162" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">split, write briefs</text>

      <rect x="480" y="126" width="160" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1" stroke-dasharray="4,3"/>
      <text x="560" y="148" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Advise</text>
      <text x="560" y="162" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">advisor tool</text>

      <rect x="720" y="126" width="160" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1" stroke-dasharray="4,3"/>
      <text x="800" y="148" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Final review</text>
      <text x="800" y="162" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">reviewer subagent</text>

      <rect x="960" y="126" width="160" height="48" rx="6" fill="rgba(191,69,32,0.08)" stroke="#bf4520" stroke-width="1"/>
      <text x="1040" y="148" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Judge and merge</text>
      <text x="1040" y="162" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">diff, tests, PR</text>

      <rect x="240" y="226" width="80" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="280" y="248" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Research</text>
      <text x="280" y="262" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">search, web</text>

      <rect x="480" y="326" width="160" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="560" y="348" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Build</text>
      <text x="560" y="362" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">design, secrets, APIs</text>

      <rect x="480" y="426" width="160" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="560" y="448" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Build</text>
      <text x="560" y="462" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">tests, docs, ports</text>

      <rect x="480" y="526" width="160" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="560" y="548" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Build</text>
      <text x="560" y="562" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">agy-run, own files</text>

      <rect x="720" y="526" width="160" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="800" y="548" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">First-pass review</text>
      <text x="800" y="562" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">read-only, findings</text>

      <!-- Annotation callouts -->
      <text x="640" y="242" fill="#4f5d75" font-size="13" font-style="italic" font-family="'Instrument Serif', serif">Haiku also wraps GLM and Neon:</text>
      <text x="640" y="260" fill="#4f5d75" font-size="13" font-style="italic" font-family="'Instrument Serif', serif">it runs the CLI, checks the diff</text>
      <text x="640" y="278" fill="#4f5d75" font-size="13" font-style="italic" font-family="'Instrument Serif', serif">and the tests, then reports.</text>
      <text x="1064" y="428" fill="#4f5d75" font-size="13" font-style="italic" font-family="'Instrument Serif', serif">Fix rounds go back to the</text>
      <text x="1064" y="446" fill="#4f5d75" font-size="13" font-style="italic" font-family="'Instrument Serif', serif">builder that owns the file,</text>
      <text x="1064" y="464" fill="#4f5d75" font-size="13" font-style="italic" font-family="'Instrument Serif', serif">resumed, not a new one.</text>

      <!-- Legend -->
      <line x1="40" y1="628" x2="1240" y2="628" stroke="rgba(45,49,66,0.10)" stroke-width="0.8"/>
      <text x="40" y="648" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" letter-spacing="0.18em">LEGEND</text>
      <rect x="40" y="660" width="14" height="10" rx="2" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="60" y="668" fill="#4f5d75" font-size="8.5" font-family="'Geist', sans-serif">Step</text>
      <rect x="132" y="660" width="14" height="10" rx="2" fill="rgba(191,69,32,0.08)" stroke="#bf4520" stroke-width="1"/>
      <text x="152" y="668" fill="#4f5d75" font-size="8.5" font-family="'Geist', sans-serif">Decision</text>
      <rect x="244" y="660" width="14" height="10" rx="2" fill="#ffffff" stroke="#2d3142" stroke-width="1" stroke-dasharray="3,2"/>
      <text x="264" y="668" fill="#4f5d75" font-size="8.5" font-family="'Geist', sans-serif">Optional step</text>
      <line x1="376" y1="665" x2="404" y2="665" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#integrated-model-team-arrow)"/>
      <text x="412" y="668" fill="#4f5d75" font-size="8.5" font-family="'Geist', sans-serif">Handoff</text>
      <line x1="496" y1="665" x2="524" y2="665" stroke="#4f5d75" stroke-width="1.2" stroke-dasharray="4,3" marker-end="url(#integrated-model-team-arrow)"/>
      <text x="532" y="668" fill="#4f5d75" font-size="8.5" font-family="'Geist', sans-serif">Optional handoff</text>
      <line x1="660" y1="665" x2="688" y2="665" stroke="#bf4520" stroke-width="1.4" marker-end="url(#integrated-model-team-arrow-accent)"/>
      <text x="696" y="668" fill="#4f5d75" font-size="8.5" font-family="'Geist', sans-serif">Headline handoff</text>
    </svg>
    </div>

    <h2>Inside a Haiku wrapper: it hands the brief to the CLI, then checks the result itself</h2>

    <div class="diagram-container">
    <svg viewBox="0 0 1280 324" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="haiku-wrapper-title haiku-wrapper-desc">
      <title id="haiku-wrapper-title">What a Haiku wrapper does around a GLM or Neon run</title>
      <desc id="haiku-wrapper-desc">Flow of a Haiku wrapper agent: it saves the brief, runs the builder CLI, reads the result, checks the diff against the owned files, runs the build and tests itself, and reports, stopping early on an authentication, quota, denied command or git guard failure.</desc>
      <defs>
        <pattern id="haiku-wrapper-dots" width="22" height="22" patternUnits="userSpaceOnUse">
          <circle cx="1" cy="1" r="0.9" fill="rgba(45,49,66,0.10)"/>
        </pattern>
        <marker id="haiku-wrapper-arrow" markerWidth="8" markerHeight="6" refX="7" refY="3" orient="auto"><polygon points="0 0, 8 3, 0 6" fill="#4f5d75"/></marker>
      </defs>
      <rect width="100%" height="100%" fill="#f5f5f5"/>
      <rect width="100%" height="100%" fill="url(#haiku-wrapper-dots)" opacity="0.55"/>

      <!-- Arrows (drawn first) -->
      <line x1="180" y1="112" x2="216" y2="112" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#haiku-wrapper-arrow)"/>
      <line x1="356" y1="112" x2="392" y2="112" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#haiku-wrapper-arrow)"/>
      <line x1="532" y1="112" x2="568" y2="112" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#haiku-wrapper-arrow)"/>
      <line x1="708" y1="112" x2="744" y2="112" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#haiku-wrapper-arrow)"/>
      <line x1="884" y1="112" x2="920" y2="112" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#haiku-wrapper-arrow)"/>
      <line x1="462" y1="136" x2="462" y2="200" stroke="#4f5d75" stroke-width="1.2" stroke-dasharray="5,4" marker-end="url(#haiku-wrapper-arrow)"/>
      <line x1="638" y1="136" x2="638" y2="200" stroke="#4f5d75" stroke-width="1.2" stroke-dasharray="5,4" marker-end="url(#haiku-wrapper-arrow)"/>

      <!-- Arrow labels -->
      <rect x="470" y="160" width="68" height="12" rx="2" fill="#f5f5f5"/>
      <text x="504" y="169" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.12em">EXIT 3 4 5</text>
      <rect x="646" y="160" width="84" height="12" rx="2" fill="#f5f5f5"/>
      <text x="688" y="169" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.12em">OUTSIDE FILES</text>

      <!-- Nodes -->
      <rect x="40" y="88" width="140" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="110" y="110" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Save brief</text>
      <text x="110" y="124" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">outside the repo</text>
      <rect x="216" y="88" width="140" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="286" y="110" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Run the CLI</text>
      <text x="286" y="124" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">opencode run, agy-run</text>
      <rect x="392" y="88" width="140" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="462" y="110" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Read result</text>
      <text x="462" y="124" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">exit code, JSON</text>
      <rect x="568" y="88" width="140" height="48" rx="6" fill="rgba(191,69,32,0.08)" stroke="#bf4520" stroke-width="1"/>
      <text x="638" y="110" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Check diff</text>
      <text x="638" y="124" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">owned files only</text>
      <rect x="744" y="88" width="140" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="814" y="110" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Run tests</text>
      <text x="814" y="124" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">build, test</text>
      <rect x="920" y="88" width="140" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="990" y="110" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Report</text>
      <text x="990" y="124" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">claims vs checked</text>

      <rect x="392" y="200" width="316" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1" stroke-dasharray="4,3"/>
      <text x="550" y="222" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Stop and report</text>
      <text x="550" y="236" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">auth, quota, denied command, git guard</text>

      <!-- Annotation callout -->
      <text x="760" y="222" fill="#4f5d75" font-size="13" font-style="italic" font-family="'Instrument Serif', serif">It never trusts the builder's own claim that tests passed:</text>
      <text x="760" y="240" fill="#4f5d75" font-size="13" font-style="italic" font-family="'Instrument Serif', serif">it runs them, and says which results are only the builder's word.</text>

      <!-- Legend -->
      <line x1="40" y1="272" x2="1240" y2="272" stroke="rgba(45,49,66,0.10)" stroke-width="0.8"/>
      <text x="40" y="292" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" letter-spacing="0.18em">LEGEND</text>
      <rect x="40" y="304" width="14" height="10" rx="2" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="60" y="312" fill="#4f5d75" font-size="8.5" font-family="'Geist', sans-serif">Step</text>
      <rect x="132" y="304" width="14" height="10" rx="2" fill="rgba(191,69,32,0.08)" stroke="#bf4520" stroke-width="1"/>
      <text x="152" y="312" fill="#4f5d75" font-size="8.5" font-family="'Geist', sans-serif">The check that matters</text>
      <rect x="296" y="304" width="14" height="10" rx="2" fill="#ffffff" stroke="#2d3142" stroke-width="1" stroke-dasharray="3,2"/>
      <text x="316" y="312" fill="#4f5d75" font-size="8.5" font-family="'Geist', sans-serif">Early exit</text>
      <line x1="416" y1="309" x2="444" y2="309" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#haiku-wrapper-arrow)"/>
      <text x="452" y="312" fill="#4f5d75" font-size="8.5" font-family="'Geist', sans-serif">Handoff</text>
      <line x1="536" y1="309" x2="564" y2="309" stroke="#4f5d75" stroke-width="1.2" stroke-dasharray="4,3" marker-end="url(#haiku-wrapper-arrow)"/>
      <text x="572" y="312" fill="#4f5d75" font-size="8.5" font-family="'Geist', sans-serif">On failure</text>
    </svg>
    </div>
  </div>
</body>
</html>
```
````

# Notes

- **Where Haiku comes from:** the Opus and Fable advisor prompts set `CLAUDE_CODE_SUBAGENT_MODEL=haiku`, so search and research subagents run on Haiku (their output is research, never code, and they do not call the advisor); the GLM and Neon prompts make `glm-builder`, `agy-builder` and `agy-reviewer` thin Haiku wrappers that run a CLI, check `git status` and `git diff` against the owned files, run the build and tests themselves and report. The overview shows the first role as a node and the second in the lane label and a callout; the detail diagram shows the wrapper's steps.
- **Checked on this machine (25 Nov 2026):** `self_check.py` OK and `verify_geometry.py` 0 findings on each SVG separately; the combined page gives one false positive in the geometry check (two diagrams in one file), which is why section 4 checks them separately. The headless render looked clean (no crossings, labels clear of dividers). The upload through `omaxerahs upload --destination` returned a working URL serving `text/html`; re-uploading the same file name did not replace what the CDN served, which is why section 5 says to add a random suffix to the name, as XerahS's own upload path does.
- **Not done:** a dark variant and a PNG export (Playwright was not installed). The page uses Google Fonts, so a machine with no network falls back to system fonts.
- **Keep it true:** when a model, lane or rule changes, change section 2 first, then the reference implementation, then re-run the checks. The diagram is only useful while it matches `~/.claude/rules/model-team.md`.
- **Related:** [claude-code-opus-advisor-setup](claude-code-opus-advisor-setup.md), [claude-code-opus-glm-planner-builders-setup](claude-code-opus-glm-planner-builders-setup.md), [claude-code-opus-neon-agy-lane-setup](claude-code-opus-neon-agy-lane-setup.md).
