---
layout: default
title: "Next.js Performance Optimization (2026)"
description: "Learn how to use Claude Code and specialized skills to optimize Next.js applications for speed, bundle size, and runtime performance."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-nextjs-performance-optimization/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
render_with_liquid: false
geo_optimized: true
---
{% raw %}
Claude Code Next.js Performance Optimization

Next.js performance optimization requires a systematic approach covering bundle analysis, runtime efficiency, and runtime performance. Claude Code combined with specialized skills can accelerate this process significantly.

Getting a Next.js application to feel fast involves multiple distinct layers. A page can have a perfect Lighthouse score in isolation and still feel sluggish in production if caching is misconfigured, if too much JavaScript ships to the browser, or if images load without proper prioritization. This guide walks through each layer methodically, with the kind of code-level detail that lets you take action immediately.

## Understanding the Performance Layers

Before diving into specific techniques, it helps to have a mental model of where performance is lost. Next.js applications typically suffer in one or more of these areas:

| Layer | Primary metric | Common culprit |
|---|---|---|
| Bundle size | Time to Interactive (TTI) | Unoptimized imports, no code splitting |
| Image delivery | Largest Contentful Paint (LCP) | Missing `priority`, wrong `sizes` |
| Data fetching | Time to First Byte (TTFB) | No caching, waterfall requests |
| Runtime rendering | Total Blocking Time (TBT) | Too many Client Components, missing memoization |
| Client navigation | Perceived speed | No prefetching, excessive client-side state |

Claude Code is useful at every layer because it can read your entire codebase at once and identify patterns that human reviewers often miss, like a `'use client'` directive added unnecessarily three levels up a component tree, causing an entire subtree to ship as client JavaScript.

## Analyzing Bundle Size

Large JavaScript bundles directly impact initial load times and Time to Interactive (TTI). The first step is understanding what's actually in your bundle.

Use the `Bash` tool to run bundle analysis:

```bash
npx next build && npx @next/bundle-analyzer
```

This generates a visual report showing which modules contribute most to bundle size. Claude Code can then help you interpret these results and identify optimization targets.

The `frontend-design` skill is particularly useful here, it understands component patterns and can suggest code splitting strategies specific to Next.js App Router. When you describe your page structure, it can recommend which components should use dynamic imports versus static imports.

To enable the bundle analyzer permanently in your project, configure it in `next.config.js`:

```js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
 enabled: process.env.ANALYZE === 'true',
})

module.exports = withBundleAnalyzer({
 // your existing Next.js config
})
```

Then run `ANALYZE=true npm run build` whenever you want a fresh bundle report. Looking at the output, focus on:

- Chunks over 100 kB. these are candidates for dynamic imports
- Duplicated packages. multiple versions of the same library inflate bundles silently
- Packages you don't recognize. often transitive dependencies that is replaced with lighter alternatives

A common discovery is that a single component importing a full charting library (like Recharts or Chart.js) causes every page in the app to download that library. Dynamic imports solve this directly.

## Implementing Dynamic Imports

Code splitting at the component level reduces initial JavaScript payload. Next.js supports dynamic imports natively:

```tsx
import dynamic from 'next/dynamic'

const HeavyChart = dynamic(
 () => import('../components/HeavyChart'),
 {
 loading: () => <ChartSkeleton />,
 ssr: false
 }
)
```

The key decisions are `ssr: false` for client-only components and the loading fallback for perceived performance. Claude Code can audit your page components and suggest where dynamic imports would have the most impact.

Beyond single components, you can dynamically import entire feature modules. Suppose your dashboard has an advanced analytics panel that only power users access. Lazy-load the entire panel:

```tsx
import dynamic from 'next/dynamic'
import { useState } from 'react'

const AdvancedAnalytics = dynamic(
 () => import('../features/AdvancedAnalytics'),
 { loading: () => <div>Loading analytics...</div> }
)

export function Dashboard() {
 const [showAnalytics, setShowAnalytics] = useState(false)

 return (
 <div>
 <button onClick={() => setShowAnalytics(true)}>
 Show Advanced Analytics
 </button>
 {showAnalytics && <AdvancedAnalytics />}
 </div>
 )
}
```

The analytics bundle only downloads when the user clicks the button. For a 200 kB analytics module, this can cut initial page weight in half.

When to use dynamic imports vs. static imports:

| Scenario | Use dynamic import? |
|---|---|
| Component only visible after user action | Yes |
| Component below the fold on most screen sizes | Yes |
| Component requires browser-only APIs (canvas, WebGL) | Yes with `ssr: false` |
| Component visible immediately on page load | No |
| Small utility component (< 5 kB) | No |
| Shared layout component | No |

## Image Optimization Strategies

Images typically account for the largest portion of page weight. Next.js provides the `next/image` component, but proper configuration matters:

```tsx
import Image from 'next/image'

export function HeroSection() {
 return (
 <Image
 src="/hero.png"
 alt="Product screenshot"
 width={1200}
 height={600}
 priority
 sizes="(max-width: 768px) 100vw, 50vw"
 />
 )
}
```

The `priority` prop preloads above-the-fold images, improving Largest Contentful Paint (LCP). The `sizes` attribute helps the browser select the appropriate image variant.

Only use `priority` on the single image that is the LCP element, typically the hero image. Marking multiple images as `priority` defeats the purpose; the browser downloads them all simultaneously and gains nothing.

For images below the fold, Next.js applies lazy loading automatically. You can confirm this is working by checking the Network tab in DevTools, below-fold images should not appear in the initial request waterfall.

Common image mistakes and fixes:

```tsx
// Wrong: no sizes attribute, browser guesses
<Image src="/thumbnail.jpg" width={400} height={300} alt="..." />

// Correct: sizes tells browser the rendered width at each breakpoint
<Image
 src="/thumbnail.jpg"
 width={400}
 height={300}
 sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 400px"
 alt="..."
/>
```

For dynamic images from a CMS or CDN, configure remote patterns in `next.config.js`:

```js
module.exports = {
 images: {
 remotePatterns: [
 {
 protocol: 'https',
 hostname: 'images.yourdomain.com',
 pathname: '/uploads/',
 },
 ],
 formats: ['image/avif', 'image/webp'],
 },
}
```

Enabling AVIF format can reduce image sizes by 20-50% compared to WebP, at the cost of slightly longer encoding time during the build. For most production sites the tradeoff is worthwhile.

## Route-Based Code Splitting

Next.js automatically splits code by route, but you can optimize further with Route Groups:

```
app/
 (marketing)/
 page.tsx
 layout.tsx
 (app)/
 dashboard/
 page.tsx
 layout.tsx
```

Route Groups let you share layouts without bundling marketing code with dashboard code. This is especially valuable when the two sections have different dependency needs.

The `tdd` skill can help you write tests that verify route-based splitting works correctly, ensuring that code intended for one route doesn't leak into another.

A practical way to verify your route splitting is working: after running `next build`, check the `.next/static/chunks` directory. Each route should have its own chunk file. If you see a single large chunk shared across routes that have nothing in common, there is a dependency being inadvertently shared through a module that should be split.

You can also use Next.js's built-in instrumentation to trace which modules load for which routes:

```bash
NEXT_PRIVATE_DEBUG_CACHE=1 npm run build 2>&1 | grep "shared"
```

This surfaces modules being marked as shared across routes, letting you decide whether that sharing is intentional.

## Reducing Client-Side JavaScript

Server Components in Next.js App Router reduce client-side JavaScript by default. The key is understanding which components truly need interactivity:

- Server Components (default): Data fetching, rendering, no interactivity
- Client Components (`'use client'`): Event handlers, hooks, browser APIs

Audit your components with this pattern:

```bash
grep -r "'use client'" app/
```

Aim for Server Components as the default. Move interactivity to leaf components marked with `'use client'`.

A common architectural mistake is placing `'use client'` high in the tree when only a small piece of that subtree needs it. Consider this pattern:

```tsx
// Before: entire card is a Client Component because of one button
'use client'

export function ProductCard({ product }) {
 const [saved, setSaved] = useState(false)

 return (
 <div>
 <h2>{product.name}</h2> {/* Server-renderable */}
 <p>{product.description}</p> {/* Server-renderable */}
 <img src={product.image} alt="" /> {/* Server-renderable */}
 <button onClick={() => setSaved(!saved)}>
 {saved ? 'Saved' : 'Save'}
 </button>
 </div>
 )
}
```

```tsx
// After: only the interactive button is a Client Component
// ProductCard.tsx (Server Component, no 'use client')
import { SaveButton } from './SaveButton'

export function ProductCard({ product }) {
 return (
 <div>
 <h2>{product.name}</h2>
 <p>{product.description}</p>
 <img src={product.image} alt="" />
 <SaveButton />
 </div>
 )
}

// SaveButton.tsx
'use client'
import { useState } from 'react'

export function SaveButton() {
 const [saved, setSaved] = useState(false)
 return (
 <button onClick={() => setSaved(!saved)}>
 {saved ? 'Saved' : 'Save'}
 </button>
 )
}
```

The second pattern ships significantly less JavaScript because the product name, description, and image are rendered on the server and sent as HTML, no JavaScript required.

## Runtime Performance

Bundle size affects load time, but runtime performance affects perceived responsiveness. Key areas include:

## Memoization Strategy

React.memo, useMemo, and useCallback prevent unnecessary re-renders, but overusing them adds complexity without benefit:

```tsx
'use client'

import { memo, useMemo } from 'react'

// Only memoize expensive computations
const ExpensiveList = memo(function ExpensiveList({ items }) {
 const sorted = useMemo(
 () => items.sort((a, b) => b.score - a.score),
 [items]
 )

 return (
 <ul>
 {sorted.map(item => (
 <ListItem key={item.id} item={item} />
 ))}
 </ul>
 )
})
```

A practical rule: only add `useMemo` when you can measure a render time over 1ms for the computation. Memoizing a `.filter()` over a 10-item array adds overhead without benefit. Memoizing a sort-and-group operation over 10,000 items can cut a 50ms computation to near zero on subsequent renders.

Use React DevTools Profiler to identify components that re-render unexpectedly. The "highlight updates" feature in React DevTools makes wasteful re-renders visible at a glance, components flash when they render, so you can spot when a parent re-render is cascading into children unnecessarily.

## Virtualization for Large Lists

Rendering thousands of items tanks performance. Use windowing libraries:

```tsx
import { useVirtualizer } from '@tanstack/react-virtual'

function VirtualList({ items }) {
 const parentRef = useRef(null)

 const virtualizer = useVirtualizer({
 count: items.length,
 getScrollElement: () => parentRef.current,
 estimateSize: () => 48,
 })

 return (
 <div ref={parentRef} style={{ height: '400px', overflow: 'auto' }}>
 <div style={{ height: virtualizer.getTotalSize() }}>
 {virtualizer.getVirtualItems().map(virtual => (
 <div
 key={virtual.key}
 style={{
 position: 'absolute',
 transform: `translateY(${virtual.start}px)`,
 }}
 >
 {items[virtual.index].name}
 </div>
 ))}
 </div>
 </div>
 )
}
```

Virtualization is non-negotiable for lists exceeding a few hundred items. A list of 5,000 items rendered without virtualization can freeze the browser for several seconds on page load. The same list virtualized renders instantly because only the ~15 visible items exist in the DOM at any time.

For variable-height items (like comment threads), use `measureElement` to measure actual rendered heights:

```tsx
const virtualizer = useVirtualizer({
 count: items.length,
 getScrollElement: () => parentRef.current,
 estimateSize: () => 80, // estimate, will be measured
 measureElement: (el) => el.getBoundingClientRect().height,
})
```

## Caching Strategies

Next.js provides multiple caching layers:

1. Request Memoization: Automatic within React
2. Data Cache: Persisted across builds
3. Full Route Cache: Prerendered pages
4. Router Cache: Client-side navigation

For dynamic data, use `revalidate`:

```tsx
async function getData() {
 const res = await fetch('https://api.example.com/data', {
 next: { revalidate: 60 }
 })
 return res.json()
}
```

This caches the fetch result for 60 seconds, reducing database and API load.

For data that changes unpredictably, use on-demand revalidation via tags:

```tsx
// Fetch with a cache tag
async function getProduct(id: string) {
 const res = await fetch(`https://api.example.com/products/${id}`, {
 next: { tags: [`product-${id}`] }
 })
 return res.json()
}

// Route handler to invalidate on demand
// app/api/revalidate/route.ts
import { revalidateTag } from 'next/cache'
import { NextRequest } from 'next/server'

export async function POST(request: NextRequest) {
 const { productId } = await request.json()
 revalidateTag(`product-${productId}`)
 return Response.json({ revalidated: true })
}
```

Your backend can call this endpoint (with appropriate authentication) whenever a product is updated, invalidating only the affected cache entries rather than the entire data cache.

Caching decision matrix:

| Data type | Recommended strategy | Revalidate interval |
|---|---|---|
| Static content (legal, docs) | `force-cache` | Never or long-lived |
| Product catalog | Tag-based revalidation | On change |
| Blog posts | Time-based revalidation | 1 hour |
| User-specific data | `no-store` | N/A |
| Real-time data (prices, inventory) | `no-store` | N/A |

## Server-Side Data Fetching Patterns

One of the most impactful optimizations available in Next.js App Router is moving data fetching out of Client Components entirely. Fetching data in Server Components eliminates client-server waterfalls, the pattern where the browser downloads JavaScript, executes it, discovers it needs data, makes an API request, then renders.

```tsx
// Server Component. no waterfall, data arrives with the HTML
async function ProductPage({ params }) {
 // These two fetches happen in parallel on the server
 const [product, reviews] = await Promise.all([
 getProduct(params.id),
 getReviews(params.id),
 ])

 return (
 <main>
 <ProductDetails product={product} />
 <ReviewList reviews={reviews} />
 </main>
 )
}
```

By using `Promise.all`, both fetches happen simultaneously on the server. The client receives a fully rendered page without making any additional API requests after hydration.

## Measuring Performance

Use the `supermemory` skill to track performance metrics over time. The skill can organize your benchmarks and help you correlate changes with performance improvements:

- Lighthouse: Overall scores
- Web Vitals: Core Web Vitals metrics
- Bundle Analyzer: Size trends
- React DevTools: Component render counts

Run Lighthouse in CI to catch regressions:

```bash
npm install -D @lhci/cli
```

Configure `.lighthouserc.js` to establish performance budgets:

```js
module.exports = {
 ci: {
 collect: {
 url: ['http://localhost:3000/', 'http://localhost:3000/products'],
 numberOfRuns: 3,
 },
 assert: {
 assertions: {
 'categories:performance': ['error', { minScore: 0.85 }],
 'first-contentful-paint': ['error', { maxNumericValue: 2000 }],
 'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],
 'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
 'total-blocking-time': ['error', { maxNumericValue: 300 }],
 },
 },
 upload: {
 target: 'temporary-public-storage',
 },
 },
}
```

These assertions fail the CI pipeline if any page regresses below your defined thresholds, preventing performance regressions from shipping unnoticed.

## Automating Optimization Workflows

Combine Claude Code with your existing tooling. Create a skill that runs a performance audit:

```bash
Performance audit script
npm run build
npx next build --analyze
lighthouse https://localhost:3000 --output json --output-path lighthouse-results.json
```

Claude Code can interpret these results and prioritize fixes based on impact.

A useful pattern is to add performance audit as a pre-deployment step in your CI pipeline. Using GitHub Actions:

```yaml
.github/workflows/performance.yml
name: Performance Audit
on: [pull_request]

jobs:
 lighthouse:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4
 - uses: actions/setup-node@v4
 with:
 node-version: '20'
 - run: npm ci
 - run: npm run build
 - run: npm run start &
 - run: npx wait-on http://localhost:3000
 - run: npx lhci autorun
 env:
 LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}
```

This posts Lighthouse results directly to each pull request, making performance impact visible before merging.

## A Prioritized Optimization Checklist

Not all optimizations are equal. Start with the ones that move metrics the most:

1. Run bundle analyzer. identify and eliminate large unused dependencies
2. Audit `'use client'` directives. push them down to leaf components
3. Add `priority` to LCP images. immediate LCP improvement
4. Add `sizes` attribute to all images. prevents oversized image downloads
5. Implement dynamic imports for below-fold features. reduces TTI
6. Enable Route Groups. prevents marketing code from loading in app routes
7. Add `revalidate` to frequently-fetched data. reduces API and database load
8. Add virtualization to lists over 200 items. eliminates render blocking
9. Set up Lighthouse CI. prevents future regressions
10. Profile with React DevTools. find and fix unexpected re-renders

## Summary

Next.js performance optimization involves multiple layers: bundle size through code splitting, runtime performance through proper component architecture, and caching strategies for data fetching. Claude Code accelerates this process by analyzing your codebase, suggesting targeted optimizations, and helping you implement patterns like dynamic imports and virtualization.

The specialized skills like `frontend-design`, `tdd`, and `supermemory` each contribute to a comprehensive performance workflow, from design patterns that prevent performance issues, to tests that catch regressions, to memory systems that track improvements over time.

Start with bundle analysis, implement route-based and component-based code splitting, add image optimization, and layer on runtime optimizations as needed. Measure continuously to ensure your optimizations actually move the metrics that matter. The checklist above gives you a prioritized starting point that works for most Next.js applications, work through it top-to-bottom, measure after each change, and stop when your Core Web Vitals reach acceptable thresholds.

---


**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-nextjs-performance-optimization)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Next.js Deployment Optimization](/claude-code-nextjs-deployment-optimization/). CI/CD, Docker, environment config, and production release workflows (complements this performance guide)
- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


