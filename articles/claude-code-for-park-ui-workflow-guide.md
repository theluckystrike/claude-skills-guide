---
layout: default
title: "Claude Code for Park UI"
description: "Build styled components with Park UI and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-park-ui-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, park-ui, workflow]
---

## The Setup

You are building UIs with Park UI, a component library built on top of Ark UI that provides beautifully styled, accessible components. Park UI combines Ark UI's headless components with Panda CSS for styling, offering a design system similar to shadcn/ui but with Panda CSS instead of Tailwind. Claude Code can create UI components, but it generates shadcn/ui with Tailwind patterns instead of Park UI's Panda CSS approach.

## What Claude Code Gets Wrong By Default

1. **Uses shadcn/ui with Tailwind CSS.** Claude generates components with `className="flex items-center"` Tailwind utilities. Park UI uses Panda CSS with `css({ display: 'flex', alignItems: 'center' })` or the styled system.

2. **Copies components from shadcn/ui registry.** Claude runs `npx shadcn-ui@latest add button`. Park UI has its own CLI and component registry — `npx @park-ui/cli add button` installs Park UI components.

3. **Ignores Panda CSS token system.** Claude hardcodes colors and spacing values. Park UI uses Panda CSS design tokens (`token('colors.accent.default')`) for consistent theming across the component library.

4. **Mixes Radix UI with Park UI.** Claude imports from `@radix-ui/react-*`. Park UI is built on Ark UI (which uses Zag.js), not Radix — the component APIs and import paths are different.

## The CLAUDE.md Configuration

```
# Park UI Project

## Components
- Library: Park UI (styled Ark UI components)
- Styling: Panda CSS (not Tailwind)
- Base: Ark UI headless components
- CLI: @park-ui/cli for adding components

## Park UI Rules
- Install: npx @park-ui/cli add [component]
- Styling: Panda CSS with design tokens
- Tokens: token('colors.accent.default') for values
- Recipes: component styles defined as Panda recipes
- Variants: size, variant props on components
- Theme: configure in panda.config.ts presets
- Compound: Root, Trigger, Content pattern from Ark UI

## Conventions
- Add components with Park UI CLI
- Customize via Panda CSS recipe overrides
- Theme tokens in panda.config.ts
- Use Park UI presets for consistent design
- Component props: size="sm", variant="outline"
- Slot recipes for compound component styling
- Support React, Solid, Vue via Ark UI
```

## Workflow Example

You want to build a settings page with Park UI components. Prompt Claude Code:

"Create a settings page using Park UI with a Card layout, Tabs for different settings sections (Profile, Notifications, Security), form inputs with labels, a Switch for notification toggles, and Save/Cancel buttons. Use Park UI components and Panda CSS styling."

Claude Code should import Park UI components (`Card`, `Tabs`, `Input`, `Switch`, `Button`), compose them in the compound component pattern, use Panda CSS's `css()` or `styled()` for layout, and apply Park UI's variant props for consistent styling.

## Common Pitfalls

1. **Tailwind classes on Park UI components.** Claude adds `className="mt-4 p-2"` to Park UI components. Park UI uses Panda CSS — use `css({ marginTop: '4', padding: '2' })` or the styled system instead of Tailwind utilities.

2. **Missing Panda CSS configuration.** Claude uses Park UI components without the Panda CSS preset. Park UI requires `@park-ui/panda-preset` in `panda.config.ts` for the design tokens and recipes to work correctly.

3. **Not using the CLI for component installation.** Claude copies component code manually. Park UI's CLI installs components with the correct imports, recipes, and Panda CSS integration — manual copying misses recipe definitions and token references.

## Related Guides

- [Claude Code for Shadcn UI Workflow Guide](/claude-code-for-shadcn-ui-workflow-guide/)
- [Claude Code for Panda CSS Workflow Guide](/claude-code-for-panda-css-workflow-guide/)
- [Best Claude Code Skills for Frontend Development](/best-claude-code-skills-for-frontend-development/)
