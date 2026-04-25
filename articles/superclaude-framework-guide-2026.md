---
layout: default
title: "SuperClaude Framework (2026)"
description: "Install SuperClaude's 30 slash commands, 16 agents, and 7 behavioral modes — the most feature-rich Claude Code framework at 22K stars."
permalink: /superclaude-framework-guide-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# SuperClaude Framework: 30 Commands Guide (2026)

SuperClaude by SuperClaude-Org (22K+ stars) is the most opinionated Claude Code framework available. It ships 30 slash commands, 16 specialized agents, and 7 behavioral modes — all installed with a single `pipx` command. If you want Claude Code to behave like a full engineering team, this is the framework.

## What It Is

A Python package that installs a structured system of:

- **30 Slash Commands** (`/sc:pm`, `/sc:implement`, `/sc:test`, `/sc:review`, `/sc:deploy`, etc.) — each triggers a different workflow with specialized prompting
- **16 Agents** — pre-configured behavioral profiles for roles like project manager, implementer, tester, security auditor, and DevOps engineer
- **7 Behavioral Modes** — toggleable modes like `strict`, `creative`, `review`, `tdd`, `pair`, `teach`, and `silent` that change how Claude Code responds

The framework installs as `.claude/commands/` and `.claude/` configuration files in your project.

## Why It Matters

Claude Code out of the box is a generalist. It writes code, reviews code, and manages files — but it doesn't switch mental models between tasks. Asking it to review code and then implement a feature uses the same behavioral pattern for both.

SuperClaude assigns distinct behavioral profiles to distinct tasks. When you type `/sc:review`, Claude Code enters code-reviewer mode with specific criteria, severity levels, and output formats. When you type `/sc:implement`, it switches to builder mode with different constraints. This role-switching produces markedly better output than using a single behavioral profile for everything.

## Installation

### Via pipx (Recommended)

```bash
pipx install superclaude
superclaude install
```

### In a Specific Project

```bash
cd /path/to/your/project
superclaude install --project
```

This creates the full `.claude/` directory structure with all commands, agents, and mode configurations.

### Verify Installation

```bash
superclaude doctor
```

Output should show all 30 commands, 16 agents, and 7 modes as installed and compatible with your Claude Code version.

## Key Features

1. **/sc:pm (Project Manager)** — generates project plans, breaks features into tasks, estimates complexity. Pairs with [Task Master](/claude-task-master-setup-guide-2026/) for persistence.

2. **/sc:implement** — switches to implementation mode. Claude Code follows the project's coding standards, writes code in small increments, and runs tests after each change.

3. **/sc:test** — generates test suites. Supports TDD mode where tests are written before implementation.

4. **/sc:review** — formal code review with severity levels (critical, warning, nit), categorized feedback (security, performance, style, logic), and an approval/request-changes verdict.

5. **/sc:deploy** — deployment checklist generation, pre-deploy verification, and post-deploy smoke test coordination.

6. **/sc:refactor** — targeted refactoring with before/after diffs, preserving existing test coverage.

7. **/sc:security** — security audit focusing on OWASP Top 10, dependency vulnerabilities, secrets exposure, and authentication/authorization flaws.

8. **7 Behavioral Modes** — `strict` enforces zero tolerance for warnings; `creative` allows exploratory solutions; `tdd` requires tests before code; `pair` simulates pair programming with explanations; `teach` adds educational context to every action.

## Real Usage Example

### Running a Code Review

```
You: /sc:review src/auth/login.ts

Claude Code: [Entering review mode]

## Code Review: src/auth/login.ts

### Critical (1)
- **Line 34**: Password comparison uses `===` instead of timing-safe
  comparison. Vulnerable to timing attacks.
  Fix: Use `crypto.timingSafeEqual()` after converting to buffers.

### Warning (2)
- **Line 12**: No rate limiting on login attempts. Brute force possible.
- **Line 45**: Error message reveals whether email exists ("Invalid password"
  vs "User not found"). Information disclosure risk.

### Nit (1)
- **Line 8**: Import `bcrypt` is unused after line 30's refactor to argon2.

### Verdict: REQUEST CHANGES
1 critical issue must be resolved before merge.
```

### Switching Modes Mid-Session

```
You: /sc:mode tdd

Claude Code: [TDD mode active]
I will now write failing tests before any implementation.
All code changes require a corresponding test.
Green-red-refactor cycle enforced.

You: Add email validation to the registration endpoint

Claude Code: Starting with the test:

// test/registration.test.ts
describe('registration email validation', () => {
  it('rejects emails without @ symbol', async () => {
    const res = await request(app).post('/register').send({
      email: 'invalid-email', password: 'Str0ng!Pass'
    });
    expect(res.status).toBe(400);
    expect(res.body.error).toContain('valid email');
  });
  // ... 4 more test cases
});

Running tests... 5 FAILING (expected — no implementation yet)
Now implementing the validation...
```

### Agent Selection

```
You: /sc:agent security-auditor

Claude Code: [Security Auditor agent active]
Behavioral profile:
- Treat all user input as hostile
- Check every dependency against known CVE databases
- Flag any secret or credential in source code
- Verify authentication on every endpoint
- Report findings in OWASP format

Ready to audit. Provide a file, directory, or endpoint.
```

## When To Use

- **Teams with defined workflows** — the slash commands enforce consistent processes across developers
- **Projects requiring formal reviews** — `/sc:review` produces structured, actionable feedback
- **TDD practitioners** — the TDD mode is the most robust test-first enforcement available
- **Security-conscious codebases** — the security agent and `/sc:security` command catch vulnerabilities other tools miss
- **Onboarding new developers** — the `teach` mode explains every decision, accelerating learning

## When NOT To Use

- **Quick scripts and experiments** — the framework's structure adds overhead to throwaway work
- **Teams that resist process** — if developers won't adopt slash commands, the framework sits unused
- **Minimal CLAUDE.md setups** — SuperClaude installs many files; if you prefer a single CLAUDE.md, use [Karpathy skills](/karpathy-claude-code-skills-complete-guide-2026/) instead
- **Offline environments** — initial installation requires network access for the pip package

## FAQ

### Can I use only some commands?

Yes. After installation, delete any command files from `.claude/commands/` that you don't need. The remaining commands work independently.

### Does it conflict with custom CLAUDE.md rules?

SuperClaude installs its rules in a structured format that coexists with your custom rules. The `/sc:` prefix prevents conflicts with other slash commands.

### How do I update?

```bash
pipx upgrade superclaude
superclaude install --update
```

### Can I create custom commands?

Yes. Add `.md` files to `.claude/commands/` following the SuperClaude template format. The `superclaude scaffold-command` utility generates the boilerplate.

### What's the token overhead?

The active mode/agent profile adds 200-400 tokens per message. Slash commands add their prompt template on invocation only — no persistent overhead.

## Our Take

**8/10.** SuperClaude is the most complete framework for teams that want structured Claude Code workflows. The 30 commands cover every phase of development, and the behavioral modes are genuinely useful (TDD mode alone is worth the install). Loses points for installation complexity — `pipx` + `superclaude install` + configuration is more friction than dropping a single CLAUDE.md file. Best for teams of 3+ developers who need consistency.

## Related Resources

- [Best Claude Skills for Developers](/best-claude-skills-for-developers-2026/) — how SuperClaude compares to other frameworks
- [Claude Code Hooks Explained](/understanding-claude-code-hooks-system-complete-guide/) — the hook system SuperClaude builds on
- [The Claude Code Playbook](/playbook/) — workflow patterns to combine with SuperClaude commands
