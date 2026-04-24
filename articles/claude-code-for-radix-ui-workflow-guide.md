---
layout: default
title: "Claude Code for Radix UI"
description: "Build accessible components with Radix UI and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-radix-ui-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, radix-ui, workflow]
---

## The Setup

You are building a component library using Radix UI primitives — unstyled, accessible React components that handle complex interaction patterns (dialogs, dropdowns, tooltips) correctly. Claude Code can compose Radix components, but it builds these patterns from scratch with divs and event handlers, missing the accessibility and keyboard navigation that Radix provides.

## What Claude Code Gets Wrong By Default

1. **Builds dialogs with div and useState.** Claude creates `<div className="modal">` with manual open/close state. Radix provides `<Dialog.Root>`, `<Dialog.Trigger>`, `<Dialog.Content>` with built-in focus trapping, escape handling, and screen reader support.

2. **Ignores compound component pattern.** Claude wraps everything in a single component. Radix uses compound components: `<Select.Root>`, `<Select.Trigger>`, `<Select.Content>`, `<Select.Item>` — each part is composable and stylable independently.

3. **Missing accessibility attributes.** Claude adds `onClick` handlers without `aria-*` attributes, keyboard navigation, or focus management. Radix handles all WAI-ARIA requirements automatically — roles, states, and keyboard interactions are built-in.

4. **Adds duplicate event handling.** Claude writes custom keyboard handlers for escape, tab trapping, and focus management. Radix handles all of this — adding custom handlers duplicates logic and can conflict.

## The CLAUDE.md Configuration

```
# Radix UI Primitives Project

## Components
- Primitives: @radix-ui/* (unstyled, accessible)
- Styling: Tailwind CSS or CSS Modules on Radix components
- Composition: compound component pattern

## Radix Rules
- Install per component: @radix-ui/react-dialog, react-dropdown-menu
- Use compound components: Root > Trigger > Content > Items
- Styling via className or data attributes (data-state, data-side)
- Animation: use data-[state=open/closed] for CSS transitions
- Portal: Content renders in portal by default (correct z-index)
- Controlled: use open/onOpenChange for controlled state
- Uncontrolled: use defaultOpen for uncontrolled
- Accessibility built-in — do NOT add manual aria attributes

## Conventions
- Wrap Radix primitives in styled components for reuse
- Use data-[state=open] and data-[state=closed] for animations
- ForwardRef on all component wrappers
- Asynchronous content: render in Dialog.Content, not outside
- Use Radix's onOpenChange, not custom onClick for close
- Compose multiple Radix primitives (Dialog + Form, etc.)
```

## Workflow Example

You want to create a styled command palette component. Prompt Claude Code:

"Create a command palette using Radix Dialog and Command. It should open with Cmd+K, have a search input, filterable command list, keyboard navigation, and close on selection or escape. Style it with Tailwind."

Claude Code should use `<Dialog.Root>` controlled by a keyboard shortcut listener, `<Dialog.Content>` with a search input, Radix's `<Command>` primitive (or cmdk) for the list with keyboard navigation, handle selection with `onSelect`, and use `data-[state=open]` for enter/exit animations.

## Common Pitfalls

1. **Styling `data-state` incorrectly.** Claude uses conditional className with React state for open/close animations. Radix exposes `data-state="open"` and `data-state="closed"` attributes — use CSS `[data-state=open]` selectors or Tailwind's `data-[state=open]:` modifier for animations.

2. **Dialog content outside portal.** Claude renders modal content inline, causing z-index and overflow issues. Radix Dialog renders content in a portal by default — do not override this behavior unless you have a specific reason.

3. **Prop name conflicts with HTML.** Claude passes `open` as a boolean prop to a custom wrapper without forwarding to Radix. The `open` prop must reach `Dialog.Root` — make sure wrapper components forward Radix-specific props correctly with proper TypeScript types.

## Related Guides

- [Best Claude Code Skills for Frontend Development](/best-claude-code-skills-for-frontend-development/)
- [Claude Code Accessibility Regression Testing](/claude-code-accessibility-regression-testing/)
- [Claude Code Accessible Forms Validation Error Handling Guide](/claude-code-accessible-forms-validation-error-handling-guide/)
