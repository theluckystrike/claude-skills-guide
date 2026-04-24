---
title: "Make Claude Code Consider Performance"
description: "Add performance awareness to Claude Code with CLAUDE.md rules for query optimization, bundle size, algorithmic complexity, and caching decisions."
permalink: /claude-code-ignores-performance-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Make Claude Code Consider Performance (2026)

Claude Code writes correct code that performs poorly — N+1 queries, unbounded data fetching, synchronous operations that should be async, and missing indexes. Here's how to make it performance-aware.

## The Problem

- Database queries inside loops (N+1)
- Loading entire tables when only 10 rows are needed
- Synchronous file reads blocking the event loop
- No pagination on list endpoints
- Missing database indexes on frequently queried columns
- Importing entire libraries when only one function is needed

## Root Cause

Claude Code optimizes for correctness and readability, not performance. "Fetch all users and filter in memory" is simpler code than "write a SQL WHERE clause." Without performance constraints, the agent picks the simpler approach.

## The Fix

```markdown
## Performance Rules

### Database
- NEVER query inside a loop. Use batch queries, JOINs, or IN clauses.
- ALWAYS paginate list endpoints (default limit: 20, max: 100).
- Add indexes for columns used in WHERE, ORDER BY, and JOIN clauses.
- Use SELECT with explicit columns, not SELECT *.

### API Responses
- Don't return data the client doesn't need.
- Use pagination for any endpoint that could return 100+ items.
- Consider response size — flatten nested objects if nesting adds bloat.

### Frontend (if applicable)
- Lazy-load components not visible on initial render.
- Import specific functions, not entire libraries: `import { debounce } from 'lodash-es'` not `import _ from 'lodash'`
- Avoid re-renders: memo, useMemo, useCallback where measured.

### General
- Prefer async operations for I/O (file reads, network calls, DB queries).
- When processing large datasets, use streaming or chunking.
- State the time complexity of algorithms when it's worse than O(n).
```

## CLAUDE.md Rule to Add

```markdown
## Performance Check
Before writing database queries:
- Is this inside a loop? → refactor to batch query
- Does this return unbounded results? → add pagination
- Is this missing an index? → add it

Before writing API endpoints:
- What's the maximum response size? → add limits
- Can this be paginated? → paginate it

Flag any operation with O(n^2) or worse complexity.
```

## Verification

```
Create an endpoint that returns all orders with their line items and product details
```

**Performance-ignorant:** fetches all orders, then loops to fetch line items for each, then loops again to fetch products
```typescript
// BAD: N+1+1 queries
const orders = await db.orders.findMany();
for (const order of orders) {
  order.items = await db.lineItems.findMany({ where: { orderId: order.id } });
  for (const item of order.items) {
    item.product = await db.products.findUnique({ where: { id: item.productId } });
  }
}
```

**Performance-aware:** single query with includes and pagination
```typescript
// GOOD: 1 query, paginated
const orders = await db.orders.findMany({
  take: 20,
  skip: (page - 1) * 20,
  include: {
    items: { include: { product: true } },
  },
  orderBy: { createdAt: 'desc' },
});
```

Related: [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/) | [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) | [Karpathy Simplicity First](/karpathy-simplicity-first-principle-claude-code-2026/)
