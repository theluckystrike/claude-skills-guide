---

layout: default
title: "Claude Code for ESLint Custom Plugin Workflow Tutorial"
description: "Learn how to create, test, and publish custom ESLint plugins using Claude Code. A practical guide covering plugin structure, rule development, testing."
date: 2026-03-15
last_modified_at: 2026-03-15
author: "Claude Skills Guide"
permalink: /claude-code-for-eslint-custom-plugin-workflow-tutorial/
categories: [tutorials]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
---


{% raw %}
Claude Code for ESLint Custom Plugin Workflow Tutorial

Creating custom ESLint plugins can significantly improve your codebase's consistency and catch domain-specific issues early. When combined with Claude Code, you gain an AI-powered development partner that can accelerate every step of the plugin creation process, from scaffolding to testing and publishing.

This tutorial walks you through building a complete custom ESLint plugin workflow using Claude Code, with practical examples and actionable advice you can apply immediately.

Why Build Custom ESLint Plugins?

Before diving into the workflow, let's clarify when custom plugins make sense. You should consider creating one when your project has:

- Domain-specific rules: Enforcing naming conventions, architectural patterns, or business logic that standard ESLint rules don't cover
- Team-wide standards: Codifying your team's coding style into automated checks
- Legacy migrations: Gradually enforcing fixes during code refactoring

Custom plugins integrate smoothly with your existing ESLint configuration and can be shared across projects or published as npm packages.

Setting Up Your Plugin Project

The first step is scaffolding your plugin project with a structure that Claude Code can understand and work with efficiently. Create a new directory and initialize it:

```bash
mkdir eslint-plugin-my-team && cd eslint-plugin-my-team
npm init -y
npm install --save-dev eslint
```

Your plugin needs a specific directory structure. The most common layout places rules in a `rules` directory and tests in a `tests` directory:

```
eslint-plugin-my-team/
 rules/
    no-hardcoded-credentials.js
 tests/
    rules/
        no-hardcoded-credentials.test.js
 package.json
 README.md
```

Creating Your First Rule

Now comes the core of your plugin: the rule itself. A rule is a JavaScript object with a `create` function that returns an AST visitor. Let's create a rule that detects hardcoded credentials:

```javascript
// rules/no-hardcoded-credentials.js
module.exports = {
  meta: {
    type: "problem",
    docs: {
      description: "Disallow hardcoded credentials in source code",
      category: "Security",
      recommended: true,
    },
    schema: [
      {
        type: "object",
        properties: {
          allowedKeys: {
            type: "array",
            items: { type: "string" },
          },
        },
      },
    ],
  },
  create(context) {
    const allowedKeys = context.options[0]?.allowedKeys || [];
    
    return {
      Property(node) {
        const keyName = node.key.name;
        const value = node.value.value;
        
        const sensitivePatterns = ['password', 'secret', 'api_key', 'token'];
        const isSensitive = sensitivePatterns.some(
          pattern => keyName.toLowerCase().includes(pattern)
        );
        
        if (isSensitive && !allowedKeys.includes(keyName)) {
          context.report({
            node,
            message: `Potential hardcoded credential found in '${keyName}'. Use environment variables instead.`,
          });
        }
      },
    };
  },
};
```

This rule checks property assignments for sensitive key names and reports when it finds potential credentials. The schema allows customization of allowed keys, giving teams flexibility.

Integrating with Claude Code

Here's where the workflow becomes powerful. Create a Claude Code skill to automate repetitive tasks around your plugin:

```yaml
---
name: eslint-plugin-dev
description: "Assists with ESLint plugin development: creating rules, writing tests, and validating configurations"
tools: [Read, Write, Bash]
---

You help develop ESLint plugins. When asked to create a new rule:

1. First ask for the rule's purpose and desired behavior
2. Create the rule file in the correct location following the standard template
3. Generate corresponding test cases covering both positive and negative scenarios
4. Update the plugin's index.js to export the new rule
5. Run the test suite to verify functionality

When writing tests, use the ESLint RuleTester:
- Include 'valid' cases (code that should pass)
- Include 'invalid' cases (code that should fail) with expected errors
```

This skill gives Claude Code context about your plugin development workflow, enabling it to assist more effectively.

Writing Comprehensive Tests

Every rule needs tests. ESLint provides `RuleTester` which makes this straightforward. Here's how to test our credential rule:

```javascript
// tests/rules/no-hardcoded-credentials.test.js
const rule = require('../../../rules/no-hardcoded-credentials');
const RuleTester = require('eslint').RuleTester;

const ruleTester = new RuleTester({
  parserOptions: { ecmaVersion: 2020, sourceType: 'module' },
});

ruleTester.run('no-hardcoded-credentials', rule, {
  valid: [
    'const config = { apiUrl: "https://api.example.com" };',
    'const token = process.env.API_TOKEN;',
    {
      code: 'const settings = { password: getPassword() };',
      options: [{ allowedKeys: ['password'] }],
    },
  ],
  invalid: [
    {
      code: 'const auth = { password: "secret123" };',
      errors: [{ message: /Potential hardcoded credential/ }],
    },
    {
      code: 'const api = { api_key: "sk-abc123" };',
      errors: [{ message: /Potential hardcoded credential/ }],
    },
  ],
});
```

Run tests with:

```bash
npx eslint-ava-rule-tester tests/
```

Or use the standard ESLint test runner approach with mocha:

```bash
npm install --save-dev mocha
npx mocha tests/rules/*.test.js
```

Publishing and Sharing Your Plugin

When your plugin is ready, you can publish it to npm for reuse across projects:

```bash
npm publish
```

To use your plugin in another project:

```bash
npm install eslint-plugin-my-team
```

Then add it to your `.eslintrc.js`:

```javascript
module.exports = {
  plugins: ['my-team'],
  rules: {
    'my-team/no-hardcoded-credentials': 'error',
  },
};
```

Automating Plugin Development with Claude Code

Beyond creating individual rules, Claude Code can help with entire workflows. Consider creating skills for:

- Rule generation: Describe your requirement and have Claude Code scaffold the rule and tests
- Bulk updates: When renaming patterns across many rules
- Documentation: Auto-generate rule documentation from metadata
- Migration assistance: Help convert deprecated rules to new APIs

The key is providing Claude Code with context about your plugin's structure and conventions through well-crafted skills.

Best Practices for Plugin Development

Follow these guidelines for maintainable plugins:

1. Keep rules focused: Each rule should do one thing well
2. Provide clear error messages: Help developers understand and fix issues
3. Add schemas: Validate rule options to prevent misconfiguration
4. Write comprehensive tests: Cover edge cases and valid configurations
5. Document thoroughly: Include examples of both passing and failing code

Conclusion

Building custom ESLint plugins with Claude Code transforms what used to be a manual process into a collaborative, AI-assisted workflow. From scaffolding new rules to testing and publishing, Claude Code understands your plugin's structure and can meaningfully contribute to development.

Start small with a single rule addressing a specific problem, then expand as you see the benefits. Your team will appreciate the consistency, and future developers will thank you for catching issues before they reach production.


Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

{% endraw %}
