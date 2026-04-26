---
layout: default
title: "Claude Code Git Workflow Guide (2026)"
description: "Use Claude Code for git operations: commits, branches, PRs, rebases, and conflict resolution with proper permission configuration."
date: 2026-04-15
permalink: /claude-code-with-git-workflow-guide/
categories: [guides, claude-code]
tags: [git, workflow, commits, branches, pull-requests]
last_modified_at: 2026-04-17
geo_optimized: true
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

**[Get the CLAUDE.md for your stack →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-beforeafter&utm_campaign=claude-code-with-git-workflow-guide)**

</div>

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-with-git-workflow-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

---



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Best Way to Validate Claude Code Output Before Committing](/best-way-to-validate-claude-code-output-before-committing/)
- [Claude Code GitHub Actions Setup Guide](/claude-code-github-actions-setup-guide/)
- [Best Way to Use Claude Code with Existing CI/CD](/best-way-to-use-claude-code-with-existing-ci-cd/)
- [AI Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/)



## Related Articles

- [Claude Code for Git Stash Advanced Workflow](/claude-code-for-git-stash-advanced-workflow/)
- [Claude Code for Git Absorb Workflow Tutorial](/claude-code-for-git-absorb-workflow-tutorial/)
- [Claude Code Git Cherry-Pick Workflow Guide](/claude-code-git-cherry-pick-workflow-guide/)
- [Claude Code for Git Filter-Repo Workflow](/claude-code-for-git-filter-repo-workflow/)
