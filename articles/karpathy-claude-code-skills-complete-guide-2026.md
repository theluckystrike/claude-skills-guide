---
title: "Karpathy Skills for Claude Code (2026)"
description: "Install and configure Andrej Karpathy's CLAUDE.md behavioral skills that enforce Don't Assume, Surface Tradeoffs, and Goal-Driven Execution in Claude Code."
permalink: /karpathy-claude-code-skills-complete-guide-2026/
last_tested: "2026-04-22"
---

# Karpathy Skills for Claude Code: Complete Guide (2026)

Andrej Karpathy's behavioral guidelines for Claude Code have become the gold standard for taming AI coding agents. The `andrej-karpathy-skills` repo (72K+ stars on GitHub) distills four principles into a single CLAUDE.md file that reshapes how Claude Code reasons about your codebase.

This guide covers installation, configuration, the four core principles, real usage patterns, and when this approach falls short.

## What It Is

The `andrej-karpathy-skills` repository by Forrest Chang packages observations from Andrej Karpathy — the former Tesla AI director and OpenAI co-founder — into a structured CLAUDE.md behavioral file. Drop it into any project root, and Claude Code reads it on every session start.

The file enforces four behavioral principles:

1. **Don't Assume** — ask before guessing
2. **Don't Hide Confusion** — surface uncertainty explicitly
3. **Surface Tradeoffs** — present options, not decisions
4. **Goal-Driven Execution** — stay locked on the stated objective

These aren't vague suggestions. Each principle maps to concrete behavioral rules that Claude Code interprets as hard constraints during code generation.

## Why It Matters

Without behavioral guidelines, Claude Code defaults to confident action. It picks a framework, writes an implementation, and moves forward — even when the requirements are ambiguous. This creates three recurring problems:

- **Silent assumptions** that don't match your architecture
- **Over-engineered solutions** when a simple fix would suffice
- **Scope drift** where the agent touches files unrelated to the task

Karpathy's principles attack all three. Teams using these guidelines report fewer reverted PRs and shorter review cycles because Claude Code surfaces its uncertainty instead of burying it in generated code.

## Installation

### Quick Install (Single Project)

```bash
cd /path/to/your/project
curl -o CLAUDE.md https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md
```

### Clone as Plugin

```bash
git clone https://github.com/forrestchang/andrej-karpathy-skills.git ~/.claude/plugins/karpathy-skills
```

Then reference it in your project's CLAUDE.md:

```markdown
# Include Karpathy behavioral guidelines
See ~/.claude/plugins/karpathy-skills/CLAUDE.md for base behavioral rules.
```

### Verify It Loaded

Start a Claude Code session and ask:

```
What behavioral guidelines are you following from CLAUDE.md?
```

Claude Code should reference the four principles explicitly. If it doesn't, check the file path — CLAUDE.md must sit in the project root or in `~/.claude/`.

## Key Features

1. **Don't Assume Enforcement** — Claude Code asks clarifying questions before making architectural decisions. No more guessing which database driver you want.

2. **Confusion Surfacing** — When requirements conflict or are ambiguous, the agent flags them explicitly rather than picking an interpretation silently.

3. **Tradeoff Presentation** — For decisions with multiple valid approaches, Claude Code presents 2-3 options with pros/cons before implementing.

4. **Goal Anchoring** — Every response ties back to the stated task. If Claude Code notices itself drifting, it re-states the goal and course-corrects.

5. **Zero-Config Setup** — One file, no dependencies, no build step. Works with any language or framework.

6. **Composable with Other Skills** — Stack it with [SuperClaude](/superclaude-framework-guide-2026/) commands or [custom hooks](/understanding-claude-code-hooks-system-complete-guide/) without conflicts.

7. **Community-Maintained** — Active contributor base keeps the guidelines aligned with Claude Code's evolving behavior across model updates.

## Real Usage Example

Here's how the Don't Assume principle changes behavior in practice.

**Without Karpathy Skills:**

```
You: Add authentication to the API

Claude Code: I'll add JWT authentication with bcrypt password hashing,
a /login endpoint, middleware for protected routes, and refresh tokens.
*proceeds to write 400 lines across 6 files*
```

**With Karpathy Skills:**

```
You: Add authentication to the API

Claude Code: Before I implement authentication, I need to clarify:
1. Auth method — JWT, session-based, OAuth, or API keys?
2. Password storage — bcrypt, argon2, or delegating to an identity provider?
3. Token lifetime — short-lived access + refresh, or long-lived tokens?
4. Which routes need protection? All except /login, or a specific subset?

Your existing codebase uses Express with no auth middleware currently.
The /users table has email and password_hash columns, suggesting
password-based auth was planned.
```

The second response costs zero wasted tokens on unwanted implementations.

### CLAUDE.md Integration Pattern

Most teams merge Karpathy's guidelines into their existing CLAUDE.md rather than using the file standalone:

```markdown
# Project: my-api

## Behavioral Rules (via Karpathy)
- NEVER assume the tech stack for new features. Ask first.
- When confused about requirements, say so. Don't fill gaps with guesses.
- For any decision with 2+ valid approaches, present tradeoffs before coding.
- Every response must reference the current goal. If scope creeps, flag it.

## Project-Specific Rules
- Use PostgreSQL with Drizzle ORM (not Prisma, not raw SQL)
- All API routes go in /src/routes/ following the existing pattern
- Tests use Vitest, not Jest
```

## When To Use

- **Greenfield projects** where Claude Code might pick arbitrary tech choices
- **Teams with junior developers** who rely heavily on AI-generated code
- **Ambiguous feature requests** where requirements leave room for interpretation
- **Codebases with strict architectural patterns** that shouldn't be violated
- **Multi-agent workflows** where consistency across agents matters

## When NOT To Use

- **Quick scripts and throwaway code** — the clarifying questions add friction you don't need for one-off tasks
- **Highly constrained environments** where every decision is already documented in the CLAUDE.md — the principles become redundant
- **Speed-critical prototyping** — if you want Claude Code to just pick something and run, these guidelines slow it down by design
- **Solo developers with deep context** who can spot and correct assumptions faster than answering clarifying questions

## FAQ

### Does this work with Claude Code on all plans?

Yes. CLAUDE.md is loaded regardless of your Anthropic plan tier. The behavioral guidelines work with Pro, Teams, and Enterprise.

### Can I use this alongside SuperClaude or other skill frameworks?

Absolutely. The Karpathy principles are behavioral constraints, not slash commands. They sit in a different layer than [SuperClaude's /sc: commands](/superclaude-framework-guide-2026/) or [template-based agents](/claude-code-templates-600-agents-guide-2026/). Stack them freely.

### How do I customize the strictness?

Edit the CLAUDE.md rules directly. For example, to allow assumptions about well-established patterns:

```markdown
- Don't assume UNLESS the project already has an established pattern for the decision
  (e.g., if all routes use Zod validation, assume new routes should too)
```

### Does this increase token usage?

Slightly. The clarifying questions add one round-trip before implementation. In practice, this costs far less than generating a wrong implementation and iterating. Most teams report a net token decrease.

### How often is the repo updated?

The maintainers update the guidelines when Claude Code's behavior changes across model updates. Check the repo's commit history for the latest adjustments.

## Our Take

**9/10.** The Karpathy skills are the single highest-ROI addition you can make to a CLAUDE.md file. Four rules, zero dependencies, and an immediate reduction in wasted iterations. The only missing point is that the repo doesn't include project-type-specific templates — you'll need to customize the principles for your domain. Pair it with [ccusage for cost tracking](/ccusage-claude-code-cost-tracking-guide-2026/) to quantify the improvement.

## Related Resources

- [CLAUDE.md Best Practices Guide](/claude-md-best-practices-10-templates-compared-2026/) — structuring your full CLAUDE.md
- [Best Claude Skills for Developers](/best-claude-skills-for-developers-2026/) — other high-value skill packages
- [The Claude Code Playbook](/playbook/) — end-to-end workflow patterns
