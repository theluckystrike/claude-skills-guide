---
title: "Reduce Claude Code Costs with ccusage (2026)"
description: "Cut Claude Code spending by tracking sessions with ccusage, identifying token waste, and applying CLAUDE.md rules that reduce unnecessary tool calls."
permalink: /claude-code-costs-too-much-reduce-spend-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Reduce Claude Code Costs with ccusage (2026)

Your Claude Code bill is higher than expected. Here's how to find where tokens are wasted and add rules that cut spend without reducing output quality.

## The Problem

Common cost drivers:
- Long sessions that drift from the goal (goal drift → extra tool calls)
- Generating then reverting wrong implementations (assumption waste)
- Over-reading files for context that isn't needed
- Generating overly verbose explanations between tool calls
- Re-reading the same files multiple times in a session

## Root Cause

Claude Code doesn't optimize for cost. It optimizes for helpfulness, which means reading broadly, explaining thoroughly, and generating complete solutions. Without constraints, this maximizes tokens consumed per task.

## The Fix

### 1. Install ccusage for Visibility

```bash
npx ccusage session --limit 10
```

Identify your most expensive sessions. Look for:
- Sessions over $5 (usually contain a stuck loop or massive drift)
- Sessions where duration exceeds 1 hour (likely drift)
- Projects that consistently cost more than others

### 2. Add Cost-Conscious CLAUDE.md Rules

```markdown
## Token Efficiency
- Read only the files you need. Don't scan entire directories "for context."
- Keep explanations brief — 1-2 sentences between tool calls, not paragraphs.
- If a task requires more than 15 tool calls, pause and ask if the approach is right.
- Don't regenerate code that was already written. If a small change is needed, edit the specific lines.
- When searching for code, use targeted grep patterns, not broad file reads.
```

### 3. Break Large Tasks

Instead of:
```
Rewrite the entire authentication system
```

Use:
```
Phase 1: Replace bcrypt with argon2 in the password service only
```

Smaller tasks = fewer tool calls = less spend.

## CLAUDE.md Rule to Add

```markdown
## Cost Guard
- Maximum 20 tool calls per task. If you reach 20, summarize progress and ask how to proceed.
- Prefer editing specific lines over rewriting entire files.
- Don't read files larger than 500 lines in full — read targeted line ranges.
- Avoid re-reading files already in context.
```

## Verification

Run `npx ccusage session` before and after adding rules. Compare:
- Average cost per session
- Average tool calls per session
- Frequency of sessions over $5

Expect a 20-40% reduction in per-session cost with these rules active.

Related: [ccusage Cost Tracking Guide](/ccusage-claude-code-cost-tracking-guide-2026/) | [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/) | [The Claude Code Playbook](/playbook/)
