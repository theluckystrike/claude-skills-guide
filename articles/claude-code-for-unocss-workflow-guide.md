---
layout: default
title: "Claude Code for UnoCSS — Workflow Guide"
description: "Use instant atomic CSS with UnoCSS and Claude Code setup. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-unocss-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, unocss, workflow]
---

## The Setup

You are using UnoCSS, the instant on-demand atomic CSS engine that is faster and more flexible than Tailwind CSS. UnoCSS generates utility classes only when they are used, supports custom rules, and can emulate Tailwind, Windi, or Tachyons presets. Claude Code can write utility classes, but it assumes Tailwind and misses UnoCSS-specific features.

## What Claude Code Gets Wrong By Default

1. **Installs Tailwind CSS alongside UnoCSS.** Claude adds `tailwindcss` when asked about utility CSS. UnoCSS with `@unocss/preset-wind` provides Tailwind-compatible classes without installing Tailwind.

2. **Creates `tailwind.config.js` for customization.** Claude configures Tailwind's config file for theme customization. UnoCSS uses `uno.config.ts` with a different structure including presets, rules, shortcuts, and themes.

3. **Misses UnoCSS's attributify mode.** Claude only uses `class="..."` strings. UnoCSS supports attributify mode: `<div text="lg red-500" p="4">` — splitting classes into attribute groups for readability.

4. **Ignores custom rules and shortcuts.** Claude writes long utility class strings. UnoCSS lets you define shortcuts (`btn: 'py-2 px-4 rounded bg-blue-500'`) and custom rules with regex patterns directly in the config.

## The CLAUDE.md Configuration

```
# UnoCSS Atomic CSS Project

## Styling
- CSS Engine: UnoCSS (on-demand atomic CSS)
- Config: uno.config.ts at project root
- Presets: @unocss/preset-wind (Tailwind-compatible)
- Mode: class + attributify

## UnoCSS Rules
- Config in uno.config.ts with defineConfig()
- Tailwind classes via preset-wind (enabled by default)
- Custom shortcuts: shortcuts: { 'btn': 'py-2 px-4 rounded' }
- Attributify mode: <div text="lg" p="4" bg="blue-500">
- Custom rules: rules: [[/^m-(\d+)$/, ([, d]) => ({ margin: `${d}px` })]]
- Icons: @unocss/preset-icons for any Iconify icon as class
- Variants: dark:, hover:, md: work like Tailwind
- Never install Tailwind — UnoCSS preset-wind handles it

## Conventions
- uno.config.ts committed to version control
- Shortcuts for repeated utility patterns
- Use attributify for components with many utilities
- Icons: i-lucide-search, i-mdi-home (Iconify format)
- Theme customization in uno.config.ts theme section
- Use @apply in CSS files via @unocss/transformer-directives
```

## Workflow Example

You want to set up UnoCSS with custom shortcuts and icon support. Prompt Claude Code:

"Configure UnoCSS with preset-wind, preset-icons (Lucide icon set), and attributify mode. Add shortcuts for btn, card, and input styles. Set up the Vite plugin."

Claude Code should create `uno.config.ts` with `presetWind()`, `presetIcons({ prefix: 'i-' })`, `presetAttributify()`, shortcuts for common component styles, and install `@unocss/vite` as the Vite plugin in `vite.config.ts`. Also add `import 'virtual:uno.css'` to the main entry file.

## Common Pitfalls

1. **Missing the virtual CSS import.** Claude configures UnoCSS but forgets `import 'virtual:uno.css'` in the entry file. Without this import, no utility classes are injected into the page, and everything appears unstyled.

2. **Attributify mode conflicts with component props.** Claude uses `text="center"` in attributify mode on components where `text` is a prop name. Attributify can conflict with HTML attributes and component props. Use prefixed attributify (`un-text="center"`) to avoid collisions.

3. **Icon class generation failures.** Claude uses icon classes like `i-lucide-search` but the icons do not render. UnoCSS preset-icons needs the icon data package installed: `@iconify-json/lucide` for Lucide icons, `@iconify-json/mdi` for Material Design, etc.

## Related Guides

- [Best Way to Use Claude Code for Frontend Styling](/best-way-to-use-claude-code-for-frontend-styling/)
- [Claude Code CSS Animations Workflow Guide](/claude-code-css-animations-workflow-guide/)
- [Claude Code Figma to Tailwind Component Conversion](/claude-code-figma-to-tailwind-component-conversion/)
