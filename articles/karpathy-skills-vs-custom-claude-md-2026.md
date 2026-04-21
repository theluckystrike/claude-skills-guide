---
title: "Karpathy Skills vs Custom CLAUDE.md (2026)"
description: "Should you use Karpathy's proven 4-principle CLAUDE.md or write your own from scratch? Compare both approaches with concrete examples."
permalink: /karpathy-skills-vs-custom-claude-md-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Karpathy Skills vs Custom CLAUDE.md (2026)

Every Claude Code project needs a CLAUDE.md file. The question is whether to start with Karpathy's battle-tested template or write your own from scratch. Both work. The tradeoffs are real.

## Quick Verdict

**Start with Karpathy Skills** as your behavioral foundation, then add project-specific rules on top. Writing a CLAUDE.md entirely from scratch means reinventing principles that Karpathy's 72K-star community has already validated.

## Feature Comparison

| Feature | Karpathy Skills | Custom CLAUDE.md |
|---|---|---|
| Community Validation | 72K stars | Your own testing |
| Setup Time | 1 minute (copy file) | 30 minutes to hours |
| Behavioral Coverage | 4 core principles | Whatever you define |
| Project Specifics | None | Tailored to your stack |
| Maintenance | Pull upstream updates | You maintain it |
| Learning Curve | Read and understand | Design and iterate |
| Team Adoption | Drop-in standard | Needs documentation |
| Flexibility | Fixed principles | Total control |

## What Karpathy Skills Provides

Four behavioral principles in a single markdown file:

**Don't Assume** — When Claude encounters ambiguous requirements, it asks rather than guesses. This alone prevents a category of bugs where Claude fills in blanks with plausible but incorrect assumptions.

**Don't Hide Confusion** — Claude explicitly states when something is unclear instead of powering through with a best guess. This surfaces misunderstandings early rather than embedding them in code.

**Surface Tradeoffs** — When you ask Claude to do something, it tells you the downsides. Ask for a quick fix and Claude will note that it introduces tech debt. Ask for a complex solution and Claude will mention the simpler alternative.

**Goal-Driven Execution** — Claude focuses on what you are trying to achieve rather than literally following instructions. If your instructions would not achieve your goal, Claude says so.

## What Custom CLAUDE.md Provides

A custom file lets you encode project-specific knowledge:

- Tech stack requirements ("use pnpm, not npm")
- Code style rules ("functions under 60 lines, NASA Power of 10")
- Architecture decisions ("all API routes go through /api/v1/")
- Testing requirements ("every function needs 2 assertions")
- File structure rules ("components in /src/components/, never in /src/pages/")
- Domain-specific knowledge ("our user table has a soft-delete column")

None of this exists in Karpathy Skills because it is project-agnostic. Your custom file fills the project-specific gap.

## The Combined Approach

The best strategy is both. Start with Karpathy Skills as section one of your CLAUDE.md:

```markdown
# Behavioral Principles (from Karpathy Skills)
1. Don't Assume — ask for clarification
2. Don't Hide Confusion — surface ambiguity
3. Surface Tradeoffs — explain downsides
4. Goal-Driven Execution — focus on objectives

# Project-Specific Rules
- Stack: Next.js 14, TypeScript, Tailwind, Supabase
- Package manager: pnpm only
- Functions: max 60 lines, 2 assertions each
- ...
```

This gives you the validated behavioral foundation plus your project-specific context. Claude gets both the reasoning principles and the domain knowledge.

For detailed guidance on structuring this file, see the [CLAUDE.md best practices guide](/claude-md-file-best-practices-guide/).

## When Pure Custom Wins

Sometimes Karpathy's principles do not fit:

- **Highly autonomous workflows** — If you want Claude to make assumptions and move fast, "Don't Assume" slows things down. Some developers prefer Claude to guess and ask for forgiveness rather than permission.
- **Specialized domains** — If you are using Claude for academic writing or data analysis, the four principles may be less relevant than domain-specific rules.
- **Minimal setups** — If your CLAUDE.md is just 5 lines of project context, adding the Karpathy principles might be overkill.

## Maintenance Comparison

Karpathy Skills is maintained by the community. When new patterns emerge or Claude's behavior changes, the repo updates. You can pull updates periodically.

Custom files are maintained by you. When your project evolves, you update the file. When Claude starts exhibiting a new pattern you dislike, you add a rule. The maintenance is proportional to your project's complexity.

The combined approach means maintaining both: pulling Karpathy updates and keeping your project rules current. This is minimal overhead — maybe 10 minutes per month.

## When To Use Each

**Choose Karpathy Skills alone when:**
- You want quick improvement with zero customization effort
- Your project is simple enough that behavioral principles are sufficient
- You are evaluating Claude Code and want a good starting template

**Choose custom CLAUDE.md alone when:**
- You have specific behavioral requirements that conflict with Karpathy's principles
- You want total control over Claude's behavior
- Your domain has unique requirements that need extensive documentation

**Choose the combined approach when:**
- You want validated behavioral principles plus project-specific context
- You are building a team [playbook](/the-claude-code-playbook/) and need a strong foundation
- You want the community's evolving best practices plus your own rules

## Final Recommendation

Copy Karpathy Skills into your CLAUDE.md, add your project-specific rules below it, and move on. You get 72K stars worth of community validation plus your domain knowledge. Revisit and refine monthly. The 80/20 outcome requires less than 5 minutes of setup, and your [Claude Code sessions](/claude-code-best-practices-2026/) will improve immediately.
