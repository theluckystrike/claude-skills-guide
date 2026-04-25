---
layout: default
title: "Claude Code for Effect-TS (2026)"
description: "Claude Code for Effect-TS — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-effect-ts-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, effect-ts, workflow]
---

## The Setup

You are building a TypeScript application using Effect-TS, a library for typed functional effects that handles errors, dependencies, and async operations in a composable way. Claude Code can write Effect programs and services, but it defaults to try/catch patterns and misunderstands Effect's pipe-based composition and dependency injection system.

## What Claude Code Gets Wrong By Default

1. **Uses try/catch for error handling.** Claude wraps operations in try/catch blocks. Effect-TS uses typed errors in the `Effect<Success, Error, Requirements>` type signature and handles them with `Effect.catchTag()` or `Effect.catchAll()`.

2. **Creates classes with constructor injection.** Claude writes DI using constructor parameters or InversifyJS. Effect-TS uses `Context.Tag` and `Layer` for dependency injection — services are defined as tags and provided through layer composition.

3. **Writes Promise-based async code.** Claude uses `async/await` with Promises. Effect-TS wraps async operations in `Effect.tryPromise()` and chains them with `pipe()` and `Effect.flatMap()`.

4. **Ignores the generator syntax.** Claude writes deeply nested `pipe()` chains. Effect-TS supports `Effect.gen(function* () { ... })` syntax that looks like async/await but preserves full type safety for errors and requirements.

## The CLAUDE.md Configuration

```
# Effect-TS Project

## Architecture
- Core: Effect-TS (effect package)
- Pattern: Typed effects with Service/Layer architecture
- Error handling: Typed errors, no try/catch
- DI: Context.Tag + Layer composition

## Effect-TS Rules
- Use Effect.gen(function* () { }) for readable effect chains
- Errors are typed: Effect<A, E, R> where E is the error channel
- Services defined with Context.Tag: class MyService extends Context.Tag("MyService")
- Dependencies provided via Layer: Layer.succeed, Layer.effect
- Use Effect.tryPromise for wrapping async operations
- Schema validation with @effect/schema, not Zod
- Never throw errors — use Effect.fail() or Effect.die()
- Run effects with Effect.runPromise() at the edge (entry points only)

## Conventions
- Services in src/services/ directory
- Layers composed in src/layers/ or src/main.ts
- Errors defined as tagged unions: class NotFound extends Data.TaggedError("NotFound")
- Use pipe() for composition: pipe(effect, Effect.map(...), Effect.flatMap(...))
- Prefer Effect.gen over deep pipe chains for readability
- Runtime created once in src/runtime.ts
```

## Workflow Example

You want to create a user service with typed errors. Prompt Claude Code:

"Create an Effect-TS user service with getById and create methods. The getById should fail with a typed NotFoundError. The create method should validate input with @effect/schema and fail with a ValidationError. Provide the service as a Layer."

Claude Code should define `NotFoundError` and `ValidationError` as `Data.TaggedError` classes, create a `UserService` tag with `Context.Tag`, implement it using `Effect.gen`, define the layer with `Layer.succeed(UserService, implementation)`, and wire error handling using `Effect.catchTag("NotFound", ...)`.

## Common Pitfalls

1. **Mixing Effect and Promise in the same function.** Claude awaits an Effect inside an async function. Effects must be run with `Effect.runPromise()` only at the program boundary. Inside Effect code, use `Effect.flatMap` to chain, never `await`.

2. **Forgetting to provide required layers.** Claude creates effects that require services but runs them without providing layers. The TypeScript compiler catches this as the `R` (requirements) channel is not `never`, but Claude ignores the type error and uses `as any`.

3. **Using `Effect.sync` for async operations.** Claude wraps fetch calls in `Effect.sync(() => fetch(...))`. Sync effects cannot contain async code — use `Effect.tryPromise()` for anything that returns a Promise, or `Effect.async` for callback-based APIs.

## Related Guides

- [Best Way to Use Claude Code with TypeScript Projects](/best-way-to-use-claude-code-with-typescript-projects/)
- [Claude Code API Contract Testing Guide](/claude-code-api-contract-testing-guide/)
- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)

## Related Articles

- [Claude Code for WebDriverIO Automation Workflow](/claude-code-for-webdriverio-automation-workflow/)
- [Claude Code for Runbook Review Process Workflow](/claude-code-for-runbook-review-process-workflow/)
- [Claude Code for Cloud Run Jobs Workflow](/claude-code-for-cloud-run-jobs-workflow/)
- [Claude Code Sre Reliability — Complete Developer Guide](/claude-code-sre-reliability-engineering-workflow-guide/)
- [Claude Code for TorchScript Workflow Guide](/claude-code-for-torchscript-workflow-guide/)
- [Claude Code for Viem Ethereum Workflow Guide](/claude-code-for-viem-ethereum-workflow-guide/)
- [Claude Code for Great Expectations Data Workflow](/claude-code-for-great-expectations-data-workflow/)
- [Claude Code for OpenLineage Workflow Tutorial Guide](/claude-code-for-openlineage-workflow-tutorial-guide/)


## Common Questions

### How do I get started with claude code for effect-ts?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code Announcements 2026](/anthropic-claude-code-announcements-2026/)
- [Fix Stream Idle Timeout in Claude Code](/anthropic-sdk-streaming-hang-timeout/)
- [How to Audit Your Claude Code Token](/audit-claude-code-token-usage-step-by-step/)
