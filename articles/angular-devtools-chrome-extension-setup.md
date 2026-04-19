---
layout: default
title: "Angular DevTools Setup Chrome Extension Guide (2026)"
description: "Learn how to install and configure Angular DevTools for Chrome to debug, inspect, and optimize your Angular applications effectively."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /angular-devtools-chrome-extension-setup/
reviewed: true
score: 8
categories: [guides]
tags: [chrome, claude-skills]
render_with_liquid: false
geo_optimized: true
---
{% raw %}
Angular DevTools is an official Chrome extension provided by the Angular team that provides powerful debugging and profiling capabilities for Angular applications. Whether you are maintaining a legacy Angular project or building a modern application with the latest Angular version, this extension significantly improves your development workflow. It bridges the gap between generic browser DevTools and Angular-specific internals, exposing the component tree, change detection behavior, and performance timing in ways that were previously only accessible through console logging or guesswork.

## Installing Angular DevTools

The installation process is straightforward. Open Chrome and navigate to the [Angular DevTools Chrome Web Store page](https://chrome.google.com/webstore/detail/angular-devtools/ienfalfjdbdpebioblbfnkbdplhggbhce). Click the "Add to Chrome" button and confirm the installation.

After installation, you will see the Angular logo in your Chrome toolbar. The extension remains disabled until you open an Angular application running Angular version 9 or later. When you visit a qualifying app, the toolbar icon activates, indicating that DevTools has detected the Angular runtime.

Angular DevTools works entirely client-side. it communicates with Angular's debugging APIs built into development builds. No server configuration or npm package is required for basic usage.

## Verifying Your Installation

Once installed, verify that Angular DevTools is working correctly:

1. Open your Angular application in Chrome
2. Right-click anywhere on the page and select "Inspect" to open DevTools
3. Look for the "Angular" tab in the DevTools panel

If the Angular tab does not appear, ensure your application meets the following requirements:

- Angular version 9 or higher
- The application is running in development mode with Ivy renderer
- No conflicting extensions that might interfere with DevTools

A quick way to confirm the Ivy renderer is active is to check your browser console. If you see no "View Engine" references and your build was produced with Angular 9+, Ivy is running. For projects with custom webpack configurations, double-check that you have not disabled Ivy explicitly in `tsconfig.app.json`.

## Comparing Angular DevTools to Browser DevTools

Before diving into the Angular-specific features, it helps to understand what Angular DevTools adds on top of the standard Chrome DevTools.

| Feature | Chrome DevTools | Angular DevTools |
|---|---|---|
| DOM element inspection | Yes | No |
| JavaScript console | Yes | No |
| Network requests | Yes | No |
| Component tree view | No | Yes |
| Component property editing | No | Yes |
| Change detection timeline | No | Yes |
| Angular-specific profiling | No | Yes |
| Directive inspection | No | Yes |

The two toolsets are complementary. Use Chrome DevTools for network, console, and DOM work. Use Angular DevTools for everything related to Angular's runtime: components, inputs, outputs, change detection, and performance.

## Understanding the Angular DevTools Interface

The Angular DevTools interface consists of two main tabs: the Component Explorer and the Profiler.

## Component Explorer Tab

The Component Explorer provides a tree view of your application's component hierarchy. You can expand nodes to see child components, directives, and pipes. Each node displays:

- Component or directive name
- Current property values
- Change detection status

You can interact directly with components from this view. Click on any component to inspect its properties in the right panel. Modified values reflect immediately in your application, which is useful for testing different states without reloading the page.

The Component Explorer is particularly useful when debugging deeply nested component trees. Rather than tracing through parent-child relationships manually in code, you can visualize the full hierarchy instantly and jump to the component that holds the state you care about.

## Profiler Tab

The Profiler tab records and displays change detection cycles. This helps you identify performance bottlenecks by showing:

- Time spent in each change detection cycle
- Components that triggered changes
- Overall application performance metrics

To use the profiler, click the "Record" button and interact with your application. Stop recording to analyze the results. The resulting timeline breaks down exactly which components ran change detection, how long each took, and what triggered each cycle.

## Practical Examples

## Inspecting Component State

Consider a simple counter application:

```typescript
import { Component } from '@angular/core';

@Component({
 selector: 'app-counter',
 template: `
 <button (click)="decrement()">-</button>
 <span>Count: {{ count }}</span>
 <button (click)="increment()">+</button>
 `
})
export class CounterComponent {
 count = 0;

 increment() {
 this.count++;
 }

 decrement() {
 this.count--;
 }
}
```

With Angular DevTools, you can select the `app-counter` component in the Component Explorer and view the current `count` value in real-time. You can also modify the count value directly in the properties panel to test edge cases without writing test code or console logs.

## Inspecting Service-Driven Components

Components that receive data from services are a common source of confusion during debugging. Consider a product list that loads from a service:

```typescript
import { Component, OnInit } from '@angular/core';
import { ProductService } from './product.service';

@Component({
 selector: 'app-product-list',
 template: `
 <div *ngFor="let product of products">
 <h3>{{ product.name }}</h3>
 <p>Price: {{ product.price }}</p>
 </div>
 `
})
export class ProductListComponent implements OnInit {
 products: any[] = [];
 isLoading = false;
 errorMessage = '';

 constructor(private productService: ProductService) {}

 ngOnInit() {
 this.isLoading = true;
 this.productService.getProducts().subscribe({
 next: (data) => {
 this.products = data;
 this.isLoading = false;
 },
 error: (err) => {
 this.errorMessage = err.message;
 this.isLoading = false;
 }
 });
 }
}
```

In the Component Explorer, you can monitor `products`, `isLoading`, and `errorMessage` as they change during the data fetch. If `isLoading` stays `true`, you know the observable never completed. If `products` remains empty despite a successful request, you can inspect the actual response data without adding a single `console.log`.

## Debugging Change Detection Issues

When your application experiences performance problems, the Profiler helps identify the cause:

1. Click the "Profiler" tab
2. Click "Record" to start capturing
3. Perform actions in your application
4. Click "Stop" to end the recording

The profiler displays a timeline showing each change detection cycle. Bars highlighted in red indicate cycles that took longer than expected. Click on any bar to see which components triggered the change detection.

For applications using `OnPush` change detection strategy, this is particularly valuable. You can verify that change detection only runs when expected, rather than on every event.

## Diagnosing Over-Rendering with OnPush

The most impactful use of the Profiler is identifying unnecessary change detection in large lists. Consider a dashboard with many child components that use `Default` change detection:

```typescript
import { Component, ChangeDetectionStrategy, Input } from '@angular/core';

// Problematic: Default strategy triggers on every parent update
@Component({
 selector: 'app-dashboard-card',
 changeDetection: ChangeDetectionStrategy.Default,
 template: `<div>{{ title }}</div>`
})
export class DashboardCardComponent {
 @Input() title: string = '';
}
```

After profiling, if you see 50 child components all re-rendering when only one changed, this is your cue to switch them to `OnPush`:

```typescript
@Component({
 selector: 'app-dashboard-card',
 changeDetection: ChangeDetectionStrategy.OnPush,
 template: `<div>{{ title }}</div>`
})
export class DashboardCardComponent {
 @Input() title: string = '';
}
```

Re-run the profiler after this change. You should see a dramatic reduction in components included in each change detection cycle. The Profiler makes this before-and-after comparison concrete and measurable.

## Configuration Options

Angular DevTools offers several configuration options accessible through the extension popup:

## Enable Debugging

By default, Angular DevTools works automatically. However, you can force-enable debugging for applications that disable it in production builds:

```typescript
// In your app's bootstrap configuration
import { enableDebugTools } from '@angular/platform-browser';

platformBrowserDynamic()
 .bootstrapModule(AppModule)
 .then(moduleRef => enableDebugTools(moduleRef));
```

For standalone component applications (Angular 14+), the equivalent is:

```typescript
import { bootstrapApplication } from '@angular/platform-browser';
import { enableDebugTools } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

bootstrapApplication(AppComponent, appConfig)
 .then(appRef => {
 const componentRef = appRef.components[0];
 enableDebugTools(componentRef);
 });
```

## Profiler Settings

Adjust profiler settings to capture more detailed information:

- Capture stack traces: Enable this to see the call stack for each change detection cycle
- Flame graph view: Toggle between timeline and flame graph visualizations
- Frame threshold: Set the minimum frame time to highlight in red

Setting a frame threshold of 16ms (roughly 60fps) is a useful starting point for performance-sensitive applications. Any cycle exceeding that threshold is worth investigating.

## Angular DevTools Across Angular Versions

Angular DevTools works with Angular 9 and above, but some features have evolved across major versions:

| Angular Version | Component Explorer | Profiler | Standalone Components |
|---|---|---|---|
| v9 – v12 | Basic | Available | Not applicable |
| v13 – v15 | Improved | Improved | Preview |
| v16 – v17 | Full | Full | Supported |
| v18+ | Full | Full | Default |

If you are on an older project (Angular 9–11), the Component Explorer may not show all directives or present change detection details as clearly as it does in v16+. In those cases, the Profiler remains the most valuable tool for diagnosing slow rendering.

## Troubleshooting Common Issues

## Extension Not Appearing

If Angular DevTools does not appear in your DevTools panel:

- Check that you are running Angular version 9 or later
- Verify the application uses Ivy (default since Angular 9)
- Disable other DevTools extensions that might conflict
- Reload the page after enabling the extension

A common cause of the tab not appearing is opening DevTools before the Angular app has finished bootstrapping. Try closing DevTools, waiting for the app to load, then reopening DevTools. The Angular tab should be present once the runtime has initialized.

## Components Not Showing Properties

Some properties may not appear in the Component Explorer if they are:

- Private properties (marked with TypeScript `private` keyword)
- Properties decorated with `@Input()` or `@Output()` that have not received values yet
- Defined in parent components (use the breadcrumb navigation to switch contexts)

To expose private properties for debugging purposes without altering production code, you can temporarily use `public` during a debugging session and revert once the issue is identified.

## Profiler Data Not Recording

Ensure you are not running the application in production mode, as some debugging features are disabled. If using Angular CLI, verify your build configuration:

```json
{
 "configurations": {
 "production": {
 "optimize": true,
 "extractLicenses": true,
 "sourceMap": false
 }
 }
}
```

For development, use the default development configuration that preserves debugging information. Running `ng serve` (without `--configuration production`) always uses the development configuration.

If you accidentally ran a production build locally for testing, re-run `ng serve` without any production flag to restore debugging support.

## Tips for Effective Use

- Pin frequently inspected components: Right-click on a component in the tree and select "Pin to top" for quick access
- Use the search function: Press Ctrl+F or Cmd+F in the Component Explorer to find components by name
- Navigate the breadcrumb: Click breadcrumb items at the top of the properties panel to switch between component contexts
- Export profiler data: Save profiler results as JSON for further analysis or to share with team members
- Use alongside network throttling: Combine Angular DevTools profiling with Chrome's CPU throttling (in the Performance panel) to simulate lower-end devices and surface change detection bottlenecks that only appear under load
- Focus on red bars first: In the Profiler timeline, red bars indicate cycles that exceeded 16ms. Start your investigation there rather than trying to optimize fast cycles

## Integrating Angular DevTools into Your Development Workflow

Angular DevTools is most effective when used proactively rather than reactively. Rather than waiting for a user to report a slowdown, incorporate profiling into your standard feature development cycle.

A practical workflow looks like this:

1. Build a new component or feature
2. Run the application with `ng serve`
3. Open the Profiler and record a typical user interaction (form submit, list scroll, modal open)
4. Review the change detection timeline for unexpected renders
5. Verify `OnPush` components are only re-rendering when their inputs change
6. Export the profiler JSON as a baseline artifact

When you repeat this process before and after performance optimizations, you get concrete data showing the improvement rather than subjective impressions.

Angular DevTools integrates smoothly with Chrome DevTools, providing Angular-specific insights alongside the browser's standard debugging tools. Once you incorporate this extension into your workflow, debugging Angular applications becomes significantly more efficient and the guesswork of tracking down performance regressions is replaced with measurable, reproducible data.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=angular-devtools-chrome-extension-setup)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome DevTools Performance Profiling: A Practical Guide](/chrome-devtools-performance-profiling/)
- [React DevTools Chrome Extension Guide: Master Component.](/react-devtools-chrome-extension-guide/)
- [AI Calendar Assistant Chrome Extension: A Developer's Guide](/ai-calendar-assistant-chrome-extension/)
- [Tailwind CSS Devtools Chrome Extension Guide (2026)](/chrome-extension-tailwind-css-devtools/)
- [Redux DevTools Chrome Tutorial: Debug State Like a Pro](/redux-devtools-chrome-tutorial/)
- [How to Use Zotero Chrome Extension Setup Guide](/zotero-chrome-extension-setup-guide/)
- [Svelte Devtools Chrome Extension Guide (2026)](/chrome-extension-svelte-devtools/)
- [How to Use Lighthouse Chrome Extension — Complete Developer](/lighthouse-chrome-extension-guide/)
- [Chrome Devtools Workspaces Local Overrides — Developer Guide](/chrome-devtools-workspaces-local-overrides/)
- [Capital One Shopping Chrome Extension Review (2026)](/capital-one-shopping-chrome-review/)
- [Have I Been Pwned Chrome Extension Guide](/have-i-been-pwned-chrome/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


