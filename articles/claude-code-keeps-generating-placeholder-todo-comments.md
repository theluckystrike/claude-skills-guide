---
layout: default
title: "Claude Code Keeps Generating Placeholder TODO Comments"
description: "Why Claude Code keeps adding placeholder TODO comments and how to fix it. Practical solutions for controlling AI-generated code comments."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-keeps-generating-placeholder-todo-comments/
---

# Claude Code Keeps Generating Placeholder TODO Comments

If you've been working with Claude Code, you've probably seen it—those familiar `// TODO: implement error handling` or `// TODO: add validation` comments scattered throughout generated code. While well-intentioned, these placeholder comments can accumulate quickly and become technical debt if not addressed properly. Let's explore why Claude Code generates these comments and how you can control this behavior effectively.

## Why Claude Code Generates TODO Comments

Claude Code generates placeholder TODO comments for several reasons related to how Large Language Models approach code generation. Understanding these motivations helps you address the root cause rather than just treating symptoms.

**Incomplete Context**: When Claude Code doesn't have complete information about your requirements, it uses TODO comments as placeholders for functionality you're expected to fill in. This often happens when you ask for complex features without specifying all the implementation details.

**Risk Mitigation**: The AI sometimes adds TODO comments as a way to acknowledge uncertainty. Rather than guessing incorrectly, it marks areas where implementation decisions need human input.

**Template Patterns**: Claude Code has been trained on millions of codebases where TODO comments are common patterns. The model sometimes defaults to these patterns, especially when generating code in unfamiliar domains or languages.

## Practical Solutions

### 1. Provide Complete Specifications

The most effective fix is providing detailed context about what you want. Instead of:

```
Create a user authentication module
```

Try:

```
Create a user authentication module with:
- Email/password login (bcrypt hashing)
- JWT token refresh
- Password reset via email
- Rate limiting (5 attempts per minute)
- Return proper HTTP status codes
```

When you specify exact requirements, Claude Code has less reason to leave placeholders.

### 2. Use claude.md to Set Expectations

Create a `CLAUDE.md` file in your project root with clear instructions about TODO comments:

{% raw %}
```markdown
# Project Guidelines

## Code Style
- Implement all functionality completely - do not leave TODO comments
- If something is unclear, ask the user before implementing
- Write production-ready code with proper error handling
- Include input validation for all user inputs
```
{% endraw %}

This tells Claude Code upfront that placeholder comments aren't acceptable in your codebase.

### 3. Direct Prompt Modification

You can also address TODO generation directly in your prompts:

```
Write a function to process user data. Include all error handling, 
input validation, and edge case handling. Do not leave any TODO 
comments - implement everything completely or ask me clarifying 
questions first.
```

### 4. Use Skills to Enforce Complete Code

Create a custom skill that specifically addresses code completeness. In `~/.claude/skills/complete-code.md`:

{% raw %}
```markdown
# Complete Implementation Skill

When writing code, always:
1. Implement all functionality fully - no TODO or FIXME placeholders
2. Add proper error handling for all functions
3. Include input validation
4. Write meaningful comments only - never use "TODO" as a placeholder
5. If requirements are unclear, ask the user before guessing

If you find yourself wanting to add a TODO comment, instead either:
- Ask the user for clarification
- Implement a reasonable default behavior
- Write a comment explaining what needs to be decided, not as a placeholder
```
{% endraw %}

Invoke this skill with `/complete-code` when generating new code.

## Finding Existing TODO Comments

If you already have TODO comments scattered throughout your codebase, you can use Claude Code to find and address them:

{% raw %}
```bash
# Search for TODO comments in your codebase
grep -r "TODO" --include="*.ts" --include="*.js" src/
```
{% endraw %}

Then ask Claude Code to review each one:

```
Review all the TODO comments in the codebase and either:
1. Implement them if you have enough context
2. Prioritize them by importance
3. Remove them if they're no longer relevant
```

## Configuring Claude Code Behavior

While there's no global setting to disable TODO comments, you can influence behavior through:

- **System prompts**: Add instructions about TODO avoidance
- **Project-specific CLAUDE.md files**: Enforce standards per project
- **Custom skills**: Create reusable rules for different project types

## When TODO Comments Are Acceptable

Not all TODO comments are problematic. They're appropriate when:

- Tracking external API changes
- Marking deprecated functionality with removal timelines
- Noting technical debt for future prioritization
- Documenting known limitations in third-party integrations

The issue arises when TODO becomes a default placeholder instead of a deliberate tracking mechanism.

## Conclusion

Claude Code generating placeholder TODO comments typically indicates a gap between your expectations and the information provided. By improving context, using CLAUDE.md files, and creating custom skills, you can dramatically reduce or eliminate these placeholders. The goal is always production-ready code, and with the right prompting strategies, Claude Code can deliver exactly that.

Remember: TODO comments should be deliberate tracking tools, not AI-generated placeholders for unimplemented features.
