---
title: "CLAUDE.md as Cost Control"
description: "Transform CLAUDE.md into a cost control instrument with rules that prevent retry spirals, cap file reads, and enforce model routing -- saving $50-200/month."
permalink: /claude-md-cost-control-rules-prevent-token-waste/
date: 2026-04-22
last_tested: "2026-04-22"
render_with_liquid: false
---

# CLAUDE.md as Cost Control: Rules That Prevent Token Waste

## The Pattern

CLAUDE.md is not just a project description file -- it is a programmable cost control mechanism. Every rule in CLAUDE.md shapes agent behavior on every turn. Rules that prevent wasteful patterns (retry loops, verbose output, unnecessary file reads) deliver compounding savings across every session. A well-optimized CLAUDE.md saves $50-$200 per month for an active Opus user.

## Why It Matters for Token Cost

CLAUDE.md loads at session start, costing 200-1,000 tokens depending on its size. That is a one-time cost per session. The rules inside CLAUDE.md influence behavior across 15-30 turns, preventing patterns that waste 5,000-50,000 tokens each. The ROI is extreme: a 500-token CLAUDE.md that prevents even one 20,000-token retry spiral pays for itself 40 times over in a single session.

The cost control potential of CLAUDE.md is underutilized because most developers treat it as a passive documentation file rather than an active behavioral constraint system.

## The Anti-Pattern (What NOT to Do)

```yaml
# Anti-pattern: CLAUDE.md as passive documentation (no cost control value)
# This is a React project using TypeScript.
# We use Vitest for testing.
# The API is in src/api/.
# Please follow our coding standards.
```

This CLAUDE.md costs ~100 tokens per session but prevents zero wasteful behaviors. It provides context (good) but imposes no constraints (missed opportunity).

## The Pattern in Action

### Step 1: Add Retry Limits

Retry spirals are the most expensive failure mode in Claude Code. A single retry loop can consume 20,000-50,000 tokens.

```yaml
# CLAUDE.md -- retry cost control
## Retry Limits
- Maximum 3 attempts on any failing command
- If a test fails 3 times with the same error, stop and report the error
- If a build fails, read the error message carefully before retrying (do not retry immediately)
- Never retry a permission-denied error -- report it to the user
- If an API returns 4xx, do not retry (client error, not transient)
- If an API returns 5xx, retry once after 2 seconds, then stop
```

**Expected savings:** Prevents 1-2 retry spirals per week. Each spiral costs 20K-50K tokens. Monthly savings: 80K-400K tokens = $1.20-$30 at Opus rates.

### Step 2: Add File Read Constraints

Unbounded file reads are the second most common token waste pattern. A single unfiltered read of a large file can inject 10,000+ tokens into the context.

```yaml
# CLAUDE.md -- file read cost control
## File Read Rules
- Never read files over 200 lines without using offset and limit parameters
- For large files (>500 lines), read the first 30 lines to understand structure, then target specific sections
- Never read files in node_modules/, dist/, build/, or .next/
- Never read binary files, images, or compiled output
- When reading test output, cap at 50 lines: `command 2>&1 | head -50`
- When reading log files, read only the last 30 lines: `tail -30 file.log`
```

**Expected savings:** Prevents 3-5 oversized file reads per session. Each costs 5,000-15,000 excess tokens. Daily savings: 15K-75K tokens = $0.23-$5.63 at Opus rates.

### Step 3: Add Output Constraints

Agent output verbosity directly costs output tokens ($15/MTok Sonnet, $75/MTok Opus).

```yaml
# CLAUDE.md -- output cost control
## Output Rules
- Do not explain code changes unless asked
- Do not suggest follow-up improvements unless asked
- Do not add TODO comments to code
- Use the Edit tool for file modifications (sends only the diff, not the full file)
- Commit messages: one line, under 72 characters, conventional format
- When reporting results, use structured format: STATUS, FILES, SUMMARY
```

**Expected savings:** Reduces average output per turn from 1,000-1,500 tokens to 400-600 tokens. Over 20 turns: saves 12K-18K output tokens per session = $0.18-$1.35 at Opus rates.

## Before and After

| Cost Control Rule | Tokens Saved/Session | Monthly Savings (Opus) |
|-------------------|---------------------|----------------------|
| Retry limits (max 3 attempts) | 5,000-50,000 | $3-$30 |
| File read constraints | 15,000-75,000 | $5-$23 |
| Output verbosity limits | 12,000-18,000 | $4-$27 |
| Tool call caps | 5,000-15,000 | $2-$8 |
| Directory exclusions | 10,000-30,000 | $3-$12 |
| **Combined** | **47,000-188,000** | **$17-$100** |

## When to Use This Pattern

- Every project that uses Claude Code regularly (this is not optional -- it is the highest-ROI optimization available)
- Team projects where multiple developers share the same codebase
- CI/CD pipelines that invoke Claude Code for automated tasks

## When NOT to Use This Pattern

- There is no scenario where cost control rules in CLAUDE.md are counterproductive. The only risk is over-constraining the agent to the point where it cannot complete complex tasks. Mitigate this by allowing the agent to escalate: "If these constraints prevent task completion, report the constraint and ask for guidance."

## Implementation in CLAUDE.md

The complete cost-optimized CLAUDE.md template:

```yaml
# CLAUDE.md

## Project: {name}
- Stack: {language, framework, database}
- Test: {test command}
- Lint: {lint command}
- Build: {build command}

## Key Directories
- {dir}: {purpose}
- {dir}: {purpose}
- NEVER MODIFY: {generated dirs}

## Cost Control Rules

### Retry Limits
- Maximum 3 attempts on any failing operation
- After 3 failures: stop, summarize what was tried, ask for guidance
- Never retry permission errors or 4xx API responses

### File Read Limits
- Max 200 lines per read without offset/limit
- Never read: node_modules/, dist/, build/, .next/, *.lock
- Cap command output: `cmd 2>&1 | head -50`
- Log files: `tail -30` only

### Output Limits
- Code changes only (no explanations unless asked)
- No TODO comments, no follow-up suggestions
- Use Edit tool (not full file rewrites)
- Structured results: STATUS | FILES | SUMMARY

### Tool Call Limits
- Maximum 15 tool calls per task
- Check /cost every 10 exchanges
- If session cost exceeds $3: report and ask before continuing

### Escalation
- If these constraints prevent task completion, report the specific constraint and ask for guidance
```

## Related Guides

- [How to Reduce Claude Code Token Usage by 3x](/reduce-claude-code-token-usage-3x-guide-2026/) -- comprehensive cost reduction strategies
- [Context Engineering for Claude Code](/context-engineering-claude-code-complete-guide-2026/) -- the framework that CLAUDE.md cost control is built on
- [Claude Code Hooks for Token Budget Enforcement](/claude-code-hooks-token-budget-enforcement/) -- automated enforcement beyond CLAUDE.md rules

- [Claude Code cost guide](/claude-code-cost-complete-guide/) — Complete guide to Claude Code costs, pricing, and optimization

## See Also

- [Installing and Managing Claude Code Skills for Cost Control](/installing-managing-claude-code-skills-cost-control/)
