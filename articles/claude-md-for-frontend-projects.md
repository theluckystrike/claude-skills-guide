---
title: "CLAUDE.md for Frontend Projects — React, Component, and State Rules (2026)"
description: "Write CLAUDE.md rules for React component structure, state management, styling conventions, and accessibility that Claude Code follows in frontend projects."
permalink: /claude-md-frontend-projects/
render_with_liquid: false
categories: [claude-md, patterns]
tags: [claude-md, frontend, react, components, styling, claude-code]
last_updated: 2026-04-19
---

## Frontend Projects Need Specific Rules

Frontend codebases have conventions that backend rules do not cover: component file structure, state management patterns, styling approaches, accessibility requirements, and bundle size constraints. Without explicit rules, Claude Code generates React components that work but violate your project's patterns -- using useState where you use Zustand, inline styles where you use Tailwind, or divs where you need semantic HTML.

CLAUDE.md brings Claude's output in line with your specific frontend architecture.

## Component Structure Rules

```markdown
## React Component Rules

### File Structure
- One component per file
- File name matches component name: UserProfile.tsx exports UserProfile
- Colocate styles: UserProfile.module.css or Tailwind classes inline
- Colocate tests: UserProfile.test.tsx in same directory
- Colocate types: types defined at top of component file, shared types in src/types/

### Component Patterns
- Functional components only — no class components
- Props interface named {ComponentName}Props, exported for testing
- Destructure props in function signature, not in body
- Default props: use default parameter values, not defaultProps
- Children: type as React.ReactNode, not React.FC
- Ref forwarding: use React.forwardRef when component wraps a DOM element

### Component Size
- Maximum 150 lines per component file (including imports and types)
- Extract custom hooks when component logic exceeds 50 lines
- Extract sub-components when JSX exceeds 80 lines
- Custom hooks: src/hooks/use{Name}.ts — one hook per file
```

## State Management Rules

```markdown
## State Management

### Local State
- useState for UI-only state (open/closed, form inputs, loading)
- useReducer for complex state with multiple related fields
- NEVER lift state higher than the lowest common ancestor that needs it

### Global State (Zustand)
- Stores in src/stores/{name}Store.ts
- One store per domain: useAuthStore, useCartStore, useUIStore
- Actions defined inside the store, not in components
- Selectors: always use shallow comparison (useStore(selector, shallow))
- NEVER put derived data in store — compute with useMemo in components
- NEVER put server data in Zustand — use React Query for server state

### Server State (React Query)
- Query keys in src/queries/keys.ts — centralized, typed
- Queries: useQuery with staleTime and gcTime configured per resource
- Mutations: useMutation with onSuccess invalidation of related queries
- Loading states: use query.isLoading and query.isError, never separate useState
- Optimistic updates: only for user-visible immediate feedback (likes, toggles)
```

## Styling Conventions

```markdown
## Styling (Tailwind CSS)

### Class Ordering
- Layout (flex, grid, position) → Sizing (w, h) → Spacing (p, m) → Typography (text, font) → Visual (bg, border, shadow) → Interactive (hover, focus)

### Rules
- Responsive: mobile-first (default → sm → md → lg → xl)
- Dark mode: use dark: prefix, NEVER toggle classes with JavaScript
- No inline style objects — Tailwind classes or CSS modules only
- Component variants: use class-variance-authority (cva) from src/lib/cva.ts
- Design tokens: extend Tailwind theme in tailwind.config.ts, never hardcode colors or spacing

### Accessibility
- Interactive elements: visible focus ring (ring-2 ring-offset-2 on focus-visible)
- Color contrast: minimum 4.5:1 ratio for text
- Touch targets: minimum 44x44px (p-3 on buttons and links)
```

## Accessibility Rules

```markdown
## Accessibility (WCAG 2.1 AA)
- Semantic HTML: button for actions, a for navigation, never div with onClick
- Images: alt text required, decorative images use alt=""
- Forms: every input has a visible label (not just placeholder)
- Headings: one h1 per page, no skipped levels (h1 → h2 → h3)
- Keyboard navigation: all interactive elements reachable with Tab
- Screen reader: aria-label on icon-only buttons, aria-live for dynamic content
- Focus management: move focus to new content after navigation or modal open
```

## File-Specific Frontend Rules

Use `.claude/rules/` for component-type-specific patterns:

```markdown
# .claude/rules/components.md
---
paths:
  - "src/components/**/*.tsx"
---

## Component File Rules
- No direct API calls — use React Query hooks from src/queries/
- No direct store access for data fetching — stores are for client state only
- Error boundaries: wrap route-level components with ErrorBoundary from src/components/ErrorBoundary
- Loading states: use Skeleton components from src/components/ui/Skeleton
- Empty states: use EmptyState component, never render nothing
```

## Performance Rules

```markdown
## Performance
- Bundle budget: 150KB gzipped for initial load
- Lazy loading: React.lazy for route-level components
- Images: use next/image or srcset with WebP format
- Memoization: useMemo for expensive computations, React.memo for list items
- NEVER use useMemo or React.memo preemptively — only when measured
- No lodash full import — use specific imports (lodash/debounce)
```

For backend API patterns that your frontend consumes, see the [API design guide](/claude-md-api-design-patterns/). For the general CLAUDE.md structure, see the [best practices guide](/claude-code-claude-md-best-practices/). For testing conventions including component tests, see the [testing conventions guide](/claude-md-testing-conventions/).
