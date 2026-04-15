---
layout: default
title: "Claude Code Git Workflow Guide"
description: "Use Claude Code for git operations: commits, branches, PRs, rebases, and conflict resolution with proper permission configuration."
date: 2026-04-15
permalink: /claude-code-with-git-workflow-guide/
categories: [guides, claude-code]
tags: [git, workflow, commits, branches, pull-requests]
---

# Claude Code Git Workflow Guide

## The Problem

You want Claude Code to handle git operations like creating branches, writing commit messages, resolving merge conflicts, and opening pull requests, but you need to configure permissions correctly and understand what Claude can do safely.

## Quick Fix

Pre-approve safe git commands and add your git workflow to CLAUDE.md:

```json
{
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git checkout *)",
      "Bash(git branch *)"
    ],
    "deny": [
      "Bash(git push --force *)",
      "Bash(git reset --hard *)"
    ]
  }
}
```

## What's Happening

Claude Code includes built-in git instructions in its system prompt by default. These instructions tell Claude how to create commits, write PR descriptions, check status, and handle common git operations. Claude prefers creating new commits over amending existing ones, stages specific files rather than using `git add -A`, and never skips hooks or force pushes unless explicitly asked.

You can customize or disable these built-in instructions with the `includeGitInstructions` setting.

## Step-by-Step Fix

### Step 1: Configure git command permissions

Add safe git commands to your allow list. Block destructive commands:

```json
{
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git checkout *)",
      "Bash(git branch *)",
      "Bash(git merge *)",
      "Bash(git rebase *)",
      "Bash(git stash *)",
      "Bash(git fetch *)",
      "Bash(git pull *)"
    ],
    "deny": [
      "Bash(git push --force *)",
      "Bash(git reset --hard *)",
      "Bash(git clean -f *)"
    ]
  }
}
```

Note: `git push` without `--force` can be in either allow or ask depending on your preference.

### Step 2: Add git workflow to CLAUDE.md

```markdown
# Git Workflow
- Branch naming: feature/TICKET-description, fix/TICKET-description
- Commit messages: conventional commits (feat:, fix:, refactor:, test:, docs:)
- Always run `pnpm test` before committing
- Create feature branches from `main`
- Never commit directly to `main`
```

### Step 3: Let Claude create commits

Ask Claude to commit with a descriptive message:

```text
Stage and commit the changes with a descriptive commit message
```

Claude will:
1. Run `git status` to see changes
2. Run `git diff` to understand what changed
3. Stage specific files (not `git add -A`)
4. Write a commit message based on the changes
5. Create the commit

### Step 4: Create pull requests

Claude can use the `gh` CLI to create pull requests:

```text
Create a PR for this branch with a summary of all changes
```

Pre-approve the `gh` command:

```json
{
  "permissions": {
    "allow": [
      "Bash(gh pr create *)",
      "Bash(gh pr view *)",
      "Bash(gh issue view *)"
    ]
  }
}
```

### Step 5: Resolve merge conflicts

```text
Merge main into this branch and resolve any conflicts
```

Claude will:
1. Run `git merge main`
2. Identify conflicting files
3. Read each conflict
4. Resolve conflicts based on the intent of both changes
5. Stage and commit the resolution

### Step 6: Interactive rebase and cleanup

```text
Squash the last 3 commits into one with a clean commit message
```

Note: Claude avoids interactive flags (`-i`) since they require terminal interaction. It uses non-interactive alternatives like `git rebase --onto` or `git reset --soft` followed by a new commit.

### Step 7: Configure attribution

Claude Code adds a co-authored-by line to commits by default. Customize this:

```json
{
  "attribution": {
    "commit": "Generated with Claude Code",
    "pr": ""
  }
}
```

Set `"pr": ""` to skip attribution in PR descriptions.

### Step 8: Disable built-in git instructions

If you use your own git workflow skills, disable the built-in instructions:

```json
{
  "includeGitInstructions": false
}
```

This removes the built-in commit and PR workflow instructions from Claude's system prompt.

## Prevention

Always deny `git push --force` and `git reset --hard` in your permission rules. These destructive commands should require explicit human approval. Pre-approve read-only git commands (`status`, `diff`, `log`) for frictionless workflow.

Add your team's git conventions to CLAUDE.md so Claude creates commits and branches that match your standards.

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

---


<div class="author-bio">
<strong>Built by Michael</strong> · Top Rated Plus on Upwork · $400K+ earned building with AI · 16 Chrome extensions · 3,000+ users · Building with Claude Code since launch.
<a href="https://zovo.one/lifetime?utm_source=ccg&utm_medium=author-bio&utm_campaign=social-proof">See what I ship with →</a>
</div>

---


<div class="before-after">
<div class="before">
<h4>Without CLAUDE.md</h4>
<p>You: "Add authentication to my Next.js app"</p>
<p>Claude Code generates a <code>pages/</code> directory (your App Router uses <code>app/</code>), picks NextAuth v4 (v5 is current), creates <code>.js</code> files in a TypeScript project, and uses <code>getServerSession</code> incorrectly with the wrong adapter pattern.</p>
<p><strong>Result:</strong> You spend 45 minutes fixing what Claude broke.</p>
</div>
<div class="after">
<h4>With a Professional CLAUDE.md</h4>
<p>You: Same prompt.</p>
<p>Claude Code reads CLAUDE.md &rarr; knows App Router + TypeScript strict + NextAuth v5 &rarr; generates <code>app/api/auth/[...nextauth]/route.ts</code> with correct session handling, middleware config, and type-safe session types that match your existing schema.</p>
<p><strong>Result:</strong> It works on the first run. You ship.</p>
</div>
</div>

<div class="mastery-cta">

**What if Claude Code got it right the first time?**

16 CLAUDE.md templates for popular frameworks. 80 tested prompts. Multi-agent configs. Workflow playbooks. The complete toolkit for shipping production code with Claude Code.

**[See the setup that ships →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-with-git-workflow-guide)**

$99 once. Yours forever. 47/500 founding spots left.

</div>

---

## Related Guides

- [Best Way to Validate Claude Code Output Before Committing](/best-way-to-validate-claude-code-output-before-committing/)
- [Claude Code GitHub Actions Setup Guide](/claude-code-github-actions-setup-guide/)
- [Best Way to Use Claude Code with Existing CI/CD](/best-way-to-use-claude-code-with-existing-ci-cd/)
- [AI Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/)
