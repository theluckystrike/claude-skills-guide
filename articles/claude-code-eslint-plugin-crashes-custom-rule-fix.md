---
layout: default
title: "Claude Code ESLint Plugin Crashes (2026)"
description: "Fix Claude Code ESLint plugin crash on custom rules. Update rule schema and fix AST visitor conflicts. Step-by-step solution."
permalink: /claude-code-eslint-plugin-crashes-custom-rule-fix/
date: 2026-04-20
last_tested: "2026-04-21"
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

## See Also

- [JetBrains Plugin Incompatibility Fix](/claude-code-jetbrains-plugin-incompatibility-fix-2026/)
- [Neovim Plugin Socket Error Fix](/claude-code-neovim-plugin-socket-error-fix-2026/)
- [Claude Code vs ESLint + Prettier: Code Quality Tools](/claude-code-vs-eslint-prettier-comparison/)


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Guides

- [Fix Claude Code Large File Crashes](/claude-code-crashes-on-large-files-how-to-fix/)
- [Claude Code Crashes When Loading Skill](/claude-code-crashes-when-loading-skill-debug-steps/)
- [Claude Code vs Cursor: Plugin Ecosystems Compared (2026)](/claude-code-vs-cursor-plugin-ecosystem-2026/)
- [Claude Code for Backstage Plugin](/claude-code-for-backstage-plugin-workflow-tutorial/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
