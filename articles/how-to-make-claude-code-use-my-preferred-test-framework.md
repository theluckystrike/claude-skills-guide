---
layout: default
title: "How to Make Claude Code Use My Preferred Test Framework"
description: "Learn how to configure Claude Code to use your preferred testing framework with practical examples and custom skill configurations."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, testing, test-frameworks, configuration, skills]
author: theluckystrike
reviewed: false
score: 0
permalink: /how-to-make-claude-code-use-my-preferred-test-framework/
---

# How to Make Claude Code Use My Preferred Test Framework

One of the most common questions developers have when working with Claude Code is: "How can I make Claude use my preferred test framework instead of the default?" Whether you're team Jest, pytest, RSpec, or any other testing framework, Claude Code is flexible enough to adapt to your workflow. This guide walks you through multiple methods to configure Claude Code to use your preferred test framework.

## Understanding How Claude Code Selects Test Frameworks

Claude Code automatically detects test frameworks based on your project's dependencies and configuration files. When you ask Claude to write tests, it scans for:

- `package.json` → looks for Jest, Vitest, or Mocha
- `pyproject.toml` or `requirements.txt` → looks for pytest or unittest
- `Gemfile` → looks for RSpec
- `go.mod` → looks for testing packages
- Framework-specific config files (jest.config.js, vitest.config.ts, etc.)

However, you can override this detection and explicitly instruct Claude to use your preferred framework.

## Method 1: Using Custom Skills to Set Your Preferred Framework

The most powerful approach is creating a custom skill that tells Claude exactly which test framework to use. Skills are markdown files that guide Claude's behavior during your session.

Create a skill file at `~/.claude/skills/test-framework.md`:

```markdown
# Test Framework Preference Skill

When asked to write tests, ALWAYS use [your preferred framework] unless explicitly told otherwise.

## Preferred Test Framework: pytest

- Use pytest for all Python testing
- Use pytest fixtures for test setup and teardown
- Write tests using assert statements
- Use pytest markers for test categorization
- Include descriptive test names following test_*.py convention

## Example Test Structure

```python
import pytest

def test_function_returns_expected_value():
    """Test that the function returns the correct value."""
    result = my_function(input_value)
    assert result == expected_value

@pytest.fixture
def sample_data():
    return {"key": "value"}
```

Always explain test coverage after writing tests.
```

After creating this skill, activate it in your Claude Code session:

```
/test-framework
```

Now when you ask Claude to write tests, it will automatically use pytest instead of any other framework.

## Method 2: Project-Specific Configuration with CLAUDE.md

For project-specific test framework preferences, create a `CLAUDE.md` file in your project root:

```markdown
# Project Context

## Test Framework
This project uses **Vitest** for all testing, NOT Jest.

## Testing Rules
- Write unit tests in `src/__tests__/`
- Write integration tests in `tests/integration/`
- Use Vitest's `describe`, `it`, and `expect` syntax
- Run tests with `npm run test:unit` or `npx vitest`
- Include coverage reports with `npx vitest --coverage`
```

Now whenever Claude Code works in this project, it will read `CLAUDE.md` and automatically use Vitest for all testing tasks.

## Method 3: Inline Instructions for One-Off Testing

Sometimes you just need to override the default for a single request. Simply specify your preferred framework in the prompt:

```
Write unit tests for the user authentication module. Use Mocha with Chai assertions, not Jest.
```

Claude will follow your explicit instruction and use Mocha for that specific task.

## Method 4: Configuring Test Framework in Project Files

Many testing frameworks can be configured in project files that Claude will automatically detect. Here's how to set up your preferred framework explicitly:

### For JavaScript/TypeScript Projects (Vitest)

```javascript
// vitest.config.ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html']
    },
    include: ['src/**/*.test.ts'],
    exclude: ['node_modules', 'dist']
  }
})
```

### For Python Projects (pytest)

```toml
# pyproject.toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "-v --strict-markers"
markers = [
    "unit: Unit tests",
    "integration: Integration tests",
]
```

### For Ruby Projects (RSpec)

```ruby
# .rspec
--require spec_helper
--format documentation
--color

# spec/spec_helper.rb
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_types = true
  end
end
```

## Practical Examples

### Example 1: Switching from Jest to Vitest

You have a JavaScript project but prefer Vitest's faster performance. Create `~/.claude/skills/vitest.md`:

```markdown
# Vitest Preference Skill

Always use Vitest for JavaScript/TypeScript testing in this project.

When writing tests:
1. Use `import { describe, it, expect } from 'vitest'`
2. Use `vi.fn()` for mocks instead of `jest.fn()`
3. Use `vi.mock()` for module mocking
4. Run tests with `npx vitest`
```

### Example 2: Using Playwright for E2E Testing

If you want Claude to use Playwright instead of Cypress:

```markdown
# Playwright E2E Testing Skill

For end-to-end testing, ALWAYS use Playwright:

- Import from `@playwright/test`
- Use `test` and `expect` from Playwright
- Use page.locator() for element selection
- Configure browsers in playwright.config.ts
- Run tests with `npx playwright test`

Example test structure:
```typescript
import { test, expect } from '@playwright/test';

test('user can login', async ({ page }) => {
  await page.goto('/login');
  await page.fill('#username', 'user');
  await page.fill('#password', 'pass');
  await page.click('#submit');
  await expect(page).toHaveURL('/dashboard');
});
```
```

## Best Practices

1. **Create a General Test Framework Skill**: Set up a skill in your home directory that applies to all projects unless overridden.

2. **Use CLAUDE.md for Project-Specific Preferences**: When working on a specific project, the CLAUDE.md file takes precedence and ensures consistency across team members.

3. **Document Your Framework in README.md**: Include testing setup instructions in your project documentation so Claude can reference them.

4. **Be Explicit in Prompt**: When it matters, explicitly state your preferred framework in your request to Claude.

## Conclusion

Claude Code is highly configurable when it comes to test frameworks. Whether you prefer Jest, Vitest, pytest, RSpec, or any other framework, you can ensure Claude uses your choice through custom skills, project-specific CLAUDE.md files, or explicit instructions. The key is to set up your preference once in a skill file, and Claude will remember your preference across sessions.

Start by creating a custom skill for your preferred test framework, and you'll never have to specify it again.
