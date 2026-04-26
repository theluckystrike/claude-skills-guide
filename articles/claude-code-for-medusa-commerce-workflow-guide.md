---
layout: default
title: "Claude Code for Medusa Commerce — Guide (2026)"
description: "Claude Code for Medusa Commerce — Guide — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-medusa-commerce-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, medusa, workflow]
---

## The Setup

You are building an e-commerce backend with Medusa, an open-source headless commerce platform built with Node.js. Medusa provides a modular architecture with products, orders, carts, payments, and shipping out of the box, plus an extensible plugin system. Claude Code can build e-commerce features, but it generates Shopify Liquid templates or WooCommerce PHP instead of Medusa's TypeScript API approach.

## What Claude Code Gets Wrong By Default

1. **Creates Shopify Liquid templates.** Claude writes `.liquid` template files with Shopify's template syntax. Medusa is headless — there are no server-rendered templates. You build a separate frontend (Next.js, Gatsby) that calls Medusa's REST or GraphQL API.

2. **Uses WooCommerce hooks and filters.** Claude writes PHP action hooks for checkout customization. Medusa uses TypeScript subscribers and middleware — `@Subscriber()` decorators for event handling and custom API routes for extensions.

3. **Ignores Medusa's module system.** Claude builds features as standalone Express routes. Medusa v2 uses a modular architecture where features are organized into modules with services, repositories, and migrations — custom logic extends existing modules.

4. **Hardcodes payment processing.** Claude writes Stripe integration from scratch. Medusa has official payment plugins (`medusa-payment-stripe`, `medusa-payment-paypal`) that handle the payment flow — install and configure, do not rewrite.

## The CLAUDE.md Configuration

```
# Medusa Commerce Project

## Commerce
- Platform: Medusa (open-source headless commerce)
- Backend: Node.js/TypeScript API
- Frontend: Separate (Next.js storefront)
- Database: PostgreSQL with TypeORM/MikroORM

## Medusa Rules
- API: REST endpoints at /store/* and /admin/*
- Modules: services, repositories, subscribers
- Plugins: medusa-payment-stripe, medusa-fulfillment-*
- Events: @Subscriber() for order, cart, payment events
- Custom API: extend with custom routes in src/api/
- Admin: Medusa Admin dashboard (React)
- Storefront: Next.js starter or custom frontend

## Conventions
- Backend: src/services/ for business logic
- API routes: src/api/routes/ for custom endpoints
- Subscribers: src/subscribers/ for event handlers
- Migrations: medusa migrations run for schema changes
- Plugins in medusa-config.js plugins array
- Use Medusa's built-in cart/order/payment flow
- Seed data: medusa seed -f data/seed.json
```

## Workflow Example

You want to add a custom loyalty points system to your Medusa store. Prompt Claude Code:

"Create a Medusa module for loyalty points. Add a service that awards points on order completion, a custom API endpoint to check a customer's points balance, and a subscriber that listens to the order.placed event. Store points in a custom database table."

Claude Code should create a `LoyaltyService` extending `TransactionBaseService`, a migration for the `loyalty_points` table, a subscriber listening to `order.placed` that calls the service, and a custom API route at `/store/loyalty/balance/:customerId` that returns the points balance.

## Common Pitfalls

1. **Modifying core Medusa files directly.** Claude edits files in `node_modules/medusa` or core source files. Medusa is extended through services, subscribers, and plugins — never modify core files as they are overwritten on updates.

2. **Missing middleware for custom routes.** Claude creates API routes without authentication middleware. Medusa's store routes use session-based auth and admin routes use JWT — custom routes need the appropriate middleware applied.

3. **Database migrations not running.** Claude creates a new entity but forgets the migration. Medusa uses TypeORM migrations — run `medusa migrations run` after adding new entities or modifying existing ones.

## Related Guides

- [Building a REST API with Claude Code Tutorial](/building-a-rest-api-with-claude-code-tutorial/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
- [Claude Code Database Schema Design Guide](/claude-code-database-schema-design-guide/)


## Common Questions

### How do I get started with claude code for medusa commerce -?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code Academic Workflow Guide](/claude-code-academic-workflow-guide-2026/)
- [Claude Code API Client TypeScript Guide](/claude-code-api-client-typescript-guide/)
- [Claude Code API Contract Testing Guide](/claude-code-api-contract-testing-guide/)
