---

layout: default
title: "Claude Code for SolidJS Development"
description: "Build reactive SolidJS applications with Claude Code for resource management, signals, and store patterns. Streamline your SolidJS dev workflow."
date: 2026-03-15
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
author: "Claude Skills Guide"
permalink: /claude-code-for-solidjs-resources-workflow-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---


Claude Code for SolidJS Resources Workflow Guide

SolidJS offers a unique reactive programming model with primitives like signals, stores, and resources. When combined with Claude Code CLI, you can dramatically accelerate your development workflow, getting AI assistance for generating boilerplate, debugging reactive state, and optimizing component performance. This guide walks you through integrating Claude Code into your SolidJS projects effectively.

## Understanding SolidJS Reactive Resources

Before diving into the workflow, it's essential to understand what makes SolidJS distinct. Unlike React's virtual DOM diffing, SolidJS uses fine-grained reactivity with compiled updates. Your core primitives include:

- Signals: The fundamental reactive value holders that notify subscribers on change
- Stores: Nested reactive objects for managing complex state
- Resources: Async data handlers that integrate with Solid's reactive system
- Contexts: Dependency injection for passing values through the component tree
- Memos: Derived reactive values that cache results until dependencies change
- Effects: Side-effect runners that automatically track reactive dependencies

Claude Code can help you reason about these primitives, generate proper patterns, and debug issues when your reactivity isn't behaving as expected. The key is learning how to ask the right questions and provide enough context for Claude Code to understand your specific reactive graph.

## SolidJS vs React: Core Differences

Understanding where SolidJS diverges from React helps you write better prompts to Claude Code. The AI's training data includes a lot of React patterns, so being explicit about SolidJS semantics improves output quality.

| Concept | React | SolidJS |
|---------|-------|---------|
| State | `useState` hook, triggers re-render | `createSignal`, fine-grained DOM update |
| Derived state | Computed inline or `useMemo` | `createMemo` with dependency tracking |
| Side effects | `useEffect` with dependency array | `createEffect`, auto-tracks dependencies |
| Async data | `useEffect` + useState | `createResource` + Suspense integration |
| Complex state | `useReducer` or external store | `createStore` with path-based setters |
| Re-rendering | Whole component re-runs | Component runs once; only reactive parts update |

When asking Claude Code to convert React patterns, explicitly state these differences. Something like "SolidJS components only run once, the JSX is not re-evaluated on state change, only the reactive expressions inside it" gives Claude Code the context to produce idiomatic output rather than React-style patterns wrapped in SolidJS syntax.

## Setting Up Claude Code with Your SolidJS Project

The first step is ensuring Claude Code understands your project structure. In your SolidJS project directory, create a CLAUDE.md file at the project root to give Claude Code context about your project.

A useful CLAUDE.md for a SolidJS project might include:

```markdown
Project: My SolidJS App

Tech Stack
- SolidJS with TypeScript
- Vite for bundling
- solid-router for routing
- @tanstack/solid-query for server state (in addition to createResource)

Conventions
- Signals use [value, setValue] naming
- Stores are in /src/stores/
- Components are in /src/components/
- All async data goes through createResource or solid-query, not useEffect equivalents

Key Patterns
- Use createStore for form state, signals for UI state
- Error boundaries wrap all route-level components
- Resources always have explicit error and loading states handled
```

You can also create a `.claude/settings.json` in your project root:

```json
{
 "project": {
 "include": ["src//*"],
 "exclude": ["node_modules", "dist", ".git"]
 }
}
```

The more context you provide in CLAUDE.md, the less time you spend correcting generated code. Claude Code uses this file to align on naming conventions, file locations, and architectural decisions before generating anything.

## Working with Signals Effectively

Signals are the building blocks of SolidJS reactivity. When requesting Claude Code's help with signals, describe your intent clearly:

> "Create a signal for a counter with increment and decrement functions, then show how to display it in a component"

Claude Code can generate clean signal implementations:

```typescript
import { createSignal, createEffect } from 'solid-js';

function Counter() {
 const [count, setCount] = createSignal(0);

 const increment = () => setCount(c => c + 1);
 const decrement = () => setCount(c => c - 1);

 // Effect runs when count changes
 createEffect(() => {
 console.log(`Count is now: ${count()}`);
 });

 return (
 <div>
 <p>Count: {count()}</p>
 <button onClick={decrement}>-</button>
 <button onClick={increment}>+</button>
 </div>
 );
}
```

When debugging signal issues, ask Claude Code to explain why updates aren't propagating. Common culprits include calling signal functions without parentheses (passing the function instead of its value) or creating signals inside components instead of outside.

## Common Signal Mistakes and How to Spot Them

When you ask Claude Code to review reactivity bugs, it will look for these patterns. Knowing them yourself helps you write better prompts:

```typescript
// WRONG: count is passed as a function reference, not its current value
// The JSX reads the signal once at render time and never updates
<p>{count}</p>

// RIGHT: count() is called, creating a reactive dependency
<p>{count()}</p>
```

```typescript
// WRONG: signal created outside the component but updated inside a non-reactive scope
// This loses the reactive connection
let externalValue = 0;
function Component() {
 externalValue = someComputation(); // Not reactive
 return <p>{externalValue}</p>;
}

// RIGHT: use createSignal for values that need to drive UI updates
function Component() {
 const [value, setValue] = createSignal(0);
 setValue(someComputation());
 return <p>{value()}</p>;
}
```

When sharing code for debugging, include the part of the reactive graph where you believe the break is occurring. Claude Code performs better when you say "this signal updates correctly (I checked with console.log) but this derived memo does not re-run" rather than "my UI doesn't update."

## Managing Complex State with Stores

For nested or complex state, SolidJS stores provide mutable-style APIs with reactive tracking:

```typescript
import { createStore } from 'solid-js/store';

const [state, setState] = createStore({
 user: {
 name: '',
 preferences: {
 theme: 'dark',
 notifications: true
 }
 }
});

// Nested updates are easy
setState('user', 'preferences', 'theme', 'light');

// Immutable-style updates also work
setState('user', 'name', 'New Name');
```

Claude Code excels at generating store patterns for common scenarios. Request patterns like "CRUD operations for a todo list store" or "form state management with validation" to get production-ready implementations.

## Store Pattern: Todo List with CRUD

Here is the kind of complete store pattern you can request from Claude Code with a single well-formed prompt:

```typescript
import { createStore, produce } from 'solid-js/store';

interface Todo {
 id: number;
 text: string;
 completed: boolean;
}

interface TodoStore {
 todos: Todo[];
 nextId: number;
}

const [store, setStore] = createStore<TodoStore>({
 todos: [],
 nextId: 1
});

// Add a new todo
function addTodo(text: string) {
 setStore('todos', store.todos.length, {
 id: store.nextId,
 text,
 completed: false
 });
 setStore('nextId', n => n + 1);
}

// Toggle completion
function toggleTodo(id: number) {
 setStore('todos', todo => todo.id === id, 'completed', c => !c);
}

// Remove a todo
function removeTodo(id: number) {
 setStore('todos', todos => todos.filter(t => t.id !== id));
}

// Batch update with produce for complex mutations
function completeAll() {
 setStore(produce(s => {
 s.todos.forEach(t => { t.completed = true; });
 }));
}
```

The prompt that generates this kind of output would be: "Create a SolidJS store for a todo list with TypeScript types. Include add, toggle, remove, and complete-all operations. Use the path-based setter API for single-item updates and produce for batch mutations."

Being specific about which APIs to use prevents Claude Code from defaulting to React-style patterns.

## Handling Async Data with Resources

SolidJS resources handle async data gracefully, integrating with Suspense:

```typescript
import { createResource, Suspense } from 'solid-js';

async function fetchUser(id: string) {
 const response = await fetch(`/api/users/${id}`);
 if (!response.ok) throw new Error(`HTTP ${response.status}`);
 return response.json();
}

function UserProfile(props: { userId: string }) {
 const [user] = createResource(() => props.userId, fetchUser);

 return (
 <Suspense fallback={<div>Loading...</div>}>
 <h1>{user()?.name}</h1>
 </Suspense>
 );
}
```

When working with resources, Claude Code can help you:

1. Implement proper error handling with `createResource`'s `onError` callback
2. Add refetching logic for data synchronization
3. Handle race conditions with abort controllers
4. Optimize resource fetching with fine-grained source signals

## Resources with Error Handling and Refetching

A more complete resource pattern handles loading, error, and success states explicitly:

```typescript
import { createResource, createSignal, Switch, Match, Show } from 'solid-js';

async function fetchUser(id: string, { signal }: { signal: AbortSignal }) {
 const response = await fetch(`/api/users/${id}`, { signal });
 if (!response.ok) {
 throw new Error(`Failed to fetch user ${id}: ${response.statusText}`);
 }
 return response.json() as Promise<{ id: string; name: string; email: string }>;
}

function UserProfile(props: { userId: string }) {
 const [user, { refetch }] = createResource(
 () => props.userId,
 fetchUser
 );

 return (
 <div>
 <Switch>
 <Match when={user.loading}>
 <div class="skeleton" aria-busy="true">Loading user...</div>
 </Match>
 <Match when={user.error}>
 <div class="error-state">
 <p>Failed to load user: {user.error?.message}</p>
 <button onClick={() => refetch()}>Try again</button>
 </div>
 </Match>
 <Match when={user()}>
 <div class="user-card">
 <h1>{user()!.name}</h1>
 <p>{user()!.email}</p>
 <button onClick={() => refetch()}>Refresh</button>
 </div>
 </Match>
 </Switch>
 </div>
 );
}
```

Ask Claude Code to generate this pattern with: "Create a SolidJS resource component for fetching a user by ID. Include explicit loading, error, and success states using Switch/Match. Add a refetch button. Handle HTTP errors by throwing with a descriptive message."

The abort signal is passed automatically by `createResource` when the source signal changes, this prevents race conditions where an older request completes after a newer one.

## Resource Source Signals for Dependent Fetching

A common pattern is fetching data that depends on another piece of state:

```typescript
import { createSignal, createResource } from 'solid-js';

const [selectedUserId, setSelectedUserId] = createSignal<string | null>(null);

// Resource only fetches when selectedUserId() is non-null
const [userPosts] = createResource(
 selectedUserId,
 async (userId) => {
 const res = await fetch(`/api/users/${userId}/posts`);
 return res.json();
 }
);
```

When `selectedUserId()` returns `null` or `undefined`, the resource does not fetch. When it changes to a new value, the resource automatically refetches. Claude Code can generate dependent fetching chains when you describe the dependency relationship explicitly.

## Practical Workflow: Debugging Reactivity Issues

One of the most valuable Claude Code use cases is debugging reactivity problems. When your UI isn't updating as expected:

1. Describe the symptom: "The todo text updates in the store but not the UI"
2. Share relevant code snippets
3. Ask Claude Code to identify potential causes

Common patterns Claude Code will check:

- Missing parentheses: Are you using `count` instead of `count()` in JSX?
- Component-level signals: Are signals created inside the component function instead of outside?
- Object reactivity: Are you mutating objects directly instead of using store setters?
- Untracked reads: Are you reading signals inside `untrack()` or event handlers where tracking is not active?
- Derived signals not used: Is a `createMemo` result stored in a variable but the variable itself (not the function) passed to JSX?

A useful debugging prompt template for Claude Code:

> "I have a SolidJS component where [describe component]. The state is managed with [signal/store]. When I [describe user action], I expect [expected behavior] but instead [actual behavior]. Here is the relevant code: [paste code]. What is the most likely cause?"

The more specific your description of what does and does not update, the faster Claude Code can narrow down the issue.

## Optimizing Performance with createMemo and createEffect

SolidJS provides memoization primitives that Claude Code can help you place strategically:

```typescript
import { createSignal, createMemo, createEffect } from 'solid-js';

const [count, setCount] = createSignal(0);
const [multiplier, setMultiplier] = createSignal(2);

// Memoized computation - only recalculates when count() or multiplier() changes
const scaled = createMemo(() => count() * multiplier());

// Effect with cleanup - runs when count() changes
createEffect(() => {
 const subscription = someAPI.subscribe(count());
 return () => subscription.unsubscribe();
});
```

Ask Claude Code to analyze performance bottlenecks by describing your component tree and data flow. It can suggest where to add `createMemo` to prevent unnecessary recalculations.

## When to Use createMemo vs Inline Computation

This is a common question worth asking Claude Code directly. The general rule:

| Scenario | Use |
|----------|-----|
| Simple derivation used once | Inline in JSX |
| Derivation used in multiple places | `createMemo` |
| Expensive computation | `createMemo` regardless of usage count |
| Derivation inside a loop or list | `createMemo` to avoid re-running per item |
| Derivation passed as prop | `createMemo` to prevent child re-triggering |

```typescript
// Expensive filter - use createMemo
const filteredItems = createMemo(() =>
 items().filter(item => item.category === selectedCategory())
);

// Simple lookup - inline is fine
return <p>Total: {items().length}</p>;
```

Claude Code will suggest `createMemo` placements when you ask it to review a component for unnecessary reactivity. Provide a component and ask: "Where could I add createMemo to reduce redundant computations in this component?"

## Building Reusable Primitives with Claude Code

One high-use use of Claude Code in a SolidJS project is generating custom reactive primitives that encapsulate common patterns. Rather than writing signals and effects inline, you can build composable utilities:

```typescript
// Ask Claude Code: "Create a SolidJS primitive for tracking window size reactively"
import { createSignal, onMount, onCleanup } from 'solid-js';

export function createWindowSize() {
 const [size, setSize] = createSignal({
 width: window.innerWidth,
 height: window.innerHeight
 });

 function update() {
 setSize({ width: window.innerWidth, height: window.innerHeight });
 }

 onMount(() => {
 window.addEventListener('resize', update);
 onCleanup(() => window.removeEventListener('resize', update));
 });

 return size;
}

// Usage
function ResponsiveComponent() {
 const windowSize = createWindowSize();
 const isMobile = createMemo(() => windowSize().width < 768);

 return (
 <div>
 <Show when={isMobile()} fallback={<DesktopLayout />}>
 <MobileLayout />
 </Show>
 </div>
 );
}
```

Claude Code generates clean primitives like this from short prompts. The key is asking for primitives that return signals or accessors, not components, that keeps them composable.

## Actionable Tips for Your Workflow

1. Start with clear prompts: "Generate a SolidJS store for managing authentication state with login/logout methods and TypeScript types" works better than vague requests.

2. Iterate on code: After receiving initial output, refine with specific constraints: "Add TypeScript types," "Include error handling for the API calls," or "Use Switch/Match instead of ternaries for the loading state."

3. Use Claude Code for refactoring: "Convert this useState-based React code to SolidJS signals and createEffect. Note that SolidJS components only run once, so the logic needs to be in effects and memos rather than in the component body."

4. Debug systematically: Share the smallest reproducible example when asking about bugs, the more context about your reactive dependencies, the better. Include what does update correctly as well as what does not.

5. Request comparisons: "Show me two ways to handle this: once with createSignal and once with createStore. Explain the tradeoffs." This builds understanding rather than just giving you code to copy.

6. Ask for tests: "Write vitest tests for this SolidJS store's CRUD operations using @solidjs/testing-library." Claude Code can generate test scaffolding that matches SolidJS's reactive execution model.

7. Learn patterns, don't just copy: After Claude Code generates solutions, ask follow-up questions like "Why did you use produce here instead of a path-based setter?" to understand the reasoning behind the generated code.

## Conclusion

Claude Code paired with SolidJS gives you AI-assisted development while using Solid's excellent reactivity model. By understanding signals, stores, and resources, and how to communicate your intent to Claude Code, you can build reactive applications faster and with fewer bugs.

The most productive workflow combines clear CLAUDE.md context, specific prompts that reference SolidJS primitives by name, and iterative refinement after the initial output. Claude Code is particularly strong at generating complete patterns (stores with all CRUD operations, resources with full error/loading/success handling, custom reactive primitives) when you ask for the complete version upfront rather than building incrementally.

Start with small tasks, gradually tackle more complex patterns, and let Claude Code help you learn SolidJS idioms along the way. The investment in writing precise prompts pays back quickly once you see the quality of idiomatic SolidJS code that results.


---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-solidjs-resources-workflow-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI Assisted Architecture Design Workflow Guide](/ai-assisted-architecture-design-workflow-guide/)
- [AI Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/)
- [Best Way to Integrate Claude Code into Team Workflow](/best-way-to-integrate-claude-code-into-team-workflow/)
- [Claude Code For AI Red Teaming — Complete Developer Guide](/claude-code-for-ai-red-teaming-workflow-guide/)
- [Claude Code for Sanity CMS Workflow Tutorial](/claude-code-for-sanity-cms-workflow-tutorial/)
- [Claude Code for Fig — Workflow Guide](/claude-code-for-fig-workflow-guide/)
- [Claude Code for ElastiCache Cluster Workflow](/claude-code-for-elasticache-cluster-workflow/)
- [Claude Code for CrewAI — Workflow Guide](/claude-code-for-crewai-workflow-guide/)
- [Claude Code for Jujutsu VCS — Workflow Guide](/claude-code-for-jujutsu-vcs-workflow-guide/)
- [Claude Code for Beekeeper Studio — Workflow Guide](/claude-code-for-beekeeper-studio-workflow-guide/)
- [Claude Code for TablePlus — Workflow Guide](/claude-code-for-tableplus-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


