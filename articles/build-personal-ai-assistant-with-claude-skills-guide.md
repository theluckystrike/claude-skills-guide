---
layout: post
title: "Build a Personal AI Assistant with Claude Skills Guide"
description: "Configure Claude Code as a personal assistant: /supermemory for persistent context, custom skills for daily tasks, and dotfiles for portability."
date: 2026-03-13
categories: [guides]
tags: [claude-code, claude-skills, supermemory, personal-assistant, custom-skills]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Build Personal AI Assistant with Claude Skills Guide

A personal AI assistant is useful only if it actually knows how you work — your coding conventions, your preferred tools, your recurring tasks. Generic AI chat gets you halfway there. Claude skills close the gap by letting you encode your personal workflows as reusable, invokable behaviors that persist across every session.

This guide walks through building a personal AI assistant tailored to a developer's daily workflow. You will set up persistent memory, create custom skills for your most common tasks, and wire them into a system that feels genuinely assistive rather than just reactive.

## What Makes Claude Skills Different from Plain Prompting

Before building, understand what skills actually are. Claude skills are Markdown files stored in `~/.claude/skills/`. When you invoke `/skill-name` inside a Claude Code session, Claude reads that file as part of its context and follows the instructions inside it.

This means skills are:
- **Persistent**: they do not disappear when you close a session
- **Composable**: you can invoke multiple skills in sequence
- **Version-controlled**: they are plain text files you can commit to a dotfiles repo
- **Shareable**: you can publish them to a skills hub or share with teammates

The `supermemory` skill extends this further by storing structured information about you, your projects, and your preferences. The `tdd` skill gives you test-driven development guidance on demand. The `pdf` skill handles document generation. The `frontend-design` skill accelerates UI work. These are your building blocks.

## Step 1: Set Up Your Personal Memory Layer

The foundation of any personal assistant is memory. Without it, every session starts from zero and you repeat context constantly. The `supermemory` skill solves this.

Create your personal context file. In a Claude Code session:

```
/supermemory
Store my developer profile:
- Name: [your name]
- Primary languages: TypeScript, Python
- Preferred testing framework: Vitest (not Jest)
- Code style: functional over class-based, explicit types, no magic numbers
- Preferred package manager: pnpm
- OS: macOS, shell: zsh
- Editor: Neovim with LSP
- Common project types: REST APIs, CLI tools, automation scripts
- I prefer concise explanations — skip introductions, get to the answer
```

This profile gets recalled automatically when you invoke supermemory at the start of a session. Claude Code then adapts all suggestions to your preferences without you asking.

Add project-specific context as you work:

```
/supermemory
Add to my active projects:
- Project: invoice-cli
- Stack: Node.js, TypeScript, SQLite, inquirer.js
- Status: building v2, adding recurring invoice support
- Key files: src/commands/generate.ts, src/db/schema.ts
- Deployment: npm package, published to registry
```

## Step 2: Create a Morning Briefing Skill

A personal assistant should give you an orientation each morning — what is outstanding, what is scheduled, what needs attention. Create a skill for this.

Create `~/.claude/skills/morning-brief.md`:

```markdown
# morning-brief

You are a personal productivity assistant. When invoked, help the user start their day with focus.

1. Ask the user to paste their git log for the last day:
   `git log --since="24 hours ago" --oneline`

2. Ask what is on their calendar or task list today

3. Based on their response, produce:
   - **Yesterday summary**: 2-3 sentences about what was accomplished based on commits
   - **Today's priorities**: ranked list of 3-5 things to focus on
   - **Blockers**: anything that looks like it needs resolution before proceeding
   - **Quick wins**: small tasks that can be done in under 30 minutes

Be direct and concise. Do not pad the output. Treat the user as a senior developer who needs signal, not noise.
```

Invoke it each morning:

```
/morning-brief
Here is my git log: [paste output]
Today I have a 10am design review and need to ship the recurring invoice feature by Friday.
```

## Step 3: Create a Code Review Skill

Code review is one of the highest-use tasks you can partially automate. Build a personal review skill tuned to your standards:

Create `~/.claude/skills/my-review.md`:

```markdown
# my-review

You are a senior code reviewer with the following personal standards:
- Flag any function longer than 40 lines as a refactor candidate
- Flag any variable named with single letters (except i, j in loops)
- Check for missing error handling on all async functions
- Verify TypeScript types are not using `any`
- Check for console.log statements left in production code
- Verify new public functions have JSDoc comments
- Check imports are sorted (standard library first, then third-party, then local)

When reviewing code, provide feedback as a numbered list sorted by severity:
1. CRITICAL — must fix before merge
2. IMPORTANT — should fix
3. SUGGESTION — optional improvement

Be terse. Skip praise. Focus on what needs to change.
```

Use it before committing:

```
/my-review
Review this diff before I commit:
[paste git diff output]
```

## Step 4: Build a Daily Task Automation Skill

For recurring tasks — writing commit messages, generating changelogs, summarizing PRs — create dedicated skills so you never have to re-explain context.

**Commit message generator** — `~/.claude/skills/commit-msg.md`:

```markdown
# commit-msg

Generate a conventional commit message for the provided diff.

Format: <type>(<scope>): <subject>

Types: feat, fix, docs, style, refactor, test, chore
- Keep subject under 72 characters
- Use imperative mood: "add" not "added"
- Scope is the primary file or module affected
- If the diff touches multiple unrelated areas, suggest splitting into separate commits

Return only the commit message. No explanation needed.
```

**Changelog entry generator** — `~/.claude/skills/changelog.md`:

```markdown
# changelog

Generate a changelog entry for the provided commits.

Format:
## [version] — YYYY-MM-DD

### Added
- [new features]

### Changed
- [modifications to existing behavior]

### Fixed
- [bug fixes]

### Removed
- [deprecated or removed features]

Base the entry on the commit messages provided. Keep each line under 100 characters.
Write for a technical audience. Skip internal refactors unless they affect behavior.
```

## Step 5: Wire Skills with Supermemory for Long-Term Context

The real power comes from combining skills with persistent memory. When starting any new coding session:

```
/supermemory
Retrieve my developer profile and current active project context.
```

Then invoke the appropriate skill. Because supermemory provides your preferences, the skill output is already tuned to how you work without repeating yourself.

For longer projects, store decisions as you make them:

```
/supermemory
Store this architecture decision for invoice-cli:
- Decision: use SQLite over PostgreSQL
- Rationale: CLI tool runs locally, no server needed, user owns their data
- Date: 2026-03-13
- Trade-off: no multi-user support, acceptable for personal billing tool
```

Retrieve it months later when you forget why you made that choice:

```
/supermemory
What was my rationale for using SQLite in invoice-cli?
```

## Step 6: Store Your Skill Library in Dotfiles

Skills are just text files. Back them up and version-control them with your dotfiles:

```bash
# Add skills to your dotfiles repo
mkdir -p ~/dotfiles/claude/skills
ln -s ~/dotfiles/claude/skills ~/.claude/skills

cd ~/dotfiles
git add claude/skills/
git commit -m "chore: add Claude personal assistant skills"
git push
```

When you set up a new machine, restoring your entire personal assistant takes one `git clone` and one symlink.

## Building the Habit

A personal assistant is only as useful as how consistently you use it. Suggested daily routine:

- **Morning**: `/morning-brief` with yesterday's git log and today's task list
- **Before commit**: `/my-review` on your diff, then `/commit-msg` to generate the message
- **After significant changes**: `/supermemory` to store any new architectural decisions
- **Weekly**: generate a changelog with `/changelog` from the week's commits

Over two to three weeks, the system accumulates enough context that Claude Code starts feeling like it genuinely knows your codebase and preferences. The `supermemory` layer means you stop repeating yourself. The custom skills mean common tasks take seconds instead of minutes.

---

## Related Reading

- [Claude Skills Automated Blog Post Workflow Tutorial](/claude-skills-guide/articles/claude-skills-automated-blog-post-workflow-tutorial/) — Apply skills to content creation
- [Full Stack Web App with Claude Skills Step by Step](/claude-skills-guide/articles/full-stack-web-app-with-claude-skills-step-by-step/) — Skills across the full development lifecycle
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) — Full developer skill stack reference

Built by theluckystrike — More at [zovo.one](https://zovo.one)
