---

layout: default
title: "Qwik State Management with Claude Code (2026)"
description: "Master Qwik useStore and useSignal reactive state management with Claude Code. Resumability patterns and serialization strategies explained."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-qwik-store-reactive-state-management-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
last_tested: "2026-04-21"
geo_optimized: true
---

Qwik's unique approach to reactivity sets it apart from traditional JavaScript frameworks. Instead of hydrating entire applications on the client, Qwik uses resumability, serializing state into the HTML and resuming execution where the server left off. Understanding how to manage this reactive state is essential for building performant Qwik applications.

This guide covers Qwik's core state management primitives: `useStore` for reactive objects and `useSignal` for primitive values, along with patterns for building scalable state management in your Qwik projects. We'll go deep on the internals, compare approaches to other frameworks, and show you how to use Claude Code effectively when building Qwik state logic.

## Understanding Qwik's Reactivity Model

Unlike React's virtual DOM diffing or Vue's proxy-based reactivity, Qwik uses a fine-grained reactive system that tracks dependencies at the component level. When you modify reactive state, Qwik only updates the specific DOM nodes that depend on that changed value.

The key primitives you'll work with are:

- useSignal: For primitive values (strings, numbers, booleans)
- useStore: For complex objects and nested reactivity
- useComputed: For derived values that automatically update

```typescript
import { component$, useStore, useSignal, useComputed$ } from '@builder.io/qwik';

export default component$(() => {
 // Primitive state - use useSignal
 const count = useSignal(0);

 // Complex state - use useStore
 const user = useStore({
 name: 'John',
 preferences: {
 theme: 'dark',
 notifications: true
 }
 });

 // Derived state
 const doubled = useComputed$(() => count.value * 2);

 return (
 <div>
 <p>Count: {count.value}</p>
 <p>Doubled: {doubled.value}</p>
 <p>User: {user.name}</p>
 <button onClick$={() => count.value++}>Increment</button>
 </div>
 );
});
```

## How Resumability Differs from Hydration

The key reason Qwik state management works the way it does comes down to resumability. In React or Vue, when a server-rendered page loads in the browser, the framework re-executes all component code to build up an event listener map and reconcile the virtual DOM. This is hydration, and it happens even if no user interaction has occurred yet.

Qwik avoids this entirely. State is serialized into the HTML as JSON and loaded lazily. When a user clicks a button, Qwik deserializes only the state relevant to that interaction, executes only the event handler that was triggered, and patches only the affected DOM nodes.

This has direct consequences for state design:

- State must be serializable (no closures, no class instances with methods, no circular references)
- Reactive signals and stores are Qwik's serialization-safe containers for component state
- Every `$` suffix on a function (like `onClick$`) marks a lazy boundary where Qwik can split code

Understanding this context helps you write better state logic and avoid subtle bugs when working with Claude Code on Qwik projects.

## Qwik vs React vs Vue: Reactivity Comparison

| Feature | Qwik | React | Vue 3 |
|---|---|---|---|
| Reactivity model | Fine-grained signals | Virtual DOM diffing | Proxy-based reactivity |
| Initial JS on load | Near zero | Full bundle hydration | Full bundle hydration |
| State serialization | Built-in (resumable) | Not built-in | Not built-in |
| Derived state | `useComputed$` | `useMemo` | `computed()` |
| Global state | Context API + `useStore` | Context + useReducer / Zustand | Pinia / Vuex |
| Mutation style | Direct mutation on store/signal | `setState` or setter functions | Direct mutation on reactive refs |
| Auto-memoization | Yes (framework-level) | Manual (`memo`, `useMemo`) | Partial (computed caches) |
| TypeScript support | First-class | First-class | First-class |

The most meaningful difference for day-to-day development is mutation style. In Qwik you mutate reactive state directly (`count.value++`, `store.user.name = 'Alice'`) and Qwik tracks the dependency graph for you. There is no setState equivalent, no immer-style immutable updates, and no manual dependency arrays.

useStore Detailed look

The `useStore` hook creates a reactive object that Qwik tracks at a fine-grained level. The second argument lets you configure reactivity options.

## Basic Store Usage

```typescript
interface Todo {
 id: number;
 text: string;
 completed: boolean;
}

export const TodoList = component$(() => {
 const store = useStore({
 todos: [] as Todo[],
 filter: 'all' as 'all' | 'active' | 'completed'
 });

 return (
 <div>
 <select
 value={store.filter}
 onChange$={(e) => store.filter = (e.target as HTMLSelectElement).value as any}
 >
 <option value="all">All</option>
 <option value="active">Active</option>
 <option value="completed">Completed</option>
 </select>

 <ul>
 {store.todos.map(todo => (
 <li key={todo.id}>
 <input
 type="checkbox"
 checked={todo.completed}
 onChange$={(e) => todo.completed = (e.target as HTMLInputElement).checked}
 />
 {todo.text}
 </li>
 ))}
 </ul>
 </div>
 );
});
```

## Adding Items to a Store Array

One common source of confusion is array mutation. Qwik tracks array length and index access, but you need to be careful with methods like `push`, `splice`, and `filter`. Direct mutations work, but reassigning the array reference also works cleanly:

```typescript
export const TodoManager = component$(() => {
 const store = useStore({
 todos: [] as Todo[],
 nextId: 1,
 inputText: ''
 });

 const addTodo = $(() => {
 if (!store.inputText.trim()) return;
 // Direct push works with Qwik's proxy
 store.todos.push({
 id: store.nextId++,
 text: store.inputText.trim(),
 completed: false
 });
 store.inputText = '';
 });

 const removeTodo = $((id: number) => {
 // Reassigning the array reference also triggers reactivity
 store.todos = store.todos.filter(t => t.id !== id);
 });

 const toggleTodo = $((id: number) => {
 const todo = store.todos.find(t => t.id === id);
 if (todo) todo.completed = !todo.completed;
 });

 return (
 <div class="todo-app">
 <div class="add-row">
 <input
 value={store.inputText}
 onInput$={(e) => store.inputText = (e.target as HTMLInputElement).value}
 onKeyDown$={(e) => e.key === 'Enter' && addTodo()}
 placeholder="Add a todo..."
 />
 <button onClick$={addTodo}>Add</button>
 </div>
 <ul>
 {store.todos.map(todo => (
 <li key={todo.id} class={todo.completed ? 'done' : ''}>
 <input
 type="checkbox"
 checked={todo.completed}
 onChange$={() => toggleTodo(todo.id)}
 />
 <span>{todo.text}</span>
 <button onClick$={() => removeTodo(todo.id)}>x</button>
 </li>
 ))}
 </ul>
 </div>
 );
});
```

## Nested Reactivity with useStore

One of Qwik's powerful features is deep reactivity. By default, changes to nested properties trigger updates:

```typescript
export const NestedStore = component$(() => {
 const store = useStore({
 config: {
 api: {
 endpoint: '/api/v1',
 timeout: 5000
 }
 }
 });

 return (
 <div>
 <button onClick$={() => {
 // This deeply nested change still triggers reactivity
 store.config.api.timeout = 10000;
 }}>
 Update Timeout
 </button>
 </div>
 );
});
```

However, you can optimize performance by using the `reactive` option set to `false` for flat structures:

```typescript
const flatStore = useStore({
 prop1: 'value1',
 prop2: 'value2'
}, { reactive: false });
```

## When to Use reactive: false

The `reactive: false` option is a performance optimization for stores where you know you will replace the whole value rather than mutate individual properties. A common use case is a pagination store where the entire page data refreshes on each request:

```typescript
export const PaginatedList = component$(() => {
 // This store's data is always replaced wholesale, never mutated in place
 const page = useStore({
 items: [] as string[],
 total: 0,
 currentPage: 1
 }, { reactive: false });

 const loadPage = $(async (pageNum: number) => {
 const res = await fetch(`/api/items?page=${pageNum}`);
 const data = await res.json();
 // Replacing the whole store object works with reactive: false
 page.items = data.items;
 page.total = data.total;
 page.currentPage = pageNum;
 });

 return (
 <div>
 <button onClick$={() => loadPage(page.currentPage - 1)}>Prev</button>
 <span>Page {page.currentPage}</span>
 <button onClick$={() => loadPage(page.currentPage + 1)}>Next</button>
 </div>
 );
});
```

useSignal for Primitive Values

Use `useSignal` when you have single primitive values. Signals are more performant than stores for simple values because they have less overhead.

```typescript
export const SignalCounter = component$(() => {
 const count = useSignal(0);
 const name = useSignal('Guest');
 const isLoading = useSignal(false);

 return (
 <div>
 <h1>Hello, {name.value}!</h1>
 <p>Count: {count.value}</p>

 <button
 onClick$={() => count.value++}
 disabled={isLoading.value}
 >
 Increment
 </button>

 <button onClick$={() => isLoading.value = !isLoading.value}>
 Toggle Loading
 </button>
 </div>
 );
});
```

## Signals for DOM References

`useSignal` doubles as Qwik's ref mechanism. When you assign a signal to a JSX element's `ref` attribute, Qwik populates the signal's value with the DOM element after mount:

```typescript
export const FocusInput = component$(() => {
 const inputRef = useSignal<HTMLInputElement>();

 const focusInput = $(() => {
 // After mount, inputRef.value is the actual DOM element
 inputRef.value?.focus();
 });

 return (
 <div>
 <input ref={inputRef} type="text" placeholder="Type here..." />
 <button onClick$={focusInput}>Focus Input</button>
 </div>
 );
});
```

This is a clean, typed alternative to `document.querySelector` and avoids the need for a separate ref API.

useSignal vs useStore: Decision Guide

| Use case | Recommended primitive |
|---|---|
| Single boolean flag | `useSignal<boolean>` |
| Counter or numeric value | `useSignal<number>` |
| Current selected tab | `useSignal<string>` |
| DOM element reference | `useSignal<HTMLElement>` |
| Form with multiple fields | `useStore` |
| List of items | `useStore` with array property |
| Nested configuration object | `useStore` with deep reactivity |
| Flat key-value config replaced wholesale | `useStore` with `reactive: false` |
| Shared global state | `useStore` + context |

## Computed State with useComputed$

`useComputed$` creates a derived signal that automatically recalculates when its reactive dependencies change. The result is cached until a dependency changes, so you never run expensive derivations on every render.

```typescript
export const FilteredList = component$(() => {
 const store = useStore({
 items: ['apple', 'banana', 'apricot', 'blueberry', 'cherry'],
 query: ''
 });

 const filtered = useComputed$(() =>
 store.query.length === 0
 ? store.items
 : store.items.filter(item =>
 item.toLowerCase().includes(store.query.toLowerCase())
 )
 );

 return (
 <div>
 <input
 value={store.query}
 onInput$={(e) => store.query = (e.target as HTMLInputElement).value}
 placeholder="Filter fruits..."
 />
 <p>{filtered.value.length} results</p>
 <ul>
 {filtered.value.map(item => (
 <li key={item}>{item}</li>
 ))}
 </ul>
 </div>
 );
});
```

A key rule: `useComputed$` is read-only. You cannot assign to `filtered.value`. If you need bidirectional derived state, use a store with explicit setter logic instead.

## Sharing State Across Components

Qwik provides several patterns for sharing state between components.

## Props Drilling with Signals

Pass signals down as props for parent-child communication:

```typescript
interface Props {
 count: { value: number };
}

export const Parent = component$(() => {
 const sharedCount = useSignal(0);

 return (
 <div>
 <Child count={sharedCount} />
 <button onClick$={() => sharedCount.value++}>
 Parent Increment
 </button>
 </div>
 );
});

export const Child = component$<Props>(({ count }) => {
 return (
 <div>
 <p>Child sees: {count.value}</p>
 <button onClick$={() => count.value++}>
 Child Increment
 </button>
 </div>
 );
});
```

## Using Context for Global State

For truly global state, use Qwik's context API:

```typescript
import { createContextId, useContext, useContextProvider, useStore } from '@builder.io/qwik';

interface AppState {
 theme: 'light' | 'dark';
 user: { name: string } | null;
}

export const AppContext = createContextId<AppState>('app-context');

export const AppProvider = component$(() => {
 const appState = useStore<AppState>({
 theme: 'light',
 user: null
 });

 useContextProvider(AppContext, appState);

 return <Slot />;
});

// Using the context in any component
export const ThemedComponent = component$(() => {
 const appState = useContext(AppContext);

 return (
 <button onClick$={() => {
 appState.theme = appState.theme === 'light' ? 'dark' : 'light';
 }}>
 Current: {appState.theme}
 </button>
 );
});
```

## Real-World Context: Auth State

Here is a more complete example showing a global auth context with typed actions:

```typescript
import {
 createContextId,
 useContext,
 useContextProvider,
 useStore,
 component$,
 Slot,
 $
} from '@builder.io/qwik';

interface User {
 id: string;
 email: string;
 role: 'admin' | 'user';
}

interface AuthState {
 user: User | null;
 isLoading: boolean;
 error: string | null;
}

export const AuthContext = createContextId<AuthState>('auth');

export const AuthProvider = component$(() => {
 const auth = useStore<AuthState>({
 user: null,
 isLoading: false,
 error: null
 });

 useContextProvider(AuthContext, auth);
 return <Slot />;
});

export const LoginButton = component$(() => {
 const auth = useContext(AuthContext);

 const login = $(async (email: string, password: string) => {
 auth.isLoading = true;
 auth.error = null;
 try {
 const res = await fetch('/api/login', {
 method: 'POST',
 body: JSON.stringify({ email, password }),
 headers: { 'Content-Type': 'application/json' }
 });
 if (!res.ok) throw new Error('Invalid credentials');
 auth.user = await res.json();
 } catch (err: any) {
 auth.error = err.message;
 } finally {
 auth.isLoading = false;
 }
 });

 if (auth.user) {
 return <span>Logged in as {auth.user.email}</span>;
 }

 return (
 <button
 onClick$={() => login('demo@example.com', 'password')}
 disabled={auth.isLoading}
 >
 {auth.isLoading ? 'Logging in...' : 'Log In'}
 </button>
 );
});
```

This pattern shows how to handle async state transitions, loading, error, and success, entirely within Qwik's reactive primitives.

## Using Claude Code to Build Qwik State Logic

Claude Code is particularly effective for scaffolding Qwik stores because the patterns are structured and repetitive. Here are prompts that get good results:

Prompt for generating a typed store with actions:

```
Create a Qwik useStore for a shopping cart.
The cart should support:
- Adding items with id, name, price, and quantity
- Removing items by id
- Updating quantity for an existing item
- A computed total price
Use TypeScript interfaces. Include useComputed$ for the total.
```

Prompt for context migration from React:

```
I have a React Context with useReducer managing user preferences
(theme, language, fontSize). Convert this to Qwik's context API
using useStore and useContextProvider.
Keep the same TypeScript types but use Qwik mutation style.
```

Prompt for debugging reactivity issues:

```
My Qwik component updates store.items with a push() call but the
UI doesn't re-render. The store uses { reactive: false }.
Explain why and show me the fix.
```

Claude Code works best with Qwik when you are explicit about which primitive to use and whether the state is serializable. If you describe a state shape that includes functions or class instances, ask Claude Code to flag the serialization issue and suggest an alternative.

## State Serialization Rules and Common Pitfalls

Because Qwik serializes state into HTML, certain values cannot be stored in `useStore` or `useSignal`:

| Value type | Serializable | Alternative |
|---|---|---|
| `string`, `number`, `boolean` | Yes | - |
| Plain object | Yes | - |
| Array of plain objects | Yes | - |
| `null`, `undefined` | Yes | - |
| Function / closure | No | Use `$()` at module scope |
| Class instance with methods | No | Use plain object + module-scope functions |
| DOM element | No | Use `useSignal<HTMLElement>` (Qwik handles the ref) |
| `Promise` | No | Resolve first, store result |
| Circular reference | No | Flatten or use IDs |

A common mistake is storing a fetched class instance directly in state:

```typescript
// WRONG: Class instances are not serializable
class UserModel {
 constructor(public name: string) {}
 greet() { return `Hello ${this.name}`; }
}

const store = useStore({ user: new UserModel('Alice') }); // Will break resumability

// CORRECT: Use a plain object
const store = useStore({ user: { name: 'Alice' } });
// Define greet as a standalone function or useComputed$
const greeting = useComputed$(() => `Hello ${store.user.name}`);
```

## Best Practices for Qwik State Management

Follow these practices to build maintainable Qwik applications:

1. Choose the right primitive: Use `useSignal` for primitives, `useStore` for objects. This optimization matters in large applications.

2. Minimize reactivity scope: When possible, use `{ reactive: false }` on stores that don't need deep tracking.

3. Keep state co-located: Define state in the component that needs it. Only lift state up when truly necessary.

4. Use computed values wisely: `useComputed$` caches results and only recalculates when dependencies change, making it efficient for derived state.

5. Use $ suffix: Remember that event handlers ending with `$` are lazy-loaded. This is fundamental to Qwik's performance model.

6. Keep state serializable: Avoid storing functions, class instances, or circular references in stores.

7. Use context for cross-tree state: When multiple unrelated subtrees need shared state, prefer context over deeply threaded props.

```typescript
// Good: Derived value with useComputed$
const fullName = useComputed$(() =>
 `${user.value.firstName} ${user.value.lastName}`
);

// Avoid: Computing derived values during render
// const fullName = user.value.firstName + ' ' + user.value.lastName;
```

## Practical Anti-Patterns to Avoid

## Anti-pattern: Storing derived state in a store instead of computing it

```typescript
// AVOID: keeping a computed value in the store causes sync issues
const store = useStore({
 firstName: 'Alice',
 lastName: 'Smith',
 fullName: 'Alice Smith' // Must be manually kept in sync
});

// PREFER: derive it with useComputed$
const store = useStore({ firstName: 'Alice', lastName: 'Smith' });
const fullName = useComputed$(() => `${store.firstName} ${store.lastName}`);
```

## Anti-pattern: Using multiple signals when a single store is cleaner

```typescript
// AVOID when fields are closely related
const firstName = useSignal('');
const lastName = useSignal('');
const email = useSignal('');
const isSubmitting = useSignal(false);

// PREFER: group related form state in a store
const form = useStore({
 firstName: '',
 lastName: '',
 email: '',
 isSubmitting: false
});
```

## Anti-pattern: Triggering fetches in computed values

```typescript
// AVOID: side effects in useComputed$ lead to unpredictable behavior
const data = useComputed$(async () => {
 const res = await fetch('/api/data'); // side effect inside computed
 return res.json();
});

// PREFER: use useTask$ for side effects
useTask$(async ({ track }) => {
 track(() => store.query);
 const res = await fetch(`/api/data?q=${store.query}`);
 store.results = await res.json();
});
```

## Conclusion

Qwik's reactive state management offers a fresh perspective on building web applications. By understanding when to use `useSignal` versus `useStore`, using context for global state, and following best practices for reactivity, you can build applications that are both highly performant and easy to maintain.

The key insight is that Qwik's fine-grained reactivity means you don't need to think about memoization or optimization strategies that plague other frameworks, Qwik handles this automatically at the framework level.

When using Claude Code to assist with Qwik development, lean on it for generating typed store shapes, scaffolding context providers, and catching serialization issues early. The structured nature of Qwik's state primitives makes it one of the best frameworks for AI-assisted development, the rules are clear and the output is predictable.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-qwik-store-reactive-state-management-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Flutter State Management Workflow Best Practices](/claude-code-flutter-state-management-workflow-bestpractices/)
- [Claude Code for Zustand State Management Workflow](/claude-code-for-zustand-state-management-workflow/)
- [Claude Code Redux Toolkit State Management Guide](/claude-code-redux-toolkit-state-management-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


