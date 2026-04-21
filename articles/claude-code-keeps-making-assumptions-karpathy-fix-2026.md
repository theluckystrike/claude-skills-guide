---
title: "Fix Claude Code Making Assumptions (2026)"
description: "Stop Claude Code from silently choosing libraries, patterns, and architecture — add Don't Assume rules to CLAUDE.md with exact code blocks."
permalink: /claude-code-keeps-making-assumptions-karpathy-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Fix Claude Code Making Assumptions (2026)

Claude Code picks libraries, patterns, and architectural decisions without asking. This produces code you'll rewrite. Here's the fix.

## The Problem

You ask Claude Code to add a feature. Instead of clarifying ambiguities, it silently chooses:
- Which library to use
- Where to put the files
- What error handling pattern to follow
- How to structure the implementation
- What additional features to include

The generated code works but doesn't match your project's conventions, leading to rejected PRs and wasted sessions.

## Root Cause

Claude Code is trained to be helpful and decisive. Without behavioral constraints, "helpful" means "pick the most common approach and implement it." The model has no mechanism to distinguish "I should ask" from "I should decide" unless your CLAUDE.md tells it.

## The Fix

Add this to your project's CLAUDE.md:

```markdown
## Stop Making Assumptions

### Always Ask Before
- Choosing a library not already in the project
- Creating a new file or directory pattern
- Picking an implementation approach when 2+ are valid
- Adding scope beyond the explicit request

### How to Ask
When uncertain, present options:
**Decision needed:** [what needs deciding]
**Options:**
1. [option A — tradeoffs]
2. [option B — tradeoffs]
**My recommendation:** [pick with reasoning]
```

## CLAUDE.md Rule to Add

For the strongest effect, combine with project-specific technology directives:

```markdown
## Technology Decisions (DO NOT DEVIATE)
- ORM: [your ORM]. No alternatives.
- Test framework: [your test framework]. No alternatives.
- Styling: [your approach]. No alternatives.
- When a technology choice isn't listed here, ASK before choosing.
```

## Verification

Give Claude Code an ambiguous task:

```
Add caching to the API
```

**Bad response:** installs Redis, writes a cache layer, picks TTL values
**Good response:** asks about cache backend, which endpoints, TTL strategy, and invalidation approach

If it still assumes, add the specific assumption to the "Always Ask Before" list.

Related: [Karpathy Don't Assume Principle](/karpathy-dont-assume-principle-claude-code-2026/) | [CLAUDE.md Best Practices](/claude-md-file-best-practices-guide/) | [Claude Code Best Practices](/claude-code-best-practices-2026/)
