---
title: "Make Claude Code Write Tests First"
description: "Configure Claude Code for test-driven development with CLAUDE.md rules that enforce red-green-refactor and test-before-implementation ordering."
permalink: /claude-code-write-tests-first-tdd-setup-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Make Claude Code Write Tests First (TDD) (2026)

Claude Code writes implementation first and tests as an afterthought. For TDD practitioners, this is backwards. Here's how to enforce test-first development.

## The Problem

Given "add email validation to the signup endpoint," Claude Code:
1. Writes the validation logic
2. Writes tests that pass against the implementation
3. Tests mirror the code rather than driving design

The tests become documentation of what was built, not specifications of what should be built.

## Root Cause

Claude Code's default behavior optimizes for "task completion" — write code that works. TDD's red-green-refactor cycle adds steps (write failing test, then implement). Without explicit rules, the agent skips the "failing test" phase.

## The Fix

```markdown
## TDD Protocol (Mandatory)

### Ordering
1. Write the test FIRST (it must fail)
2. Run the test — confirm it FAILS
3. Write the MINIMUM implementation to make it pass
4. Run the test — confirm it PASSES
5. Refactor if needed (tests must still pass)
6. Repeat for next test case

### Rules
- NEVER write implementation before a test exists for it
- Each test must fail before its corresponding implementation
- Run tests after EVERY code change (implementation and refactoring)
- Test file must be created BEFORE the implementation file for new features

### Test Structure
- Test names describe expected behavior, not implementation
- BAD: "test_validateEmail_function"
- GOOD: "rejects emails without @ symbol"
```

## CLAUDE.md Rule to Add

```markdown
## Test-First Requirement
For any code change that adds or modifies behavior:
1. Write/update the test file FIRST
2. Run tests — show me the failure
3. Then write the implementation
4. Run tests — show me the pass

If you catch yourself writing implementation before tests, STOP,
delete the implementation, write the test, then re-implement.
```

## Verification

```
Add a function that calculates shipping cost based on weight and destination
```

**Non-TDD response:** writes `calculateShipping()`, then writes tests
**TDD response:** writes `calculateShipping.test.ts` with 4 failing test cases, runs them (all fail), then implements `calculateShipping()`, runs again (all pass)

For a more robust TDD setup, consider [SuperClaude's TDD mode](/superclaude-framework-guide-2026/) which automates the cycle enforcement.

Related: [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/) | [The Claude Code Playbook](/playbook/) | [Claude Code Hooks Explained](/understanding-claude-code-hooks-system-complete-guide/)

## See Also

- [Claude Code Write Path Outside Workspace — Fix (2026)](/claude-code-write-tool-path-outside-workspace-fix-2026/)
- [Claude Code Tab Completion Setup Guide 2026](/claude-code-tab-completion-setup-2026/)
- [How to Set Up Claude Code in Ghostty Terminal 2026](/claude-code-ghostty-terminal-setup-2026/)
- [Set Up Claude Code in Dev Containers 2026](/claude-code-dev-containers-setup-2026/)
- [Claude Code + WebStorm JetBrains Setup 2026](/claude-code-webstorm-jetbrains-setup-2026/)
