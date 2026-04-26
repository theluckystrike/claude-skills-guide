---

layout: default
title: "Claude Code + Percy Visual Testing (2026)"
description: "Automate visual regression testing with Percy and Claude Code. Capture snapshots, review diffs, and catch UI breaks before production deployment."
date: 2026-03-15
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
author: Claude Skills Guide
permalink: /claude-code-for-percy-visual-testing-workflow-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Claude Code for Percy Visual Testing Workflow Guide

Visual testing is a critical component of modern web development. While unit tests verify functionality and integration tests check system behavior, visual tests ensure your application actually *looks* correct to users. Percy, a popular visual testing platform, combined with Claude Code's intelligent automation capabilities, creates a powerful workflow for catching visual regressions before they reach production.

This guide walks you through setting up and optimizing a Claude Code-driven Percy visual testing workflow that fits smoothly into your development process.

## Understanding Percy and Visual Testing Fundamentals

Percy is a visual testing and review platform that captures screenshots of your application at various states and compares them against baseline images to detect visual changes. These changes, called visual diffs, help teams identify unintended UI modifications caused by code changes.

The typical Percy workflow involves:

1. Running your application in a browser or CI environment
2. Percy capturing snapshots of specified pages or components
3. Percy comparing new snapshots against established baselines
4. Reviewing and approving changes in the Percy dashboard

Integrating Claude Code into this workflow adds intelligent automation, you can instruct Claude to manage test execution, analyze results, and even make decisions about visual changes based on your preferences.

## Setting Up Percy with Your Project

Before integrating with Claude Code, ensure Percy is properly configured in your project. Most JavaScript projects use the `@percy/cli` and `@percy/ember` (or similar framework-specific package) packages.

```bash
npm install --save-dev @percy/cli
```

Next, configure Percy in your project's configuration file:

```yaml
percy.config.yaml
version: 2
snapshot:
 widths: [375, 768, 1280]
 minHeight: 1024
 percyCSS: ".hide-from-percy { visibility: hidden !important; }"
static:
 baseUrl: "/"
 files: "/*.html"
```

For Storybook projects, Percy provides built-in support. Add the Percy Storybook plugin:

```bash
npm install --save-dev @percy/storybook
```

Configure it in your Storybook configuration:

```javascript
// .storybook/main.js
module.exports = {
 addons: ['@percy/storybook'],
};
```

## Creating a Claude Skill for Percy Workflows

Now you'll create a Claude Skill that understands Percy's concepts and can execute visual testing workflows. This skill will encapsulate best practices for running Percy tests and interpreting results.

Create a file named `percy-visual-testing.md` in your Claude skills directory:

```markdown
---
name: Percy Visual Testing
description: Execute Percy visual testing workflows, analyze visual diffs, and manage visual regression testing for web applications
---

Percy Visual Testing Skill

This skill helps you run Percy visual tests, analyze results, and manage visual regression workflows.

Running Percy Snapshots

To capture Percy snapshots for your application:

```bash
npx percy snapshot ./build --base-url=http://localhost:3000
```

For Storybook projects:

```bash
npx percy storybook ./storybook-static
```

Analyzing Percy Results

After snapshot capture, Percy outputs a build URL. Claude can help analyze this by:

1. Extracting the build URL from the output
2. Checking for visual diffs in the response
3. Categorizing changes by severity (new, changed, removed)

Common Percy Commands

- `percy snapshot [directory]` - Capture snapshots from a directory
- `percy exec -- [command]` - Run a command with Percy enabled
- `percy token` - Manage API tokens
```

## Automating Visual Testing Workflows

One of Claude Code's strengths is its ability to automate complex sequences. Here's how to create a comprehensive visual testing workflow:

## Running Tests Across Multiple Viewports

Modern applications must work across device sizes. Configure Percy to capture snapshots at multiple widths:

```javascript
// percy-multi-viewport.js
const percyConfig = {
 snapshot: {
 widths: [375, 768, 1024, 1280, 1440],
 minHeight: 800
 },
 discovery: {
 allowedHostnames: ['localhost', 'your-app.dev'],
 networkIdleTimeout: 250
 }
};

module.exports = percyConfig;
```

## Integrating with CI Pipelines

Automate Percy tests within your continuous integration pipeline. Here's a GitHub Actions example:

```yaml
name: Visual Testing
on: [pull_request]

jobs:
 percy:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4
 - uses: actions/setup-node@v4
 with:
 node-version: '20'
 - run: npm ci
 - run: npm run build
 - run: npx percy snapshot ./build
 env:
 PERCY_TOKEN: ${{ secrets.PERCY_TOKEN }}
```

## Best Practices for Visual Testing with Claude

1. Establish Clear Baseline Policies

When starting with Percy, establish clear guidelines for baseline management. Decide whether visual changes require manual approval or can be auto-accepted for certain patterns.

```yaml
percy.config.yaml
snapshot:
 # Enable auto-approval for snapshots matching specific patterns
 percyCSS: |
 .animation-test { animation: none !important; }
 .time-sensitive { visibility: hidden !important; }
```

2. Use Percy CSS for Stability

Certain UI elements (animations, timestamps, dynamic content) cause flaky tests. Use Percy's CSS targeting to handle these:

```yaml
snapshot:
 percyCSS: |
 .animate-on-hover { animation: none !important; }
 .timestamp::before { content: "Fixed Date" !important; }
 .random-data { visibility: hidden !important; }
```

3. Organize Snapshots Logically

Group related snapshots using Percy's discovery configuration. This makes review easier:

```yaml
static:
 baseUrl: "/"
 files: "/*.html"
 ignore: ["/admin/", "/dev/"]
```

4. Use Claude for Result Analysis

After Percy completes, use Claude to analyze the JSON results and extract actionable insights:

```bash
curl -s "https://percy.io/api/v1/builds/${PERCY_BUILD_ID}" \
 -H "Authorization: Token token=${PERCY_TOKEN}" | jq '.data.attributes'
```

## Handling Visual Regression Workflows

When Percy detects visual changes, follow this decision framework:

1. Unexpected change? Investigate the corresponding code change first
2. Intended change? Review visually and approve in Percy dashboard
3. False positive? Add Percy CSS rules or adjust snapshot targeting
4. Unclear impact? Share the build URL with designers for review

## Conclusion

Integrating Claude Code with Percy creates a powerful visual testing workflow that combines intelligent automation with comprehensive visual regression detection. By following the setup guidelines, creating dedicated skills, and implementing best practices outlined in this guide, you'll catch visual regressions early and maintain consistent UI quality across your applications.

The key is treating visual testing as an integral part of your development process, not an afterthought. With Percy capturing changes and Claude automating execution and analysis, your team can confidently iterate on UI improvements while maintaining visual consistency.

Start with a small set of critical pages, establish baseline acceptance criteria, and gradually expand your visual test coverage. The investment pays dividends in reduced visual bugs and improved user experience.


---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-percy-visual-testing-workflow-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code API Regression Testing Workflow Guide](/claude-code-api-regression-testing-workflow/)
- [Claude Code Continuous Testing Workflow: Complete Guide for 2026](/claude-code-continuous-testing-workflow/)
- [Claude Code for Distributed Load Testing Workflow](/claude-code-for-distributed-load-testing-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


