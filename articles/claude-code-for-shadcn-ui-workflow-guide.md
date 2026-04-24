---
layout: default
title: "Claude Code for shadcn/ui"
description: "Add and customize shadcn/ui components with Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-shadcn-ui-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, shadcn-ui, workflow]
---

## The Setup

You are building a React application with shadcn/ui, the component collection that copies component source code into your project rather than installing from npm. You own and customize every component. Claude Code can generate and modify shadcn/ui components, but it treats them like imported library components and generates code that conflicts with the local component structure.

## What Claude Code Gets Wrong By Default

1. **Imports from a shadcn npm package.** Claude writes `import { Button } from 'shadcn-ui'` or `import { Button } from '@shadcn/ui'`. shadcn/ui is not an npm package — components live in your project at `@/components/ui/button`. They are local files you own.

2. **Installs components with npm.** Claude runs `npm install @shadcn/ui` which does not exist. Components are added with `npx shadcn@latest add button` which copies the source file into your project.

3. **Avoids modifying component source.** Claude treats shadcn components as read-only library code. The entire point of shadcn/ui is that you own the code — modify it freely to match your design system.

4. **Uses wrong Tailwind class patterns.** Claude writes arbitrary Tailwind classes that conflict with shadcn's `cn()` utility and variant system. shadcn components use `cva` (class-variance-authority) for variants and `cn()` from `@/lib/utils` for class merging.

## The CLAUDE.md Configuration

```
# shadcn/ui Component Project

## UI Components
- Components: shadcn/ui (source code in project, NOT npm package)
- Location: src/components/ui/ (local files, fully owned)
- Add new: npx shadcn@latest add <component-name>
- Styling: Tailwind CSS with cva() for variants, cn() for merging

## shadcn/ui Rules
- Import from local paths: @/components/ui/button (NOT from npm)
- Components are YOUR code — modify freely
- Use cn() from @/lib/utils for class composition
- Variants with cva() from class-variance-authority
- Primitives from Radix UI (already dependency of shadcn components)
- New components: npx shadcn@latest add <name>
- Theme in globals.css with CSS variables (--primary, --secondary, etc.)

## Conventions
- UI primitives in src/components/ui/ (shadcn components)
- App components in src/components/ (composed from UI primitives)
- Override shadcn defaults by editing the component source directly
- Theme colors as CSS variables in app/globals.css
- Dark mode via class strategy (add 'dark' class to html)
- Use cn() for conditional classes, never ternary className strings
```

## Workflow Example

You want to customize the Button component and create a new composite component. Prompt Claude Code:

"Modify the shadcn Button to add an 'icon' variant that is square with centered content. Then create a SearchBar component that combines the Input and Button components with a search icon."

Claude Code should edit `src/components/ui/button.tsx` directly, adding an `icon` variant to the `buttonVariants` cva definition, then create `src/components/search-bar.tsx` that imports from `@/components/ui/input` and `@/components/ui/button`, composing them with proper `cn()` class merging.

## Common Pitfalls

1. **Overwriting components on re-add.** Claude runs `npx shadcn@latest add button` to update a component, overwriting local customizations. Once a component is added and modified, never re-add it. Track customizations in comments or use git to merge updates manually.

2. **Missing the `cn()` utility.** Claude uses template literals for conditional classes: `` className={`btn ${active ? 'active' : ''}`} ``. shadcn components use `cn()` which properly merges Tailwind classes and handles conflicts: `cn('btn', active && 'active')`.

3. **CSS variable theme mismatches.** Claude adds colors with Tailwind values like `bg-blue-500` instead of using the CSS variable theme: `bg-primary`. shadcn's theming system uses CSS variables defined in `globals.css` so the entire app theme can change by swapping variable values.

## Related Guides

- [Best Way to Use Claude Code for Frontend Styling](/best-way-to-use-claude-code-for-frontend-styling/)
- [Claude Code Figma to Code Component Workflow](/claude-code-figma-to-code-component-workflow/)
- [Best Claude Code Skills for Frontend Development](/best-claude-code-skills-for-frontend-development/)

## See Also

- [Claude Code for Park UI — Workflow Guide](/claude-code-for-park-ui-workflow-guide/)
- [Claude Code for Radix UI — Workflow Guide](/claude-code-for-radix-ui-workflow-guide/)
- [Claude Code for Ark UI — Workflow Guide](/claude-code-for-ark-ui-workflow-guide/)
