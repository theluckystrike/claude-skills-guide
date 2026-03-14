---

layout: default
title: "How to Make Claude Code Respect My ESLint Config"
description: "A practical guide to ensuring Claude Code follows your ESLint configuration when writing and editing code. Learn the key techniques and configurations."
date: 2026-03-14
categories: [guides]
tags: [claude-code, eslint, linting, code-quality, configuration, claude-skills]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /how-to-make-claude-code-respect-my-eslint-config/
---


{% raw %}
# How to Make Claude Code Respect My ESLint Config

When you're working with Claude Code as your AI coding assistant, you want assurance that the code it generates or modifies aligns with your project's linting rules. Nothing breaks the development flow faster than committing code that immediately triggers ESLint errors in CI/CD. This guide walks you through the essential techniques to make Claude Code respect your ESLint configuration consistently.

## Understanding Claude Code and ESLint Integration

Claude Code interacts with your codebase through tools that read, write, and execute commands. When generating code or making edits, it doesn't automatically "see" your ESLint configuration—it relies on you to provide context about your coding standards. The good news is that Claude Code can absolutely respect your ESLint setup when properly configured.

The key is understanding that Claude Code operates within a skill framework and session context. Within those boundaries, you have several powerful mechanisms to ensure linting compliance.

## Method 1: Use Project Context Files

The most straightforward approach is making your ESLint configuration visible to Claude Code through project context. Create a `.claude/context.md` file in your project root that explicitly references your ESLint setup:

```markdown
# Project Context

## Linting Configuration
- ESLint config: eslint.config.js (or .eslintrc.json)
- Project uses Airbnb JavaScript Style Guide
- Enforced rules: no-var, prefer-const, camelCase
- Max line length: 100 characters
```

This context file loads automatically when Claude Code operates in your project. By documenting your ESLint configuration here, you're essentially giving Claude Code a reference guide it can consult when writing code.

For projects with complex ESLint setups, consider creating a dedicated `docs/eslint-rules.md` that lists specific rules:

```markdown
# ESLint Rules Reference

## JavaScript Rules
- `no-unused-vars`: error - No unused variables allowed
- `semi`: ["error", "always"] - Semicolons required
- `quotes`: ["error", "single"] - Single quotes for strings
- `indent`: ["error", 2] - 2-space indentation

## Import Rules
- `import/order`: ["error", { "groups": [["builtin", "external", "internal"]] }]
- `import/no-unresolved`: error
```

## Method 2: Configure Claude Code with Custom Skills

Claude Code's skill system lets you define custom behaviors that include linting awareness. Create a skill that explicitly references your ESLint configuration:

```yaml
---
name: eslint-aware-code
description: Write code that respects project ESLint configuration
tools:
  - Read
  - Write
  - Bash
  - Edit
---

You are a code generator that always respects the project's ESLint configuration.

When writing or editing code:
1. First check for eslint.config.js, .eslintrc.json, or .eslintrc.js
2. Review the extends and rules sections
3. Apply those rules when generating code
4. Always run `npm run lint` or `npx eslint .` after making changes
5. Fix any linting errors before considering the task complete

Common patterns to avoid based on standard ESLint rules:
- No `var` declarations - use `const` or `let`
- Always use semicolons
- Use single quotes for strings
- Declare variables before using them
- No console.log statements in production code
```

To use this skill, invoke it in your conversation: `/skill eslint-aware-code`

## Method 3: Use Pre-Commit Hooks with Claude Code

One of the most reliable methods is setting up a pre-commit workflow that validates Claude Code's output. Create a script that runs ESLint checks:

```bash
#!/bin/bash
# scripts/claude-lint-check.sh

echo "Running ESLint validation..."
npx eslint --ext .js,.jsx,.ts,.tsx,.vue,.svelte .

if [ $? -ne 0 ]; then
    echo "ESLint found issues. Please fix before committing."
    exit 1
fi

echo "ESLint check passed!"
```

Add this to your project's pre-commit hooks or run it explicitly after Claude Code completes significant work:

```bash
# After Claude Code makes changes
npm run lint
# or
yarn lint
```

If you're using Claude Code's Bash tool frequently, create an alias:

```bash
alias clint='npx eslint . --max-warnings=0'
```

## Method 4: Prompt Engineering for Linting Compliance

In your conversations with Claude Code, explicitly state your ESLint requirements. This is the simplest method but requires consistency:

```
Please write a new utility function in src/utils/format.js. The code must pass ESLint checks - we use Airbnb style guide with TypeScript. Run the linter after writing the code and fix any issues.
```

You can make this even more effective by creating a reusable prompt template:

```
CONTEXT: Our project uses ESLint with the following configuration:
- Config: .eslintrc.json
- Extends: airbnb-base, prettier
- Rules: strict mode, semicolons required, 2-space indent

When writing code:
1. Follow these ESLint rules strictly
2. Run `npm run lint` after completing code changes
3. Fix any linting errors before finishing
4. Report the linting results in your response
```

## Method 5: Integrate ESLint into Claude Code's Workflow

For teams that want seamless integration, configure Claude Code to automatically run ESLint after file modifications. You can do this through custom tool configurations or by adding explicit instructions in your project's CLAUDE.md file:

```markdown
# Claude Code Instructions

## Code Quality
After any file write or edit operation, automatically run:
```bash
npm run lint
```

If ESLint reports errors, fix them immediately before confirming the task is complete.
```

## Best Practices for Long-Term Success

**Document your ESLint setup comprehensively.** The more context Claude Code has about your linting rules, the better it can comply.

**Use consistent command invocation.** Whether you prefer `npm run lint`, `yarn lint`, or direct ESLint commands, be consistent and remind Claude Code which command you use.

**Consider ESLint caching.** For large projects, enable ESLint cache to speed up validation:
```bash
npx eslint . --cache
```

**Review Claude Code's output.** While these methods significantly improve compliance, always verify the generated code passes your linting checks—especially for critical production code.

## Troubleshooting Common Issues

If Claude Code consistently ignores your ESLint config, try these solutions:

1. **Missing context**: Ensure your ESLint config files are in the project root
2. **Wrong config file name**: Verify you're using the correct filename (eslint.config.js, .eslintrc.json, etc.)
3. **Parser issues**: Check that ESLint parser and parserOptions match your project (for TypeScript, Vue, etc.)
4. **Plugin conflicts**: Some plugins require specific configuration that Claude Code might miss

## Conclusion

Making Claude Code respect your ESLint configuration is entirely achievable through context files, custom skills, pre-commit hooks, and consistent prompting. The investment in setting up these mechanisms pays off in cleaner code, fewer CI/CD failures, and a more productive development workflow.

Start with the context file method for quick results, then progressively add skill configurations and hooks for comprehensive coverage. Your future self—along with your code review teammates—will thank you.
{% endraw %}


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/claude-code-token-usage-optimization-best-practices-guide/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

