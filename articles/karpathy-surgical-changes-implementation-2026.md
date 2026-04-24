---
title: "Implement Surgical Changes in CLAUDE.md (2026)"
description: "Copy-paste CLAUDE.md rules that enforce Karpathy's Surgical Changes principle — diff budgets, file-scope limits, and noticed-issue tracking."
permalink: /karpathy-surgical-changes-implementation-2026/
last_tested: "2026-04-22"
render_with_liquid: false
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
