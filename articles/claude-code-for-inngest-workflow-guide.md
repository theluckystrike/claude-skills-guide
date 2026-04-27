---
sitemap: false
layout: default
title: "Claude Code for Inngest (2026)"
description: "Claude Code for Inngest — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-inngest-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, inngest, workflow]
---

## The Setup

You are building durable, event-driven workflows using Inngest — a platform that handles retries, scheduling, step functions, and flow control for serverless applications. Inngest lets you write complex multi-step workflows as code that survives function restarts. Claude Code can write Inngest functions, but it creates plain serverless functions without Inngest's durability and step abstractions.

## What Claude Code Gets Wrong By Default

1. **Writes stateless serverless functions.** Claude creates one-shot API handlers that fail silently if any step errors. Inngest functions use `step.run()` to break work into durable steps that retry independently.

2. **Implements manual retry logic.** Claude adds try/catch with exponential backoff loops. Inngest handles retries automatically — each `step.run()` retries on failure with configurable backoff, and completed steps are not re-executed.

3. **Uses cron jobs with external schedulers.** Claude sets up AWS EventBridge or GitHub Actions cron. Inngest has built-in cron triggers: `createFunction({ event: 'cron/daily-report', schedule: '0 9 * * *' })`.

4. **Manages event queues manually.** Claude sets up BullMQ or SQS for event processing. Inngest is the queue — you send events with `inngest.send()` and functions trigger automatically based on event names.

## The CLAUDE.md Configuration

```
# Inngest Durable Workflows

## Architecture
- Workflows: Inngest (durable step functions)
- SDK: inngest (TypeScript SDK)
- Serve: /api/inngest route serves all functions
- Dev: npx inngest-cli dev for local testing

## Inngest Rules
- Functions defined with createFunction({ id, event }, async ({ step }) => {})
- Break work into steps: step.run('step-name', async () => { })
- Steps are durable — completed steps are NOT re-executed on retry
- Send events: inngest.send({ name: 'app/user.signup', data: { } })
- Cron: createFunction({ cron: '0 9 * * *' }, handler)
- Concurrency: createFunction({ concurrency: { limit: 5 } })
- Sleep: step.sleep('wait-1h', '1h') for delayed execution
- Wait for event: step.waitForEvent('approval', { timeout: '24h' })

## Conventions
- Functions in inngest/functions/ directory
- Inngest client in inngest/client.ts
- All functions served via single /api/inngest route
- Event names: 'app/resource.action' pattern
- Dev server: npx inngest-cli dev (visual debugging UI)
- Function IDs: kebab-case, unique across the app
- Never use setTimeout — use step.sleep() instead
```

## Workflow Example

You want to create an onboarding workflow triggered by user signup. Prompt Claude Code:

"Create an Inngest function that runs when a user signs up. Step 1: send a welcome email. Step 2: wait 24 hours. Step 3: send a getting-started guide. Step 4: check if the user has created a project. If not, step 5: send a nudge email after 48 more hours."

Claude Code should create a function with `createFunction({ id: 'onboarding-flow', event: 'app/user.signup' })` using `step.run()` for email sends, `step.sleep()` for delays, and `step.run()` to check user activity, with conditional logic for the nudge email.

## Common Pitfalls

1. **Non-deterministic step names.** Claude generates step names with timestamps or random values. Inngest uses step names to track completion — if the name changes between retries, Inngest cannot identify which steps completed. Step names must be static strings.

2. **Side effects outside step.run().** Claude puts API calls and database writes outside `step.run()` blocks. Code outside steps re-executes on every retry attempt. All side effects must be inside `step.run()` to be durable and idempotent.

3. **Missing the serve endpoint.** Claude creates Inngest functions but does not set up the `/api/inngest` route. Inngest discovers and invokes functions through this single endpoint. Without it, functions are defined but never execute.

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code for AI Agent Tool Calling](/claude-code-for-ai-agent-tool-calling-implementation/)
- [Best Way to Use Claude Code with Existing CI/CD](/best-way-to-use-claude-code-with-existing-ci-cd/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)

## Related Articles

- [Claude Code Inngest Durable Workflow for Long Running Tasks](/claude-code-inngest-durable-workflow-long-running-tasks/)


## Common Questions

### How do I get started with claude code for inngest?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code Inngest Durable Workflow](/claude-code-inngest-durable-workflow-long-running-tasks/)
- [Claude Code for Inngest Event Functions](/claude-code-inngest-event-driven-function-workflow-tutorial/)
- [Claude Code + Inngest Fan-Out Workflows](/claude-code-inngest-fan-out-parallel-tasks-workflow/)
