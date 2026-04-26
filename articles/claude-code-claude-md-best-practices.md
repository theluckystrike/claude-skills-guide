---
layout: default
title: "CLAUDE.md Best Practices for Projects (2026)"
description: "Write effective CLAUDE.md files that Claude Code follows consistently. Scoping, structure, imports, and rules for team projects. Updated for 2026."
last_tested: "2026-04-22"
date: 2026-04-15
permalink: /claude-code-claude-md-best-practices/
categories: [guides, claude-code]
tags: [CLAUDE.md, memory, instructions, configuration, team]
last_modified_at: 2026-04-17
geo_optimized: true
---

# CLAUDE.md Best Practices for Projects

## The Problem

You have a CLAUDE.md file but Claude Code does not consistently follow your instructions. Rules get ignored, the file has grown unwieldy, and your team members have conflicting configurations.

## Quick Fix

Keep CLAUDE.md under 200 lines. Use specific, verifiable instructions instead of vague guidance:

```markdown
# CLAUDE.md
- Use 2-space indentation for TypeScript
- Run `pnpm test` before committing
- API handlers go in src/api/handlers/
- Never import from src/internal/ in public modules
```

## What's Happening

CLAUDE.md files are loaded into the context window at the start of every session, consuming tokens alongside your conversation. Claude treats them as context rather than enforced configuration. The more specific and concise your instructions, the more consistently Claude follows them.

Longer files consume more context and reduce adherence because Claude must balance more instructions against the actual task. Vague instructions like "format code properly" give Claude no clear criteria to verify against, while "use 2-space indentation" is unambiguous.

Claude Code supports CLAUDE.md files at multiple scopes, each with different loading behavior. Understanding this hierarchy is key to effective configuration.

## Step-by-Step Fix

### Step 1: Choose the right location

| Scope | Location | Use for |
|-------|----------|---------|
| Managed policy | `/Library/Application Support/ClaudeCode/CLAUDE.md` | Org-wide standards |
| Project | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team-shared instructions |
| User | `~/.claude/CLAUDE.md` | Personal preferences |
| Local | `./CLAUDE.local.md` | Personal project overrides |

Project CLAUDE.md files are shared via version control. Local files are gitignored for personal preferences.

### Step 2: Generate a starting point

Run `/init` in Claude Code to auto-generate a CLAUDE.md based on your codebase:

```text
/init
```

Claude analyzes your project and creates a file with build commands, test instructions, and conventions it discovers. If a CLAUDE.md already exists, `/init` suggests improvements.

### Step 3: Write specific, verifiable instructions

Every instruction should be concrete enough to verify:

```markdown
# Build & Test
- Build: `pnpm build`
- Test: `pnpm test`
- Lint: `pnpm lint`
- Type check: `pnpm tsc --noEmit`

# Code Conventions
- Use 2-space indentation
- Prefer named exports over default exports
- Error types extend AppError from src/errors/base.ts
- All API endpoints must validate input with zod schemas

# Architecture
- src/api/handlers/ - HTTP request handlers
- src/services/ - Business logic
- src/models/ - Database models
- src/utils/ - Shared utilities (never import from services/)
```

### Step 4: Use imports for large documentation

Instead of cramming everything into CLAUDE.md, import files:

```markdown
See @README for project overview and @package.json for npm commands.

# Additional Instructions
- git workflow @docs/git-instructions.md
- API conventions @docs/api-conventions.md
```

Imported files are expanded and loaded at launch. Relative paths resolve relative to the CLAUDE.md file.

### Step 5: Use .claude/rules/ for scoped instructions

For instructions that only apply to specific file types or directories, use rules files:

Create `.claude/rules/typescript.md`:

```markdown
---
paths:
 - "**/*.ts"
 - "**/*.tsx"
---
- Use strict TypeScript: no `any` types
- All functions must have explicit return types
- Use `interface` over `type` for object shapes
```

Rules with `paths:` frontmatter load only when Claude reads matching files, keeping baseline context small.

### Step 6: Handle monorepo CLAUDE.md files

In large monorepos, CLAUDE.md files from other teams get picked up when Claude walks the directory tree. Use `claudeMdExcludes` to skip irrelevant files:

```json
{
 "claudeMdExcludes": [
 "packages/team-b/**",
 "services/legacy/**"
 ]
}
```

Add this to your settings to prevent other teams' CLAUDE.md files from loading.

### Step 7: Understand compaction behavior

After compaction, project-root CLAUDE.md and auto memory re-inject from disk automatically. Path-scoped rules and subdirectory CLAUDE.md files are lost until Claude reads a matching file again.

If a rule must persist across compaction, remove the `paths:` frontmatter or move it to the project-root CLAUDE.md.

### Step 8: Separate personal from team instructions

Use `CLAUDE.local.md` for personal preferences that should not affect your team:

```markdown
# CLAUDE.local.md (gitignored)
- I prefer verbose error messages in test output
- Always show me the full diff before committing
- My sandbox URL: http://localhost:3001
```

## Prevention

Review CLAUDE.md quarterly. Remove outdated instructions and consolidate duplicates. When Claude makes the same mistake twice, add a specific rule. When a code review catches something Claude should know, add it to CLAUDE.md.

Target under 200 lines per file. Use `.claude/rules/` files for type-specific instructions and skills for multi-step procedures. This keeps the per-session context overhead minimal.

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---


<div class="before-after">

**Without a CLAUDE.md — what actually happens:**

You type: "Add auth to my Next.js app"

Claude generates: `pages/api/auth/[...nextauth].js` — wrong directory (you're on App Router), wrong file extension (you use TypeScript), wrong NextAuth version (v4 patterns, you need v5), session handling that doesn't match your middleware setup.

You spend 40 minutes reverting and rewriting. Claude was "helpful."

**With the Zovo Lifetime CLAUDE.md:**

Same prompt. Claude reads 300 lines of context about YOUR project. Generates: `app/api/auth/[...nextauth]/route.ts` with v5 patterns, your session types, your middleware config, your test patterns.

Works on first run. You commit and move on.

That's the difference a $99 file makes.

**[Get the CLAUDE.md for your stack →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-beforeafter&utm_campaign=claude-code-claude-md-best-practices)**

</div>

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-claude-md-best-practices)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

---



**Build yours →** Create a custom CLAUDE.md with our [Generator Tool](/generator/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [CLAUDE.md best practices definitive guide](/claude-md-best-practices-definitive-guide/) — the definitive CLAUDE.md reference
- [Claude Code hooks](/claude-code-hooks-complete-guide/) — hook into tool execution
- [Claude Code spec workflow](/claude-code-spec-workflow-guide/) — spec-first development patterns
- [Super Claude Code framework](/super-claude-code-framework-guide/) — structured prompting on top of CLAUDE.md
- [Best Way to Set Up Claude Code for a New Project](/best-way-to-set-up-claude-code-for-new-project/)
- [Best Way to Integrate Claude Code into Team Workflow](/best-way-to-integrate-claude-code-into-team-workflow/)
- [Claude Code 2026 New Features Skills and Hooks Roundup](/claude-code-2026-new-features-skills-and-hooks-roundup/)
- [Best Way to Give Claude Code Repeatable Output](/best-way-to-give-claude-code-repeatable-deterministic-output/)

## See Also

- [Claude Code CLAUDE.md Best Practices for Teams 2026](/claude-code-claude-md-best-practices-teams-2026/)
