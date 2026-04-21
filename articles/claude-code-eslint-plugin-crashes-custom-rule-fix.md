---
title: "Claude Code ESLint Plugin Crashes on Custom Rule — Fix (2026)"
description: "Fix Claude Code ESLint plugin crash on custom rules. Update rule schema and fix AST visitor conflicts. Step-by-step solution."
permalink: /claude-code-eslint-plugin-crashes-custom-rule-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
ESLint: TypeError: Cannot read properties of undefined (reading 'type')
  Rule: "custom-plugin/my-rule"
  at RuleContext._checkSelector (/node_modules/eslint/lib/linter/rule-context.js:45:22)

# Or:
Oops! Something went wrong! :(
ESLint: 9.0.0
TypeError: context.getScope is not a function
  at create (/lib/rules/my-custom-rule.js:12:28)

# Or:
Configuration for rule "custom-plugin/my-rule" is invalid:
  Value "error" should be object.
```

## The Fix

1. **Update custom rules for ESLint v9 flat config API changes**

```javascript
// WRONG — ESLint v8 API (deprecated)
module.exports = {
  create(context) {
    const scope = context.getScope();  // Removed in v9
    return {
      Identifier(node) {
        context.report({ node, message: "..." });
      }
    };
  }
};

// CORRECT — ESLint v9 API
module.exports = {
  meta: {
    type: "problem",
    schema: [],  // Required in v9
  },
  create(context) {
    return {
      Identifier(node) {
        const scope = context.sourceCode.getScope(node);  // v9 API
        context.report({ node, message: "..." });
      }
    };
  }
};
```

2. **Verify the rule loads correctly in isolation**

```bash
# Test just the custom rule
npx eslint --rule '{"custom-plugin/my-rule": "error"}' --debug src/test-file.ts 2>&1 | head -20
```

3. **Verify the fix:**

```bash
npx eslint src/ --max-warnings 0 2>&1 | tail -5
# Expected: No errors or only linting warnings (no crash stack traces)
```

## Why This Happens

ESLint v9 introduced the flat config system and removed several deprecated APIs. Custom rules written for ESLint v8 that use `context.getScope()`, `context.getAncestors()`, or `context.parserServices` crash because these methods no longer exist. The replacement APIs live on `context.sourceCode`. When Claude Code runs your linter as part of a pre-commit hook or code generation validation, these crashes block the entire workflow with an unhelpful TypeError.

## If That Doesn't Work

- **Alternative 1:** Pin ESLint to v8 temporarily: `npm install eslint@8 --save-dev` while you migrate custom rules
- **Alternative 2:** Disable the crashing rule in your config: `{ "custom-plugin/my-rule": "off" }` and file a migration issue
- **Check:** Run `npx eslint --print-config src/file.ts | grep my-rule` to see how the rule is configured and if the schema matches

## Prevention

Add to your `CLAUDE.md`:
```markdown
All ESLint custom rules must use the v9 API: context.sourceCode.getScope(node) instead of context.getScope(). Include meta.schema in every custom rule definition. Test custom rules in isolation before adding to the shared config.
```

**Related articles:** [ESLint Prettier Conflict Fix](/claude-code-eslint-prettier-conflict-fix/), [Debugging Skills](/claude-code-debugging-skill/), [Errors Atlas](/errors-atlas/)
