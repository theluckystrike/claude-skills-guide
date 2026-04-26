---
layout: default
title: "Make Claude Code Consider Performance (2026)"
description: "Add performance awareness to Claude Code with CLAUDE.md rules for query optimization, bundle size, algorithmic complexity, and caching decisions."
permalink: /claude-code-ignores-performance-fix-2026/
date: 2026-04-20
last_tested: "2026-04-22"
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


## Why This Happens

This error occurs in Claude Code when the underlying system operation fails due to a configuration mismatch, missing dependency, or environmental constraint. The most common trigger is running Claude Code in an environment where the expected toolchain is not fully available or configured differently than the defaults Claude assumes.

When Claude Code executes commands or generates code, it relies on the project environment matching certain assumptions about installed tools, available paths, and system capabilities. If any of these assumptions are wrong, the operation fails with the error shown above. This is particularly common in fresh environments, CI/CD pipelines, Docker containers, and corporate networks with custom configurations.

The root cause usually falls into one of three categories: (1) a missing or outdated dependency that the operation requires, (2) a permission or access restriction preventing the operation from completing, or (3) a configuration file that is either missing, malformed, or pointing to the wrong location.


## If That Doesn't Work

Try these alternative approaches in order:

- **Reset the configuration:** Delete the relevant config file and let Claude Code regenerate it. Sometimes cached or corrupted configuration causes persistent failures even after fixing the root cause.
- **Check file permissions:** Run `ls -la` on the relevant files and directories. Ensure your user has read/write access. On macOS, also check System Settings > Privacy for any access restrictions.
- **Update all tooling:** Run `npm update -g` for global packages, update Claude Code itself, and verify your Node.js version with `node --version` (18+ required).
- **Try a clean environment:** Create a new terminal session to eliminate stale environment variables. Run `env | grep -i claude` and `env | grep -i proxy` to check for interfering variables.
- **Enable verbose output:** Set `CLAUDE_CODE_DEBUG=1` before running Claude Code to get detailed logging that pinpoints the exact failure step.


## Prevention

Add these rules to your project's `CLAUDE.md` to prevent this issue from recurring:

```markdown
# Environment Checks
Before running commands, verify the required tools are available.
Check versions match project requirements before proceeding.
If a command fails, read the error message carefully before retrying.
Do not retry failed commands without changing something first.
```

Additionally, consider adding a project setup validation script:

```bash
#!/bin/bash
# validate-env.sh — run before starting Claude Code sessions
set -euo pipefail

echo "Checking environment..."
node --version | grep -q "v2[0-2]" || echo "WARN: Node.js 20+ recommended"
command -v git >/dev/null || echo "ERROR: git not found"
[ -f package.json ] || echo "ERROR: not in project root"
echo "Environment check complete."
```


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.




**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Performance Monitor Chrome Extension](/chrome-extension-performance-monitor/)
- [Claude Skills Performance Optimization](/claude-skills-performance-optimization/)
- [Chrome DevTools Performance Profiling](/chrome-devtools-performance-profiling/)
- [Claude Code for Performance SLO](/claude-code-for-performance-slo-workflow-tutorial/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
