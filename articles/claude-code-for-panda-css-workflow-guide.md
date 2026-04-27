---
sitemap: false
layout: default
title: "Claude Code for Panda CSS (2026)"
description: "Claude Code for Panda CSS — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-panda-css-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, panda-css, workflow]
---

## The Setup

You are styling a React application with Panda CSS, the CSS-in-JS library with build-time extraction and zero runtime overhead. Panda CSS generates atomic CSS classes from TypeScript-first style definitions. Claude Code can write Panda styles, but it defaults to Tailwind class strings, Emotion's `css` prop, or inline style objects instead.

## What Claude Code Gets Wrong By Default

1. **Writes Tailwind utility classes.** Claude generates `className="flex items-center p-4"` string-based classes. Panda CSS uses `css({ display: 'flex', alignItems: 'center', padding: '4' })` with object syntax.

2. **Uses runtime CSS-in-JS patterns.** Claude imports `styled` from Emotion or styled-components. Panda CSS extracts styles at build time — there is no runtime style injection. The `styled` function exists but generates static CSS.

3. **Ignores the `panda.config.ts` design tokens.** Claude hardcodes colors and spacing values. Panda CSS defines tokens in config and references them as `token('colors.blue.500')` or within recipes.

4. **Creates global CSS files for component styles.** Claude writes `.module.css` files alongside components. Panda CSS colocates styles in the component file using `css()`, `cva()`, or `styled()` functions.

## The CLAUDE.md Configuration

```
# Panda CSS Styling Project

## Styling
- CSS: Panda CSS (build-time extraction, zero runtime)
- Config: panda.config.ts at project root
- Generated: styled-system/ directory (auto-generated, gitignored)
- Codegen: npx panda codegen (regenerates styled-system)

## Panda CSS Rules
- Import css, cva, styled from 'styled-system/css' or 'styled-system/jsx'
- Use object syntax: css({ color: 'red.500', fontSize: 'lg' })
- Tokens reference config values: 'colors.blue.500', 'spacing.4'
- Recipes with cva(): define component variants
- Patterns: flex(), grid(), container() from styled-system/patterns
- Never use className strings — use css() function
- Responsive: css({ base: { p: '2' }, md: { p: '4' } })
- Run panda codegen after config changes

## Conventions
- Design tokens in panda.config.ts (colors, spacing, typography)
- Component styles use css() or cva() inline
- Shared recipes in theme/recipes/ directory
- Semantic tokens for light/dark mode
- Use patterns for layout: flex(), grid(), stack()
- Never install Tailwind or Emotion — Panda handles everything
```

## Workflow Example

You want to create a reusable Button component with variants. Prompt Claude Code:

"Create a Button component using Panda CSS with visual (solid, outline, ghost), size (sm, md, lg), and color (blue, red, green) variants using cva(). Include hover and disabled states."

Claude Code should define a `buttonRecipe` using `cva()` from `styled-system/css` with base styles, variant definitions for visual/size/color, compound variants for special combinations, and default variants. The Button component should apply the recipe with `className={buttonRecipe({ visual, size, color })}`.

## Common Pitfalls

1. **Forgetting to run `panda codegen`.** Claude updates `panda.config.ts` but does not regenerate the styled-system directory. Token and recipe changes require running `panda codegen` to update the generated functions.

2. **Importing from wrong paths.** Claude imports `css` from `@pandacss/dev` instead of the generated `styled-system/css`. Panda CSS generates project-specific imports in the `styled-system/` directory — always import from there, not from the panda npm package.

3. **Using arbitrary values without the bracket syntax.** Claude writes `css({ width: '347px' })` for custom values. Panda CSS requires bracket syntax for arbitrary values not in your token scale: `css({ width: '[347px]' })` or better, add it as a token.

## Related Guides

**Configure permissions →** Build your settings with our [Permission Configurator](/permissions/).

- [Best Way to Use Claude Code for Frontend Styling](/best-way-to-use-claude-code-for-frontend-styling/)
- [Claude Code CSS Animations Workflow Guide](/claude-code-css-animations-workflow-guide/)
- [Claude Code Figma to Code Component Workflow](/claude-code-figma-to-code-component-workflow/)

## Related Articles

- [Claude Code For Critical CSS — Complete Developer Guide](/claude-code-for-critical-css-workflow-tutorial/)
- [Optimize Tailwind CSS with Claude Code](/claude-code-tailwind-css-optimization-guide/)
- [Claude Code for Lightning CSS — Workflow Guide](/claude-code-for-lightning-css-workflow-guide/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a CLAUDE.md file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring .claude/settings.json for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your .claude/ directory and CLAUDE.md to version control so the entire team uses the same configuration. Each developer can add personal preferences in ~/.claude/settings.json (user-level) without affecting the project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation."
      }
    }
  ]
}
</script>
