---
title: "Make Claude Code Match Team Conventions (2026)"
description: "Configure Claude Code to follow your team's naming, file structure, and code style conventions using CLAUDE.md and linter integration."
permalink: /claude-code-doesnt-match-team-conventions-fix-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Make Claude Code Match Team Conventions (2026)

A new pull request from Claude Code uses `camelCase` for file names when your team uses `kebab-case`. The functions use `handle` prefixes when your convention is `on` prefixes. Every Claude Code contribution needs manual style fixes before it can merge.

## The Problem

Claude Code does not automatically detect or follow:
- File naming conventions (kebab-case, camelCase, PascalCase)
- Function naming patterns (handleClick vs onClick)
- Directory organization rules
- Git commit message formats
- Comment styles (JSDoc vs inline)
- Error handling patterns (throw vs return Result)

## Root Cause

Teams develop conventions over months or years. These conventions live in tribal knowledge, PR review comments, and linter configs — not in a format Claude Code can read at session start. The model defaults to generic best practices that may conflict with your specific choices.

## The Fix

The [claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow) repo (963 stars) demonstrates how to encode team-specific workflows into Claude Code skills. It includes 28 skills and 14 agents built for an academic LaTeX/R workflow, showing how any team can codify their conventions.

### Step 1: Document Naming Conventions

```markdown
## Naming Conventions — MANDATORY
### Files
- Components: PascalCase.tsx (UserProfile.tsx)
- Hooks: camelCase starting with "use" (useAuth.ts)
- Utils: kebab-case.ts (date-helpers.ts)
- Tests: [filename].test.ts (co-located with source)
- Types: kebab-case.types.ts (user.types.ts)

### Code
- Variables: camelCase (userName, isActive)
- Constants: UPPER_SNAKE (MAX_RETRIES, API_BASE_URL)
- Types/Interfaces: PascalCase (UserProfile, ApiResponse)
- Enum values: PascalCase (Status.Active, Role.Admin)
- Private class members: prefix with underscore (_cache)

### Functions
- Event handlers: on + Event (onSubmit, onChange)
- Boolean returns: is/has/can prefix (isValid, hasPermission)
- Async functions: verb + Noun (fetchUser, createOrder)
- Factory functions: create + Noun (createLogger, createClient)
```

### Step 2: Document Structural Patterns

```markdown
## Code Structure Patterns
### React Components
1. Types/interfaces at top
2. Component function
3. Hooks first, then derived state, then handlers, then render

### API Routes
1. Input validation (Zod)
2. Authentication check
3. Authorization check
4. Business logic (via service layer)
5. Response formatting

### Error Handling
- Use Result<T, E> pattern (neverthrow library)
- NEVER use try/catch for control flow
- Log errors at the boundary, not at every level
```

## CLAUDE.md Code to Add

```markdown
## Convention Check
Before writing code, scan 2-3 existing files in the same directory to match:
- Import ordering (external → internal → relative)
- Spacing and formatting patterns
- Comment style and density
- Export patterns (named vs default)
If your output would look different from neighboring files, adjust to match.
```

## Verification

1. Ask Claude Code to create a new component
2. Check: File name matches your convention?
3. Check: Internal structure matches your pattern?
4. Check: Would this pass your PR review without style comments?

## Prevention

Combine CLAUDE.md with enforced linting. Add to your configuration:

```json
{
  "hooks": {
    "post-tool-use": [{
      "tool": "write_file",
      "command": "npx eslint --fix $FILE && npx prettier --write $FILE"
    }]
  }
}
```

The [claude-code-templates](https://github.com/davila7/claude-code-templates) library includes convention templates for popular team setups that you can customize.

For more on team setup, see the [team onboarding playbook](/claude-code-team-onboarding-playbook-2026/). Review CLAUDE.md patterns in our [CLAUDE.md best practices guide](/claude-md-best-practices-10-templates-compared-2026/). Learn about hooks-based enforcement in the [hooks guide](/understanding-claude-code-hooks-system-complete-guide/).
