---
layout: default
title: "Claude Code WCAG Accessibility Audit Workflow"
description: "Build a practical WCAG accessibility audit workflow using Claude Code skills. Practical examples, automated checks, and remediation guidance for developers."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, wcag, accessibility, a11y, audit, workflow]
author: theluckystrike
reviewed: true
score: 7
permalink: /claude-code-wcag-accessibility-audit-workflow/
---

# Claude Code WCAG Accessibility Audit Workflow

Web accessibility ensures that people with disabilities can perceive, understand, navigate, and interact with your digital products. The Web Content Accessibility Guidelines (WCAG) provide a comprehensive framework with success criteria across four principles: Perceivable, Operable, Understandable, and Robust (POUR). This guide shows you how to leverage Claude Code skills to build an automated accessibility audit workflow.

## Setting Up Your Accessibility Skills

Claude Code supports accessibility-focused skills that guide the auditing process. The primary skill you'll use is `/frontend-design`, which includes accessibility considerations in component generation. For comprehensive audits, pair this with the `/tdd` skill to create test cases for accessibility requirements.

Your skill setup directory should include:

```
~/.claude/skills/
├── frontend-design.md
├── tdd.md
└── pdf.md
```

Each skill is a Markdown file that Claude loads when you invoke its slash command. The `/frontend-design` skill ensures new components follow WCAG patterns from the start, while `/tdd` helps you write tests that verify accessibility behavior.

## Creating an Accessibility Audit Checklist

Before auditing, establish a checklist based on WCAG 2.1 Level AA compliance—the standard most projects target. Your checklist should cover:

**Perceivable**
- Text alternatives for images (1.1.1)
- Captions for video content (1.2.1-1.2.5)
- Color contrast ratios of 4.5:1 for normal text (1.4.3)
- Resizable text without loss of functionality (1.4.4)

**Operable**
- Keyboard accessibility for all interactive elements (2.1.1)
- No keyboard traps (2.1.2)
- Skip navigation links (2.4.1)
- Page titles that describe purpose (2.4.2)

**Understandable**
- Language specification in HTML (3.1.1)
- Consistent navigation (3.2.3)
- Error identification and suggestions (3.3.1-3.3.2)

**Robust**
- Valid HTML parsing (4.1.1)
- Name, role, and value for custom components (4.1.2)

## Automated Testing with Axe and Claude

Integrate automated accessibility testing into your development workflow. Install axe-core for runtime analysis:

```bash
npm install --save-dev @axe-core/cli
```

Create a test file that Claude can help you write using the `/tdd` skill:

```javascript
// tests/accessibility/homepage.a11y.test.js
import { chromium } from 'playwright';
import axe from 'axe-core';

describe('Homepage Accessibility', () => {
  it('should pass axe-core accessibility checks', async () => {
    const browser = await chromium.launch();
    const page = await browser.newPage();
    
    await page.goto('http://localhost:3000');
    
    const results = await page.evaluate(() => {
      return axe.run();
    });
    
    // Fail if there are critical violations
    const criticalViolations = results.violations.filter(
      v => v.impact === 'critical'
    );
    
    expect(criticalViolations).toHaveLength(0);
    
    await browser.close();
  });
});
```

When you need to expand your test coverage, invoke the `/tdd` skill in Claude Code and describe the component you want tested. Claude will generate test cases that verify accessibility behavior.

## Manual Audit Workflow with Claude

Automated testing catches only about 30-40% of accessibility issues. For the remainder, use Claude to guide your manual audit. Here's a practical workflow:

**Step 1: Generate audit script**
Tell Claude what you're auditing:

```
/frontend-design
Review this React component for WCAG 2.1 Level AA compliance. Check for:
- Missing alt text on images
- Improper heading hierarchy (h1-h6 sequence)
- Missing form labels
- Insufficient color contrast
- Keyboard trap issues
```

**Step 2: Document findings**
Create an accessibility report structure:

```markdown
# Accessibility Audit Report - [Page Name]

## Critical Issues
| Issue | WCAG Criterion | Location | Remediation |
|-------|---------------|----------|-------------|
| Missing alt on logo | 1.1.1 | header.jsx:15 | Add alt="Company Name" |

## Moderate Issues
| Issue | WCAG Criterion | Location |
|-------|---------------|----------|
| Low contrast button | 1.4.3 | cta.jsx:42 |

## Recommendations
- Add skip navigation link
- Implement focus indicators
```

**Step 3: Prioritize remediation**
Focus on fixing critical issues first—the ones that prevent users from accessing content entirely. Moderate issues affect the experience but don't block access entirely.

## Using the PDF Skill for Reports

After completing your audit, generate a formal report using the `/pdf` skill. This is useful for documentation, stakeholder sharing, or compliance records:

```markdown
# Accessibility Audit Report
## [Project Name]
## Date: [Audit Date]
## Auditor: [Name]

### Executive Summary
[Summary of findings]

### Critical Violations
[List with WCAG references]

### Remediation Plan
[Priority-ordered fixes]
```

Invoke `/pdf` in Claude Code and provide your audit data. Claude will format it into a professional PDF document.

## Integrating Accessibility into CI/CD

Automate accessibility checks in your continuous integration pipeline:

```yaml
# .github/workflows/accessibility.yml
name: Accessibility Checks

on: [push, pull_request]

jobs:
  a11y-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build application
        run: npm run build
      
      - name: Run accessibility tests
        run: npm test -- --testPathPattern=a11y
      
      - name: Upload accessibility report
        uses: actions/upload-artifact@v4
        with:
          name: a11y-report
          path: reports/accessibility/
```

This workflow runs your accessibility tests on every push and pull request, catching regressions before they reach production.

## Combining Skills for Comprehensive Audits

The real power comes from combining multiple Claude skills:

- Use `/frontend-design` when building new components—they'll be accessible by default
- Use `/tdd` to create regression tests for accessibility fixes
- Use `/supermemory` to store your organization's accessibility patterns so Claude remembers them across sessions
- Use `/pdf` to generate formal audit reports for stakeholders

Each skill operates independently but works well together. You can invoke multiple skills in a single Claude Code session.

## Common Accessibility Issues and Fixes

Here are frequent issues Claude helps identify and fix:

**Missing form labels**
```jsx
// Before (inaccessible)
<input type="email" placeholder="Email">

// After (accessible)
<label for="email">Email address</label>
<input type="email" id="email" placeholder="email@example.com">
```

**Improper heading hierarchy**
```jsx
// Before (confusing structure)
<h1>Welcome</h1>
<h3>About us</h3>

// After (logical structure)
<h1>Welcome</h1>
<h2>About us</h2>
```

**Poor color contrast**
```css
/* Before (fails WCAG) */
.button-primary {
  background-color: #999;
  color: #fff;
}

/* After (passes WCAG AA) */
.button-primary {
  background-color: #0056b3;
  color: #fff;
}
```

## Conclusion

Building a WCAG accessibility audit workflow with Claude Code combines automated testing, manual review guidance, and documentation generation. The `/frontend-design`, `/tdd`, `/pdf`, and `/supermemory` skills work together to create a comprehensive accessibility practice. Start with automated axe-core tests, use Claude to guide manual audits, and generate formal reports for stakeholders. By integrating accessibility checks into your CI/CD pipeline, you catch issues early and maintain compliance over time.

---

## Related Reading

- [Best Claude Skills for Frontend Development](/claude-skills-guide/best-claude-code-skills-for-frontend-development/) — Build accessible components from the start
- [Automated Testing Pipeline with Claude TDD Skill](/claude-skills-guide/automated-testing-pipeline-with-claude-tdd-skill-2026/) — Extend your test coverage
- [Claude Skills Token Optimization](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/) — Manage costs on large audits
- [Frontend Design Skill Complete Guide](/claude-skills-guide/best-claude-skills-for-developers-2026/) — Master accessibility-first component creation

Built by theluckystrike — More at [zovo.one](https://zovo.one)
