---
layout: default
title: "Claude Code Design System Tokens"
description: "Learn how to use Claude Code's design system tokens for building consistent, professional user interfaces with the canvas-design skill."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, design-system, frontend, canvas-design, tokens, claude-skills]
permalink: /claude-code-design-system-tokens-frontend-developer-guide/
reviewed: true
score: 7
geo_optimized: true
---
Claude Code Design System Tokens: A Frontend Developer Guide

Design system tokens are the foundation of consistent, scalable user interfaces. When working with Claude Code's canvas-design skill, understanding how to use these tokens can dramatically improve your workflow and output quality. This guide walks you through practical patterns for integrating design system tokens into your frontend development process, from basic color usage through theming, component composition, and dark mode support.

What Are Design System Tokens?

Design system tokens are semantic, platform-agnostic values that represent design decisions. Instead of hardcoding colors like `#0066CC` throughout your codebase, you use semantic tokens like `primary-color` or `text-primary`. This abstraction layer makes it easy to:

- Maintain consistency across your entire application
- Support multiple themes (light/dark mode)
- Update styling globally from a single source
- Create design systems that scale
- Hand off designs to engineers without ambiguity

Claude Code's canvas-design skill uses a rich set of tokens organized by category: colors, typography, spacing, shadows, and borders. Each token has a purpose-specific name that communicates its intended use.

There are two levels of tokens worth distinguishing from the start:

| Token Type | Example | Purpose |
|---|---|---|
| Primitive | `blue.500`, `gray.200` | Raw scale values. rarely used directly |
| Semantic | `primary.500`, `text-muted` | Communicate intent. use these in components |
| Component | `button-bg`, `input-border` | Scoped to a specific component |

Semantic tokens are the workhorse of a design system. When you change a semantic token's underlying value (say, updating `primary.500` from `#0066CC` to `#0052A3`), every component that references it updates automatically.

## Working with Color Tokens

Color tokens in the canvas-design skill follow a hierarchical naming convention. Here's how to apply them effectively:

```javascript
// Using color tokens in your component styles
const buttonStyles = {
 backgroundColor: 'primary.500', // Main brand color
 color: 'white',
 borderRadius: 'md',
 padding: '4 8', // 4 units vertical, 8 horizontal
};

const buttonHover = {
 backgroundColor: 'primary.600', // Darker shade for hover state
};

// Accessible text with semantic tokens
const cardTitle = {
 color: 'gray.900',
 fontSize: 'xl',
 fontWeight: 'semibold',
};
```

The token hierarchy uses scales from 50 to 900, where lower numbers are lighter and higher numbers are darker. This scale system allows you to create visual hierarchy without guessing hex values.

## Practical Color Scale Reference

When you need to choose a shade, this mental model helps:

| Scale | Visual Weight | Common Uses |
|---|---|---|
| 50 | Near white tint | Hover backgrounds, subtle fills |
| 100 | Very light | Disabled state backgrounds |
| 200 | Light | Borders on light backgrounds |
| 300 | Light-medium | Placeholder text |
| 400 | Medium | Secondary icons |
| 500 | Base brand | Primary buttons, links |
| 600 | Dark | Hover state of primary |
| 700 | Darker | Active/pressed states |
| 800 | Very dark | Text on colored backgrounds |
| 900 | Near black | High-contrast text |

Using this scale consistently means your interactive states (default → hover → active) will always follow the pattern `500 → 600 → 700`, which creates a predictable visual rhythm that users learn quickly.

## Accessible Color Combinations

Color tokens also help you maintain WCAG contrast ratios. Here are combinations that reliably pass AA contrast (4.5:1 for normal text):

```javascript
// All of these meet WCAG AA for normal text
const accessiblePairs = {
 default: { bg: 'white', text: 'gray.900' }, // ~16:1
 subtle: { bg: 'gray.50', text: 'gray.700' }, // ~6:1
 inverted: { bg: 'gray.900', text: 'white' }, // ~16:1
 brand: { bg: 'primary.500', text: 'white' }, // varies by brand. verify
 warning: { bg: 'yellow.100', text: 'yellow.800' }, // ~7:1
 error: { bg: 'red.50', text: 'red.700' }, // ~5:1
};
```

Claude Code can audit your component library against these pairs and flag any combinations that fall below the threshold.

## Typography Tokens for Consistent Text

Typography tokens handle font families, sizes, weights, and line heights. Here's a practical example:

```javascript
// Define typography styles using tokens
const headingStyles = {
 fontFamily: 'heading', // Heading font family
 fontWeight: 'bold',
 lineHeight: 'tight',
 color: 'gray.900',
};

const bodyStyles = {
 fontFamily: 'body', // Body font family
 fontSize: 'base', // Base font size (typically 16px)
 lineHeight: 'normal',
 color: 'gray.700',
};

const captionStyles = {
 fontSize: 'sm', // Small text
 color: 'gray.500',
};
```

Typography tokens automatically adapt to your theme configuration, making global font changes straightforward.

## Building a Type Scale

A well-designed type scale creates hierarchy without needing to reach for font weight or color. The canvas-design skill ships with a modular scale that covers most needs:

```javascript
// Complete type scale reference
const typeScale = {
 '2xs': '0.625rem', // 10px. legal fine print
 'xs': '0.75rem', // 12px. labels, badges
 'sm': '0.875rem', // 14px. secondary text, captions
 'base': '1rem', // 16px. body copy
 'lg': '1.125rem', // 18px. lead text, callouts
 'xl': '1.25rem', // 20px. card titles
 '2xl': '1.5rem', // 24px. section headings
 '3xl': '1.875rem', // 30px. page subheadings
 '4xl': '2.25rem', // 36px. page headings
 '5xl': '3rem', // 48px. hero headings
};

// Example: A blog post layout using the scale
const blogPostStyles = {
 title: { fontSize: '4xl', fontWeight: 'bold', lineHeight: 'tight' },
 subtitle: { fontSize: '2xl', fontWeight: 'semibold', color: 'gray.700' },
 byline: { fontSize: 'sm', color: 'gray.500' },
 body: { fontSize: 'lg', lineHeight: 'relaxed', color: 'gray.800' },
 caption: { fontSize: 'xs', color: 'gray.400', fontStyle: 'italic' },
};
```

When Claude Code generates a layout, it picks from these scales automatically. You can ask it to "use a tighter type scale" or "make the heading hierarchy more pronounced" and it will adjust token references accordingly.

## Spacing and Layout Tokens

Spacing tokens use a consistent scale that ensures visual rhythm throughout your interface:

```javascript
// Spacing token usage
const cardContainer = {
 padding: '6', // Generous padding
 marginBottom: '4', // Space between cards
 gap: '3', // Gap between flex children
};

const formField = {
 marginBottom: '4', // Consistent field spacing
 paddingX: '4', // Horizontal padding only
};
```

The spacing scale typically follows: 0, 1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 56, 64. Each step increases the spacing by a consistent multiplier.

## Spatial Reasoning with the Scale

A common mistake is reaching for arbitrary pixel values when a token would do. Here's a practical mapping for common layout scenarios:

```javascript
// Component internal spacing. tight contexts
const inlineChip = {
 paddingX: '2', // 8px. tight inline element
 paddingY: '1', // 4px
 gap: '1', // 4px between icon and label
};

// Component internal spacing. comfortable contexts
const formCard = {
 padding: '6', // 24px. comfortable card
 gap: '4', // 16px between fields
};

// Section-level spacing. page layout
const pageSection = {
 paddingY: '16', // 64px. section breathing room
 gap: '8', // 32px between section children
};

// Margin between major page sections
const sectionSeparator = {
 marginTop: '24', // 96px. clear visual separation
};
```

Using the scale consistently means your eye picks up the rhythm intuitively. Components that use `gap: '4'` visually group themselves; components separated by `marginTop: '12'` feel like distinct sections.

## Shadow and Elevation Tokens

Shadows create depth and indicate interactive states. The canvas-design skill provides tokens for various elevation levels:

```javascript
// Elevation tokens
const cardBase = {
 backgroundColor: 'white',
 borderRadius: 'lg',
 boxShadow: 'sm', // Subtle shadow for cards
};

const cardHover = {
 boxShadow: 'md', // Medium shadow on hover
 transform: 'translateY(-2px)', // Subtle lift effect
};

const modalOverlay = {
 backgroundColor: 'blackAlpha.600', // Semi-transparent overlay
 boxShadow: 'xl', // Strong shadow for modals
};
```

## Shadow as a Communication Tool

Elevation tokens do more than look nice. they communicate interactive affordance. A consistent elevation system tells users what they can click and what will appear on top of what:

| Shadow Token | Elevation Level | Use Case |
|---|---|---|
| `none` | 0. flat | Inline elements, flat cards |
| `xs` | 1. barely lifted | Table rows, subtle cards |
| `sm` | 2. card | Default card elevation |
| `md` | 3. raised | Hovered cards, sticky headers |
| `lg` | 4. floating | Dropdowns, popovers |
| `xl` | 5. modal | Dialogs, drawers |
| `2xl` | 6. max | Full-screen overlays |

```javascript
// Applying elevation consistently
const dropdown = {
 boxShadow: 'lg', // Floating above content
 borderRadius: 'md',
 border: '1px solid',
 borderColor: 'gray.200',
};

const tooltip = {
 boxShadow: 'md', // Less elevation than a dropdown
 borderRadius: 'sm',
 backgroundColor: 'gray.900',
 color: 'white',
};
```

## Border and Radius Tokens

Consistent border and radius values tie your interface together:

```javascript
// Border tokens
const inputField = {
 borderWidth: '1px',
 borderColor: 'gray.300',
 borderRadius: 'md', // Medium rounded corners
};

const inputFocus = {
 borderColor: 'primary.500',
 boxShadow: '0 0 0 3px primary.100', // Focus ring
};

// Button variations
const buttonPrimary = {
 borderRadius: 'md',
};

const buttonPill = {
 borderRadius: 'full', // Fully rounded (pill shape)
};
```

## Radius as Brand Personality

The border radius scale is one of the most powerful brand levers available. The same layout with different radii reads as completely different personalities:

```javascript
// Sharp / professional / enterprise
const enterpriseTheme = {
 radii: {
 sm: '2px',
 md: '4px',
 lg: '6px',
 full: '9999px',
 }
};

// Friendly / rounded / consumer
const consumerTheme = {
 radii: {
 sm: '8px',
 md: '12px',
 lg: '16px',
 full: '9999px',
 }
};

// Pill-heavy / modern / SaaS
const saasTheme = {
 radii: {
 sm: '4px',
 md: '8px',
 lg: '12px',
 full: '9999px', // Used heavily for buttons and badges
 }
};
```

Claude Code will ask about your brand personality when you start a canvas-design session. Providing this context up front means the generated tokens will match your product's voice without manual adjustment.

## Combining Tokens for Component Patterns

The real power of design tokens emerges when you combine them into reusable component patterns:

```javascript
// A button component pattern
const createButton = (variant = 'primary') => {
 const variants = {
 primary: {
 backgroundColor: 'primary.500',
 color: 'white',
 _hover: { backgroundColor: 'primary.600' },
 _active: { backgroundColor: 'primary.700' },
 },
 secondary: {
 backgroundColor: 'gray.100',
 color: 'gray.800',
 _hover: { backgroundColor: 'gray.200' },
 _active: { backgroundColor: 'gray.300' },
 },
 outline: {
 backgroundColor: 'transparent',
 borderWidth: '1px',
 borderColor: 'primary.500',
 color: 'primary.500',
 _hover: { backgroundColor: 'primary.50' },
 },
 };

 return {
 padding: '3 6',
 borderRadius: 'md',
 fontWeight: 'medium',
 transition: 'all 0.2s',
 ...variants[variant],
 };
};
```

## Building a Form Component Library

Forms are where token consistency matters most. Users fill out dozens of forms. inconsistency in input styling creates cognitive friction. Here's a complete token-driven form system:

```javascript
// Base input styles
const inputBase = {
 width: 'full',
 paddingX: '4',
 paddingY: '2.5',
 fontSize: 'base',
 lineHeight: 'normal',
 borderWidth: '1px',
 borderColor: 'gray.300',
 borderRadius: 'md',
 backgroundColor: 'white',
 color: 'gray.900',
 transition: 'border-color 0.15s, box-shadow 0.15s',
 _placeholder: { color: 'gray.400' },
 _hover: { borderColor: 'gray.400' },
 _focus: {
 borderColor: 'primary.500',
 boxShadow: '0 0 0 3px token(primary.100)',
 outline: 'none'
 },
 _disabled: {
 backgroundColor: 'gray.50',
 color: 'gray.400',
 cursor: 'not-allowed'
 },
 _invalid: {
 borderColor: 'red.500',
 _focus: { boxShadow: '0 0 0 3px token(red.100)' }
 }
};

// Label styles
const labelBase = {
 display: 'block',
 fontSize: 'sm',
 fontWeight: 'medium',
 color: 'gray.700',
 marginBottom: '1.5',
};

// Helper text
const helperText = {
 fontSize: 'sm',
 color: 'gray.500',
 marginTop: '1.5',
};

// Error message
const errorText = {
 fontSize: 'sm',
 color: 'red.600',
 marginTop: '1.5',
};
```

Every state is handled through token references. When you update your brand color, the focus ring updates automatically. When you switch to dark mode, the theme layer swaps `white` and `gray.900` without touching the component code.

## Theme Customization

The canvas-design skill supports theme customization through token overrides:

```javascript
// Custom theme configuration
const customTheme = {
 colors: {
 primary: {
 50: '#e6f2ff',
 100: '#b3d9ff',
 500: '#0066cc', // Your brand blue
 600: '#0052a3',
 700: '#003d7a',
 },
 },
 fonts: {
 heading: 'Inter, system-ui, sans-serif',
 body: 'Inter, system-ui, sans-serif',
 },
 radii: {
 none: '0',
 sm: '4px',
 md: '8px',
 lg: '12px',
 full: '9999px',
 },
};
```

## Implementing Dark Mode with Semantic Tokens

Dark mode is where the semantic token layer pays for itself. If you've used primitive tokens directly (`gray.900` for text), dark mode requires touching every component. Semantic tokens let you flip the theme in one place:

```javascript
// Semantic color tokens. light mode defaults
const semanticTokens = {
 colors: {
 'bg-default': { default: 'white', _dark: 'gray.900' },
 'bg-subtle': { default: 'gray.50', _dark: 'gray.800' },
 'bg-muted': { default: 'gray.100', _dark: 'gray.700' },
 'text-default': { default: 'gray.900', _dark: 'white' },
 'text-muted': { default: 'gray.600', _dark: 'gray.400' },
 'text-subtle': { default: 'gray.400', _dark: 'gray.500' },
 'border-default': { default: 'gray.200', _dark: 'gray.700' },
 'border-emphasis': { default: 'gray.400', _dark: 'gray.500' },
 }
};

// Component using semantic tokens. works in both modes
const cardWithDarkMode = {
 backgroundColor: 'bg-default',
 borderWidth: '1px',
 borderColor: 'border-default',
 color: 'text-default',
 padding: '6',
 borderRadius: 'lg',
 boxShadow: 'sm',
};
```

Claude Code understands this semantic layer pattern and will generate components using semantic tokens rather than primitives when you specify that dark mode support is required.

## Best Practices for Token Usage

1. Prefer semantic tokens: Use `text-primary` over `gray-900` when the meaning is clear. Semantic tokens communicate intent.

2. Maintain consistency: Don't mix raw values with tokens in the same component. Stick to the token system throughout.

3. Use scales wisely: When choosing a color or spacing value, look at the full scale first. Picking from established scales ensures visual harmony.

4. Document custom tokens: If you create custom tokens for your project, document their purpose and usage context.

5. Test across themes: Verify your components work with different theme configurations, especially for dark mode.

6. Audit for hardcoded values: Run a codebase search for hex colors or raw pixel values. Every hardcoded value is a future maintenance burden. Claude Code can perform this audit and suggest token replacements.

7. Name tokens for intent, not appearance: A token named `danger-border` is more useful than `red-border`. When you rebrand red to orange for accessibility, `danger-border` still makes sense.

8. Keep primitive and semantic layers separate: Your primitive palette (`blue.500`, `red.600`) should never be referenced in components. Enforce this via lint rules or code review guidelines.

## Token Naming Anti-Patterns to Avoid

```javascript
// BAD. hard to refactor, no intent
const badTokenUsage = {
 color: '#cc0000', // Raw hex
 padding: '16px', // Raw pixel
 borderColor: 'red.500', // Primitive color in a component
 fontSize: '14px', // Raw pixel font size
};

// GOOD. clear intent, easy to update globally
const goodTokenUsage = {
 color: 'error.600', // Semantic. purpose is clear
 padding: '4', // Token scale
 borderColor: 'error.300', // Semantic color reference
 fontSize: 'sm', // Named size token
};
```

## Conclusion

Design system tokens transform how you build user interfaces. By using Claude Code's canvas-design skill token system, you create applications that are consistent, maintainable, and themable. Start with the basic color, typography, and spacing tokens, then build up to more complex component patterns as your familiarity grows.

The investment in learning token-based design pays dividends in reduced design debt, faster iteration, and more cohesive user experiences. The semantic layer is the key architectural decision. once components reference semantic tokens instead of primitives, supporting dark mode, rebranding, or white-labeling becomes a configuration change rather than a migration project. Claude Code can accelerate every stage of this work, from scaffolding your initial token file through auditing existing components for hardcoded values and generating dark-mode-ready component variants.


---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-design-system-tokens-frontend-developer-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Best Claude Code Skills for Frontend Development](/best-claude-code-skills-for-frontend-development/)
- [Claude Code Accessibility Workflow for Frontend Engineers](/claude-code-accessibility-workflow-for-frontend-engineers/)
- [Claude Code Daily Workflow for Frontend Developers Guide](/claude-code-daily-workflow-for-frontend-developers-guide/)
- [Claude Code Generating CSS Variables from Design System](/claude-code-generating-css-variables-from-design-system/)
- [Claude Code frontend design plugin](/claude-code-frontend-design-plugin-guide/) — design system integration plugin

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Claude Code Frontend Developer Cross Browser Testing Guide](/claude-code-frontend-developer-cross-browser-testing-guide/)
