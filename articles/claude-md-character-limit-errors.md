---
layout: default
title: "CLAUDE.md Character Limit (2026)"
description: "The exact CLAUDE.md size recommendation, what happens when you exceed it, and techniques for keeping instructions within the effective limit."
permalink: /claude-md-character-limit-errors/
date: 2026-04-20
categories: [claude-md, fixes]
tags: [claude-md, character-limit, size, optimization, context-window]
last_updated: 2026-04-19
---

## There Is No Hard Character Limit

Claude Code does not enforce a hard character or line limit on CLAUDE.md. You can write a 1,000-line file and Claude will load it without error. The problem is not a technical limit -- it is a practical one: Anthropic recommends keeping each CLAUDE.md file under 200 lines because longer files produce measurably worse instruction adherence.

This distinction matters. You will not see an error message. You will see Claude gradually ignoring more of your rules as the file grows.

## What Happens at Different Sizes

| Lines | Behavior |
|---|---|
| Under 100 | Strong adherence to all rules |
| 100-200 | Good adherence, recommended range |
| 200-400 | Degraded adherence, especially for rules near the bottom |
| 400+ | Significant context consumption, inconsistent rule following |

The degradation is not linear. Claude does not suddenly stop at line 201. But the longer your file, the more context it consumes, and the less room Claude has for reasoning about your actual request. Rules compete with each other for attention, and later rules lose.

## How to Measure Your Current Impact

```bash
# Line count per CLAUDE.md file
find . -name "CLAUDE.md" -o -name "CLAUDE.local.md" | while read f; do
  echo "$(wc -l < "$f") $f"
done | sort -rn

# Word count (rough token estimate: 1 token ≈ 0.75 words)
wc -w CLAUDE.md

# Count rules files too
find .claude/rules/ -name "*.md" 2>/dev/null | while read f; do
  echo "$(wc -l < "$f") $f"
done | sort -rn
```

## Fix 1: Audit and Remove

The fastest fix is removing instructions that are no longer needed:

```markdown
# Remove these:
- Outdated framework-specific rules (still referencing Express 4 in an Express 5 project)
- Rules your linter already enforces (semicolons, trailing commas)
- Duplicate rules that appear in both CLAUDE.md and .claude/rules/
- Commented-out sections you kept "just in case"
- Verbose explanations that could be shortened
```

Before:
```markdown
## Testing
- We use Jest as our testing framework. Jest was chosen because it provides
  built-in mocking, snapshot testing, and good TypeScript support through
  ts-jest. All tests should follow the Arrange-Act-Assert pattern.
```

After:
```markdown
## Testing
- Framework: Jest with ts-jest
- Pattern: Arrange-Act-Assert
```

Same information, one-third the lines.

## Fix 2: Move to .claude/rules/

File-specific rules should use path-specific rules files:

```markdown
# Move from CLAUDE.md to .claude/rules/testing.md
---
paths:
  - "**/*.test.ts"
  - "**/*.spec.ts"
---
- Arrange-Act-Assert pattern
- One assertion per test
- Mock external services only
```

These load conditionally, consuming zero context when Claude works on non-test files.

## Fix 3: Move Procedures to Skills

Multi-step procedures are the biggest size offenders:

```markdown
# Move from CLAUDE.md to .claude/skills/deploy/SKILL.md
# Zero context cost until /deploy is invoked

---
name: deploy
description: Production deployment checklist
disable-model-invocation: true
---

1. Run full test suite
2. Build production bundle
3. Tag release
...
```

## Fix 4: Use @imports for Organization

If you prefer keeping all rules visible from the root file, use imports:

```markdown
# CLAUDE.md — 30 lines
## Project Identity
- Language: TypeScript 5.4
...

## Standards
@docs/coding-standards.md
@docs/api-conventions.md
@docs/security-rules.md
```

Note: imports do not reduce context consumption -- the content is still loaded. But they help you maintain and audit your rules by keeping the root file readable. For actual context savings, use `.claude/rules/` with path patterns.

## Fix 5: Prioritize Rule Placement

If you must have a longer file, put your most important rules first. Claude adheres more strongly to instructions near the top of the file:

```markdown
# CLAUDE.md — prioritized order

## Critical Rules (lines 1-30)
# Architecture boundaries, security rules, error handling

## Important Rules (lines 31-80)
# Naming conventions, testing standards

## Nice-to-Have Rules (lines 81-120)
# Code style preferences, documentation format
```

## The Compaction Factor

Long CLAUDE.md files have a compounding problem with compaction. When Claude Code auto-compacts a long conversation, the project-root CLAUDE.md is re-read from disk. If that file is 500 lines, it consumes a large portion of the post-compaction context budget before Claude even starts reasoning about your request. Shorter CLAUDE.md files leave more room for conversation history and the actual work.

```
Post-compaction context budget:
  Short CLAUDE.md (60 lines):  ~2K tokens for instructions, rest for work
  Long CLAUDE.md (400 lines):  ~8K tokens for instructions, less for work
```

This means long files do not just reduce instruction adherence -- they reduce Claude's overall reasoning capacity in extended sessions.

## Monitoring Over Time

As projects evolve, CLAUDE.md tends to grow. Set up a periodic check:

```bash
# Add to your CI pipeline or run monthly
LINES=$(wc -l < CLAUDE.md)
if [ "$LINES" -gt 200 ]; then
  echo "WARNING: CLAUDE.md has grown to $LINES lines (limit: 200)"
  echo "Run an audit to identify content that should move to .claude/rules/ or skills"
fi
```

This catches CLAUDE.md bloat before it degrades Claude's behavior. Prevention is simpler than debugging why Claude stopped following rules that "used to work."

For the complete guide to splitting CLAUDE.md, see the [length optimization guide](/claude-md-length-optimization/). For the full file specification, see the [CLAUDE.md complete guide](/claude-md-file-complete-guide-what-it-does/). For writing concise rules that Claude follows, see the [best practices guide](/claude-code-claude-md-best-practices/).
