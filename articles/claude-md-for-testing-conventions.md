---
layout: default
title: "CLAUDE.md for Testing Conventions (2026)"
description: "How to write CLAUDE.md rules for test structure, coverage requirements, mocking strategies, and assertion patterns that Claude Code follows consistently."
permalink: /claude-md-testing-conventions/
date: 2026-04-20
categories: [claude-md, patterns]
tags: [claude-md, testing, conventions, jest, pytest, claude-code]
last_updated: 2026-04-19
---

## The Problem with Claude's Default Tests

Without testing rules, Claude Code generates tests that pass but prove nothing. You get tests that assert `expect(result).toBeDefined()` instead of checking the actual value. You get tests that mock the function under test instead of its dependencies. You get a single happy-path test with no error cases.

CLAUDE.md fixes this by specifying exactly what a good test looks like in your project. Claude follows concrete testing rules reliably because they are verifiable -- either the test has an error case or it does not.

## Testing Rules Template (TypeScript / Jest)

```markdown
## Testing Standards

### Structure
- Test runner: Jest with ts-jest
- File naming: {module}.test.ts colocated with source file
- One describe() per module, nested describe() per method
- Use test() not it() — project convention
- Arrange-Act-Assert pattern with blank line separators

### Coverage Requirements
- Every public function: minimum 1 happy path + 1 error path test
- Every API endpoint: test 200, 400, 401, 404 responses
- Every database repository method: test with actual database (test container)
- Edge cases: empty input, null values, boundary values, concurrent access

### Mocking Rules
- Mock external services (HTTP clients, third-party APIs)
- Mock time-dependent operations (use jest.useFakeTimers)
- NEVER mock the function under test
- NEVER mock internal utility functions — test them through their callers
- Database: use test containers, not mocks. Prisma with SQLite for unit tests.
- Reset all mocks in afterEach: jest.restoreAllMocks()

### Assertions
- Assert specific values, not just type or existence
- NEVER use expect(result).toBeDefined() as the only assertion
- NEVER use expect(result).toBeTruthy() for non-boolean values
- Use toEqual for objects, toBe for primitives
- Error assertions: expect(result.error).toBeInstanceOf(SpecificError)
- Snapshot tests: only for serialized output (API responses, HTML). Never for logic.
```

## Testing Rules Template (Python / pytest)

```markdown
## Testing Standards

### Structure
- Test runner: pytest with pytest-asyncio
- File naming: test_{module}.py in tests/ directory mirroring src/ structure
- One class per module: TestUserService, TestOrderRepository
- Fixtures over setup/teardown — define in conftest.py

### Coverage Requirements
- Every public function: minimum 1 happy path + 1 error path
- Every API endpoint: test status codes 200, 400, 401, 404, 422
- Parametrize edge cases: @pytest.mark.parametrize for input variations

### Mocking Rules
- Mock external HTTP calls with responses library
- Mock filesystem with tmp_path fixture
- NEVER mock the function under test
- Database: use test database with transaction rollback per test
- Time: use freezegun for time-dependent tests

### Assertions
- Assert specific return values, not just truthiness
- Use pytest.raises(SpecificException) with match parameter
- Compare dicts with == operator for clear diff output
- Assert database state after mutations — query and verify
```

## File-Specific Test Rules

Use `.claude/rules/` to apply different testing standards to different areas:

```markdown
# .claude/rules/test-standards.md
---
paths:
  - "**/*.test.ts"
  - "**/*.spec.ts"
  - "tests/**/*.py"
---

## Test-Specific Rules
- No production imports in test helpers — keep test utilities in tests/helpers/
- Test data factories in tests/factories/ — deterministic, not random
- Async tests: always await assertions, never fire-and-forget
- Timeout: 10 seconds per test maximum. If longer, the test is doing too much.
- No console.log in tests — use test reporter for debugging output
```

## Integration Test Conventions

```markdown
## Integration Tests (tests/integration/)
- Start test database from docker-compose.test.yml
- Run migrations before test suite, rollback after each test
- Test the full request/response cycle through the HTTP layer
- Seed test data with factory functions, never rely on persistent test data
- Clean up: remove created resources in afterEach, not afterAll
- Parallel safe: each test uses unique identifiers, no shared state
```

## Making Claude Write Better Tests

The most effective instruction for test quality is negative -- telling Claude what NOT to do:

```markdown
## Test Anti-Patterns (NEVER generate these)
- Tests that only check .toBeDefined() or .toBeTruthy()
- Tests where the mock returns the expected value (circular logic)
- Tests with no assertions (test passes by not throwing)
- Tests that depend on execution order
- Tests that share mutable state across test cases
- Commented-out test cases
```

When Claude generates a test, verify it against these rules. If it produces a test that only asserts `.toBeDefined()`, the rule was likely too far down in a file exceeding 200 lines.

For general coding standards that complement testing conventions, see the [coding standards enforcement guide](/claude-md-for-coding-standards-enforcement/). For the error handling patterns your tests should verify, see the [error handling guide](/claude-md-error-handling-patterns/). For the complete CLAUDE.md writing guide, see the [best practices documentation](/claude-code-claude-md-best-practices/).

## See Also

- [CLAUDE.md for Database Conventions — Schema, Queries, and Migration Rules (2026)](/claude-md-database-conventions/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.




**Build yours →** Create a custom CLAUDE.md with our [Generator Tool](/generator/).

## Related Guides

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [CLAUDE.md for Database Conventions](/claude-md-database-conventions/)
- [Claude Skill Naming Conventions](/claude-skill-naming-conventions/)
- [Claude Md For Database Conventions](/claude-md-for-database-conventions-and-patterns/)
- [Make Claude Code Match Team Conventions](/claude-code-doesnt-match-team-conventions-fix-2026/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>
