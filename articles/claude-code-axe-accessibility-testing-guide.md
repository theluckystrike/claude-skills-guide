---

layout: default
title: "Claude Code Axe Accessibility Testing Guide"
description: "A practical guide to implementing Axe accessibility testing with Claude Code. Learn how to automate accessibility audits, integrate axe-core, and fix common WCAG violations using Claude skills."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-axe-accessibility-testing-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
---


# Claude Code Axe Accessibility Testing Guide

Automated accessibility testing has become essential for building inclusive web applications. Axe, the accessibility engine from Deque Systems, provides a powerful library for detecting accessibility violations directly in your development workflow. This guide demonstrates how to integrate axe accessibility testing with Claude Code using specialized skills and practical automation patterns.

## Understanding Axe and Accessibility Testing

Axe is an open-source accessibility testing engine that runs in browsers and CI/CD pipelines. It checks against WCAG 2.1, Section 508, and ARIA accessibility standards. The library offers over 100 accessibility rules covering common issues like missing alt text, improper heading hierarchy, color contrast failures, and keyboard navigation problems.

When combined with Claude Code, you can automate the entire accessibility testing lifecycle—from initial audit through remediation validation. The key is structuring your prompts effectively and using Claude skills designed for testing workflows.

## Setting Up Your Testing Environment

First, install the required dependencies in your project:

```bash
npm install --save-dev @axe-core/cli puppeteer
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
      console.log(`  - ${node.html}`);
    });
  });

  expect(accessibilityResults.violations).toHaveLength(0);
}
```

## Practical Workflow for Automated Audits

Integrate axe testing into your Claude Code workflow using these steps:

### 1. Initial Audit with Claude

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

### 2. Remediation with Claude Skills

Use `/pdf` skill to generate accessibility compliance reports for stakeholders. Combine with `/supermemory` to track accessibility debt across sprints:

```
Track these accessibility violations in supermemory with 
priority levels. Create entries for each violation with 
the component location and estimated fix time.
```

### 3. CI/CD Integration

Add axe testing to your continuous integration:

```yaml
# GitHub Actions workflow
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

## Common Axe Violations and Fixes

### Color Contrast Failures

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

### Missing ARIA Attributes

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

### Focus Management Issues

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

## Best Practices for Sustainable Accessibility

1. **Run tests locally before commits**: Catch issues early in development
2. **Use axe-core in component tests**: Test accessibility at the unit level
3. **Automate visual regression checks**: Combine with tools like Percy for visual a11y validation
4. **Document accessibility decisions**: Use /supermemory to track patterns and exceptions
5. **Prioritize critical violations**: Address critical and serious issues before minor ones

## Conclusion

Integrating axe accessibility testing with Claude Code transforms accessibility from a periodic audit into a continuous process. By using skills like `/frontend-design` for accessible component generation and `/tdd` for automated test creation, you build accessibility into your development DNA rather than treating it as an afterthought.

The key is starting simple—run an initial audit, fix critical violations, then expand your test coverage incrementally. Claude Code excels at translating technical axe output into specific, actionable fixes that developers can implement immediately.

## Related Reading

- [Claude Code WCAG Accessibility Audit Workflow](/claude-skills-guide/claude-code-wcag-accessibility-audit-workflow/) — WCAG is the standard axe tests against
- [Claude Code Aria Labels Implementation Guide](/claude-skills-guide/claude-code-aria-labels-implementation-guide/) — Fix the ARIA issues axe discovers
- [Claude Code Keyboard Navigation Testing Guide](/claude-skills-guide/claude-code-keyboard-navigation-testing-guide/) — Combine axe with keyboard nav testing
- [Claude TDD Skill: Test-Driven Development Workflow](/claude-skills-guide/claude-tdd-skill-test-driven-development-workflow/) — Run axe tests in your TDD workflow

Built by theluckystrike — More at [zovo.one](https://zovo.one)
