---
title: "Structured Metadata vs Discovery (2026)"
description: "Structured metadata costs 200-500 tokens while discovery queries burn 3,000-15,000 tokens for the same information -- close this gap in Claude Code."
permalink: /structured-metadata-vs-discovery-queries-token-gap/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Structured Metadata vs Discovery Queries: The Token Efficiency Gap

## What This Means for Claude Code Users

Every time Claude Code runs `ls`, reads `package.json`, or greps for import statements to understand a project, it is executing a discovery query. These queries cost 1,000-5,000 tokens each. Structured metadata -- pre-built indexes, manifests, and CLAUDE.md files -- delivers the same information for 200-500 tokens. The gap between these approaches is the single largest source of preventable token waste, often accounting for 20-40% of total session cost.

## The Concept

Discovery queries are read-time operations where Claude Code explores the codebase to answer a question: "What testing framework is used?", "Where are the API routes?", "What version of Node is this project using?" Each question triggers one or more tool calls (Bash, Read, Grep), each carrying overhead (245 tokens for Bash, 150 tokens for Read) plus the response content.

Structured metadata is write-time information: project facts documented once and loaded cheaply. A 300-token CLAUDE.md section replaces what would otherwise require 3-5 discovery tool calls costing 3,000-10,000 tokens. The efficiency gap between these approaches is 10-30x.

The concept mirrors database query optimization. A full table scan (discovery query) examines every row to find an answer. An indexed lookup (structured metadata) jumps directly to the answer. In token economics, the "index" is pre-computed context.

## How It Works in Practice

### Example 1: Project Orientation

Without structured metadata, Claude Code must discover project basics through exploration.

```bash
# Discovery approach: 5 tool calls, ~6,500 tokens total
# Call 1: ls (245 overhead + ~200 content = 445 tokens)
ls -la

# Call 2: Read package.json (150 overhead + ~800 content = 950 tokens)
# Reads entire package.json to find framework, test runner, scripts

# Call 3: Read tsconfig.json (150 overhead + ~400 content = 550 tokens)
# Discovers TypeScript configuration

# Call 4: ls src/ (245 overhead + ~300 content = 545 tokens)
# Maps directory structure

# Call 5: Grep for test framework (245 overhead + ~500 content = 745 tokens)
# grep -r "describe\|it\|test" --include="*.test.*" -l
```

Total discovery cost: approximately 3,235 tokens in overhead plus 3,200 tokens in content = **6,435 tokens**.

```yaml
# Structured metadata approach: 1 file load, ~400 tokens total

# CLAUDE.md
## ProjectX
- Stack: TypeScript 5.4, React 19, Next.js 15
- Test: Vitest (`pnpm test`)
- Lint: `pnpm lint` (Biome)
- Build: `pnpm build`
- Node: 22 (enforced via .nvmrc)

## Directory Map
- src/app/       -- Next.js app router pages
- src/components -- React components (one per file)
- src/lib/       -- Shared utilities and hooks
- src/server/    -- Server actions and API routes
- tests/         -- Integration tests (Vitest)
```

Total metadata cost: **~400 tokens**. Savings: **94%** (6,035 tokens saved).

### Example 2: Dependency Discovery

When Claude Code needs to know which libraries are available, it can either read package.json (950+ tokens for a typical project) or consult a pre-built summary.

```yaml
# CLAUDE.md -- dependency metadata section (~200 tokens)
## Key Dependencies
- ORM: Prisma 6.2 (schema in prisma/schema.prisma)
- Auth: next-auth 5.0 (config in src/lib/auth.ts)
- Validation: Zod 3.23
- State: Zustand 5.0
- HTTP: Built-in fetch (no axios)
- Date: date-fns 4.1 (no moment.js)

## Do Not Install
- axios (use fetch)
- moment (use date-fns)
- lodash (use native Array methods)
```

This 200-token metadata block prevents Claude Code from reading the full package.json (950 tokens), checking for lock files (500 tokens), and potentially installing duplicate libraries (which triggers more discovery). Net savings: 1,250+ tokens per session that touches dependencies.

## Token Cost Impact

The token efficiency gap compounds across a session because discovery queries add content to the context window that persists through subsequent turns. A 6,000-token discovery result re-sent across 15 turns costs 90,000 tokens in total input. A 400-token metadata block re-sent across 15 turns costs 6,000 tokens.

```text
20-turn session, 3 discovery phases:
  Discovery approach: 3 * 6,000 = 18,000 tokens (initial)
  Re-send cost: 18,000 * 20 turns = 360,000 cumulative input tokens
  Session cost at Opus: $5.40 (input only)

  Metadata approach: 400 tokens (initial, loaded once)
  Re-send cost: 400 * 20 turns = 8,000 cumulative input tokens
  Session cost at Opus: $0.12 (input only)

  Savings: $5.28 per session (98%)
```

## Implementation Checklist

- [ ] Audit the first 5 tool calls of the last 10 sessions -- identify repeated discovery patterns
- [ ] Create a CLAUDE.md with project basics (stack, commands, directory map) -- target 300-500 tokens
- [ ] Add a dependency summary section -- key libraries and "do not install" list
- [ ] Document API endpoint inventory in a structured format (route, method, auth requirement)
- [ ] Create module-level CLAUDE.md files for complex directories
- [ ] Add a "conventions" section covering naming patterns, file structure, and coding style

## The CCG Framework Connection

The structured metadata vs discovery query framework is the practical core of context engineering for Claude Code. Every CLAUDE.md best practice, every skill definition, and every MCP tool optimization ultimately reduces to the same principle: pre-compute context at write time to avoid expensive discovery at read time. The CCG framework treats metadata investment as the highest-ROI activity a team can perform for AI-assisted development.

## Further Reading

- [What Is Context Engineering?](/what-is-context-engineering-karpathy-claude-code/) -- the conceptual framework behind metadata-first approaches
- [CLAUDE.md as Cost Control](/claude-md-cost-control-rules-prevent-token-waste/) -- practical CLAUDE.md patterns
- [The Metadata-First Pattern](/metadata-first-pattern-npx-metadata-json/) -- the architecture pattern formalized
