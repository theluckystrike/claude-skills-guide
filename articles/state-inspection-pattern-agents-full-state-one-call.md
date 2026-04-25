---
layout: default
title: "State Inspection Pattern (2026)"
description: "The state inspection pattern delivers complete backend state to Claude Code in one tool call, eliminating 5-10 discovery queries and saving 3,000-8,000 tokens."
permalink: /state-inspection-pattern-agents-full-state-one-call/
date: 2026-04-22
last_tested: "2026-04-22"
---

# State Inspection Pattern: Give Agents Full Backend State in One Call

## The Pattern

The state inspection pattern consolidates system state into a single queryable endpoint or command that returns everything an agent needs to understand the current system status -- database counts, queue depths, error rates, deployment version, and service health -- in one call instead of 5-10 separate queries.

## Why It Matters for Token Cost

Every tool call in Claude Code carries overhead: ~245 tokens for a Bash call, ~150 tokens for a Read call, plus the response content. When Claude Code needs to understand system state, the typical discovery pattern runs 5-10 commands:

- Check API health: `curl localhost:3000/health` (~245 + ~200 = ~445 tokens)
- Check database: `psql -c "SELECT count(*) FROM users"` (~245 + ~100 = ~345 tokens)
- Check queue: `curl localhost:3000/api/queue/stats` (~245 + ~300 = ~545 tokens)
- Check cache: `redis-cli info memory` (~245 + ~400 = ~645 tokens)
- Check errors: `tail -20 /var/log/app/error.log` (~245 + ~600 = ~845 tokens)

Total: ~2,825 tokens in overhead and responses for 5 calls. With 10 calls, this reaches 4,000-8,000 tokens.

The state inspection pattern collapses this into one call: ~245 tokens overhead + ~800 tokens response = ~1,045 tokens. Savings: 1,780-6,955 tokens per state inspection sequence.

At Sonnet 4.6 rates ($3/$15 per MTok), saving 5,000 tokens per inspection across 100 monthly sessions: $1.50/month in input tokens alone, higher with output token compounding.

## The Anti-Pattern (What NOT to Do)

```bash
# Anti-pattern: Claude Code runs 7 separate commands to understand state
curl -s localhost:3000/health
psql -h localhost -d myapp -tc "SELECT count(*) FROM users"
psql -h localhost -d myapp -tc "SELECT count(*) FROM orders WHERE status='pending'"
psql -h localhost -d myapp -tc "SELECT count(*) FROM subscriptions WHERE status='active'"
redis-cli info memory | grep used_memory_human
curl -s localhost:3000/api/queue/stats
tail -5 /var/log/app/error.log
```

Token cost: 7 x ~245 overhead + variable responses = ~3,500-5,000 tokens.

Each command is also a separate conversational turn, meaning the accumulated context grows with each call. By the 7th call, Claude Code is re-sending all previous tool calls and responses as input.

## The Pattern in Action

### Step 1: Build the Inspection Endpoint

```typescript
// src/api/routes/inspect.ts
import { Router } from "express";
import { prisma } from "../db";
import { redis } from "../cache";
import { queue } from "../queue";

const router = Router();

router.get("/api/inspect", async (req, res) => {
  const MAX_ERRORS = 10; // Bounded: NASA P10 Rule 2
  const TIMEOUT_MS = 5000;

  // Parallel data fetch with timeout
  const timeoutPromise = new Promise((_, reject) =>
    setTimeout(() => reject(new Error("Inspection timeout")), TIMEOUT_MS)
  );

  try {
    const [userCount, pendingOrders, activeSubscriptions, queueStats, cacheInfo] =
      await Promise.race([
        Promise.all([
          prisma.user.count(),
          prisma.order.count({ where: { status: "PENDING" } }),
          prisma.subscription.count({ where: { status: "ACTIVE" } }),
          queue.getJobCounts(),
          redis.info("memory"),
        ]),
        timeoutPromise,
      ]) as [number, number, number, object, string];

    const memoryMatch = cacheInfo.match(/used_memory_human:(\S+)/);

    res.json({
      status: "healthy",
      ts: new Date().toISOString(),
      db: { users: userCount, pending_orders: pendingOrders, active_subs: activeSubscriptions },
      queue: queueStats,
      cache: { memory: memoryMatch ? memoryMatch[1] : "unknown" },
      deploy: { version: process.env.APP_VERSION || "unknown", node: process.version },
    });
  } catch (error) {
    res.status(500).json({
      status: "degraded",
      error: error instanceof Error ? error.message : "Unknown error",
      ts: new Date().toISOString(),
    });
  }
});

export default router;
```

### Step 2: Create a CLI Wrapper

```bash
#!/bin/bash
# scripts/inspect.sh -- CLI wrapper for state inspection
set -uo pipefail

TIMEOUT=5

RESPONSE=$(curl -sf --max-time "$TIMEOUT" localhost:3000/api/inspect 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "INSPECT_FAILED: API unreachable (exit code: $EXIT_CODE)"
  exit 1
fi

echo "$RESPONSE"
```

### Step 3: Reference in CLAUDE.md

```markdown
# CLAUDE.md

## System State
- Quick state check: `./scripts/inspect.sh`
- Returns: DB counts, queue stats, cache info, deploy version
- Use this FIRST before running individual diagnostic commands
```

## Before and After

| Metric | Anti-Pattern (7 calls) | Inspection Pattern (1 call) | Improvement |
|--------|----------------------|---------------------------|-------------|
| Tool calls | 7 | 1 | 86% fewer |
| Token overhead | ~1,715 | ~245 | 86% reduction |
| Response tokens | ~1,800 | ~400 | 78% reduction |
| Total tokens | ~3,515 | ~645 | 82% reduction |
| Conversational turns | 7 | 1 | 86% fewer |
| Context accumulation | High (each call compounds) | Minimal | Significant |

### Step 4: Advanced -- Filtered Inspection

For targeted inspections that return only relevant sections:

```bash
#!/bin/bash
# scripts/inspect.sh -- supports section filtering
set -uo pipefail

TIMEOUT=5
SECTION="${1:-all}"

RESPONSE=$(curl -sf --max-time "$TIMEOUT" "localhost:3000/api/inspect?section=$SECTION" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "INSPECT_FAILED: API unreachable (exit code: $EXIT_CODE)"
  exit 1
fi

echo "$RESPONSE"
```

```bash
# Full inspection
./scripts/inspect.sh all

# Database only (smaller response, fewer tokens)
./scripts/inspect.sh db

# Queue only
./scripts/inspect.sh queue
```

Filtered inspection further reduces token cost: a database-only inspection returns ~100 tokens of JSON instead of ~400 tokens for the full response. When Claude Code is investigating a database-specific issue, the filtered version saves 300 tokens per call.

## When to Use This Pattern

- **System debugging**: When Claude Code needs to understand overall system health before diagnosing a specific issue.
- **Deployment verification**: After deploying, check that all services are healthy in one call.
- **Routine monitoring tasks**: Daily health checks or automated reporting scripts.

### Database-Specific State Inspection

For database-heavy applications, create a database-specific inspection endpoint:

```typescript
// src/api/routes/inspect-db.ts
router.get("/api/inspect/db", async (req, res) => {
  const MAX_TABLES = 30;

  try {
    const tables = await prisma.$queryRaw`
      SELECT table_name,
             (SELECT count(*) FROM information_schema.columns c
              WHERE c.table_name = t.table_name AND c.table_schema = 'public') as column_count
      FROM information_schema.tables t
      WHERE table_schema = 'public'
      ORDER BY table_name
      LIMIT ${MAX_TABLES}`;

    // Get row counts for key tables (bounded: top 10 largest)
    const rowCounts: Record<string, number> = {};
    const keyTables = ["users", "orders", "subscriptions", "invoices", "sessions"];

    for (const table of keyTables) {
      try {
        const result = await prisma.$queryRawUnsafe(
          `SELECT count(*) as count FROM "${table}"`
        );
        rowCounts[table] = Number(result[0].count);
      } catch {
        rowCounts[table] = -1; // Table may not exist
      }
    }

    // Get recent migration status
    const migrations = await prisma.$queryRaw`
      SELECT migration_name, finished_at
      FROM _prisma_migrations
      ORDER BY finished_at DESC
      LIMIT 5`;

    res.json({
      tables: tables.length,
      tableList: tables,
      rowCounts,
      recentMigrations: migrations,
      schemaVersion: migrations[0]?.migration_name || "unknown",
    });
  } catch (error) {
    res.status(500).json({
      error: error instanceof Error ? error.message : "DB inspection failed",
    });
  }
});
```

This single endpoint replaces: `\dt` (list tables), `\d <table>` (describe tables x5), `SELECT count(*)` (row counts x5), and migration status queries. Total replacement: 10-12 individual queries, saving 3,000-6,000 tokens.

### Caching Inspection Results

For expensive inspection queries, cache the results with a short TTL:

```bash
#!/bin/bash
# scripts/inspect-cached.sh
# Cache inspection results for 60 seconds
set -uo pipefail

CACHE_FILE="/tmp/claude-inspect-cache.json"
CACHE_TTL=60  # seconds

# Check cache freshness
if [ -f "$CACHE_FILE" ]; then
  CACHE_AGE=$(( $(date +%s) - $(stat -f%m "$CACHE_FILE" 2>/dev/null || stat -c%Y "$CACHE_FILE") ))
  if [ "$CACHE_AGE" -lt "$CACHE_TTL" ]; then
    cat "$CACHE_FILE"
    exit 0
  fi
fi

# Cache miss: fetch fresh data
curl -sf --max-time 5 localhost:3000/api/inspect > "$CACHE_FILE" 2>/dev/null
cat "$CACHE_FILE"
```

If Claude Code calls the inspection endpoint multiple times in a session (common during debugging), the cache prevents redundant API calls. Each cached call saves ~245 tokens of Bash overhead and the round-trip latency.

## When NOT to Use This Pattern

- **Single-metric checks**: If Claude Code only needs one piece of information (e.g., user count), a direct query is simpler and avoids loading unnecessary data.
- **High-security environments**: The inspection endpoint exposes internal state. Restrict access with authentication and do not deploy it to public-facing routes.

## Implementation in CLAUDE.md

```markdown
# CLAUDE.md -- State Inspection Rule

## Diagnostics Protocol
1. ALWAYS run `./scripts/inspect.sh` FIRST when investigating system issues
2. Parse the JSON response before running additional queries
3. Only run individual diagnostic commands if the inspection output is insufficient
4. Never run more than 3 individual diagnostic commands without compacting
```

This rule guides Claude Code toward the efficient pattern and prevents the 7-command anti-pattern from recurring.

### Inspection Pattern for Microservices

In microservice architectures, each service has its own state. A gateway-level inspection endpoint aggregates state from all services:

```typescript
// src/api/routes/inspect-all.ts
router.get("/api/inspect/all", async (req, res) => {
  const TIMEOUT_MS = 3000;
  const services = [
    { name: "auth", url: "http://auth-service:3001/inspect" },
    { name: "billing", url: "http://billing-service:3002/inspect" },
    { name: "notifications", url: "http://notify-service:3003/inspect" },
  ];

  const results: Record<string, unknown> = {};

  await Promise.all(
    services.map(async (svc) => {
      try {
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), TIMEOUT_MS);
        const res = await fetch(svc.url, { signal: controller.signal });
        clearTimeout(timeout);
        results[svc.name] = await res.json();
      } catch {
        results[svc.name] = { status: "unreachable" };
      }
    })
  );

  res.json({ services: results, ts: new Date().toISOString() });
});
```

Without the aggregated endpoint, Claude Code would run 3 separate curl commands (3 x ~445 = ~1,335 tokens of overhead). With the gateway endpoint, one call (~445 tokens) returns all three services' state. For architectures with 5+ services, the savings scale linearly.

**Savings: (N-1) x ~445 tokens per multi-service inspection, where N is the number of services.**

### Versioning Inspection Responses

As the backend evolves, the inspection endpoint should return version information so Claude Code can detect schema changes:

```json
{
  "inspectVersion": "3",
  "status": "healthy",
  "db": { "users": 14523, "pending_orders": 47 },
  "changedSince": {
    "v2": "Added queue.failed_24h field",
    "v3": "Added deploy.git_sha field"
  }
}
```

The version field allows CLAUDE.md rules to specify expectations: "Inspection endpoint v3 returns deploy.git_sha. If missing, the backend may be outdated." This prevents Claude Code from running additional diagnostic commands when the inspection response format changes.

## Related Guides

- [Agent-First Backend Design: Principles for Token Efficiency](/agent-first-backend-design-token-efficiency/) -- the broader architecture philosophy
- [Reducing Claude Code MCP Round-Trips: Batch Operations Pattern](/reducing-claude-code-mcp-round-trips-batch-pattern/) -- batch pattern for MCP operations
- [Claude Code Hooks Guide](/understanding-claude-code-hooks-system-complete-guide/) -- automate state checks with hooks
