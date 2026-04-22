---
title: "What Is Context Engineering? Karpathy + Claude Code"
description: "Context engineering -- Andrej Karpathy's term for controlling what an LLM sees -- applied to Claude Code to reduce token costs by 50-70% per session."
permalink: /what-is-context-engineering-karpathy-claude-code/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# What Is Context Engineering? (Karpathy's Definition Applied to Claude Code)

## What This Means for Claude Code Users

Context engineering is the difference between a $3 Claude Code session and a $15 one. Andrej Karpathy coined the term to describe the discipline of carefully curating what information enters an LLM's context window -- and, equally important, what stays out. For Claude Code users paying per token, every unnecessary line of context is a direct cost. Mastering context engineering reduces token usage by 50-70% without sacrificing output quality.

## The Concept

Andrej Karpathy introduced the idea that "prompt engineering" was an insufficient term for what practitioners actually do. The real work is not in crafting a single prompt but in engineering the entire context that surrounds it: system prompts, retrieved documents, tool outputs, conversation history, and memory state. Karpathy's observation was that the context window is a scarce, expensive resource, and treating it casually leads to both poor results and high costs.

The core insight is that LLMs do not "know" things in the way humans do. They reason over whatever text is in their context window at inference time. If the context contains irrelevant information, the model wastes compute attending to it. If the context is missing critical information, the model hallucinates or produces generic output. Context engineering is the practice of ensuring the context is exactly right -- not too much, not too little, not the wrong information.

Avi Chawla extended this concept with practical frameworks, categorizing context engineering into four dimensions: what to include, what to exclude, how to structure it, and when to refresh it. These four dimensions map directly to Claude Code optimization techniques.

In the Claude Code environment, context engineering manifests in five layers:

1. **CLAUDE.md** -- persistent project context loaded at session start
2. **Conversation history** -- accumulates with every exchange
3. **Tool outputs** -- file reads, bash results, grep results
4. **MCP tool definitions** -- schema overhead for every connected tool
5. **Subagent context** -- duplicated context for parallel workers

Each layer has a token cost, and each layer can be optimized.

## How It Works in Practice

### Example 1: CLAUDE.md as a Context Engineering Artifact

A well-engineered CLAUDE.md file is the primary context engineering tool for Claude Code. It pre-loads essential project information, eliminating discovery tool calls.

```yaml
# CLAUDE.md -- engineered for minimal token cost, maximum context value
# Total: ~350 tokens (replaces ~5,000 tokens of discovery)

## Project: InvoiceAPI
- Stack: TypeScript, Fastify, PostgreSQL, Prisma
- Test: `pnpm test` (Vitest)
- Lint: `pnpm lint` (ESLint + Prettier)
- Build: `pnpm build`

## Architecture
- src/routes/    -- HTTP handlers (thin, delegate to services)
- src/services/  -- Business logic (fat, all logic here)
- src/models/    -- Prisma schema + generated types
- src/utils/     -- Pure utility functions

## Rules
- All database access through Prisma (never raw SQL)
- Services return Result<T, Error> types (never throw)
- Route handlers validate input with Zod schemas in src/schemas/
- Never modify src/models/generated/ (auto-generated)
```

Without this file, Claude Code would spend 3-5 tool calls discovering this information (reading package.json, checking directory structure, reading tsconfig.json). Those calls cost approximately 3 x 245 (Bash overhead) + 3 x 2,000 (file content) = 6,735 tokens. The CLAUDE.md delivers the same information in 350 tokens. **Savings: 95%.**

### Example 2: Strategic Context Exclusion

Context engineering is not just about adding the right information -- it is about excluding the wrong information. In Claude Code, large tool outputs are the primary source of context pollution.

```yaml
# CLAUDE.md -- exclusion rules (context engineering)
## Context Limits
- When running tests, pipe through `head -50` to cap output
- Never read node_modules/ or dist/ directories
- For git diff, use `--stat` first; only read full diff for specific files
- Log files: read only the last 30 lines (`tail -30`)
- Build output: redirect to /dev/null unless debugging a build failure
```

```bash
# Anti-pattern: unbounded test output (can be 5,000+ tokens)
pnpm test

# Context-engineered: capped test output (~500 tokens)
pnpm test 2>&1 | head -50

# Anti-pattern: full git diff (can be 10,000+ tokens)
git diff

# Context-engineered: summary first, then targeted (~300 tokens)
git diff --stat
```

Capping test output from 5,000 tokens to 500 tokens across 10 test runs per session saves 45,000 tokens. At Opus rates, that is $0.68-$3.38 per session.

## Token Cost Impact

Context engineering produces compounding savings because context grows with every turn. A 50K-token context that is re-sent across 20 turns costs 1M tokens in input alone. Reducing that context to 25K tokens through engineering halves the compounding cost.

```text
Unengineered session (20 turns):
  Average context: 80K tokens, growing to 150K
  Total input tokens: ~2.3M
  Cost at Opus: $34.50 input + output

Engineered session (20 turns):
  Average context: 30K tokens, growing to 60K
  Total input tokens: ~0.9M
  Cost at Opus: $13.50 input + output

Savings: $21.00 per 20-turn session (61%)
```

## Implementation Checklist

- [ ] Create or audit CLAUDE.md with essential project context (target: 200-500 tokens)
- [ ] Add context exclusion rules to CLAUDE.md (test output caps, directory exclusions)
- [ ] Split monolithic CLAUDE.md into layered files (root + module-specific)
- [ ] Set up `/compact` cadence: every 10 exchanges or 80K tokens
- [ ] Remove unused MCP tool definitions (audit tool list, disable unused)
- [ ] Add prompt specificity to team coding guidelines (file paths, line numbers)
- [ ] Establish model routing rules (Haiku for discovery, Sonnet for coding, Opus for architecture)
- [ ] Review and compress subagent task descriptions (target: under 500 tokens per handoff)

## The CCG Framework Connection

Context engineering is the theoretical foundation that unites every cost optimization technique in the CCG production framework. Token budget rules, CLAUDE.md best practices, compaction strategies, and model routing all derive from the same principle: the context window is a finite, expensive resource that must be engineered, not filled passively.

The CCG framework applies context engineering across three timescales: per-turn (prompt specificity, tool output capping), per-session (compaction, model switching), and per-project (CLAUDE.md layering, MCP tool pruning). Practitioners who internalize context engineering as a discipline rather than a collection of tips typically achieve sustained 50-70% cost reductions.

## Further Reading

- [Context Engineering for Claude Code: Complete Guide](/context-engineering-claude-code-complete-guide-2026/) -- full implementation playbook
- [CLAUDE.md as Cost Control](/claude-md-cost-control-rules-prevent-token-waste/) -- CLAUDE.md patterns specifically for cost reduction
- [Claude Code Context Window Management](/claude-code-context-window-management/) -- technical mechanics of the context window
- Andrej Karpathy -- "Context Engineering" concept (introduced via social media and talks, 2025)
- Avi Chawla -- practical context engineering frameworks and taxonomies
