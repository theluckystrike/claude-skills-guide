---

layout: default
title: "Best Way to Prompt Claude Code to Write Tests First"
description: "Learn effective prompts and skill patterns to get Claude Code to write tests before implementation using Test-Driven Development principles."
date: 2026-03-14
categories: [guides]
tags: [claude-code, testing, tdd, prompts, best-practices, claude-skills]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /best-way-to-prompt-claude-code-to-write-tests-first/
---


# Best Way to Prompt Claude Code to Write Tests First

Getting Claude Code to follow Test-Driven Development (TDD) principles requires clear, specific prompts that establish expectations upfront. This guide covers practical patterns for prompting Claude to write tests before diving into implementation.

## Why Test-First Matters with Claude Code

When working with Claude Code, the model has full context of your project and can make assumptions about what you want. Without explicit test-first guidance, Claude often generates implementation code first and may skip tests entirely or add them as an afterthought. This leads to:

- **Incomplete test coverage** — Core functionality gets tested, but edge cases are overlooked
- **Missed requirements** — Tests clarify what the code should do; skipping them means unclear specifications
- **Refactoring reluctance** — Without tests, you're hesitant to improve code later

By prompting Claude to write tests first, you get a clear specification of expected behavior, a safety net for refactoring, and better-designed code that satisfies testable requirements.

## The Core Prompt Pattern

The most effective approach uses a structured prompt that explicitly tells Claude to write tests before any implementation:

```
I want you to practice Test-Driven Development. For this task:

1. First, write failing tests that describe the expected behavior
2. Run the tests to confirm they fail
3. Then write the minimum code to make tests pass
4. Run tests again to verify success
5. Refactor if needed while keeping tests passing

Do not write implementation code until you have written the tests.
```

This pattern works because it explicitly orders the steps and prohibits implementation until tests exist. However, for specific scenarios, you'll want to tailor this further.

## Prompting for Unit Tests

For unit testing specific functions or classes, include details about the testing framework and expected behavior:

```
Create unit tests for the calculateShipping() function in src/shipping.js:

- Use Jest
- Test these cases: standard shipping (5 days), express shipping (2 days), overnight shipping (1 day), invalid destination, empty input
- Mock any external dependencies
- Include descriptive test names following the pattern: should_return_[expected]_when_[condition]

Write tests first, verify they fail, then implement the function.
```

The key elements here are:
- **Testing framework** — Specify Jest, Mocha, pytest, etc.
- **Test cases** — List specific scenarios to cover
- **Naming convention** — Guide test naming for consistency
- **Mocking guidance** — Address external dependencies upfront

## Prompting for Integration Tests

Integration tests require different prompting because they test how components work together:

```
Write integration tests for the user authentication flow:

1. Test successful login with valid credentials
2. Test failed login with wrong password (should return error message)
3. Test session persistence across page refreshes
4. Test logout clears session properly

Use the existing test infrastructure in tests/integration/. 
Write these tests BEFORE implementing any new authentication code.
Focus on testing the public API endpoints, not internal implementation details.
```

Integration tests benefit from focusing on the public API and expected outcomes rather than implementation specifics.

## Creating a Reusable TDD Skill

For consistent test-first behavior, create a Claude Code skill that encapsulates TDD best practices. Here's a skill that enforces writing tests first:

```yaml
---
name: tdd
description: "Practice Test-Driven Development: write failing tests first, then implement to make them pass"
  - Read
  - Write
  - Bash
max_turns: 15
---

When working on any code task, follow this TDD workflow:

## Step 1: Understand the Requirements
Before writing any code, read any existing relevant files to understand the context, existing patterns, and testing setup.

## Step 2: Write Failing Tests
1. Create or locate the test file (use {test_file_path})
2. Write tests that describe the expected behavior
3. Each test should fail because the implementation doesn't exist yet
4. Run the tests: {test_command} to confirm failures

## Step 3: Write Minimal Implementation
1. Write the minimum code needed to make tests pass
2. Do not add extra functionality beyond what tests require
3. Run tests to verify they pass

## Step 4: Refactor
1. If the implementation needs improvement, refactor while keeping tests passing
2. Do not add tests for refactored code unless you're adding new behavior

## Test Naming Convention
Use descriptive names: should_[expected behavior]_when_[condition]
Example: should_return_404_when_user_not_found

## Error Handling in Tests
- Test both success and failure cases
- Include edge cases: empty inputs, null values, boundary conditions
- Test error messages for failure scenarios

## Important Rules
- Never write implementation code before writing tests
- Never skip running tests to verify failures
- Never mark tests as pending or skip them
- Always confirm all tests pass before considering the task complete
```

With this skill loaded, you can simply say "Use TDD to add a function that validates email addresses" and Claude will follow the test-first pattern automatically.

## Prompting Edge Cases

### When You Already Have Some Implementation

If partial code exists, prompt Claude to first understand it, then write tests for new behavior:

```
The user service already has basic CRUD operations in src/userService.js.
I need to add email verification functionality.

First, read src/userService.js to understand the current structure.
Then write tests for the new verifyEmail() method covering:
- valid email format
- invalid email format
- email that doesn't exist in database
- successful verification

After tests fail (because verifyEmail doesn't exist yet), implement the method.
```

### When Tests Should Guide Implementation

Sometimes you want the tests to essentially write the specification:

```
Write comprehensive tests for a password reset feature that:
- Sends a reset link to the user's email
- Validates the reset token within 1 hour
- Allows password change with strong password requirements
- Logs the user in after successful password change

Do not implement anything yet—just write thorough tests. 
I'll review the tests first before you implement.
```

This approach uses tests as a specification document, catching requirements gaps early.

## Common Prompt Failures and Fixes

### Failure: "Write tests for this code"
This is too vague. Claude might write superficial tests that don't catch edge cases.

**Fix:** Specify exact test cases and scenarios to cover.

### Failure: "Make sure to test edge cases"
Without defining what edge cases mean for your specific domain, Claude may miss important scenarios.

**Fix:** List the edge cases explicitly in your prompt.

### Failure: "Add tests later"
This almost guarantees tests won't get written as priorities shift.

**Fix:** Make test-first a hard requirement in your prompt, not a suggestion.

## Best Practices Summary

1. **Be explicit about test-first** — Say "write tests before implementation" not "also write tests"
2. **Specify the testing framework** — Don't make Claude guess which framework to use
3. **List specific test cases** — Cover happy path, error cases, and edge cases
4. **Require test execution** — Ask Claude to run tests and show the failure output
5. **Create a TDD skill** — For consistent behavior across tasks, encapsulate the pattern in a reusable skill

By using these prompting strategies, you can reliably get Claude Code to write comprehensive tests before implementation, resulting in better-designed, more maintainable code with solid test coverage.

---

**Related guides:**

- [Advanced Claude Skills with Tool Use and Function Calling](/claude-skills-guide/advanced-claude-skills-with-tool-use-and-function-calling/) — Learn how to create skills with precise tool orchestration
- [Skill .md File Format Explained With Examples](/claude-skills-guide/skill-md-file-format-explained-with-examples/) — Create your own TDD skill using the full skill specification

**
## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike** — More at [zovo.one](https://zovo.one)
