---
title: "Claude Code reading too many files (2026)"
description: "Fix Claude Code reading too many files by scoping context with .claudeignore, CLAUDE.md file budgets, and directory boundaries to save 50K+ tokens per task."
permalink: /claude-code-reading-too-many-files-scope-context/
date: 2026-04-22
last_tested: "2026-04-22"
---

# Claude Code reading too many files -- how to scope context

## The Problem

Claude Code reads 15-30 files to understand a project before making a single change. On a 500-file project, this exploration phase consumes 50K-150K tokens ($0.15-$0.45 on Sonnet 4.6) before any useful work begins. The symptom: running `/cost` after Claude's first response shows 50K+ input tokens, and the response is "I've reviewed the project structure and here's my plan" -- with zero actual changes made.

## Quick Fix (2 Minutes)

Create a `.claudeignore` file in the project root:

```bash
cat > .claudeignore << 'EOF'
node_modules/
dist/
build/
.git/
coverage/
__snapshots__/
*.min.js
*.map
*.lock
vendor/
EOF
```

Then add a file budget to CLAUDE.md:

```markdown
# Add to CLAUDE.md
## File Reading Rules
- Maximum 5 files before proposing a solution
- Use Grep to search, not Read to browse
- If you need more context, ask which files to read
```

## Why This Happens

Claude Code's agentic behavior includes a discovery phase: before acting on a task, it builds a mental model of the project. Without guidance, Claude defaults to broad exploration:

1. **File tree scan:** Lists directories to understand structure (~2K tokens)
2. **Config files:** Reads package.json, tsconfig.json, etc. (~3K tokens)
3. **Entry points:** Reads index.ts/main.ts files (~5K tokens)
4. **Related files:** Reads files that might be relevant to the task (~30K-100K tokens)

This behavior is rational for an agent with no prior knowledge. The problem is that steps 2-4 are wasteful when the knowledge could be pre-loaded via CLAUDE.md or skills at 1% of the token cost.

The token mechanics: each Read tool call costs ~150 tokens of overhead plus the file content. A 200-line TypeScript file is approximately 2,500 tokens. Reading 20 files: 20 x (150 + 2,500) = 53,000 tokens. With CLAUDE.md pre-loading: 400 tokens.

## The Full Fix

### Step 1: Diagnose

Check how many files Claude reads in a typical session:

```bash
# Start a session and give a simple task
claude "Add input validation to the createUser function in src/services/user.ts"

# After Claude responds, check cost
/cost
# If input tokens > 40K for a single-file task, Claude is reading too many files
```

### Step 2: Fix

**Layer 1: .claudeignore (hard exclusion)**

```bash
# .claudeignore
node_modules/
dist/
build/
.git/
coverage/
__snapshots__/
*.min.js
*.min.css
*.map
*.lock
vendor/
legacy/
docs/archive/
```

This reduces the searchable file tree by 60-90% depending on the project.

**Layer 2: CLAUDE.md project map (soft guidance)**

```markdown
# CLAUDE.md

## Project Structure
- src/routes/ -- Express route handlers (18 files)
- src/services/ -- business logic (12 files)
- src/repositories/ -- database queries (8 files)
- src/middleware/ -- Express middleware (5 files)
- src/types/ -- TypeScript interfaces (4 files)
- __tests__/ -- Jest tests, mirrors src/

## File Reading Rules
- Read at most 5 files before proposing a solution
- Always read the target file first, then its direct dependencies
- Use Grep to find references, not Read to browse
- Never read test files unless the task is about tests
```

**Layer 3: Skills for domain knowledge (eliminates exploration)**

```markdown
# .claude/skills/project-context.md

## Key Dependencies
- user.ts imports: repositories/user.ts, types/user.ts, utils/validation.ts
- post.ts imports: repositories/post.ts, types/post.ts, services/user.ts
- auth middleware: uses services/auth.ts, types/auth.ts
```

### Step 3: Prevent

Add monitoring to catch regression:

```markdown
# CLAUDE.md

## Cost Awareness
- If more than 5 files need to be read, explain why before reading them
- Report estimated token usage at the start of complex tasks
- Run /compact after completing each major task in a session
```

## Cost Recovery

If a session has already consumed excessive tokens from file reading:

```bash
# Compact the session to recover context space
/compact

# Then redirect with a specific instruction
"Focus only on src/services/user.ts. Do not read any other files unless I ask."
```

The `/compact` command recovers 60-80% of the context window, effectively reclaiming the tokens wasted on unnecessary file reads.

## Prevention Rules for CLAUDE.md

Copy-paste these rules into any project's CLAUDE.md:

```markdown
## Context Scoping Rules
- Maximum 5 files read per task before proposing a solution
- Always start with the file mentioned in the task
- Use Grep (not Read) to find function references
- Never read node_modules/, dist/, or build/ directories
- If a task seems to require reading 10+ files, ask which are most relevant
- After every 5 files read, state what you have learned and propose a plan
```

These rules typically reduce per-task file reads from 15-30 down to 3-7, saving 30K-80K tokens per task. At 15 tasks/day on Sonnet 4.6: $2.97-$7.92/day, or **$65-$174/month** per developer.

## How Many Files Is Normal?

Use these benchmarks to determine whether Claude's file reading behavior is within expected ranges:

| Task Type | Expected Files Read | If Exceeding |
|-----------|-------------------|-------------|
| Bug fix (1 file mentioned) | 1-3 | CLAUDE.md needs project map |
| Feature (2-3 files specified) | 3-5 | Add file budget rule |
| Refactor (module-level) | 5-8 | Use skills for module context |
| Architecture review | 8-12 | Acceptable for this task type |
| "Improve the codebase" | 15-30 | Task is too vague, be specific |

The last row highlights a key insight: vague tasks cause the most excessive file reading. "Improve the codebase" gives Claude no scope boundary, so it reads everything. "Improve error handling in src/auth/validate.ts" limits reads to 2-3 files.

## Monitoring File Read Behavior

Track Claude's file reading patterns to identify when scoping rules are not working:

```bash
# During a session, Claude's tool calls show which files are being read
# Watch for these patterns:

# Pattern 1: Config file reads (wasteful for most tasks)
# Seeing: package.json, tsconfig.json, .eslintrc, jest.config
# Fix: add project context to CLAUDE.md

# Pattern 2: Test file reads (wasteful for non-test tasks)
# Seeing: __tests__/auth.test.ts, __tests__/user.test.ts
# Fix: add CLAUDE.md rule "never read test files unless task is about tests"

# Pattern 3: Sibling file reads (sometimes necessary, often not)
# Seeing: routes/users.ts, routes/posts.ts, routes/comments.ts
# Claude reads similar files to learn patterns
# Fix: document patterns in CLAUDE.md or skills

# Pattern 4: Deep directory scanning
# Seeing: ls src/, ls src/routes/, ls src/services/, ls src/utils/
# Fix: add directory map to CLAUDE.md
```

## The .claudeignore Optimization Ladder

Start with aggressive exclusions and relax as needed:

### Level 1: Universal Exclusions (apply to every project)

```bash
node_modules/
.git/
dist/
build/
coverage/
*.lock
*.map
*.min.js
*.min.css
```

### Level 2: Project-Type Exclusions

```bash
# Add for Node.js/TypeScript projects:
__snapshots__/
.turbo/
.next/
.nuxt/

# Add for Python projects:
__pycache__/
.venv/
*.pyc
.mypy_cache/

# Add for Go projects:
vendor/
```

### Level 3: Project-Specific Exclusions

```bash
# Based on audit findings:
legacy/        # Old code not being modified
docs/archive/  # Outdated documentation
scripts/internal/  # DevOps scripts irrelevant to development
fixtures/large/    # Large test data files
```

Each level progressively reduces the searchable file tree. Level 1 alone typically reduces it by 60-80%. Levels 2-3 push reduction to 85-95%.

## Related Guides

- [Why Claude Code Gets Expensive on Large Projects](/why-claude-code-expensive-large-projects-fix/) -- comprehensive guide for large codebases
- [Claude Code Context Window Management](/claude-code-context-window-management-2026/) -- understanding context mechanics
- [Cost Optimization Hub](/cost-optimization/) -- all cost reduction techniques

## See Also

- [System Prompt Exceeds Token Limit — Fix (2026)](/claude-code-system-prompt-too-many-tokens-fix-2026/)
- [File Watcher EMFILE Too Many Open Files Fix](/claude-code-file-watcher-emfile-too-many-open-files-fix-2026/)
- [Claude Code subagent spawning too many agents — cost control](/claude-code-subagent-spawning-too-many-cost-control/)
- [Claude Code spending tokens on files I didn](/claude-code-spending-tokens-files-didnt-ask-about/)
