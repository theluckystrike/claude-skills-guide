---
title: "Claude Code spending tokens on files I"
description: "Stop Claude Code from spending tokens on irrelevant files with .claudeignore rules, CLAUDE.md boundaries, and scoped prompts that cut waste by 40-60%."
permalink: /claude-code-spending-tokens-files-didnt-ask-about/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Claude Code spending tokens on files I didn't ask about

## The Problem

Claude Code reads files beyond the scope of the requested task, consuming 20K-80K tokens on irrelevant context. The symptom: asking Claude to "fix the bug in auth.ts" results in Claude reading 10 unrelated files -- configuration files, test files, README, package.json -- before touching auth.ts. Each unnecessary file read costs 1,000-5,000 tokens. On Sonnet 4.6, this waste adds $0.06-$0.24 per task, accumulating to $26-$106/month for a developer running 20 tasks/day.

## Quick Fix (2 Minutes)

Add explicit scoping to the prompt:

```bash
# Instead of:
claude "Fix the bug in the authentication module"

# Use:
claude "Fix the null check bug in src/auth/validate.ts line 47.
Only read src/auth/validate.ts and src/auth/types.ts. Do not read other files."
```

Then add to CLAUDE.md:

```markdown
## Scope Rule
Only read files directly related to the task.
Never read README, package.json, or config files unless the task is about configuration.
```

## Why This Happens

Claude Code's exploration behavior serves a purpose: understanding context before making changes reduces errors. However, the default exploration is overbroad for most tasks. Three patterns cause unnecessary file reads:

1. **Orientation reads:** Claude reads project config (package.json, tsconfig.json, .env.example) to understand the tech stack. Cost: 3K-8K tokens. Unnecessary when CLAUDE.md already describes the stack.

2. **Dependency tracing:** Claude follows import chains beyond what the task requires. A change to one function triggers reading all files that import from that module. Cost: 10K-40K tokens. Unnecessary when the task is scoped to internal logic.

3. **Pattern discovery:** Claude reads similar files to understand coding conventions. Before editing a route file, it reads 2-3 other route files. Cost: 5K-15K tokens. Unnecessary when conventions are documented in CLAUDE.md.

## The Full Fix

### Step 1: Diagnose

Run a test task and observe what Claude reads:

```bash
claude "Add a console.log statement to the top of src/utils/format.ts"

# Watch the tool calls -- if Claude reads more than 1 file for this trivial task,
# scoping is needed
# Check cost:
/cost
# If input > 10K tokens for adding a console.log, there is scope creep
```

### Step 2: Fix

**Create .claudeignore for hard boundaries:**

```bash
# .claudeignore
node_modules/
dist/
build/
.git/
*.lock
*.min.js
*.map
coverage/
__snapshots__/
.env*
```

**Add scope rules to CLAUDE.md:**

```markdown
# CLAUDE.md

## Scope Rules (MANDATORY)
- Read ONLY files mentioned in the task or directly imported by those files
- Never read README.md, CHANGELOG.md, or documentation files for code tasks
- Never read package.json unless the task involves dependencies
- Never read tsconfig.json unless the task involves TypeScript configuration
- Never read .env files (security risk and irrelevant to most tasks)
- Before reading ANY file not mentioned in the task, state why it is necessary

## Project Context (so you don't need to read config files)
- Stack: TypeScript, Express, Prisma, Jest
- Node version: 18
- TypeScript: strict mode, paths configured in tsconfig
- Test runner: Jest with ts-jest transformer
```

The "Project Context" section eliminates the need for orientation reads -- saving 3K-8K tokens per session.

**Add dependency context to skills:**

```markdown
# .claude/skills/imports.md

## Import Map (common dependencies between files)
- src/auth/validate.ts imports: types/auth.ts, utils/crypto.ts
- src/routes/users.ts imports: services/user.ts, middleware/auth.ts
- src/services/user.ts imports: repositories/user.ts, types/user.ts
```

This eliminates dependency tracing reads -- saving 10K-40K tokens per task.

### Step 3: Prevent

```markdown
# CLAUDE.md addition

## Before Reading a File
Ask: "Is this file directly required to complete the task?"
- If yes: read it
- If maybe: state the reason and ask
- If no: do not read it
```

## Cost Recovery

If Claude has already read unnecessary files in the current session:

```bash
# Compact to remove the unnecessary context
/compact

# Then restart with explicit scope
"Now focus only on src/auth/validate.ts. Ignore everything else you read."
```

## Prevention Rules for CLAUDE.md

```markdown
## File Access Rules
- ONLY read files explicitly mentioned in the task
- ONLY follow imports that are directly relevant to the change
- NEVER read: README, CHANGELOG, package.json, tsconfig.json, .env (unless task requires)
- NEVER read test files unless the task is about tests
- NEVER read more than 3 files that were not mentioned in the task
- Before reading an unmentioned file, explain in one sentence why it is needed
- If unsure whether a file is needed, ask instead of reading

## Already-Known Context
Stack: TypeScript strict, Express, Prisma, PostgreSQL, Jest
Node: 18, pnpm
Conventions: repository pattern, zod validation, JWT auth
```

Expected savings: 40-60% reduction in unnecessary file reads, worth $26-$64/month per developer on Sonnet 4.6 at 20 tasks/day.

## Understanding Claude's File Selection Logic

Claude Code decides which files to read based on:

1. **Task keywords:** "auth" triggers reading files with "auth" in the name or path
2. **Import chains:** Reading a file that imports from another triggers reading the imported file
3. **Pattern matching:** Before editing a route file, Claude reads other route files to learn patterns
4. **Uncertainty reduction:** When the task is ambiguous, Claude reads more files to reduce uncertainty

Each mechanism can be short-circuited with the right CLAUDE.md rules:

```markdown
# CLAUDE.md

## File Selection Rules (override defaults)
- Task keywords: read only the file mentioned, not all files matching the keyword
- Import chains: follow max 2 levels of imports from the target file
- Pattern matching: patterns are documented in this file and .claude/skills/
  Do NOT read other files to learn patterns
- Uncertainty: if the task is ambiguous, ASK for clarification instead of reading more files
```

## Common Triggers and Fixes

| Trigger | Files Read | Tokens Wasted | Fix |
|---------|-----------|---------------|-----|
| "Fix the auth module" | 5-10 auth-related files | 15K-30K | Be specific: "Fix auth.ts line 34" |
| Import chain tracing | 3-8 imported files | 10K-25K | Add dependency map skill |
| Pattern discovery | 2-5 similar files | 6K-15K | Document patterns in CLAUDE.md |
| Config file reading | 3-5 config files | 3K-8K | Add stack info to CLAUDE.md |
| Test file reading | 2-5 test files | 6K-15K | Rule: "no test reads for non-test tasks" |

## Measuring Improvement

Track the "irrelevant file ratio" over time:

```bash
# After each session, estimate:
# Total files read: (check tool calls in the session)
# Relevant files: (files that were actually edited or directly informed the edit)
# Irrelevant files: Total - Relevant
# Ratio: Relevant / Total

# Targets:
# Before optimization: 30-50% relevance ratio
# After basic CLAUDE.md: 60-70% relevance ratio
# After skills + scoping: 80-90% relevance ratio
# Optimal: 85-95% relevance ratio (some exploration is healthy)
```

An irrelevant file ratio above 50% (more than half the files read were not needed) indicates immediate optimization opportunities worth $20-$100/month per developer.

## The Balance Between Exploration and Efficiency

Some file exploration is healthy and necessary. A developer who restricts Claude to reading only the exact file mentioned in the prompt may prevent Claude from catching related issues or understanding broader implications. The goal is not zero exploration but efficient exploration -- reading 2-3 contextually relevant files rather than 10 loosely related ones. A relevance ratio of 85-95% allows enough exploration for quality while preventing the 40-60% waste seen in unoptimized sessions.

## Related Guides

- [Claude Code reading too many files](/claude-code-reading-too-many-files-scope-context/) -- broader file reading optimization
- [CLAUDE.md Token Optimization](/claude-md-token-optimization-rules-save-money/) -- optimizing the context document
- [Cost Optimization Hub](/cost-optimization/) -- all optimization techniques
