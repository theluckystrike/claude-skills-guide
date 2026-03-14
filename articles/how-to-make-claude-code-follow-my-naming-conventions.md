---
layout: default
title: "How to Make Claude Code Follow My Naming Conventions"
description: "Learn practical techniques to configure Claude Code to respect your naming conventions. Includes .claude.json settings, skill patterns, and examples."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills, naming-conventions, code-style]
author: "theluckystrike"
reviewed: true
score: 8
permalink: /how-to-make-claude-code-follow-my-naming-conventions/
---

{% raw %}

# How to Make Claude Code Follow My Naming Conventions

Getting Claude Code to consistently respect your naming conventions is essential for maintaining code quality across your projects. Whether you prefer camelCase, PascalCase, snake_case, or any other naming style, you can configure Claude Code to understand and apply your conventions automatically. This guide explores practical methods to ensure AI-generated code matches your project's naming standards from the first line written.

## Why Naming Conventions Matter

Naming conventions are the backbone of readable and maintainable code. When Claude Code generates code that doesn't match your project's established patterns, you spend valuable time refactoring and correcting inconsistencies. This becomes especially painful in larger teams where multiple developers interact with the same codebase.

The good news is that Claude Code is highly configurable. By providing clear, persistent instructions about your naming preferences, you can reduce manual corrections and maintain consistency throughout your project lifecycle.

## Using .claude.json for Global Naming Preferences

The most straightforward approach to enforce naming conventions is through the `.claude.json` configuration file. This file lives in your project root and provides Claude Code with persistent context about your preferences.

Create or update your `.claude.json` with specific naming instructions:

```json
{
  "preferences": {
    "naming": {
      "variables": "camelCase",
      "constants": "UPPER_SNAKE_CASE",
      "functions": "camelCase",
      "classes": "PascalCase",
      "interfaces": "PascalCase",
      "types": "PascalCase",
      "files": "kebab-case",
      "directories": "kebab-case",
      "components": "PascalCase",
      "hooks": "camelCase",
      "database_tables": "snake_case",
      "database_columns": "snake_case",
      "api_endpoints": "kebab-case"
    }
  }
}
```

This configuration serves as a baseline that Claude Code references when generating any new code. The preferences cover all common naming contexts, from JavaScript variables to database schemas.

## Creating a Naming Conventions Skill

For more complex or language-specific naming requirements, create a dedicated Claude skill that enforces your conventions. Skills provide richer context and can handle nuanced rules that configuration files cannot express.

Create a file named `naming-conventions.md` in your `.claude/skills` directory:

```markdown
---
name: naming-conventions
description: Enforces project-specific naming conventions
trigger: always
---

# Naming Conventions

Follow these naming conventions for all code generation:

## JavaScript/TypeScript
- Use camelCase for variables, functions, and let/const declarations
- Use PascalCase for classes, interfaces, types, and React components
- Use UPPER_SNAKE_CASE for constants and enum values
- Prefix boolean variables with is, has, should, or can
- Use verb prefixes for functions: get, set, fetch, handle, on

## React Components
- Use PascalCase for component names
- Name props interfaces as ComponentNameProps
- Name custom hooks with use prefix: useCustomHook
- Name event handlers with on prefix: onClick, onSubmit

## CSS/Modules
- Use kebab-case for class names
- Use camelCase for CSS-in-JS style objects

## File Naming
- Use kebab-case for all file names
- Components: UserProfile.tsx, auth-button.tsx
- Utils: date-helper.ts, api-client.ts
- Hooks: use-auth.ts, use-fetch-data.ts

## Database
- Use snake_case for table and column names
- Use singular table names: user, product, order
- Prefix junction tables: user_role (not roles_users)

Always verify generated names match these patterns before completing code generation.
```

This skill activates automatically and provides comprehensive guidance for every code generation task.

## Language-Specific Naming Patterns

Different programming languages have different conventions. You can configure Claude Code to apply the right convention based on the language being used.

### Python Conventions

For Python projects, add specific instructions:

```python
# Use snake_case for:
# - functions: def get_user_data()
# - variables: user_name = "John"
# - private methods: def _internal_method()
# - constants: MAX_RETRY_COUNT = 3

# Use PascalCase for:
# - classes: class UserProfile:
# - exceptions: class InvalidInputError:

# Use SCREAMING_SNAKE_CASE for:
# - module-level constants
# - enum values
```

### Java/Kotlin Conventions

For Java and Kotlin projects:

```java
// Use PascalCase for:
// - classes: public class UserService
// - interfaces: interface Repository<T>
// - enums: enum UserRole { ADMIN, USER }

// Use camelCase for:
// - methods: public void getUserById()
// - variables: private String userName
// - parameters: void processOrder(Order order)

// Use ALL_CAPS for:
// - constants: public static final int MAX_SIZE = 100
```

## Enforcing Naming in Specific Contexts

Some naming conventions are context-dependent. You can create targeted instructions for specific scenarios.

### API Response Naming

When generating API code, enforce consistent JSON naming:

```javascript
// For API responses, prefer:
// - snake_case for JSON properties: user_id, created_at
// - camelCase for JavaScript variables: userId, createdAt

// In your skill:
When generating API endpoints and responses:
- Use snake_case for all JSON property names
- Use camelCase for all JavaScript/TypeScript variables
- This applies to request bodies, response payloads, and error objects
```

### Database Naming Conventions

For database-related code generation:

```sql
-- Table naming:
-- - Use singular names: user, product, order
-- - Use snake_case: user_profile, order_item

-- Column naming:
-- - Primary key: id
-- - Foreign keys: user_id, product_id
-- - Timestamps: created_at, updated_at
-- - Boolean: is_active, has_permission

-- Index naming:
-- - idx_table_column: idx_users_email
-- - Unique indexes: uk_users_email
```

## Verifying Naming Compliance

After configuring your naming conventions, verify that Claude Code follows them consistently. Create a verification skill that reviews generated code:

```markdown
---
name: naming-audit
description: Audits code for naming convention compliance
trigger: verify
---

# Naming Audit

Before completing any code generation task:

1. Scan all generated identifiers against project naming rules
2. Check variable names follow camelCase (or your convention)
3. Verify file names use kebab-case
4. Ensure React components use PascalCase
5. Report any violations found

If violations exist, refactor the code to match conventions before finalizing.
```

## Combining Approaches for Maximum Effect

The most robust solution combines multiple approaches. Start with `.claude.json` for baseline preferences, add a comprehensive skill for detailed rules, and use verification steps to catch any misses.

This layered approach ensures that even if one layer misses a specific convention, another layer catches it. The result is consistent, convention-compliant code that requires minimal manual intervention.

## Testing Your Configuration

After setting up your naming conventions, test them with a simple prompt:

```bash
# Ask Claude Code to generate a simple function
Generate a function that calculates the total price for a shopping cart
```

Check the output:
- Variables should use your preferred case style
- Function names should follow your conventions
- File names should match your patterns

If anything doesn't match, adjust your configuration and retest. Fine-tuning your settings takes some initial effort but pays dividends in reduced refactoring time.

## Conclusion

Making Claude Code follow your naming conventions is straightforward with the right configuration. Start with `.claude.json` for broad coverage, add a dedicated skill for detailed rules, and implement verification steps to ensure compliance. Once configured, Claude Code becomes an active participant in maintaining your project's naming standards, generating code that's ready to merge from the first draft.

{% endraw %}
