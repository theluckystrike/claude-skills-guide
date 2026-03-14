---

layout: default
title: "Claude Code Generating CSS Variables from Design System"
description: "Learn how to use Claude Code skills to automatically generate CSS variables from design systems. Practical examples for extracting colors, typography, spacing, and more."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-generating-css-variables-from-design-system/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
---


# Claude Code Generating CSS Variables from Design System

Design systems have become essential for maintaining consistent user interfaces across applications. However, translating design tokens from tools like Figma, Sketch, or style guides into CSS variables remains a tedious manual process. Claude Code offers powerful capabilities to automate this workflow, transforming design specifications into production-ready CSS custom properties with minimal effort.

## Understanding the Design System to CSS Variables Pipeline

When working with design systems, you typically encounter design tokens—atomic values representing colors, typography, spacing, and other design attributes. These tokens often exist in JSON, YAML, or as documentation specifications. Claude Code can parse these inputs and generate corresponding CSS variables following established naming conventions.

The process involves three key stages: token extraction, variable transformation, and output generation. Claude Code excels at each stage through its file reading capabilities, code generation skills, and ability to work with structured data formats.

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

## Advanced: Creating Theme Composables

For more complex design systems, you might need to generate theme-aware variables that respond to light/dark modes or other contextual changes. Claude Code can create sophisticated CSS variable structures:

```
/generate-theme-variables from design-tokens.json include light and dark mode variations with prefers-color-scheme media queries
```

This produces a robust theming system:

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

## Integration with Design Tokens Format

Claude Code understands common design token formats including the Design Tokens Format Module (DTCG) specification. You can directly import token files and request specific output formats:

```
/convert design-tokens.json to CSS custom properties using DTCG format preserve group hierarchy
```

This approach maintains the logical organization of your tokens while generating clean, maintainable CSS.

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

## Conclusion

Claude Code transforms the tedious process of creating CSS variables from design systems into a streamlined, automated workflow. By using Claude's ability to read design specifications, understand structured data formats, and generate clean code, you can maintain design system consistency while significantly reducing manual effort. Whether you're working with simple color palettes or complex multi-theme systems, Claude Code provides the flexibility and power to generate production-ready CSS custom properties that integrate smoothly into modern web projects.
