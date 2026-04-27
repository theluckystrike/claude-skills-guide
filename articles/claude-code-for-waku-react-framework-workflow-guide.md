---
sitemap: false
layout: default
title: "Claude Code for Waku React Framework (2026)"
description: "Claude Code for Waku React Framework — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-waku-react-framework-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, waku, workflow]
---

## The Setup

You are building React applications with Waku, a minimal React framework focused on React Server Components (RSC). Waku provides a lightweight alternative to Next.js with first-class RSC support, file-based routing, and a focus on simplicity. Claude Code can build React apps, but it generates Next.js App Router patterns that differ from Waku's API and conventions.

## What Claude Code Gets Wrong By Default

1. **Uses Next.js App Router conventions.** Claude creates `app/page.tsx` with Next.js-specific exports like `generateMetadata` and `generateStaticParams`. Waku has its own file-based routing in `src/pages/` with different conventions.

2. **Imports from `next/` packages.** Claude uses `import { useRouter } from 'next/navigation'` and `import Image from 'next/image'`. Waku does not provide these — use standard React Router or Waku's own routing utilities.

3. **Confuses client and server boundaries.** Claude adds `"use client"` to every component. Waku is RSC-first — components are server components by default. Only add `"use client"` to components that need browser APIs, state, or event handlers.

4. **Uses Next.js data fetching patterns.** Claude writes `fetch()` calls with Next.js-specific caching options. Waku uses standard async server components — `async function Page() { const data = await fetchData(); }` without framework-specific caching APIs.

## The CLAUDE.md Configuration

```
# Waku React Framework

## Framework
- Framework: Waku (minimal RSC-first React framework)
- Routing: file-based in src/pages/
- Components: server components by default
- Build: Vite-based bundling

## Waku Rules
- Pages: src/pages/index.tsx, src/pages/about.tsx
- Layout: src/pages/_layout.tsx for shared layout
- Server components: default — no directive needed
- Client components: "use client" only when needed
- Data: async server components fetch directly
- Static: createPages() for static generation
- Config: waku.config.ts for framework settings

## Conventions
- Server components by default (RSC-first)
- "use client" only for interactive components
- Fetch data in server components directly
- No API routes — use server components for data
- Minimal bundle: fewer client components = less JS
- Layout in _layout.tsx for nested layouts
- Use createPages for static site generation
```

## Workflow Example

You want to build a blog with Waku using server components for data fetching. Prompt Claude Code:

"Create a Waku blog with a posts list page and individual post pages. Fetch posts from a CMS API in server components. Use a shared layout with navigation. Only use client components for the mobile menu toggle."

Claude Code should create `src/pages/_layout.tsx` as a server component with navigation, `src/pages/index.tsx` as an async server component that fetches posts, `src/pages/posts/[slug].tsx` for individual posts with async data fetching, and a `MobileMenu` client component with `"use client"` for the interactive menu toggle.

## Common Pitfalls

1. **Adding "use client" to everything.** Claude marks all components as client components out of habit. In Waku, every `"use client"` directive adds JavaScript to the client bundle. Keep components as server components unless they specifically need interactivity.

2. **Using Next.js link and image components.** Claude imports `Link` from `next/link`. Waku uses its own `Link` component from `waku` — import paths and props differ from Next.js.

3. **Server component state management.** Claude tries to use `useState` in server components. Server components cannot use hooks — state and interactivity must be in client components. Pass data as props from server to client components.

## Related Guides

**Try it:** Browse 155+ skills in our [Skill Finder](/skill-finder/).

- [Best AI Tools for Frontend Development 2026](/best-ai-tools-for-frontend-development-2026/)
- [Best Claude Code Skills for Frontend Development](/best-claude-code-skills-for-frontend-development/)
- [Claude Code for TanStack Router Workflow Guide](/claude-code-for-tanstack-router-workflow-guide/)

## See Also

- [Claude Code for HTMX — Workflow Guide](/claude-code-for-htmx-framework-workflow-guide/)


## Common Questions

### How do I get started with claude code for waku react framework?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code with Angular vs React](/claude-code-angular-vs-react/)
- [Claude Code Axum Rust Web Framework](/claude-code-axum-rust-web-framework-guide/)
- [Claude Code + Ant Design React Workflow](/claude-code-for-ant-design-workflow-guide/)
