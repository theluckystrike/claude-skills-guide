---
layout: default
title: "Claude Code Guides — Ship Faster with Claude Code"
description: "2,665 production-tested Claude Code guides. CLAUDE.md templates, debugging workflows, and MCP integrations from a developer earning $400K+/year on Upwork."
---

<style>
/* ---------- Design tokens ---------- */
:root {
  --bg: #0a0a0a;
  --ink: #f2f0ea;
  --ink-muted: #7a756c;
  --accent: #ff6a3d;
  --rule: rgba(242, 240, 234, 0.08);
  --font-serif: 'Fraunces', Georgia, serif;
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
}

/* ---------- Reset page-body and body defaults ---------- */
body {
  max-width: none !important;
  padding: 0 !important;
  margin: 0 !important;
}
.page-body {
  max-width: none !important;
  padding: 0 !important;
  margin: 0 !important;
}

/* ---------- Override style.css .hero collision ---------- */
.hero {
  text-align: left !important;
  background: none !important;
  margin: 0 !important;
  border: none !important;
  padding: 0 !important;
}
.hero h1 {
  text-align: left;
  margin: 0;
}
.hero p {
  color: inherit;
}

/* ---------- Kill h2::after accent underline on homepage ---------- */
.tool-s10__headline::after,
.work-s10__headline::after,
.offer-s10__headline::after,
.tool-s10__eyebrow::after,
.work-s10__eyebrow::after,
.offer-s10__eyebrow::after,
.site-footer-s10 h2::after {
  display: none !important;
}
.s10-section h2::after {
  display: none !important;
}
.s10-section h2 {
  border-bottom: none !important;
  position: static;
  padding-bottom: 0;
}

/* ---------- Section container ---------- */
.s10-section {
  width: 100%;
  padding-left: 1.5rem;
  padding-right: 1.5rem;
  box-sizing: border-box;
}

/* ---------- SECTION 1: HERO ---------- */
.hero-s10 {
  min-height: 85vh;
  display: flex;
  align-items: center;
  justify-content: flex-start;
  max-width: 720px;
  margin: 0 auto;
  padding-top: 2rem;
  padding-bottom: 2rem;
}
.hero-s10__inner {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}
.hero-s10__headline {
  font-family: var(--font-serif);
  font-size: clamp(2.75rem, 6vw, 4.75rem);
  font-weight: 400;
  line-height: 1.1;
  color: var(--ink);
  margin: 0;
}
.hero-s10__headline-italic {
  display: block;
  font-style: italic;
}
.hero-s10__lede {
  font-family: var(--font-sans);
  font-size: clamp(1.125rem, 1.5vw, 1.25rem);
  line-height: 1.6;
  color: var(--ink);
  max-width: 44ch;
  margin: 0;
}
.hero-s10__proof {
  font-family: var(--font-sans);
  font-size: 1rem;
  line-height: 1.6;
  color: var(--ink-muted);
  max-width: 44ch;
  margin: 0;
}
.hero-s10__cta {
  display: inline-block;
  background: var(--accent);
  color: var(--bg);
  padding: 1rem 1.75rem;
  border-radius: 2px;
  font-family: var(--font-sans);
  font-weight: 600;
  font-size: 1.0625rem;
  text-decoration: none;
  transition: opacity 0.2s ease, transform 0.15s ease;
  align-self: flex-start;
}
.hero-s10__cta:hover {
  opacity: 0.92;
  transform: translateY(-1px);
  text-decoration: none;
  color: var(--bg);
}
.hero-s10__sig {
  font-family: var(--font-sans);
  font-size: 0.875rem;
  color: var(--ink-muted);
  margin: 0;
}

/* ---------- SECTION 2: PROOF ---------- */
.proof-s10 {
  border-top: 1px solid var(--rule);
  border-bottom: 1px solid var(--rule);
  padding-top: 6rem;
  padding-bottom: 6rem;
}
.proof-s10__grid {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 3rem;
  max-width: 1100px;
  margin: 0 auto;
}
.proof-s10__item {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}
.proof-s10__number {
  font-family: var(--font-serif);
  font-size: clamp(3rem, 5vw, 4.5rem);
  font-weight: 400;
  color: var(--accent);
  line-height: 1;
}
.proof-s10__text {
  font-family: var(--font-sans);
  font-size: 0.9375rem;
  line-height: 1.6;
  color: var(--ink-muted);
  margin: 0;
}
.proof-s10__text strong {
  color: var(--ink);
  font-weight: 500;
}

/* ---------- SECTION 3: TOOL ---------- */
.tool-s10 {
  padding-top: 6rem;
  padding-bottom: 6rem;
}
.tool-s10__grid {
  display: grid;
  grid-template-columns: 1fr 1.4fr;
  gap: 4rem;
  align-items: center;
  max-width: 1100px;
  margin: 0 auto;
}
.tool-s10__eyebrow {
  font-family: var(--font-sans);
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--accent);
  margin: 0 0 0.75rem 0;
}
.tool-s10__headline {
  font-family: var(--font-serif);
  font-size: clamp(2.25rem, 4vw, 3.25rem);
  font-weight: 400;
  line-height: 1.15;
  color: var(--ink);
  margin: 0 0 1.25rem 0;
}
.tool-s10__body {
  font-family: var(--font-sans);
  font-size: 1rem;
  line-height: 1.6;
  color: var(--ink-muted);
  margin: 0 0 1rem 0;
}
.tool-s10__frameworks {
  font-family: var(--font-sans);
  font-size: 0.9375rem;
  line-height: 1.6;
  color: var(--ink-muted);
  margin: 0 0 2rem 0;
}
.tool-s10__cta {
  display: inline-block;
  background: transparent;
  color: var(--ink);
  border: 1px solid var(--ink);
  padding: 0.875rem 1.5rem;
  border-radius: 2px;
  font-family: var(--font-sans);
  font-weight: 600;
  font-size: 1rem;
  text-decoration: none;
  transition: all 0.2s ease;
}
.tool-s10__cta:hover {
  background: var(--ink);
  color: var(--bg);
  text-decoration: none;
}
.tool-s10__demo {
  border: 1px solid var(--rule);
  border-radius: 4px;
  overflow: hidden;
  min-height: 360px;
  background: #111;
}
.tool-s10__demo-bar {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1rem;
  background: rgba(242, 240, 234, 0.04);
  border-bottom: 1px solid var(--rule);
}
.tool-s10__demo-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #333;
}
.tool-s10__demo-dot:first-child { background: #ff5f57; }
.tool-s10__demo-dot:nth-child(2) { background: #febc2e; }
.tool-s10__demo-dot:nth-child(3) { background: #28c840; }
.tool-s10__demo-file {
  margin-left: auto;
  font-family: var(--font-mono);
  font-size: 0.75rem;
  color: var(--ink-muted);
}
.tool-s10__demo-code {
  padding: 1.25rem;
  font-family: var(--font-mono);
  font-size: 0.8rem;
  line-height: 1.7;
  color: var(--ink-muted);
  white-space: pre;
  overflow-x: auto;
}
.tool-s10__demo-code .cm { color: #555; }
.tool-s10__demo-code .kw { color: #ff6a3d; }
.tool-s10__demo-code .str { color: #4ade80; }
.tool-s10__demo-code .val { color: #60a5fa; }

/* ---------- SECTION 4: WORK ---------- */
.work-s10 {
  padding-top: 6rem;
  padding-bottom: 6rem;
  border-top: 1px solid var(--rule);
}
.work-s10__inner {
  max-width: 900px;
  margin: 0 auto;
}
.work-s10__eyebrow {
  font-family: var(--font-sans);
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--accent);
  margin: 0 0 0.75rem 0;
}
.work-s10__headline {
  font-family: var(--font-serif);
  font-size: clamp(2.25rem, 4vw, 3.25rem);
  font-weight: 400;
  line-height: 1.15;
  color: var(--ink);
  margin: 0 0 3rem 0;
}
.work-s10__item {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 2rem;
  align-items: start;
  border-top: 1px solid var(--rule);
  padding: 2rem 0;
  text-decoration: none;
  transition: transform 0.2s ease;
}
.work-s10__item:hover {
  transform: translateX(4px);
  text-decoration: none;
}
.work-s10__item:hover .work-s10__title {
  color: var(--accent);
}
.work-s10__title {
  font-family: var(--font-serif);
  font-size: 1.5rem;
  font-weight: 400;
  color: var(--ink);
  margin: 0 0 0.5rem 0;
  transition: color 0.2s ease;
}
.work-s10__desc {
  font-family: var(--font-sans);
  font-size: 0.9375rem;
  line-height: 1.6;
  color: var(--ink-muted);
  margin: 0;
}
.work-s10__arrow {
  font-family: var(--font-sans);
  font-size: 1.5rem;
  color: var(--ink-muted);
  padding-top: 0.25rem;
}
.work-s10__browse {
  display: inline-block;
  margin-top: 2rem;
  font-family: var(--font-sans);
  font-size: 1rem;
  font-weight: 600;
  color: var(--accent);
  text-decoration: none;
  transition: opacity 0.2s ease;
}
.work-s10__browse:hover {
  opacity: 0.8;
  text-decoration: none;
  color: var(--accent);
}

/* ---------- SECTION 5: OFFER ---------- */
.offer-s10 {
  padding-top: 6rem;
  padding-bottom: 6rem;
  border-top: 1px solid var(--rule);
}
.offer-s10__inner {
  max-width: 1100px;
  margin: 0 auto;
}
.offer-s10__eyebrow {
  font-family: var(--font-sans);
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--accent);
  margin: 0 0 0.75rem 0;
}
.offer-s10__headline {
  font-family: var(--font-serif);
  font-size: clamp(2.25rem, 4vw, 3.25rem);
  font-weight: 400;
  line-height: 1.15;
  color: var(--ink);
  margin: 0 0 3rem 0;
}
.offer-s10__grid {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 1px;
  background: var(--rule);
}
.offer-s10__card {
  background: var(--bg);
  padding: 2rem;
  display: flex;
  flex-direction: column;
}
.offer-s10__card--featured {
  border-top: 2px solid var(--accent);
  background: linear-gradient(180deg, rgba(255, 106, 61, 0.04) 0%, var(--bg) 40%);
}
.offer-s10__tier-header {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 1rem;
}
.offer-s10__tier-name {
  font-family: var(--font-sans);
  font-size: 1rem;
  font-weight: 600;
  color: var(--ink);
}
.offer-s10__tier-price {
  font-family: var(--font-sans);
  font-size: 0.9375rem;
  color: var(--ink-muted);
}
.offer-s10__pitch {
  font-family: var(--font-serif);
  font-size: 1.25rem;
  font-weight: 400;
  line-height: 1.4;
  color: var(--ink);
  margin: 0 0 1.5rem 0;
}
.offer-s10__features {
  list-style: none;
  padding: 0;
  margin: 0 0 2rem 0;
  flex-grow: 1;
}
.offer-s10__features li {
  font-family: var(--font-sans);
  font-size: 0.9375rem;
  color: var(--ink-muted);
  padding: 0.625rem 0;
  border-bottom: 1px solid var(--rule);
}
.offer-s10__features li:first-child {
  border-top: 1px solid var(--rule);
}
.offer-s10__cta--filled {
  display: inline-block;
  background: var(--accent);
  color: var(--bg);
  padding: 0.875rem 1.5rem;
  border-radius: 2px;
  font-family: var(--font-sans);
  font-weight: 600;
  font-size: 1rem;
  text-decoration: none;
  text-align: center;
  transition: opacity 0.2s ease;
}
.offer-s10__cta--filled:hover {
  opacity: 0.88;
  text-decoration: none;
  color: var(--bg);
}
.offer-s10__cta--outline {
  display: inline-block;
  background: transparent;
  color: var(--ink);
  border: 1px solid var(--ink);
  padding: 0.875rem 1.5rem;
  border-radius: 2px;
  font-family: var(--font-sans);
  font-weight: 600;
  font-size: 1rem;
  text-decoration: none;
  text-align: center;
  transition: all 0.2s ease;
}
.offer-s10__cta--outline:hover {
  background: var(--ink);
  color: var(--bg);
  text-decoration: none;
}
.offer-s10__cta--text {
  display: inline-block;
  font-family: var(--font-sans);
  font-weight: 600;
  font-size: 1rem;
  color: var(--ink-muted);
  text-decoration: none;
  transition: color 0.2s ease;
}
.offer-s10__cta--text:hover {
  color: var(--accent);
  text-decoration: none;
}
.offer-s10__card--featured {
  position: relative;
}
.offer-s10__badge {
  position: absolute;
  top: -10px;
  right: 20px;
  background: var(--accent);
  color: var(--bg);
  font-family: var(--font-sans);
  font-size: 0.7rem;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  padding: 0.3rem 0.75rem;
  border-radius: 2px;
}
.offer-s10__math-inline {
  font-family: var(--font-serif);
  font-style: italic;
  font-size: 0.875rem;
  color: var(--ink-muted);
  line-height: 1.5;
  margin: 0 0 1.5rem 0;
  padding: 1rem 0;
  border-top: 1px solid var(--rule);
}
.offer-s10__cta--filled-large {
  display: inline-block;
  background: var(--accent);
  color: var(--bg);
  padding: 1rem 1.75rem;
  border-radius: 2px;
  font-family: var(--font-sans);
  font-weight: 600;
  font-size: 1.0625rem;
  text-decoration: none;
  text-align: center;
  transition: opacity 0.2s ease, transform 0.15s ease;
}
.offer-s10__cta--filled-large:hover {
  opacity: 0.92;
  transform: translateY(-1px);
  text-decoration: none;
  color: var(--bg);
}

/* ---------- FOOTER ---------- */
.site-footer-s10 {
  padding: 4rem 1.5rem;
  text-align: center;
  font-family: var(--font-sans);
  font-size: 0.875rem;
  color: var(--ink-muted);
  line-height: 1.6;
}
.footer__site {
  color: var(--ink);
  font-weight: 500;
  margin: 0 0 0.75rem 0;
}
.footer__bio {
  margin: 0 0 0.75rem 0;
}
.footer__links {
  margin: 0 0 0.75rem 0;
}
.footer__links a {
  color: var(--ink-muted);
  text-decoration: none;
  transition: color 0.2s ease;
}
.footer__links a:hover {
  color: var(--accent);
}
.footer__copy {
  margin: 0;
}

/* ---------- RESPONSIVE ---------- */
@media (max-width: 900px) {
  .tool-s10__grid {
    grid-template-columns: 1fr;
    gap: 2rem;
  }
  .tool-s10__image {
    min-height: 240px;
  }
}

@media (max-width: 768px) {
  .proof-s10__grid {
    grid-template-columns: 1fr;
    gap: 2.5rem;
  }
  .offer-s10__grid {
    grid-template-columns: 1fr;
  }
  .work-s10__item {
    grid-template-columns: 1fr auto;
    gap: 1rem;
  }
}

@media (max-width: 375px) {
  .hero-s10 {
    min-height: auto;
    padding-top: 3rem;
    padding-bottom: 3rem;
  }
  .proof-s10__grid {
    grid-template-columns: 1fr;
  }
  .offer-s10__grid {
    grid-template-columns: 1fr;
  }
}
</style>

<!-- ============ SECTION 1: HERO ============ -->
<div class="s10-section">
  <div class="hero-s10">
    <div class="hero-s10__inner">
      <h1 class="hero-s10__headline">
        Claude Code<span class="hero-s10__headline-italic">was meant to work like this.</span>
      </h1>
      <p class="hero-s10__lede">One file in your repo. 300 lines.<br>Stops guessing your stack. Starts engineering.</p>
      <a href="/generator/" class="hero-s10__cta">Generate your CLAUDE.md &rarr;</a>
      <p class="hero-s10__proof">I've shipped 2,665 guides on configuring it right.<br>I earn $400K+/year doing this for Upwork clients.<br>The configs are here.</p>
      <p class="hero-s10__sig">Michael Lip &mdash; solo dev, Da Nang</p>
    </div>
  </div>
</div>

<!-- ============ SECTION 2: PROOF ============ -->
<div class="s10-section proof-s10">
  <div class="proof-s10__grid">
    <div class="proof-s10__item">
      <span class="proof-s10__number">$400K+</span>
      <p class="proof-s10__text"><strong>earned on Upwork</strong> writing production code with Claude Code. 100% Job Success Score.</p>
    </div>
    <div class="proof-s10__item">
      <span class="proof-s10__number">2,665</span>
      <p class="proof-s10__text"><strong>guides shipped.</strong> Every one of them tested on a real problem I hit.</p>
    </div>
    <div class="proof-s10__item">
      <span class="proof-s10__number">50K+</span>
      <p class="proof-s10__text"><strong>developers</strong> using the Chrome extensions I've shipped at zovo.one.</p>
    </div>
  </div>
</div>

<!-- ============ SECTION 3: TOOL ============ -->
<div class="s10-section tool-s10">
  <div class="tool-s10__grid">
    <div class="tool-s10__content">
      <p class="tool-s10__eyebrow">The tool</p>
      <h2 class="tool-s10__headline">Try it.</h2>
      <p class="tool-s10__body">Tell it your stack. Get a production CLAUDE.md in 60 seconds.</p>
      <p class="tool-s10__frameworks">Next.js, FastAPI, Rails, Go, Rust, Terraform &mdash; 27 frameworks.<br>Drop it in your project. Claude Code stops guessing.</p>
      <a href="/generator/" class="tool-s10__cta">Open the generator &rarr;</a>
    </div>
    <div class="tool-s10__demo">
      <div class="tool-s10__demo-bar">
        <span class="tool-s10__demo-dot"></span>
        <span class="tool-s10__demo-dot"></span>
        <span class="tool-s10__demo-dot"></span>
        <span class="tool-s10__demo-file">CLAUDE.md</span>
      </div>
      <div class="tool-s10__demo-code"><span class="cm"># Generated by claudecodeguides.com</span>

<span class="kw">project:</span> <span class="str">acme-saas</span>
<span class="kw">framework:</span> <span class="str">next.js 14 (app router)</span>
<span class="kw">language:</span> <span class="str">typescript 5.4 strict</span>

<span class="cm"># Architecture rules</span>
<span class="kw">patterns:</span>
  <span class="val">- server components by default</span>
  <span class="val">- "use client" only for interactivity</span>
  <span class="val">- colocate tests next to source</span>

<span class="cm"># Boundaries Claude must respect</span>
<span class="kw">never:</span>
  <span class="val">- modify prisma/schema.prisma</span>
  <span class="val">- change auth middleware</span>
  <span class="val">- add dependencies without asking</span>

<span class="cm"># Style</span>
<span class="kw">formatting:</span> <span class="str">biome</span>
<span class="kw">max_line_length:</span> <span class="str">100</span>
<span class="kw">imports:</span> <span class="str">absolute (@/)</span></div>
    </div>
  </div>
</div>

<!-- ============ SECTION 4: WORK ============ -->
<div class="s10-section work-s10">
  <div class="work-s10__inner">
    <p class="work-s10__eyebrow">The work</p>
    <h2 class="work-s10__headline">What developers are actually reading.</h2>
    <a href="/claude-api-timeout-error-handling-retry-guide/" class="work-s10__item">
      <div>
        <h3 class="work-s10__title">Fix Claude API Stream Idle Timeout</h3>
        <p class="work-s10__desc">2,198 developers read this last month. Because stream timeouts are real, the fix is specific, and nobody else wrote it down.</p>
      </div>
      <span class="work-s10__arrow">&rarr;</span>
    </a>
    <a href="/claude-code-for-fpga-development-workflow-tutorial/" class="work-s10__item">
      <div>
        <h3 class="work-s10__title">Claude Code + FPGA Development</h3>
        <p class="work-s10__desc">121 impressions, 16 clicks, 13.2% CTR. Most articles about FPGAs and AI don't exist. This one does.</p>
      </div>
      <span class="work-s10__arrow">&rarr;</span>
    </a>
    <a href="/claude-opus-orchestrator-sonnet-worker-architecture/" class="work-s10__item">
      <div>
        <h3 class="work-s10__title">Opus Orchestrator + Sonnet Worker Architecture</h3>
        <p class="work-s10__desc">3-layer delegation pattern. Opus plans, Sonnet executes, tokens drop 60%. The multi-agent architecture most teams discover too late.</p>
      </div>
      <span class="work-s10__arrow">&rarr;</span>
    </a>
    <a href="/all-articles/" class="work-s10__browse">Browse all 2,665 guides &rarr;</a>
  </div>
</div>

<!-- ============ SECTION 5: OFFER ============ -->
<div class="s10-section offer-s10">
  <div class="offer-s10__inner">
    <p class="offer-s10__eyebrow">The offer</p>
    <h2 class="offer-s10__headline">Three ways to use this site.</h2>
    <div class="offer-s10__grid">
      <!-- FREE -->
      <div class="offer-s10__card">
        <div class="offer-s10__tier-header">
          <span class="offer-s10__tier-name">FREE</span>
        </div>
        <p class="offer-s10__pitch">Everything on this site, forever.</p>
        <ul class="offer-s10__features">
          <li>2,665 guides</li>
          <li>Generator tool</li>
          <li>Weekly updates</li>
        </ul>
        <a href="/all-articles/" class="offer-s10__cta--text">Keep browsing &rarr;</a>
      </div>
      <!-- COMMUNITY -->
      <div class="offer-s10__card">
        <div class="offer-s10__tier-header">
          <span class="offer-s10__tier-name">COMMUNITY</span>
          <span class="offer-s10__tier-price">$4.99/mo</span>
        </div>
        <p class="offer-s10__pitch">16 CLAUDE.md templates + private Discord + monthly calls.</p>
        <ul class="offer-s10__features">
          <li>Private Discord</li>
          <li>Monthly builder calls</li>
          <li>Template library</li>
        </ul>
        <a href="https://zovo.one/community" class="offer-s10__cta--outline">Join community &rarr;</a>
      </div>
      <!-- LIFETIME -->
      <div class="offer-s10__card offer-s10__card--featured">
        <span class="offer-s10__badge">Most Popular</span>
        <div class="offer-s10__tier-header">
          <span class="offer-s10__tier-name">LIFETIME</span>
          <span class="offer-s10__tier-price">$99 once</span>
        </div>
        <p class="offer-s10__pitch">Everything above + 80 prompts + orchestration configs + every future build.</p>
        <ul class="offer-s10__features">
          <li>16 templates</li>
          <li>80 tested prompts</li>
          <li>Orchestration configs</li>
          <li>Every future build</li>
        </ul>
        <p class="offer-s10__math-inline">After 20 months, Community costs the same as Lifetime.<br>Lifetime members pay nothing from month 21 onward.</p>
        <a href="https://zovo.one/lifetime" class="offer-s10__cta--filled-large">Get lifetime &rarr;</a>
      </div>
    </div>
  </div>
</div>

<!-- ============ FOOTER ============ -->
<footer class="site-footer-s10">
  <p class="footer__site">claudecodeguides.com</p>
  <p class="footer__bio">Built by Michael Lip in Da Nang, Vietnam.<br>Updated daily by an agent fleet running on five Claude Max subscriptions.</p>
  <p class="footer__links"><a href="https://zovo.one">zovo.one</a> &middot; <a href="https://github.com/theluckystrike">GitHub</a></p>
  <p class="footer__copy">&copy; 2026</p>
</footer>
