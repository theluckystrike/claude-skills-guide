---

layout: default
title: "Claude Code for Lighthouse CI Workflow Tutorial"
description: "Learn how to integrate Claude Code with Lighthouse CI to automate performance testing in your development workflow. Step-by-step guide with practical examples."
date: 2026-03-15
author: Claude Skills Guide
permalink: /claude-code-for-lighthouse-ci-workflow-tutorial/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
---


{% raw %}
# Claude Code for Lighthouse CI Workflow Tutorial

Performance is critical for user experience and SEO, yet it's often overlooked until problems become visible in production. Integrating Lighthouse CI into your development workflow with Claude Code creates an automated safety net that catches performance regressions before they reach production. This tutorial shows you how to set up this powerful combination.

## What is Lighthouse CI?

Lighthouse CI is a collection of commands that run Lighthouse audits as part of your continuous integration pipeline. It collects performance metrics, compares them against budgets and thresholds, and can fail builds when metrics drop below acceptable levels. By combining it with Claude Code, you get an AI-powered assistant that can analyze Lighthouse results, explain what went wrong, and even suggest fixes.

## Setting Up Lighthouse CI in Your Project

First, install the Lighthouse CI CLI as a development dependency:

```bash
npm install --save-dev @lhci/cli
```

Create a `lighthouserc.js` configuration file in your project root:

```javascript
module.exports = {
  ci: {
    collect: {
      staticFileDistDir: './dist',
      numberOfRuns: 3,
      url: ['http://localhost:3000'],
    },
    upload: {
      target: 'temporary-public-storage',
      serverBaseUrl: process.env.LHCI_SERVER_URL,
      token: process.env.LHCI_TOKEN,
    },
    assert: {
      assertions: {
        'categories:performance': ['error', { minScore: 0.9 }],
        'categories:accessibility': ['error', { minScore: 0.9 }],
        'first-contentful-paint': ['warn', { maxNumericValue: 2000 }],
        'largest-contentful-paint': ['error', { maxNumericValue: 4000 }],
        'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
      },
    },
  },
};
```

This configuration runs Lighthouse three times against your local server, with assertions that fail the build if performance or accessibility scores drop below 90.

## Integrating with Claude Code

Now let's create a Claude Skill that helps you work with Lighthouse CI results. Create a file called `lighthouse-ci-skill.md`:

```markdown
---
name: lighthouse-ci
description: Analyze Lighthouse CI results and suggest performance improvements
tools: [bash, read_file]
version: 1.0.0
---

# Lighthouse CI Analysis Skill

You are a performance optimization expert. When provided with Lighthouse CI results, analyze them thoroughly and provide actionable recommendations.

## Analyzing Results

When you receive Lighthouse output:
1. Identify the lowest-scoring categories and specific audits
2. Look for patterns in failing audits (e.g., image optimization, JavaScript blocking)
3. Note any regressions from previous runs

## Providing Recommendations

For each failing audit, explain:
- What the metric means for user experience
- Why it might be failing
- Specific code changes or configuration adjustments to fix it
```

This skill gives Claude context for interpreting Lighthouse results and providing relevant advice.

## Automating Your CI Pipeline

Add Lighthouse CI to your GitHub Actions workflow or other CI system:

```yaml
name: Performance Audit

on: [push, pull_request]

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Build application
        run: npm run build
        
      - name: Start server
        run: npm start &
        
      - name: Wait for server
        run: sleep 10
        
      - name: Run Lighthouse CI
        run: npx lhci autorun
        env:
          LHCI_TOKEN: ${{ secrets.LHCI_TOKEN }}
```

This workflow builds your application, starts a local server, and runs Lighthouse audits on every push and pull request.

## Working with Claude on Performance Issues

When Lighthouse CI reports failures, ask Claude for help:

```
Claude, the Lighthouse CI build failed with a 0.7 performance score. 
The first-contentful-paint is 3.2s and largest-contentful-paint is 4.8s. 
Can you analyze this and suggest fixes?
```

Claude will use the lighthouse-ci skill to explain what's causing the delays and recommend specific optimizations:

1. **Optimize images**: Use modern formats like WebP, add explicit dimensions
2. **Reduce JavaScript blocking**: Defer non-critical scripts, code-split bundles
3. **Improve server response**: Enable compression, optimize database queries
4. **Leverage browser caching**: Set appropriate cache headers

## Setting Up Budget Alerts

Prevent performance drift by setting budget thresholds in your configuration:

```javascript
module.exports = {
  ci: {
    assert: {
      assertions: {
        // Budget-based assertions
        'resource-summary:javascript:size': ['error', { maxNumericValue: 170000 }],
        'resource-summary:css:size': ['error', { maxNumericValue: 10000 }],
        'resource-summary:image:size': ['error', { maxNumericValue: 500000 }],
        
        // Third-party impact
        'third-party-summary': ['warn', { maxNumericWeight: 0.3 }],
      },
    },
  },
};
```

These budgets catch issues before they become severe. When a JavaScript bundle exceeds 170KB or third-party scripts load too slowly, your build fails.

## Advanced: Historical Comparison

Lighthouse CI can compare results against previous runs to detect regressions:

```javascript
module.exports = {
  ci: {
    assert: {
      assertions: {
        // Compare against previous baseline
        'performance': ['error', { aggregationMethod: 'median', minScore: 0.85 }],
      },
    },
  },
};
```

Use this with Claude to understand why metrics changed. Ask Claude to review the git diff between builds and identify what code changes caused the regression.

## Best Practices

1. **Run locally first**: Use `lhci autorun` in development before pushing
2. **Warm up your server**: Add startup delays to ensure consistent measurements
3. **Test in production-like environments**: Staging should mirror production
4. **Review results in PRs**: Lighthouse comments in pull requests provide visibility

## Conclusion

Integrating Claude Code with Lighthouse CI transforms performance monitoring from a manual chore into an automated, intelligent process. Claude can explain complex metrics, identify root causes, and guide you toward solutions—all within your existing development workflow. Start with the basics in this tutorial, then gradually add more sophisticated assertions as your team becomes comfortable with the workflow.
{% endraw %}
