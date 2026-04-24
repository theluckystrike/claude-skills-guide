---
title: "Help Claude Code Work With Legacy Code (2026)"
description: "Help Claude Code work with legacy codebases by documenting quirks, deprecated patterns, and migration boundaries in CLAUDE.md."
permalink: /claude-code-cant-handle-legacy-code-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Help Claude Code Work With Legacy Code (2026)

You point Claude Code at a 2018-era Express app with callbacks, Jade templates, and Mongoose models using deprecated APIs. Claude Code suggests async/await refactors, Pug migrations, and Mongoose 8 patterns — all at once. The legacy code works. The suggestions would break it.

## The Problem

Claude Code modernizes aggressively. When it sees older patterns, it:
- Suggests upgrading deprecated APIs without checking compatibility
- Converts callbacks to async/await in code that depends on callback ordering
- Recommends replacing working libraries with modern alternatives
- Ignores that "legacy" often means "battle-tested and stable"

## Root Cause

Claude Code's training data skews toward modern practices. When it encounters `var` instead of `const`, or callbacks instead of Promises, it flags them as problems to fix rather than context to respect. The model does not distinguish between "old and broken" and "old and stable."

## The Fix

The [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) includes sections on working with legacy systems, including threat modeling for migration risks. Use its framework to document your legacy context.

### Step 1: Document Legacy Boundaries

```markdown
## Legacy Context
This project was started in 2018 and uses:
- Express 4.x with callback-style middleware
- Jade templates (NOT Pug — do not rename .jade to .pug)
- Mongoose 5.x (NOT 7 or 8 — schema syntax differs)
- jQuery 3.x in frontend (NOT React/Vue)
- var keyword in older files (DO NOT convert to const/let)

## Migration Rules
- DO NOT modernize code unless the task specifically asks for it
- New files can use modern patterns (async/await, const/let)
- Existing files: match the style already present in that file
- NEVER suggest library upgrades unless asked
```

### Step 2: Map the Danger Zones

```markdown
## Fragile Areas — EXTRA CAUTION
- routes/payment.js — Stripe callback flow, tested in production for 3 years
- middleware/auth.js — Custom session handling, do not replace with passport
- models/user.js — Pre/post hooks depend on Mongoose 5 behavior
- public/js/checkout.js — jQuery event delegation, order-dependent

Changes to these files require explicit user approval.
```

### Step 3: Define the Modernization Strategy

```markdown
## Strangler Fig Pattern
New features go in src/v2/ using modern patterns.
Old code in routes/ and models/ stays untouched unless migrating.
Migration happens feature by feature, not file by file.

When adding to a legacy file: use that file's existing patterns.
When creating a new file: use modern patterns.
```

## CLAUDE.md Code to Add

```markdown
## Legacy Code Protocol
1. Read the file before suggesting changes
2. Match existing patterns in that file (even if outdated)
3. Do not suggest upgrades unless the task is "upgrade X"
4. If a modern approach conflicts with legacy dependencies, use the legacy approach
5. Test changes against the actual Node.js version (check .nvmrc or engines in package.json)
```

## Verification

1. Ask Claude Code to add a route in the legacy Express app
2. Check: Does it use callback style to match existing routes?
3. Check: Does it avoid importing modern libraries?
4. Ask: "What should I modernize first?" — it should reference your migration strategy

## Prevention

Use the [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) "Don't Assume" principle as a reminder to read before writing. Legacy code has reasons for its patterns that are not always visible.

For migration planning, see [The Claude Code Playbook](/playbook/). Learn about scoping Claude Code sessions to specific directories in the [large repo guide](/claude-code-slow-on-large-repos-fix-2026/). For code quality patterns that respect existing style, see our [best practices guide](/karpathy-skills-vs-claude-code-best-practices-2026/).
