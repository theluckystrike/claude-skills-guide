---
layout: default
title: "Claude Code Gives Incorrect Imports — How to Fix"
description: "Struggling with Claude Code generating wrong import statements? This guide provides practical solutions for fixing incorrect imports in your codebase."
date: 2026-03-14
categories: [troubleshooting]
tags: [claude-code, claude-skills, troubleshooting, error-fix, imports]
author: "Claude Skills Guide"
reviewed: true
score: 10
---

# Claude Code Gives Incorrect Imports — How to Fix

Working with Claude Code means dealing with code generation across various languages and frameworks. One frustrating issue that developers encounter is when Claude generates incorrect import statements—paths that don't exist, wrong package names, or mismatched module references. This guide walks you through diagnosing and fixing these import-related problems. For related troubleshooting, see the [troubleshooting hub](/claude-skills-guide/troubleshooting-hub/).

## Why Incorrect Imports Happen

Before diving into solutions, understanding why Claude Code produces incorrect imports helps prevent future issues. Several factors contribute to this problem:

1. **Outdated project context** — Claude may not have the latest information about your project's dependency structure
2. **Similar package names** — Some frameworks have similarly named packages from different maintainers
3. **Monorepo complexity** — Multiple packages with overlapping names confuse the import resolution
4. **Custom alias configurations** — Webpack, TypeScript, or other build tools often define path aliases that Claude doesn't automatically detect

## Diagnosing the Import Problem

When you notice incorrect imports in generated code, start by identifying the specific issue. Common patterns include:

- **Wrong relative path** — Using `../../components/Button` when the actual path is `../components/Button`
- **Non-existent package** — Importing from `lodash` when you have `lodash-es` installed
- **Missing namespace** — Using `import { x } from 'module'` instead of `import * as x from 'module'`
- **Incorrect alias resolution** — Not respecting `tsconfig.json` path mappings

## Practical Solutions

### Solution 1: Provide Clear Directory Context

The most effective fix is giving Claude Code precise information about your project structure. Before asking Claude to generate code, share your import patterns.

```bash
# Share your typical import style
Our project uses these patterns:
- Components: import Button from '@/components/Button'
- Utils: import { formatDate } from '@/utils/date'
- Types: import type { User } from '@/types'
```

You can also reference your `tsconfig.json` or `jsconfig.json` path aliases directly:

```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"]
    }
  }
}
```

When working with skills like [**frontend-design**](/claude-skills-guide/claude-frontend-design-skill-review-and-tutorial/) or **tdd**, specifying your alias configuration upfront prevents incorrect import generation.

### Solution 2: Use Explicit Import Examples

Show Claude concrete examples from your existing codebase. This is particularly useful in monorepos where multiple packages have similar structures.

```javascript
// Instead of letting Claude guess, provide a reference
// Here's how we import from our shared UI package:
import { Button, Card } from '@company/ui';
import { useAuth } from '@company/auth hooks';
```

This approach works well when using skills such as [**supermemory**](/claude-skills-guide/claude-supermemory-skill-persistent-context-explained/) to store and reference your project's import conventions.

### Solution 3: Configure Skill Instructions

You can [create a custom skill](/claude-skills-guide/how-to-write-a-skill-md-file-for-claude-code/) or modify existing skill instructions to include your project's import rules. Add specific instructions about import patterns:

```markdown
# Custom Import Rules for Our Project

## Path Aliases
Always use @ alias instead of relative paths:
- Use @/components/Button NOT ../../components/Button
- Use @/hooks/useAuth NOT ../hooks/useAuth

## Named Exports
Always use named imports:
- import { useState, useEffect } from 'react'
- NOT import React from 'react'

## Package Names
- Use 'react-query' for server state
- Use '@tanstack/react-query' is NOT allowed
```

### Solution 4: Verify Generated Code Before Applying

Always review import statements before accepting Claude's code. This habit catches issues early and provides feedback that improves future generations.

```typescript
// Claude generated this:
import { useMemo } from 'react/useMemo';
// Should be:
import { useMemo } from 'react';

// Claude generated this:
import API from '../services/api/client';
// Should be (in our project):
import { apiClient } from '@/lib/api';
```

### Solution 5: Use TypeScript/ESLint for Quick Feedback

Set up your development environment to catch import errors immediately:

```bash
# Install dependencies that help identify import issues
npm install --save-dev eslint-import-resolver-alias
```

Configure `.eslintrc.js`:

```javascript
module.exports = {
  settings: {
    'import/resolver': {
      alias: {
        map: [
          ['@', './src'],
          ['@components', './src/components']
        ],
        extensions: ['.js', '.jsx', '.ts', '.tsx']
      }
    }
  }
};
```

When working with the **tdd** skill, this setup ensures your test files also have correct imports, preventing test failures due to path resolution issues.

## Fixing Existing Incorrect Imports

If Claude has already generated code with wrong imports, here's a systematic fix:

1. **Run your linter** — Most projects have ESLint configured to catch import errors
2. **Check IDE warnings** — VS Code and other editors highlight import issues in red
3. **Use auto-fix features** — Many IDEs offer quick fixes for import problems

```bash
# ESLint auto-fix for imports
npx eslint --fix src/
```

4. **Manual verification** — For complex monorepo setups, verify each import resolves correctly

## Preventing Future Import Issues

Establish practices that minimize incorrect imports:

- **Keep context updated** — Remind Claude about recent dependency changes
- **Use consistent naming** — Avoid similarly named packages that confuse AI
- **Document import conventions** — Create a reference document or skill instruction
- **Review generated code** — Always audit import statements before committing

## When to Use Specific Skills

Certain Claude skills excel at handling import-related tasks:

- **tdd** — Ensures test files have correct imports from the start
- **frontend-design** — Knows component import patterns for various frameworks
- **pdf** — Can generate documentation that includes correct import examples
- **supermemory** — Remembers your project's import conventions across sessions

## Summary

Incorrect imports from Claude Code usually stem from missing context about your project's specific configuration. By providing clear path alias information, showing concrete examples, configuring skill instructions, and verifying generated code, you can significantly reduce these issues. Remember to use skills like **tdd**, **frontend-design**, and **supermemory** to maintain consistent import patterns across your project.

## Related Reading

- [Claude Skill Not Triggering: Troubleshoot Guide](/claude-skills-guide/claude-skill-not-triggering-automatically-troubleshoot/) — resolve other common skill invocation and behavior issues
- [How to Write a Skill MD File for Claude Code](/claude-skills-guide/how-to-write-a-skill-md-file-for-claude-code/) — codify your import conventions in a custom skill
- [Claude SuperMemory Skill: Persistent Context Guide](/claude-skills-guide/claude-supermemory-skill-persistent-context-explained/) — remember project-specific conventions across sessions
- [Claude Code Skills Context Window Exceeded Error Fix](/claude-skills-guide/claude-code-skills-context-window-exceeded-error-fix/) — handle context and configuration issues in Claude Code

Built by theluckystrike — More at [zovo.one](https://zovo.one)
