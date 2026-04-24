---
layout: default
title: "Claude Md For Accessibility"
description: "Learn how to use Claude Code skills to generate, audit, and maintain accessibility-compliant code. Practical examples for WCAG compliance, ARIA."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, accessibility, a11y, wcag, aria, keyboard-navigation, claude-skills]
author: "theluckystrike"
permalink: /claude-md-for-accessibility-requirements-a11y/
reviewed: true
score: 7
geo_optimized: true
---
## Claude MD for Accessibility Requirements: A Practical A11y Guide

Accessibility isn't a feature you bolt on at the end of development. It's a fundamental aspect of building inclusive web applications that serve all users, including those using assistive technologies like screen readers, voice control software, and switch access devices. The Web Content Accessibility Guidelines (WCAG) exist to provide a shared standard for making web content accessible, and failing to meet those standards exposes your project to both legal risk and a worse experience for a large portion of your users.

Claude Code, combined with well-designed skills, can help you integrate accessibility testing and implementation directly into your development workflow. Rather than treating WCAG compliance as an audit that happens before launch, you can bake it into every sprint from the very first commit.

This guide shows you how to use Claude MD skills to generate accessible markup, audit existing code for WCAG compliance, handle complex ARIA patterns, and maintain accessibility as your projects evolve.

## Why Accessibility Can't Be an Afterthought

Before diving into tooling, it's worth understanding the scale of the problem. According to the CDC, roughly 1 in 4 adults in the US has some type of disability. Many of these users rely on assistive technologies: screen readers like NVDA and VoiceOver, keyboard-only navigation, zoom software, and alternative input devices.

Beyond the ethical case, there is a legal one. The ADA, Section 508 (for US federal agencies), and the European Accessibility Act all carry real enforcement teeth. Court cases against major retailers, banks, and universities have resulted in multi-million-dollar settlements and mandatory remediation programs.

The cost argument is equally compelling. Fixing an accessibility defect in production costs 10–100x more than catching it in development. WCAG 2.1 Level AA is the baseline most organizations target. Level A covers the most critical failures; Level AAA is aspirational and not required for full compliance.

| WCAG Level | Scope | Typical Requirement |
|---|---|---|
| Level A | Essential | Images have alt text, forms have labels |
| Level AA | Standard | Color contrast 4.5:1, keyboard nav works |
| Level AAA | Enhanced | Live captions, sign language for video |

Claude skills help you hit Level AA reliably without needing an accessibility specialist on every pull request.

## Setting Up Accessibility-Focused Skills

Claude skills can be configured with specific tools and prompts that focus on accessibility requirements. The key is establishing a skill that understands WCAG 2.1 guidelines and can apply them to your codebase.

Here's a skill configuration focused on accessibility:

```yaml
---
name: a11y-audit
description: "Audit code for accessibility compliance"
---
```

When you invoke this skill, Claude analyzes your HTML, JavaScript, and CSS components through the lens of accessibility standards. It checks for proper semantic markup, ARIA labels, focus management, and color contrast.

A more complete skill definition might include system prompt instructions that tell Claude which WCAG version to target, whether you're building for Section 508, and any project-specific patterns to watch for:

```yaml
---
name: a11y-audit
description: "Audit code for WCAG 2.1 Level AA compliance"
systemPrompt: |
 You are an accessibility expert. When reviewing code:
 1. Flag any WCAG 2.1 Level AA violations with their criterion number
 2. Suggest specific remediation for each issue
 3. Prioritize issues by impact on users with disabilities
 4. Check semantic HTML, ARIA usage, focus management, and color contrast
---
```

With this skill active, you can ask Claude to review any component and receive structured feedback tied directly to WCAG criterion numbers, making it straightforward to document compliance status.

## Generating Accessible Components

One of the most practical applications of Claude skills for accessibility is component generation. Instead of writing accessible markup from scratch, you can prompt Claude to generate components that meet WCAG requirements by default.

Consider a modal dialog component. An inaccessible version might look like this:

```html
<div class="modal">
 <h2>Confirm Action</h2>
 <p>Are you sure you want to proceed?</p>
 <button>Cancel</button>
 <button>Confirm</button>
</div>
```

When you ask Claude to generate an accessible version using an accessibility-focused skill, it produces:

```html
<div role="dialog" aria-modal="true" aria-labelledby="modal-title" aria-describedby="modal-desc">
 <h2 id="modal-title">Confirm Action</h2>
 <p id="modal-desc">Are you sure you want to proceed?</p>
 <button aria-label="Cancel this action">Cancel</button>
 <button aria-label="Confirm this action">Confirm</button>
</div>
```

The difference is substantial. The accessible version includes `role="dialog"` to announce the component type to screen readers, `aria-modal="true"` to indicate focus isolation, `aria-labelledby` connecting the heading to the dialog, and descriptive `aria-label` attributes on buttons.

But there's more to a fully accessible modal than markup alone. Claude can also generate the JavaScript that manages focus correctly:

```javascript
function openModal(modalEl) {
 const focusableSelectors = [
 'button', '[href]', 'input', 'select', 'textarea',
 '[tabindex]:not([tabindex="-1"])'
 ];
 const focusableElements = modalEl.querySelectorAll(focusableSelectors.join(', '));
 const firstFocusable = focusableElements[0];
 const lastFocusable = focusableElements[focusableElements.length - 1];

 // Move focus into modal on open
 firstFocusable.focus();

 // Trap focus within modal
 modalEl.addEventListener('keydown', function trapFocus(e) {
 if (e.key !== 'Tab') return;
 if (e.shiftKey) {
 if (document.activeElement === firstFocusable) {
 e.preventDefault();
 lastFocusable.focus();
 }
 } else {
 if (document.activeElement === lastFocusable) {
 e.preventDefault();
 firstFocusable.focus();
 }
 }
 });

 // Close on Escape
 document.addEventListener('keydown', function handleEscape(e) {
 if (e.key === 'Escape') closeModal(modalEl);
 });
}
```

Without this focus management code, a screen reader user can Tab out of the modal and into the page behind it, a serious usability failure that the WCAG 2.1 criterion 2.1.2 (No Keyboard Trap) specifically addresses.

## Common ARIA Patterns and Where Developers Go Wrong

ARIA (Accessible Rich Internet Applications) is powerful but frequently misused. Claude's accessibility skills can audit for these common mistakes:

1. Using ARIA roles on the wrong elements

```html
<!-- Wrong: ARIA role does not override native semantics -->
<div role="button" onclick="submit()">Submit</div>

<!-- Right: use the native element with proper styling -->
<button type="submit">Submit</button>
```

2. Missing required ARIA properties

Some roles require companion attributes. A `role="combobox"` without `aria-expanded` will generate errors in accessibility tree inspectors:

```html
<!-- Incomplete -->
<input role="combobox" />

<!-- Complete -->
<input
 role="combobox"
 aria-expanded="false"
 aria-autocomplete="list"
 aria-controls="suggestion-list"
 aria-haspopup="listbox"
/>
```

3. Live regions not announcing updates

Dynamic content updates, search results, form validation errors, notifications, must be announced to screen readers. Without `aria-live`, users relying on screen readers will never know something changed:

```html
<!-- Screen readers won't announce this when it updates -->
<div id="status-message"></div>

<!-- Screen readers will announce updates politely -->
<div id="status-message" aria-live="polite" aria-atomic="true"></div>
```

Claude can scan your entire component library for these patterns and generate a prioritized report. Prompt it with your component directory and ask for an ARIA audit, you'll typically surface a dozen or more issues that automated tools like axe-core miss because they require understanding intent, not just syntax.

## Using the PDF Skill for Accessibility Documentation

Accessibility compliance requires thorough documentation. The PDF skill in Claude can help you generate accessibility statements, WCAG compliance reports, and VPAT (Voluntary Product Accessibility Template) documents.

When creating accessibility documentation, ensure you include:

- Conformance level (A, AA, or AAA)
- Specific WCAG success criteria addressed
- Known limitations and alternative navigation methods
- Contact information for accessibility support

The PDF skill can also extract text from existing PDF documents to audit them for accessibility, checking for proper tagging, reading order, and alternative text for images. Many organizations receive vendor PDFs that need to meet Section 508 standards before distribution, the PDF skill makes it possible to run these audits quickly at scale.

## Auditing JavaScript for Keyboard Navigation

JavaScript-heavy applications often break keyboard navigation. Interactive elements must be reachable and operable using only the keyboard. Claude can audit your JavaScript code to identify accessibility issues.

Common keyboard navigation problems include:

1. Missing focus management. When content updates dynamically, focus can be lost or stranded
2. Custom elements without keyboard support. Buttons implemented as divs lack keyboard interaction
3. Trap scenarios. Users can enter an element but cannot exit
4. `tabindex` misuse. Using large positive tabindex values breaks the natural tab order
5. Event listener gaps. Handling `click` but not `keydown` for Enter/Space activation

The frontend-design skill includes patterns for implementing keyboard-accessible interactive components. It provides templates for:
- Skip links that allow bypassing repetitive navigation
- Focus indicators that meet the 3:1 contrast ratio requirement
- Arrow key navigation for menus and grids
- Escape key handling for closing modals and dropdowns

Here's an example of a keyboard-navigable dropdown menu that Claude generates with the frontend-design skill:

```javascript
class AccessibleDropdown {
 constructor(trigger, menu) {
 this.trigger = trigger;
 this.menu = menu;
 this.items = Array.from(menu.querySelectorAll('[role="menuitem"]'));
 this.currentIndex = -1;
 this.bindEvents();
 }

 bindEvents() {
 this.trigger.addEventListener('keydown', (e) => {
 if (e.key === 'ArrowDown' || e.key === 'Enter' || e.key === ' ') {
 e.preventDefault();
 this.open();
 this.focusItem(0);
 }
 });

 this.menu.addEventListener('keydown', (e) => {
 switch (e.key) {
 case 'ArrowDown':
 e.preventDefault();
 this.focusItem(this.currentIndex + 1);
 break;
 case 'ArrowUp':
 e.preventDefault();
 this.focusItem(this.currentIndex - 1);
 break;
 case 'Escape':
 this.close();
 this.trigger.focus();
 break;
 case 'Home':
 e.preventDefault();
 this.focusItem(0);
 break;
 case 'End':
 e.preventDefault();
 this.focusItem(this.items.length - 1);
 break;
 }
 });
 }

 focusItem(index) {
 this.currentIndex = Math.max(0, Math.min(index, this.items.length - 1));
 this.items[this.currentIndex].focus();
 }

 open() {
 this.trigger.setAttribute('aria-expanded', 'true');
 this.menu.removeAttribute('hidden');
 }

 close() {
 this.trigger.setAttribute('aria-expanded', 'false');
 this.menu.setAttribute('hidden', '');
 this.currentIndex = -1;
 }
}
```

This implementation follows the ARIA Authoring Practices Guide (APG) menu button pattern, covering Home/End navigation, arrow key cycling, and Escape to close, exactly what screen reader users expect.

## Integrating Accessibility Testing with TDD

The tdd (test-driven development) skill pairs well with accessibility requirements. You can write tests that verify accessibility compliance alongside functional tests. Testing libraries like jest-dom, Testing Library, and axe-core integrate cleanly with this workflow.

```javascript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { axe, toHaveNoViolations } from 'jest-axe';
expect.extend(toHaveNoViolations);

describe('Accessible Button Component', () => {
 it('should have proper role attribute', () => {
 const button = render('<button>Click me</button>');
 expect(button.getAttribute('role')).toBe('button');
 });

 it('should be focusable', () => {
 const button = render('<button>Click me</button>');
 expect(button.tabIndex).toBe(0);
 });

 it('should respond to Enter key', () => {
 const handler = jest.fn();
 const button = render('<button>Click me</button>');
 button.addEventListener('click', handler);
 button.dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter' }));
 expect(handler).toHaveBeenCalled();
 });

 it('should have no axe accessibility violations', async () => {
 const { container } = render(<LoginForm />);
 const results = await axe(container);
 expect(results).toHaveNoViolations();
 });

 it('should announce error messages to screen readers', async () => {
 render(<LoginForm />);
 await userEvent.click(screen.getByRole('button', { name: /submit/i }));
 const errorRegion = screen.getByRole('alert');
 expect(errorRegion).toBeInTheDocument();
 expect(errorRegion).toHaveAttribute('aria-live', 'assertive');
 });
});
```

The `jest-axe` integration is particularly valuable, it runs axe-core's rule engine against your rendered components and fails the test if any violations are found. Claude's TDD skill can generate both the component and its accessibility test suite simultaneously, so you never ship a component that hasn't been checked.

By writing accessibility tests as part of your TDD workflow, you ensure that accessibility requirements are treated with the same importance as functional requirements.

## Color Contrast and Visual Design Checks

WCAG 2.1 criterion 1.4.3 requires a minimum contrast ratio of 4.5:1 for normal text and 3:1 for large text (18pt or 14pt bold). Criterion 1.4.11 extends this to UI components like buttons, input borders, and focus indicators.

Claude can analyze CSS and flag contrast issues by examining color values in context:

```css
/* Claude identifies this as a contrast failure */
.button-secondary {
 color: #767676; /* Gray text */
 background: #f5f5f5; /* Light gray background */
 /* Contrast ratio: ~2.3:1. fails WCAG AA */
}

/* Suggested fix */
.button-secondary {
 color: #595959; /* Darker gray */
 background: #f5f5f5;
 /* Contrast ratio: ~4.6:1. passes WCAG AA */
}
```

When Claude reviews your design tokens or CSS custom properties, it can build a full contrast audit table across your entire design system:

| Token Pair | Ratio | Status |
|---|---|---|
| --text-primary on --bg-white | 12.6:1 | Pass (AAA) |
| --text-muted on --bg-white | 4.7:1 | Pass (AA) |
| --text-placeholder on --bg-input | 2.9:1 | Fail |
| --text-disabled on --bg-white | 1.8:1 | Intentional (disabled) |

Disabled state elements are typically exempted from contrast requirements, so Claude's audit should be smart enough to flag them as expected rather than failures.

## Maintaining Accessibility with Supermemory

As projects grow, maintaining accessibility becomes challenging. The supermemory skill helps you track accessibility decisions, known issues, and remediation plans across your codebase.

Supermemory can store:
- Links between components and their accessibility tests
- Known WCAG violations and their severity
- Design decisions that impact accessibility
- Progress on accessibility remediation efforts
- Accepted risk decisions (e.g., a known AAA failure that's out of scope)

When you modify a component, supermemory can surface related accessibility context, reminding you of connected tests and any documented concerns. This is especially valuable for cross-functional teams where designers, developers, and QA engineers are all touching the same components.

## Automating Accessibility Reviews in CI/CD

Rather than relying solely on manual audits, use Claude skills to automate parts of your accessibility review process. The combination of code analysis skills and testing skills creates a pipeline where accessibility checks run automatically on every pull request.

Set up a workflow where:
1. Code commits trigger accessibility analysis
2. Claude scans for common issues (missing alt text, improper heading hierarchy, contrast problems)
3. Test suites verify keyboard interaction and screen reader compatibility
4. axe-core runs against Storybook stories or integration test renders
5. Reports are generated for each pull request with links to the specific WCAG criteria violated

A GitHub Actions workflow example:

```yaml
name: Accessibility Check
on: [pull_request]

jobs:
 a11y:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4
 - name: Install dependencies
 run: npm ci
 - name: Run accessibility tests
 run: npm run test:a11y
 - name: Upload accessibility report
 uses: actions/upload-artifact@v4
 with:
 name: a11y-report
 path: reports/accessibility/
```

This automation catches issues early, before they reach production and affect real users. Claude can generate the test scripts that power this pipeline, ask it to write an axe-core scan against your production URL or a local Playwright-driven crawl of your application.

## Getting Started with Accessible Development

Begin by auditing your current codebase with an accessibility-focused Claude skill. Identify the highest-impact issues, those affecting the most users or violating the most critical WCAG criteria, and address them systematically.

A practical triage approach for existing codebases:

1. Run automated scanning first. Tools like axe-core, Lighthouse, and WAVE can catch roughly 30–40% of WCAG failures automatically. Use Claude to parse and prioritize those reports.
2. Test with real assistive technology. Use NVDA (Windows) or VoiceOver (macOS/iOS) to navigate your app as a screen reader user would. Ask Claude to help interpret what you find.
3. Keyboard-only testing. Unplug your mouse and try to complete every critical user journey. Document where you get stuck.
4. Color contrast sweep. Use Claude to review all CSS color pairings against WCAG thresholds.
5. Form audit. Forms are the highest-risk area, every input needs a visible label, every error message needs to be programmatically associated with its field.

As you build new features, include accessibility requirements in your initial specifications. Use Claude skills to generate accessible components from the start rather than retrofitting accessibility later. The ARIA Authoring Practices Guide (APG) at w3.org/WAI/ARIA/apg is the canonical reference for complex widget patterns, Claude knows this guide well and can generate implementations that follow it precisely.

The accessibility skills ecosystem continues to evolve. Stay current by exploring new skills as they become available, and consider contributing your own accessibility-focused skills back to the community.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-md-for-accessibility-requirements-a11y)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Code Focus Management Audit Accessibility Guide](/claude-code-focus-management-audit-accessibility-guide/)
- [Claude Code WCAG Accessibility Audit Workflow](/claude-code-wcag-accessibility-audit-workflow/)
- [Claude Code Accessibility Regression Testing Guide](/claude-code-accessibility-regression-testing/)
- [Why Does Claude Code Perform Better With — Developer Guide](/why-does-claude-code-perform-better-with-claude-md/)
- [How to Use Claude Md Conflicting — Complete Developer (2026)](/claude-md-conflicting-instructions-resolution-guide/)
- [Claude.md for API Design Standards Guide](/claude-md-for-api-design-standards-guide/)
- [How Claude Code Eliminated Boilerplate Coding](/how-claude-code-eliminated-boilerplate-coding/)
- [Claude Md For Contractor And Vendor Teams — Developer Guide](/claude-md-for-contractor-and-vendor-teams/)
- [Claude Md Secrets And Sensitive Info — Developer Guide](/claude-md-secrets-and-sensitive-info-handling/)
- [Claude Md For Dependency Management Rules — Developer Guide](/claude-md-for-dependency-management-rules/)
- [CLAUDE.md Example for Rails + Turbo + Stimulus — Production Template (2026)](/claude-md-example-for-rails-turbo-stimulus/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


