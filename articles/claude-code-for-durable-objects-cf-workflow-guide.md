---
sitemap: false
layout: default
title: "Claude Code for Durable Objects (2026)"
description: "Claude Code for Durable Objects — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-durable-objects-cf-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, cloudflare, workflow]
---

## The Setup

You are building stateful applications on Cloudflare's edge using Durable Objects — singleton instances that maintain state and handle coordination across requests. Unlike stateless Workers, Durable Objects have persistent storage and WebSocket support. Claude Code can scaffold Durable Object classes and Worker bindings, but it treats them like regular serverless functions and misses the singleton coordination model.

## What Claude Code Gets Wrong By Default

1. **Writes stateless request handlers.** Claude creates Workers that read/write to KV for state. Durable Objects maintain in-memory state between requests and have their own transactional storage — KV is the wrong pattern.

2. **Creates multiple instances for the same entity.** Claude spawns new Durable Object instances per request. Each Durable Object has a unique ID and only one instance exists per ID globally. You route requests to existing instances using `env.MY_DO.get(id)`.

3. **Uses external databases for coordination.** Claude adds Redis or PostgreSQL for real-time coordination. Durable Objects are designed for exactly this — they serialize requests to a single instance, eliminating race conditions without external locking.

4. **Ignores the `wrangler.toml` binding configuration.** Claude creates Durable Object classes but never adds the binding in `wrangler.toml`, causing "binding not found" errors at runtime.

## The CLAUDE.md Configuration

```
# Cloudflare Durable Objects Project

## Architecture
- Runtime: Cloudflare Workers + Durable Objects
- State: Durable Object transactional storage (NOT KV)
- Config: wrangler.toml with durable_objects bindings
- WebSockets: Durable Objects handle WS connections natively

## Durable Object Rules
- DO classes extend DurableObject base class
- One instance per unique ID — requests serialized to that instance
- Access via stub: env.MY_DO.get(env.MY_DO.idFromName("room-1"))
- Storage: this.ctx.storage.get/put/delete (transactional, not KV)
- WebSockets: this.ctx.getWebSockets() for connected clients
- Alarms: this.ctx.storage.setAlarm() for scheduled wake-ups
- Binding in wrangler.toml: [[durable_objects.bindings]]

## Conventions
- One DO class per domain concern (ChatRoom, Counter, RateLimiter)
- Worker acts as router, forwards requests to correct DO instance
- ID strategy: idFromName for named entities, newUniqueId for ephemeral
- Keep DO state minimal — offload large data to R2 or D1
- Use blockConcurrencyWhile() in constructor for initialization
- Never use setTimeout — use Durable Object Alarms instead
```

## Workflow Example

You want to build a collaborative counter that multiple users can increment simultaneously. Prompt Claude Code:

"Create a Durable Object that acts as a shared counter. Multiple Worker requests should increment the same counter without race conditions. Add a WebSocket endpoint so connected clients see the count update in real-time."

Claude Code should create a DO class with `this.count` state initialized from storage, an increment method that updates both memory and `this.ctx.storage.put()`, broadcasts the new count to all WebSocket connections via `this.ctx.getWebSockets()`, and configures the Worker to route increment requests to the correct DO stub.

## Common Pitfalls

1. **Forgetting `blockConcurrencyWhile` for initialization.** Claude reads from storage in the `fetch()` handler on every request. Use `blockConcurrencyWhile()` in the constructor to load state once — subsequent requests see the in-memory value without storage reads.

2. **Using `setTimeout` for delayed work.** Claude schedules future work with `setTimeout`. Durable Objects can be evicted between requests, killing timers. Use `this.ctx.storage.setAlarm(Date.now() + delay)` which persists across evictions.

3. **Exceeding the 128KB storage value limit.** Claude stores large JSON blobs in a single storage key. Each Durable Object storage value is limited to 128KB. Split large data across multiple keys or store it in R2 with only a reference in DO storage.

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code AWS Lambda Deployment Guide](/claude-code-aws-lambda-deployment-guide/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
- [Claude Code for AI Agent Tool Calling](/claude-code-for-ai-agent-tool-calling-implementation/)

## Related Articles

- [Claude Code for Rust Trait Objects Workflow Guide](/claude-code-for-rust-trait-objects-workflow-guide/)
- [Claude Code Inngest Durable Workflow for Long Running Tasks](/claude-code-inngest-durable-workflow-long-running-tasks/)


## Common Questions

### How do I get started with claude code for durable objects?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code for Rust Trait Objects](/claude-code-for-rust-trait-objects-workflow-guide/)
- [Claude Code Inngest Durable Workflow](/claude-code-inngest-durable-workflow-long-running-tasks/)
- [Claude Code Announcements 2026](/anthropic-claude-code-announcements-2026/)
