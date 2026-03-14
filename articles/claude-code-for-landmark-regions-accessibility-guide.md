---

layout: default
title: "Claude Code for Landmark Regions Accessibility Guide"
description: "Learn how to use Claude Code to implement and audit ARIA landmark regions for improved web accessibility and screen reader navigation."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /claude-code-for-landmark-regions-accessibility-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
---

{% raw %}

# Claude Code for Landmark Regions Accessibility Guide

ARIA landmark regions are invisible yet powerful structural elements that help screen reader users navigate web pages efficiently. By properly implementing landmark regions, you create a semantic backbone that assistive technologies can traverse, allowing users to jump between main content, navigation, sidebars, and other key sections without reading through every element. This guide demonstrates how to use Claude Code and related skills to implement, audit, and maintain landmark regions in your projects.

## Understanding ARIA Landmark Regions

Landmark regions are HTML elements or ARIA roles that identify major page sections. Screen readers recognize these regions and provide keyboard shortcuts for quick navigation. The seven primary landmark roles include:

- **banner**: Site-level content like logos and headers
- **navigation**: Navigation menus and links
- **main**: Primary content of the page
- **complementary**: Supporting content like sidebars
- **contentinfo**: Footer information
- **form**: Form sections
- **search**: Search functionality

Modern HTML5 semantic elements automatically map to these landmarks. The `<main>` element becomes the main landmark, `<nav>` becomes navigation, and so forth. This means many websites already have landmark regions without any explicit ARIA attributes.

However, improper implementation creates problems. A page with multiple `<nav>` elements but no accessible names forces screen reader users to guess which navigation contains the primary menu versus supplementary links. Similarly, pages without a main landmark force users to read through headers, sidebars, and footers to find actual content.

## Setting Up Your Accessibility Environment

Before implementing landmark regions, configure Claude Code with appropriate skills. The **accessibility-testing** skill provides automated auditing capabilities, while the **frontend-design** skill offers templates for proper landmark implementation.

Install the accessibility skill by placing it in your `.claude/` directory:

```bash
# The skill analyzes your codebase for accessibility issues
# including missing or incorrect landmark implementations
```

The **tdd** skill complements accessibility work by generating automated tests that verify landmark presence and correctness:

```bash
# Generate tests that check for landmark region existence
# and proper implementation patterns
```

These skills work together—frontend-design generates proper markup, while tdd ensures landmarks remain correctly implemented through refactoring and updates.

## Implementing Landmark Regions Correctly

### Using Semantic HTML

The simplest approach uses semantic HTML5 elements, which browsers and assistive technologies automatically recognize:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <title>E-commerce Product Page</title>
</head>
<body>
  <header role="banner">
    <img src="logo.svg" alt="Company Name">
    <nav role="navigation" aria-label="Primary">
      <ul>
        <li><a href="/products">Products</a></li>
        <li><a href="/about">About</a></li>
      </ul>
    </nav>
  </header>

  <main role="main">
    <article>
      <h1>Product Name</h1>
      <p>Product description...</p>
    </article>
  </main>

  <aside role="complementary" aria-label="Related products">
    <h2>Related Products</h2>
  </aside>

  <footer role="contentinfo">
    <p>&copy; 2026 Company Name</p>
  </footer>
</body>
</html>
```

Notice each landmark includes an `aria-label` or `aria-labelledby` attribute when multiple elements share the same role. This provides context—screen readers announce "navigation, primary" rather than simply "navigation."

### Adding Landmarks to Existing Projects

For legacy applications without semantic markup, add landmark roles to existing containers:

```html
<!-- Before: Generic div structure -->
<div class="header">
  <div class="logo"></div>
  <div class="menu"></div>
</div>

<!-- After: Proper landmarks added -->
<div class="header" role="banner">
  <div class="logo"></div>
  <nav class="menu" role="navigation" aria-label="Main menu"></nav>
</div>
```

When adding roles to existing elements, ensure the element's semantics remain compatible. Adding `role="navigation"` to a `<div>` works, but avoid adding conflicting roles like `role="button"` to elements that function as headings.

### Dynamic Content and Single-Page Applications

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

## Best Practices and Common Pitfalls

### Do

- Use semantic HTML elements as your first choice
- Label multiple landmarks of the same type
- Include landmarks in all page templates
- Test with actual screen readers (NVDA, VoiceOver, JAWS)

### Don't

- Nest landmarks inside other landmarks
- Add landmark roles to non-landmark containers without cause
- Leave landmark containers empty
- Use landmarks for styling hooks (use classes instead)

The most common mistake involves placing one landmark inside another. For example, putting a `<nav>` inside `<header>` works, but creating a landmark inside another landmark causes confusion:

```html
<!-- Avoid: nested landmarks cause confusion -->
<main role="main">
  <nav role="navigation">
    <!-- This navigation is inside main, unclear to users -->
  </nav>
</main>
```

Instead, use the navigation within main without making it a landmark itself, or accept that users will encounter the nested navigation after reaching main content.

## Conclusion

Landmark regions form the navigation backbone of accessible websites. By leveraging Claude Code and accessibility skills, you can implement proper landmarks from project start and maintain them through development cycles. The investment minimal—proper landmark implementation takes minutes—while the benefit to screen reader users is substantial. Users gain the ability to navigate directly to content that matters to them, bypassing repetitive elements that would otherwise require dozens of tab presses.

Start by auditing your current projects for landmark presence, then add missing regions and labels. Your users will notice the improvement immediately.

{% endraw %}
