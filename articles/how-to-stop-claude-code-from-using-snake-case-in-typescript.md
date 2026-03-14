---
layout: default
title: "How to Stop Claude Code from Using Snake Case in TypeScript"
description: "Practical guide to prevent Claude Code from generating snake_case variable names in TypeScript projects. Learn configuration tricks and best practices."
date: 2026-03-14
categories: [claude-code, typescript, configuration]
tags: [claude-code, typescript, naming-conventions, configuration, best-practices]
author: theluckystrike
permalink: /how-to-stop-claude-code-from-using-snake-case-in-typescript/
---

{% raw %}
# How to Stop Claude Code from Using Snake Case in TypeScript

If you have ever asked Claude Code to generate TypeScript code only to find it producing `user_name`, `get_data`, or `api_response` instead of the more idiomatic `userName`, `getData`, and `apiResponse`, you are not alone. This is one of the most common friction points developers encounter when working with Claude Code on TypeScript projects. The good news is that with the right configuration and prompting strategies, you can guide Claude Code to consistently use camelCase—the standard naming convention for JavaScript and TypeScript.

## Understanding Why Claude Code Uses Snake Case

Before diving into solutions, it helps to understand why Claude Code tends toward snake_case in the first place. Claude Code's training data includes a massive amount of code from multiple programming languages, and snake_case is the dominant convention in Python, Rust, Go, and many other languages. When Claude Code is not explicitly told which naming convention to use, it sometimes defaults to what it sees most frequently across its training data.

Additionally, Claude Code may interpret certain prompts ambiguously. A request like "create a user data handler" does not specify whether you want `userDataHandler` or `user_data_handler`, so Claude errs on the side of clarity—using snake_case as a more explicit separator between words.

The solution is to make your naming expectations explicit at multiple levels: in project configuration, in Claude Code settings, and in your prompts.

## Solution 1: Configure Your Project's TypeScript Compiler

TypeScript itself does not enforce variable naming conventions, but you can configure tools that do. The most effective approach combines multiple layers of configuration to create an environment where snake_case simply will not compile or get auto-formatted away.

Create or update your `tsconfig.json` to include strict settings that encourage consistent code:

```typescript
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true
  }
}
```

While these settings do not directly enforce camelCase, they create a stricter codebase that encourages more deliberate naming. Combine this with ESLint and Prettier for the actual enforcement.

## Solution 2: Set Up ESLint with camelCase Rules

ESLint is your strongest ally in preventing snake_case from entering your codebase. The `camelcase` rule will flag any snake_case variables and either warn or error depending on your configuration.

Install the necessary ESLint packages:

```bash
npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
```

Then create an `.eslintrc.js` or `.eslintrc.json` in your project root:

```javascript
module.exports = {
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint'],
  rules: {
    '@typescript-eslint/naming-convention': [
      'error',
      {
        selector: 'default',
        format: ['camelCase']
      },
      {
        selector: 'variable',
        format: ['camelCase', 'PascalCase']
      },
      {
        selector: 'function',
        format: ['camelCase', 'PascalCase']
      },
      {
        selector: 'parameterProperty',
        format: ['camelCase']
      }
    ]
  }
};
```

This configuration tells ESLint to enforce camelCase for variables, functions, and parameters. When Claude Code generates code with snake_case, ESLint will immediately flag it, and you can either fix it manually or run `eslint --fix` to auto-correct.

## Solution 3: Configure Prettier for Consistent Formatting

Prettier can also help by reformatting any snake_case to camelCase on save. Add or update your `prettier.config.js`:

```javascript
module.exports = {
  semi: true,
  singleQuote: true,
  trailingComma: 'es5',
  printWidth: 80,
  tabWidth: 2
};
```

While Prettier does not directly convert snake_case to camelCase, pairing it with ESLint's auto-fix ensures consistent formatting. The key is to enable ESLint's fix-on-save in your editor.

## Solution 4: Claude Code Settings File

Claude Code respects project-level settings that can influence its behavior. Create a `.claude.json` file in your project root to set expectations:

```json
{
  "project": {
    "name": "my-typescript-project",
    "type": "typescript"
  },
  "preferences": {
    "codeStyle": {
      "namingConvention": "camelCase",
      "useSemicolons": true,
      "quoteStyle": "single"
    }
  }
}
```

This file communicates your preferences to Claude Code. While not all settings are guarantees, Claude Code will generally respect explicit project preferences.

## Solution 5: The Prompt Engineering Approach

Perhaps the most immediate solution is to be explicit in your prompts. Claude Code responds well to clear instructions. Instead of writing:

> "Create a user authentication module"

Write:

> "Create a user authentication module using TypeScript with camelCase naming conventions for all variables, functions, and class properties. Do not use snake_case or PascalCase for variable names."

For even better results, create a system prompt orCLAUDE.md file in your project that establishes these conventions permanently:

```markdown
# Project Conventions

- All TypeScript code must use camelCase for variables, functions, and class properties
- Use PascalCase for class names and TypeScript types/interfaces
- Avoid snake_case entirely in JavaScript/TypeScript code
- Use meaningful, descriptive variable names
```

Place this `CLAUDE.md` file in your project root, and Claude Code will read it at the start of each session, making camelCase the default behavior.

## Solution 6: Use Editor Extensions for Auto-Correction

If you use VS Code, install the ESLint extension and enable "Auto Fix on Save":

```json
{
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  }
}
```

With this setting, every time you save a file, ESLint automatically corrects any snake_case violations. This means even if Claude Code generates snake_case initially, it gets converted to camelCase instantly.

## Best Practices for Long-Term Success

The most reliable approach combines multiple strategies. Start by setting up ESLint with the naming convention rules, as this provides the strongest enforcement mechanism. Add a `CLAUDE.md` file to communicate your expectations directly to Claude Code. Configure your editor to auto-fix on save, creating a frictionless workflow.

When working with Claude Code, always mention TypeScript explicitly in your prompts and specify camelCase as your preferred naming convention. Over time, Claude Code will learn your preferences and default to the correct convention without needing as much prompting.

Remember that consistency matters more than perfection. If snake_case appears occasionally, use your ESLint auto-fix to correct it rather than getting frustrated. The goal is a codebase that remains consistently readable and maintainable.

## Conclusion

Stopping Claude Code from using snake_case in TypeScript requires a multi-layered approach: project configuration, linting rules, explicit prompts, and editor tools working together. By implementing ESLint's naming convention rules, creating a CLAUDE.md file with your conventions, and being explicit in your prompts, you can enjoy TypeScript code that consistently uses camelCase—the standard that your team and future maintainers will thank you for.
{% endraw %}
