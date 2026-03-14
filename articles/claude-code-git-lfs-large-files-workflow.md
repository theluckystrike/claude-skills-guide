---
layout: default
title: "Git LFS + Claude Code: Managing Large Files in Your Repository"
description: "A practical workflow for handling large binary files with Git LFS while using Claude Code for development. Includes configuration tips and common pitfalls."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-git-lfs-large-files-workflow/
---

# Git LFS with Claude Code: Managing Large Files Effectively

Working with large binary files in Git repositories can quickly become a nightmare without proper tooling. Git LFS (Large File Storage) provides an elegant solution, and when combined with Claude Code, creates a powerful workflow for managing assets, documentation, and data files in your projects.

## Understanding the Git LFS Problem

Standard Git repositories store every version of every file. When you commit a 50MB asset file, Git keeps that entire file in your repository history. Over time, this balloons your repository size, slows down clones, and eats up bandwidth. Git LFS solves this by storing large files externally while maintaining Git-like workflow semantics.

Common scenarios where developers encounter large files include:

- Design assets and images in documentation-heavy projects
- Machine learning model files and datasets
- Compiled binaries and dependencies
- Video and audio files for media applications

## Setting Up Git LFS in Your Project

Before integrating with Claude Code, you need LFS properly configured in your repository. Install Git LFS first, then initialize it in your project:

```bash
git lfs install
git lfs track "*.psd"
git lfs track "*.mp4"
git lfs track "*.model"
```

The `git lfs track` command tells LFS which file types to handle. Add the patterns to your `.gitattributes` file, which should look something like this:

```
*.psd filter=lfs diff=lfs merge=lfs -text
*.mp4 filter=lfs diff=lfs merge=lfs -text
*.model filter=lfs diff=lfs merge=lfs -text
```

Now when you add and commit these files, Git LFS automatically handles them differently—storing pointers in your repository while keeping the actual content in LFS storage.

## Integrating Git LFS with Claude Code Workflows

Claude Code works seamlessly with Git LFS once properly configured. The key is ensuring your LFS hooks are in place before you start development. When Claude Code runs git commands, it will automatically interact with LFS-tracked files correctly.

For projects using the supermemory skill for persistent context, you can maintain LFS tracking patterns in your project notes. Similarly, when using the tdd skill for test-driven development, ensure your test fixtures don't inadvertently bypass LFS handling.

A practical approach involves creating a Claude.md file in your project root:

```markdown
# Project LFS Configuration

This project uses Git LFS for the following file types:
- `*.psd` - Adobe Photoshop files
- `*.ai` - Adobe Illustrator files  
- `models/*` - ML model files
- `assets/` - Design assets

Do not commit large files directly—ensure LFS tracking is configured.
```

This guides Claude Code to handle large files appropriately during development sessions.

## Handling Common Git LFS Pitfalls

Even with proper setup, developers encounter issues. Here are solutions for the most common problems.

### Forgotten LFS Tracking

If you've already committed large files without LFS, you need to migrate them. The process involves converting existing large files to LFS pointers:

```bash
git lfs migrate import --include="*.psd,*.mp4"
git push origin main
```

This rewrites your git history, so coordinate with your team before running this on shared branches.

### Storage Limits and Costs

Git LFS provides generous free tiers, but large teams may hit limits. Monitor your usage with:

```bash
git lfs ls-files
git lfs fetch --recent
```

If you're working on open-source projects, GitHub provides unlimited LFS for public repositories. Private repos have different limits depending on your plan.

### Clone and Fetch Performance

When cloning repositories with LFS files, use `--filter` to control what downloads:

```bash
git clone --filter=blob:none git@github.com:user/repo.git
git lfs checkout
```

This performs a "lazy clone," downloading only LFS pointers initially and fetching actual content on demand.

## Best Practices for Claude Code Projects

When combining Claude Code with Git LFS, consider these workflow optimizations.

**Use Separate Repositories for Large Assets**: For very large projects, consider splitting repositories. Keep your code in one repo and assets in another, using Git submodules or package management to reference external assets.

**Document LFS Requirements in CLAUDE.md**: If your project requires specific LFS setup, document it clearly. Claude Code respects the instructions in CLAUDE.md and will follow your LFS guidance.

**Leverage Skills for Specialized Tasks**: When working with PDF documentation using the pdf skill, ensure any generated or processed large PDF files are handled appropriately. Similarly, the frontend-design skill works well with image assets that should use LFS.

**Automate LFS File Detection**: Create git aliases or shell functions that warn when you're about to commit potentially large files:

```bash
# Add to .gitconfig
[alias]
    untracked-size = !git ls-files --others --exclude-standard | xargs du -h | sort -rh | head -10
```

## Advanced LFS Configuration

For teams with specific requirements, Git LFS offers advanced configuration options.

**Custom Transfer Servers**: If you need to host LFS files on your own infrastructure, configure custom transfer endpoints in your `.gitconfig`:

```bash
git config lfs.url https://your-internal-lfs-server.com/info/lfs
```

**LFS Pre-Push Hooks**: Ensure LFS files are properly pushed before regular git pushes by using the pre-push hook:

```bash
git lfs pre-push --dry-run
```

This validates that all LFS objects exist remotely before your push completes.

## Conclusion

Git LFS combined with Claude Code creates a robust workflow for managing large files in development projects. By properly tracking binary assets, documenting requirements, and following best practices, you keep repository sizes manageable while maintaining full functionality.

The key is establishing LFS configuration early in your project and ensuring all team members understand the workflow. With these patterns in place, large files no longer become a bottleneck in your development process.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
