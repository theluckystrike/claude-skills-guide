---

layout: default
title: "Build Dark Mode with Claude Code (2026)"
description: "Implement dark mode in web apps using Claude Code with CSS variables, theme toggles, and system preference detection. Practical code examples."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, dark-mode, css, frontend, frontend-design, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-dark-mode-implementation-guide/
reviewed: true
score: 7
last_tested: "2026-04-21"
geo_optimized: true
---

Dark mode has transformed from a nice-to-have feature into an expectation for modern web applications. Users appreciate the flexibility to switch between light and dark themes, whether for aesthetic preferences, reduced eye strain in low-light environments, or accessibility considerations. This guide walks you through implementing dark mode systematically using Claude Code, covering CSS custom properties, JavaScript toggles, system preference detection, persistence strategies, and React-based component patterns.

## Why Dark Mode Matters in 2026

Before diving into implementation, it's worth understanding why dark mode deserves careful engineering rather than a quick afterthought. Approximately 80% of smartphone users enable dark mode when available. Battery life on OLED screens improves measurably in dark mode because black pixels consume no power. And for users with conditions like photophobia or migraines, dark mode can make the difference between using your app or abandoning it entirely.

Dark mode also has accessibility implications under WCAG guidelines. your dark theme must maintain a minimum 4.5:1 contrast ratio for normal text and 3:1 for large text, the same standard that applies to light mode. Implementing dark mode incorrectly can actually hurt accessibility even while appearing to help it.

Claude Code accelerates all of this by generating pattern-consistent code, catching contrast issues during review, and writing tests that verify your theme tokens stay in sync.

## Approach Comparison: Three Implementation Strategies

Before writing any code, choose your architecture. The approach you pick here affects how maintainable your codebase is six months later.

| Strategy | Pros | Cons | Best For |
|---|---|---|---|
| CSS Custom Properties | Native browser support, zero JS runtime cost, easy to inspect | Requires IE fallbacks if legacy support needed | Most modern projects |
| CSS-in-JS (styled-components/Emotion) | Co-located with components, TypeScript-friendly | Runtime overhead, harder to inspect in DevTools | React-heavy apps |
| Separate Stylesheets | Works without JS, simple mental model | Large bundle, harder to maintain in sync | Static sites, no-JS environments |
| Tailwind dark: variant | Utility-first, minimal custom CSS | Requires PurgeCSS tuning, verbose HTML | Tailwind projects |

For most production web applications in 2026, CSS custom properties combined with a `data-theme` attribute on `<html>` delivers the best balance of performance, maintainability, and developer ergonomics.

## CSS Custom Properties as the Foundation

The most maintainable approach to dark mode relies on CSS custom properties (variables). Instead of maintaining separate stylesheets or complex class-based overrides, you define your color palette once and swap values based on a data attribute or class on the root element.

```css
:root {
 --bg-primary: #ffffff;
 --bg-secondary: #f5f5f5;
 --text-primary: #1a1a1a;
 --text-secondary: #666666;
 --border-color: #e0e0e0;
 --accent-color: #0066cc;
 --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.12);
 --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
}

[data-theme="dark"] {
 --bg-primary: #1a1a1a;
 --bg-secondary: #2d2d2d;
 --text-primary: #f0f0f0;
 --text-secondary: #a0a0a0;
 --border-color: #404040;
 --accent-color: #4da6ff;
 --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.4);
 --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.35);
}

body {
 background-color: var(--bg-primary);
 color: var(--text-primary);
 transition: background-color 0.3s ease, color 0.3s ease;
}
```

Notice the shadow tokens. this is a detail many implementations miss. Shadows that look subtle in light mode become invisible against dark backgrounds if you don't adjust them. By including shadow variables in your token set, you get consistent depth perception across both themes.

This pattern scales well because you update component styles to use the custom properties rather than hardcoded colors. When you need to modify your theme, you change the values in one place.

## Implementing the Theme Toggle

A theme toggle requires both JavaScript logic and UI elements. The toggle should persist user preference, respect system preferences on first visit, and update immediately without a flash of unstyled content.

```javascript
const getThemePreference = () => {
 const stored = localStorage.getItem('theme');
 if (stored) return stored;
 return window.matchMedia('(prefers-color-scheme: dark)').matches
 ? 'dark'
 : 'light';
};

const setTheme = (theme) => {
 document.documentElement.setAttribute('data-theme', theme);
 localStorage.setItem('theme', theme);
};

const toggleTheme = () => {
 const current = document.documentElement.getAttribute('data-theme');
 setTheme(current === 'dark' ? 'light' : 'dark');
};

document.addEventListener('DOMContentLoaded', () => {
 setTheme(getThemePreference());
});
```

You can invoke Claude Code with the frontend-design skill to generate accessible toggle buttons that follow WAI-ARIA patterns:

```
/frontend-design create accessible dark mode toggle button with proper ARIA labels
```

Here's what an accessible toggle button looks like in practice:

```html
<button
 id="theme-toggle"
 type="button"
 aria-label="Switch to dark mode"
 aria-pressed="false"
 class="theme-toggle"
>
 <svg class="icon-sun" aria-hidden="true" width="20" height="20"><!-- sun SVG --></svg>
 <svg class="icon-moon" aria-hidden="true" width="20" height="20"><!-- moon SVG --></svg>
</button>
```

```javascript
const themeToggleBtn = document.getElementById('theme-toggle');

themeToggleBtn.addEventListener('click', () => {
 const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
 setTheme(isDark ? 'light' : 'dark');
 themeToggleBtn.setAttribute('aria-pressed', String(!isDark));
 themeToggleBtn.setAttribute(
 'aria-label',
 isDark ? 'Switch to dark mode' : 'Switch to light mode'
 );
});
```

The `aria-pressed` attribute communicates toggle state to screen readers without requiring them to infer it from visual appearance.

## Preventing Flash of Wrong Theme

A common issue occurs when the page loads before JavaScript executes. the user sees a flash of the wrong theme. The solution involves a small inline script in the `<head>` that runs before the page renders:

```html
<head>
 <script>
 (function() {
 const stored = localStorage.getItem('theme');
 const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
 const theme = stored || (prefersDark ? 'dark' : 'light');
 document.documentElement.setAttribute('data-theme', theme);
 })();
 </script>
</head>
```

This script executes synchronously before any CSS loads, ensuring the correct theme is applied immediately. It is intentionally tiny and self-contained. no imports, no dependencies. Even if your main JavaScript bundle fails to load, users still get the right theme.

For Next.js projects, place this in `_document.js` inside the `<Head>` component. For server-rendered apps, you can also read the stored preference from a cookie server-side and render the correct `data-theme` attribute directly in the HTML, eliminating the need for client-side detection entirely.

## Handling System Preference Changes

Users may change their system preference while using your application. Listening for changes keeps your implementation in sync:

```javascript
const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');

mediaQuery.addEventListener('change', (e) => {
 if (!localStorage.getItem('theme')) {
 setTheme(e.matches ? 'dark' : 'light');
 }
});
```

This code only applies system preference changes when the user hasn't manually set a preference. Once a user toggles manually, their choice takes priority. This is the correct behavior. respecting explicit user intent over inferred preference.

## Component-Level Dark Mode

Larger applications benefit from component-level theming. Each component defines its own custom properties, allowing granular control:

```css
.card {
 background-color: var(--card-bg, var(--bg-secondary));
 border: 1px solid var(--card-border, var(--border-color));
 border-radius: 8px;
 padding: 16px;
}

[data-theme="dark"] .card {
 --card-bg: #252525;
 --card-border: #3a3a3a;
}
```

The tdd skill can help you write tests for component theming to ensure consistency across your design system:

```
/tdd create test suite for dark mode component styling consistency
```

## React Hook Pattern for Theme Management

In React applications, a custom hook centralizes theme logic cleanly:

```javascript
import { useState, useEffect } from 'react';

function useTheme() {
 const [theme, setThemeState] = useState(() => {
 if (typeof window === 'undefined') return 'light';
 return localStorage.getItem('theme') ||
 (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
 });

 useEffect(() => {
 document.documentElement.setAttribute('data-theme', theme);
 localStorage.setItem('theme', theme);
 }, [theme]);

 const toggleTheme = () => {
 setThemeState(prev => prev === 'dark' ? 'light' : 'dark');
 };

 return { theme, toggleTheme };
}

export default useTheme;
```

Use it in any component:

```javascript
function Header() {
 const { theme, toggleTheme } = useTheme();

 return (
 <header>
 <nav>...</nav>
 <button onClick={toggleTheme} aria-label={`Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`}>
 {theme === 'dark' ? 'Light Mode' : 'Dark Mode'}
 </button>
 </header>
 );
}
```

## Dark Mode for Syntax Highlighting

Code blocks require special attention in dark mode. If you use Prism.js or Highlight.js, most themes include dark variants:

```javascript
// Apply dark code theme dynamically
function updateCodeTheme(isDark) {
 const existingLink = document.getElementById('code-theme');
 if (existingLink) existingLink.remove();

 const link = document.createElement('link');
 link.id = 'code-theme';
 link.rel = 'stylesheet';
 link.href = isDark ? '/prism-tomorrow.css' : '/prism-solarized.css';
 document.head.appendChild(link);
}
```

For custom code blocks, define syntax colors as CSS variables:

```css
.code-block {
 --code-bg: #282c34;
 --code-keyword: #c678dd;
 --code-string: #98c379;
 --code-comment: #5c6370;
 --code-function: #61afef;
 --code-number: #d19a66;
}

[data-theme="light"] .code-block {
 --code-bg: #fafafa;
 --code-keyword: #a626a4;
 --code-string: #50a14f;
 --code-comment: #a0a1a7;
 --code-function: #4078f2;
 --code-number: #986801;
}
```

Note that the dark code block background (`#282c34`) is intentionally darker than the page background (`#1a1a1a` is already quite dark). Use a slightly lighter shade for the code background so code blocks remain visually distinct on dark pages.

## Image and Media Considerations

Dark mode isn't just about text and backgrounds. Images and media need consideration too.

For images that look harsh on dark backgrounds, CSS filters can soften them:

```css
[data-theme="dark"] img:not([data-no-filter]) {
 filter: brightness(0.85) contrast(1.05);
}
```

For illustrations and icons designed for light mode, offer dark-mode variants using the `picture` element:

```html
<picture>
 <source srcset="/logo-dark.svg" media="(prefers-color-scheme: dark)">
 <img src="/logo-light.svg" alt="Company logo">
</picture>
```

If you control your SVGs inline, simply use `currentColor` for fills and let CSS handle the rest via your text color token.

## Testing Dark Mode Implementation

Automated testing ensures your dark mode works correctly across different scenarios. The pdf skill can help generate accessibility reports for your themed interfaces:

```
/pdf create accessibility audit for dark mode contrast ratios
```

For visual regression testing, Playwright makes it straightforward to capture both themes:

```javascript
// playwright.config.js
const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
 projects: [
 { name: 'light-mode', use: { colorScheme: 'light' } },
 { name: 'dark-mode', use: { colorScheme: 'dark' } },
 ],
});
```

```javascript
// theme.spec.js
const { test, expect } = require('@playwright/test');

test('dark mode applies correct background color', async ({ page }) => {
 await page.goto('/');
 const bg = await page.evaluate(() => {
 return getComputedStyle(document.documentElement)
 .getPropertyValue('--bg-primary').trim();
 });
 // In dark mode, bg should be the dark value
 expect(bg).toBe('#1a1a1a');
});

test('theme persists after page reload', async ({ page }) => {
 await page.goto('/');
 await page.click('#theme-toggle');
 await page.reload();
 const theme = await page.evaluate(() =>
 document.documentElement.getAttribute('data-theme')
 );
 expect(theme).toBe('dark');
});
```

For contrast ratio testing, tools like `axe-core` integrate with Playwright and flag WCAG violations automatically, covering both your light and dark themes in a single CI run.

## Common Pitfalls to Avoid

Several recurring mistakes show up in dark mode implementations:

Hardcoded colors in component CSS: If a developer adds `color: #333` directly to a component instead of `color: var(--text-primary)`, that component breaks in dark mode and the bug may not surface until a user reports it. Enforce custom property usage through linting.

Forgetting form elements: Browser-native form inputs (`<input>`, `<select>`, `<textarea>`) have their own styling that doesn't automatically follow your custom properties. Always include explicit dark-mode overrides for form elements.

Not testing with real OLED devices: What looks acceptable on a laptop monitor may have poor contrast on an OLED phone screen. Test on actual hardware before shipping.

Missing print stylesheet adjustments: If your app can be printed, add a `@media print` override that forces light mode colors regardless of theme.

## Best Practices Summary

Keep these principles in mind as you implement dark mode: use CSS custom properties for maintainability, always persist user preferences, prevent flash of wrong theme with inline scripts, respect system preferences on first visit, test both themes thoroughly with automated tools, ensure sufficient color contrast for accessibility, handle images and media explicitly, and address form element styling separately.

Dark mode implementation doesn't have to be complicated. By building on CSS custom properties and following these patterns, you create a flexible theming system that serves all users regardless of their preference or device settings. The investment pays off in user satisfaction, accessibility compliance, and a codebase that makes future theme changes straightforward to execute.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-dark-mode-implementation-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Cookie Consent Implementation: A Practical Guide](/claude-code-cookie-consent-implementation/)
- [Claude Code CSS Animations Workflow Guide](/claude-code-css-animations-workflow-guide/)
- [Claude Code Tailwind CSS V4 Migration Guide](/claude-code-tailwind-css-v4-migration-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


