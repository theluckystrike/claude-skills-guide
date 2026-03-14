---
layout: default
title: "Claude Code Error: Git Push Rejected During Skill Fix"
description: "Resolve git push rejection errors when fixing Claude skills. Practical solutions for developers dealing with remote changes, branch conflicts, and skill synchronization issues."
date: 2026-03-14
categories: [troubleshooting]
tags: [claude-code, git, error-fix, claude-skills, debugging]
author: theluckystrike
reviewed: true
score: 5
permalink: /claude-code-error-git-push-rejected-during-skill-fix/
---

# Claude Code Error: Git Push Rejected During Skill Fix

When working with Claude Code and custom skills, you may encounter a frustrating scenario: you fix a bug in your skill, attempt to push your changes, and Git rejects your push with an error message about remote changes or branch protection. This guide walks through the common causes of this issue and provides practical solutions for developers and power users.

## Understanding the Rejection Error

The git push rejection typically manifests in one of these forms:

```
error: failed to push some refs to 'git@github.com:yourrepo/yourproject.git'
hint: You have diverged commits
! [rejected] main -> main (fetch first)
error: failed to push some refs to 'remote'
```

This occurs when your local branch has diverged from the remote branch. In the context of Claude skills, this usually happens because the skill definition files were modified elsewhere—perhaps through another session, an automated CI pipeline, or a different machine syncing your skills.

## Why This Happens with Claude Skills

Claude skills live in your repository as `.md` files with specific front matter formatting. When you use skills like `frontend-design` to generate code, `pdf` to create documentation, or `tdd` to scaffold tests, these tools may modify files in your repository. If you're simultaneously working on skill fixes across multiple environments, remote divergence becomes likely.

Consider this workflow: you notice your custom skill `supermemory` has an outdated pattern. You open Claude Code on your laptop, edit the skill file, and prepare to push. Meanwhile, your desktop machine auto-synced a newer version or a CI job updated the skill metadata. Now your push fails because Git sees conflicting histories.

## Resolving the Push Rejection

### Option 1: Pull and Merge (Recommended for Most Cases)

The simplest approach uses standard Git workflow:

```bash
# First, fetch the latest changes
git fetch origin

# View the differences
git log HEAD..origin/main --oneline

# Pull and merge the remote changes
git pull origin main

# Resolve any conflicts in your skill files
# Edit the conflicted files, then:
git add .

# Commit the merge
git commit -m "Merge remote changes while fixing supermemory skill"

# Push your changes
git push origin main
```

This method preserves your skill fix while incorporating remote updates. It's ideal when the remote changes don't conflict with your modifications.

### Option 2: Rebase for Clean History

If you prefer a linear history, use rebase instead:

```bash
git fetch origin
git rebase origin/main
```

During rebase, Git replays your commits on top of the remote branch. If conflicts arise, resolve them file-by-file:

```bash
# After resolving a conflict in your-skill.md
git add articles/your-skill.md
git rebase --continue
```

Rebase creates a cleaner history but rewrites commit IDs. Use this only if you haven't shared your branch with others.

### Option 3: Force Push (Use with Caution)

When you're certain your local version is correct and the remote changes should be discarded:

```bash
git push origin main --force
```

**Warning**: This overwrites the remote branch and can cause data loss. Never force push to protected branches like `main` or `master` unless you have admin permissions and understand the consequences.

For protected branches, you may need to temporarily disable protection or create a pull request instead:

```bash
# Push to a new branch
git push origin main:feature/your-skill-fix

# Then create a PR through GitHub UI or CLI
gh pr create --base main --head feature/your-skill-fix
```

## Preventing Future Push Rejections

### Sync Before Starting Work

Always pull the latest changes before editing skill files:

```bash
git pull origin main
```

This habit prevents divergence before it starts.

### Use Dedicated Branches for Skill Development

Create feature branches for skill modifications:

```bash
git checkout -b fix/tdd-skill-template
# Make your edits
git push origin fix/tdd-skill-template
# Open a PR when ready
```

This workflow keeps your main branch clean and allows review of skill changes.

### Configure Git to Auto-Fetch

Add these settings to your global Git config:

```bash
git config --global fetch.prune true
git config --global pull.rebase true
```

These settings automatically clean up stale remote branches and use rebase during pulls.

### Document Your Skill Dependencies

If multiple skills interact (for instance, `pdf` and `docx` both reference shared templates), document their relationships. This helps when resolving conflicts:

```markdown
<!-- In your skill README -->
# Skill Dependencies

- `pdf` skill uses templates from `templates/pdf-base.md`
- `docx` skill shares formatting rules with `pdf`
- Changes to base templates require coordinated updates
```

## Working with Specific Skills

When fixing skills like `frontend-design` or `canvas-design`, you may generate new files. Track these additions:

```bash
# Check what files changed
git status

# Add new skill files
git add skills/frontend-design.md
git add generated/
```

The `algorithmic-art` skill often creates output files that shouldn't be committed. Use `.gitignore`:

```gitignore
# Ignore generated art outputs
outputs/*.png
outputs/*.pdf
```

## Common Error Messages and Solutions

### "Updates were rejected because the remote contains work you do not have locally"

This occurs when someone pushed to the remote after your last pull. Solution: pull first, then push.

### "Protected branch rejected push"

Your repository has branch protection rules. Create a PR instead of pushing directly, or request branch protection exceptions for skill maintenance.

### "Permission denied (publickey)"

Your SSH keys aren't configured correctly. Verify with:

```bash
ssh -T git@github.com
```

## Conclusion

Git push rejections during Claude skill fixes are common but solvable. The key is understanding why divergence occurs—typically from multi-machine workflows or automated processes updating skill files. Pull-and-merge works for most cases, while rebase offers cleaner history for advanced users. Always sync before starting work and consider branch-based workflows for significant skill modifications.

For power users managing multiple skills like `mcp-builder`, `skill-creator`, and domain-specific skills, establishing a consistent Git workflow prevents these interruptions. Remember to document skill dependencies when multiple skills share templates or configurations.


## Related Reading

- [Claude Skills Troubleshooting Hub](/claude-skills-guide/troubleshooting-hub/)
- [Claude Code Output Quality: How to Improve Results](/claude-skills-guide/claude-code-output-quality-how-to-improve-results/)
- [Claude Code Keeps Making the Same Mistake: Fix Guide](/claude-skills-guide/claude-code-keeps-making-same-mistake-fix-guide/)
- [Best Way to Scope Tasks for Claude Code Success](/claude-skills-guide/best-way-to-scope-tasks-for-claude-code-success/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
