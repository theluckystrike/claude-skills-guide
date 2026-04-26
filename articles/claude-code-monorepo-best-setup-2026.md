---
layout: default
title: "Claude Code Monorepo: Best Setup Guide (2026)"
description: "Configure Claude Code for monorepos with per-package CLAUDE.md files, scoped tool permissions, and workspace-aware dependency management rules."
permalink: /claude-code-monorepo-best-setup-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Claude Code Monorepo: Best Setup Guide (2026)

Monorepos amplify every Claude Code problem — wrong package dependencies, cross-package import mistakes, files in wrong directories. Here's the setup that tames it.

## The Problem

In a monorepo, Claude Code:
- Installs dependencies at the root instead of in the specific package
- Uses relative imports between packages instead of workspace imports
- Creates files in the wrong package directory
- Doesn't know which tsconfig/eslint config applies to which package
- Modifies shared packages without understanding downstream impact

## Root Cause

Claude Code sees one project root. It doesn't inherently understand workspace boundaries, package scoping, or the dependency direction between packages.

## The Fix

### 1. Root CLAUDE.md for Global Rules

```markdown
# Monorepo: my-project

## Structure
- packages/api — Express API (TypeScript)
- packages/web — Next.js frontend (TypeScript)
- packages/shared — shared types and utilities
- packages/cli — CLI tool (TypeScript)

## Monorepo Rules
- Dependencies: ALWAYS use `pnpm add <pkg> --filter <workspace>`, NEVER `pnpm add` at root
- Imports between packages: use workspace names `@myorg/shared`, NEVER relative paths `../../shared`
- Each package has its own tsconfig.json, eslint config, and test setup
- Before modifying @myorg/shared, list all packages that import from it

## Package Boundaries
- packages/api depends on @myorg/shared
- packages/web depends on @myorg/shared
- packages/cli depends on @myorg/shared
- @myorg/shared depends on nothing — no imports from other packages
```

### 2. Per-Package CLAUDE.md Files

Create `packages/api/CLAUDE.md`:

```markdown
# API Package
- Framework: Express with tRPC
- ORM: Drizzle
- Tests: Vitest
- All routes in src/routes/
- All services in src/services/
```

### 3. Workspace-Aware Commands

Add to [commands](/understanding-claude-code-hooks-system-complete-guide/):

```markdown
# .claude/commands/add-dep.md
When adding a dependency to this monorepo:
1. Identify which package needs it
2. Run: pnpm add <package> --filter @myorg/<workspace>
3. Never install at the root unless it's a dev tool used by all packages
```

## CLAUDE.md Rule to Add

```markdown
## Cross-Package Changes
Before modifying @myorg/shared:
1. List all packages that import the changed code
2. Check if the change breaks any consumer
3. Update consumers if needed
4. Run tests in ALL affected packages, not just @myorg/shared
```

## Verification

```
Add a date formatting utility to the shared package
```

**Bad:** creates `packages/shared/src/utils/date.ts`, adds `date-fns` to root `package.json`
**Good:** creates the utility in `packages/shared/src/utils/`, runs `pnpm add date-fns --filter @myorg/shared`, verifies no downstream breaks

Related: [CLAUDE.md Best Practices](/claude-md-best-practices-10-templates-compared-2026/) | [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/) | [Karpathy Don't Assume Examples](/karpathy-dont-assume-examples-real-projects-2026/)

## See Also

- [Claude Code Monorepo Workspace Resolution Failure — Fix (2026)](/claude-code-monorepo-workspace-resolution-failure-fix/)
- [Monorepo Workspace Package Resolution — Fix (2026)](/claude-code-monorepo-workspace-package-resolution-fix-2026/)
- [Make Claude Code Write Tests First (TDD) (2026)](/claude-code-write-tests-first-tdd-setup-2026/)
- [Claude Code Tab Completion Setup Guide 2026](/claude-code-tab-completion-setup-2026/)
- [How to Set Up Claude Code in Ghostty Terminal 2026](/claude-code-ghostty-terminal-setup-2026/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


## Best Practices

1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency.

2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed.

3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions.

4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops).

5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like "refactor auth, add tests, and update docs" produce better results when broken into three separate prompts, each building on the previous result.


## Common Issues

**Claude Code ignores the configuration:** Ensure the configuration file is in the correct location. CLAUDE.md must be in the project root (the directory where you run `claude`). Settings go in `.claude/settings.json`. Verify with `ls -la CLAUDE.md .claude/settings.json`.

**Changes are not taking effect:** Claude Code reads CLAUDE.md at the start of each session. If you modify it during a session, the changes apply to new conversations but not the current one. Start a new session to pick up configuration changes.

**Slow performance on large projects:** Add a `.claudeignore` file to exclude large directories (node_modules, .git, dist, build, vendor). This reduces file scanning time and prevents Claude from reading irrelevant files. The format is identical to `.gitignore`.

**Unexpected file modifications:** Check `.claude/settings.json` for overly broad permission patterns. Narrow the allow list to specific commands and file patterns. For sensitive directories, add explicit deny rules.


## Related Guides

- [Claude Code GCP MCP Server Setup](/claude-code-gcp-mcp/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)
- [Setup: Neovim AI Coding Setup](/neovim-ai-coding-setup-with-claude-2026/)
- [Claude Code Setup on Mac](/claude-code-setup-on-mac-step-by-step/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a CLAUDE.md file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring .claude/settings.json for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your .claude/ directory and CLAUDE.md to version control so the entire team uses the same configuration. Each developer can add personal preferences in ~/.claude/settings.json (user-level) without affecting the project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation."
      }
    }
  ]
}
</script>
