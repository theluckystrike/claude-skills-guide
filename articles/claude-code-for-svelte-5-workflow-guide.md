---
layout: default
title: "Claude Code for Svelte 5 (2026)"
description: "Claude Code for Svelte 5 — Workflow Guide tutorial with real-world examples, working configurations, best practices, and deployment steps verified for..."
date: 2026-04-18
permalink: /claude-code-for-svelte-5-workflow-guide/
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



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Best AI Tools for Frontend Development 2026](/best-ai-tools-for-frontend-development-2026/)
- [Best Claude Code Skills for Frontend Development](/best-claude-code-skills-for-frontend-development/)
- [Vibe Coding for Web Apps NextJS Vercel Guide](/vibe-coding-for-web-apps-nextjs-vercel-guide/)

## Svelte 5 Migration Checklist

If you are migrating an existing Svelte 4 project to Svelte 5, Claude Code can automate many of the required syntax changes. Use this checklist to track the migration:

1. **Replace reactive declarations.** Find all `$:` statements and convert them to `$derived()` runes. Claude Code can do this across all files with a single prompt: "Replace all $: reactive statements with $derived() runes in every .svelte file."

2. **Replace reactive state.** Find all `let` variables that are mutated by the component and wrap them with `$state()`. Not every `let` variable needs to be reactive -- only those that trigger re-renders when changed.

3. **Replace lifecycle hooks.** Convert `onMount`, `onDestroy`, `beforeUpdate`, and `afterUpdate` to `$effect()` runes. Note that `$effect` runs on both server and client in SvelteKit, so add browser checks where needed.

4. **Update event handlers.** Replace `on:click` with `onclick`, `on:input` with `oninput`, and so on. The `on:` prefix is deprecated in Svelte 5.

5. **Replace slots with snippets.** Svelte 5 introduces `{#snippet}` blocks as a replacement for named slots. Convert `<slot name="header">` to `{#snippet header()}...{/snippet}`.

6. **Test each component.** After migration, run your test suite and manually verify interactive components. Reactivity changes can introduce subtle bugs where values update in a different order than expected.

## Related Articles

- [Claude Code for Svelte Animations Workflow Tutorial](/claude-code-for-svelte-animations-workflow-tutorial/)


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
