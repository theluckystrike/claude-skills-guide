---
layout: default
title: "Why Does Claude Code Sometimes Ignore My Instructions?"
description: "Debug why Claude Code ignores your instructions. Learn how token limits, system prompts, skill configurations, and instruction clarity affect Claude's behavior."
date: 2026-03-14
categories: [troubleshooting]
tags: [claude-code, instructions, debugging, troubleshooting, skill-configuration]
author: theluckystrike
permalink: /why-does-claude-code-sometimes-ignore-my-instructions/
---

# Why Does Claude Code Sometimes Ignore My Instructions?

You've been there: you type a clear instruction, and Claude Code does something completely different. Maybe it skips the error handling you requested, uses a different coding style than you specified, or ignores a specific file you wanted modified. Understanding why this happens helps you write better prompts and get more predictable results.

## The Core Issue: Interpretation Versus Execution

Claude Code doesn't ignore instructions maliciously or randomly. The model interprets your request within a complex context that includes conversation history, loaded skills, system-level configurations, and implicit priorities. Several factors can cause the model to prioritize something other than your explicit instruction.

## Factor 1: Token Limits and Context Management

When a conversation grows long, Claude Code operates under token constraints. Each message, code snippet, and tool output consumes tokens from your context window. When approaching these limits, the model must make decisions about what information to retain.

If your instruction appears in a message that gets truncated due to token limits, Claude may not process it fully. This commonly happens when:

- You've shared large files or error logs
- The conversation includes many back-and-forth exchanges
- Previous responses contained verbose code blocks

**Solution**: Reference specific files or use clear markers. Instead of writing "fix the authentication logic in the files I mentioned earlier," explicitly name the file:

```bash
# More likely to work when tokens are constrained
Please add JWT validation to auth/middleware.ts
# Instead of
Please fix the auth issues we discussed
```

## Factor 2: System Prompts Override User Instructions

Claude Code loads with system-level prompts that define its core behavior. When you install skills like **frontend-design**, **pdf**, or **tdd**, these add their own instructions to the system's context. Sometimes these skill instructions conflict with your direct requests.

For example, the **tdd** skill may prioritize writing tests before implementation code. If you explicitly ask to skip tests and just write the implementation, Claude might still include tests because the skill's instructions carry significant weight.

**Solution**: Use explicit override language:

```markdown
IGNORE the tdd skill's test-first requirement for this specific request.
I want only the implementation code, no tests.
```

## Factor 3: Implicit Reasoning About Intent

Claude attempts to infer your true intent, which sometimes leads it to deviate from literal instructions. If you say "make this function faster," Claude might refactor the code entirely when a simpler optimization would suffice. The model reasons that "faster" implies a significant improvement, not just a minor tweak.

This also applies to vague instructions. When you write "make the API response better," Claude must interpret what "better" means—faster response time, better error handling, improved data structure, or cleaner code.

**Solution**: Be specific about what you want:

```python
# Vague - unpredictable results
"Make this function better"

# Specific - predictable results
"Add a try-catch block that returns a 500 error with the exception message
when the database query fails. Do not change anything else in this function."
```

## Factor 4: The claude.md Priority

If a `claude.md` file exists in your project root, its contents load as persistent context. This file often contains team conventions, coding standards, and project-specific rules. When your instruction conflicts with something in claude.md, the model typically follows the project's established patterns.

**Example claude.md that might override your instructions:**

```markdown
# Our project conventions
- Always use async/await, never .then() chains
- Include JSDoc comments on all exported functions
- Use named exports exclusively
```

If you ask Claude to "quickly write a function using .then() for simplicity," it might still use async/await because the project conventions carry weight.

**Solution**: Acknowledge the conflict explicitly:

```bash
I understand our project requires async/await, but for this one-off
script, please use .then() chains to keep it synchronous and simple.
```

## Factor 5: Tool Use Restrictions

Claude Code decides when and how to use available tools. Sometimes it won't read a file you expect it to, won't run a command you requested, or won't use a specific skill you have installed.

The **supermemory** skill, for instance, stores conversation context for retrieval later. If you expect Claude to reference something from three sessions ago but haven't invoked supermemory explicitly, Claude operates only with the current session's context.

**Solution**: Invoke skills explicitly when needed:

```bash
@supermemory search for my discussion about API rate limiting
```

## Factor 6: Safety and Policy Constraints

Claude Code has built-in safety guidelines that prevent certain actions. These aren't optional—you cannot override them with a prompt. If your instruction would cause Claude to help with something potentially harmful, it will redirect or refuse.

This includes instructions to bypass security measures, generate malicious code, or assist with tasks that violate acceptable use policies. The model errs on the side of caution.

## Factor 7: Execution Environment Issues

Sometimes Claude Code appears to ignore instructions because of environment constraints it cannot control. If a required tool isn't installed, a dependency is missing, or file permissions are incorrect, Claude adapts to what's available—which might look like ignoring your instruction.

**Example:**

```bash
# You ask for this
Please run npm test to verify the fix

# But the tests fail because node_modules isn't installed
# Claude works around this by just reading the code instead
```

## Practical Debugging Steps

When Claude isn't following your instructions:

1. **Check your wording** — Is it specific enough? Remove ambiguity.

2. **Verify context** — Has the conversation become long? Consider starting fresh or being more explicit.

3. **Check for conflicts** — Does a skill or claude.md contradict your request?

4. **Use explicit overrides** — Say "ignore previous instructions about X" or "override the default behavior for this specific case."

5. **Confirm skill activation** — Are you invoking the right skill with `@skillname`?

6. **Break complex requests** — Split one complex instruction into multiple clear steps.

## Summary

Claude Code doesn't ignore instructions arbitrarily. Token limits, skill configurations, project conventions, safety policies, and the model's attempt to understand your true intent all influence its behavior. By writing more specific prompts, understanding the priority of different instruction sources, and explicitly overriding conflicting contexts, you can get much more predictable results.

The key is treating Claude Code as a collaborator that needs clear, unambiguous communication—just like working with a teammate who doesn't share your exact context.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
