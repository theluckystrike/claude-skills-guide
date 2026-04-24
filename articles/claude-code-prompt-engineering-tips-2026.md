---
title: "Claude Code Prompt Engineering Tips"
description: "Practical prompt engineering tips for Claude Code including task scoping, file references, acceptance criteria, and common anti-patterns."
permalink: /claude-code-prompt-engineering-tips-2026/
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code Prompt Engineering Tips (2026)

The difference between a 2-minute fix and a 20-minute back-and-forth is often the prompt. Claude Code responds best to specific, scoped, and structured prompts. These tips come from patterns observed across the ecosystem.

## The Anatomy of a Good Prompt

A productive Claude Code prompt has four parts:

1. **What to do** (action + target)
2. **Where to do it** (file path or scope)
3. **How to do it** (constraints and patterns)
4. **How to verify** (acceptance criteria)

### Example: Bad Prompt
```
Fix the login
```

### Example: Good Prompt
```
Fix the TypeError in src/components/LoginForm.tsx on line 42.
The error occurs when email is null.
Add a null check before calling validateEmail().
After fixing, run 'npx vitest run src/components/LoginForm.test.tsx'
to verify the fix.
```

## Tip 1: Start With the File Path

Always include the file path. This prevents Claude Code from searching:

```
# Without path (expensive — triggers search)
"Update the user service to add email validation"

# With path (cheap — direct read)
"In src/services/user.service.ts, add Zod email validation to the createUser function"
```

## Tip 2: Define Boundaries

Tell Claude Code what NOT to do:

```
"Add pagination to the users list in src/app/users/page.tsx.
- Use server-side pagination with offset/limit
- DO NOT modify the API route
- DO NOT add new dependencies
- Only change the page component and its hook"
```

The [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) "Goal-Driven Execution" principle maps directly to this: do what was asked, nothing more.

## Tip 3: Provide Examples

When you want a specific pattern, show it:

```
"Add a new API route for /api/comments.
Follow the same pattern as /api/posts (src/app/api/posts/route.ts):
- Zod schema validation
- Auth check via getServerSession
- Service layer call
- Standard response wrapper"
```

## Tip 4: Use Acceptance Criteria

```
"Refactor the payment processing in src/services/payment.ts.

Acceptance criteria:
1. Extract retry logic into a reusable function
2. All existing tests pass without modification
3. No new dependencies added
4. Maximum 5 lines changed per function
5. TypeScript strict mode passes"
```

## Tip 5: Chain Small Tasks

Instead of one large prompt, chain small ones:

```
Step 1: "Read src/services/auth.ts and explain the current auth flow"
Step 2: "Add refresh token support to the auth flow. The refresh token
         should be stored in an httpOnly cookie."
Step 3: "Write tests for the refresh token functionality"
```

This matches the session chunking pattern from [claude-task-master](https://github.com/eyaltoledano/claude-task-master), which breaks PRDs into ordered, dependency-aware tasks.

## Tip 6: Reference CLAUDE.md Rules

When you want a specific convention enforced:

```
"Add the user preferences endpoint. Follow our API Response Contract
from CLAUDE.md — use the {data, meta, error} wrapper shape."
```

This tells Claude Code to re-read that specific CLAUDE.md section.

## Tip 7: Ask for Plans Before Code

For complex tasks, get Claude Code's plan first:

```
"I want to add real-time notifications. Before writing any code,
outline your implementation plan:
1. Which files you will create or modify
2. Which libraries you will use (from our approved list)
3. The data flow from event to notification
4. Estimated number of files changed"
```

Review the plan, adjust, then proceed.

## Tip 8: Specify Output Format

When you need structured output:

```
"Audit src/services/ for error handling inconsistencies.

Output format:
## [filename]
- Line [N]: [issue description]
- Recommendation: [specific fix]

Sort by severity (critical first)."
```

## Anti-Patterns to Avoid

### Anti-Pattern 1: Vague Scope
```
# Bad
"Make the code better"
"Clean up this file"
"Improve performance"

# Good
"Reduce the time complexity of findDuplicates() from O(n^2) to O(n)
using a Set for lookup in src/utils/dedup.ts"
```

### Anti-Pattern 2: Too Many Tasks at Once
```
# Bad
"Add pagination, search, filtering, sorting, and export to the users page"

# Good
"Add server-side pagination to the users page with 25 items per page"
(then handle the others in follow-up prompts)
```

### Anti-Pattern 3: Assuming Context
```
# Bad (after 20 messages)
"Now do the same thing for the other file"

# Good
"Apply the same Zod validation pattern we used in src/routes/users.ts
to src/routes/orders.ts"
```

### Anti-Pattern 4: No Success Criteria
```
# Bad
"Add caching"

# Good
"Add Redis caching to getUser() in src/services/user.ts with a 5-minute TTL.
Verify by running the service and checking that the second call returns
the cached result (log output should show 'cache hit')."
```

## Prompt Templates

### Bug Fix Template
```
Bug: [description]
File: [path]:[line]
Steps to reproduce: [1, 2, 3]
Expected: [what should happen]
Actual: [what happens]
Fix constraints: [only change X, don't touch Y]
Verify: [command to run]
```

### Feature Template
```
Feature: [name]
Files to create/modify: [paths]
Pattern to follow: [reference existing file]
Acceptance criteria: [1, 2, 3]
Not in scope: [what to skip]
```

### Refactoring Template
```
Refactor: [what specifically]
File: [path]
Current issue: [why it needs refactoring]
Target state: [what it should look like]
Constraints: [behavior must not change, tests must pass]
```

## FAQ

### How long should prompts be?
50-200 words for simple tasks. 200-500 words for complex features. Longer prompts are fine if they reduce ambiguity. The [claude-howto](https://github.com/luongnv89/claude-howto) repo provides visual prompt templates.

### Should I include code snippets in prompts?
Yes, when showing a specific pattern to follow. Keep snippets under 20 lines. For larger references, point Claude Code to the file path.

### Does prompt structure affect token cost?
Minimally. A well-structured 200-word prompt costs ~260 tokens. A vague 20-word prompt costs ~26 tokens but may generate 2,000 tokens of incorrect output that you need to redo.

### Can I save prompt templates?
Yes. Use slash commands (`.claude/commands/`) to save reusable prompt templates. See the [skills vs hooks vs commands guide](/claude-code-skills-vs-hooks-vs-commands-2026/).

For more on getting better results from Claude Code, see [The Claude Code Playbook](/playbook/). For managing context across prompts, read the [context window guide](/claude-code-context-window-management-2026/). For team-wide prompt standards, see the [team onboarding playbook](/claude-code-team-onboarding-playbook-2026/).

- [Super Claude Code framework](/super-claude-code-framework-guide/) — structured prompting framework for advanced users
- [CLAUDE.md best practices](/claude-md-best-practices-definitive-guide/) — project-level prompt configuration
- [Claude Code spec workflow](/claude-code-spec-workflow-guide/) — write specs before implementation for better prompts
