---
title: "Implement Karpathy Don't Assume (2026)"
description: "Copy-paste CLAUDE.md rules that enforce Karpathy's Don't Assume principle — with severity levels, exception handling, and team customization."
permalink: /karpathy-dont-assume-implementation-claude-md-2026/
last_tested: "2026-04-22"
---

# Implement Karpathy Don't Assume in CLAUDE.md (2026)

This article provides production-ready CLAUDE.md blocks that enforce Karpathy's Don't Assume principle. Copy-paste these into your project, customize the exception list, and Claude Code stops making silent decisions.

## The Principle

Don't Assume means Claude Code asks before choosing when the codebase doesn't dictate the answer. The implementation challenge is calibration: too strict and every action requires approval; too loose and the principle is toothless.

## Why It Matters

Teams that deploy the Don't Assume principle report 40-60% fewer reverted PRs from Claude Code. The clarification round-trip adds 15-30 seconds but prevents 10-30 minute rewrite cycles when assumptions are wrong.

The key is making the rules specific enough that Claude Code knows exactly when to ask and when to proceed.

## CLAUDE.md Implementation

### Minimal Version (Solo Developers)

```markdown
## Assumptions Policy
- When a task has multiple valid approaches, list them with tradeoffs before implementing
- When adding a new dependency, confirm it's wanted before installing
- When the task scope is ambiguous, state what you think is in/out and ask
- EXCEPTION: Follow existing codebase patterns without asking
```

### Standard Version (Small Teams)

```markdown
## Don't Assume — Clarification Rules

### Always Ask Before
- Adding a dependency not in package.json / requirements.txt / go.mod
- Creating a new directory or file naming convention
- Choosing between 2+ valid architectural approaches
- Modifying shared configuration files (tsconfig, eslint, webpack, etc.)
- Adding functionality beyond what was explicitly requested
- Changing error handling patterns from what exists in the codebase

### Never Ask About
- Following established patterns in the codebase (same validation lib, same test structure)
- Variable and function naming that follows existing conventions
- Import ordering and formatting (handled by linters)
- Adding types/interfaces that mirror existing data structures

### How to Ask
Present options in this format:
1. **Option A** — [description]. Pros: [x]. Cons: [y].
2. **Option B** — [description]. Pros: [x]. Cons: [y].
Recommendation: [your pick and why]
```

### Strict Version (Enterprise / Compliance)

```markdown
## Don't Assume — Strict Clarification Protocol

### CRITICAL — Always Ask
- Any new dependency (including transitive dependencies over 1MB)
- Any change to authentication, authorization, or security boundaries
- Any modification to database schemas or migrations
- Any change to API contracts (request/response shapes, status codes)
- Any modification to CI/CD pipelines or deployment configurations
- Any change to environment variables or secrets management
- Creating, renaming, or deleting files outside the task's stated scope

### IMPORTANT — Ask When Ambiguous
- Implementation approach when 2+ patterns exist in the codebase
- Error handling strategy when the task involves new error types
- Test coverage scope (unit only, integration, e2e)
- Performance optimization approach (caching, pagination, lazy loading)

### LOW — Proceed With Note
- Formatting and style choices within established linter rules
- Internal variable and function naming
- Comment content and documentation phrasing
- Test case naming conventions

When asking, use this format:
**Decision needed:** [what]
**Options:**
1. [option with tradeoffs]
2. [option with tradeoffs]
**My recommendation:** [pick with reasoning]
**Risk if wrong:** [consequence of choosing incorrectly]
```

## Before/After Examples

### Before (No Rules)

```
User: Add rate limiting to the API

Claude Code: Done. I installed express-rate-limit and applied a
100 req/15min limit to all routes. I also added Redis store for
distributed rate limiting since you have Redis in docker-compose.
```

Problems: chose the library, set arbitrary limits, assumed distributed need.

### After (Standard Version)

```
User: Add rate limiting to the API

Claude Code:
**Decision needed:** Rate limiting implementation

**Options:**
1. **express-rate-limit (in-memory)** — simple, no new deps if you
   use the built-in store. Won't work across multiple instances.
2. **express-rate-limit + rate-limit-redis** — adds Redis store.
   Works across instances. You already have Redis in docker-compose.
3. **Custom middleware** — full control, no dependencies, but more
   code to maintain.

**My recommendation:** Option 2 — you have Redis available and your
docker-compose suggests multi-instance deployment.

Also need to confirm:
- Rate limits: per-user, per-IP, or per-API-key?
- Thresholds: how many requests per window?
- Which routes: all routes, or just auth-sensitive ones?
```

## Common Mistakes

1. **Rules too vague** — "Ask before making big decisions" gives Claude Code no calibration. Define specific categories.

2. **No exception list** — without "never ask about" items, Claude Code asks about everything, including trivial formatting choices.

3. **Missing the "how to ask" format** — without a format template, Claude Code asks unstructured questions that are hard to answer quickly.

4. **Forgetting to update exceptions** — as your project matures, more patterns become established. Update the "never ask" list to match.

## Related Principles

- [Don't Assume: Real Project Examples](/karpathy-dont-assume-examples-real-projects-2026/) — see these rules in action
- [Debug When Claude Code Assumes Wrong](/karpathy-dont-assume-debugging-failures-2026/) — diagnose assumption failures
- [Karpathy Skills Complete Guide](/karpathy-claude-code-skills-complete-guide-2026/) — all four principles
- [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) — structuring your full CLAUDE.md


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


## Related Guides

- [Implement ArXiv Papers with Claude Code](/claude-code-arxiv-paper-implementation-guide/)
- [Implement Surgical Changes in CLAUDE.md](/karpathy-surgical-changes-implementation-2026/)
- [Implement Goal-Driven Execution](/karpathy-goal-driven-implementation-2026/)
- [Implement SOLID Principles with Claude](/claude-code-solid-principles-implementation/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json. When working with Claude Code on this topic, keep these implementation details in mind: **Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations. **Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code. **Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%. **Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results."
      }
    }
  ]
}
</script>
