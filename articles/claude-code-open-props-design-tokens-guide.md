---

layout: default
title: "Claude Code + Open Props Design Tokens (2026)"
description: "Use Open Props design tokens with Claude Code for consistent spacing, colors, and typography in frontend projects. Integration patterns and examples."
date: 2026-03-14
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
author: "Claude Skills Guide"
permalink: /claude-code-open-props-design-tokens-guide/
reviewed: true
score: 7
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
---

Open Props has become one of the most popular CSS variable-based design systems for developers who want lightweight, customizable design tokens without the overhead of a full component library. When combined with Claude Code's AI capabilities, you can rapidly scaffold design systems, generate consistent token usage, and maintain design consistency across projects. This guide walks through practical approaches to integrating Open Props with your Claude Code workflow.

## What Are Open Props Design Tokens

Open Props is a CSS-native design token system that provides variables for colors, spacing, typography, shadows, and more. Unlike heavy UI frameworks, Open Props lets you import only what you need. The tokens are CSS custom properties that follow a consistent naming convention, making them easy to understand and modify.

The core tokens include color scales, spacing units, font sizes, border radii, and shadows. Each category follows a predictable pattern:

```css
--gray-1: #f7f7f8;
--gray-2: #ececf1;
--gray-6: #545459;
--gray-12: #0d0d0f;

--space-1: 0.25rem;
--space-2: 0.5rem;
--space-4: 1rem;
--space-8: 2rem;

--font-size-xs: 0.75rem;
--font-size-sm: 0.875rem;
--font-size-base: 1rem;
```

The numbering convention is intentional. Lower numbers represent lighter, smaller, or softer values. Higher numbers represent darker, larger, or stronger values. Once you internalize this pattern, you can predict token names without consulting documentation. which is a huge productivity boost when working with Claude Code's generative prompts.

## Open Props vs. Other Design Token Systems

Before committing to Open Props, it helps to understand how it compares to alternatives. The decision affects how you prompt Claude Code and what kind of output you can expect.

| System | Approach | Bundle Size | Customization | Claude Code Fit |
|---|---|---|---|---|
| Open Props | CSS custom properties | ~7KB (tree-shaken) | High | Excellent. tokens map directly to CSS output |
| Tailwind CSS | Utility classes + config | 20KB+ (purged) | High | Good. needs class-based prompts |
| CSS Modules + vars | Manual custom props | Zero overhead | Total | Good. but no baseline system |
| Styled Components tokens | JS-in-CSS | 15KB+ runtime | High | Moderate. JSX-centric output |
| Design Tokens (W3C spec) | JSON → build step | Varies | High | Moderate. requires build tooling |

Open Props wins for projects where you want raw CSS flexibility, minimal build tooling, and the ability to generate component styles directly. Claude Code produces cleaner output when working with Open Props because the token names are semantic enough to appear in natural language prompts.

## Setting Up Open Props with Claude Code

When starting a new project, you can use Claude Code to generate the complete Open Props setup. The frontend-design skill provides structured guidance for component-based architecture, but you can also work directly with Open Props for maximum flexibility.

First, install Open Props via your preferred package manager:

```bash
npm install open-props
```

Then import the tokens you need in your CSS:

```css
@import "open-props/style";
@import "open-props/normalize";
```

For better tree-shaking, import individual token categories:

```css
@import "open-props/colors";
@import "open-props/spacing";
@import "open-props/typography";
```

If you are using Vite, PostCSS, or a similar build tool, you can configure automatic token imports so every CSS file has access to the full token set without manual imports. Add this to your `postcss.config.js`:

```js
// postcss.config.js
module.exports = {
 plugins: {
 'postcss-jit-props': {
 ...require('open-props'),
 },
 },
};
```

The `postcss-jit-props` plugin only injects the tokens you actually use, which keeps your final CSS bundle lean even if you import the entire Open Props library in your source files.

## Using Claude Code to Generate Token-Based Components

Claude Code excels at generating consistent component styles using your design tokens. When working on a new component, describe your requirements and reference the specific Open Props tokens you want to use:

```
Create a card component using Open Props tokens.
Use --gray-1 for background, --gray-12 for text,
--space-4 for padding, --radius-lg for border-radius,
and --shadow-3 for the shadow.
```

Claude Code will generate markup and styles like this:

```html
<article class="card">
 <h2 class="card-title">Card Title</h2>
 <p class="card-content">Your content here</p>
</article>
```

```css
.card {
 background: var(--gray-1);
 color: var(--gray-12);
 padding: var(--space-4);
 border-radius: var(--radius-lg);
 box-shadow: var(--shadow-3);
}
```

You can push further by asking Claude Code to build out interactive states using the animation and transition tokens:

```
Add hover and focus states to the card component using
--shadow-5 on hover and --transition-2 for the animation.
Keep all values as Open Props tokens.
```

The resulting output stays consistent with the token system rather than introducing hard-coded values, which is the main benefit of working this way. If you later need to adjust the shadow depth globally, you change one token reference, not dozens of component files.

## Real-World Scenario: Building a Design System with Claude Code

Consider a practical scenario: you are building a small SaaS product with five or six core UI components. buttons, cards, forms, navigation, badges, and modals. Using Open Props with Claude Code, you can scaffold all of these in a single session by providing a clear token baseline.

Start by creating a `tokens.css` file that establishes your project's semantic layer on top of Open Props:

```css
/* tokens.css */
@import "open-props/colors";
@import "open-props/spacing";
@import "open-props/typography";
@import "open-props/shadows";
@import "open-props/borders";
@import "open-props/animations";

:root {
 --brand-primary: var(--indigo-6);
 --brand-primary-hover: var(--indigo-7);
 --brand-surface: var(--gray-0);
 --text-primary: var(--gray-12);
 --text-secondary: var(--gray-7);
 --border-default: var(--gray-3);
}
```

Then prompt Claude Code with the component specs one at a time, referencing this semantic layer:

```
Build a primary button component using the semantic tokens
from tokens.css. Use --brand-primary for background,
white for text, --space-2 for vertical padding, --space-4
for horizontal padding. Include hover state with
--brand-primary-hover. Use --transition-1 for smooth
state changes.
```

Claude Code generates:

```css
.btn-primary {
 background: var(--brand-primary);
 color: white;
 padding: var(--space-2) var(--space-4);
 border: none;
 border-radius: var(--radius-2);
 cursor: pointer;
 font-size: var(--font-size-sm);
 font-weight: var(--font-weight-6);
 transition: background var(--transition-1),
 transform var(--transition-1),
 box-shadow var(--transition-1);
}

.btn-primary:hover {
 background: var(--brand-primary-hover);
 box-shadow: var(--shadow-2);
 transform: translateY(-1px);
}

.btn-primary:active {
 transform: translateY(0);
 box-shadow: none;
}
```

This component is fully token-driven. Changing `--brand-primary` in your semantic layer propagates throughout the entire design system automatically.

## Extending Open Props with Custom Tokens

Your project may require tokens beyond what Open Props provides. Create a custom tokens file that extends the base system:

```css
/* custom-tokens.css */
:root {
 /* Brand colors extending Open Props */
 --brand-primary: #6366f1;
 --brand-secondary: #8b5cf6;
 --brand-surface: #fafafa;

 /* Semantic tokens */
 --color-success: #22c55e;
 --color-warning: #f59e0b;
 --color-error: #ef4444;

 /* Custom spacing */
 --space-container: var(--space-12);
 --space-section: var(--space-16);

 /* Component-level tokens */
 --card-padding: var(--space-4);
 --nav-height: 4rem;
 --sidebar-width: 16rem;
}
```

Import your custom tokens after Open Props to allow overrides:

```css
@import "open-props/colors";
@import "open-props/spacing";
@import "custom-tokens";
```

The layered approach. base tokens, then semantic tokens, then component tokens. is a proven pattern. It gives you the flexibility to rebrand by changing semantic tokens without touching any component files.

## Working with Typography Tokens

Open Props typography tokens provide a comprehensive scale. The font-size tokens work with your root font size to create consistent type hierarchies. Combine them with the line-height and font-weight tokens for complete type styles:

```css
.heading-1 {
 font-size: var(--font-size-7);
 line-height: var(--font-lineheight-1);
 font-weight: var(--font-weight-7);
}

.body-text {
 font-size: var(--font-size-3);
 line-height: var(--font-lineheight-3);
}
```

A practical addition is mapping these tokens to semantic names that your team understands:

```css
:root {
 --text-display: var(--font-size-8);
 --text-heading: var(--font-size-6);
 --text-subheading: var(--font-size-5);
 --text-body: var(--font-size-3);
 --text-caption: var(--font-size-1);
 --text-label: var(--font-size-2);
}
```

When you prompt Claude Code using these semantic names rather than raw token numbers, you get more predictable output because the naming intent is clearer. A prompt that says "use --text-heading for the card title" is less ambiguous than "use --font-size-6."

For projects using the tdd skill for test-driven development, you can verify typography consistency by checking computed styles against these token values.

## Animation and Transition Tokens

Open Props includes animation tokens for smooth transitions and micro-interactions. Use these tokens to maintain consistent motion design:

```css
.button {
 transition: background var(--transition-1), transform var(--transition-1);
}

.button:hover {
 transform: translateY(-1px);
}

.button:active {
 transform: translateY(0);
}
```

The animation tokens cover durations, easings, and keyframe definitions, making it simple to create cohesive motion patterns throughout your application.

Open Props also ships keyframe animations you can apply directly:

```css
.toast-enter {
 animation: var(--animation-slide-in-up);
}

.spinner {
 animation: var(--animation-spin) infinite;
}

.pulse-element {
 animation: var(--animation-pulse);
}
```

When prompting Claude Code for animated components, reference the animation token by name:

```
Create a notification toast component that slides in using
--animation-slide-in-up. Use --color-success as the
background for success messages and --space-3 for padding.
```

This produces output that uses the token system throughout rather than mixing hard-coded values with variable references.

## Dark Mode with Open Props

Open Props includes a built-in dark mode color scheme. The color tokens automatically remap when the user's system preference is dark, or you can control it manually with a class:

```css
@import "open-props/colors";

/* Light mode is the default */
/* Dark mode activates automatically via prefers-color-scheme */

/* Override with a class for manual control */
[data-theme="dark"] {
 color-scheme: dark;
}
```

The gray scale tokens automatically shift. `--gray-1` becomes very dark and `--gray-12` becomes very light in dark mode. This means any component built with the gray scale adapts to dark mode without additional CSS. Prompt Claude Code to use this behavior explicitly:

```
Build a sidebar navigation component using only Open Props
gray tokens for backgrounds and text. It should work
correctly in both light and dark mode without any
prefers-color-scheme media queries.
```

## Practical Workflow with Claude Code Skills

When working on complex projects, combine multiple Claude Code skills for optimal results. The pdf skill helps generate design documentation from your token specifications. Use supermemory to remember project-specific token conventions across sessions.

For team projects, document your custom token extensions in a central location. When onboarding new developers, have Claude Code explain the token system structure using the frontend-design skill's component patterns.

A useful workflow is to start each design session by giving Claude Code a brief token inventory:

```
Project context: We use Open Props with a custom semantic
layer. Key tokens: --brand-primary (indigo), --text-primary
(--gray-12), --card-padding (--space-4). All components
use these semantic tokens, not raw Open Props values.
```

This primes Claude Code to generate output that respects your conventions rather than defaulting to arbitrary values.

## Performance Considerations

Open Props tokens are CSS custom properties, which means they inherit and cascade naturally. However, excessive token usage can impact CSS specificity and maintenance. Follow these practices:

- Prefer semantic tokens over raw token references in components
- Limit custom token additions to what's actually needed
- Use the individual token imports for better performance
- Use `postcss-jit-props` in production to strip unused token definitions

For very large applications, consider organizing tokens by feature area to make auditing and refactoring easier. A tokens directory with files like `colors.css`, `spacing.css`, `typography.css`, and `components.css` scales better than a single flat file as the system grows.

## Conclusion

Open Props provides a flexible foundation for design token management that pairs excellently with Claude Code's generative capabilities. By establishing clear token conventions and using AI-assisted code generation, you can build consistent design systems efficiently. The key is starting with the base tokens, adding a semantic layer that matches your project's language, and prompting Claude Code with those semantic names for output that fits naturally into your existing system.

The combination is especially powerful for rapid prototyping. You can go from a rough component description to a fully token-driven, dark-mode-aware implementation in a single prompt cycle, then refine from there. That speed advantage compounds as your token system matures and Claude Code learns your project's conventions through context.

---


**Try it:** Browse 155+ skills in our [Skill Finder](/skill-finder/).
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-open-props-design-tokens-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Design System Tokens: A Frontend Developer Guide](/claude-code-design-system-tokens-frontend-developer-guide/)
- [AI Assisted Architecture Design Workflow Guide](/ai-assisted-architecture-design-workflow-guide/)
- [Chrome Extension Color Picker Design: A Developer's Guide](/chrome-extension-color-picker-design/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

**Quick setup →** Launch your project with our [Project Starter](/starter/).
