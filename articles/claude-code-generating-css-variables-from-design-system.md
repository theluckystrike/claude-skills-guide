---

layout: default
title: "Claude Code Generating CSS Variables"
description: "Learn how to use Claude Code skills to automatically generate CSS variables from design systems. Practical examples for extracting colors, typography."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-generating-css-variables-from-design-system/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---

Design systems have become essential for maintaining consistent user interfaces across applications. However, translating design tokens from tools like Figma, Sketch, or style guides into CSS variables remains a tedious manual process. Claude Code offers powerful capabilities to automate this workflow, transforming design specifications into production-ready CSS custom properties with minimal effort.

## Understanding the Design System to CSS Variables Pipeline

When working with design systems, you typically encounter design tokens, atomic values representing colors, typography, spacing, and other design attributes. These tokens often exist in JSON, YAML, or as documentation specifications. Claude Code can parse these inputs and generate corresponding CSS variables following established naming conventions.

The process involves three key stages: token extraction, variable transformation, and output generation. Claude Code excels at each stage through its file reading capabilities, code generation skills, and ability to work with structured data formats.

Understanding where your tokens come from matters as much as generating the output. Teams exporting from Figma via plugins like Token Studio produce JSON with nested group structures. Teams maintaining a hand-authored YAML spec have a flat, predictable format. Claude Code adapts to both, but you get cleaner output when you give it a clear description of your token file's structure at the start of the request.

## Extracting Colors from Design Specifications

One of the most common use cases involves converting a color palette from a design system into CSS variables. Suppose you have a design spec document with color values. You can ask Claude Code to analyze the specification and generate the appropriate CSS variables.

```
/extract-colors from the design-spec.md file and create CSS custom properties for all colors using the format --color-{name}-{shade}
```

Claude Code will read your design specification, identify color values (in hex, RGB, or HSL formats), and generate a complete CSS variables section. The output follows a semantic naming convention that makes maintenance straightforward.

For example, a design system with primary, secondary, and neutral color scales produces variables like:

```css
:root {
 /* Primary Colors */
 --color-primary-50: #eff6ff;
 --color-primary-100: #dbeafe;
 --color-primary-500: #3b82f6;
 --color-primary-600: #2563eb;
 --color-primary-900: #1e3a8a;

 /* Neutral Colors */
 --color-neutral-50: #fafafa;
 --color-neutral-100: #f5f5f5;
 --color-neutral-500: #6b7280;
 --color-neutral-900: #111827;
}
```

Notice that the palette uses numeric shades (50 through 900), matching the Tailwind-style scale many design tools generate. This is intentional: when your CSS variable names mirror the naming your designers already use in Figma, handoff friction disappears. Engineers read a Figma spec calling for `primary-600` and immediately know the corresponding variable name.

If your design system uses a different naming scheme, say, `brand-blue-light`, `brand-blue-mid`, `brand-blue-dark`, tell Claude Code your convention explicitly:

```
/extract-colors from design-spec.md and generate CSS custom properties using the format --color-{group}-{modifier}, where modifiers are light, mid, dark, and darkest
```

Claude Code will honor the naming structure you specify rather than imposing its own.

## Working with Typography Tokens

Typography systems often contain font families, sizes, weights, and line heights. Claude Code can transform these specifications into CSS custom properties that work smoothly with modern CSS features like `clamp()` for fluid typography.

```
/generate-typography-variables from typography-spec.json include font-family, font-size, font-weight, and line-height with rem units
```

This generates a comprehensive typography scale:

```css
:root {
 /* Font Families */
 --font-family-sans: 'Inter', system-ui, -apple-system, sans-serif;
 --font-family-display: 'Playfair Display', Georgia, serif;
 --font-family-mono: 'JetBrains Mono', 'Fira Code', monospace;

 /* Font Sizes (rem) */
 --font-size-xs: 0.75rem;
 --font-size-sm: 0.875rem;
 --font-size-base: 1rem;
 --font-size-lg: 1.125rem;
 --font-size-xl: 1.25rem;
 --font-size-2xl: 1.5rem;
 --font-size-3xl: 1.875rem;
 --font-size-4xl: 2.25rem;

 /* Font Weights */
 --font-weight-normal: 400;
 --font-weight-medium: 500;
 --font-weight-semibold: 600;
 --font-weight-bold: 700;

 /* Line Heights */
 --line-height-tight: 1.25;
 --line-height-normal: 1.5;
 --line-height-relaxed: 1.625;
}
```

For teams building responsive layouts, it's worth asking Claude Code to generate fluid type scale variants using `clamp()`. This eliminates the need for media query breakpoints just to scale text:

```css
:root {
 /* Fluid Font Sizes */
 --font-size-sm: clamp(0.8rem, 0.17vw + 0.76rem, 0.89rem);
 --font-size-base: clamp(1rem, 0.34vw + 0.91rem, 1.19rem);
 --font-size-lg: clamp(1.25rem, 0.61vw + 1.1rem, 1.58rem);
 --font-size-xl: clamp(1.56rem, 1vw + 1.31rem, 2.11rem);
 --font-size-2xl: clamp(1.95rem, 1.56vw + 1.56rem, 2.81rem);
}
```

To get this output, ask Claude Code to use a modular scale with fluid interpolation between your minimum and maximum viewport widths. Giving it your minimum viewport (e.g. 320px) and maximum viewport (e.g. 1440px) plus the base size at each end produces accurate `clamp()` values without manual arithmetic.

## Handling Spacing and Layout Tokens

Spacing systems typically follow a numeric scale (4, 8, 16, 24, 32, etc.). Claude Code can generate spacing variables that maintain consistency across your application:

```
/create-spacing-variables from spacing.json using 0.5rem base unit
```

The output includes not just literal spacing values but also semantic aliases:

```css
:root {
 /* Spacing Scale */
 --spacing-0: 0;
 --spacing-1: 0.25rem;
 --spacing-2: 0.5rem;
 --spacing-3: 0.75rem;
 --spacing-4: 1rem;
 --spacing-5: 1.25rem;
 --spacing-6: 1.5rem;
 --spacing-8: 2rem;
 --spacing-10: 2.5rem;
 --spacing-12: 3rem;
 --spacing-16: 4rem;

 /* Semantic Aliases */
 --spacing-inline-xs: var(--spacing-2);
 --spacing-inline-sm: var(--spacing-3);
 --spacing-inline-md: var(--spacing-4);
 --spacing-inline-lg: var(--spacing-6);

 --spacing-block-xs: var(--spacing-2);
 --spacing-block-sm: var(--spacing-4);
 --spacing-block-md: var(--spacing-6);
 --spacing-block-lg: var(--spacing-8);
}
```

The semantic aliases are the part that actually saves teams time. Rather than deciding per-component whether a button's vertical padding should be `--spacing-3` or `--spacing-4`, developers reach for `--spacing-inline-sm` and the decision has already been made by the design system. Claude Code can generate these aliases automatically if you describe your layout conventions, inline for horizontal rhythm, block for vertical rhythm, component for internal component padding.

You can also ask for border radius, shadow, and z-index tokens in the same pass:

```css
:root {
 /* Border Radius */
 --radius-sm: 0.25rem;
 --radius-md: 0.375rem;
 --radius-lg: 0.5rem;
 --radius-xl: 0.75rem;
 --radius-full: 9999px;

 /* Elevation / Shadows */
 --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
 --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
 --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
 --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);

 /* Z-Index */
 --z-base: 0;
 --z-dropdown: 10;
 --z-sticky: 20;
 --z-overlay: 30;
 --z-modal: 40;
 --z-toast: 50;
}
```

## Advanced: Creating Theme Composables

For more complex design systems, you might need to generate theme-aware variables that respond to light/dark modes or other contextual changes. Claude Code can create sophisticated CSS variable structures:

```
/generate-theme-variables from design-tokens.json include light and dark mode variations with prefers-color-scheme media queries
```

This produces a solid theming system:

```css
:root {
 /* Light Mode (Default) */
 --color-background: #ffffff;
 --color-surface: #f9fafb;
 --color-text-primary: #111827;
 --color-text-secondary: #6b7280;
 --color-border: #e5e7eb;

 /* Semantic Color Aliases */
 --color-action: var(--color-primary-600);
 --color-success: var(--color-green-600);
 --color-warning: var(--color-amber-600);
 --color-error: var(--color-red-600);
}

/* Dark Mode */
@media (prefers-color-scheme: dark) {
 :root {
 --color-background: #111827;
 --color-surface: #1f2937;
 --color-text-primary: #f9fafb;
 --color-text-secondary: #9ca3af;
 --color-border: #374151;
 }
}

/* Manual Dark Mode Override */
[data-theme="dark"] {
 --color-background: #111827;
 --color-surface: #1f2937;
 --color-text-primary: #f9fafb;
 --color-text-secondary: #9ca3af;
 --color-border: #374151;
}
```

The dual approach, `prefers-color-scheme` media query plus `[data-theme]` attribute, is important. The media query handles users who never interact with a theme toggle. The attribute override handles users who want to set their own preference independent of the OS setting. Claude Code generates both by default when you ask for dark mode support.

For product teams that need more than two themes (brand themes, high-contrast accessibility themes, white-label variations), Claude Code can generate a complete token layer:

```css
/* High Contrast Theme */
[data-theme="high-contrast"] {
 --color-background: #000000;
 --color-surface: #0a0a0a;
 --color-text-primary: #ffffff;
 --color-text-secondary: #e0e0e0;
 --color-border: #ffffff;
 --color-action: #ffff00;
}

/* Brand Theme: Sunset */
[data-theme="sunset"] {
 --color-primary-500: #f97316;
 --color-primary-600: #ea580c;
 --color-action: var(--color-primary-600);
}
```

The pattern of using semantic aliases that point to primitive values means swapping a full brand theme only requires overriding the primitives, the semantic layer inherits the new values automatically.

## Comparison: Manual vs. Claude Code Token Generation

| Task | Manual Approach | With Claude Code |
|---|---|---|
| 50-token color palette | 20-30 minutes of copy-paste | Under 2 minutes |
| Adding dark mode variants | Duplicate and adjust every value by hand | Single request with automatic pairing |
| Renaming a token group | Find-and-replace across multiple files | Specify new convention, regenerate |
| DTCG format conversion | Learn spec, write transform script | Direct request with format flag |
| Fluid typography with `clamp()` | Manual math or third-party calculator | Inline with font scale generation |
| Semantic alias layer | Design decision + tedious wiring | Generated alongside primitives |

The time savings compound when you consider the revision cycle. Design changes are inevitable. When your designer adjusts the primary palette in Figma and re-exports the token JSON, the old workflow meant manually tracking down every changed value and updating your CSS. With Claude Code, you re-run the generation command and get a fresh file in seconds.

## Integration with Design Tokens Format

Claude Code understands common design token formats including the Design Tokens Format Module (DTCG) specification. You can directly import token files and request specific output formats:

```
/convert design-tokens.json to CSS custom properties using DTCG format preserve group hierarchy
```

This approach maintains the logical organization of your tokens while generating clean, maintainable CSS.

A DTCG-format token file uses `$value` and `$type` keys to describe each token. When Claude Code encounters this structure, it respects the group hierarchy, producing CSS that mirrors the logical groupings your designers established. For teams where both designers and engineers interact with the token file, this consistency reduces the cognitive overhead of context-switching between tools.

## Practical Workflow Example

A complete workflow might look like this:

1. Export your design tokens from Figma using a plugin like "Design Tokens" or "Token Studio"
2. Save the tokens as JSON or YAML
3. Use Claude Code to generate the CSS variables:

```
/css-variables generate --input design-tokens.json --output src/styles/variables.css --format css-custom-properties
```

4. Import the generated file in your main stylesheet:

```css
@import './variables.css';

/* Use the variables */
.button {
 background-color: var(--color-primary-600);
 color: white;
 padding: var(--spacing-3) var(--spacing-6);
 border-radius: var(--spacing-1);
 font-family: var(--font-family-sans);
}
```

5. For CI/CD integration, add the generation step to your build pipeline so the CSS file regenerates whenever the token JSON changes:

```yaml
.github/workflows/tokens.yml
name: Regenerate CSS Tokens
on:
 push:
 paths:
 - 'design-tokens.json'
jobs:
 generate:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4
 - name: Generate CSS variables
 run: claude-code /css-variables generate --input design-tokens.json --output src/styles/variables.css
 - name: Commit updated variables
 run: |
 git config user.email "ci@example.com"
 git config user.name "CI Bot"
 git add src/styles/variables.css
 git commit -m "chore: regenerate CSS variables from design tokens" || echo "No changes"
 git push
```

This closes the loop: a designer exports updated tokens, pushes the JSON file, and the CSS layer updates automatically without any engineer involvement.

## Debugging Common Token Generation Issues

A few problems come up repeatedly when generating CSS variables from design system tokens.

Naming collisions occur when two token groups produce the same variable name. If your color scale has `primary.500` and your semantic layer also defines a `primary` key, you end up with `--color-primary` and `--color-primary-500` coexisting, which is confusing. Tell Claude Code to flag potential collisions during generation and suggest a resolution strategy.

Missing fallback values are a problem in older browsers that don't support CSS custom properties. For teams with IE11 requirements (rare but still present in enterprise contexts), ask Claude Code to generate a PostCSS-compatible output that includes both the variable and a static fallback:

```css
.button {
 background-color: #2563eb; /* fallback */
 background-color: var(--color-primary-600);
}
```

Circular references in semantic alias layers can produce undefined variables at runtime. When a semantic alias points to another alias that points back to the original, browsers silently fall through to the initial value. Claude Code can detect circular references during generation and break them by substituting the resolved primitive value.

## Conclusion

Claude Code transforms the tedious process of creating CSS variables from design systems into a streamlined, automated workflow. By using Claude's ability to read design specifications, understand structured data formats, and generate clean code, you can maintain design system consistency while significantly reducing manual effort. Whether you're working with simple color palettes or complex multi-theme systems, Claude Code provides the flexibility and power to generate production-ready CSS custom properties that integrate smoothly into modern web projects.

The most durable benefit is not the time saved on any single token generation, it is the fact that your CSS variables stay synchronized with your design source of truth. When tokens and variables drift apart, the design system loses credibility with engineers and designers alike. Automating the generation step removes drift from the equation entirely.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-generating-css-variables-from-design-system)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Design System Tokens: A Frontend Developer Guide](/claude-code-design-system-tokens-frontend-developer-guide/)
- [Claude Code Design Token Automation from Figma Variables](/claude-code-design-token-automation-from-figma-variables/)
- [Claude Code for Learning System Design Concepts](/claude-code-for-learning-system-design-concepts/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


