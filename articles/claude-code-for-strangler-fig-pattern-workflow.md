---
layout: default
title: "Claude Code for Strangler Fig Pattern Workflow"
description: "Learn how to use Claude Code to implement the strangler fig pattern for seamless legacy system migration. Practical workflows, code examples, and actionable strategies."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /claude-code-for-strangler-fig-pattern-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
---

{% raw %}
# Claude Code for Strangler Fig Pattern Workflow

The strangler fig pattern represents one of the most elegant approaches to modernizing legacy systems without the风险 of massive "big bang" rewrites. Named after the strangler fig tree that slowly envelops and replaces its host, this pattern allows you to incrementally migrate functionality from a legacy system to a modern architecture while keeping everything running smoothly. Claude Code becomes an invaluable partner in executing this migration strategy, providing intelligent assistance from initial analysis through final decommissioning.

## Understanding the Strangler Fig Pattern

Before diving into implementation, you need to grasp the core principles that make this pattern so effective. The strangler fig pattern operates on three fundamental phases that run concurrently rather than sequentially.

**Phase One: Facade Deployment** involves placing a new interface in front of your existing legacy system. This facade acts as a proxy, routing requests to either the old system or new services based on which functionality has been migrated. Users and external systems continue interacting with a single endpoint without noticing any changes.

**Phase Two: Incremental Migration** is where the real work happens. You systematically identify features in the legacy system, build new implementations, and redirect traffic one feature at a time. Each migration is small, testable, and reversible if problems arise.

**Phase Three: Decommissioning** occurs when all functionality has been migrated. The facade is either removed entirely or simplified to point to the new system, and the legacy code can be archived or deleted.

Claude Code excels at each phase by helping you analyze the existing codebase, generate migration code, maintain test coverage, and verify behavior parity throughout the process.

## Analyzing Your Legacy System

Every successful strangler fig migration begins with thorough understanding of what you're migrating. Claude Code can accelerate this discovery phase significantly.

```bash
claude "Analyze this legacy codebase and create a comprehensive inventory:
1. List all API endpoints with their request/response schemas
2. Identify all database tables and their relationships
3. Document external service integrations and dependencies
4. Identify shared utilities, middleware, and authentication logic
5. Flag any areas with high complexity or technical debt

Output this as a structured markdown document that I can use for migration planning."
```

This analysis reveals your migration candidates. Look for standalone features with clear boundaries—these become your first targets. Complex, tightly coupled functionality should wait until you've established a rhythm with simpler migrations.

## Setting Up the Migration Facade

The facade serves as the traffic router between your legacy and new systems. Claude Code can help you generate an appropriate facade based on your tech stack.

```typescript
// Example: API Gateway facade for strangler fig pattern
interface RouteConfig {
  path: string;
  method: string;
  target: 'legacy' | 'modern';
  feature: string;
}

const routes: RouteConfig[] = [
  { path: '/api/users', method: 'GET', target: 'modern', feature: 'user-list' },
  { path: '/api/users', method: 'POST', target: 'legacy', feature: 'user-create' },
  { path: '/api/orders', method: 'GET', target: 'legacy', feature: 'order-list' },
];

app.all('/api/*', async (req, res) => {
  const route = routes.find(r => 
    r.path === req.path && r.method === req.method
  );
  
  if (!route) {
    return res.status(404).json({ error: 'Route not found' });
  }
  
  const targetBase = route.target === 'legacy' 
    ? process.env.LEGACY_API_URL 
    : process.env.MODERN_API_URL;
    
  const response = await fetch(`${targetBase}${req.path}`, {
    method: req.method,
    headers: { 
      ...req.headers,
      'x-migration-feature': route.feature 
    },
    body: req.method !== 'GET' ? JSON.stringify(req.body) : undefined
  });
  
  res.status(response.status).json(await response.json());
});
```

Ask Claude Code to generate your specific facade implementation:

```bash
claude "Create an API Gateway facade in [your-language/framework] that:
1. Routes requests to either legacy or modern endpoints based on configuration
2. Adds tracking headers to identify which system handled each request
3. Logs all requests with timing information
4. Handles authentication consistently across both systems
5. Returns appropriate error responses

Use environment variables for configuration and include proper TypeScript types."
```

## Implementing Incremental Feature Migration

With your facade in place, you can begin migrating features one at a time. This is where Claude Code demonstrates its value by helping you replicate functionality in the new system while maintaining parity with the old.

```bash
claude "I need to migrate the 'user-list' feature from our legacy Rails app to a new Node.js/Express API. 

Legacy implementation is in app/controllers/users_controller.rb
Legacy database table is 'users' with columns: id, name, email, created_at, updated_at, legacy_hash

Please:
1. Review the legacy implementation and extract the business logic
2. Create a new Express route handler that replicates the exact behavior
3. Write SQL/Migration for the new database schema
4. Include proper error handling and validation
5. Add unit tests that verify behavior matches the legacy system

Focus on edge cases: empty results, pagination, sorting, filtering."
```

After implementing each feature, verify that the new system behaves identically to the old:

```bash
claude "Create a verification test script that:
1. Makes identical requests to both legacy and modern endpoints
2. Compares responses for key fields (status code, body content, headers)
3. Reports any discrepancies with detailed diffs
4. Tests edge cases: empty inputs, invalid IDs, authentication scenarios
5. Outputs results in both console and JSON formats for CI integration

This will help me verify behavior parity before switching traffic."
```

## Managing Traffic Switches

Once a feature is migrated and verified, you update the facade configuration to route traffic to the new implementation. Claude Code can help you manage this systematically.

```bash
claude "Create a traffic migration checklist for switching the 'user-list' feature:
1. Pre-migration checks (new system health, test coverage, rollback plan)
2. Configuration change to route traffic to 'modern'
3. Post-migration monitoring checklist (error rates, latency, success metrics)
4. Rollback procedure if issues detected within 24 hours
5. Communication template for stakeholders

Include the exact commands to execute and expected outcomes at each step."
```

Use feature flags for additional safety:

```javascript
// Example: Feature flag integration
const featureFlags = {
  'user-list': process.env.FF_USER_LIST === 'modern',
  'user-create': process.env.FF_USER_CREATE === 'modern',
  'order-list': process.env.FF_ORDER_LIST === 'legacy',
};

function resolveTarget(feature: string): 'legacy' | 'modern' {
  const flag = featureFlags[feature];
  if (flag !== undefined) return flag ? 'modern' : 'legacy';
  return 'legacy'; // Default to legacy for unmigrated features
}
```

This allows instant rollback by simply changing environment variables without code deployment.

## Best Practices for Strangler Fig Success

The strangler fig pattern rewards patience and discipline. These practices ensure your migrations succeed.

**Start with read operations.** Query endpoints are easier to migrate because they're idempotent and don't modify state. Migration confidence builds before tackling writes.

**Migrate related features together.** If the user profile and user settings share significant code, migrate both simultaneously to avoid splitting shared logic awkwardly.

**Maintain comprehensive logging.** Every request through the facade should include headers identifying which system handled it. This becomes essential for debugging production issues.

```bash
claude "Add structured logging to the facade that captures:
1. Request ID (propagated through all systems)
2. Which system handled the request (legacy/modern)
3. Migration feature name
4. Timing for each request
5. Error details when failures occur

Use JSON format for easy log aggregation and alerting."
```

**Plan for parallel operation.** Your legacy and new systems will run simultaneously for months. Budget for the infrastructure costs and maintenance burden during this period.

**Document everything.** As features migrate, update your API documentation to reflect which system handles each endpoint. Mark deprecated endpoints clearly.

## When to Use the Strangler Fig Pattern

This pattern shines in scenarios where you cannot afford downtime or risky deployments. Consider it when migrating from monoliths to microservices, upgrading legacy frameworks (PHP to Node.js, Java to Kotlin), moving from on-premise to cloud, or consolidating multiple legacy systems into one platform.

The incremental nature of the strangler fig pattern means you deliver value continuously rather than waiting for a massive, risky release. Claude Code accelerates every phase of this journey, making what was once a daunting migration into a manageable, methodical process.

Start small, verify frequently, and let the strangler fig pattern gradually transform your system one feature at a time.
{% endraw %}
