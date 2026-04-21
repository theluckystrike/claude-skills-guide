---
title: "Karpathy Surgical Changes Principle (2026)"
description: "Apply Karpathy's Surgical Changes principle to keep Claude Code diffs minimal — change only what's needed, touch no unrelated files."
permalink: /karpathy-surgical-changes-principle-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Karpathy Surgical Changes Principle (2026)

The Surgical Changes principle from Karpathy's guidelines constrains Claude Code's modification scope. When asked to fix a bug or add a feature, Claude Code should change the minimum set of lines required — nothing more.

## The Principle

**Surgical Changes.** Every modification should be the smallest diff that achieves the stated goal. Do not refactor adjacent code, rename variables for "clarity," fix unrelated style issues, or restructure files while making a targeted change.

This means:
- Fix the bug, not the file the bug is in
- Add the feature, not "improve" surrounding code
- Change the lines that need changing, leave everything else untouched
- If unrelated improvements are needed, flag them separately

## Why It Matters

Large diffs are hard to review. When Claude Code mixes a 3-line bug fix with a 50-line refactor of the same file, the reviewer has to mentally separate "what fixed the bug" from "what was Claude Code tidying up." This slows code review and increases the risk of regressions sneaking in with the "improvements."

Surgical changes also reduce git blame noise. Six months from now, when someone runs `git blame` on a file, every line should trace back to a meaningful change — not to a drive-by refactor that happened to touch the same file as a bug fix.

For teams running multiple Claude Code agents in parallel, surgical changes prevent merge conflicts. Two agents working on different features in the same file will conflict less when each agent only touches the lines it needs.

## CLAUDE.md Implementation

```markdown
## Surgical Changes (Karpathy Principle)

### Rules
- Change ONLY the lines necessary to achieve the stated task
- Do NOT rename variables, reformat code, or restructure files unless that IS the task
- Do NOT fix unrelated issues discovered while working on the task
- When you notice unrelated problems, list them at the end of your response as "Noticed but not fixed"
- Every file you modify must be directly relevant to the task. If a file isn't mentioned in the task and doesn't need to change for the task to work, don't touch it.

### Diff Check
Before presenting changes, review your diff and remove any modifications that aren't strictly necessary for the task. If you can't justify a changed line with "this line must change for the task to work," revert it.
```

## Before/After Examples

### Before (Unsurgical)

Task: "Fix the off-by-one error in the pagination function"

```diff
- function paginate(items, page, perPage) {
+ function paginateItems(items: Item[], page: number, perPage: number): Item[] {
-   const start = page * perPage;
+   const start = (page - 1) * perPage;  // Fixed off-by-one
-   const end = start + perPage;
+   const end = Math.min(start + perPage, items.length);
-   return items.slice(start, end);
+   return items.slice(start, end);
  }
+
+ // Also extracted this helper while I was here
+ function getTotalPages(totalItems: number, perPage: number): number {
+   return Math.ceil(totalItems / perPage);
+ }
```

Problems: renamed the function, added TypeScript types, added bounds checking (not the bug), extracted a helper (not requested).

### After (Surgical)

```diff
  function paginate(items, page, perPage) {
-   const start = page * perPage;
+   const start = (page - 1) * perPage;
    const end = start + perPage;
    return items.slice(start, end);
  }
```

One line changed. The bug is fixed. Everything else stays put.

## Common Mistakes

1. **"While I'm here" syndrome** — Claude Code sees an improvement opportunity in the same file and takes it. The rule is explicit: don't.

2. **Confusing "surgical" with "incomplete"** — if the fix requires changing 3 files, change 3 files. Surgical means minimum necessary changes, not minimum file count.

3. **Not flagging noticed issues** — the principle says to list unrelated problems at the end. Skipping this means the issues go untracked.

4. **Applying to greenfield code** — when writing new code (not modifying existing), surgical changes don't apply. Write complete, well-structured new code.

## Related Principles

- **Don't Assume** — don't assume the user wants a refactor alongside the fix
- **Goal-Driven Execution** — the goal is the stated task, not general code improvement
- **Simplicity First** — surgical changes are simple by nature
- [Implement Surgical Changes in CLAUDE.md](/karpathy-surgical-changes-implementation-2026/)
- [Diff-Minimizing Examples](/karpathy-surgical-changes-examples-2026/)
- [The Claude Code Playbook](/the-claude-code-playbook/)
