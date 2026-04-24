---
layout: default
title: "Claude Code for Million.js"
description: "Speed up React rendering with Million.js and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-million-js-react-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, million-js, workflow]
---

## The Setup

You are optimizing React rendering performance using Million.js, the library that replaces React's virtual DOM with a faster block-based approach. Million.js can make components up to 70% faster by compiling them into optimized DOM operations. Claude Code can add Million.js to components, but it applies it incorrectly or wraps incompatible components.

## What Claude Code Gets Wrong By Default

1. **Wraps every component with `block()`.** Claude adds `const FastComponent = block(MyComponent)` to all components. Million.js `block()` only works with components that follow specific rules — it cannot handle components with complex conditional rendering or hooks that change between renders.

2. **Uses `block()` on components with dynamic children.** Claude wraps components that render `{children}` or `{items.map(...)}` in block(). Million.js blocks cannot have dynamic children — these need the `<For>` component or must stay as regular React components.

3. **Ignores the compiler plugin.** Claude manually wraps components. Million.js has a compiler plugin for Vite/Next.js/Webpack that automatically optimizes eligible components — manual wrapping is error-prone.

4. **Applies to leaf components only.** Claude optimizes small components like buttons. Million.js has the most impact on components with many static elements and few dynamic parts — large list items, cards, and page sections benefit most.

## The CLAUDE.md Configuration

```
# Million.js React Optimization

## Performance
- Library: Million.js (block-based virtual DOM)
- Compiler: million/compiler plugin for auto-optimization
- Manual: block() wrapper for specific components

## Million.js Rules
- Add compiler plugin to bundler config (Vite/Next/Webpack)
- Compiler auto-detects and optimizes eligible components
- Manual block(): only for components with stable structure
- Block components cannot have: dynamic children, hooks that change
- Use <For> component for lists instead of .map()
- Static parts: elements that don't change between renders
- Dynamic parts: props, state values that change

## Conventions
- Install million and add compiler plugin first
- Let compiler handle optimization automatically
- Manual block() only when compiler misses opportunities
- Measure performance before and after with React DevTools
- Use <For each={items}> for optimized list rendering
- Do not block() components with useEffect that conditionally renders
- Profile: compare render times in React DevTools Profiler
```

## Workflow Example

You want to optimize a slow product listing page. Prompt Claude Code:

"This product grid re-renders slowly with 200+ items. Add Million.js to optimize rendering. Set up the compiler plugin for Next.js and optimize the ProductCard component if it is eligible for block optimization."

Claude Code should add the Million.js compiler plugin to `next.config.js`, analyze ProductCard for block eligibility (static structure, no dynamic children), and if eligible, let the compiler handle it or manually wrap with `block()`. Replace `.map()` with `<For each={products}>` for the list rendering.

## Common Pitfalls

1. **Hydration mismatches with SSR.** Claude adds Million.js to SSR-rendered components. Block components may cause hydration mismatches if the server renders differently than the client. Test SSR pages thoroughly after adding Million.js.

2. **Compiler over-optimization.** Claude enables the compiler globally without exclusions. Some components (those with heavy hooks, context consumers, or portals) can break when optimized. Use `// million-ignore` comments on incompatible components.

3. **Measuring wrong metrics.** Claude checks page load time to measure Million.js impact. Million.js optimizes re-render performance, not initial render. Use React DevTools Profiler to measure re-render times on interaction (sort, filter, update).

## Related Guides

- [AI Coding Tools for Performance Optimization](/ai-coding-tools-for-performance-optimization/)
- [Best Claude Code Skills for Frontend Development](/best-claude-code-skills-for-frontend-development/)
- [Best AI Tools for Frontend Development 2026](/best-ai-tools-for-frontend-development-2026/)
