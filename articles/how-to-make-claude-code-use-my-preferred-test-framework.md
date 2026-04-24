---
layout: default
title: "How To Make Claude Code Use My"
description: "Learn how to configure Claude Code to use your preferred testing framework with practical examples and custom skill configurations."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [tutorials]
tags: [claude-code, testing, test-frameworks, configuration, skills, claude-skills]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /how-to-make-claude-code-use-my-preferred-test-framework/
geo_optimized: true
---
One of the most common questions developers have when working with Claude Code is: "How can I make Claude use my preferred test framework instead of the default?" Whether you're team Jest, pytest, RSpec, or any other testing framework, Claude Code is flexible enough to adapt to your workflow. This guide walks you through multiple methods to configure Claude Code to use your preferred test framework, covering everything from one-off inline instructions to persistent global skills that apply across every project you work on.

## Understanding How Claude Code Selects Test Frameworks

Claude Code automatically detects test frameworks based on your project's dependencies and configuration files. When you ask Claude to write tests, it scans for:

- `package.json`. looks for Jest, Vitest, or Mocha in `devDependencies`
- `pyproject.toml` or `requirements.txt`. looks for pytest or unittest
- `Gemfile`. looks for RSpec
- `go.mod`. looks for the standard `testing` package or `testify`
- Framework-specific config files (`jest.config.js`, `vitest.config.ts`, `pytest.ini`, `.rspec`, etc.)

Claude uses this detected context to make a best-guess choice. If your project has both `jest` and `vitest` in `package.json`, Claude may pick the wrong one. If there is no config file at all, say, you're starting a new service from scratch, Claude will fall back to whatever framework it considers standard for the language.

The good news is that you can override this detection at several levels, from global preferences to per-project rules to single-prompt instructions. Understanding which level to use for which situation is the key to a smooth workflow.

## Method 1: Using Custom Skills to Set Your Preferred Framework

The most powerful and persistent approach is creating a custom skill that tells Claude exactly which test framework to use. Skills are Markdown files placed in `~/.claude/skills/` (or `~/.claude/` directly) that guide Claude's behavior whenever they are active.

A skill file for pytest might look like this:

Create `~/.claude/skills/pytest-preferred.md`:

```markdown
Test Framework Preference Skill

When asked to write tests, ALWAYS use pytest unless explicitly told otherwise.
Never default to unittest.TestCase. Never write tests without fixtures if shared
state is needed.

Preferred Test Framework: pytest

- Use pytest for all Python testing
- Use pytest fixtures for test setup and teardown, defined in conftest.py
- Write tests using plain assert statements (not self.assert*)
- Use pytest.mark decorators for test categorization (unit, integration, slow)
- Follow the test_*.py naming convention for all test files
- Use pytest-asyncio for async tests with @pytest.mark.asyncio

Example Test Structure

```python
import pytest
from mypackage.users import create_user, UserAlreadyExistsError

@pytest.fixture
def sample_payload():
 return {"name": "Alice", "email": "alice@example.com"}

def test_create_user_returns_id(sample_payload):
 user = create_user(sample_payload)
 assert user["id"] is not None

def test_create_user_raises_on_duplicate(sample_payload):
 create_user(sample_payload)
 with pytest.raises(UserAlreadyExistsError):
 create_user(sample_payload)

@pytest.mark.parametrize("email", ["", None, "not-an-email"])
def test_create_user_rejects_invalid_email(email, sample_payload):
 sample_payload["email"] = email
 with pytest.raises(ValueError):
 create_user(sample_payload)
```

Always explain which cases are covered after writing tests.
```

Activate this skill at the start of any Claude Code session:

```
/pytest-preferred
```

From that point forward, Claude will use pytest for every test-writing task in the session, regardless of what it detects in your project files. The skill acts as a persistent preference that overrides Claude's automatic detection.

## Stacking Skills

You can combine skills. If your project uses FastAPI with pytest and you want Claude to follow async testing patterns, activate both skills:

```
/pytest-preferred
/fastapi-async
```

Claude merges the context from all active skills, so you can build a layered preference system without duplicating content across skill files.

## Method 2: Project-Specific Configuration with CLAUDE.md

For project-specific test framework preferences, create a `CLAUDE.md` file in your project root. Claude Code reads this file automatically whenever it is working within that directory tree, no manual activation required.

```markdown
Project Context. payments-service

Test Framework
This project uses Vitest for all testing, NOT Jest.
Do not generate Jest-style tests. Do not import from `jest` or use `jest.fn()`.

Testing Rules
- Write unit tests in `src/__tests__/`
- Write integration tests in `tests/integration/`
- Use Vitest's `describe`, `it`, and `expect` syntax
- Use `vi.fn()` for mocks and `vi.mock()` for module mocking
- Run unit tests with `npm run test:unit` or `npx vitest`
- Run all tests including integration with `npx vitest run`
- Include coverage reports with `npx vitest --coverage`
- Target 80% line coverage for all new modules

Test File Naming
- Unit tests: `ComponentName.test.ts`
- Integration tests: `feature.integration.test.ts`
- E2E tests: `flow.e2e.test.ts` (Playwright, not Vitest)
```

Now whenever Claude Code works in this project, it reads `CLAUDE.md` and automatically uses Vitest for all unit and integration testing tasks. Team members who clone the repository get the same behavior, the `CLAUDE.md` file commits to version control along with the rest of the codebase, making test framework preferences part of the project's documented standards.

CLAUDE.md vs Skills: Which Wins?

When both a `CLAUDE.md` file and an active skill specify a test framework, the `CLAUDE.md` file takes precedence for project-specific concerns. Think of it this way: your global skill says "I generally prefer pytest," but the project's `CLAUDE.md` says "this specific project uses unittest for legacy reasons." Claude respects the project-level override.

## Method 3: Inline Instructions for One-Off Testing

Sometimes you just need to override the default for a single request without changing any configuration. Simply specify your preferred framework in the prompt:

```
Write unit tests for the user authentication module.
Use Mocha with Chai assertions, not Jest. Structure them
with describe/it blocks and use chai's expect interface.
```

Claude will follow your explicit instruction and use Mocha with Chai for that specific task, then revert to its default behavior for subsequent requests. This is the right approach when you are working in someone else's repository, exploring an unfamiliar framework, or generating a quick proof of concept.

For multi-turn sessions where you want the preference to persist beyond a single message, start the session with a clear statement:

```
For this entire session, write all tests using pytest with the
pytest-bdd plugin. Use Gherkin-style Given/When/Then structure.
```

Claude will maintain this preference across subsequent messages in the same conversation.

## Method 4: Configuring Test Framework in Project Files

Many testing frameworks can be configured in project files that Claude will automatically detect. Establishing an explicit configuration file serves two purposes: it configures the framework's runtime behavior, and it signals to Claude which framework the project uses.

For JavaScript/TypeScript Projects (Vitest)

```javascript
// vitest.config.ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
 test: {
 environment: 'node',
 coverage: {
 provider: 'v8',
 reporter: ['text', 'json', 'html'],
 thresholds: {
 lines: 80,
 functions: 80,
 branches: 70,
 }
 },
 include: ['src//*.test.ts'],
 exclude: ['node_modules', 'dist'],
 globals: false,
 }
})
```

When Claude sees `vitest.config.ts`, it will default to Vitest for all test generation in that project without needing any explicit instruction.

For Python Projects (pytest)

```toml
pyproject.toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "-v --strict-markers --tb=short"
markers = [
 "unit: Unit tests (fast, no I/O)",
 "integration: Integration tests (may hit DB or network)",
 "slow: Tests that take more than 2 seconds",
]
asyncio_mode = "auto"
```

Claude reads `pyproject.toml` to understand the project's testing conventions. The presence of `[tool.pytest.ini_options]` is a strong signal to use pytest.

For Ruby Projects (RSpec)

```ruby
.rspec
--require spec_helper
--format documentation
--color
--order random

spec/spec_helper.rb
RSpec.configure do |config|
 config.expect_with :rspec do |expectations|
 expectations.include_chain_clauses_in_custom_types = true
 end
 config.mock_with :rspec do |mocks|
 mocks.verify_partial_doubles = true
 end
 config.shared_context_metadata_behavior = :apply_to_host_groups
end
```

For Go Projects (testify)

If you prefer `testify` over the standard `testing` package assertions, add a comment to your `CLAUDE.md` and Claude will adapt:

```markdown
Testing (Go)
Use `github.com/stretchr/testify/assert` and `testify/require` for all assertions.
Do not use raw `t.Error` or `t.Fatal` calls directly.
Structure tests as table-driven tests where multiple scenarios exist.
```

## Practical Examples

## Example 1: Switching from Jest to Vitest

You have a JavaScript project but prefer Vitest's faster performance and native ESM support. Create `~/.claude/skills/vitest.md`:

```markdown
Vitest Preference Skill

Always use Vitest for JavaScript/TypeScript testing in this project.
Never import from `@jest/globals` or use Jest-specific APIs.

When writing tests:
1. Import from `vitest`: `import { describe, it, expect, vi, beforeEach } from 'vitest'`
2. Use `vi.fn()` for mocks (not `jest.fn()`)
3. Use `vi.mock('module-path')` for module mocking
4. Use `vi.spyOn(object, 'method')` for spies
5. Run tests with `npx vitest` (watch mode) or `npx vitest run` (CI mode)
6. For async tests, use `async/await` with `expect(promise).resolves` or `rejects`

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { fetchUser } from './api'
import * as http from './http'

describe('fetchUser', () => {
 beforeEach(() => {
 vi.clearAllMocks()
 })

 it('returns user data on success', async () => {
 vi.spyOn(http, 'get').mockResolvedValue({ id: 1, name: 'Alice' })
 const user = await fetchUser(1)
 expect(user.name).toBe('Alice')
 })

 it('throws on network error', async () => {
 vi.spyOn(http, 'get').mockRejectedValue(new Error('timeout'))
 await expect(fetchUser(1)).rejects.toThrow('timeout')
 })
})
```
```

## Example 2: Using Playwright for E2E Testing

If you want Claude to use Playwright instead of Cypress for end-to-end testing, add to your `CLAUDE.md` or a dedicated skill:

```markdown
Playwright E2E Testing

For end-to-end testing, ALWAYS use Playwright. Do not suggest Cypress.

- Import from `@playwright/test`
- Use `test` and `expect` from Playwright's test runner
- Use `page.getByRole()`, `page.getByLabel()`, and `page.getByTestId()` for element selection
 (prefer these over CSS selectors or XPath)
- Use `page.locator()` only when semantic selectors are not available
- Configure browsers and base URL in `playwright.config.ts`
- Run tests with `npx playwright test`
- For CI, run `npx playwright test --reporter=github`

Example test structure:
```typescript
import { test, expect } from '@playwright/test';

test.describe('authentication flow', () => {
 test('user can log in with valid credentials', async ({ page }) => {
 await page.goto('/login');
 await page.getByLabel('Email').fill('user@example.com');
 await page.getByLabel('Password').fill('securepassword');
 await page.getByRole('button', { name: 'Sign in' }).click();
 await expect(page).toHaveURL('/dashboard');
 await expect(page.getByRole('heading', { name: 'Welcome' })).toBeVisible();
 });

 test('shows error on invalid credentials', async ({ page }) => {
 await page.goto('/login');
 await page.getByLabel('Email').fill('user@example.com');
 await page.getByLabel('Password').fill('wrongpassword');
 await page.getByRole('button', { name: 'Sign in' }).click();
 await expect(page.getByText('Invalid credentials')).toBeVisible();
 });
});
```
```

## Example 3: pytest-bdd for Behavior-Driven Development

If your team uses BDD and wants Claude to write tests in Gherkin format with pytest-bdd:

```markdown
pytest-bdd Preference

Write all acceptance tests using pytest-bdd with Gherkin feature files.

Structure:
- Feature files in `features/` directory with `.feature` extension
- Step definitions in `tests/step_defs/` with `test_*.py` naming
- Use `@given`, `@when`, `@then` decorators from `pytest_bdd`
- Run with `pytest tests/step_defs/`

Feature file example:
```gherkin
Feature: User Registration

 Scenario: Successful registration with valid email
 Given the registration form is open
 When the user submits email "alice@example.com" and password "Str0ng!"
 Then the user account is created
 And a confirmation email is sent to "alice@example.com"
```

Step definitions example:
```python
from pytest_bdd import given, when, then, scenario
from pytest_bdd import parsers

@scenario('features/registration.feature', 'Successful registration with valid email')
def test_registration():
 pass

@given("the registration form is open")
def registration_form(client):
 return client.get('/register')

@when(parsers.parse('the user submits email "{email}" and password "{password}"'))
def submit_registration(client, email, password):
 client.post('/register', data={"email": email, "password": password})
```
```

## Framework Comparison: When to Use What

| Framework | Language | Best For | Claude Activation |
|-----------|----------|----------|-------------------|
| pytest | Python | All Python projects | `pyproject.toml` or skill |
| unittest | Python | Legacy codebases | Inline instruction |
| Jest | JS/TS | React projects (CRA) | `jest.config.js` |
| Vitest | JS/TS | Vite projects, ESM | `vitest.config.ts` |
| Mocha + Chai | JS/TS | Node.js APIs | `.mocharc.yml` + skill |
| RSpec | Ruby | Rails, Ruby gems | `Gemfile` + `.rspec` |
| Playwright | Any | E2E browser testing | `playwright.config.ts` |
| Cypress | JS/TS | E2E (legacy choice) | `cypress.config.ts` |
| Go testing | Go | Standard Go | Inline or CLAUDE.md |
| testify | Go | Go with assertions | `go.mod` + CLAUDE.md |

## Troubleshooting: When Claude Picks the Wrong Framework

If Claude is still generating tests with the wrong framework despite your configuration, work through this checklist:

1. Check for conflicting config files. If both `jest.config.js` and `vitest.config.ts` exist in the project root, Claude is confused. Remove the unused one.

2. Verify skill activation. Skills are not automatically active, they must be invoked. Run `/skill-name` at the start of each session.

3. Be explicit in the first message. Start your conversation with "For all tests in this session, use [framework]" before asking Claude to write any code.

4. Check CLAUDE.md location. The file must be in the project root (the directory where you started Claude Code), not a subdirectory.

5. Inspect your CLAUDE.md content. Make sure the framework preference is stated clearly and without ambiguity. "We use Vitest" is clearer than "We have Vitest installed."

## Best Practices

1. Create a global test framework skill for your primary language and keep it in `~/.claude/skills/`. This is your default across all projects unless overridden.

2. Use CLAUDE.md for project-specific preferences and commit it to version control. This ensures consistent behavior for every team member and every CI run that invokes Claude Code.

3. Document your framework in README.md alongside setup instructions. Claude can reference README content as supplementary context.

4. Be explicit when it matters. For one-off tasks or unfamiliar repos, state your framework preference directly in the prompt rather than relying on detection.

5. Test the configuration early. At the start of a new project or after adding a `CLAUDE.md`, ask Claude: "Which test framework will you use for this project?" to confirm it has picked up the right context before writing hundreds of lines of tests.

6. Keep skill files focused. A skill for pytest should cover pytest-specific conventions, not general Python style. Smaller, focused skills compose more reliably than large monolithic ones.

## Conclusion

Claude Code is highly configurable when it comes to test frameworks. Whether you prefer Jest, Vitest, pytest, RSpec, Playwright, or any other framework, you can ensure Claude uses your choice through custom skills, project-specific `CLAUDE.md` files, or explicit inline instructions. The layered configuration system means your global preferences apply everywhere unless a project-level override exists, and project-level overrides apply everywhere unless you override them per-prompt.

The most reliable setup is: a global skill file for your preferred framework per language, a `CLAUDE.md` in each project that confirms or overrides that preference, and clear framework-specific config files (`vitest.config.ts`, `pyproject.toml`, etc.) that Claude can detect automatically.

Start by creating a custom skill for your preferred test framework, and you'll never have to specify it again.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=how-to-make-claude-code-use-my-preferred-test-framework)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Evals Framework Workflow Tutorial](/claude-code-for-evals-framework-workflow-tutorial/)
- [Claude TDD Skill: Test-Driven Development Guide (2026)](/claude-tdd-skill-test-driven-development-workflow/)
- [How Do I Test a Claude Skill Before Deploying to Team](/how-do-i-test-a-claude-skill-before-deploying-to-team/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


