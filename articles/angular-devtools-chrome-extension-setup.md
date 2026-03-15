---

layout: default
title: "Angular DevTools Chrome Extension Setup: A Complete Guide"
description: "Learn how to install and configure Angular DevTools for Chrome to debug, inspect, and optimize your Angular applications effectively."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /angular-devtools-chrome-extension-setup/
reviewed: true
score: 8
categories: [guides]
tags: [chrome, claude-skills]
---


{% raw %}

Angular DevTools is an official Chrome extension provided by the Angular team that provides powerful debugging and profiling capabilities for Angular applications. Whether you are maintaining a legacy Angular project or building a modern application with the latest Angular version, this extension significantly improves your development workflow.

## Installing Angular DevTools

The installation process is straightforward. Open Chrome and navigate to the [Angular DevTools Chrome Web Store page](https://chrome.google.com/webstore/detail/angular-devtools/ienfalfjdbdpebioblbfnkbdplhggbhce). Click the "Add to Chrome" button and confirm the installation.

After installation, you will see the Angular logo in your Chrome toolbar. The extension remains disabled until you open an Angular application running Angular version 9 or later.

## Verifying Your Installation

Once installed, verify that Angular DevTools is working correctly:

1. Open your Angular application in Chrome
2. Right-click anywhere on the page and select "Inspect" to open DevTools
3. Look for the "Angular" tab in the DevTools panel

If the Angular tab does not appear, ensure your application meets the following requirements:

- Angular version 9 or higher
- The application is running in development mode with Ivy renderer
- No conflicting extensions that might interfere with DevTools

## Understanding the Angular DevTools Interface

The Angular DevTools interface consists of two main tabs: the **Component Explorer** and the **Profiler**.

### Component Explorer Tab

The Component Explorer provides a tree view of your application's component hierarchy. You can expand nodes to see child components, directives, and pipes. Each node displays:

- Component or directive name
- Current property values
- Change detection status

You can interact directly with components from this view. Click on any component to inspect its properties in the right panel. Modified values reflect immediately in your application, which is useful for testing different states without reloading the page.

### Profiler Tab

The Profiler tab records and displays change detection cycles. This helps you identify performance bottlenecks by showing:

- Time spent in each change detection cycle
- Components that triggered changes
- Overall application performance metrics

To use the profiler, click the "Record" button and interact with your application. Stop recording to analyze the results.

## Practical Examples

### Inspecting Component State

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

With Angular DevTools, you can select the `app-counter` component in the Component Explorer and view the current `count` value in real-time. You can also modify the count value directly in the properties panel to test edge cases.

### Debugging Change Detection Issues

When your application experiences performance problems, the Profiler helps identify the cause:

1. Click the "Profiler" tab
2. Click "Record" to start capturing
3. Perform actions in your application
4. Click "Stop" to end the recording

The profiler displays a timeline showing each change detection cycle. Bars highlighted in red indicate cycles that took longer than expected. Click on any bar to see which components triggered the change detection.

For applications using `OnPush` change detection strategy, this is particularly valuable. You can verify that change detection only runs when expected, rather than on every event.

## Configuration Options

Angular DevTools offers several configuration options accessible through the extension popup:

### Enable Debugging

By default, Angular DevTools works automatically. However, you can force-enable debugging for applications that disable it in production builds:

```typescript
// In your app's bootstrap configuration
import { enableDebugTools } from '@angular/platform-browser';

platformBrowserDynamic()
  .bootstrapModule(AppModule)
  .then(moduleRef => enableDebugTools(moduleRef));
```

### Profiler Settings

Adjust profiler settings to capture more detailed information:

- **Capture stack traces**: Enable this to see the call stack for each change detection cycle
- **Flame graph view**: Toggle between timeline and flame graph visualizations
- **Frame threshold**: Set the minimum frame time to highlight in red

## Troubleshooting Common Issues

### Extension Not Appearing

If Angular DevTools does not appear in your DevTools panel:

- Check that you are running Angular version 9 or later
- Verify the application uses Ivy (default since Angular 9)
- Disable other DevTools extensions that might conflict
- Reload the page after enabling the extension

### Components Not Showing Properties

Some properties may not appear in the Component Explorer if they are:

- Private properties
- Tagged with `@Input()` or `@Output()` decorators
- Defined in parent components (use the breadcrumb navigation to switch contexts)

### Profiler Data Not Recording

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

For development, use the default development configuration that preserves debugging information.

## Tips for Effective Use

- **Pin frequently inspected components**: Right-click on a component in the tree and select "Pin to top" for quick access
- **Use the search function**: Press Ctrl+F or Cmd+F in the Component Explorer to find components by name
- **Navigate the breadcrumb**: Click breadcrumb items at the top of the properties panel to switch between component contexts
- **Export profiler data**: Save profiler results as JSON for further analysis or to share with team members

Angular DevTools integrates smoothly with Chrome DevTools, providing Angular-specific insights alongside the browser's standard debugging tools. Once you incorporate this extension into your workflow, debugging Angular applications becomes significantly more efficient.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)

{% endraw %}
