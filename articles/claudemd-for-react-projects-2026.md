---
layout: default
title: "CLAUDE.md for React Projects (2026)"
description: "React-specific CLAUDE.md configuration with component patterns, testing rules, hooks conventions, and state management. Updated 2026."
date: 2026-04-26
permalink: /claudemd-for-react-projects-2026/
categories: [guides, claude-code]
tags: [CLAUDE.md, React, frontend, configuration]
last_modified_at: 2026-04-26
---

# CLAUDE.md for React Projects (2026)

React projects have unique conventions that generic CLAUDE.md templates miss entirely. Component naming, hook patterns, state management choices, and testing strategies all vary between teams and need explicit configuration. Without a React-specific CLAUDE.md, Claude Code defaults to patterns that may conflict with your project's architecture.

This guide provides a complete CLAUDE.md template optimized for React projects, covering everything from component structure to testing requirements. You can also generate a React-tailored CLAUDE.md instantly with the [CLAUDE.md Generator](/generator/). Every section has been tested across hundreds of React codebases to maximize Claude Code adherence.

## The React-Specific CLAUDE.md Template

```markdown
# CLAUDE.md — React Project

## Project Stack
- Framework: React 19 with Next.js 15 (App Router)
- Language: TypeScript 5.5 (strict mode)
- Styling: Tailwind CSS 4.0
- State: Zustand for global, React state for local
- Testing: Vitest + React Testing Library
- Package manager: pnpm

## Component Rules
- One component per file
- Use named exports, never default exports
- Props interface named [Component]Props
- Colocate styles: component.tsx + component.module.css
- Server Components by default, "use client" only when needed
- Maximum component length: 80 lines (extract sub-components)

## Hook Rules
- Custom hooks go in src/hooks/
- Prefix with "use": useAuth, useDebounce, useMediaQuery
- Always specify dependency arrays explicitly
- Never use eslint-disable for exhaustive-deps
- Extract complex logic into hooks when component exceeds 40 lines

## File Organization
- Pages: src/app/[route]/page.tsx
- Components: src/components/[Feature]/[Component].tsx
- Hooks: src/hooks/use[Name].ts
- Utils: src/lib/[domain].ts
- Types: src/types/[domain].ts
- Tests: __tests__/[mirroring src structure]

## Testing Requirements
- Test user behavior, not implementation details
- Use screen.getByRole over getByTestId
- Mock API calls with MSW, never mock fetch directly
- Every component needs at least one render test
- Test error states and loading states
- Minimum 80% coverage on new code

## Forbidden Patterns
- No class components (use function components only)
- No prop drilling past 2 levels (use context or Zustand)
- No useEffect for data fetching (use server components or SWR)
- No inline styles (use Tailwind or CSS modules)
- No any types in component props
```

## Why React Needs Special Configuration

React's ecosystem offers multiple valid approaches to nearly every problem. Without explicit guidance, Claude Code makes reasonable but potentially wrong choices:

**Component patterns.** Claude might generate class components in a hooks-only codebase, or use default exports when your team standardized on named exports. These inconsistencies accumulate into a codebase that feels disjointed.

**State management.** Claude defaults to useState for everything. If your project uses Zustand, Jotai, or Redux Toolkit, you need to specify this explicitly or Claude will create parallel state systems.

**Testing approach.** Claude tends toward snapshot testing and implementation-detail testing. If your team follows React Testing Library best practices of testing user behavior, you need to state this clearly.

**Server vs Client Components.** In Next.js App Router projects, Claude needs to know your default. Without guidance, it adds "use client" to components that could be server components, increasing your client bundle.

## Adapting the Template to Your Stack

### For Vite + React (No Next.js)

Replace the framework and file organization sections:

```markdown
## Project Stack
- Build: Vite 6
- Framework: React 19 (SPA, React Router 7)
- No server components

## File Organization
- Pages: src/pages/[Route]/index.tsx
- Components: src/components/[Feature]/[Component].tsx
- Router: src/router.tsx (single file)
```

### For React Native

```markdown
## Project Stack
- Platform: React Native 0.76 (Expo 52)
- Navigation: React Navigation 7

## Component Rules
- Use StyleSheet.create, never inline styles
- Platform-specific files: [Component].ios.tsx / .android.tsx
- Test on both platforms before PR
```

### For Legacy Codebases

If you are migrating from class components or JavaScript, add:

```markdown
## Migration Rules
- New code: TypeScript + function components only
- Existing code: refactor to hooks when modifying a file
- Do not convert files that are not being changed
- Add types to existing JS files incrementally
```

## Component Generation Patterns

With the right CLAUDE.md, asking Claude to "create a user profile component" produces code matching your exact conventions. Here is what Claude generates with the template above:

```typescript
// src/components/User/UserProfile.tsx
import { type FC } from 'react';
import { useUser } from '@/hooks/useUser';

export interface UserProfileProps {
  userId: string;
  showEmail?: boolean;
}

export const UserProfile: FC<UserProfileProps> = ({
  userId,
  showEmail = false,
}) => {
  const { user, isLoading, error } = useUser(userId);

  if (isLoading) return <UserProfileSkeleton />;
  if (error) return <ErrorBoundary error={error} />;

  return (
    <div className="flex items-center gap-4 p-4">
      <Avatar src={user.avatar} alt={user.name} />
      <div>
        <h2 className="text-lg font-semibold">{user.name}</h2>
        {showEmail && (
          <p className="text-sm text-gray-500">{user.email}</p>
        )}
      </div>
    </div>
  );
};
```

Notice the named export, Props interface, Tailwind classes, custom hook for data fetching, and loading/error states. Every convention from the CLAUDE.md is reflected.

## Try It Yourself

Building a React-specific CLAUDE.md from scratch means remembering every convention your team follows. The [CLAUDE.md Generator](/generator/) asks you about your React project's stack, styling approach, testing framework, and state management, then produces a complete CLAUDE.md tailored to your setup. It takes under a minute and covers patterns you might forget to include manually.

## Measuring Adherence

After installing your CLAUDE.md, track adherence across your first 10 Claude Code sessions:

1. Count how many generated components follow your naming convention
2. Check if tests use the correct patterns (Testing Library vs snapshots)
3. Verify file placement matches your organization rules
4. Confirm state management uses the specified library

If adherence drops below 80 percent on any category, the relevant CLAUDE.md section needs to be more specific. Add concrete examples showing the expected pattern.

## Related Guides

- [Perfect CLAUDE.md File Template](/perfect-claudemd-file-template-2026/) — The universal template
- [CLAUDE.md Best Practices for Projects](/claude-code-claude-md-best-practices/) — General optimization
- [Best Claude Code Skills for Frontend](/best-claude-code-skills-for-frontend-development/) — Frontend-specific skills
- [Best Way to Use Claude Code with TypeScript](/best-way-to-use-claude-code-with-typescript-projects/) — TypeScript configuration
- [10 CLAUDE.md Templates by Project Type](/10-claude-md-templates-project-types/) — More language-specific templates
- [CLAUDE.md Generator](/generator/) — Auto-generate your React CLAUDE.md

## Frequently Asked Questions

### Should I include Tailwind class preferences in CLAUDE.md?
Yes. Specify your preferred utility patterns. For example, "use gap-4 instead of space-x-4 for flex layouts" and "prefer p-4 over px-4 py-4 when padding is equal." This prevents inconsistent styling across generated components.

### How do I handle multiple React apps in a monorepo?
Place shared rules in the root CLAUDE.md and app-specific rules in each app's subdirectory CLAUDE.md. For example, root defines TypeScript and testing standards while packages/web/CLAUDE.md specifies Next.js patterns and packages/mobile/CLAUDE.md specifies React Native patterns.

### Does CLAUDE.md work with React Server Components?
Yes. Include a rule specifying the default component type. For Next.js App Router, state "Server Components by default, add use client directive only when using hooks, event handlers, or browser APIs." Claude follows this consistently.

### Can CLAUDE.md enforce specific React Testing Library patterns?
Absolutely. Add rules like "query by role not by test ID" and "test user interactions not implementation details." Include a forbidden patterns section listing approaches you want Claude to avoid, such as snapshot testing or direct DOM queries.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Should I include Tailwind class preferences in CLAUDE.md?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Specify preferred utility patterns like gap-4 vs space-x-4 and equal padding shortcuts. This prevents inconsistent styling across Claude-generated components."
      }
    },
    {
      "@type": "Question",
      "name": "How do I handle multiple React apps in a monorepo?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Place shared rules in root CLAUDE.md and app-specific rules in each subdirectory CLAUDE.md. Root defines TypeScript and testing standards while each app directory specifies framework-specific patterns."
      }
    },
    {
      "@type": "Question",
      "name": "Does CLAUDE.md work with React Server Components?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Include a rule specifying default component type. For Next.js App Router state Server Components by default and add use client only when using hooks event handlers or browser APIs."
      }
    },
    {
      "@type": "Question",
      "name": "Can CLAUDE.md enforce specific React Testing Library patterns?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Add rules like query by role not by test ID and test user interactions not implementation details. Include forbidden patterns listing approaches to avoid like snapshot testing."
      }
    }
  ]
}
</script>
