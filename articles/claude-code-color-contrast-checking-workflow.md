---

layout: default
title: "Check Color Contrast with Claude Code"
description: "Check WCAG color contrast ratios with Claude Code for accessibility compliance. Automate contrast audits across your entire design system and codebase."
date: 2026-03-14
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
author: "Claude Skills Guide"
permalink: /claude-code-color-contrast-checking-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---

Color contrast checking is a critical yet often overlooked aspect of web accessibility. Ensuring your text meets WCAG guidelines protects users with visual impairments and keeps your project legally compliant. This guide walks you through a practical workflow using Claude Code skills to systematically check and verify color contrast across your entire project.

## Why Color Contrast Checking Matters

Web Content Accessibility Guidelines (WCAG) 2.1 specify minimum contrast ratios: 4.5:1 for normal text and 3:1 for large text. Failure to meet these standards excludes users with low vision, color blindness, or those viewing content on poorly calibrated displays. Many development teams treat accessibility as an afterthought, discovering issues only during expensive audits or, worse, after legal complaints.

The business case for accessible color contrast is substantial. Approximately 8% of men and 0.5% of women have some form of color vision deficiency. Users with cataracts, glaucoma, or diabetic retinopathy also depend on sufficient contrast. Beyond individual users, Section 508 compliance is mandatory for US federal agency contracts, and the European Accessibility Act (EAA) extends similar requirements across the EU. Lawsuits under the Americans with Disabilities Act have targeted major brands including Netflix, Domino's, and Target.

Integrating color contrast checking into your regular development workflow catches problems early. The key is automation. manual checking becomes impractical as codebases grow. Claude Code skills provide the tooling to make contrast checking a smooth part of your development process.

## Understanding WCAG Contrast Requirements

Before automating checks, you need to understand what you're testing for. WCAG 2.1 defines two conformance levels for contrast:

| Criterion | Normal Text | Large Text | UI Components |
|-----------|-------------|------------|---------------|
| WCAG AA (Level AA) | 4.5:1 | 3:1 | 3:1 |
| WCAG AAA (Level AAA) | 7:1 | 4.5:1 | n/a |

"Large text" means 18pt (24px) or 14pt bold (approximately 18.67px bold). UI components include form inputs, focus indicators, and interactive controls. these only need 3:1 against adjacent colors.

There are notable exceptions. Decorative text, logos, and text that is part of a brand's inactive UI (like disabled button labels) are exempt. However, exempt does not mean invisible. a disabled button showing 1.2:1 contrast still creates a confusing experience.

WCAG 3.0 (in draft) introduces APCA (Advanced Perceptual Contrast Algorithm), which replaces the current luminance-ratio formula with a more nuanced perceptual model. Building automation now that is easy to update will save you from scrambling when that standard matures.

## Prerequisites and Skill Setup

Before implementing this workflow, ensure Claude Code is installed and configured. You will need several skills available in the Claude Skills ecosystem:

- frontend-design skill: Provides accessibility-aware component generation and design pattern recommendations
- axe-accessibility skill: Integrates axe-core accessibility testing into your workflow
- tdd skill: Helps write automated tests that verify contrast requirements
- pdf skill: Useful when generating accessibility audit reports

To install skills, clone community skill repositories from GitHub and place the `.md` files in `~/.claude/skills/`. Skills activate automatically when their trigger patterns match your prompts.

## Step 1: Audit Existing Color Values

Begin by cataloging all color values used throughout your project. Create a dedicated file to track these values and their usage contexts. This inventory becomes your reference point for systematic checking.

Use Claude Code to scan your project files:

```bash
grep -rE "#[0-9A-Fa-f]{3,6}|rgb\(|rgba\(|hsl\(" --include="*.css" --include="*.scss" --include="*.ts" --include="*.tsx" src/
```

For projects using CSS custom properties or design tokens, extend the scan:

```bash
Capture CSS variables and design tokens alongside hardcoded values
grep -rE "var\(--[a-z-]+\)|#[0-9A-Fa-f]{3,6}|rgb\(|rgba\(|hsl\(" \
 --include="*.css" --include="*.scss" --include="*.json" \
 --include="*.ts" --include="*.tsx" src/ tokens/
```

Feed the results to Claude with a prompt like: "Organize these color values into a table with their file locations and usage contexts (background, text, borders, etc.)."

Once you have the inventory, resolve CSS custom properties to their actual hex or RGB values. A token like `--color-text-primary: #1a1a1a` is only meaningful when you know what background it sits on. Ask Claude to trace each variable to its computed value across your defined themes.

A well-structured color inventory looks like this:

```
Token | Hex Value | Used On | Context
-------------------------|-----------|----------------|--------------------
--color-text-primary | #1a1a1a | #ffffff | Body text
--color-text-muted | #6b7280 | #ffffff | Captions, metadata
--color-text-link | #2563eb | #ffffff | Inline links
--color-text-link-hover | #1d4ed8 | #ffffff | Hovered links
--color-btn-label | #ffffff | #2563eb | Primary button
--color-error | #dc2626 | #fff7f7 | Error messages
--color-placeholder | #9ca3af | #ffffff | Input placeholders
```

This table becomes the input for your contrast ratio calculations and makes it easy to spot which tokens are risky at a glance.

## Step 2: Calculate Contrast Ratios

Once you have your color inventory, calculate contrast ratios for each text-on-background combination. Claude Code can perform these calculations directly:

```javascript
function getContrastRatio(foreground, background) {
 const getLuminance = (color) => {
 const rgb = color.match(/\d+/g).map(Number);
 const [r, g, b] = rgb.map(c => {
 c = c / 255;
 return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
 });
 return 0.2126 * r + 0.7152 * g + 0.0722 * b;
 };

 const l1 = getLuminance(foreground);
 const l2 = getLuminance(background);
 const lighter = Math.max(l1, l2);
 const darker = Math.min(l1, l2);

 return (lighter + 0.05) / (darker + 0.05);
}
```

Extend this into a batch checker that processes your entire inventory:

```javascript
function parseHexToRgb(hex) {
 const cleaned = hex.replace('#', '');
 const full = cleaned.length === 3
 ? cleaned.split('').map(c => c + c).join('')
 : cleaned;
 const num = parseInt(full, 16);
 return `rgb(${(num >> 16) & 255}, ${(num >> 8) & 255}, ${num & 255})`;
}

const colorPairs = [
 { fg: '#1a1a1a', bg: '#ffffff', context: 'Body text', isLarge: false },
 { fg: '#6b7280', bg: '#ffffff', context: 'Muted text', isLarge: false },
 { fg: '#2563eb', bg: '#ffffff', context: 'Links', isLarge: false },
 { fg: '#ffffff', bg: '#2563eb', context: 'Button label', isLarge: false },
 { fg: '#dc2626', bg: '#fff7f7', context: 'Error messages', isLarge: false },
 { fg: '#9ca3af', bg: '#ffffff', context: 'Placeholders', isLarge: false },
];

const results = colorPairs.map(pair => {
 const ratio = getContrastRatio(
 parseHexToRgb(pair.fg),
 parseHexToRgb(pair.bg)
 );
 const threshold = pair.isLarge ? 3.0 : 4.5;
 return {
 ...pair,
 ratio: ratio.toFixed(2),
 passesAA: ratio >= threshold,
 passesAAA: ratio >= (pair.isLarge ? 4.5 : 7.0),
 };
});

results.forEach(r => {
 const status = r.passesAA ? 'PASS' : 'FAIL';
 console.log(`${status} [${r.ratio}:1] ${r.context}. ${r.fg} on ${r.bg}`);
});
```

Ask Claude to evaluate each color pair against WCAG requirements and flag combinations that fail. Group failures by severity: below 3:1 is a critical failure regardless of text size, 3:1 to 4.5:1 fails for normal text but passes large text.

A typical output helps you triage instantly:

```
PASS [14.73:1] Body text. #1a1a1a on #ffffff
FAIL [4.18:1] Muted text. #6b7280 on #ffffff ← fails AA normal text
PASS [8.59:1] Links. #2563eb on #ffffff
PASS [4.52:1] Button label. #ffffff on #2563eb
FAIL [3.96:1] Error messages. #dc2626 on #fff7f7 ← fails AA normal text
FAIL [2.42:1] Placeholders. #9ca3af on #ffffff ← critical failure
```

For each failure, prompt Claude to suggest alternative hex values that preserve the visual intent while reaching the required threshold. A muted gray that fails at 4.18:1 can often be darkened by a single step. for example, `#6b7280` to `#5a6475`. to clear the 4.5:1 bar without visually disrupting the design.

## Step 3: Integrate Automated Testing

Incorporate contrast checking into your test suite using the tdd skill. Create visual regression tests that capture contrast failures:

```javascript
import { checkContrast } from 'axe-core';

describe('Color Contrast Compliance', () => {
 it('primary text meets WCAG AA requirements', async () => {
 const violations = await checkContrast();
 const failures = violations.filter(v =>
 v.impact === 'serious' || v.impact === 'critical'
 );

 expect(failures).toHaveLength(0);
 });
});
```

For component-level testing with Playwright or Cypress, you can target specific rendered elements:

```javascript
// Using Playwright + axe-playwright
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('login form passes contrast checks', async ({ page }) => {
 await page.goto('/login');

 const accessibilityScanResults = await new AxeBuilder({ page })
 .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
 .analyze();

 const contrastViolations = accessibilityScanResults.violations.filter(
 v => v.id === 'color-contrast'
 );

 expect(contrastViolations).toEqual([]);
});
```

This gives you component-scoped failures with CSS selectors pointing to the exact elements that fail. When the test output reads `button.btn-secondary > span` you know exactly what to fix without hunting through markup.

Run these tests in your CI pipeline to prevent accessibility regressions. The super-memory skill can track historical contrast test results, helping you identify patterns in where violations typically occur.

## Step 4: Generate Comprehensive Reports

For stakeholder communication and documentation, generate detailed contrast audit reports. Use the pdf skill to create professional documents:

```markdown
Color Contrast Audit Report

Executive Summary
Total color pairs checked: 47
Passing: 38 (81%)
Failing: 9 (19%)

Critical Failures
[Detailed table of failing combinations with suggested fixes]

Recommendations
[Prioritized list of remediation steps]
```

Claude Code can generate these reports automatically after running contrast analysis, saving hours of manual documentation work.

When presenting to design teams, include before/after hex swatches alongside the numeric ratios. Designers respond better to seeing the proposed fix visually than to a raw number. Ask Claude to format the audit table with columns for current value, proposed value, and the visual difference in plain language. for example, "3% darker, perceptually similar."

A complete report table might look like:

| Element | Current | Ratio | Proposed Fix | New Ratio | Impact |
|---------|---------|-------|--------------|-----------|--------|
| Muted text | #6b7280 on #fff | 4.18:1 | #5a6475 on #fff | 4.71:1 | Low visual change |
| Error label | #dc2626 on #fff7f7 | 3.96:1 | #b91c1c on #fff7f7 | 5.08:1 | Slightly darker red |
| Placeholder | #9ca3af on #fff | 2.42:1 | #6b7280 on #fff | 4.18:1 | Noticeable darkening |

## Step 5: Continuous Monitoring

Implement pre-commit hooks that block code with obvious contrast violations:

```bash
.git/hooks/pre-commit
npx @axe-core/cli https://localhost:3000 --exit
```

For more targeted pre-commit checks scoped to changed CSS files, use a lint-staged configuration:

```json
{
 "lint-staged": {
 "*.{css,scss}": ["node scripts/check-contrast.js"],
 "*.{ts,tsx}": ["npx axe-lint"]
 }
}
```

The `check-contrast.js` script can parse the changed files for new color values and run them through your contrast calculator before allowing the commit to proceed. This is faster than spinning up a full browser for every save and catches hardcoded color errors at the source.

For design systems, create living documentation that specifies approved color combinations. The frontend-design skill can generate these guidelines automatically based on your project's color palette and WCAG requirements.

A well-maintained design system documents approved pairs explicitly:

```css
/* APPROVED. 14.73:1. body text */
.text-primary { color: #1a1a1a; }

/* APPROVED. 8.59:1. inline links */
.text-link { color: #2563eb; }

/* APPROVED. 4.71:1. secondary/muted text (minimum compliant) */
.text-muted { color: #5a6475; }

/* DO NOT USE on white backgrounds. fails AA */
/* .text-placeholder-old { color: #9ca3af; } */
```

Keeping deprecated token aliases in comments (with clear warnings) prevents regressions when developers copy old code snippets.

## Handling Dynamic Content

Color contrast checking becomes more complex with dynamic content. User-generated content, dark mode switches, and theme variations multiply the number of color combinations to verify. Address this through:

1. Theme matrices: Test all color scheme combinations (light/dark, high contrast modes)
2. Content sampling: Check representative samples of user content types
3. Runtime validation: Implement client-side contrast checking that alerts users to problematic combinations

For dark mode specifically, many teams check light mode exhaustively and forget to re-audit the dark theme. Create a separate inventory pass for each theme:

```bash
Run axe against both themes in CI
playwright test --project=chromium contrast.spec.ts -- --theme=light
playwright test --project=chromium contrast.spec.ts -- --theme=dark
```

Pass the theme via query parameter or a cookie in the test setup, then run identical assertions against both. Teams often find that an 8:1 ratio in light mode drops to 2.8:1 in dark mode because the dark background color was chosen casually.

For user-generated content with custom colors (forum posts, rich text editors), you cannot pre-audit every combination. Instead, implement runtime clamping: intercept custom color assignments and only apply them if the computed contrast ratio clears 4.5:1 against the current background. A small utility function running on `input` events is enough:

```javascript
function isSafeTextColor(hexColor, backgroundHex) {
 const fg = parseHexToRgb(hexColor);
 const bg = parseHexToRgb(backgroundHex);
 return getContrastRatio(fg, bg) >= 4.5;
}

colorPicker.addEventListener('input', (e) => {
 const chosen = e.target.value;
 const bg = getComputedStyle(previewArea).backgroundColor;
 if (!isSafeTextColor(chosen, rgbToHex(bg))) {
 showWarning('This color is hard to read. Consider a darker shade.');
 }
});
```

## Common Pitfalls to Avoid

Several mistakes weaken color contrast checking workflows:

- Checking only primary brand colors while ignoring secondary variations
- Ignoring placeholder text, disabled states, and error messages
- Testing only in one browser or operating system
- Checking during development but not in production

A few less-obvious traps are worth calling out explicitly. Transparent backgrounds compound: `rgba(0, 0, 0, 0.5)` over white computes differently than over a light gray card. Always resolve alpha-composited colors to their actual rendered value before running the ratio calculation.

Font rendering differs by OS. macOS renders fonts with subpixel antialiasing that makes thin text look lighter than it actually is. Windows ClearType and Linux font hinting produce different perceived weights. For borderline ratios. anything between 4.5:1 and 5:1. budget extra margin rather than assuming the calculation perfectly matches perception on every platform.

Animated content introduces contrast windows. An entrance animation fading text from transparent to full opacity passes through low-contrast intermediate states. If the animation is slower than about 400ms and the intermediate state is visible, users with vestibular disorders or slow processing may try to read it mid-fade. Aim for contrast compliance throughout the entire keyframe sequence, not just the final state.

Addressing these gaps requires expanding your testing matrix and automating checks across environments.

## Measuring Success

Track your accessibility metrics over time. Aim for zero critical contrast failures in automated tests. Use Lighthouse accessibility scores as a baseline metric:

```bash
lhci autorun --config=lighthouserc.json
```

Supplement Lighthouse with a dedicated contrast dashboard. Store results from each CI run in a lightweight JSON file:

```json
{
 "run": "2026-03-21T09:12:00Z",
 "branch": "main",
 "totalPairs": 47,
 "passing": 47,
 "failing": 0,
 "lighthouseA11y": 98
}
```

Graphing these numbers over time reveals whether accessibility holds steady as new features ship. A single spike in failures on a release branch is an early warning that a design change broke something before it reaches production.

Teams that treat color contrast as a first-class quality metric. tracked in dashboards, blocked in CI, audited in design reviews. eliminate accessibility debt gradually rather than paying it back in panic before audits. Claude Code makes the automation lightweight enough that there is no reason to defer it.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-color-contrast-checking-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code WCAG Accessibility Audit Workflow](/claude-code-wcag-accessibility-audit-workflow/)
- [Claude Code Axe Accessibility Testing Guide](/claude-code-axe-accessibility-testing-guide/)
- [Claude Code Screen Reader Testing Workflow](/claude-code-screen-reader-testing-workflow/)
- [Claude Skills Guides Hub](/guides-hub/)
- [Claude Code for Val Town — Workflow Guide](/claude-code-for-val-town-workflow-guide/)
- [Claude Code for Unstructured IO — Guide](/claude-code-for-unstructured-io-workflow-guide/)
- [Claude Code for Oxc Compiler — Workflow Guide](/claude-code-for-oxc-compiler-workflow-guide/)
- [Claude Code for Helix Editor — Workflow Guide](/claude-code-for-helix-editor-workflow-guide/)
- [Claude Code for Inngest — Workflow Guide](/claude-code-for-inngest-workflow-guide/)
- [Claude Code for Just — Workflow Guide](/claude-code-for-just-command-runner-workflow-guide/)
- [Claude Code for Zed Editor — Workflow Guide](/claude-code-for-zed-editor-workflow-guide/)
- [Claude Code for StarRocks — Workflow Guide](/claude-code-for-starrocks-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


