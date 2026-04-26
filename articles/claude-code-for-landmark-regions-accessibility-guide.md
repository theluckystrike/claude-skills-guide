---

layout: default
title: "Claude Code for Landmark Regions (2026)"
description: "Learn how to use Claude Code to implement and audit ARIA landmark regions for improved web accessibility and screen reader navigation."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-landmark-regions-accessibility-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
render_with_liquid: false
geo_optimized: true
---

{% raw %}
ARIA landmark regions are invisible yet powerful structural elements that help screen reader users navigate web pages efficiently. By properly implementing landmark regions, you create a semantic backbone that assistive technologies can traverse, allowing users to jump between main content, navigation, sidebars, and other key sections without reading through every element. This guide demonstrates how to use Claude Code and related skills to implement, audit, and maintain landmark regions in your projects.

## Understanding ARIA Landmark Regions

Landmark regions are HTML elements or ARIA roles that identify major page sections. Screen readers recognize these regions and provide keyboard shortcuts for quick navigation. The seven primary landmark roles include:

- banner: Site-level content like logos and headers
- navigation: Navigation menus and links
- main: Primary content of the page
- complementary: Supporting content like sidebars
- contentinfo: Footer information
- form: Form sections
- search: Search functionality

Modern HTML5 semantic elements automatically map to these landmarks. The `<main>` element becomes the main landmark, `<nav>` becomes navigation, and so forth. This means many websites already have landmark regions without any explicit ARIA attributes.

However, improper implementation creates problems. A page with multiple `<nav>` elements but no accessible names forces screen reader users to guess which navigation contains the primary menu versus supplementary links. Similarly, pages without a main landmark force users to read through headers, sidebars, and footers to find actual content.

## HTML5 Elements to ARIA Role Mapping

Understanding the implicit mappings eliminates redundant role attributes in your markup. When a semantic element already provides the correct implicit role, adding an explicit `role` attribute is noise, not a problem per se, but unnecessary.

| HTML5 Element | Implicit ARIA Role | Notes |
|---|---|---|
| `<header>` (top-level) | `banner` | Only when not nested inside `<article>`, `<aside>`, `<main>`, `<nav>`, or `<section>` |
| `<nav>` | `navigation` | Each `<nav>` element creates a separate navigation landmark |
| `<main>` | `main` | Only one allowed per page |
| `<aside>` | `complementary` | Supporting content, not required reading |
| `<footer>` (top-level) | `contentinfo` | Only when not nested inside sectioning elements |
| `<form>` | `form` | Only when the form has an accessible name via `aria-label` or `aria-labelledby` |
| `<section>` | `region` | Only when the section has an accessible name |
| `<search>` | `search` | HTML living standard addition; use `role="search"` for broader support |

A header nested inside an `<article>` does not get the `banner` role, it remains a generic `<header>` element with no landmark semantics. This distinction catches many developers off guard during audits.

## Setting Up Your Accessibility Environment

Before implementing landmark regions, configure Claude Code with appropriate skills. The accessibility-testing skill provides automated auditing capabilities, while the frontend-design skill offers templates for proper landmark implementation.

Install the accessibility skill by placing it in your `.claude/` directory:

```bash
The skill analyzes your codebase for accessibility issues
including missing or incorrect landmark implementations
```

The tdd skill complements accessibility work by generating automated tests that verify landmark presence and correctness:

```bash
Generate tests that check for landmark region existence
and proper implementation patterns
```

These skills work together, frontend-design generates proper markup, while tdd ensures landmarks remain correctly implemented through refactoring and updates.

## Prompting Claude Code Effectively for Accessibility Work

The quality of output from Claude Code scales directly with how specifically you describe your page structure. Compare these two prompts:

## Vague prompt: "Add landmark regions to my page."

Effective prompt: "I have a marketing landing page built with generic `<div>` elements. The page has: a top header with a logo and primary nav, a hero section, three feature cards in a row, a pricing table, a contact form, and a footer with social links and legal text. Audit this HTML and add appropriate landmark regions with aria-label values for any duplicated landmark types. Flag any places where I have nested landmarks."

The second prompt gives Claude Code enough context to generate accurate, non-generic markup rather than a boilerplate skeleton you have to adapt anyway.

## Implementing Landmark Regions Correctly

## Using Semantic HTML

The simplest approach uses semantic HTML5 elements, which browsers and assistive technologies automatically recognize:

```html
<!DOCTYPE html>
<html lang="en">
<head>
 <title>E-commerce Product Page</title>
</head>
<body>
 <header>
 <img src="logo.svg" alt="Company Name">
 <nav aria-label="Primary">
 <ul>
 <li><a href="/products">Products</a></li>
 <li><a href="/about">About</a></li>
 </ul>
 </nav>
 </header>

 <main>
 <article>
 <h1>Product Name</h1>
 <p>Product description...</p>
 </article>
 </main>

 <aside aria-label="Related products">
 <h2>Related Products</h2>
 </aside>

 <footer>
 <p>&copy; 2026 Company Name</p>
 </footer>
</body>
</html>
```

Notice the navigation element includes an `aria-label` attribute. When multiple elements share the same role, the label provides context, screen readers announce "navigation, primary" rather than simply "navigation." Without the label, users navigating between landmarks cannot distinguish one `<nav>` from another.

## Adding Landmarks to Existing Projects

For legacy applications without semantic markup, add landmark roles to existing containers:

```html
<!-- Before: Generic div structure -->
<div class="header">
 <div class="logo"></div>
 <div class="menu"></div>
</div>
<div class="content">
 <p>Main page content here</p>
</div>
<div class="sidebar">
 <p>Related links</p>
</div>
<div class="footer">
 <p>&copy; 2026</p>
</div>

<!-- After: Proper landmarks added -->
<div class="header" role="banner">
 <div class="logo"></div>
 <nav class="menu" role="navigation" aria-label="Main menu"></nav>
</div>
<main class="content" role="main">
 <p>Main page content here</p>
</main>
<aside class="sidebar" role="complementary" aria-label="Related links">
 <p>Related links</p>
</aside>
<div class="footer" role="contentinfo">
 <p>&copy; 2026</p>
</div>
```

When adding roles to existing elements, ensure the element's semantics remain compatible. Adding `role="navigation"` to a `<div>` works, but avoid adding conflicting roles like `role="button"` to elements that function as headings.

For large legacy codebases, Claude Code can scan your templates and flag every element that should carry a landmark role but does not. Provide it with a representative page template and ask for a full audit with specific line-number references to fix.

## Dynamic Content and Single-Page Applications

Single-page applications and dynamically loaded content require special attention. When content loads asynchronously, landmarks must exist in the initial HTML:

```html
<div id="app">
 <header role="banner">...</header>
 <nav role="navigation" aria-label="Main" id="main-nav"></nav>
 <main role="main" id="content-area">
 <!-- Dynamic content loads here -->
 </main>
</div>
```

JavaScript then populates the main content area without requiring new landmark containers. This approach maintains consistent navigation structure regardless of which view displays.

## Route Changes and Focus Management in SPAs

In a single-page application, navigating between routes does not trigger a page reload, so the browser does not automatically move focus or announce a new page to screen readers. Proper landmark structure is necessary but not sufficient, you also need to manage focus on route transitions.

```javascript
// React example with focus management on route change
import { useEffect, useRef } from 'react';
import { useLocation } from 'react-router-dom';

function RouteChangeAnnouncer() {
 const location = useLocation();
 const mainRef = useRef(null);
 const announceRef = useRef(null);

 useEffect(() => {
 // Get the page title from the document or a data attribute
 const pageTitle = document.title || 'New page loaded';

 // Update the live region so screen readers announce the navigation
 if (announceRef.current) {
 announceRef.current.textContent = '';
 // Small timeout forces re-announcement even if text is the same
 setTimeout(() => {
 announceRef.current.textContent = `Navigated to ${pageTitle}`;
 }, 100);
 }

 // Move focus to the main content area
 if (mainRef.current) {
 mainRef.current.focus();
 }
 }, [location.pathname]);

 return (
 <>
 {/* Visually hidden live region for announcements */}
 <div
 ref={announceRef}
 aria-live="polite"
 aria-atomic="true"
 style={{
 position: 'absolute',
 width: '1px',
 height: '1px',
 overflow: 'hidden',
 clip: 'rect(0,0,0,0)',
 whiteSpace: 'nowrap'
 }}
 />
 <main ref={mainRef} tabIndex={-1} id="main-content">
 {/* Route content renders here */}
 </main>
 </>
 );
}
```

The `tabIndex={-1}` on the `<main>` element allows programmatic focus without placing it in the natural tab order. This is a standard pattern for focus management in accessible SPAs.

## Form and Search Landmarks

The `form` and `search` landmarks are commonly missed. A form only gains the `form` landmark role when it has an accessible name. An unnamed `<form>` element has no implicit landmark role at all.

```html
<!-- This form has NO landmark role. it is just a generic container -->
<form method="post" action="/subscribe">
 <input type="email" name="email">
 <button type="submit">Subscribe</button>
</form>

<!-- This form IS a landmark. it has an accessible name -->
<form method="post" action="/subscribe" aria-label="Newsletter signup">
 <input type="email" name="email" aria-label="Email address">
 <button type="submit">Subscribe</button>
</form>

<!-- Search landmark. prefer the HTML element for new builds -->
<search>
 <label for="site-search">Search this site</label>
 <input type="search" id="site-search" name="q">
 <button type="submit">Search</button>
</search>

<!-- For older browsers that do not support <search> -->
<form role="search" aria-label="Site search">
 <label for="site-search">Search this site</label>
 <input type="search" id="site-search" name="q">
 <button type="submit">Search</button>
</form>
```

Ask Claude Code to audit your forms specifically for accessible names. In a typical codebase, fewer than half of forms that should be landmarks actually carry the necessary label.

## Auditing Landmark Implementation

Regular audits ensure landmarks remain correctly implemented as projects evolve. Claude Code with accessibility skills can scan your codebase:

```javascript
// Accessibility audit checks for:
// 1. Presence of main landmark
// 2. Unique labels for multiple navigation elements
// 3. Proper nesting (no landmarks inside landmarks)
// 4. Consistent use across pages
```

Common issues discovered during audits include:

- Multiple `<main>` elements on single pages
- Missing landmarks on error pages or modal views
- Empty landmark containers that confuse users
- Landmark roles added but semantic elements ignored

## Automated Auditing with axe-core

For programmatic auditing during development and CI pipelines, axe-core provides reliable landmark checks:

```javascript
// Install: npm install axe-core
import axe from 'axe-core';

async function auditLandmarks(pageUrl) {
 // Run axe with landmark-specific rules
 const results = await axe.run(document, {
 runOnly: {
 type: 'rule',
 values: [
 'landmark-banner-is-top-level',
 'landmark-complementary-is-top-level',
 'landmark-contentinfo-is-top-level',
 'landmark-main-is-top-level',
 'landmark-no-duplicate-banner',
 'landmark-no-duplicate-contentinfo',
 'landmark-no-duplicate-main',
 'landmark-one-main',
 'landmark-unique',
 'region'
 ]
 }
 });

 if (results.violations.length > 0) {
 console.error('Landmark violations found:');
 results.violations.forEach(violation => {
 console.error(` [${violation.impact}] ${violation.description}`);
 violation.nodes.forEach(node => {
 console.error(` Element: ${node.html}`);
 console.error(` Fix: ${node.failureSummary}`);
 });
 });
 } else {
 console.log('No landmark violations found.');
 }

 return results;
}
```

Integrate this into your CI pipeline with Playwright or Puppeteer to catch regressions before they reach production:

```javascript
// In your Playwright test suite
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('homepage has correct landmark structure', async ({ page }) => {
 await page.goto('/');

 const results = await new AxeBuilder({ page })
 .include('body')
 .withRules([
 'landmark-one-main',
 'landmark-no-duplicate-banner',
 'landmark-unique'
 ])
 .analyze();

 expect(results.violations).toEqual([]);
});

test('all navigation landmarks are labeled', async ({ page }) => {
 await page.goto('/');

 const navElements = await page.locator('nav, [role="navigation"]').all();

 // If there are multiple nav elements, each needs an aria-label
 if (navElements.length > 1) {
 for (const nav of navElements) {
 const label = await nav.getAttribute('aria-label');
 const labelledby = await nav.getAttribute('aria-labelledby');
 expect(label || labelledby).toBeTruthy();
 }
 }
});
```

Ask Claude Code to generate a complete Playwright accessibility test suite for your project. Provide your site map and page types, and request tests that cover landmark structure, focus order, and keyboard navigation.

## Manual Testing with Screen Readers

Automated tools catch structural problems but cannot verify that the landmark labels are meaningful to real users. Manual testing with actual screen readers remains essential.

| Screen Reader | OS | Navigation Shortcut | Landmark List |
|---|---|---|---|
| NVDA | Windows | `D` to next landmark, `Shift+D` to previous | Insert+F7 |
| JAWS | Windows | `R` to next landmark | Insert+F3 |
| VoiceOver | macOS | `VO+U` opens rotor, then arrow to Landmarks | VO+U, then arrow |
| VoiceOver | iOS | Rotor gesture, select Landmarks | Two-finger twist |
| TalkBack | Android | Swipe to navigate, use local context menu | Via navigation settings |
| Narrator | Windows | `Caps Lock+F5` lists landmarks | Caps Lock+F5 |

A practical testing workflow: open your page in NVDA or VoiceOver, navigate directly to the landmarks list, and verify that each landmark has a meaningful name. Then navigate the page using only landmark shortcuts and ask: can I reach every section of this page without using the tab key? If the answer is no, a section is likely missing a landmark.

## Best Practices and Common Pitfalls

Do

- Use semantic HTML elements as your first choice
- Label multiple landmarks of the same type
- Include landmarks in all page templates
- Test with actual screen readers (NVDA, VoiceOver, JAWS)
- Verify landmarks on error pages, empty states, and modal dialogs
- Use skip links in addition to landmarks for keyboard users who do not use screen readers

## Don't

- Nest landmarks inside other landmarks
- Add landmark roles to non-landmark containers without cause
- Leave landmark containers empty
- Use landmarks for styling hooks (use classes instead)
- Add role attributes that duplicate the implicit role of an HTML element

## Skip Links: The Companion to Landmarks

Landmark regions help screen reader users, but keyboard-only users who do not use screen readers benefit from skip links. These are anchors that appear on focus and allow users to jump past repetitive navigation directly to main content. Skip links and landmarks serve different but overlapping audiences and should both be present.

```html
<!-- Place this as the first element inside <body> -->
<a href="#main-content" class="skip-link">Skip to main content</a>

<!-- Visually hidden until focused -->
<style>
.skip-link {
 position: absolute;
 top: -40px;
 left: 0;
 background: #000;
 color: #fff;
 padding: 8px;
 z-index: 100;
 text-decoration: none;
}

.skip-link:focus {
 top: 0;
}
</style>

<header>...</header>
<main id="main-content" tabindex="-1">
 <!-- tabindex="-1" allows the skip link focus to land here -->
 <h1>Page title</h1>
</main>
```

## Nested Landmarks: The Most Common Mistake

The most common mistake involves placing one landmark inside another in ways that create confusing page structure. For example, putting a `<nav>` inside `<header>` is perfectly acceptable, a primary navigation inside a banner is expected. But creating a landmark inside `<main>` when you simply want to group content visually is incorrect.

```html
<!-- Avoid: navigation inside main creates a confusing landmark tree -->
<main role="main">
 <nav role="navigation">
 <!-- This in-page navigation is inside main. misleading to users -->
 </nav>
</main>

<!-- Better: use a plain <ul> for in-page anchor links -->
<main>
 <nav aria-label="On this page">
 <!-- Acceptable. clearly labeled in-page TOC navigation -->
 <ul>
 <li><a href="#section-1">Section 1</a></li>
 <li><a href="#section-2">Section 2</a></li>
 </ul>
 </nav>
 <section id="section-1">...</section>
 <section id="section-2">...</section>
</main>
```

In the corrected example, the in-page table of contents navigation carries a clear `aria-label` that tells screen reader users exactly what it is. Users navigating by landmarks will encounter "navigation, on this page". clear and expected.

## Landmark Density: More Is Not Better

Adding a landmark to every `<section>` on your page creates a landmark list that is as useless as no landmarks at all. The WCAG guidance on the `region` role (which `<section>` maps to) is explicit: only use it for sections that are important enough to be listed in the landmark navigation.

A useful heuristic: if a user would reasonably want to navigate directly to this section from a landmarks list, give it a landmark. If it is just a visual grouping of related content, use `<section>` without a label and it will not become a region landmark.

## Testing Your Implementation End-to-End

A complete accessibility workflow for landmark regions involves three layers of verification:

1. Static analysis: Lint your HTML with tools like HTML-validate configured with accessibility rules. Catches structural problems at build time.

2. Automated runtime audit: Run axe-core in CI via Playwright or Cypress. Catches landmark violations in rendered output, including JavaScript-generated markup.

3. Manual screen reader testing: Verify that the landmark labels are meaningful and navigation is practical. No automated tool can tell you whether "navigation, nav-1" is a useful label (it is not).

Claude Code can generate the configuration for all three layers. Describe your build toolchain, whether you use Vite, Next.js, Astro, or a custom setup, and ask for a complete accessibility testing pipeline that runs on every pull request.

## Conclusion

Landmark regions form the navigation backbone of accessible websites. By using Claude Code and accessibility skills, you can implement proper landmarks from project start and maintain them through development cycles. The investment is minimal, proper landmark implementation takes minutes, while the benefit to screen reader users is substantial. Users gain the ability to navigate directly to content that matters to them, bypassing repetitive elements that would otherwise require dozens of tab presses.

Start by auditing your current projects for landmark presence using axe-core, then add missing regions and labels. Pair your landmarks with skip links for keyboard-only users, and validate with at least one real screen reader before shipping. Your users will notice the improvement immediately.



---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-landmark-regions-accessibility-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI Accessibility Chrome Extension: A Developer Guide](/ai-accessibility-chrome-extension/)
- [AI Coding Tools for Accessibility Improvements](/ai-coding-tools-for-accessibility-improvements/)
- [Chrome Extension Accessibility Audit: A Practical Guide](/chrome-extension-accessibility-audit/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


