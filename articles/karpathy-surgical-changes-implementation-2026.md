---
title: "Implement Surgical Changes in CLAUDE.md (2026)"
description: "Copy-paste CLAUDE.md rules that enforce Karpathy's Surgical Changes principle — diff budgets, file-scope limits, and noticed-issue tracking."
permalink: /karpathy-surgical-changes-implementation-2026/
last_tested: "2026-04-22"
---

# Implement Surgical Changes in CLAUDE.md (2026)

Ready-to-use CLAUDE.md blocks that keep Claude Code diffs minimal. Three versions — from lightweight to strict — with diff budgets and file-scope limits.

## The Principle

Change only what's necessary. See the [full principle guide](/karpathy-surgical-changes-principle-2026/).

## Why It Matters

Every unnecessary line in a diff is a line that could introduce a regression, a merge conflict, or a confused reviewer. Surgical rules keep Claude Code focused on the task, not on general housekeeping.

## CLAUDE.md Implementation

### Minimal Version

```markdown
## Change Scope
- Only modify lines directly required for the current task
- Do not refactor, rename, or restyle code unless that is the task
- List any unrelated issues you notice under "Noticed but not fixed"
```

### Standard Version

```markdown
## Surgical Changes — Scope Control

### File Rules
- Only modify files that MUST change for the task to work
- Before modifying a file, state why it needs to change
- If a file needs more than 50 lines changed, confirm scope with the user

### Line Rules
- Change the minimum lines necessary
- Do not rename variables or functions unless the task requires it
- Do not reformat code (whitespace, line breaks, import ordering)
- Do not add comments to existing code unless the task is "add documentation"
- Do not change error messages, log statements, or strings unless they're the bug

### Noticed Issues
At the end of every response that modifies code, include:
**Noticed but not fixed:**
- [issue 1 — location and description]
- [issue 2 — location and description]
Or "None" if no issues were noticed.
```

### Strict Version

```markdown
## Surgical Changes — Strict Protocol

### Pre-Change Declaration
Before making ANY changes, list:
1. Files that will be modified
2. For each file, the specific lines/sections that will change
3. Justification: why each change is necessary for the task

### Change Budget
- Bug fixes: target ≤10 lines changed
- Small features: target ≤50 lines changed
- If your change exceeds the budget, explain why and get confirmation

### Prohibited Actions (unless explicitly requested)
- Renaming anything (variables, functions, files, directories)
- Reformatting (whitespace, semicolons, quotes, import order)
- Adding or removing comments
- Restructuring code (moving functions between files, reordering methods)
- Upgrading dependencies or changing version numbers
- Modifying configuration files not related to the task

### Post-Change Audit
After making changes, verify:
- Every modified line is necessary for the task
- No files were touched that aren't directly needed
- The diff is the smallest possible for this task
```

## Before/After Examples

### Before: Bug Fix Plus Cleanup

```diff
  // auth.ts
- import { hash, compare } from 'bcrypt'
- import { sign, verify } from 'jsonwebtoken'
+ import { hash, compare } from 'bcrypt';
+ import { sign, verify } from 'jsonwebtoken';

- export async function login(email, password) {
+ export async function login(email: string, password: string): Promise<LoginResult> {
    const user = await db.users.findByEmail(email)
-   if (!user) return null
+   if (!user) {
+     return { success: false, error: 'User not found' };
+   }
-   const valid = await compare(password, user.passwordHash)
+   const valid = await compare(password, user.passwordHash);
-   if (!valid) return null
+   if (!valid) {
+     return { success: false, error: 'Invalid password' };
+   }
-   // BUG: token expires in seconds, should be hours
-   return sign({ id: user.id }, SECRET, { expiresIn: 3600 })
+   const token = sign({ id: user.id }, SECRET, { expiresIn: '1h' });
+   return { success: true, token };
  }
```

22 lines changed. The bug was a 1-line fix (`3600` → `'1h'`). Everything else is semicolons, types, and error refactoring.

### After: Surgical Fix

```diff
  export async function login(email, password) {
    const user = await db.users.findByEmail(email)
    if (!user) return null
    const valid = await compare(password, user.passwordHash)
    if (!valid) return null
-   return sign({ id: user.id }, SECRET, { expiresIn: 3600 })
+   return sign({ id: user.id }, SECRET, { expiresIn: '1h' })
  }
```

1 line changed. Bug fixed. Done.

## Common Mistakes

1. **Using strict mode for greenfield work** — when building new features from scratch, there's nothing to be surgical about. Use surgical rules for modifications only.

2. **Counting "noticed but not fixed" as failure** — the list of noticed issues is a feature, not a problem. It captures tech debt visibility without mixing it into unrelated diffs.

3. **Not adjusting change budgets** — a database migration might need 200 lines of schema changes. The budget is a guideline for flagging unexpectedly large diffs, not a hard cap.

## Related Principles

- [Surgical Changes: Diff-Minimizing Examples](/karpathy-surgical-changes-examples-2026/) — more before/after diffs
- [Fix Claude Code Touching Unrelated Files](/karpathy-surgical-changes-debugging-2026/) — debugging scope creep
- [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) — where surgical rules fit
- [Claude Code Hooks Explained](/understanding-claude-code-hooks-system-complete-guide/) — hooks can enforce diff size limits


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

- [Claude Code Version History and Changes](/claude-code-version-history-changes-2026/)
- [Fix Claude Md Changes Not Taking Effect](/claude-md-changes-not-taking-effect-fix-guide/)
- [Make Claude Code Explain Its Changes](/claude-code-doesnt-explain-changes-fix-2026/)
- [Implement ArXiv Papers with Claude Code](/claude-code-arxiv-paper-implementation-guide/)

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
