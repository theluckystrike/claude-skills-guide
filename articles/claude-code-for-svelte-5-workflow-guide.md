---
layout: default
title: "Claude Code for Svelte 5"
description: "Claude Code for Svelte 5 — Workflow Guide tutorial with real-world examples, working configurations, best practices, and deployment steps verified for..."
date: 2026-04-18
permalink: /claude-code-for-svelte-5-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, svelte, workflow]
last_tested: "2026-04-22"
---

## The Setup

You are building a web application with Svelte 5, which introduces runes — a new reactivity system replacing Svelte 4's implicit reactivity with explicit `$state`, `$derived`, and `$effect` primitives. Claude Code can generate Svelte components, but it writes Svelte 4 syntax or React patterns that do not work with Svelte 5's rune-based reactivity.

## What Claude Code Gets Wrong By Default

1. **Uses Svelte 4 `let` reactivity.** Claude writes `let count = 0` expecting automatic reactivity. Svelte 5 requires `let count = $state(0)` for reactive declarations — plain `let` variables are not reactive anymore.

2. **Uses `$:` reactive statements.** Claude writes `$: doubled = count * 2` for derived values. Svelte 5 replaces `$:` with `let doubled = $derived(count * 2)` — the old syntax is deprecated.

3. **Uses `onMount` lifecycle from Svelte 4.** Claude imports `onMount` from `svelte`. Svelte 5 uses `$effect()` for lifecycle-like behavior that automatically tracks dependencies and runs when they change.

4. **Writes React JSX instead of Svelte template syntax.** Claude generates `<div className={...}>` with JSX. Svelte uses HTML-like templates with `class:active={isActive}` directives and `{#if}`/`{#each}` blocks.

## The CLAUDE.md Configuration

```
# Svelte 5 Project

## Framework
- UI: Svelte 5 with runes (NOT Svelte 4)
- Meta-framework: SvelteKit 2
- Reactivity: $state, $derived, $effect runes
- Styling: scoped CSS in <style> blocks

## Svelte 5 Rules
- Reactive state: let count = $state(0)
- Derived values: let doubled = $derived(count * 2)
- Side effects: $effect(() => { console.log(count) })
- Props: let { name, age = 25 }: Props = $props()
- Bind: bind:value={inputValue}
- Events: onclick={handler} (lowercase, no on: prefix in Svelte 5)
- Snippets: {#snippet name()} ... {/snippet} replaces slots
- Template: {#if}, {#each}, {#await} blocks

## Conventions
- Components in src/lib/components/ directory
- Pages in src/routes/ (SvelteKit file-based routing)
- Stores: use $state in .svelte.ts files for shared state
- Scoped styles by default in <style> blocks
- Use $bindable() for two-way binding props
- TypeScript: <script lang="ts"> in all components
- Never use $: or onMount — use $derived and $effect
```

## Workflow Example

You want to create a todo list component with Svelte 5 runes. Prompt Claude Code:

"Create a Svelte 5 todo list component with add, toggle, and delete functionality. Use $state for the todo list, $derived for the filtered view and completion count, and $effect to save to localStorage on changes."

Claude Code should use `let todos = $state<Todo[]>([])` for the list, `let completed = $derived(todos.filter(t => t.done).length)` for the count, `$effect(() => { localStorage.setItem('todos', JSON.stringify(todos)) })` for persistence, and Svelte template syntax with `{#each}` blocks for rendering.

## Common Pitfalls

1. **Mutating $state arrays with push.** Claude uses `todos.push(newTodo)` expecting reactivity. In Svelte 5, array mutations on `$state` arrays work but the variable must be declared with `$state`. However, reassignment (`todos = [...todos, newTodo]`) is more explicit and always triggers updates.

2. **$effect running on server.** Claude puts browser APIs in `$effect` without checking the environment. In SvelteKit, `$effect` runs on the server during SSR. Check `import { browser } from '$app/environment'` before accessing `localStorage`, `window`, or DOM APIs.

3. **Event handler syntax change.** Claude writes `on:click={handler}` from Svelte 4. Svelte 5 uses `onclick={handler}` (standard HTML attribute names). The `on:` directive syntax is deprecated and will show warnings.

## Related Guides

- [Best AI Tools for Frontend Development 2026](/best-ai-tools-for-frontend-development-2026/)
- [Best Claude Code Skills for Frontend Development](/best-claude-code-skills-for-frontend-development/)
- [Vibe Coding for Web Apps NextJS Vercel Guide](/vibe-coding-for-web-apps-nextjs-vercel-guide/)

## Related Articles

- [Claude Code for Svelte Animations Workflow Tutorial](/claude-code-for-svelte-animations-workflow-tutorial/)
