---
layout: default
title: "Claude Code For Vue 3 Suspense (2026)"
description: "Learn how to use Claude Code CLI to build Vue 3 Suspense workflows with async components, error boundaries, and practical code examples."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-vue-3-suspense-workflow-tutorial/
categories: [tutorials, guides]
tags: [claude-code, claude-skills, vue-3, suspense, async-components]
reviewed: true
score: 7
render_with_liquid: false
geo_optimized: true
---
{% raw %}
Claude Code for Vue 3 Suspense Workflow Tutorial

Vue 3's Suspense component is a powerful feature for handling async dependencies in your components. When combined with Claude Code, you can rapidly build solid async loading workflows that provide excellent user experiences. This tutorial walks you through using Claude Code to implement Vue 3 Suspense patterns effectively, from basic setup through advanced multi-boundary architectures.

## Understanding Vue 3 Suspense

Suspense is a built-in Vue 3 component that allows you to handle async dependencies in your component tree. Instead of manually managing loading states at each level, Suspense provides a unified way to show fallback content while async components are being resolved.

```vue
<template>
 <Suspense>
 <template #default>
 <AsyncUserProfile />
 </template>
 <template #fallback>
 <LoadingSpinner />
 </template>
 </Suspense>
</template>
```

The key insight is that Suspense intercepts the setup function's promise. When your component returns a Promise from its setup (or uses an async setup), Suspense waits for it to resolve before rendering the default slot.

## How Suspense Differs from Manual Loading State

Before Suspense, every async component required its own loading flag management. That approach leads to repetitive boilerplate and inconsistent loading UX across the app:

```vue
<!-- Old pattern: manual loading state in every component -->
<script setup>
import { ref, onMounted } from 'vue'

const data = ref(null)
const loading = ref(true)
const error = ref(null)

onMounted(async () => {
 try {
 data.value = await fetchData()
 } catch (e) {
 error.value = e.message
 } finally {
 loading.value = false
 }
})
</script>

<template>
 <div v-if="loading">Loading...</div>
 <div v-else-if="error">Error: {{ error }}</div>
 <div v-else>{{ data }}</div>
</template>
```

Suspense eliminates this per-component boilerplate by moving the concern up to a boundary component. The async child just awaits its data; the parent Suspense handles the rest.

## Suspense vs. defineAsyncComponent: Comparison

| Feature | Suspense + async setup | defineAsyncComponent |
|---|---|---|
| Loading component | Parent-controlled | Per-component |
| Error handling | onErrorCaptured hook | errorComponent option |
| Granularity | Entire subtree | Single component |
| Code splitting | Manual import() | Automatic |
| Timeout support | Custom logic | Built-in option |
| Best for | Data fetching | Heavy UI components |

Use `defineAsyncComponent` for large UI chunks you want to code-split. Use async `setup()` with Suspense when the component is always loaded but needs async data before rendering.

## Setting Up Your Vue 3 Project with Claude Code

Before building Suspense workflows, set up a Vue 3 project and configure Claude Code to assist you:

```bash
npm create vue@latest my-suspense-app
cd my-suspense-app
npm install
```

Initialize Claude Code in your project by creating a CLAUDE.md file with Vue-specific context:

```bash
touch CLAUDE.md
```

Add instructions that help Claude understand your project conventions:

```markdown
Project Context

This is a Vue 3 project using Composition API with <script setup> syntax.
- All async data fetching uses top-level await in setup
- Suspense boundaries are at the route level and component level
- Error boundaries are implemented via the ErrorBoundary wrapper component
- Prefer TypeScript for new components
```

This CLAUDE.md file is read automatically every session, giving Claude Code persistent project knowledge without repeating context in each prompt.

## Useful Claude Code Prompts for Suspense Work

When starting a new async component, try prompts like:

- "Create an async Vue 3 component that fetches user data and works with Suspense"
- "Add an error boundary wrapper around my Suspense component with retry logic"
- "Refactor this loading state pattern to use top-level await and Suspense"
- "Generate a skeleton loader component that matches this component's layout"

Claude Code reads your existing components when you reference them by filename, so it can generate matching styles and naming conventions automatically.

## Building Your First Async Component

For a component to work with Suspense, its `setup()` function must return a Promise. The cleanest way to achieve this in Vue 3 is top-level await inside `<script setup>`:

```vue
<!-- UserProfile.vue. works with Suspense via top-level await -->
<script setup>
const response = await fetch('/api/user/1')
const user = await response.json()
</script>

<template>
 <div class="user-profile">
 <h2>{{ user.name }}</h2>
 <p>{{ user.email }}</p>
 <p class="role">{{ user.role }}</p>
 </div>
</template>
```

Because `<script setup>` compiles to a `setup()` function, any top-level `await` causes it to return a Promise. exactly what Suspense needs.

Here is a more complete, production-ready pattern with TypeScript and composable-based fetching:

```vue
<script setup lang="ts">
interface User {
 id: number
 name: string
 email: string
 role: string
 avatarUrl: string
}

const fetchUser = async (id: number): Promise<User> => {
 const res = await fetch(`/api/users/${id}`)
 if (!res.ok) throw new Error(`Failed to load user: ${res.status}`)
 return res.json()
}

const props = defineProps<{ userId: number }>()
const user = await fetchUser(props.userId)
</script>

<template>
 <div class="user-profile">
 <img :src="user.avatarUrl" :alt="user.name" />
 <h2>{{ user.name }}</h2>
 <p>{{ user.email }}</p>
 <span class="badge">{{ user.role }}</span>
 </div>
</template>
```

This pattern throws on error, which Suspense and `onErrorCaptured` in a parent can catch and display.

## Implementing Nested Suspense Boundaries

One of Suspense's powerful features is nested handling. Ask Claude Code to create a dashboard with multiple async components, each with independent loading states:

```vue
<!-- Dashboard.vue -->
<script setup>
import { defineAsyncComponent } from 'vue'
import DashboardSkeleton from './DashboardSkeleton.vue'
import SectionSkeleton from './SectionSkeleton.vue'

const AsyncUserList = defineAsyncComponent(() =>
 import('./components/UserList.vue')
)

const AsyncAnalytics = defineAsyncComponent(() =>
 import('./components/Analytics.vue')
)

const AsyncActivityFeed = defineAsyncComponent(() =>
 import('./components/ActivityFeed.vue')
)
</script>

<template>
 <!-- Outer boundary: waits for ALL sections -->
 <Suspense>
 <template #default>
 <div class="dashboard">
 <!-- Inner boundary: analytics loads independently -->
 <Suspense>
 <template #default>
 <AsyncAnalytics />
 </template>
 <template #fallback>
 <SectionSkeleton type="chart" />
 </template>
 </Suspense>

 <!-- Inner boundary: user list loads independently -->
 <Suspense>
 <template #default>
 <AsyncUserList />
 </template>
 <template #fallback>
 <SectionSkeleton type="list" />
 </template>
 </Suspense>

 <AsyncActivityFeed />
 </div>
 </template>
 <template #fallback>
 <DashboardSkeleton />
 </template>
 </Suspense>
</template>
```

With nested boundaries, the analytics chart can load and render while the user list is still pending. Without nesting, all sections would wait for the slowest component.

## When to Nest vs. Keep Flat

Nested Suspense is the right choice when:
- Sections are independently valuable to the user
- Load times vary significantly between sections
- You want progressive disclosure of content

Keep a flat single Suspense when:
- All content is interdependent and meaningless without the others
- A layout shift from partial loading would confuse users
- The combined load time is short enough that splitting adds no benefit

## Handling Errors with Error Boundaries

Vue 3 doesn't have a built-in error boundary component, but `onErrorCaptured` provides the same capability. Claude Code can help you build a reusable wrapper:

```vue
<!-- ErrorBoundary.vue -->
<script setup>
import { ref, onErrorCaptured } from 'vue'

const props = defineProps({
 fallbackMessage: {
 type: String,
 default: 'Something went wrong'
 }
})

const emit = defineEmits(['retry'])

const error = ref(null)
const errorInfo = ref(null)

onErrorCaptured((err, instance, info) => {
 error.value = err
 errorInfo.value = info
 return false // Prevent propagation to parent boundaries
})

const retry = () => {
 error.value = null
 errorInfo.value = null
 emit('retry')
}
</script>

<template>
 <div v-if="error" class="error-boundary">
 <div class="error-content">
 <h3>{{ fallbackMessage }}</h3>
 <p class="error-detail">{{ error.message }}</p>
 <button class="retry-btn" @click="retry">Try Again</button>
 </div>
 </div>
 <Suspense v-else>
 <template #default>
 <slot />
 </template>
 <template #fallback>
 <slot name="loading">
 <div class="loading-placeholder">Loading...</div>
 </slot>
 </template>
 </Suspense>
</template>
```

Use this wrapper throughout your application for consistent error handling:

```vue
<ErrorBoundary fallback-message="Failed to load user data" @retry="refreshKey++">
 <template #loading>
 <UserProfileSkeleton />
 </template>
 <UserProfile :key="refreshKey" :user-id="userId" />
</ErrorBoundary>
```

The `key` prop trick forces the component to remount on retry, re-triggering the async setup and clearing the error state.

## Practical Suspense Workflow Patterns

1. Multiple Dependent Async Resources

When components depend on each other, use sequential loading within the same async setup:

```vue
<script setup>
const fetchDashboardData = async () => {
 // Sequential: each step depends on the previous
 const user = await fetchUser()
 const permissions = await fetchPermissions(user.id)
 const dashboard = await fetchDashboard(permissions.dashboardId)

 return { user, permissions, dashboard }
}

const { user, permissions, dashboard } = await fetchDashboardData()
</script>
```

2. Parallel Loading with Promise.all

For independent async operations, load in parallel to minimize total wait time:

```vue
<script setup>
// Parallel: all three start at the same time
const [users, posts, comments] = await Promise.all([
 fetchUsers(),
 fetchPosts(),
 fetchComments()
])
</script>
```

The difference between sequential and parallel can be dramatic. If each fetch takes 300ms, sequential takes 900ms total while parallel takes 300ms.

3. Timeout Handling with defineAsyncComponent

Add timeout fallbacks for better UX when loading heavy route-level components:

```vue
<script setup>
import { defineAsyncComponent } from 'vue'
import LoadingSpinner from './LoadingSpinner.vue'
import ErrorDisplay from './ErrorDisplay.vue'

const LazyComponent = defineAsyncComponent({
 loader: () => import('./HeavyComponent.vue'),
 loadingComponent: LoadingSpinner,
 delay: 200, // Wait 200ms before showing loading state
 timeout: 5000, // Show error after 5 seconds
 errorComponent: ErrorDisplay,
 onError(error, retry, fail, attempts) {
 if (attempts <= 3) {
 retry()
 } else {
 fail()
 }
 }
})
</script>
```

The `delay` option prevents loading flash for fast connections, while `timeout` and `onError` handle slow or failed networks with automatic retry logic.

4. Route-Level Suspense with Vue Router

Integrating Suspense at the router view level gives every page consistent async handling:

```vue
<!-- App.vue -->
<template>
 <RouterView v-slot="{ Component }">
 <ErrorBoundary>
 <template #loading>
 <PageSkeleton />
 </template>
 <Suspense>
 <component :is="Component" />
 <template #fallback>
 <PageSkeleton />
 </template>
 </Suspense>
 </ErrorBoundary>
 </RouterView>
</template>
```

This pattern means every page component can use top-level await freely, with consistent loading and error UX across the entire application.

5. Suspense with Pinia Stores

When using Pinia for state management, async actions can be awaited at the store level before components render:

```vue
<!-- ComponentUsingStore.vue -->
<script setup>
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

// Await the store action. Suspense handles the pending state
await userStore.fetchCurrentUser()
</script>

<template>
 <div>
 <h2>Welcome, {{ userStore.currentUser.name }}</h2>
 </div>
</template>
```

```javascript
// stores/user.js
import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
 state: () => ({ currentUser: null }),
 actions: {
 async fetchCurrentUser() {
 const res = await fetch('/api/me')
 this.currentUser = await res.json()
 }
 }
})
```

## Building Skeleton Loaders That Match Your Layout

Skeleton loaders are significantly better than generic spinners because they maintain layout stability and give users a visual preview of the content structure. Ask Claude Code to generate a matching skeleton for any component:

```vue
<!-- UserProfileSkeleton.vue -->
<template>
 <div class="user-profile skeleton">
 <div class="skeleton-avatar pulse"></div>
 <div class="skeleton-lines">
 <div class="skeleton-line skeleton-line--name pulse"></div>
 <div class="skeleton-line skeleton-line--email pulse"></div>
 <div class="skeleton-line skeleton-line--role pulse"></div>
 </div>
 </div>
</template>

<style scoped>
.pulse {
 background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
 background-size: 200% 100%;
 animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
 0% { background-position: 200% 0; }
 100% { background-position: -200% 0; }
}

.skeleton-avatar {
 width: 64px;
 height: 64px;
 border-radius: 50%;
}

.skeleton-line {
 height: 16px;
 border-radius: 4px;
 margin-bottom: 8px;
}

.skeleton-line--name { width: 40%; }
.skeleton-line--email { width: 60%; }
.skeleton-line--role { width: 25%; }
</style>
```

## Best Practices from Claude Code

When working with Vue 3 Suspense, Claude Code recommends these patterns:

1. Keep async components focused - Each async component should handle one data domain. Components that fetch user data, permissions, and settings separately are easier to cache, test, and reuse.
2. Use meaningful loading states - Skeleton loaders that match component layout reduce perceived load time and prevent jarring layout shifts when content appears.
3. Implement proper error handling - Always wrap Suspense in an error boundary. Network failures are inevitable; the question is whether users see a useful message or a broken page.
4. Consider component lifecycle - Async components mounted during route navigation need cleanup. Use `onUnmounted` to cancel in-flight requests with `AbortController`.
5. Test with slow networks - Use Chrome DevTools Network tab to throttle to "Slow 3G" and verify your skeleton loaders and timeouts work correctly.
6. Avoid waterfall fetching - If three components each make sequential API calls, consider combining them into a single parallel fetch in a parent component.

## Debugging Suspense Issues

When Suspense doesn't behave as expected, check these common issues:

- Component never leaves pending state: Ensure async components return Promises from setup. Using `onMounted` for data fetching does NOT trigger Suspense. the Promise must come from `setup()` itself.
- defineAsyncComponent loader issues: Verify loader functions return `import()` Promises. A common mistake is calling `import()` outside the loader function so it executes immediately on component registration.
- Unhandled rejections cause silent failures: Wrap async setup calls in try/catch or ensure a parent `onErrorCaptured` is in place. Unhandled async errors in `setup()` will reach Suspense's error state.
- Re-renders don't re-fetch: Top-level awaits only run once on mount. To re-fetch on prop changes, use a `watch` or force remount with a `key` change.
- Nested Suspense doesn't activate: Inner Suspense boundaries only catch pending components inside their default slot. If async components are rendered outside the default slot they won't be caught.

Claude Code can help diagnose issues by examining your component tree and identifying where async dependencies aren't properly configured. Paste the relevant component files into your session and describe the behavior you're seeing.

## Using Claude Code to Generate Suspense Boilerplate

Claude Code significantly accelerates Suspense workflow development by generating complete patterns from short prompts. Some effective prompts:

Generate a full async page component:
```
Create a Vue 3 page component that fetches a list of products from /api/products,
uses top-level await for Suspense compatibility, and includes TypeScript types.
```

Create a reusable error boundary:
```
Build a Vue 3 ErrorBoundary component that wraps Suspense, exposes a retry
mechanism, and accepts a custom error message prop.
```

Refactor existing code:
```
Refactor this component to use top-level await instead of onMounted loading
state, making it compatible with Vue 3 Suspense.
```

Claude Code generates production-ready code that follows your project's existing conventions when your CLAUDE.md contains sufficient context.

## Conclusion

Vue 3 Suspense provides an elegant solution for managing async component loading. By combining Suspense with thoughtful error handling and loading states, you create applications that feel responsive and handle network variability gracefully. Use Claude Code to rapidly prototype these patterns and iterate on your implementation.

The combination of top-level await in `<script setup>`, nested Suspense boundaries, reusable error boundary components, and skeleton loaders covers the vast majority of real-world async UI requirements. Start with simple async components at the route level, then progressively add nested boundaries and granular skeletons as your application's complexity grows.

The investment in proper async handling. particularly the error boundary wrapper and meaningful skeleton loaders. pays compounding returns as your application scales. Users encounter fewer broken states, and developers spend less time debugging inconsistent loading behavior across different parts of the app.


---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-vue-3-suspense-workflow-tutorial)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading


- [Getting Started Guide](/getting-started/). From zero to productive with Claude Code
- [Claude Code for Apache Drill Workflow Tutorial](/claude-code-for-apache-drill-workflow-tutorial/)
- [Claude Code for Astro Actions Workflow Tutorial](/claude-code-for-astro-actions-workflow-tutorial/)
- [Claude Code for Automated PR Checks Workflow Tutorial](/claude-code-for-automated-pr-checks-workflow-tutorial/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


