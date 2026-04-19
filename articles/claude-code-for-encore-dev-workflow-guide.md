---
layout: default
title: "Claude Code for Encore Dev — Workflow Guide"
description: "Build type-safe backends with Encore.dev and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-encore-dev-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, encore, workflow]
---

## The Setup

You are building a backend with Encore, the development platform that uses static analysis to understand your application architecture and automatically provisions infrastructure (databases, queues, cron jobs) from your code. Claude Code can write Encore services, but it creates traditional Express/Fastify APIs with manual infrastructure provisioning.

## What Claude Code Gets Wrong By Default

1. **Creates Express route handlers.** Claude writes `app.get('/users', handler)`. Encore defines APIs with decorated TypeScript functions: `export const getUser = api({ method: 'GET', path: '/users/:id' }, handler)`.

2. **Provisions databases manually.** Claude writes Docker Compose files for PostgreSQL. Encore provisions databases automatically from your code: `const db = new SQLDatabase('mydb', { migrations: './migrations' })`. No Terraform, no Docker.

3. **Adds message queue infrastructure.** Claude sets up Redis or RabbitMQ for pub/sub. Encore has built-in pub/sub: `new Topic('user-events')` and `new Subscription(topic, handler)` — infrastructure provisioned automatically.

4. **Writes separate cron job services.** Claude creates cron job scripts with node-cron. Encore has built-in cron: `const job = new CronJob('daily-cleanup', { schedule: '0 9 * * *', endpoint: dailyCleanup })`.

## The CLAUDE.md Configuration

```
# Encore Backend Project

## Framework
- Backend: Encore.dev (TypeScript, infrastructure-from-code)
- APIs: Decorated functions with api() wrapper
- Database: SQLDatabase (auto-provisioned PostgreSQL)
- Pub/Sub: Topic + Subscription (auto-provisioned)
- Cron: CronJob (built-in, no external scheduler)

## Encore Rules
- APIs: export const myApi = api({ method, path, auth }, handler)
- Services: one directory per service in root
- Database: const db = new SQLDatabase('name', { migrations })
- Pub/Sub: const topic = new Topic<EventType>('name')
- Auth: define authHandler with api.authHandler()
- Config: encore.app (root config), service dirs auto-discovered
- Testing: encore test (built-in test runner with service mocking)
- Local dev: encore run (full local environment with real DBs)

## Conventions
- Service per domain: users/, projects/, billing/
- Each service is a directory with encore.service.ts
- Migrations in service/migrations/ directory
- Auth handler in auth/ service
- Use Encore's generated client for service-to-service calls
- Never provision infrastructure manually — Encore handles it
- encore.app at root configures the application
```

## Workflow Example

You want to create a notification service with event-driven architecture. Prompt Claude Code:

"Create an Encore notification service that subscribes to user signup events, stores notification preferences in a database, and sends welcome emails. Add a cron job that sends weekly digest notifications."

Claude Code should create a `notifications/` service directory, subscribe to the `user-signup` topic, create a `SQLDatabase` for notification preferences with a migration, define an API endpoint for preferences, and add a `CronJob` for the weekly digest.

## Common Pitfalls

1. **Importing between services incorrectly.** Claude imports internal functions from other services. Encore services communicate through their public APIs only — use the generated client: `import { users } from '~encore/clients'` for service-to-service calls.

2. **Missing encore.service.ts.** Claude creates a directory with code but no `encore.service.ts` file. Encore discovers services by this file — without it, the directory is not recognized as a service and APIs are not registered.

3. **Local development port assumptions.** Claude configures the frontend to call `localhost:3000`. Encore's local dev server assigns ports dynamically. Use `encore run` which shows the assigned port, or use Encore's generated client which handles the URL automatically.

## Related Guides

- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)
- [Best Claude Skills for DevOps and Deployment](/best-claude-skills-for-devops-and-deployment/)

## Related Articles

- [Claude Code For Go To Definition — Complete Developer Guide](/claude-code-for-go-to-definition-workflow-tutorial/)
- [Claude Code for Tabnine AI Autocomplete Workflow](/claude-code-for-tabnine-ai-autocomplete-workflow/)
- [Claude Code for Few-Shot Prompting Best Practices Workflow](/claude-code-for-few-shot-prompting-best-practices-workflow/)
- [Claude Code For Oss License — Complete Developer Guide](/claude-code-for-oss-license-selection-workflow-guide/)
- [Claude Code For Mob Programming — Complete Developer Guide](/claude-code-for-mob-programming-workflow-tutorial/)
- [Claude Code For Zig Programming — Complete Developer Guide](/claude-code-for-zig-programming-language-workflow/)
- [Claude Code for BentoML Workflow Tutorial](/claude-code-for-bentoml-workflow-tutorial/)
- [Claude Code For Ant Design — Complete Developer Guide](/claude-code-for-ant-design-workflow-guide/)
