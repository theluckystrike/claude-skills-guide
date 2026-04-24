---
layout: default
title: "Claude Code Axe Accessibility"
description: "Automate accessibility audits with axe-core and Claude Code. Fix common WCAG violations using Claude skills. Includes code examples and fixes."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-axe-accessibility-testing-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
last_tested: "2026-04-22"
---
Automated accessibility testing has become essential for building inclusive web applications. Axe, the accessibility engine from Deque Systems, provides a powerful library for detecting accessibility violations directly in your development workflow. This guide demonstrates how to integrate axe accessibility testing with Claude Code using specialized skills and practical automation patterns.

## Understanding Axe and Accessibility Testing

Axe is an open-source accessibility testing engine that runs in browsers and CI/CD pipelines. It checks against WCAG 2.1, Section 508, and ARIA accessibility standards. The library offers over 100 accessibility rules covering common issues like missing alt text, improper heading hierarchy, color contrast failures, and keyboard navigation problems.

When combined with Claude Code, you can automate the entire accessibility testing lifecycle, from initial audit through remediation validation. The key is structuring your prompts effectively and using Claude skills designed for testing workflows.

Axe operates in three modes: browser extensions for manual audits, JavaScript library injection for automated testing, and CLI tools for headless pipeline integration. Each mode serves a different part of the workflow. Browser extensions are useful for quick spot-checks during development. The JavaScript library integrates with Playwright, Puppeteer, WebdriverIO, and testing frameworks like Jest and Vitest. The CLI tool handles CI/CD scenarios where you need to fail builds on violations.

Understanding axe's violation severity levels is critical for prioritization. Critical violations block screen reader users entirely, examples include interactive elements with no accessible name, or form fields with no associated labels. Serious violations make tasks significantly harder but not impossible. Moderate and minor violations create friction and should be resolved but rarely block work entirely. A practical strategy is to set your CI/CD pipeline to fail on critical and serious, track moderate in your backlog, and fix minor violations as you touch related code.

## Setting Up Your Testing Environment

First, install the required dependencies in your project:

```bash
npm install --save-dev @axe-core/cli puppeteer
```

For projects using Playwright (recommended for modern setups):

```bash
npm install --save-dev @axe-core/playwright playwright
```

Create a basic axe audit script:

```javascript
const { crawl } = require('@axe-core/cli');
const fs = require('fs');

async function runAccessibilityAudit(url) {
 const results = await crawl({
 urls: [url],
 playwright: true,
 browser: 'chromium'
 });

 const violations = results[0].violations;
 const critical = violations.filter(v => v.impact === 'critical');
 const serious = violations.filter(v => v.impact === 'serious');

 console.log(`Found ${violations.length} accessibility violations`);
 console.log(`Critical: ${critical.length}, Serious: ${serious.length}`);

 fs.writeFileSync(
 'a11y-report.json',
 JSON.stringify(results, null, 2)
 );

 return violations;
}

runAccessibilityAudit(process.argv[2] || 'http://localhost:3000');
```

For a Playwright-based setup that integrates directly into your test suite:

```javascript
const { chromium } = require('playwright');
const AxeBuilder = require('@axe-core/playwright').default;

async function auditPage(url) {
 const browser = await chromium.launch();
 const page = await browser.newPage();
 await page.goto(url);

 const results = await new AxeBuilder({ page })
 .withTags(['wcag2a', 'wcag2aa', 'wcag21aa'])
 .analyze();

 await browser.close();
 return results;
}
```

The Playwright integration is preferred over raw Puppeteer because Playwright handles authentication flows, dynamic content rendering, and multi-page navigation more reliably. When testing applications that require login, you can authenticate first, then run the audit on protected pages.

## Using Claude Code Skills for Accessibility

The `/frontend-design` skill helps generate accessible components from the start. When starting a new component, prompt Claude with explicit accessibility requirements:

```
Using /frontend-design, create a form with proper label associations,
error messaging with aria-live regions, and keyboard-navigable
focus states. Include proper heading hierarchy.
```

The `/tdd` skill accelerates writing accessibility test cases. Pair it with axe-core to create regression tests:

```javascript
const AxeBuilder = require('@axe-core/webdriverjs');
const { By } = require('selenium-webdriver');

async function accessibilitySpec(driver) {
 const accessibilityResults = await new AxeBuilder(driver)
 .withTags(['wcag2a', 'wcag2aa', 'wcag21aa'])
 .analyze();

 accessibilityResults.violations.forEach(violation => {
 console.log(`${violation.id}: ${violation.description}`);
 violation.nodes.forEach(node => {
 console.log(` - ${node.html}`);
 });
 });

 expect(accessibilityResults.violations).toHaveLength(0);
}
```

When using Claude to analyze axe output, paste the raw JSON violations array into your prompt rather than summarizing it. Claude can read the full structure, including the `nodes[].failureSummary` and `nodes[].target` selectors, and provide targeted fixes for each specific element. A prompt like "Fix these axe violations: [paste JSON]" produces more precise recommendations than "I have some accessibility violations."

You can also use Claude to write targeted axe configurations. If your project uses third-party components that intentionally fail certain rules (for example, a legacy date picker you cannot modify), Claude can generate rule exclusions that suppress known false positives without hiding real problems:

```javascript
const results = await new AxeBuilder({ page })
 .withTags(['wcag2a', 'wcag2aa'])
 .exclude('#legacy-date-picker') // third-party, pending replacement
 .disableRules(['color-contrast']) // overridden by brand team, tracked separately
 .analyze();
```

Document every exclusion with a comment explaining why it exists. Claude is good at generating these explanatory comments when you provide the business context.

## Practical Workflow for Automated Audits

Integrate axe testing into your Claude Code workflow using these steps:

1. Initial Audit with Claude

Ask Claude Code to run an accessibility audit:

```
Run an axe accessibility audit on the login page at
http://localhost:3000/login. Focus on critical and serious
violations. List each violation with its WCAG criterion
and provide fix recommendations.
```

Claude can analyze the JSON output and translate technical violations into actionable fixes:

```javascript
// Example: Fixing missing form labels
// Before
<input type="email" placeholder="Email">

// After
<label for="email">Email address</label>
<input type="email" id="email" placeholder="name@example.com"
 aria-describedby="email-hint">
<span id="email-hint" class="hint">We'll send a verification link</span>
```

A common mistake is relying on `placeholder` as a substitute for a visible label. Screen readers do not consistently announce placeholder text. The fix above adds a visible label (which also benefits sighted users) and adds a hint linked via `aria-describedby` for additional context. This pattern satisfies WCAG 1.3.1 (Info and Relationships) and 3.3.2 (Labels or Instructions).

2. Remediation with Claude Skills

Use `/pdf` skill to generate accessibility compliance reports for stakeholders. Combine with `/supermemory` to track accessibility debt across sprints:

```
Track these accessibility violations in supermemory with
priority levels. Create entries for each violation with
the component location and estimated fix time.
```

When remediating a backlog of violations, group them by component rather than by rule type. Fixing all violations in the navigation component at once is more efficient than fixing all `aria-required-attr` violations across unrelated components. Ask Claude to group violations by component, then generate targeted fix batches.

3. CI/CD Integration

Add axe testing to your continuous integration:

```yaml
GitHub Actions workflow
- name: Accessibility Audit
 run: |
 npm run start &
 sleep 5
 node audit.js http://localhost:3000
 npx axe-cli http://localhost:3000 --exit
```

Configure axe-cli to fail builds on critical violations:

```javascript
// cli-config.json
{
 "axeVersion": "4.9.0",
 "tags": ["wcag2a", "wcag2aa", "wcag21aa"],
 "runOnly": {
 "type": "tag",
 "values": ["wcag2aa"]
 },
 "threshold": {
 "fails": 1,
 "passes": 95
 }
}
```

A more practical CI configuration gates on impact level rather than total count. This prevents noise from low-priority violations blocking deployments:

```bash
Only fail on critical and serious violations
node -e "
const report = require('./a11y-report.json');
const blocking = report[0].violations.filter(v =>
 v.impact === 'critical' || v.impact === 'serious'
);
if (blocking.length > 0) {
 console.error('Blocking accessibility violations found:');
 blocking.forEach(v => console.error(' -', v.id, ':', v.description));
 process.exit(1);
}
console.log('No blocking violations. Moderate/minor tracked separately.');
"
```

## Common Axe Violations and Fixes

## Color Contrast Failures

Axe frequently flags contrast ratio issues. Use Claude to suggest fixes:

```css
/* Failing: 2.8:1 contrast ratio */
.button-primary {
 background: #9c27b0;
 color: #e1bee7;
}

/* Fixed: 7.1:1 contrast ratio */
.button-primary {
 background: #6a1b9a;
 color: #ffffff;
}
```

When working with design systems, contrast failures often originate in color token definitions rather than individual component styles. Ask Claude to audit your color tokens directly and generate a contrast matrix showing which foreground/background combinations are safe. This prevents re-testing the same token pairs across every component that uses them.

| Token Combination | Ratio | WCAG AA (4.5:1) | WCAG AAA (7:1) |
|---|---|---|---|
| `--color-text` on `--color-bg` | 12.1:1 | Pass | Pass |
| `--color-muted` on `--color-bg` | 3.9:1 | Fail | Fail |
| `--color-primary` on `--color-bg` | 5.2:1 | Pass | Fail |
| `--color-warning` on `--color-bg` | 2.1:1 | Fail | Fail |

Catching a failing token at the design system level is significantly more efficient than fixing it in dozens of individual components.

## Missing ARIA Attributes

Dynamic content requires proper ARIA handling:

```javascript
// Before: No state announcement
function toggleDropdown() {
 dropdown.classList.toggle('open');
}

// After: Proper ARIA state
function toggleDropdown() {
 const isOpen = dropdown.getAttribute('aria-expanded') === 'true';
 dropdown.setAttribute('aria-expanded', !isOpen);
 dropdown.classList.toggle('open');
}
```

The `aria-expanded` pattern applies to any disclosure widget: accordions, dropdowns, tree views, and collapsible navigation items. When you add `aria-expanded`, the trigger element must also have an accessible name that describes what it controls. For a button that opens a navigation menu, this might look like:

```html
<button
 aria-expanded="false"
 aria-controls="main-nav"
 aria-label="Toggle main navigation">
 <svg aria-hidden="true"><!-- hamburger icon --></svg>
</button>
<nav id="main-nav" hidden>
 <!-- navigation links -->
</nav>
```

The `aria-controls` attribute links the button to the element it controls, which helps screen reader users understand the relationship even without visual context.

## Focus Management Issues

Ensure proper focus handling for modal dialogs:

```javascript
function openModal(modalElement) {
 modalElement.removeAttribute('hidden');
 modalElement.setAttribute('role', 'dialog');
 modalElement.setAttribute('aria-modal', 'true');

 // Focus the modal container or first focusable element
 const focusable = modalElement.querySelector(
 'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
 );
 if (focusable) {
 focusable.focus();
 } else {
 modalElement.focus();
 }

 // Trap focus within modal
 trapFocus(modalElement);
}
```

Focus management has two sides: moving focus in when the modal opens, and returning focus out when it closes. Always store a reference to the element that triggered the modal open, then restore focus to it on close:

```javascript
let previousFocus = null;

function openModal(modalElement, triggerElement) {
 previousFocus = triggerElement || document.activeElement;
 modalElement.removeAttribute('hidden');
 // ... set attributes, move focus in
}

function closeModal(modalElement) {
 modalElement.setAttribute('hidden', '');
 if (previousFocus) {
 previousFocus.focus();
 previousFocus = null;
 }
}
```

Without this, keyboard users lose their place in the page after dismissing a modal, they land at the top of the document and must tab through everything again to return to where they were.

## Landmark Region Violations

Axe also checks for missing landmark regions. Pages without proper landmarks force screen reader users to navigate linearly through every element to find content. A complete landmark structure looks like:

```html
<header role="banner">
 <nav aria-label="Main navigation">...</nav>
</header>
<main id="main-content">
 <h1>Page Title</h1>
 <!-- primary content -->
</main>
<aside aria-label="Related articles">...</aside>
<footer role="contentinfo">...</footer>
```

If your page has multiple navigation elements (main nav plus breadcrumbs, for example), each needs a unique `aria-label` to distinguish them. Axe flags duplicate landmark roles without distinguishing labels as a violation.

## Comparing Axe Against Other Testing Tools

Axe is not the only automated accessibility testing tool, and understanding its strengths and limitations helps you build a complete testing strategy.

| Tool | What It Covers | Integration |
|---|---|---|
| axe-core | WCAG 2.1 rule-based checks | Browser, Node.js, CI |
| Lighthouse | Accessibility + performance audit | Chrome DevTools, CLI |
| Pa11y | CLI-first, axe + htmlcs rules | CI/CD pipelines |
| WAVE | Visual overlay for manual review | Browser extension |
| IBM Equal Access | Alternative rule set, IBM standard | Browser, CI |

Automated tools collectively catch about 30-40% of WCAG violations. The remaining violations require manual testing: checking tab order makes logical sense, verifying that screen reader announcements are meaningful, testing with real assistive technologies like NVDA, JAWS, or VoiceOver. Use axe as your automated baseline, then layer manual testing on top for complete coverage.

## Best Practices for Sustainable Accessibility

1. Run tests locally before commits: Catch issues early in development
2. Use axe-core in component tests: Test accessibility at the unit level
3. Automate visual regression checks: Combine with tools like Percy for visual a11y validation
4. Document accessibility decisions: Use /supermemory to track patterns and exceptions
5. Prioritize critical violations: Address critical and serious issues before minor ones
6. Test with real users: Automated tools cannot replace testing with people who use assistive technology
7. Establish a baseline early: Running axe on a new project before writing any code gives you a clean baseline to maintain; retrofitting accessibility on legacy code is significantly harder
8. Keep axe-core updated: New rules are added regularly; updating the library can surface violations in previously clean code, which is worth catching early

## Conclusion

Integrating axe accessibility testing with Claude Code transforms accessibility from a periodic audit into a continuous process. By using skills like `/frontend-design` for accessible component generation and `/tdd` for automated test creation, you build accessibility into your development DNA rather than treating it as an afterthought.

The key is starting simple, run an initial audit, fix critical violations, then expand your test coverage incrementally. Claude Code excels at translating technical axe output into specific, actionable fixes that developers can implement immediately.

As your testing matures, extend your axe setup to cover authenticated pages, dynamic content loaded after interaction, and third-party embedded components. The combination of automated axe coverage in CI, manual spot-checks in the browser extension, and Claude-assisted remediation creates a workflow that keeps accessibility issues from accumulating into an unmanageable backlog.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-axe-accessibility-testing-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code WCAG Accessibility Audit Workflow](/claude-code-wcag-accessibility-audit-workflow/). WCAG is the standard axe tests against
- [Claude Code Aria Labels Implementation Guide](/claude-code-aria-labels-implementation-guide/). Fix the ARIA issues axe discovers
- [Claude Code Keyboard Navigation Testing Guide](/claude-code-keyboard-navigation-testing-guide/). Combine axe with keyboard nav testing
- [Claude TDD Skill: Test-Driven Development Workflow](/claude-tdd-skill-test-driven-development-workflow/). Run axe tests in your TDD workflow
- [Claude Code for Percy Visual Testing Workflow Guide](/claude-code-for-percy-visual-testing-workflow-guide/)
- [Claude Code for Runbook Testing Workflow Tutorial](/claude-code-for-runbook-testing-workflow-tutorial/)
- [Claude Code for Soak Testing Workflow Tutorial Guide](/claude-code-for-soak-testing-workflow-tutorial-guide/)
- [How to Use Claude Code with Jest Testing](/claude-code-with-jest-testing-workflow/)
- [React Component Testing with Claude Code](/claude-code-react-component-testing-guide/)
- [Claude Code for Browser Mode Testing — Guide](/claude-code-for-browser-mode-testing-workflow-guide/)
- [Claude Code Shift Left Testing Strategy Guide](/claude-code-shift-left-testing-strategy-guide/)
- [Claude Code for Load Testing with Locust Workflow Guide](/claude-code-for-load-testing-with-locust-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


