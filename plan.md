# CCG Homepage Redesign Port — Chunked Execution Plan

> **Source**: `/Users/mike/Downloads/CCG/index.html` (1,703 lines, standalone)
> **Target**: `/Users/mike/claude-skills-guide/index.md` (785 lines, Jekyll `layout: default`)
> **Layout**: `/Users/mike/claude-skills-guide/_layouts/default.html` (504 lines)
> **Global CSS**: `/Users/mike/claude-skills-guide/assets/css/style.css` (1,374 lines)
> **Created**: 2026-04-20
> **Status**: COMPLETE — All 7 batches, 26 chunks executed 2026-04-20

---

## Architecture Decision Record

### Key Constraint
The new design is a standalone 1,703-line HTML file with its own nav, footer, oklch color system, 4 Google Fonts families, theme toggle, interactive generator, and tweaks panel. The live site uses Jekyll `layout: default` which injects its own nav bar, footer, breadcrumbs, structured data, AdSense, sticky CTA bar, and in-content CTA scripts. The homepage (`index.md`) uses `layout: default` and places all visual content in the `{{ content }}` block, which lands inside `<section class="page-body">`.

### Critical Conflicts Identified

| Area | New Design | Existing Site | Conflict |
|------|-----------|---------------|----------|
| Nav | `.nav` with brand mark, nav-links, theme toggle, CTA | `.site-header > .site-nav` with 11 links | Both render; doubled nav |
| Footer | `.footer` 4-column grid | `<footer>` simple centered text (hidden on homepage via `{% unless page.url == "/" %}`) | Footer already suppressed on homepage -- safe to add new one |
| Body reset | `max-width: none`, full-bleed sections | `body { max-width: 900px }` in style.css | Current index.md already overrides with `!important` |
| Fonts | Instrument Serif, Inter, JetBrains Mono, Fraunces | DM Sans, Fraunces, Inter, JetBrains Mono | Need to add Instrument Serif; drop DM Sans on homepage |
| Colors | oklch with `--accent-h` hue variable, light/dark theme | Hex values `#d97757`, `#0a0a0a`, `#faf9f5` | oklch needs scoping to homepage |
| `.hero` class | Both files use `.hero` | Collision -- existing style.css defines `.hero` | Must rename or scope |
| `.stats` class | Both files use `.stats` | Collision -- existing style.css defines `.stats` | Must rename or scope |
| h2::after | style.css adds accent underline to all h2 | New design has no h2::after | Current index.md already kills this |

---

## BATCH 0: PRE-FLIGHT (Setup)

### Chunk 0.1: Create homepage layout

**Decision: Option C -- Create a separate layout for homepage**

Rationale:
- Option A (modify `default.html`) is dangerous: it affects ALL 3,021 articles + topic pages
- Option B (CSS hide nav on homepage) is hacky and leaves dead HTML in the DOM
- Option C is cleanest: a new `_layouts/homepage.html` that shares the `<head>` logic but uses the new nav/footer

**Files to modify:**
- CREATE: `/Users/mike/claude-skills-guide/_layouts/homepage.html`

**Changes:**
- Copy `default.html` as starting point
- Remove the `<header class="site-header">` nav block
- Remove the `<nav class="breadcrumbs">` block
- Remove the `{% unless page.url == "/" %}` footer block
- Remove the `article-body` / `author-cta` / `related-guides` article wrappers
- Keep: `<head>` (SEO, structured data, fonts, AdSense, critical CSS)
- Keep: `<a href="#main-content" class="skip-link">`
- Keep: `<main id="main-content">`
- Keep: sticky footer CTA bar + script (it's a site-wide conversion element)
- Add: Instrument Serif to the Google Fonts `<link>` (Fraunces, Inter, JetBrains Mono already loaded)
- Render `{{ content }}` without the `.page-body` wrapper
- Update frontmatter in `index.md` to `layout: homepage`

**QA:**
- `grep -c 'site-header' _layouts/homepage.html` returns 0
- `grep -c 'layout: homepage' index.md` returns 1
- All other pages still use `layout: default` (unchanged)

---

## BATCH 1: CSS FOUNDATION

### Chunk 1.1: Port design tokens

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md` -- replace the existing `<style>` block

**Changes:**
Port these design tokens from the new design into the `<style>` block in `index.md`:

```
:root {
  --accent-h: 38;
  --accent: oklch(0.72 0.11 var(--accent-h));
  --accent-dim: oklch(0.56 0.09 var(--accent-h));
  --accent-ink: oklch(0.18 0.04 var(--accent-h));
  --serif: 'Instrument Serif', 'Times New Roman', serif;
  --serif-alt: 'Fraunces', 'Instrument Serif', 'Times New Roman', serif;
  --sans: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  --mono: 'JetBrains Mono', ui-monospace, 'SF Mono', Menlo, monospace;
  --track-tight: 0.08em;
  --track: 0.12em;
  --track-wide: 0.18em;
  --u: 8px;
}
```

**Token mapping (new -> existing for reference):**
| New token | oklch value | Nearest existing hex | Notes |
|-----------|-----------|---------------------|-------|
| `--accent` | `oklch(0.72 0.11 38)` | `#d97757` (--accent in old) | Very close -- warm terracotta |
| `--bg` (dark) | `oklch(0.155 0.007 60)` | `#0a0a0a` / `#141413` | Slightly warmer than old |
| `--ink` (dark) | `oklch(0.97 0.006 80)` | `#faf9f5` / `#f2f0ea` | Near-white, compatible |
| `--ink-2` | `oklch(0.80 0.008 70)` | `#b0aea5` (--ink-muted) | Muted text |
| `--line` | `oklch(0.30 0.010 60)` | `#2e2e2a` | Border/rule color |

**Dark theme tokens** -- scope to `html[data-theme="dark"]`:
- `--bg`, `--bg-2`, `--bg-3`, `--line`, `--line-soft`, `--ink` through `--ink-4`
- `--green`, `--red`, `--blue`, `--shadow-1`, `--shadow-2`

**Light theme tokens** -- scope to `html[data-theme="light"]`:
- All the light-mode variants

**Conflict avoidance:**
- The old `index.md` tokens (`--bg: #0a0a0a`, `--ink: #f2f0ea`, etc.) will be REPLACED, not appended
- The old `--font-serif`, `--font-sans`, `--font-mono` names change to `--serif`, `--sans`, `--mono`
- All class selectors in `index.md` that reference old token names must be updated

**QA:**
- Zero CSS parse errors: `npx stylelint index.md` (or manual visual inspection)
- Verify oklch renders in Chrome 111+, Safari 15.4+, Firefox 113+ (our audience)
- Fallback: not needed -- oklch browser support is 95%+ as of 2026

### Chunk 1.2: Port layout helpers and typographic scale

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md` (inline `<style>` block)

**Changes -- layout helpers:**
```
.wrap { max-width: 1360px; margin: 0 auto; padding: 0 40px; }
.wrap-tight { max-width: 1120px; margin: 0 auto; padding: 0 40px; }
.hair { border: 0; border-top: 1px solid var(--line); margin: 0; }
.hair-soft { border: 0; border-top: 1px solid var(--line-soft); margin: 0; }
```

**Changes -- typographic scale:**
```
.display { ... }          /* Hero headline: clamp(52px, 8vw, 128px) */
.display i { ... }        /* Accent italic in display */
.h2 { ... }               /* Section headline: clamp(44px, 5vw, 80px) */
.h2 i { ... }             /* Accent italic in h2 */
.h3 { ... }               /* Card titles: 34px */
.eyebrow { ... }          /* Mono uppercase labels: 11px */
.mono { ... }             /* Mono family utility */
.num { ... }              /* Tabular nums utility */
```

**Conflict note:** The `.h2` and `.h3` classes use generic names but won't conflict with `style.css`'s `h2` and `h3` element selectors because these are class selectors, not element selectors.

**QA:**
- `.wrap` produces centered content at max 1360px on a 1440px viewport
- `.display` font-size is visually ~52px on 375px screen, ~128px on 1440px screen

### Chunk 1.3: Port responsive breakpoints

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md` (inline `<style>` block)

**Changes -- add all four breakpoint blocks from the new design:**

1. `@media (max-width: 880px)` -- grid collapse, hide nav-links, hide hero-stack
2. `@media (max-width: 900px)` -- tablet: wrap padding to 24px, hero/stats/guides/pricing/footer stack to 1col
3. `@media (max-width: 640px)` -- mobile: body font 14.5px, wrap padding to 18px, tighter nav, smaller display, 44px min touch targets
4. `@media (max-width: 380px)` -- tiny phones: wrap padding 14px, display 36px, hide "Guides" from brand word
5. `@media (hover: none) and (pointer: coarse)` -- touch target baseline

**Note:** Remove the existing responsive rules in `index.md` (lines 579-615 of current file) that target 900px, 768px, 375px. They reference the old class names.

**QA:**
- Chrome DevTools responsive mode at 380px, 640px, 900px, 1360px
- No horizontal scroll at any breakpoint
- All tap targets >= 44px on touch devices

---

## BATCH 2: NAV INTEGRATION

### Chunk 2.1: Port new nav into homepage layout

**Recommendation: Option C -- separate `homepage.html` layout** (detailed in Chunk 0.1 above)

**Files to modify:**
- `/Users/mike/claude-skills-guide/_layouts/homepage.html` (created in Chunk 0.1)
- `/Users/mike/claude-skills-guide/index.md` (frontmatter change + nav HTML)

**Changes:**
The new nav HTML goes into `index.md` content (not the layout), because it's homepage-specific content. The layout just provides a clean shell without the default nav.

Nav HTML to port (from new design lines 1056-1078):
```html
<nav class="nav">
  <div class="nav-inner">
    <a class="brand" href="/">
      <span class="brand-mark">&#926;</span>
      <span class="brand-word">Claude Code <span>Guides</span></span>
    </a>
    <div class="nav-links">
      <a href="/all-articles/">Guides <span style="...">3,020</span></a>
      <a href="/generator/">Generator</a>
      <a href="/about/">About</a>
      <a href="#pricing">Pricing</a>
      <a href="https://discord.com/invite/QeHxTFbqmC" target="_blank" rel="noopener noreferrer">Community &#8599;</a>
    </div>
    <div class="nav-right">
      <button class="theme-toggle" id="themeBtn" aria-label="Toggle theme">
        <svg id="themeIcon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
          <path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/>
        </svg>
      </button>
      <a class="btn btn-primary" href="https://zovo.one/lifetime">Get lifetime &#8594;</a>
    </div>
  </div>
</nav>
```

**Nav CSS to port:** Lines 140-204 of new design (`.nav`, `.nav-inner`, `.brand`, `.brand-mark`, `.brand-word`, `.nav-links`, `.nav-right`, `.theme-toggle`, `.btn`, `.btn-primary`, `.btn-ghost`)

**Data updates:**
- `#guides` -> `/all-articles/`
- `#generator` -> `/generator/`
- `#stats` -> `/about/`
- `#pricing` stays as anchor (on-page)
- Community -> `https://discord.com/invite/QeHxTFbqmC`
- `2,665` -> `3,020`

**QA:**
- Nav is sticky at top on scroll
- Brand mark renders xi character (&#926;)
- All nav links resolve to real pages
- Theme toggle button is visible but JS wired in Batch 5
- Mobile (<= 880px): nav-links hidden, brand + CTA still visible

---

## BATCH 3: HERO SECTION

### Chunk 3.1: Hero meta bar

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md`

**HTML to port** (lines 1084-1089 of new design):
```html
<div class="hero-meta">
  <div><span>Vol. 04 / Iss. 118</span><span>Apr 20, 2026</span></div>
  <div><span>Last update</span><b>47 min ago</b></div>
  <div><span>Guides shipped</span><b>3,020</b></div>
  <div><span>Status</span><b style="color:var(--green)">&#9679; Operational</b></div>
</div>
```

**CSS to port:** `.hero-meta` and children (lines 212-235)

**Data updates:**
- `2,665` -> `3,020` (actual article count is 3,021)
- Date should be static or use Jekyll `{{ site.time | date: "%b %d, %Y" }}`

**QA:**
- 4-column bar at desktop, 2-column at 900px, 1-column at 640px
- Monospace text, uppercase, proper truncation on small screens

### Chunk 3.2: Hero grid (copy + CLAUDE.md pane)

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md`

**HTML to port** (lines 1091-1157 of new design):
- `.hero-grid` (2-column: copy | mdpane)
- `.hero-copy` with `.kicker`, `.display` headline, `.hero-sub`, `.hero-cta`, `.hero-note`
- `.mdpane` with `.mdpane-head`, `.mdpane-body` (line-numbered CLAUDE.md preview), `.mdpane-foot`

**CSS to port:** Lines 206-366 of new design (hero, mdpane, code highlighting classes)

**Data updates:**
- `2,665` -> `3,020` in CTA button text ("Browse 3,020 guides")
- CTA link `#generator` -> `/generator/`
- CTA link `#guides` -> `/all-articles/`
- Pricing link `#pricing` stays (on-page anchor)

**Conflict resolution:**
- The new design uses `.hero` class -- the existing `style.css` also defines `.hero` (lines 382-403)
- The current `index.md` already has overrides for `.hero { text-align: left !important; ... }`
- SOLUTION: The new design's `.hero` styles go in the inline `<style>` block and will override `style.css` due to specificity (inline styles > external stylesheet). But since we're using a new layout (`homepage.html`) that doesn't load `.page-body` wrapper, and the new hero padding/layout is completely different, we need to ensure the old `.hero` selector in `style.css` doesn't leak. Add a body-level class `.hp` to scope: `body.hp .hero { ... }`
- OR: simpler -- the inline `<style>` in `index.md` is parsed AFTER `style.css` (it comes later in the HTML), so it will naturally win in cascade. Verify no `!important` conflicts.

**QA:**
- Hero grid: 2 columns at desktop, stacks at 900px
- CLAUDE.md pane: code block with syntax highlighting (colored spans for comments, keys, strings)
- Kicker badge has green blinking dot
- Line numbers render correctly (1-23)

### Chunk 3.3: Hero floating stack card

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md`

**HTML to port** (lines 1153-1157):
```html
<div class="hero-stack">
  <div class="row"><b>stack</b><span>next + ts + prisma</span></div>
  <div class="row"><b>guides matched</b><span>34</span></div>
  <div class="row"><b>est. tokens saved</b><span class="up">&#8595; 62%</span></div>
</div>
```

**CSS:** `.hero-stack` (lines 348-367) -- absolute positioned, hidden at <= 880px

**QA:**
- Card floats bottom-right of the mdpane at desktop
- Hidden on tablet/mobile
- Green color for "up" class

---

## BATCH 4: CONTENT SECTIONS

### Chunk 4.1: Stats section (3 stat cards + mini charts)

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md`

**HTML to port** (lines 1162-1234): Full `.stats` section with `.stats-head`, `.stats-grid` (3 `.stat` cards), each containing `.stat-label`, `.stat-num`, `.stat-chart` (bar chart), `.stat-body`.

**CSS to port:** Lines 368-429

**Data updates:**
- `2,665` -> `3,020`
- All other stats remain as-is ($400K+, 50K+)

**Conflict resolution:**
- `.stats` class collision with `style.css` lines 504-529 (existing `.stats`, `.stat`, `.stat .number`, `.stat .label`)
- SOLUTION: The inline styles in `index.md` will override the external stylesheet naturally. But we need to verify no leakage. The existing `.stats` uses `display: flex` while the new one uses a completely different structure. Since we're on a new layout with no `.page-body` wrapper, and the inline `<style>` comes after `style.css`, the new rules will win. Add an explicit reset: `.stats { display: block; padding: ...; }` to force override.

**QA:**
- 3 columns at desktop, 1 column at <= 880px
- Stat numbers use serif font at clamp(88px, 9vw, 128px)
- Mini bar charts visible with accent-colored "on" bars

### Chunk 4.2: Bio strip

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md`
- CREATE: `/Users/mike/claude-skills-guide/assets/portrait.jpg` (from user's photo)

**HTML to port** (lines 1223-1233): `.bio` section with `.bio-portrait`, `.bio-text`, `.bio-meta`

**CSS to port:** Lines 431-459

**Portrait image:**
- Source: `/Users/mike/Documents/Screenshot 2026-04-20 at 3.31.33 PM.png`
- Process: resize to 216x216 (2x for retina of 108x108 display), compress to JPEG, save as `/Users/mike/claude-skills-guide/assets/portrait.jpg`
- Replace the CSS placeholder background (`repeating-linear-gradient`) with `background-image: url('/assets/portrait.jpg'); background-size: cover;`
- Remove the "portrait" text content from the div

**Data updates:**
- Bio text stays as-is (Michael Lip, Da Nang, agent fleet)
- Update links: `zovo.one` -> `https://zovo.one`, `github/theluckystrike` -> `https://github.com/theluckystrike`

**QA:**
- Portrait renders as 108px circle at desktop, 140px at mobile
- 3-column grid at desktop (portrait | text | meta), stacks at <= 880px
- Portrait image loads without CORS issues on GitHub Pages

### Chunk 4.3: Guides section (tabs + featured card + secondary grid + row cards)

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md`

**HTML to port** (lines 1238-1348): Full `.guides` section with:
- `.section-head` (eyebrow, h2, subtitle, browse CTA)
- `.guide-tabs` (7 tab buttons)
- `.guide-grid` (1 featured `.guide.feat` + 2 secondary `.guide` cards)
- `.guides-more` (8 `.guide-row` link cards)

**CSS to port:** Lines 461-608

**Data updates (CRITICAL -- all placeholder data must be replaced):**

Tab counts (from actual repo article counts):
| Tab | Placeholder | Real count |
|-----|------------|------------|
| Trending | 12 | 12 (keep -- editorial) |
| Newest | 47 | 47 (keep -- editorial) |
| API | 213 | 134 |
| Agents | 189 | 66 |
| MCP | 104 | 92 |
| Prompts | 312 | 34 |
| Getting started | 88 | 60 |
| Extensions (add) | -- | 416 |

**Decision:** The tab counts in the prototype are aspirational. Replace with real counts from the repo. Also add an "Extensions" tab since it's the largest category (416 articles).

Featured article slugs (replace `#` hrefs):
| Card | Current | Real slug |
|------|---------|-----------|
| Featured (#1) | `#` | `/claude-api-timeout-error-handling-retry-guide/` |
| Secondary (Opus) | `#` | `/claude-opus-orchestrator-sonnet-worker-architecture/` |
| Secondary (FPGA) | `#` | `/claude-code-for-fpga-development-workflow-tutorial/` |
| Row: MCP | `#` | `/building-custom-mcp-server-python-tutorial/` (verify exists) |
| Row: Prompts | `#` | `/best-claude-code-prompts-for-developers/` (verify exists) |
| Row: Start | `#` | `/claude-md-monorepo-configuration-guide/` (verify exists) |
| Row: Ext | `#` | `/chrome-extension-zero-build-step-guide/` (verify exists) |
| Row: API | `#` | `/claude-api-rate-limit-backoff-patterns/` (verify exists) |
| Row: Agents | `#` | `/ai-agent-tool-use-loop-patterns/` (verify exists) |
| Row: Cost | `#` | `/reduce-claude-api-costs-optimization-guide/` (verify exists) |
| Row: Debug | `#` | `/debug-flaky-agent-runs-deterministic-seeds/` (verify exists) |

**NOTE:** All row card slugs must be verified against actual files in `/Users/mike/claude-skills-guide/articles/`. If a slug doesn't exist, find the closest matching article.

Browse all CTA: `#` -> `/all-articles/`
"3,020" in text

**QA:**
- Featured card spans 2 rows in the grid at desktop
- Guide tabs are horizontally scrollable on mobile
- All 8 row cards render in a 4-column grid at desktop, 1-column at mobile
- Every link resolves to a real article

### Chunk 4.4: Generator section (interactive form with chips)

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md`

**HTML to port** (lines 1351-1421): `.gen-section` with:
- `.gen-intro` (eyebrow, h2, description, feature list)
- `.gen-demo` (mock form: framework chips, language chips, constraint chips, output preview)

**CSS to port:** Lines 610-702

**Data updates:**
- `#generator` is an on-page anchor; the demo links to the real generator
- "27 stacks" stays (matches generator page)

**JS dependency:** Chip toggle behavior (wired in Batch 5)

**QA:**
- 2-column grid at desktop, stacks at <= 900px
- Chips toggle on/off visually (accent background when "on")
- Output preview updates framework/language text on chip click
- Green pulsing dot in demo header

### Chunk 4.5: Pricing section (3-tier + math box)

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md`

**HTML to port** (lines 1424-1492): `.pricing` section with:
- `.section-head` (eyebrow, h2, subtitle, date metadata)
- `.price-grid` (3 `.price` cards: Free, Community, Lifetime)
- `.price-math` (the breakeven equation box)

**CSS to port:** Lines 704-783

**Data updates:**
- `2,665` -> `3,020` in Free tier feature
- Free "Keep browsing" -> `/all-articles/`
- Community "Join community" -> `https://zovo.one/community`
- Lifetime "Get lifetime" -> `https://zovo.one/lifetime`
- Date metadata: `Apr 20, 2026` (or Jekyll dynamic)

**QA:**
- 3 columns at desktop, 1 column at mobile
- Lifetime card (`.price.hi`) has darker background
- "Most chosen" tag renders as pill badge
- Math box is dashed-border with equation

### Chunk 4.6: Footer (4-column layout)

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md`

**HTML to port** (lines 1496-1533): `.footer` with:
- `.footer-top` (4-column grid: brand | Read | Tools | Elsewhere)
- `.foot-bottom` (copyright + version)

**CSS to port:** Lines 785-828

**Data updates (replace ALL `#` hrefs):**
| Link | Target |
|------|--------|
| All guides | `/all-articles/` |
| Getting started | `/topics/getting-started/` |
| API | `/topics/api/` |
| Agents | `/topics/agents/` |
| MCP | `/topics/mcp/` |
| Prompts | `/topics/prompt-engineering/` |
| CLAUDE.md generator | `/generator/` |
| Template library | `https://zovo.one/lifetime` |
| Orchestration kit | `https://zovo.one/lifetime` |
| RSS feed | `/feed.xml` |
| zovo.one | `https://zovo.one` |
| Discord | `https://discord.com/invite/QeHxTFbqmC` |
| GitHub | `https://github.com/theluckystrike` |
| Upwork profile | `https://www.upwork.com/freelancers/~01b0e2c31b7c8a0e5c` |
| Email | `mailto:michael@zovo.one` (verify) |

**QA:**
- 4 columns at desktop (2fr 1fr 1fr 1fr)
- 2 columns at 900px, 1 column at 640px
- Brand text "Claude Code / Guides." renders large serif
- All links resolve

---

## BATCH 5: JAVASCRIPT

### Chunk 5.1: Theme toggle

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md` (add `<script>` block at bottom)

**Port from lines 1571-1608 of new design:**

Functions to keep:
- `applyTheme(t)` -- sets `data-theme` attribute on `<html>`, swaps SVG icon
- Theme toggle click handler

Functions to strip:
- `applyHue(h)` -- hue customization is a tweaks-panel feature; hardcode hue at 38
- `applyDensity(d)` -- density toggle is a tweaks-panel feature; hardcode "comfortable"
- `persist(patch)` -- postMessage to parent window (design tool integration)
- `syncTweakUI()` -- tweaks panel sync

**Additional requirement:**
- Add `<script>` in `<head>` (via the homepage layout) to set `data-theme="dark"` immediately to prevent FOUC:
  ```html
  <script>document.documentElement.setAttribute('data-theme','dark')</script>
  ```
- Or add this to the `homepage.html` layout `<head>` section

**NASA Power of 10 compliance:**
- Each function < 60 lines: `applyTheme` is ~8 lines -- PASS
- Bounded loops: no loops -- PASS
- Zero warnings: use strict mode -- PASS

**QA:**
- Click theme toggle: page switches between dark/light
- SVG icon changes (moon <-> sun)
- Theme persists via `data-theme` attribute (no localStorage needed for MVP)

### Chunk 5.2: Guide tabs

**Port from lines 1611-1618:**

```javascript
const tabs = document.getElementById('tabs');
if (tabs) {
  tabs.addEventListener('click', (e) => {
    const b = e.target.closest('button');
    if (!b) return;
    tabs.querySelectorAll('button').forEach(x => x.classList.remove('on'));
    b.classList.add('on');
  });
}
```

**Scope:** Visual tab switching only (highlight active tab). Does NOT filter guide content -- that would require Jekyll/JS data binding which is out of scope for the port.

**QA:**
- Click any tab: it gets `.on` class (accent underline), others lose it
- No JS errors in console

### Chunk 5.3: Generator chips

**Port from lines 1621-1640:**

- Chip click handler: single-select for framework/language groups, multi-select for constraints
- `updateGen()`: updates the output preview text based on selected chips

**QA:**
- Click "FastAPI" chip: it becomes active, "Next.js 14" deactivates
- Click constraint chips: multiple can be active
- Output preview updates framework/language text

### Chunk 5.4: Regenerate animation

**Port from lines 1643-1646:**

```javascript
document.getElementById('regen').addEventListener('click', () => {
  const body = document.querySelector('.mdpane-body');
  body.animate([{opacity:1},{opacity:.3},{opacity:1}], {duration: 500});
});
```

**QA:**
- Click "regenerate for my stack" in mdpane footer: content flashes

### Chunk 5.5: Strip tweaks panel JS

**Lines to REMOVE entirely (1648-1700):**
- The `persist()` function
- The `syncTweakUI()` function
- The panel click handler
- The hue range input handler
- The `__edit_mode_*` postMessage handlers
- The `TWEAKS` config object (line 11-16 of the `<script>` tag in `<head>`)

**QA:**
- No reference to `tweaksPanel`, `swatches`, `hueRange`, `persist`, `__edit_mode` in final code
- No JS console errors

---

## BATCH 6: DATA REPLACEMENT

### Chunk 6.1: Replace all `#` hrefs with real CCG paths

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md`

**Systematic replacement:**
1. Nav links (done in Chunk 2.1)
2. Hero CTA buttons (done in Chunk 3.2)
3. Guide card hrefs (done in Chunk 4.3)
4. Footer links (done in Chunk 4.6)
5. Pricing CTAs (done in Chunk 4.5)

**Verification script:**
```bash
grep -c 'href="#"' index.md
# Must return 0 (no unresolved placeholder links)
# Exception: href="#pricing", href="#generator", href="#guides" (on-page anchors) are acceptable ONLY if they match section IDs
```

### Chunk 6.2: Update article counts

**Replacement:**
- Every instance of `2,665` -> `3,020` (actual count: 3,021, round down for display)
- Occurrences: hero-meta, hero CTA, stats section, guides section head, pricing free tier, footer

**Verification:**
```bash
grep -c '2,665' index.md
# Must return 0
grep -c '3,020' index.md
# Should return 5-7 (expected occurrences)
```

### Chunk 6.3: Update guide tab counts with real numbers

See table in Chunk 4.3. Replace placeholder counts with actual counts from the repo.

### Chunk 6.4: Verify and fix all featured article slugs

**Process:**
For each slug referenced in the guides section, verify the file exists:
```bash
ls articles/claude-api-timeout-error-handling-retry-guide.md
ls articles/claude-opus-orchestrator-sonnet-worker-architecture.md
# etc.
```

If a slug doesn't exist, search for the closest match:
```bash
ls articles/ | grep "timeout"
ls articles/ | grep "opus.*orchestrator"
```

### Chunk 6.5: Portrait image

- Copy and process: `/Users/mike/Documents/Screenshot 2026-04-20 at 3.31.33 PM.png` -> `/Users/mike/claude-skills-guide/assets/portrait.jpg`
- Resize to 216x216, JPEG quality 85
- Update bio HTML to use `<img>` or CSS `background-image`

---

## BATCH 7: CLEANUP & QA

### Chunk 7.1: Remove tweaks panel HTML

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md`

**Remove entirely:**
- The `<div class="tweaks" id="tweaksPanel">` block (lines 1536-1569 of source)
- All CSS for `.tweaks`, `.tweaks-head`, `.tweaks-body`, `.tweak-row`, `.tweak-opts`, `.swatch-row`
- The `TWEAKS` object from `<script>`
- All density-variant CSS (`html[data-density="compact"]`)

**QA:**
```bash
grep -c 'tweaks' index.md    # Must return 0
grep -c 'TWEAKS' index.md    # Must return 0
grep -c 'swatch' index.md    # Must return 0
grep -c 'density' index.md   # Must return 0
```

### Chunk 7.2: Remove `data-screen-label` attributes

**Files to modify:**
- `/Users/mike/claude-skills-guide/index.md`

**Remove all occurrences:**
```
data-screen-label="00 Nav"
data-screen-label="01 Hero"
data-screen-label="02 Stats"
data-screen-label="03 Guides"
data-screen-label="04 Generator"
data-screen-label="05 Pricing"
data-screen-label="06 Footer"
```

**QA:**
```bash
grep -c 'data-screen-label' index.md  # Must return 0
```

### Chunk 7.3: CSS conflict audit

**Files to check:**
- `/Users/mike/claude-skills-guide/assets/css/style.css`
- `/Users/mike/claude-skills-guide/index.md` (inline styles)

**Known conflicts to verify are resolved:**

| Class | In style.css | In new design | Resolution |
|-------|-------------|---------------|------------|
| `.hero` | Lines 382-403 | Lines 206-211 | Inline override wins (later in cascade) |
| `.stats` | Lines 504-529 | Lines 368-429 | Inline override wins |
| `.stat` | Lines 511-528 | Lines 389-420 | Inline override wins |
| `h2::after` | Lines 78-86 | Not used | Kill with `.h2::after { display: none }` or ensure `.h2` class never matches `h2::after` element selector |
| `body` max-width | Line 34 | Full bleed | Override with `body { max-width: none !important }` (already present) |
| `.site-header` | Lines 231-241 | Not present | Not rendered (homepage layout has no `.site-header`) |

**QA:**
- Load homepage: no visual glitches from inherited styles
- Load any article page: no visual changes from the port (the homepage layout is isolated)
- Run visual diff: compare article page before/after the commit

### Chunk 7.4: Link resolution check

**Verification script:**
```bash
# Extract all hrefs from index.md, check each internal path exists
grep -oP 'href="(/[^"#]*)"' index.md | sort -u | while read -r href; do
  path="${href#href=\"}"
  path="${path%\"}"
  # Check if path maps to a file
  if [[ "$path" == */ ]]; then
    # Directory-style URL, check for index
    test -f "articles/${path%/}.md" -o -d "${path%/}" || echo "BROKEN: $path"
  fi
done
```

### Chunk 7.5: Responsive QA

**Test at these viewports:**
| Width | Expected behavior |
|-------|------------------|
| 380px | Tiny phone: wrap 14px, display 36px, brand shows "Claude Code" only |
| 640px | Mobile: wrap 18px, all grids 1-col, 44px touch targets, hero stacked |
| 900px | Tablet: wrap 24px, hero/stats/pricing stacked, nav-links hidden |
| 1360px | Desktop: full layout, all grids multi-column, nav-links visible |

**Tools:**
- Chrome DevTools responsive mode
- Safari responsive design mode (for iOS testing)

### Chunk 7.6: Final build test

```bash
cd /Users/mike/claude-skills-guide
bundle exec jekyll build
# Must complete with 0 errors, 0 warnings (zero warnings policy)
# Check _site/index.html exists and is valid HTML
```

---

## Execution Order & Dependencies

```
Batch 0 (pre-flight)
  └── 0.1: Create homepage layout ← MUST DO FIRST

Batch 1 (CSS) — depends on 0.1
  ├── 1.1: Design tokens
  ├── 1.2: Layout helpers + type scale ← depends on 1.1
  └── 1.3: Responsive breakpoints ← depends on 1.2

Batch 2 (Nav) — depends on 0.1
  └── 2.1: Port nav HTML + CSS

Batch 3 (Hero) — depends on 1.x complete
  ├── 3.1: Hero meta bar
  ├── 3.2: Hero grid ← depends on 3.1
  └── 3.3: Hero stack card ← depends on 3.2

Batch 4 (Content) — depends on 1.x complete
  ├── 4.1: Stats section
  ├── 4.2: Bio strip (needs portrait image)
  ├── 4.3: Guides section ← LARGEST chunk, needs slug verification
  ├── 4.4: Generator section
  ├── 4.5: Pricing section
  └── 4.6: Footer

Batch 5 (JS) — depends on Batches 2-4 (needs DOM elements to exist)
  ├── 5.1: Theme toggle
  ├── 5.2: Guide tabs
  ├── 5.3: Generator chips
  ├── 5.4: Regenerate animation
  └── 5.5: Strip tweaks JS

Batch 6 (Data) — can run in parallel with Batch 5
  ├── 6.1: Replace # hrefs
  ├── 6.2: Update article counts
  ├── 6.3: Update tab counts
  ├── 6.4: Verify article slugs
  └── 6.5: Portrait image

Batch 7 (Cleanup) — MUST be last
  ├── 7.1: Remove tweaks panel
  ├── 7.2: Remove data-screen-label
  ├── 7.3: CSS conflict audit
  ├── 7.4: Link resolution check
  ├── 7.5: Responsive QA
  └── 7.6: Final build test
```

---

## Risk Register

| Risk | Impact | Mitigation |
|------|--------|------------|
| oklch colors not supported in older browsers | Broken colors for ~2% of users | oklch support is 95%+; our audience (developers) uses modern browsers. No fallback needed. |
| `.hero`/`.stats` class collision breaks article pages | Visual regression on 3,021 pages | Isolated via `homepage.html` layout -- article pages never load the new CSS |
| Instrument Serif font not loaded | Hero headline falls back to Times New Roman | Add to Google Fonts `<link>` in `homepage.html` layout |
| Jekyll Liquid parsing of `{{ }}` in inline JS | Build errors | Wrap JS in `{% raw %}...{% endraw %}` |
| Portrait image too large | Slow page load | Compress to JPEG 85%, max 50KB |
| GitHub Pages build failure | Site goes down | Test locally with `bundle exec jekyll build` before pushing |

---

## Estimated LOC Changes

| File | Current lines | Estimated final lines | Delta |
|------|--------------|----------------------|-------|
| `index.md` | 785 | ~1,450 | +665 |
| `_layouts/homepage.html` | 0 (new) | ~120 | +120 |
| `_layouts/default.html` | 504 | 504 (unchanged) | 0 |
| `assets/css/style.css` | 1,374 | 1,374 (unchanged) | 0 |
| `assets/portrait.jpg` | 0 (new) | binary ~40KB | +1 file |

**Total net change:** ~785 new/modified lines + 1 new layout + 1 new image asset.
**Zero changes to any existing article, topic page, or global CSS.**
