---
title: "Stop Claude Code Over-Relying on Comments (2026)"
description: "Stop Claude Code from treating stale comments as authoritative by configuring comment trust rules and code-first analysis in CLAUDE.md."
permalink: /claude-code-over-relies-on-comments-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Stop Claude Code Over-Relying on Comments (2026)

A comment says `// Returns user email` but the function actually returns the full user object. Claude Code trusts the comment, generates code expecting a string, and the build breaks. Stale comments mislead the model.

## The Problem

Claude Code treats comments as ground truth. When comments contradict the actual code behavior, Claude Code often:
- Follows the comment instead of the implementation
- Generates code based on outdated JSDoc annotations
- Copies TODO comments into new files as if they were instructions
- Uses commented-out code as a pattern reference

## Root Cause

Comments are natural language — the same domain the model excels in. Code is structured syntax that requires more analysis. When a comment says one thing and the code does another, Claude Code has a bias toward the human-readable explanation.

Stale comments are pervasive in real codebases. Studies show 20-30% of comments become inaccurate over time.

## The Fix

Apply the "Don't Assume" principle from [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) to teach Claude Code to verify comments against implementation. The [SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) includes analysis agents that prioritize code behavior over documentation.

### Step 1: Add Comment Trust Rules

```markdown
## Comment Trust Hierarchy
1. Actual code behavior (function signatures, return types) — HIGHEST trust
2. TypeScript types and interfaces — HIGH trust
3. Test assertions — HIGH trust
4. JSDoc annotations — MEDIUM trust (verify against implementation)
5. Inline comments — LOW trust (may be stale)
6. TODO/FIXME comments — IGNORE for implementation (note for context only)
7. Commented-out code — ZERO trust (pretend it does not exist)
```

### Step 2: Add Verification Rules

```markdown
## When Comments Conflict With Code
If a comment says "returns X" but the function signature returns Y:
- Trust the function signature
- Flag the inconsistency in your response
- Fix the comment to match the code (not the other way around)
```

### Step 3: Clean Up While Working

```markdown
## Comment Hygiene
When modifying a function:
1. Update JSDoc to match actual parameters and return types
2. Remove commented-out code blocks
3. Update TODO comments that your change resolves
4. Delete comments that just restate the code ("increment counter by 1")
```

## CLAUDE.md Code to Add

```markdown
## Code-First Analysis
When understanding a function:
1. Read the function signature and return type FIRST
2. Read the test cases SECOND
3. Read the implementation THIRD
4. Read comments LAST (for context only, not for behavior)
Never generate code based solely on what a comment describes.
```

## Verification

1. Add a deliberately misleading comment to a function
2. Ask Claude Code to use that function in new code
3. Check: Did it follow the comment or the actual implementation?
4. With proper CLAUDE.md rules, it should follow the implementation

## Prevention

Add a comment-lint rule to your CI that flags stale JSDoc:

```bash
npx eslint --rule '{"jsdoc/check-param-names": "error"}' src/
```

The [awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) lists plugins that can validate comment accuracy during Claude Code sessions.

For more on code analysis patterns, see [The Claude Code Playbook](/playbook/). Learn about configuring trust hierarchies in the [CLAUDE.md best practices guide](/claude-md-best-practices-10-templates-compared-2026/). For debugging workflows that avoid comment traps, read the [debugging guide](/claude-code-debugging-workflow-guide-2026/).
