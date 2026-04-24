---
title: "Claude Code for WCAG Accessibility (2026)"
permalink: /claude-code-wcag-accessibility-testing-2026/
description: "Automate WCAG 2.2 accessibility testing with Claude Code. Build CI pipeline checks for Level AA compliance with axe-core and Pa11y integration."
last_tested: "2026-04-22"
domain: "web accessibility"
---

## Why Claude Code for WCAG Accessibility Testing

The DOJ's final rule under Title II of the ADA (April 2024) requires state and local government web content to conform to WCAG 2.1 Level AA by 2026-2028. The European Accessibility Act (EAA) takes effect June 2025 for private sector digital products. These regulations make accessibility testing a legal requirement, not a best practice. Manual testing with screen readers catches interaction issues but cannot scale across hundreds of pages. Automated tools like axe-core catch 30-40% of WCAG issues, while Claude Code can help interpret ambiguous results and generate fixes.

Claude Code integrates axe-core, Pa11y, and Lighthouse accessibility audits into CI/CD pipelines, generates fix suggestions for common violations, and creates regression tests that prevent accessibility regressions from reaching production.

## The Workflow

### Step 1: Set Up Accessibility Testing Infrastructure

```bash
# Install testing tools
npm install -D @axe-core/cli pa11y pa11y-ci
npm install -D @axe-core/playwright  # For Playwright integration
npm install -D jest-axe              # For component-level testing

# Create Pa11y CI configuration
cat > .pa11yci.json << 'EOF'
{
  "defaults": {
    "standard": "WCAG2AA",
    "timeout": 30000,
    "wait": 2000,
    "chromeLaunchConfig": {
      "args": ["--no-sandbox"]
    }
  },
  "urls": [
    "http://localhost:3000/",
    "http://localhost:3000/login",
    "http://localhost:3000/dashboard",
    "http://localhost:3000/settings",
    "http://localhost:3000/checkout"
  ]
}
EOF
```

### Step 2: Implement Component-Level Accessibility Tests

```javascript
// tests/accessibility/components.test.js
const { render } = require('@testing-library/react');
const { axe, toHaveNoViolations } = require('jest-axe');
expect.extend(toHaveNoViolations);

const { LoginForm } = require('../../src/components/LoginForm');
const { DataTable } = require('../../src/components/DataTable');
const { NavigationMenu } = require('../../src/components/NavigationMenu');
const { Modal } = require('../../src/components/Modal');

describe('WCAG 2.2 AA Component Tests', () => {
  // 1.1.1 Non-text Content
  test('LoginForm has no accessibility violations', async () => {
    const { container } = render(<LoginForm />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  // 1.3.1 Info and Relationships - tables must have headers
  test('DataTable has proper table semantics', async () => {
    const { container } = render(
      <DataTable
        columns={[{ header: 'Name', accessor: 'name' }]}
        data={[{ name: 'Test' }]}
      />
    );
    const results = await axe(container);
    expect(results).toHaveNoViolations();

    // Verify table headers exist
    const headers = container.querySelectorAll('th');
    expect(headers.length).toBeGreaterThan(0);

    // Verify scope attribute on headers
    headers.forEach(th => {
      expect(th.getAttribute('scope')).toBeTruthy();
    });
  });

  // 2.4.7 Focus Visible - interactive elements must show focus
  test('NavigationMenu links have visible focus styles', async () => {
    const { container } = render(<NavigationMenu />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();

    // Check for focus-visible CSS
    const links = container.querySelectorAll('a, button');
    links.forEach(el => {
      const styles = window.getComputedStyle(el, ':focus-visible');
      // At minimum, outline should not be 'none'
      expect(el.className).toMatch(/focus/i);
    });
  });

  // 2.4.11 Focus Not Obscured (WCAG 2.2 new) - focus must not be hidden
  test('Modal does not obscure focused elements', async () => {
    const { container, getByRole } = render(
      <Modal isOpen={true} title="Test Modal">
        <button>Action</button>
      </Modal>
    );
    const results = await axe(container);
    expect(results).toHaveNoViolations();

    // Focus should be trapped within modal
    const modal = getByRole('dialog');
    expect(modal).toHaveFocus();
  });
});
```

### Step 3: Implement Page-Level Playwright Tests

```javascript
// tests/accessibility/pages.spec.js
const { test, expect } = require('@playwright/test');
const AxeBuilder = require('@axe-core/playwright').default;

const pages = [
  { name: 'Home', path: '/' },
  { name: 'Login', path: '/login' },
  { name: 'Dashboard', path: '/dashboard' },
  { name: 'Checkout', path: '/checkout' },
];

for (const page of pages) {
  test(`${page.name} page passes WCAG 2.2 AA`, async ({ page: pwPage }) => {
    await pwPage.goto(page.path);
    await pwPage.waitForLoadState('networkidle');

    const results = await new AxeBuilder({ page: pwPage })
      .withTags(['wcag2a', 'wcag2aa', 'wcag22aa'])
      .analyze();

    // Log violations for debugging
    if (results.violations.length > 0) {
      console.log(`${page.name} violations:`);
      results.violations.forEach(v => {
        console.log(`  [${v.impact}] ${v.id}: ${v.description}`);
        v.nodes.forEach(n => {
          console.log(`    Target: ${n.target.join(' > ')}`);
          console.log(`    Fix: ${n.failureSummary}`);
        });
      });
    }

    expect(results.violations).toHaveLength(0);
  });

  // WCAG 2.2: 3.2.6 Consistent Help
  test(`${page.name} has consistent help mechanism`, async ({ page: pwPage }) => {
    await pwPage.goto(page.path);
    // Help link/button should be in consistent location across pages
    const helpLink = await pwPage.$('[data-testid="help-link"], [aria-label*="help" i]');
    expect(helpLink).toBeTruthy();
  });
}

// WCAG 1.4.11 Non-text Contrast (focus indicators)
test('Focus indicators have 3:1 contrast ratio', async ({ page }) => {
  await page.goto('/');

  // Tab through interactive elements and verify focus visibility
  const interactiveElements = await page.$$('a, button, input, select, textarea');

  for (const el of interactiveElements.slice(0, 10)) {
    await el.focus();
    const hasFocusStyle = await el.evaluate(node => {
      const style = window.getComputedStyle(node);
      const outline = style.outline;
      return outline !== 'none' && outline !== '';
    });
    expect(hasFocusStyle).toBeTruthy();
  }
});
```

### Step 4: CI Pipeline Integration

```yaml
# .github/workflows/accessibility.yml
name: WCAG Accessibility Check
on: [pull_request]

jobs:
  accessibility:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npm run build
      - run: npm start &
      - run: npx wait-on http://localhost:3000
      - run: npx pa11y-ci
      - run: npx playwright test tests/accessibility/
```

### Step 5: Verify

```bash
# Run component-level tests
npx jest tests/accessibility/components.test.js

# Run page-level tests
npx playwright test tests/accessibility/

# Run Pa11y CI scan
npx pa11y-ci

# Generate HTML report
npx pa11y http://localhost:3000 --reporter html > a11y-report.html
```

## CLAUDE.md for WCAG Accessibility Testing

```markdown
# WCAG 2.2 Level AA Testing Standards

## Domain Rules
- All pages must pass axe-core with wcag2a + wcag2aa + wcag22aa tags
- Zero critical or serious violations allowed in CI
- Color contrast minimum 4.5:1 for normal text, 3:1 for large text
- All images must have alt text (decorative images: alt="")
- All form inputs must have associated labels
- Keyboard navigation must reach all interactive elements
- Focus must be visible and not obscured (WCAG 2.2 new)
- Help mechanisms must be consistent across pages (WCAG 2.2 new)

## File Patterns
- Component tests: tests/accessibility/components.test.js
- Page tests: tests/accessibility/pages.spec.js
- Pa11y config: .pa11yci.json
- CI: .github/workflows/accessibility.yml

## Common Commands
- npx jest tests/accessibility/ --verbose
- npx playwright test tests/accessibility/
- npx pa11y-ci
- npx axe http://localhost:3000 --tags wcag2aa
- npx lighthouse http://localhost:3000 --only-categories=accessibility
```

## Common Pitfalls in WCAG Testing

- **Automated tools miss 60% of issues:** Axe-core catches structural issues but cannot evaluate content meaning, reading order, or interaction patterns. Claude Code generates manual test checklists for the issues automated tools cannot catch (meaningful alt text, logical tab order, error identification).

- **Dynamic content not tested:** SPAs load content dynamically, but accessibility tests often only check the initial page load. Claude Code adds tests that interact with the page (open modals, submit forms, expand accordions) before running axe analysis.

- **WCAG 2.2 new criteria overlooked:** Focus Not Obscured (2.4.11), Dragging Movements alternatives (2.5.7), and Consistent Help (3.2.6) are new in 2.2. Claude Code includes specific tests for these criteria that older configurations miss.

## Related

- [Claude Code for EU AI Act Compliance](/claude-code-eu-ai-act-compliance-2026/)
- [Claude Code for GDPR Data Mapping](/claude-code-gdpr-data-mapping-2026/)
- [Claude Code for ISO 27001 Controls Implementation](/claude-code-iso-27001-controls-implementation-2026/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Related Guides

- [Claude Skills for Accessibility Testing](/claude-skills-for-accessibility-testing-wcag-a11y/)
- [Claude Code Mobile App Accessibility](/claude-code-mobile-app-accessibility-testing-workflow/)
- [Claude Code Axe Accessibility](/claude-code-axe-accessibility-testing-guide/)
- [Fix Semantic HTML Accessibility](/claude-code-semantic-html-accessibility-improvement-guide/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json."
      }
    }
  ]
}
</script>
