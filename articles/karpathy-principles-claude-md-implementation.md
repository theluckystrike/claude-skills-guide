---
layout: default
title: "Karpathy's 4 Principles in Your CLAUDE.md (2026)"
description: "Translate Andrej Karpathy's vibe coding principles into concrete CLAUDE.md sections. Be explicit, test everything, iterate fast with Claude Code."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /karpathy-principles-claude-md-implementation/
reviewed: true
categories: [best-practices]
tags: [claude, claude-code, claude-md, karpathy, vibe-coding, best-practices]
---

# Karpathy's 4 Principles in Your CLAUDE.md

Andrej Karpathy distilled effective AI-assisted coding into four principles: vibe code with intent, be explicit about what you want, test everything the AI produces, and iterate fast on feedback loops. These principles sound simple, but most developers never encode them into their CLAUDE.md -- leaving Claude to guess at the standards that should be non-negotiable. Here's how to translate each principle into concrete CLAUDE.md blocks that make Claude Code follow them automatically. Start with the [CLAUDE.md Generator](/generator/) for the base structure, then layer these principle-driven sections on top.

## Principle 1: Vibe Code with Intent

Karpathy's first principle is about working at the right abstraction level. You describe the outcome, not the implementation. But "vibe coding" without guardrails produces inconsistent results. The CLAUDE.md fix is an explicit intent section that tells Claude your preferred level of abstraction:

```markdown
# Intent-Driven Development
When I describe a feature, implement the full working version:
- Include error handling for all edge cases
- Add TypeScript types for all function signatures
- Write the test file alongside the implementation
- Use existing patterns from /src as reference

When I say "quick prototype" or "sketch this out":
- Skip error handling beyond basic try/catch
- Use `any` types where inference is complex
- No tests needed
- Console.log is acceptable for debugging

Default mode: full implementation (not prototype)
```

This block eliminates the ambiguity that causes Claude to produce half-finished code or over-engineered prototypes. The "default mode" line is critical -- without it, Claude will ask which mode you want on every request.

## Principle 2: Be Explicit About What You Want

The second principle attacks the root cause of most AI coding failures: vague instructions. Your CLAUDE.md should encode every convention that you'd otherwise need to state in each prompt:

```markdown
# Explicit Standards
## Naming
- Files: kebab-case (user-profile.ts, not userProfile.ts)
- Functions: camelCase, verb-first (getUserById, not userGet)
- Types/Interfaces: PascalCase, noun (UserProfile, not IUserProfile)
- Constants: UPPER_SNAKE_CASE
- Database columns: snake_case

## Error Handling
- Never swallow errors with empty catch blocks
- Use custom error classes from /src/errors
- API routes return { error: string, code: string } on failure
- Log errors with structured context: { userId, action, error }

## Imports
- Absolute imports via @/ alias (never relative paths beyond ../)
- Group: external libs → internal modules → types → styles
- No barrel files (index.ts re-exports) -- import directly
```

Each rule prevents a specific class of correction. Without the naming section, Claude alternates between camelCase and kebab-case for files. Without the error handling rules, Claude produces `catch (e) {}` blocks that silently swallow failures. Without import rules, you get a mix of `../../utils` and `@/utils` in the same file.

## Principle 3: Test Everything the AI Produces

Karpathy's third principle is the safety net. Claude Code can run tests, but only if your CLAUDE.md tells it when and how:

```markdown
# Testing Requirements
## When to Test
- Every new function that contains business logic
- Every bug fix (write the failing test FIRST, then fix)
- Every API endpoint (integration test with supertest)
- Skip tests for: pure UI components, config files, types

## How to Test
- Framework: Vitest
- Run: `pnpm vitest run --reporter=verbose`
- Location: co-located (user-service.test.ts next to user-service.ts)
- Pattern: Arrange-Act-Assert with descriptive test names
- Mocking: use vi.mock() for external services, never mock internal modules

## Test Quality Rules
- No test should depend on another test's state
- No network calls in unit tests
- Assert specific values, not just truthiness
- Minimum: happy path + one error path per function
```

This section turns testing from an afterthought into an automatic part of every Claude Code output. The "When to Test" subsection is especially important because it prevents Claude from generating test files for trivial code while ensuring critical logic is always covered.

## Principle 4: Iterate Fast on Feedback Loops

The fourth principle is about speed. Long build times, slow test suites, and complex deployment processes kill the feedback loop. Your CLAUDE.md should encode the fast paths:

```markdown
# Fast Iteration
## Quick Checks (run after every change)
- Type check: `pnpm tsc --noEmit` (< 5 seconds)
- Lint: `pnpm eslint --fix .` (< 3 seconds)
- Related tests: `pnpm vitest run --reporter=verbose {changed_file}`

## Before Committing
- Full test suite: `pnpm vitest run`
- Build check: `pnpm build`

## Debugging Workflow
1. Reproduce the issue with a failing test
2. Fix the code
3. Verify the test passes
4. Run related test files to check for regressions

Never debug by reading code and guessing -- always reproduce first.
```

The "Quick Checks" block tells Claude to run lightweight validation after every change instead of waiting for a full CI cycle. The debugging workflow prevents Claude from making speculative fixes -- a common failure mode where Claude modifies 5 files based on a theory instead of writing a test that proves the bug exists.

## Putting It All Together

Combine all four principle blocks with your project-specific context. Use the [CLAUDE.md Generator](/generator/) to create the project overview, commands, and architecture sections, then append these four principle blocks. A complete CLAUDE.md with Karpathy's principles typically runs 120-180 lines -- well within the sweet spot for context efficiency.

The result is a Claude Code session where the AI writes code at the right abstraction level, follows your exact conventions, tests its own output, and validates changes quickly. Each principle reinforces the others: explicit standards make testing easier, fast iteration makes being explicit cheaper, and intent-driven development keeps the whole system focused on outcomes.

## Try It Yourself

Encode these principles into your own CLAUDE.md. The [CLAUDE.md Generator](/generator/) gives you the structural foundation -- project overview, architecture map, commands -- and you add the principle-driven sections from this article. The combination of generated structure and Karpathy-inspired rules produces a CLAUDE.md that makes Claude Code behave like a senior engineer who already knows your codebase.

<details>
<summary>Do I need all four principles in my CLAUDE.md?</summary>
Start with Principle 2 (Be Explicit) -- it delivers the most value per line. Add Principle 3 (Test Everything) next if you have a test framework set up. Principles 1 and 4 are refinements that matter more as your CLAUDE.md matures.
</details>

<details>
<summary>How do these principles interact with the /model command?</summary>
Use the /model command to switch between Claude models based on task complexity. Opus handles Principle 1 (intent-driven) best for complex architecture decisions. Sonnet handles Principles 2-4 efficiently for standard implementation, testing, and iteration. See the <a href="/model-selector/">Model Selector</a> for task-based recommendations.
</details>

<details>
<summary>Will these principles slow Claude down?</summary>
The opposite. Without explicit standards, Claude spends tokens asking clarifying questions or producing code you'll reject. With these principles encoded, first-attempt accuracy goes from roughly 60% to 85-90%, which means fewer round-trips and faster overall sessions.
</details>

<details>
<summary>Can I use these principles with Cursor or Copilot instead?</summary>
The concepts translate to any AI coding tool. For Cursor, encode them in .cursorrules. For Copilot, use .github/copilot-instructions.md. The syntax differs but the principle-driven structure works the same way.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need all four Karpathy principles in my CLAUDE.md?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Start with Principle 2 (Be Explicit) -- it delivers the most value per line. Add Principle 3 (Test Everything) next if you have a test framework set up. Principles 1 and 4 are refinements that matter more as your CLAUDE.md matures."
      }
    },
    {
      "@type": "Question",
      "name": "How do these principles interact with the /model command?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Use the /model command to switch between Claude models based on task complexity. Opus handles intent-driven tasks best for complex architecture decisions. Sonnet handles standard implementation, testing, and iteration efficiently. Use the Model Selector for task-based recommendations."
      }
    },
    {
      "@type": "Question",
      "name": "Will encoding these principles in CLAUDE.md slow Claude down?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The opposite. Without explicit standards, Claude spends tokens asking clarifying questions or producing code you'll reject. With these principles encoded, first-attempt accuracy goes from roughly 60% to 85-90%, which means fewer round-trips and faster overall sessions."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use these principles with Cursor or Copilot instead of Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The concepts translate to any AI coding tool. For Cursor, encode them in .cursorrules. For Copilot, use .github/copilot-instructions.md. The syntax differs but the principle-driven structure works the same way."
      }
    }
  ]
}
</script>



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

- [CLAUDE.md Generator](/generator/) -- Build your principle-driven CLAUDE.md automatically
- [Claude Code Best Practices](/best-practices/) -- Production patterns for Claude Code
- [Claude Code Commands Reference](/commands/) -- Every command in Claude Code
- [Model Selector](/model-selector/) -- Pick the right Claude model for each task
- [Advanced Claude Code Usage](/advanced-usage/) -- Power user techniques
