---
title: "Make Claude Code Write Documentation (2026)"
description: "Make Claude Code generate JSDoc, README sections, and inline documentation by adding documentation requirements to CLAUDE.md."
permalink: /claude-code-doesnt-write-docs-fix-2026/
last_tested: "2026-04-22"
---

# Make Claude Code Write Documentation (2026)

Claude Code writes a 200-line module with zero documentation. No JSDoc, no README section, no inline comments explaining the non-obvious parts. The code works but is opaque to the next person who reads it.

## The Problem

By default, Claude Code prioritizes working code over documented code. It skips:
- JSDoc comments on exported functions
- README updates for new modules
- Inline comments for non-obvious logic
- Type documentation for complex generics
- Changelog entries for notable changes

## Root Cause

Documentation is not required for code to function. Claude Code optimizes for the immediate request ("add this feature") and treats documentation as optional unless told otherwise. The model also avoids being overly verbose, which means it errs on the side of fewer comments.

## The Fix

The [claude-howto](https://github.com/luongnv89/claude-howto) repo (28K+ stars) includes documentation templates with Mermaid diagrams and copy-paste blocks. Use their patterns to define your documentation standards in CLAUDE.md.

### Step 1: Require Documentation Per Change

```markdown
## Documentation Requirements — MANDATORY
Every code change must include:

### For New Functions (exported)
- JSDoc with @param, @returns, @throws, @example
- At least one usage example in the JSDoc

### For New Modules/Files
- File-level JSDoc explaining the module's purpose
- Relationship to other modules (what imports this, what this imports)

### For Complex Logic
- Inline comment explaining WHY, not WHAT
- Link to relevant spec/ticket if the logic is non-obvious

### For API Endpoints
- Request/response examples in JSDoc
- Error response documentation
- Rate limit information if applicable
```

### Step 2: Provide Documentation Templates

```markdown
## JSDoc Template
/**
 * Calculates prorated amount for mid-cycle plan changes.
 *
 * @param currentPlan - The customer's active subscription plan
 * @param newPlan - The plan being switched to
 * @param daysRemaining - Days left in current billing cycle
 * @returns The prorated credit or charge amount in cents
 * @throws {InvalidPlanError} If either plan is archived
 *
 * @example
 * const proration = calculateProration(basicPlan, proPlan, 15);
 * // Returns 1500 (credit of $15.00)
 */
```

### Step 3: Define What NOT to Document

```markdown
## Documentation Anti-Patterns — AVOID
- Comments that restate the code: // increment i by 1
- Comments on self-documenting code: // get user by ID
- Redundant type documentation when TypeScript types are clear
- Documentation for private/internal helper functions (unless complex)
```

## CLAUDE.md Code to Add

```markdown
## Documentation Checklist
Before completing any task:
1. All exported functions have JSDoc with @param and @returns
2. Complex logic has a WHY comment
3. New files have a module-level description
4. If you added a public API endpoint, the route file has request/response docs
```

## Verification

1. Ask Claude Code to create a new service module
2. Check: Does every exported function have JSDoc?
3. Check: Is there a module-level comment explaining purpose?
4. Check: Are the non-obvious parts explained?

## Prevention

Add ESLint rules enforcing JSDoc on exports:

```json
{
  "rules": {
    "jsdoc/require-jsdoc": ["error", {
      "require": { "FunctionDeclaration": true, "MethodDefinition": true },
      "contexts": ["ExportNamedDeclaration"]
    }]
  }
}
```

The [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) index includes documentation-generation skills that work alongside Claude Code.

For documentation as part of your workflow, see [The Claude Code Playbook](/playbook/). For enforcing documentation via hooks, read the [hooks guide](/understanding-claude-code-hooks-system-complete-guide/). For team-wide documentation standards, check the [team onboarding playbook](/claude-code-team-onboarding-playbook-2026/).

## See Also

- [Fix Claude Code Not Understanding Codebase (2026)](/claude-code-doesnt-understand-codebase-fix-2026/)
- [Make Claude Code Explain Its Changes (2026)](/claude-code-doesnt-explain-changes-fix-2026/)
- [Make Claude Code Read Existing Code First (2026)](/claude-code-doesnt-read-existing-code-fix-2026/)
- [Make Claude Code Follow DRY Principle (2026)](/claude-code-doesnt-follow-dry-principle-fix-2026/)


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

- [How to Write Token-Efficient Claude](/write-token-efficient-claude-code-skills/)
- [How to Make Claude Code Write](/how-to-make-claude-code-write-performant-sql-queries/)
- [How to Make Claude Code Write Secure](/how-to-make-claude-code-write-secure-code-always/)
- [Write Database Queries with Claude Code](/how-to-use-claude-code-to-write-database-queries-from-scratch/)

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
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows."
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
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
