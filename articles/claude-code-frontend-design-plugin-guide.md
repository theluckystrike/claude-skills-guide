---
title: "Claude Code Frontend Design Plugin"
description: "How to use the Claude Code frontend-design skill for CSS, React, Vue, and Tailwind workflows. Setup, real examples, and design-to-code techniques."
permalink: /claude-code-frontend-design-plugin-guide/
last_tested: "2026-04-24"
render_with_liquid: false
---

# Claude Code Frontend Design Plugin Guide (2026)

The frontend-design skill for Claude Code adds structured workflows for turning design concepts into production code. It handles CSS layouts, responsive design, component architecture, animation, and accessibility patterns through specialized prompts that produce consistent, well-structured frontend code.

This guide covers what the skill does, how to install it, real examples across CSS, React, Vue, and Tailwind, and tips for getting the best results from design-to-code workflows.

## What the Frontend-Design Skill Does

The frontend-design skill is a set of prompt templates and instructions that optimize Claude Code for frontend development tasks. Without it, Claude Code handles frontend work as a general coding task. With it, Claude follows opinionated patterns for:

- **Layout generation**: Flexbox, Grid, and responsive layouts from verbal descriptions
- **Component architecture**: Properly structured React, Vue, or Svelte components with props, state, and event handling
- **Design token systems**: Consistent spacing, typography, and color scales
- **Accessibility**: WCAG 2.1 AA compliance built into every component
- **Animation**: CSS transitions, keyframe animations, and motion design
- **Responsive design**: Mobile-first breakpoint systems
- **Design system integration**: Following existing design token conventions

Think of it as giving Claude Code a senior frontend developer's instincts when working on visual code.

## Installation

### Method 1: Via SuperClaude Framework

If you use the [SuperClaude framework](/super-claude-code-framework-guide/), the frontend-design skill is included:

```bash
git clone https://github.com/nicbarajas/superClaude.git
cd superClaude
./install.sh
```

The skill file lives at `.claude/skills/frontend-design.md`.

### Method 2: Manual Installation

Create the skill file directly in your project:

```bash
mkdir -p .claude/skills
```

Create `.claude/skills/frontend-design.md`:

```markdown
# Frontend Design Skill

## Purpose
Generate production-quality frontend code from design descriptions.

## Rules
1. Always use semantic HTML elements
2. Follow mobile-first responsive design
3. Include ARIA labels and roles for accessibility
4. Use CSS custom properties for theming
5. Components must be self-contained with scoped styles
6. All interactive elements must have focus states
7. Color contrast must meet WCAG 2.1 AA (4.5:1 for text)
8. Use system font stacks unless a specific font is requested
9. Include reduced-motion media queries for animations
10. Generate TypeScript types for all component props

## Output Format
For each component, produce:
- Component file (TSX/Vue/Svelte)
- Styles (CSS modules, Tailwind classes, or styled-components)
- Type definitions
- Usage example
- Accessibility notes
```

Then reference it in your [CLAUDE.md](/claude-md-best-practices-definitive-guide/):

```markdown
## Skills
Load frontend-design skill from .claude/skills/frontend-design.md
```

### Method 3: CLAUDE.md Only

For a lighter approach, add frontend design rules directly to your CLAUDE.md without a separate skill file:

```markdown
## Frontend Rules
- Mobile-first responsive design with breakpoints: 640px, 768px, 1024px, 1280px
- Semantic HTML: use <nav>, <main>, <article>, <section>, <aside>, <footer>
- WCAG 2.1 AA compliance on all components
- CSS custom properties for colors, spacing, typography
- All animations must respect prefers-reduced-motion
- Use Tailwind utility classes (project uses Tailwind CSS)
```

## CSS Workflows

### Layout Generation

Describe a layout in plain language and Claude generates the CSS:

```
Create a dashboard layout with:
- Fixed sidebar (280px wide) on the left
- Top navigation bar (64px tall)
- Main content area with 24px padding
- The sidebar collapses to an icon-only view (64px) on screens under 1024px
- On mobile (under 768px), the sidebar becomes a bottom tab bar
```

Claude generates:

```css
:root {
  --sidebar-width: 280px;
  --sidebar-collapsed: 64px;
  --topbar-height: 64px;
  --content-padding: 24px;
  --color-surface: #ffffff;
  --color-border: #e5e7eb;
}

.dashboard {
  display: grid;
  grid-template-columns: var(--sidebar-width) 1fr;
  grid-template-rows: var(--topbar-height) 1fr;
  grid-template-areas:
    "sidebar topbar"
    "sidebar content";
  min-height: 100vh;
}

.sidebar {
  grid-area: sidebar;
  background: var(--color-surface);
  border-right: 1px solid var(--color-border);
  padding: 16px;
  overflow-y: auto;
  transition: width 0.2s ease;
}

.topbar {
  grid-area: topbar;
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  display: flex;
  align-items: center;
  padding: 0 var(--content-padding);
}

.content {
  grid-area: content;
  padding: var(--content-padding);
  overflow-y: auto;
}

@media (max-width: 1024px) {
  .dashboard {
    grid-template-columns: var(--sidebar-collapsed) 1fr;
  }

  .sidebar {
    width: var(--sidebar-collapsed);
    padding: 8px;
  }

  .sidebar-label {
    display: none;
  }
}

@media (max-width: 768px) {
  .dashboard {
    grid-template-columns: 1fr;
    grid-template-rows: var(--topbar-height) 1fr 64px;
    grid-template-areas:
      "topbar"
      "content"
      "sidebar";
  }

  .sidebar {
    width: 100%;
    display: flex;
    flex-direction: row;
    justify-content: space-around;
    border-right: none;
    border-top: 1px solid var(--color-border);
  }
}

@media (prefers-reduced-motion: reduce) {
  .sidebar {
    transition: none;
  }
}
```

### Animation Patterns

```
Create a card hover effect: subtle lift with shadow expansion,
0.2s duration, ease-out timing. Include a focus state for
keyboard navigation.
```

```css
.card {
  background: var(--color-surface);
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s ease-out, box-shadow 0.2s ease-out;
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.card:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

@media (prefers-reduced-motion: reduce) {
  .card {
    transition: none;
  }

  .card:hover,
  .card:focus-visible {
    transform: none;
  }
}
```

## React Component Workflows

### Component Generation

```
Create a pricing card component in React with TypeScript:
- Plan name, price, billing period, feature list
- Highlighted/recommended variant
- CTA button with loading state
- Responsive: full width on mobile, fixed 360px on desktop
- Use CSS modules for styling
```

Claude generates both the component and styles:

```tsx
// PricingCard.tsx
import React from 'react';
import styles from './PricingCard.module.css';

interface PricingCardProps {
  planName: string;
  price: number;
  period: 'month' | 'year';
  features: string[];
  highlighted?: boolean;
  ctaText?: string;
  loading?: boolean;
  onSelect: () => void;
}

export function PricingCard({
  planName,
  price,
  period,
  features,
  highlighted = false,
  ctaText = 'Get Started',
  loading = false,
  onSelect,
}: PricingCardProps) {
  const cardClass = highlighted
    ? `${styles.card} ${styles.highlighted}`
    : styles.card;

  return (
    <article className={cardClass} aria-label={`${planName} plan`}>
      {highlighted && (
        <span className={styles.badge} aria-label="Recommended plan">
          Recommended
        </span>
      )}

      <h3 className={styles.planName}>{planName}</h3>

      <div className={styles.pricing}>
        <span className={styles.currency}>$</span>
        <span className={styles.amount}>{price}</span>
        <span className={styles.period}>/{period}</span>
      </div>

      <ul className={styles.features} role="list">
        {features.map((feature, index) => (
          <li key={index} className={styles.feature}>
            <svg
              className={styles.checkIcon}
              viewBox="0 0 20 20"
              fill="currentColor"
              aria-hidden="true"
            >
              <path
                fillRule="evenodd"
                d="M16.704 4.153a.75.75 0 01.143 1.052l-8 10.5a.75.75 0 01-1.127.075l-4.5-4.5a.75.75 0 011.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 011.05-.143z"
                clipRule="evenodd"
              />
            </svg>
            {feature}
          </li>
        ))}
      </ul>

      <button
        className={styles.cta}
        onClick={onSelect}
        disabled={loading}
        aria-busy={loading}
      >
        {loading ? 'Processing...' : ctaText}
      </button>
    </article>
  );
}
```

### Design System Component Library

```
Create a button component that supports:
- Variants: primary, secondary, ghost, danger
- Sizes: sm, md, lg
- States: default, hover, active, disabled, loading
- Icon support (left and/or right)
- Full-width option
- As a link (<a>) when href is provided
```

The skill ensures Claude generates all variants with proper TypeScript discriminated unions, accessibility attributes, and consistent spacing.

## Vue Component Workflows

The frontend-design skill works with Vue 3 Composition API:

```
Create a Vue 3 modal dialog component with:
- Backdrop click to close
- Escape key to close
- Focus trap (tab cycles within modal)
- Transition animations for open/close
- Slots for header, body, footer
```

Claude generates the Vue SFC with proper `<script setup>`, scoped styles, and accessibility attributes including `role="dialog"`, `aria-modal`, and focus management.

## Tailwind CSS Workflows

When your project uses Tailwind, tell Claude in your CLAUDE.md:

```markdown
## Styling
This project uses Tailwind CSS v3. Use utility classes.
No custom CSS unless absolutely necessary.
Follow the project's tailwind.config.js for custom values.
```

Then the frontend-design skill generates Tailwind-native code:

```
Create a testimonial card grid: 3 columns on desktop,
2 on tablet, 1 on mobile. Each card has avatar, name,
role, and quote text.
```

```tsx
export function TestimonialGrid({ testimonials }: TestimonialGridProps) {
  return (
    <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
      {testimonials.map((testimonial) => (
        <article
          key={testimonial.id}
          className="rounded-lg border border-gray-200 bg-white p-6 shadow-sm"
        >
          <div className="flex items-center gap-3 mb-4">
            <img
              src={testimonial.avatarUrl}
              alt=""
              className="h-10 w-10 rounded-full object-cover"
            />
            <div>
              <p className="text-sm font-semibold text-gray-900">
                {testimonial.name}
              </p>
              <p className="text-sm text-gray-500">
                {testimonial.role}
              </p>
            </div>
          </div>
          <blockquote className="text-gray-700 leading-relaxed">
            "{testimonial.quote}"
          </blockquote>
        </article>
      ))}
    </div>
  );
}
```

*Need the complete toolkit? [The Claude Code Playbook](https://zovo.one/pricing) includes 200 production-ready templates.*

## Design-to-Code Techniques

### Technique 1: Describe Layouts in Terms of Content

Instead of specifying exact CSS, describe what content goes where:

```
# Less effective
Create a div with display: flex, gap: 16px, flex-wrap: wrap

# More effective
Create a card grid where each card contains a thumbnail image,
title, description, and action button. Cards should fill
available width, minimum 300px per card, with 16px gaps.
```

The second prompt gives Claude enough context to choose the right CSS technique (CSS Grid with `auto-fill` and `minmax`).

### Technique 2: Reference Existing Design Patterns

```
Create a navigation bar similar to GitHub's top nav:
logo on left, search in center, user menu on right.
Collapses to hamburger menu on mobile.
```

Claude knows common UI patterns and can replicate the structure with your project's styling conventions.

### Technique 3: Iterate on Components

Start simple, then add complexity:

```
# Round 1
Create a basic form with email and password fields

# Round 2
Add inline validation that shows errors on blur

# Round 3
Add password strength indicator

# Round 4
Add "show password" toggle with proper accessibility
```

This iterative approach produces better results than a single prompt asking for everything.

### Technique 4: Screenshot Description

If you have a design mockup, describe it precisely:

```
I have a design that shows:
- Header section with centered text: "Build faster" in 48px bold,
  "Ship with confidence" in 20px regular below
- 3 feature cards in a row, each with an icon (40px),
  heading, and 2-line description
- Cards have 1px gray border, 12px border-radius, 32px padding
- Background is #F9FAFB, card background is white
- 80px vertical spacing between sections
```

## Accessibility Built In

The frontend-design skill enforces accessibility by default:

### What Gets Added Automatically

1. **Semantic HTML**: `<nav>`, `<main>`, `<article>` instead of generic `<div>`
2. **ARIA attributes**: `role`, `aria-label`, `aria-expanded`, `aria-busy` where needed
3. **Focus management**: `focus-visible` styles, focus traps for modals
4. **Keyboard navigation**: Tab order, arrow key support for menus
5. **Color contrast**: Meeting WCAG 2.1 AA (4.5:1 for normal text, 3:1 for large text)
6. **Motion sensitivity**: `prefers-reduced-motion` media queries
7. **Screen reader text**: Visually hidden labels for icon-only buttons
8. **Alt text reminders**: Flags images that need descriptive alt text

### Testing Accessibility

After Claude generates components, verify with:

```
Run the accessibility audit on the PricingCard component.
Check color contrast, keyboard navigation, and screen reader compatibility.
```

Claude can run axe-core, pa11y, or similar tools if they are installed in your project.

## Troubleshooting

### Generated Code Does Not Match Project Style

Update your CLAUDE.md with specific styling rules:

```markdown
## Component Style Rules
- Use CSS Modules (not styled-components, not inline styles)
- Class names follow BEM: block__element--modifier
- Colors from design tokens only (see src/tokens/colors.ts)
- Spacing scale: 4, 8, 12, 16, 24, 32, 48, 64, 96px
```

### Components Too Complex

If Claude generates overly complex components, constrain it:

```markdown
## Component Rules
- Maximum 100 lines per component file
- Maximum 5 props per component
- Split complex components into smaller sub-components
- No inline logic; extract to custom hooks
```

### Wrong Framework

If Claude generates React when you use Vue (or vice versa):

```markdown
## Framework
This project uses Vue 3 with Composition API.
Do NOT generate React code. All components use .vue SFC format.
```

## Frequently Asked Questions

### Does the frontend-design skill work without a framework?
Yes. It works with plain HTML and CSS. Specify "vanilla HTML/CSS, no framework" in your prompt or CLAUDE.md.

### Can it generate responsive images?
Yes. It generates `<picture>` elements with `srcset` and `sizes` attributes, or responsive image CSS depending on the context.

### Does it support CSS-in-JS?
Yes. It works with styled-components, Emotion, Stitches, and vanilla-extract. Specify your CSS-in-JS library in CLAUDE.md.

### Can it replicate a specific design from a screenshot?
Claude Code can analyze screenshots when you share them in the conversation. Describe the layout and Claude generates matching code. Results are approximate, not pixel-perfect.

### How does it handle dark mode?
When instructed, it generates CSS custom properties with light/dark values and uses `prefers-color-scheme` media queries or a manual toggle with a data attribute.

### Does it generate Storybook stories?
Yes, when requested. Tell Claude to "include a Storybook story file" and it generates stories with controls for each prop.

### Can it work with design tools like Figma?
Not directly. There is no Figma MCP integration in Claude Code. Export designs as descriptions or screenshots and provide them to Claude.

### Is the skill maintained/updated?
If installed via [SuperClaude](/super-claude-code-framework-guide/), updates come with the framework. If installed manually, you maintain it yourself. Follow the Claude Code [community](/best-claude-code-repos-github-2026/) for shared improvements.

### How does this skill affect token usage?
The skill file adds 200-800 tokens to each request as context. Monitor costs with [token usage tracking](/audit-claude-code-token-usage-step-by-step/). For token-sensitive projects, consider inlining only the rules you need in your [CLAUDE.md](/claude-md-best-practices-definitive-guide/) rather than loading the full skill file. See [cost optimization strategies](/best-claude-code-cost-saving-tools-2026/) for more tips.

### Can I use this with Claude Code hooks for automatic formatting?
Yes. Set up a [PostToolUse hook](/claude-code-hooks-complete-guide/) that runs Prettier or ESLint after Claude writes CSS or component files. This ensures the generated code matches your formatting standards regardless of what the skill produces.

### Does this work with Claude Code's spec workflow?
Yes. Write a [design spec](/claude-code-spec-workflow-guide/) describing the visual requirements, then use the frontend-design skill to implement it. This combination produces highly consistent results because the spec removes ambiguity while the skill enforces frontend best practices.

### Can I combine this with MCP servers?
Yes. Using a [Supabase MCP server](/claude-code-mcp-supabase-setup-guide/) alongside the frontend-design skill lets Claude generate components that are pre-wired to your database schema. Claude can read the database structure through MCP and generate matching TypeScript types and data-fetching components.


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "### Does the frontend-design skill work without a framework?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. It works with plain HTML and CSS. Specify \\\"vanilla HTML/CSS, no framework\\\" in your prompt or CLAUDE.md."
      }
    },
    {
      "@type": "Question",
      "name": "Can it generate responsive images?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. It generates <picture> elements with srcset and sizes attributes, or responsive image CSS depending on the context."
      }
    },
    {
      "@type": "Question",
      "name": "Does it support CSS-in-JS?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. It works with styled-components, Emotion, Stitches, and vanilla-extract. Specify your CSS-in-JS library in CLAUDE.md."
      }
    },
    {
      "@type": "Question",
      "name": "Can it replicate a specific design from a screenshot?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code can analyze screenshots when you share them in the conversation. Describe the layout and Claude generates matching code. Results are approximate, not pixel-perfect."
      }
    },
    {
      "@type": "Question",
      "name": "How does it handle dark mode?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "When instructed, it generates CSS custom properties with light/dark values and uses prefers-color-scheme media queries or a manual toggle with a data attribute."
      }
    },
    {
      "@type": "Question",
      "name": "Does it generate Storybook stories?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, when requested. Tell Claude to \\\"include a Storybook story file\\\" and it generates stories with controls for each prop."
      }
    },
    {
      "@type": "Question",
      "name": "Can it work with design tools like Figma?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Not directly. There is no Figma MCP integration in Claude Code. Export designs as descriptions or screenshots and provide them to Claude."
      }
    },
    {
      "@type": "Question",
      "name": "Is the skill maintained/updated?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "If installed via SuperClaude, updates come with the framework. If installed manually, you maintain it yourself. Follow the Claude Code community for shared improvements."
      }
    },
    {
      "@type": "Question",
      "name": "How does this skill affect token usage?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The skill file adds 200-800 tokens to each request as context. Monitor costs with token usage tracking. For token-sensitive projects, consider inlining only the rules you need in your CLAUDE.md rather than loading the full skill file. See cost optimization strategies for more tips."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with Claude Code hooks for automatic formatting?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Set up a PostToolUse hook that runs Prettier or ESLint after Claude writes CSS or component files. This ensures the generated code matches your formatting standards regardless of what the skill produces."
      }
    },
    {
      "@type": "Question",
      "name": "Does this work with Claude Code's spec workflow?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Write a design spec describing the visual requirements, then use the frontend-design skill to implement it. This combination produces highly consistent results because the spec removes ambiguity while the skill enforces frontend best practices."
      }
    },
    {
      "@type": "Question",
      "name": "Can I combine this with MCP servers?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Using a Supabase MCP server alongside the frontend-design skill lets Claude generate components that are pre-wired to your database schema. Claude can read the database structure through MCP and generate matching TypeScript types and data-fetching components."
      }
    }
  ]
}
</script>

## See Also

- [Claude Code Frontend Developer Cross Browser Testing Guide](/claude-code-frontend-developer-cross-browser-testing-guide/)
