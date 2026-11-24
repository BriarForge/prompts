---
tags: [claude-code, model-team, diagram, swimlane, diagram-design, xerahs, opus, sonnet, glm, neon, reusable]
category: team-config
version: 1
last-used: 2026-11-25
---

# Draw the Claude Code model team as one diagram, and publish it through XerahS

Draws how Opus, Sonnet, GLM 5.3 and Gemini Neon work as one integrated system (planning, building, advising, reviewing) as a single self-contained HTML + SVG swimlane, using the [diagram-design](https://github.com/KovaForge/diagram-design) skill, then uploads it with the XerahS CLI. It documents the team set up by [claude-code-opus-glm-planner-builders-setup](claude-code-opus-glm-planner-builders-setup.md) and [claude-code-opus-neon-agy-lane-setup](claude-code-opus-neon-agy-lane-setup.md); redraw it whenever the roles change.

What the diagram says, in one paragraph: Opus (main) plans, writes the briefs and judges; it never writes code. Sonnet, GLM 5.3 and Neon build in parallel on separate files. Sonnet may ask the Opus advisor. Neon reads the combined diff first and returns findings. Opus judges and merges, and calls the Opus reviewer only for risky changes (security, auth, migrations, public API). Fix rounds go back to the builder that owns the file.

````text
Draw the Claude Code model team as one swimlane diagram with the diagram-design skill, check it, look at it, and publish it. Do not skip the checks.

## 0. Ground rules
- Facts below were checked on 25 Nov 2026. If the skill or a CLI behaves differently, the tool wins: adapt and say what differed.
- The diagram holds no secrets, paths, hostnames or account names. Do not add any.
- Upload only to a destination I own, and only after the checks pass.

## 1. Get the skill
1. If `diagram-design` is not installed as a skill (`~/.claude/skills/diagram-design`), clone it for reference: `gh repo clone KovaForge/diagram-design /tmp/dd -- --depth 1`. The skill is `skills/diagram-design/` (SKILL.md, references/, scripts/, assets/).
2. Read SKILL.md fully, then `references/type-swimlane.md`, `references/primitives-core.md` (the six mandatory connector rules), `references/output-spec.md` (size presets, type ramp) and `references/layout-budget.md`. Note the budget per diagram: at most 9 nodes, 12 arrows, 2 coral elements, 2 callouts, 5 swimlane lanes.
3. First-diagram gate: the skill asks whether to customise the style guide. Keep the default skin unless I say otherwise, and say that you did.

## 2. The plan (state it before drawing)
Type: swimlane. Size preset: `doc-wide`, viewBox `0 0 1280 700` (the 720 preset height shortened to leave the legend strip), `min-width: 1280px` inside a local `overflow-x: auto` wrapper. Variant: minimal light.

Lanes, top to bottom (5): OPUS main (plans, judges); OPUS advisor and reviewer; SONNET builder subagent; GLM 5.3 builder via OpenCode; NEON builder and reviewer via agy.
Columns: PLAN, BUILD AND ADVISE, REVIEW, JUDGE.
Nodes (8): Plan and brief (Opus main, plan); Judge and merge (Opus main, judge, the one coral focal node); Advise (Opus advisor lane, optional, dashed box); Final review (Opus reviewer lane, optional, dashed box); Build in the Sonnet lane (design, secrets, APIs); Build in the GLM lane (tests, docs, ports); Build in the Neon lane (agy-run, own files); First-pass review (Neon lane, read-only findings).
Arrows (9), all orthogonal, no crossings: Plan to each of the three Build nodes (label BRIEFS on one); Sonnet Build to Advise, dashed (ASKS); Neon Build to First-pass review (DIFF); GLM Build and Sonnet Build to First-pass review (enter its top edge at separate points); First-pass review to Judge and merge, coral (FINDINGS, the headline handoff, the second coral element); Judge and merge to Final review, dashed (RISKY ONLY).
Callouts (2, italic serif): "Opus never writes code. It plans, briefs and judges." and "Fix rounds go back to the builder that owns the file, resumed, not a new one."
Legend strip along the bottom: Step, Decision, Optional step, Handoff, Optional handoff, Headline handoff.
Cut on purpose: the Haiku search subagents, the wrapper agents (they only run a CLI), tests and the git guard. They are mechanics, not roles.

## 3. Draw
Start from the skill's `assets/example-swimlane.html`. Use the reference implementation below as the layout: it already passes every check. Rules to keep when you change anything: arrows drawn before boxes; each arrow label on an opaque `fill="#f5f5f5"` mask, 6 to 10 px from its stroke, never on a lane divider; fan attach points 12 px or more apart; structure on the 4 px grid; the SVG has `role="img"`, `aria-labelledby`, and `<title>` as its first child with IDs `<slug>-title` and `<slug>-desc` where the slug is the file name (`integrated-model-team`).

## 4. Check (all must pass), then look
1. `python3 scripts/self_check.py <file>` prints `OK`.
2. `python3 scripts/verify_geometry.py <file>` reports `0 finding(s)`.
3. Render it and look at the picture yourself. `scripts/export_png.py` needs Playwright; if it is missing use the browser: `google-chrome-stable --headless=new --disable-gpu --no-sandbox --hide-scrollbars --window-size=1400,900 --screenshot=<png> file://<html>`. Check: no crossings, no label touching its stroke or a lane divider, nothing clipped, the coral used on two elements only.

## 5. Publish through XerahS
1. Do not run `xerahs` itself (it starts the GUI). Use the CLI `omaxerahs`.
2. `omaxerahs doctor --json` must report the destination ready. If it does not, stop and tell me; do not write uploader secrets.
3. `omaxerahs upload <file>` only accepts images (`unsupported_type` for HTML). For any other file use a named File destination: `omaxerahs upload --destination "<display name from doctor>" --json -- <file>`. It keeps the file name and returns the URL.
4. Confirm the URL serves it: `curl -sI <url>` shows HTTP 200 and `content-type: text/html`.
5. Report: the URL, the checks and their results, and what you decided (skin, size, what was cut).

## 6. Reference implementation (passes self_check and verify_geometry)
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
    <h1>One team: Opus plans and judges, three models build, Neon reviews first, Opus reviews what is risky</h1>

    <div class="diagram-container">
    <svg viewBox="0 0 1280 700" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="integrated-model-team-title integrated-model-team-desc">
      <title id="integrated-model-team-title">One model team: plan, build, advise, review</title>
      <desc id="integrated-model-team-desc">Swimlane diagram of how Opus, Sonnet, GLM 5.3 and Gemini Neon work as one system: Opus plans and briefs, Sonnet, GLM and Neon build in parallel, Sonnet may ask the Opus advisor, Neon reviews the combined diff first, and Opus judges, merges and calls the Opus reviewer only for risky changes.</desc>
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

      <!-- Actor column divider -->
      <line x1="200" y1="100" x2="200" y2="600" stroke="rgba(45,49,66,0.22)" stroke-width="1"/>

      <!-- Lane labels -->
      <text x="60" y="146" fill="#2d3142" font-size="9" font-weight="600" font-family="'Geist Mono', monospace" letter-spacing="0.18em">OPUS</text>
      <text x="60" y="160" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace">main: plans, judges</text>
      <text x="60" y="246" fill="#2d3142" font-size="9" font-weight="600" font-family="'Geist Mono', monospace" letter-spacing="0.18em">OPUS</text>
      <text x="60" y="260" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace">advisor, reviewer</text>
      <text x="60" y="346" fill="#2d3142" font-size="9" font-weight="600" font-family="'Geist Mono', monospace" letter-spacing="0.18em">SONNET</text>
      <text x="60" y="360" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace">builder subagent</text>
      <text x="60" y="446" fill="#2d3142" font-size="9" font-weight="600" font-family="'Geist Mono', monospace" letter-spacing="0.18em">GLM 5.3</text>
      <text x="60" y="460" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace">builder, via OpenCode</text>
      <text x="60" y="546" fill="#2d3142" font-size="9" font-weight="600" font-family="'Geist Mono', monospace" letter-spacing="0.18em">NEON</text>
      <text x="60" y="560" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace">builder, reviewer, via agy</text>

      <!-- Arrows (drawn first) -->
      <!-- 1. Plan to Sonnet build -->
      <path d="M 360,174 V 342 Q 360,350 368,350 H 480" fill="none" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#integrated-model-team-arrow)"/>
      <!-- 2. Plan to GLM build -->
      <path d="M 320,174 V 442 Q 320,450 328,450 H 480" fill="none" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#integrated-model-team-arrow)"/>
      <!-- 3. Plan to Neon build -->
      <path d="M 280,174 V 542 Q 280,550 288,550 H 480" fill="none" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#integrated-model-team-arrow)"/>
      <!-- 4. Sonnet build asks the advisor (optional) -->
      <line x1="560" y1="326" x2="560" y2="274" stroke="#4f5d75" stroke-width="1.2" stroke-dasharray="5,4" marker-end="url(#integrated-model-team-arrow)"/>
      <!-- 5. Neon build to Neon review -->
      <line x1="640" y1="550" x2="720" y2="550" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#integrated-model-team-arrow)"/>
      <!-- 6. GLM build to Neon review -->
      <path d="M 640,450 H 764 Q 772,450 772,458 V 526" fill="none" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#integrated-model-team-arrow)"/>
      <!-- 7. Sonnet build to Neon review -->
      <path d="M 640,350 H 820 Q 828,350 828,358 V 526" fill="none" stroke="#4f5d75" stroke-width="1.2" marker-end="url(#integrated-model-team-arrow)"/>
      <!-- 8. Neon review findings to judge (headline handoff) -->
      <path d="M 880,550 H 1032 Q 1040,550 1040,542 V 174" fill="none" stroke="#bf4520" stroke-width="1.4" marker-end="url(#integrated-model-team-arrow-accent)"/>
      <!-- 9. Judge calls the Opus reviewer for risky changes (optional) -->
      <path d="M 960,150 H 936 Q 928,150 928,158 V 242 Q 928,250 920,250 H 880" fill="none" stroke="#4f5d75" stroke-width="1.2" stroke-dasharray="5,4" marker-end="url(#integrated-model-team-arrow)"/>

      <!-- Arrow labels -->
      <rect x="400" y="332" width="48" height="12" rx="2" fill="#f5f5f5"/>
      <text x="424" y="341" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.12em">BRIEFS</text>

      <rect x="568" y="306" width="36" height="12" rx="2" fill="#f5f5f5"/>
      <text x="586" y="315" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.12em">ASKS</text>

      <rect x="662" y="532" width="36" height="12" rx="2" fill="#f5f5f5"/>
      <text x="680" y="541" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.12em">DIFF</text>

      <rect x="1048" y="354" width="68" height="12" rx="2" fill="#f5f5f5"/>
      <text x="1082" y="363" fill="#bf4520" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.12em">FINDINGS</text>

      <rect x="936" y="212" width="76" height="12" rx="2" fill="#f5f5f5"/>
      <text x="974" y="221" fill="#4f5d75" font-size="8" font-family="'Geist Mono', monospace" text-anchor="middle" letter-spacing="0.12em">RISKY ONLY</text>

      <!-- Nodes -->
      <!-- Opus main: Plan and brief -->
      <rect x="240" y="126" width="160" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="320" y="148" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Plan and brief</text>
      <text x="320" y="162" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">split, write briefs</text>

      <!-- Opus main: Judge and merge (focal) -->
      <rect x="960" y="126" width="160" height="48" rx="6" fill="rgba(191,69,32,0.08)" stroke="#bf4520" stroke-width="1"/>
      <text x="1040" y="148" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Judge and merge</text>
      <text x="1040" y="162" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">diff, tests, PR</text>

      <!-- Opus advisor (optional) -->
      <rect x="480" y="226" width="160" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1" stroke-dasharray="4,3"/>
      <text x="560" y="248" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Advise</text>
      <text x="560" y="262" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">advisor tool</text>

      <!-- Opus reviewer (optional) -->
      <rect x="720" y="226" width="160" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1" stroke-dasharray="4,3"/>
      <text x="800" y="248" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Final review</text>
      <text x="800" y="262" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">reviewer subagent</text>

      <!-- Sonnet build -->
      <rect x="480" y="326" width="160" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="560" y="348" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Build</text>
      <text x="560" y="362" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">design, secrets, APIs</text>

      <!-- GLM build -->
      <rect x="480" y="426" width="160" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="560" y="448" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Build</text>
      <text x="560" y="462" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">tests, docs, ports</text>

      <!-- Neon build -->
      <rect x="480" y="526" width="160" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="560" y="548" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">Build</text>
      <text x="560" y="562" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">agy-run, own files</text>

      <!-- Neon review -->
      <rect x="720" y="526" width="160" height="48" rx="6" fill="#ffffff" stroke="#2d3142" stroke-width="1"/>
      <text x="800" y="548" fill="#2d3142" font-size="12" font-weight="600" font-family="'Geist', sans-serif" text-anchor="middle">First-pass review</text>
      <text x="800" y="562" fill="#4f5d75" font-size="9" font-family="'Geist Mono', monospace" text-anchor="middle">read-only, findings</text>

      <!-- Annotation callouts -->
      <text x="440" y="146" fill="#4f5d75" font-size="13" font-style="italic" font-family="'Instrument Serif', serif">Opus never writes code.</text>
      <text x="440" y="164" fill="#4f5d75" font-size="13" font-style="italic" font-family="'Instrument Serif', serif">It plans, briefs and judges.</text>
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
  </div>
</body>
</html>
```
````

# Notes

- **Checked on this machine (25 Nov 2026):** `self_check.py` OK, `verify_geometry.py` 0 findings, the headless-browser render looked clean (no crossings, labels clear of lane dividers after moving two), and the upload through `omaxerahs upload --destination` returned a working URL that served `text/html`. The page uses Google Fonts, so a machine with no network falls back to system fonts.
- **Not done:** a dark variant and a PNG export (Playwright was not installed). The diagram is an overview: if the team grows past nine nodes, split it into an overview and one detail diagram, as the skill's budget says.
- **Keep it true:** when a model, lane or rule changes, change section 2 first, then the reference implementation, then re-run the checks. The diagram is only useful while it matches `~/.claude/rules/model-team.md`.
- **Related:** [claude-code-opus-glm-planner-builders-setup](claude-code-opus-glm-planner-builders-setup.md), [claude-code-opus-neon-agy-lane-setup](claude-code-opus-neon-agy-lane-setup.md).
