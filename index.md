---
layout: homepage
title: "Claude Code Guides — Ship Faster with Claude Code"
description: "3,021 production-tested Claude Code guides. CLAUDE.md templates, debugging workflows, and MCP integrations from a developer earning $400K+/year on Upwork."
---

<style>
/* ========== DESIGN TOKENS ========== */
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
}

/* Dark (default) */
html[data-theme="dark"] {
  --bg: oklch(0.155 0.007 60);
  --bg-2: oklch(0.185 0.008 60);
  --bg-3: oklch(0.225 0.009 60);
  --line: oklch(0.30 0.010 60);
  --line-soft: oklch(0.235 0.009 60);
  --ink: oklch(0.97 0.006 80);
  --ink-2: oklch(0.80 0.008 70);
  --ink-3: oklch(0.58 0.010 70);
  --ink-4: oklch(0.42 0.010 70);
  --green: oklch(0.78 0.14 150);
  --red: oklch(0.72 0.16 25);
  --shadow-1: 0 1px 0 rgba(255,255,255,0.05) inset;
  --shadow-2: 0 30px 60px -30px rgba(0,0,0,.6), 0 1px 0 rgba(255,255,255,0.04) inset;
}

/* Light */
html[data-theme="light"] {
  --accent: oklch(0.56 0.12 var(--accent-h));
  --accent-dim: oklch(0.46 0.10 var(--accent-h));
  --bg: oklch(0.98 0.005 80);
  --bg-2: oklch(0.96 0.007 80);
  --bg-3: oklch(0.935 0.009 80);
  --line: oklch(0.82 0.010 70);
  --line-soft: oklch(0.90 0.008 70);
  --ink: oklch(0.18 0.010 60);
  --ink-2: oklch(0.34 0.010 60);
  --ink-3: oklch(0.42 0.010 60);
  --ink-4: oklch(0.48 0.010 60);
  --green: oklch(0.48 0.13 150);
  --red: oklch(0.52 0.18 25);
  --shadow-1: 0 1px 0 rgba(0,0,0,0.03) inset;
  --shadow-2: 0 30px 60px -30px rgba(60,40,20,.18), 0 1px 0 rgba(0,0,0,0.03) inset;
}

/* ========== RESETS ========== */
* { box-sizing: border-box; }
html, body { margin: 0; padding: 0; background: var(--bg); color: var(--ink); }
body {
  max-width: none !important;
  padding: 0 !important;
  margin: 0 !important;
  font-family: var(--sans);
  font-size: 15px;
  line-height: 1.55;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-rendering: optimizeLegibility;
  font-feature-settings: "ss01", "cv11", "kern";
  font-optical-sizing: auto;
}
.page-body {
  max-width: none !important;
  padding: 0 !important;
  margin: 0 !important;
}
::selection { background: var(--accent); color: var(--accent-ink); }

/* Kill style.css collisions */
body::before { display: none !important; }
.hero { text-align: left !important; background: none !important; margin: 0 !important; border: none !important; padding: 0 !important; }
.hero h1 { text-align: left; margin: 0; }
.hero p { color: inherit; }
h2::after { display: none !important; }
.stats { display: block !important; }
.stat { display: block !important; }

/* ========== LAYOUT HELPERS ========== */
.wrap { max-width: 1360px; margin: 0 auto; padding: 0 40px; }
.wrap-tight { max-width: 1120px; margin: 0 auto; padding: 0 40px; }
.hair { border: 0; border-top: 1px solid var(--line); margin: 0; }

/* ========== TYPOGRAPHY ========== */
.display {
  font-family: var(--serif);
  font-weight: 400;
  font-size: clamp(52px, 8vw, 128px);
  line-height: 0.94;
  letter-spacing: -0.028em;
  text-wrap: balance;
}
.display i {
  color: var(--accent);
  font-family: var(--serif-alt);
  font-style: italic;
  font-weight: 300;
  letter-spacing: -0.01em;
}
.h2 {
  font-family: var(--serif);
  font-weight: 400;
  font-size: clamp(44px, 5vw, 80px);
  line-height: 0.98;
  letter-spacing: -0.022em;
}
.h2 i {
  font-family: var(--serif-alt);
  font-style: italic;
  font-weight: 300;
  color: var(--accent);
}
.h3 {
  font-family: var(--serif);
  font-size: 34px;
  line-height: 1.08;
  letter-spacing: -0.015em;
  font-weight: 400;
}
.eyebrow {
  font-family: var(--mono);
  font-size: 11px;
  letter-spacing: var(--track);
  text-transform: uppercase;
  color: var(--ink-3);
  font-weight: 500;
}
.mono { font-family: var(--mono); }
.num { font-family: var(--serif); font-feature-settings: "lnum" 1, "tnum" 1; }

/* Focus visible (WCAG) */
:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
}

/* ========== NAV ========== */
.nav {
  position: sticky; top: 0; z-index: 40;
  background: rgba(30, 28, 24, 0.82);
  backdrop-filter: saturate(160%) blur(14px);
  -webkit-backdrop-filter: saturate(160%) blur(14px);
  border-bottom: 1px solid var(--line);
}
html[data-theme="light"] .nav {
  background: rgba(248, 246, 240, 0.82);
}
.nav-inner {
  display: grid; grid-template-columns: auto 1fr auto;
  align-items: center; gap: 40px;
  padding: 16px 40px;
  max-width: 1360px; margin: 0 auto;
}
.brand { display: flex; align-items: center; gap: 12px; text-decoration: none; color: var(--ink); }
.brand-mark {
  width: 28px; height: 28px; border-radius: 5px;
  background: linear-gradient(140deg, var(--accent) 0%, var(--accent-dim) 100%);
  display: grid; place-items: center;
  color: var(--accent-ink);
  font-family: var(--mono); font-weight: 700; font-size: 13px;
  box-shadow: 0 1px 2px rgba(0,0,0,.2);
}
.brand-word {
  font-family: var(--serif); font-size: 22px; letter-spacing: -0.012em;
  line-height: 1; white-space: nowrap;
}
.brand-word span {
  color: var(--ink-3);
  font-family: var(--serif-alt); font-style: italic; font-weight: 300;
}
.nav-links { display: flex; gap: 2px; justify-content: center; }
.nav-links a {
  font-size: 13px; color: var(--ink-2); text-decoration: none;
  padding: 8px 14px; border-radius: 6px;
  letter-spacing: -0.005em;
}
.nav-links a:hover { background: var(--bg-2); color: var(--ink); }
.nav-right { display: flex; align-items: center; gap: 10px; }
.theme-toggle {
  width: 36px; height: 36px; border-radius: 6px;
  border: 1px solid var(--line); background: transparent; color: var(--ink-2);
  cursor: pointer; display: grid; place-items: center;
  transition: all .15s ease;
}
.theme-toggle:hover { background: var(--bg-2); color: var(--ink); border-color: var(--ink-3); }

.btn {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 10px 16px; border-radius: 6px;
  font-size: 13px; font-weight: 500;
  text-decoration: none; cursor: pointer;
  border: 1px solid transparent;
  font-family: var(--sans);
  letter-spacing: -0.005em;
  transition: transform .14s ease, background .14s ease, border-color .14s ease;
}
.btn-primary {
  background: var(--accent); color: var(--accent-ink);
  box-shadow: var(--shadow-1);
}
.btn-primary:hover { transform: translateY(-1px); }
.btn-ghost { background: transparent; color: var(--ink); border-color: var(--line); }
.btn-ghost:hover { background: var(--bg-2); border-color: var(--ink-3); }

/* ========== HERO ========== */
.hero {
  padding: clamp(48px, 6vw, 80px) 0 72px !important;
  position: relative;
  overflow: hidden;
}
.hero-meta {
  display: grid;
  grid-template-columns: 1.3fr 0.9fr 0.9fr 1fr;
  gap: 0;
  border-top: 1px solid var(--line);
  border-bottom: 1px solid var(--line);
  margin-bottom: clamp(48px, 6vw, 72px);
  font-family: var(--mono);
  font-size: 10.5px;
  color: var(--ink-3);
  letter-spacing: 0.04em;
  text-transform: uppercase;
}
.hero-meta > div {
  padding: 12px 14px;
  border-right: 1px solid var(--line);
  display: flex; justify-content: space-between; gap: 10px;
  min-width: 0;
}
.hero-meta > div > span, .hero-meta > div > b {
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.hero-meta > div:last-child { border-right: 0; }
.hero-meta b { color: var(--ink); font-weight: 500; }

.hero-grid {
  display: grid; grid-template-columns: 1.05fr 0.95fr; gap: clamp(40px, 5vw, 88px);
  align-items: start;
}
.hero-copy .kicker {
  display: inline-flex; align-items: center; gap: 10px;
  font-family: var(--mono); font-size: 11px; letter-spacing: var(--track);
  text-transform: uppercase; color: var(--ink-3);
  padding: 7px 12px; border: 1px solid var(--line); border-radius: 999px;
  margin-bottom: 40px;
}
.kicker .dot {
  width: 6px; height: 6px; border-radius: 50%;
  background: var(--green);
  box-shadow: 0 0 0 3px rgba(74, 222, 128, 0.25);
  animation: blink 2.4s infinite;
}
@keyframes blink { 0%, 60%, 100% { opacity: 1 } 70%, 90% { opacity: .3 } }

.hero-sub {
  font-family: var(--serif-alt);
  font-weight: 300;
  font-size: 24px; color: var(--ink-2); line-height: 1.35;
  margin: 36px 0 44px; max-width: 34ch;
  letter-spacing: -0.01em;
}
.hero-sub b { color: var(--ink); font-weight: 400; }
.hero-sub i { font-style: italic; color: var(--accent); }

.hero-cta { display: flex; gap: 12px; align-items: center; flex-wrap: wrap; }
.hero-cta .btn-primary { padding: 15px 24px; font-size: 14px; }
.hero-cta .btn-ghost { padding: 15px 20px; font-size: 14px; }
.hero-note {
  font-family: var(--mono); font-size: 11px; color: var(--ink-3);
  margin-top: 32px; letter-spacing: 0.02em;
}
.hero-note span { color: var(--ink); }

/* CLAUDE.md pane */
.mdpane {
  background: var(--bg-2);
  border: 1px solid var(--line);
  border-radius: 12px;
  overflow: hidden;
  box-shadow: var(--shadow-2);
  position: relative;
}
.mdpane-head {
  display: flex; align-items: center; gap: 12px;
  padding: 12px 16px;
  border-bottom: 1px solid var(--line);
  background: var(--bg-3);
}
.mdpane-dots { display: flex; gap: 6px; }
.mdpane-dots span {
  width: 10px; height: 10px; border-radius: 50%;
  background: var(--line);
}
.mdpane-name {
  font-family: var(--mono); font-size: 12px; color: var(--ink-3);
  margin-left: 8px; letter-spacing: -0.01em;
}
.mdpane-name b { color: var(--ink); font-weight: 500; }
.mdpane-tag {
  margin-left: auto;
  font-family: var(--mono); font-size: 10px; letter-spacing: var(--track);
  text-transform: uppercase; color: var(--accent);
  padding: 4px 10px; border: 1px solid rgba(217, 119, 87, 0.35); border-radius: 999px;
  background: rgba(217, 119, 87, 0.08);
}
.mdpane-body {
  padding: 28px 28px 72px;
  font-family: var(--mono);
  font-size: 12.5px;
  line-height: 1.72;
  color: var(--ink-2);
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 0 22px;
  max-height: 560px;
  overflow: hidden;
  position: relative;
}
.mdpane-body .ln {
  color: var(--ink-4); text-align: right; user-select: none;
  font-size: 11px; padding-top: 2px; font-weight: 300;
}
.mdpane-body .code { white-space: pre; }
.c-cmt { color: var(--ink-4); font-style: italic; font-weight: 300; }
.c-key { color: var(--accent); font-weight: 500; }
.c-str { color: var(--green); }
.c-dash { color: var(--ink-4); }
.c-neg { color: var(--red); }
.c-pos { color: var(--green); }
.mdpane-foot {
  position: absolute; left: 0; right: 0; bottom: 0;
  display: flex; justify-content: space-between; align-items: center;
  padding: 11px 16px;
  border-top: 1px solid var(--line);
  background: var(--bg-3);
  font-family: var(--mono); font-size: 11px; color: var(--ink-3);
  letter-spacing: 0.02em;
  z-index: 1;
}
.mdpane-foot .gen {
  color: var(--accent); cursor: pointer;
  background: none; border: none; padding: 0; font: inherit;
}
.mdpane-foot .gen:hover { text-decoration: underline; }

/* Floating stack spec card */
.hero-stack {
  position: absolute;
  right: 32px; bottom: -28px;
  background: var(--bg-3);
  border: 1px solid var(--line);
  border-radius: 8px;
  padding: 14px 18px;
  font-family: var(--mono);
  font-size: 10.5px; line-height: 1.8;
  color: var(--ink-2);
  letter-spacing: 0.02em;
  box-shadow: 0 20px 40px -20px rgba(0,0,0,.45);
  min-width: 220px;
}
.hero-stack b { color: var(--ink); font-weight: 500; }
.hero-stack .row { display: flex; gap: 12px; justify-content: space-between; }
.hero-stack .row + .row { border-top: 1px dashed var(--line-soft); padding-top: 5px; margin-top: 5px; }
.hero-stack .row span:last-child { color: var(--ink-3); }
.hero-stack .row .up { color: var(--green); }

/* ========== STATS ========== */
.stats {
  padding: clamp(80px, 12vw, 140px) 0 clamp(72px, 10vw, 120px) !important;
  border-top: 1px solid var(--line);
}
.stats-head {
  display: grid; grid-template-columns: 1fr auto; align-items: end;
  gap: 48px; margin-bottom: clamp(48px, 6vw, 72px);
}
.stats-head p {
  font-family: var(--serif-alt); font-weight: 300; font-style: italic;
  color: var(--ink-2); font-size: 22px; max-width: 40ch;
  margin: 0; line-height: 1.4; letter-spacing: -0.01em;
}
.stats-grid {
  display: grid; grid-template-columns: repeat(3, 1fr);
  border: 1px solid var(--line);
  border-radius: 14px;
  overflow: hidden;
  background: var(--bg-2);
}
.stat {
  padding: 48px 44px !important;
  border-right: 1px solid var(--line);
  position: relative;
  min-height: 300px;
  display: flex !important; flex-direction: column; justify-content: space-between;
  gap: 32px;
}
.stat:last-child { border-right: 0; }
.stat-num {
  font-family: var(--serif);
  font-size: clamp(88px, 9vw, 128px); line-height: 0.88;
  letter-spacing: -0.04em;
  color: var(--ink);
  margin-top: 18px;
}
.stat-num .plus {
  color: var(--accent);
  font-family: var(--serif-alt); font-style: italic; font-weight: 300;
  font-size: 0.7em;
  vertical-align: 0.08em;
  margin-left: 0.02em;
}
.stat-label {
  font-family: var(--mono); font-size: 10.5px; text-transform: uppercase; letter-spacing: var(--track);
  color: var(--ink-3);
}
.stat-body {
  font-size: 14px; color: var(--ink-2); line-height: 1.6;
  max-width: 36ch; margin-top: 20px;
  letter-spacing: -0.005em;
}
.stat-chart {
  margin-top: 20px;
  display: flex; gap: 3px; align-items: end; height: 28px;
}
.stat-chart span {
  flex: 1; background: var(--line); border-radius: 1px;
  height: 40%;
}
.stat-chart span.on { background: var(--accent); height: 100%; }

/* ========== BIO ========== */
.bio {
  padding: 64px 0 0;
  margin-top: 64px;
  border-top: 1px solid var(--line);
  display: grid; grid-template-columns: auto 1fr auto; gap: 56px;
  align-items: center;
}
.bio-portrait {
  width: 108px; height: 108px; border-radius: 50%;
  background: var(--bg-3);
  border: 1px solid var(--line);
  background-image: url('/assets/portrait.jpg');
  background-size: cover;
  background-position: center;
}
.bio-text {
  font-family: var(--serif); font-size: 30px; line-height: 1.22;
  color: var(--ink); max-width: 62ch;
  letter-spacing: -0.015em;
}
.bio-text em {
  font-family: var(--serif-alt); font-style: italic; font-weight: 300;
  color: var(--accent);
}
.bio-meta { font-family: var(--mono); font-size: 11px; color: var(--ink-3); text-align: right; letter-spacing: 0.02em; line-height: 1.7; }
.bio-meta b { color: var(--ink); font-weight: 500; display: block; font-family: var(--sans); font-size: 14px; letter-spacing: -0.01em; }

/* ========== GUIDES ========== */
.guides {
  padding: clamp(80px, 12vw, 140px) 0 clamp(72px, 10vw, 120px);
  border-top: 1px solid var(--line);
}
.section-head {
  display: grid; grid-template-columns: 1fr auto; gap: 48px;
  align-items: end; margin-bottom: clamp(40px, 5vw, 64px);
}
.section-head h2 { margin: 0; }
.section-head .sub {
  font-family: var(--serif-alt); font-weight: 300; font-style: italic;
  color: var(--ink-2); font-size: 22px; margin: 20px 0 0; max-width: 48ch;
  line-height: 1.4; letter-spacing: -0.01em;
}
.section-head .eyebrow { margin-bottom: 16px; display: block; }

.guide-tabs {
  display: flex; gap: 2px; border-bottom: 1px solid var(--line);
  margin-bottom: 40px; font-family: var(--mono); font-size: 11.5px;
  overflow-x: auto;
  scrollbar-width: none;
}
.guide-tabs::-webkit-scrollbar { display: none; }
.guide-tabs button {
  background: transparent; border: 0; color: var(--ink-3);
  padding: 14px 16px; cursor: pointer;
  border-bottom: 2px solid transparent; margin-bottom: -1px;
  font-family: inherit; font-size: inherit; letter-spacing: var(--track-tight);
  text-transform: uppercase;
  white-space: nowrap;
}
.guide-tabs button.on { color: var(--ink); border-bottom-color: var(--accent); }
.guide-tabs button:hover { color: var(--ink); }
.guide-tabs .count { color: var(--ink-4); margin-left: 6px; }

.guide-grid {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr;
  gap: 20px;
}
.guide {
  border: 1px solid var(--line);
  border-radius: 12px;
  background: var(--bg-2);
  padding: 32px;
  display: flex; flex-direction: column; gap: 20px;
  text-decoration: none; color: inherit;
  position: relative;
  transition: border-color .18s ease, transform .18s ease, background .18s ease;
  min-height: 340px;
}
.guide:hover {
  border-color: rgba(217, 119, 87, 0.6);
  background: var(--bg-3);
}
.guide.feat {
  grid-row: span 2;
  background: linear-gradient(180deg, var(--bg-2), var(--bg-3));
  padding: 40px;
}
.guide-topmeta {
  display: flex; justify-content: space-between; align-items: center;
  font-family: var(--mono); font-size: 10.5px; color: var(--ink-3);
  letter-spacing: var(--track-tight); text-transform: uppercase;
}
.guide-topmeta .tag {
  padding: 4px 10px; border: 1px solid var(--line); border-radius: 999px;
  color: var(--ink-2);
}
.guide.feat .guide-topmeta .tag {
  color: var(--accent); border-color: rgba(217, 119, 87, 0.4);
  background: rgba(217, 119, 87, 0.1);
}
.guide-title {
  font-family: var(--serif); font-weight: 400;
  font-size: 30px; line-height: 1.08; letter-spacing: -0.018em;
  color: var(--ink); margin: 0;
}
.guide.feat .guide-title { font-size: clamp(36px, 4vw, 52px); line-height: 1.02; letter-spacing: -0.025em; text-wrap: balance; }
.guide.feat .guide-title i {
  font-family: var(--serif-alt); font-style: italic; font-weight: 300; color: var(--accent);
}
.guide-desc {
  font-size: 14px; color: var(--ink-2); line-height: 1.6;
  letter-spacing: -0.005em;
}
.guide-stats {
  display: grid; grid-template-columns: repeat(3, 1fr);
  border-top: 1px solid var(--line-soft);
  padding-top: 20px; margin-top: auto;
  font-family: var(--mono); font-size: 10.5px; color: var(--ink-3);
  letter-spacing: var(--track-tight); text-transform: uppercase;
}
.guide-stats b {
  display: block; color: var(--ink); font-weight: 400;
  font-family: var(--serif); font-size: 26px;
  letter-spacing: -0.02em;
  text-transform: none;
  margin-bottom: 4px;
}
.guide.feat .guide-hl {
  font-family: var(--mono); font-size: 12px;
  line-height: 1.6;
  background: rgba(217, 119, 87, 0.1);
  color: var(--ink-2);
  padding: 14px 16px;
  border-radius: 6px;
  border-left: 2px solid var(--accent);
  letter-spacing: 0.01em;
}
.guide.feat .guide-hl b {
  color: var(--accent); font-weight: 500; margin-right: 6px;
}
.guide.feat .guide-hl code {
  color: var(--ink); background: var(--bg); padding: 1px 5px; border-radius: 3px;
  font-size: 11px;
}

.guides-more {
  display: grid; grid-template-columns: repeat(4, 1fr);
  gap: 1px;
  background: var(--line);
  border: 1px solid var(--line);
  border-radius: 12px;
  overflow: hidden;
  margin-top: 20px;
}
.guide-row {
  background: var(--bg-2);
  padding: 22px 24px;
  text-decoration: none;
  color: inherit;
  display: flex; flex-direction: column; gap: 12px;
  min-height: 148px;
  transition: background .15s ease;
}
.guide-row:hover { background: var(--bg-3); }
.guide-row .t {
  font-family: var(--serif); font-size: 19px; line-height: 1.18;
  color: var(--ink); letter-spacing: -0.012em;
}
.guide-row .m {
  font-family: var(--mono); font-size: 10px; color: var(--ink-3);
  letter-spacing: var(--track-tight); text-transform: uppercase;
  display: flex; justify-content: space-between;
}
.guide-row .m:last-child { margin-top: auto; }

/* ========== GENERATOR ========== */
.gen-section {
  padding: clamp(80px, 12vw, 140px) 0 clamp(72px, 10vw, 120px);
  border-top: 1px solid var(--line);
  background: var(--bg-2);
}
.gen-grid {
  display: grid; grid-template-columns: 1fr 1.2fr; gap: 72px;
  align-items: start;
}
.gen-intro h2 { margin: 20px 0 24px; }
.gen-intro p {
  font-size: 15.5px; color: var(--ink-2); line-height: 1.65; max-width: 44ch;
  letter-spacing: -0.005em;
}
.gen-features {
  margin-top: 40px; display: grid; gap: 0;
  border-top: 1px solid var(--line);
  padding: 0;
}
.gen-features li {
  list-style: none;
  padding: 18px 0;
  border-bottom: 1px solid var(--line-soft);
  display: grid; grid-template-columns: auto 1fr; gap: 20px; align-items: center;
  font-size: 14px;
}
.gen-features .k {
  font-family: var(--mono); font-size: 10.5px; color: var(--ink-3);
  letter-spacing: var(--track); text-transform: uppercase; min-width: 130px;
}
.gen-features b { color: var(--ink); font-weight: 500; }

.gen-demo {
  border: 1px solid var(--line);
  border-radius: 12px;
  background: var(--bg);
  overflow: hidden;
  box-shadow: var(--shadow-2);
}
.gen-demo-head {
  padding: 14px 20px;
  border-bottom: 1px solid var(--line);
  display: flex; justify-content: space-between; align-items: center;
  font-family: var(--mono); font-size: 11px; color: var(--ink-3);
  letter-spacing: 0.06em; text-transform: uppercase;
  background: var(--bg-3);
}
.gen-demo-head .pulse {
  display: inline-flex; align-items: center; gap: 8px;
  color: var(--green);
}
.gen-demo-head .pulse span {
  width: 6px; height: 6px; border-radius: 50%; background: currentColor;
  box-shadow: 0 0 0 3px rgba(74, 222, 128, 0.25);
}
.gen-form {
  padding: 26px;
  display: grid; gap: 18px;
}
.gen-field { display: grid; gap: 10px; }
.gen-field label {
  font-family: var(--mono); font-size: 10px; color: var(--ink-3);
  letter-spacing: var(--track); text-transform: uppercase;
}
.gen-chips { display: flex; flex-wrap: wrap; gap: 6px; }
.chip {
  font-family: var(--mono); font-size: 11.5px;
  padding: 7px 12px; border: 1px solid var(--line); border-radius: 999px;
  color: var(--ink-2); background: var(--bg-2); cursor: pointer;
  transition: all .14s ease;
  letter-spacing: 0.01em;
}
.chip.on { background: var(--accent); color: var(--accent-ink); border-color: var(--accent); }
.chip:hover { border-color: var(--accent); color: var(--ink); }
.chip.on:hover { color: var(--accent-ink); }

.gen-out {
  border-top: 1px solid var(--line);
  background: var(--bg-2);
  padding: 24px 26px 32px;
  font-family: var(--mono); font-size: 12.5px;
  line-height: 1.7; color: var(--ink-2);
  white-space: pre-wrap;
  max-height: 320px; overflow: hidden; position: relative;
}
.gen-out::after {
  content: ''; position: absolute; left: 0; right: 0; bottom: 0; height: 50px;
  background: linear-gradient(to bottom, transparent, var(--bg-2));
}
.gen-out .c-key { color: var(--accent); font-weight: 500; }
.gen-out .c-str { color: var(--green); }
.gen-out .c-cmt { color: var(--ink-4); font-style: italic; font-weight: 300; }

/* ========== PRICING ========== */
.pricing {
  padding: clamp(80px, 12vw, 140px) 0 clamp(72px, 10vw, 120px);
  border-top: 1px solid var(--line);
}
.price-grid {
  display: grid; grid-template-columns: repeat(3, 1fr);
  border: 1px solid var(--line);
  border-radius: 14px;
  overflow: hidden;
  background: var(--bg-2);
}
.price {
  padding: 44px 40px 40px;
  border-right: 1px solid var(--line);
  display: flex; flex-direction: column; gap: 24px;
  position: relative;
}
.price:last-child { border-right: 0; }
.price.hi { background: var(--bg-3); }
.price-head {
  display: flex; justify-content: space-between; align-items: start;
}
.price-name {
  font-family: var(--mono); font-size: 11px; letter-spacing: var(--track-wide);
  text-transform: uppercase; color: var(--ink-3);
}
.price-tag {
  font-family: var(--mono); font-size: 10px; letter-spacing: var(--track);
  text-transform: uppercase;
  padding: 5px 10px;
  border: 1px solid var(--accent); color: var(--accent);
  border-radius: 999px;
  background: rgba(217, 119, 87, 0.1);
}
.price-num {
  font-family: var(--serif); font-size: 80px; line-height: 0.95;
  letter-spacing: -0.035em;
  color: var(--ink);
  display: flex; align-items: baseline; gap: 8px;
}
.price-num .cur { font-size: 30px; color: var(--ink-3); letter-spacing: -0.01em; }
.price-num .per { font-size: 13px; font-family: var(--mono); color: var(--ink-3); align-self: center; letter-spacing: 0.02em; }
.price-desc {
  font-family: var(--serif-alt); font-weight: 300; font-style: italic;
  font-size: 19px; color: var(--ink-2);
  line-height: 1.4; letter-spacing: -0.01em;
}
.price ul {
  list-style: none; margin: 0; padding: 0;
  border-top: 1px solid var(--line-soft);
}
.price ul li {
  padding: 13px 0;
  border-bottom: 1px solid var(--line-soft);
  font-size: 14px; color: var(--ink-2);
  display: grid; grid-template-columns: 20px 1fr auto; gap: 12px; align-items: center;
  letter-spacing: -0.005em;
}
.price ul li .ck { color: var(--accent); font-family: var(--mono); font-size: 12px; }
.price ul li .v { font-family: var(--mono); font-size: 10.5px; color: var(--ink-3); letter-spacing: 0.02em; }
.price .btn { justify-content: center; padding: 14px; width: 100%; margin-top: 8px; font-size: 13.5px; }

.price-math {
  margin-top: 40px;
  padding: 24px 28px;
  border: 1px dashed var(--line);
  border-radius: 10px;
  display: grid; grid-template-columns: auto 1fr auto; gap: 24px; align-items: center;
  font-family: var(--mono); font-size: 11.5px; color: var(--ink-3);
  letter-spacing: 0.02em;
}
.price-math .math-eq {
  font-family: var(--serif); font-size: 24px; color: var(--ink);
  letter-spacing: -0.015em;
}
.price-math .math-eq em {
  font-family: var(--serif-alt); font-style: italic; font-weight: 300;
  color: var(--accent);
}

/* ========== FOOTER ========== */
.footer {
  padding: 96px 0 48px;
  border-top: 1px solid var(--line);
  background: var(--bg-2);
}
.footer-top {
  display: grid; grid-template-columns: 2fr 1fr 1fr 1fr;
  gap: 56px;
  margin-bottom: 72px;
}
.footer-brand .big {
  font-family: var(--serif);
  font-size: 96px; line-height: 0.92; color: var(--ink);
  letter-spacing: -0.035em;
}
.footer-brand .big i {
  font-family: var(--serif-alt); font-style: italic; font-weight: 300;
  color: var(--accent);
}
.footer-brand p {
  font-family: var(--serif-alt); font-weight: 300; font-style: italic;
  color: var(--ink-2);
  font-size: 17px; max-width: 36ch; margin: 24px 0 0;
  line-height: 1.4; letter-spacing: -0.01em;
}
.foot-col h3 {
  font-family: var(--mono); font-size: 10.5px; letter-spacing: var(--track-wide);
  text-transform: uppercase; color: var(--ink-3);
  margin: 0 0 20px; font-weight: 500;
}
.foot-col a {
  padding: 7px 0; min-height: 44px;
  font-size: 14px; color: var(--ink-2); text-decoration: none;
  letter-spacing: -0.005em;
  display: flex; align-items: center;
}
.foot-col a:hover { color: var(--ink); }
.foot-bottom {
  display: flex; justify-content: space-between; align-items: center;
  border-top: 1px solid var(--line);
  padding-top: 24px;
  font-family: var(--mono); font-size: 10.5px; color: var(--ink-3);
  letter-spacing: var(--track-tight);
}

/* ========== RESPONSIVE ========== */
@media (max-width: 1120px) {
  .nav-links { gap: 0; }
  .nav-links a { padding: 8px 10px; font-size: 12.5px; }
}

@media (max-width: 900px) {
  .wrap { padding: 0 24px; }
  .nav-right .btn-primary { padding: 10px 14px; font-size: 12.5px; }
  .nav-links { display: none; }
  .hero-grid, .gen-grid, .section-head, .stats-head { grid-template-columns: 1fr !important; gap: 32px !important; }
  .hero-copy { max-width: 100%; }
  .hero-stack { position: static !important; transform: none !important; margin-top: 24px; width: 100% !important; max-width: 100%; }
  .hero-meta { grid-template-columns: 1fr 1fr; }
  .hero-meta > div:nth-child(2) { border-right: 0; }
  .display { font-size: clamp(44px, 11vw, 82px); line-height: 0.98; }
  .stats-grid { grid-template-columns: 1fr !important; gap: 0 !important; }
  .stat, .price { border-right: none !important; border-bottom: 1px solid var(--line); }
  .stat { padding: 32px 0 !important; }
  .stat:last-child { border-bottom: none; }
  .bio { grid-template-columns: 1fr !important; gap: 28px !important; }
  .bio-meta { text-align: left; }
  .bio-portrait { width: 140px; height: 140px; }
  .guide-grid, .guides-more { grid-template-columns: 1fr; }
  .gen-grid { grid-template-columns: 1fr !important; gap: 24px !important; }
  .price-grid { grid-template-columns: 1fr !important; gap: 20px !important; }
  .price-math { grid-template-columns: 1fr !important; gap: 16px !important; text-align: left; }
  .price-math .math-eq { font-size: 20px; }
  .footer-top { grid-template-columns: 1fr 1fr !important; gap: 28px !important; }
  .footer-brand { grid-column: 1 / -1; }
  .footer-brand .big { font-size: 72px !important; }
}

@media (max-width: 640px) {
  body { font-size: 14.5px; }
  .wrap { padding: 0 18px; }
  .nav-inner { padding: 14px 0 !important; }
  .brand-word { font-size: 18px !important; }
  .brand-mark { width: 28px !important; height: 28px !important; font-size: 16px !important; }
  .nav-right .btn-primary { font-size: 12px; padding: 9px 12px; }
  .theme-toggle { width: 44px !important; height: 44px !important; }
  .hero-meta { grid-template-columns: 1fr; font-size: 10px; }
  .hero-meta > div {
    border-right: none !important;
    border-bottom: 1px solid var(--line);
    padding: 10px 12px !important;
  }
  .hero-meta > div:last-child { border-bottom: none; }
  .display { font-size: clamp(40px, 12vw, 58px) !important; line-height: 1.0; }
  .hero { padding: 32px 0 48px !important; }
  .kicker { white-space: normal !important; line-height: 1.4; }
  .stat-num { font-size: clamp(44px, 14vw, 72px) !important; }
  .stat { padding: 24px 0 !important; }
  .stat-chart { gap: 2px; }
  .guide-grid { grid-template-columns: 1fr !important; }
  .guides-more { grid-template-columns: 1fr !important; }
  .guide-tabs {
    overflow-x: auto;
    flex-wrap: nowrap !important;
    padding-bottom: 4px;
  }
  .guide-tabs > * { flex-shrink: 0; }
  .mdpane { font-size: 11px !important; }
  .mdpane-head, .mdpane-foot { font-size: 10px !important; padding: 10px 12px !important; }
  .hero-stack { font-size: 11.5px; padding: 14px 16px !important; }
  .btn { min-height: 44px; padding: 12px 16px; }
  .chip { font-size: 11.5px; min-height: 44px; }
  .price { padding: 28px 22px !important; }
  .price ul li { grid-template-columns: 16px 1fr auto; gap: 10px; font-size: 13px; }
  .footer-top { grid-template-columns: 1fr !important; }
  .footer-brand .big { font-size: 56px !important; }
  section { padding: 56px 0 !important; }
}

@media (max-width: 380px) {
  .wrap { padding: 0 14px; }
  .display { font-size: 36px !important; }
  .brand-word > span { display: none; }
}

@media (hover: none) and (pointer: coarse) {
  a, button, .btn, .chip { -webkit-tap-highlight-color: transparent; }
}
</style>

<!-- ========= NAV ========= -->
<nav class="nav">
  <div class="nav-inner">
    <a class="brand" href="/">
      <span class="brand-mark">&#926;</span>
      <span class="brand-word">Claude Code <span>Guides</span></span>
    </a>
    <div class="nav-links">
      <a href="/all-articles/">Guides <span style="color:var(--ink-3);font-family:var(--mono);font-size:11px">3,021</span></a>
      <a href="/generator/">Generator</a>
      <a href="/about/">About</a>
      <a href="#pricing">Pricing</a>
      <a href="https://discord.com/invite/QeHxTFbqmC" target="_blank" rel="noopener noreferrer">Community &#8599;</a>
    </div>
    <div class="nav-right">
      <button class="theme-toggle" id="themeBtn" aria-label="Toggle theme">
        <svg id="themeIcon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true">
          <path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/>
        </svg>
      </button>
      <a class="btn btn-primary" href="https://zovo.one/lifetime">Get lifetime &#8594;</a>
    </div>
  </div>
</nav>

<!-- ========= HERO ========= -->
<header class="hero">
  <div class="wrap">

    <div class="hero-meta">
      <div><span>Vol. 04 / Iss. 118</span><span>Apr 20, 2026</span></div>
      <div><span>Last update</span><b>47 min ago</b></div>
      <div><span>Guides shipped</span><b>3,021</b></div>
      <div><span>Status</span><b style="color:var(--green)">&#9679; Operational</b></div>
    </div>

    <div class="hero-grid">
      <div class="hero-copy">
        <span class="kicker"><span class="dot"></span> A reference for Claude Code operators</span>
        <h1 class="display">
          Claude&nbsp;Code<br>
          was <i>meant</i> to<br>
          work like this.
        </h1>
        <p class="hero-sub">
          One file in your repo. <b>Three hundred lines.</b><br>
          Stops guessing your stack. <i>Starts engineering.</i>
        </p>
        <div class="hero-cta">
          <a class="btn btn-primary" href="/generator/">
            Generate your CLAUDE.md
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M5 12h14m-6-6 6 6-6 6"/></svg>
          </a>
          <a class="btn btn-ghost" href="/all-articles/">Browse 3,021 guides</a>
        </div>
        <div class="hero-note">
          <span>$99 lifetime</span> &middot; no subscription &middot; pays for itself in one production ticket
        </div>
      </div>

      <!-- CLAUDE.md pane -->
      <div class="mdpane" style="position:relative">
        <div class="mdpane-head">
          <div class="mdpane-dots"><span></span><span></span><span></span></div>
          <span class="mdpane-name">~/acme-saas/<b>CLAUDE.md</b></span>
          <span class="mdpane-tag">v2.4 &middot; generated</span>
        </div>
        <div class="mdpane-body">
          <div class="ln">1<br>2<br>3<br>4<br>5<br>6<br>7<br>8<br>9<br>10<br>11<br>12<br>13<br>14<br>15<br>16<br>17<br>18<br>19<br>20<br>21<br>22<br>23</div>
          <div class="code"><span class="c-cmt"># Generated by claudecodeguides.com</span>
<span class="c-key">project</span>: acme-saas
<span class="c-key">framework</span>: <span class="c-str">next.js 14 (app router)</span>
<span class="c-key">language</span>: <span class="c-str">typescript 5.4 strict</span>

<span class="c-cmt"># Architecture rules</span>
<span class="c-key">patterns</span>:
  <span class="c-dash">-</span> server components by default
  <span class="c-dash">-</span> <span class="c-str">"use client"</span> only for interactivity
  <span class="c-dash">-</span> colocate tests next to source

<span class="c-cmt"># Boundaries Claude must respect</span>
<span class="c-key">never</span>:
  <span class="c-neg">-</span> modify prisma/schema.prisma
  <span class="c-neg">-</span> change auth middleware
  <span class="c-neg">-</span> add dependencies without asking

<span class="c-cmt"># Style</span>
<span class="c-key">formatting</span>: biome
<span class="c-key">max_line_length</span>: 100
<span class="c-key">imports</span>: <span class="c-str">absolute (@/)</span>
<span class="c-key">tests</span>: <span class="c-pos">vitest + playwright</span></div>
        </div>
        <div class="mdpane-foot">
          <span>YAML &middot; 23 lines &middot; 642 bytes</span>
          <button class="gen" id="regen" type="button">&#8635; regenerate for my stack</button>
        </div>
      </div>

      <div class="hero-stack">
        <div class="row"><b>stack</b><span>next + ts + prisma</span></div>
        <div class="row"><b>guides matched</b><span>34</span></div>
        <div class="row"><b>est. tokens saved</b><span class="up">&#8595; 62%</span></div>
      </div>
    </div>
  </div>
</header>

<!-- ========= STATS ========= -->
<section class="stats" id="stats">
  <div class="wrap">
    <div class="stats-head">
      <div>
        <span class="eyebrow">&sect; 01 &middot; The operator</span>
        <h2 class="h2" style="margin:16px 0 0">Receipts, not&nbsp;<i>promises.</i></h2>
      </div>
      <p>One solo developer in Da Nang, running an agent fleet, shipping configs daily, paid by the market.</p>
    </div>

    <div class="stats-grid">
      <div class="stat">
        <div>
          <div class="stat-label">&sect; Upwork &middot; lifetime</div>
          <div class="stat-num">$400K<span class="plus">+</span></div>
        </div>
        <div>
          <div class="stat-chart">
            <span></span><span class="on"></span><span class="on"></span><span></span>
            <span class="on"></span><span class="on"></span><span class="on"></span><span></span>
            <span class="on"></span><span class="on"></span><span class="on"></span><span class="on"></span>
            <span class="on"></span><span class="on"></span><span class="on"></span>
          </div>
          <p class="stat-body">Earned writing production code with Claude Code. 100% Job Success Score. Every config here was battle-tested on a paying client first.</p>
        </div>
      </div>

      <div class="stat">
        <div>
          <div class="stat-label">&sect; Guides &middot; archive</div>
          <div class="stat-num">3,021</div>
        </div>
        <div>
          <div class="stat-chart">
            <span class="on"></span><span class="on"></span><span class="on"></span><span class="on"></span>
            <span class="on"></span><span class="on"></span><span class="on"></span><span class="on"></span>
            <span class="on"></span><span class="on"></span><span class="on"></span><span class="on"></span>
            <span class="on"></span><span class="on"></span><span class="on"></span>
          </div>
          <p class="stat-body">Every one of them tested on a real problem I hit. No AI slop, no filler &mdash; if a guide exists here, something actually broke and I found the fix.</p>
        </div>
      </div>

      <div class="stat">
        <div>
          <div class="stat-label">&sect; Zovo &middot; extensions</div>
          <div class="stat-num">50K<span class="plus">+</span></div>
        </div>
        <div>
          <div class="stat-chart">
            <span></span><span></span><span class="on"></span><span class="on"></span>
            <span class="on"></span><span class="on"></span><span class="on"></span><span class="on"></span>
            <span class="on"></span><span class="on"></span><span class="on"></span><span class="on"></span>
            <span class="on"></span><span class="on"></span><span class="on"></span>
          </div>
          <p class="stat-body">Developers using the Chrome extensions shipped at <span style="color:var(--accent)">zovo.one</span>. Same operator, same rigor, same thing running in production.</p>
        </div>
      </div>
    </div>

    <div class="bio">
      <div class="bio-portrait" role="img" aria-label="Portrait of Michael Lip"></div>
      <div class="bio-text">
        Run by <em>Michael Lip</em> &mdash; a solo developer in Da Nang maintaining a fleet of agents on five Claude Max subscriptions. Every guide is updated daily. Every config is tested before it lands.
      </div>
      <div class="bio-meta">
        <b>Michael Lip</b>
        <span>Da Nang, Vietnam</span><br>
        <span><a href="https://zovo.one" target="_blank" rel="noopener noreferrer" style="color:var(--ink-3)">zovo.one</a> &middot; <a href="https://github.com/theluckystrike" target="_blank" rel="noopener noreferrer" style="color:var(--ink-3)">github/theluckystrike</a></span>
      </div>
    </div>
  </div>
</section>

<!-- ========= GUIDES ========= -->
<section class="guides" id="guides">
  <div class="wrap">
    <div class="section-head">
      <div>
        <span class="eyebrow">&sect; 02 &middot; The work</span>
        <h2 class="h2">What developers<br>are <i>actually</i> reading.</h2>
        <p class="sub">3,021 guides in the archive. Here's what's hot this week &mdash; by impressions, clicks, and actual CTR.</p>
      </div>
      <a class="btn btn-ghost" href="/all-articles/">Browse all 3,021 &#8594;</a>
    </div>

    <div class="guide-tabs" id="tabs" role="toolbar" aria-label="Guide categories">
      <button class="on" aria-pressed="true" data-tab="trending">Trending <span class="count">[12]</span></button>
      <button aria-pressed="false" data-tab="new">Newest <span class="count">[47]</span></button>
      <button aria-pressed="false" data-tab="api">API <span class="count">[134]</span></button>
      <button aria-pressed="false" data-tab="agents">Agents <span class="count">[66]</span></button>
      <button aria-pressed="false" data-tab="mcp">MCP <span class="count">[92]</span></button>
      <button aria-pressed="false" data-tab="prompts">Prompts <span class="count">[34]</span></button>
      <button aria-pressed="false" data-tab="start">Getting started <span class="count">[60]</span></button>
    </div>

    <div class="guide-grid">
      <a class="guide feat" href="/claude-api-timeout-error-handling-retry-guide/">
        <div class="guide-topmeta">
          <span>&sect; API &middot; reliability</span>
          <span class="tag">#1 trending</span>
        </div>
        <h3 class="guide-title">Fix Claude API Stream Idle Timeout &mdash; <i>a guide nobody else wrote.</i></h3>
        <p class="guide-desc">2,198 developers read this last month. Because stream timeouts are real, the fix is specific, and nobody else wrote it down. Covers retry backoff, keep-alive heartbeats, and the one HTTP/2 gotcha that eats 30% of long-running completions.</p>
        <div class="guide-hl">
          <b>TL;DR</b> &mdash; increase <code>keepAliveTimeout</code> beyond your proxy's idle cutoff, wrap the stream in a watchdog, resume on <code>408</code>/<code>504</code> without reloading context.
        </div>
        <div class="guide-stats">
          <div><b>2,198</b><span>reads / mo</span></div>
          <div><b>13m</b><span>read time</span></div>
          <div><b>94%</b><span>completion</span></div>
        </div>
      </a>

      <a class="guide" href="/claude-opus-orchestrator-sonnet-worker-architecture/">
        <div class="guide-topmeta">
          <span>&sect; Agents &middot; arch</span>
          <span class="tag">trending</span>
        </div>
        <h3 class="guide-title">Opus Orchestrator + Sonnet Worker pattern.</h3>
        <p class="guide-desc">3-layer delegation: Opus plans, Sonnet executes, tokens drop 60%. The multi-agent architecture most teams discover too late.</p>
        <div class="guide-stats">
          <div><b>1,842</b><span>reads</span></div>
          <div><b>&minus;60%</b><span>tokens</span></div>
          <div><b>8m</b><span>read</span></div>
        </div>
      </a>

      <a class="guide" href="/claude-code-for-fpga-development-workflow-tutorial/">
        <div class="guide-topmeta">
          <span>&sect; Niche &middot; FPGA</span>
          <span class="tag">high CTR</span>
        </div>
        <h3 class="guide-title">Claude Code for FPGA development workflow.</h3>
        <p class="guide-desc">121 impressions, 16 clicks, 13.2% CTR. Most articles about FPGAs and AI don't exist. This one does.</p>
        <div class="guide-stats">
          <div><b>121</b><span>impr.</span></div>
          <div><b>13.2%</b><span>CTR</span></div>
          <div><b>12m</b><span>read</span></div>
        </div>
      </a>
    </div>

    <div class="guides-more">
      <a class="guide-row" href="/building-your-first-mcp-tool-integration-guide-2026/">
        <div class="m"><span>&sect; MCP</span><span>new</span></div>
        <div class="t">Building a custom MCP server in 40 lines of Python.</div>
        <div class="m"><span>904 reads</span><span>6m</span></div>
      </a>
      <a class="guide-row" href="/claude-api-system-prompt-engineering-for-production-apps/">
        <div class="m"><span>&sect; Prompts</span><span>&mdash;</span></div>
        <div class="t">The 12 prompts I reuse across every Upwork engagement.</div>
        <div class="m"><span>3,114 reads</span><span>14m</span></div>
      </a>
      <a class="guide-row" href="/claude-md-best-practices-for-large-codebases/">
        <div class="m"><span>&sect; Start</span><span>&mdash;</span></div>
        <div class="t">A CLAUDE.md that actually works for monorepos.</div>
        <div class="m"><span>2,008 reads</span><span>11m</span></div>
      </a>
      <a class="guide-row" href="/chrome-extension-development-2026/">
        <div class="m"><span>&sect; Ext</span><span>&mdash;</span></div>
        <div class="t">Shipping a Chrome extension with zero build step.</div>
        <div class="m"><span>687 reads</span><span>9m</span></div>
      </a>
      <a class="guide-row" href="/claude-code-error-rate-limit-429-how-to-handle/">
        <div class="m"><span>&sect; API</span><span>&mdash;</span></div>
        <div class="t">Rate-limit backoff patterns that don't lose work.</div>
        <div class="m"><span>1,402 reads</span><span>7m</span></div>
      </a>
      <a class="guide-row" href="/claude-code-for-ai-agent-tool-calling-implementation/">
        <div class="m"><span>&sect; Agents</span><span>new</span></div>
        <div class="t">Tool-use loops: when to recurse, when to stop.</div>
        <div class="m"><span>512 reads</span><span>10m</span></div>
      </a>
      <a class="guide-row" href="/claude-code-reduce-api-costs-guide/">
        <div class="m"><span>&sect; Cost</span><span>&mdash;</span></div>
        <div class="t">Cutting my Claude bill by 70% without losing quality.</div>
        <div class="m"><span>2,744 reads</span><span>8m</span></div>
      </a>
      <a class="guide-row" href="/best-way-to-give-claude-code-repeatable-deterministic-output/">
        <div class="m"><span>&sect; Debug</span><span>&mdash;</span></div>
        <div class="t">Reproducing flaky agent runs with deterministic seeds.</div>
        <div class="m"><span>430 reads</span><span>9m</span></div>
      </a>
    </div>
  </div>
</section>

<!-- ========= GENERATOR ========= -->
<section class="gen-section" id="generator">
  <div class="wrap">
    <div class="gen-grid">
      <div class="gen-intro">
        <span class="eyebrow">&sect; 03 &middot; The tool</span>
        <h2 class="h2">Try it. Tell it<br><i>your</i> stack.</h2>
        <p>Get a production-grade CLAUDE.md in 60 seconds. 27 frameworks supported &mdash; Next.js, FastAPI, Rails, Go, Rust, Terraform, the rest. Drop the file in your project. Claude Code stops guessing.</p>
        <ul class="gen-features">
          <li><span class="k">&rarr; output</span><span><b>CLAUDE.md</b> &mdash; 200&ndash;400 lines, YAML frontmatter, ready to commit</span></li>
          <li><span class="k">&rarr; coverage</span><span><b>27 stacks</b> &middot; web, mobile, infra, ML, embedded</span></li>
          <li><span class="k">&rarr; time</span><span>about <b>60 seconds</b>, no signup</span></li>
          <li><span class="k">&rarr; license</span><span><b>yours</b> &mdash; edit, commit, share, resell</span></li>
        </ul>
      </div>

      <div class="gen-demo">
        <div class="gen-demo-head">
          <span>claudecodeguides.com/generator</span>
          <span class="pulse"><span></span> live</span>
        </div>
        <div class="gen-form" aria-label="Generator demo">
          <div class="gen-field">
            <label id="lbl-fw">framework</label>
            <div class="gen-chips" data-group="fw" role="group" aria-labelledby="lbl-fw">
              <button class="chip on" aria-pressed="true">Next.js 14</button>
              <button class="chip" aria-pressed="false">FastAPI</button>
              <button class="chip" aria-pressed="false">Rails 7</button>
              <button class="chip" aria-pressed="false">Go</button>
              <button class="chip" aria-pressed="false">Rust</button>
              <button class="chip" aria-pressed="false">Svelte</button>
              <button class="chip" aria-pressed="false">+ 21 more</button>
            </div>
          </div>
          <div class="gen-field">
            <label id="lbl-lang">language</label>
            <div class="gen-chips" data-group="lang" role="group" aria-labelledby="lbl-lang">
              <button class="chip on" aria-pressed="true">TypeScript strict</button>
              <button class="chip" aria-pressed="false">Python 3.12</button>
              <button class="chip" aria-pressed="false">Ruby</button>
              <button class="chip" aria-pressed="false">Rust</button>
            </div>
          </div>
          <div class="gen-field">
            <label id="lbl-c">constraints (pick any)</label>
            <div class="gen-chips" data-group="c" data-multi="1" role="group" aria-labelledby="lbl-c">
              <button class="chip on" aria-pressed="true">Don't touch auth</button>
              <button class="chip on" aria-pressed="true">Colocate tests</button>
              <button class="chip" aria-pressed="false">No new deps</button>
              <button class="chip" aria-pressed="false">Strict imports</button>
              <button class="chip" aria-pressed="false">Biome formatter</button>
            </div>
          </div>
        </div>
        <div class="gen-out" id="genOut" aria-live="polite"><span class="c-cmt"># Generated by claudecodeguides.com &middot; hit &darr; regenerate</span>
<span class="c-key">project</span>: <span id="gp">your-app</span>
<span class="c-key">framework</span>: <span class="c-str" id="gf">next.js 14 (app router)</span>
<span class="c-key">language</span>: <span class="c-str" id="gl">typescript 5.4 strict</span>

<span class="c-cmt"># rules the agent will respect</span>
<span class="c-key">never</span>:
  - modify auth middleware
  - add dependencies without asking
<span class="c-key">always</span>:
  - colocate tests next to source
  - server components by default
</div>
      </div>
    </div>
  </div>
</section>

<!-- ========= PRICING ========= -->
<section class="pricing" id="pricing">
  <div class="wrap">
    <div class="section-head">
      <div>
        <span class="eyebrow">&sect; 04 &middot; The offer</span>
        <h2 class="h2">Three ways to<br>use this <i>site.</i></h2>
        <p class="sub">Free tier is complete. Paid tiers are for operators who want the same configs I bill clients for.</p>
      </div>
      <div style="font-family:var(--mono);font-size:11px;color:var(--ink-3);letter-spacing:0.08em;text-align:right;line-height:1.6">
        last updated<br><b style="color:var(--ink)">Apr 20, 2026</b><br>
        next review<br><b style="color:var(--ink)">May 15, 2026</b>
      </div>
    </div>

    <div class="price-grid">
      <div class="price">
        <div class="price-head">
          <span class="price-name">&sect; Free</span>
        </div>
        <div class="price-num"><span class="cur">$</span>0</div>
        <div class="price-desc">Everything on this site, forever. No login. No gate.</div>
        <ul>
          <li><span class="ck">&#10003;</span><span>All 3,021 guides</span><span class="v">open</span></li>
          <li><span class="ck">&#10003;</span><span>CLAUDE.md generator</span><span class="v">27 stacks</span></li>
          <li><span class="ck">&#10003;</span><span>Weekly updates</span><span class="v">rss</span></li>
          <li><span class="ck">&#10003;</span><span>Search across archive</span><span class="v">full-text</span></li>
        </ul>
        <a class="btn btn-ghost" href="/all-articles/">Keep browsing &#8594;</a>
      </div>

      <div class="price">
        <div class="price-head">
          <span class="price-name">&sect; Community</span>
        </div>
        <div class="price-num"><span class="cur">$</span>4.99<span class="per">/ mo</span></div>
        <div class="price-desc">Everything free + templates, Discord, monthly builder calls.</div>
        <ul>
          <li><span class="ck">&#10003;</span><span>16 CLAUDE.md templates</span><span class="v">.yml</span></li>
          <li><span class="ck">&#10003;</span><span>Private Discord</span><span class="v">~410 ops</span></li>
          <li><span class="ck">&#10003;</span><span>Monthly builder calls</span><span class="v">zoom &middot; rec.</span></li>
          <li><span class="ck">&#10003;</span><span>Template library</span><span class="v">curated</span></li>
        </ul>
        <a class="btn btn-ghost" href="https://zovo.one/community">Join community &#8594;</a>
      </div>

      <div class="price hi">
        <div class="price-head">
          <span class="price-name">&sect; Lifetime</span>
          <span class="price-tag">Most chosen</span>
        </div>
        <div class="price-num"><span class="cur">$</span>99<span class="per">once</span></div>
        <div class="price-desc">All of the above + 80 prompts + orchestration configs + every future build.</div>
        <ul>
          <li><span class="ck">&#10003;</span><span>16 templates</span><span class="v">.yml</span></li>
          <li><span class="ck">&#10003;</span><span>80 tested prompts</span><span class="v">.md</span></li>
          <li><span class="ck">&#10003;</span><span>Orchestration configs</span><span class="v">opus + sonnet</span></li>
          <li><span class="ck">&#10003;</span><span>Every future build</span><span class="v">forever</span></li>
          <li><span class="ck">&#10003;</span><span>Priority in Discord</span><span class="v">@lifetime</span></li>
        </ul>
        <a class="btn btn-primary" href="https://zovo.one/lifetime">Get lifetime &#8594; $99</a>
      </div>
    </div>

    <div class="price-math">
      <span class="eyebrow" style="font-size:10px">&sect; the math</span>
      <span class="math-eq">$99 &divide; $4.99/mo = <em>&asymp; 20 months</em>. After month 21, Lifetime pays nothing &mdash; forever.</span>
      <span>compounded value &middot; one-time</span>
    </div>
  </div>
</section>

<!-- ========= FOOTER ========= -->
<footer class="footer">
  <div class="wrap">
    <div class="footer-top">
      <div class="footer-brand">
        <div class="big">Claude Code<br><i>Guides.</i></div>
        <p>An independent reference for Claude Code operators &mdash; maintained daily by Michael Lip and a small fleet of agents.</p>
      </div>
      <div class="foot-col">
        <h3>&sect; Read</h3>
        <a href="/all-articles/">All guides</a>
        <a href="/topics/getting-started/">Getting started</a>
        <a href="/topics/api/">API</a>
        <a href="/topics/agents/">Agents</a>
        <a href="/topics/mcp/">MCP</a>
        <a href="/topics/prompt-engineering/">Prompts</a>
      </div>
      <div class="foot-col">
        <h3>&sect; Tools</h3>
        <a href="/generator/">CLAUDE.md generator</a>
        <a href="https://zovo.one/lifetime">Template library</a>
        <a href="https://zovo.one/lifetime">Orchestration kit</a>
        <a href="/feed.xml">RSS feed</a>
      </div>
      <div class="foot-col">
        <h3>&sect; Elsewhere</h3>
        <a href="https://zovo.one" target="_blank" rel="noopener noreferrer">zovo.one &#8599;</a>
        <a href="https://discord.com/invite/QeHxTFbqmC" target="_blank" rel="noopener noreferrer">Discord &#8599;</a>
        <a href="https://github.com/theluckystrike" target="_blank" rel="noopener noreferrer">GitHub &#8599;</a>
        <a href="https://www.upwork.com/freelancers/~01b0e2c31b7c8a0e5c" target="_blank" rel="noopener noreferrer">Upwork profile &#8599;</a>
        <a href="mailto:michael@zovo.one">Email</a>
      </div>
    </div>
    <div class="foot-bottom">
      <span>&copy; 2026 &middot; Built in Da Nang &middot; Updated daily by an agent fleet on five Claude Max subscriptions.</span>
      <span>v2.4 &middot; no cookies &middot; no tracking</span>
    </div>
  </div>
</footer>

{% raw %}
<script>
(function(){
  'use strict';
  var html = document.documentElement;

  /* ---- Theme toggle ---- */
  function applyTheme(t) {
    console.assert(t === 'dark' || t === 'light', 'applyTheme: invalid theme');
    console.assert(html instanceof HTMLElement, 'applyTheme: html element missing');
    html.setAttribute('data-theme', t);
    var icon = document.getElementById('themeIcon');
    if (!icon) return;
    icon.innerHTML = (t === 'dark')
      ? '<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/>'
      : '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>';
    try { localStorage.setItem('ccg-theme', t); } catch(e) {}
  }

  /* Init theme from localStorage or default dark */
  var saved = null;
  try { saved = localStorage.getItem('ccg-theme'); } catch(e) {}
  applyTheme(saved || 'dark');

  /* Theme toggle click */
  var themeBtn = document.getElementById('themeBtn');
  if (themeBtn) {
    themeBtn.addEventListener('click', function() {
      var next = (html.getAttribute('data-theme') === 'dark') ? 'light' : 'dark';
      applyTheme(next);
    });
  }

  /* ---- Guide tabs ---- */
  var tabs = document.getElementById('tabs');
  if (tabs) {
    console.assert(tabs.querySelectorAll('button').length > 0, 'tabs: no buttons found');
    console.assert(tabs.querySelector('button.on'), 'tabs: no default active tab');
    tabs.addEventListener('click', function(e) {
      var b = e.target.closest('button');
      if (!b) return;
      tabs.querySelectorAll('button').forEach(function(x) {
        x.classList.remove('on');
        x.setAttribute('aria-pressed', 'false');
      });
      b.classList.add('on');
      b.setAttribute('aria-pressed', 'true');
    });
  }

  /* ---- Generator chips ---- */
  var chipGroups = document.querySelectorAll('.gen-chips');
  console.assert(chipGroups.length > 0, 'chips: no chip groups found');
  console.assert(chipGroups.length <= 10, 'chips: unexpected number of groups');
  chipGroups.forEach(function(group) {
    var multi = group.dataset.multi === '1';
    group.addEventListener('click', function(e) {
      var c = e.target.closest('.chip');
      if (!c) return;
      if (multi) {
        c.classList.toggle('on');
        c.setAttribute('aria-pressed', c.classList.contains('on') ? 'true' : 'false');
      } else {
        group.querySelectorAll('.chip').forEach(function(x) {
          x.classList.remove('on');
          x.setAttribute('aria-pressed', 'false');
        });
        c.classList.add('on');
        c.setAttribute('aria-pressed', 'true');
      }
      updateGen();
    });
  });

  function updateGen() {
    console.assert(document.getElementById('gf'), 'updateGen: gf element missing');
    console.assert(document.getElementById('gl'), 'updateGen: gl element missing');
    var fwEl = document.querySelector('.gen-chips[data-group="fw"] .chip.on');
    var langEl = document.querySelector('.gen-chips[data-group="lang"] .chip.on');
    var fw = fwEl ? fwEl.textContent.trim() : 'Next.js 14';
    var lang = langEl ? langEl.textContent.trim() : 'TypeScript';
    var gf = document.getElementById('gf');
    var gl = document.getElementById('gl');
    if (gf) gf.textContent = fw.toLowerCase();
    if (gl) gl.textContent = lang.toLowerCase();
  }

  /* ---- Regenerate hero md (cosmetic shake) ---- */
  var regen = document.getElementById('regen');
  if (regen) {
    console.assert(document.querySelector('.mdpane-body'), 'regen: mdpane-body missing');
    console.assert(typeof Element.prototype.animate === 'function', 'regen: Web Animations API not supported');
    regen.addEventListener('click', function() {
      var body = document.querySelector('.mdpane-body');
      if (body) {
        body.animate([{opacity:1},{opacity:.3},{opacity:1}], {duration: 500});
      }
    });
  }
})();
</script>
{% endraw %}
