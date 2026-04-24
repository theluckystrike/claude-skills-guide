---

layout: default
title: "Claude Code for Git Filter-Repo"
description: "Learn how to use Claude Code to automate and simplify git filter-repo workflows for cleaning up repository history, removing sensitive data, and."
date: 2026-03-15
last_modified_at: 2026-04-17
author: Claude Skills Guide
permalink: /claude-code-for-git-filter-repo-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
geo_optimized: true
last_tested: "2026-04-22"
---

Git filter-repo is a powerful tool for rewriting Git history, but it can be intimidating due to its complexity and the irreversible nature of history rewriting. This guide shows how Claude Code can help you safely navigate filter-repo workflows, generate correct commands, and avoid common pitfalls, whether you are removing accidentally committed secrets, carving out a subdirectory into its own repository, or reducing a bloated monorepo to something manageable.

What is Git Filter-Repo?

Git filter-repo is the modern replacement for older tools like BFG Repo-Cleaner and git-filter-branch. It allows you to:

- Remove sensitive data (API keys, passwords) from history
- Extract a subdirectory into a new repository
- Flatten repository structure
- Remove large binary files that bloat your repository
- Change file paths and directory structures across all commits

The tool is incredibly powerful but requires careful planning since it rewrites commit hashes, affecting every commit in your repository's history.

Here is a quick comparison of the three main history-rewriting tools:

| Tool | Speed | Safety | Complexity | Status |
|---|---|---|---|---|
| git-filter-branch | Slow | Low (easy to corrupt) | High | Deprecated |
| BFG Repo-Cleaner | Fast | Medium | Low | Maintenance only |
| git-filter-repo | Fast | High | Medium | Actively maintained |

Git's own documentation now explicitly recommends git-filter-repo over git-filter-branch for any history rewriting task. BFG is still useful for its simplicity on pure file-removal tasks, but git-filter-repo handles every scenario BFG covers and more, with better performance on large repositories.

## Setting Up Filter-Repo with Claude Code

First, ensure you have filter-repo installed. Claude Code can help you verify this:

```bash
Check if filter-repo is installed
pip install git-filter-repo

Verify installation
git filter-repo --version
```

On macOS with Homebrew you can also install via:

```bash
brew install git-filter-repo
```

Before proceeding with any filter-repo operation, always create a backup of your repository. Claude Code can help you set up a safe working environment:

```bash
Clone your repository to a backup location
git clone --mirror git@github.com:yourorg/yourrepo.git backup-repo.git
```

The `--mirror` flag captures every ref, branches, tags, notes, and stash entries, so your backup is a complete snapshot of the remote state. A regular `git clone` does not capture all of this. Store the mirror somewhere outside the working directory you plan to operate on, and verify it before proceeding:

```bash
Verify the mirror is intact
cd backup-repo.git
git fsck --full
cd ..
```

A clean `git fsck` with no errors means your backup is reliable. If fsck reports errors, stop and investigate before touching the primary repository.

## Using Claude Code to Plan Your Filter-Repo Operation

The most valuable way Claude Code assists with filter-repo workflows is in the planning phase. Before running any destructive commands, describe your goal to Claude and ask for a step-by-step plan.

For example, you might say: "I need to remove all files larger than 100MB from my repository history and I want to keep only the src and docs directories."

Claude can then generate the appropriate filter-repo command:

```bash
First, identify large files
git filter-repo --analyze

Review the analysis in .git/filter-repo/analysis/

Remove files over 100MB from history
git filter-repo --strip-blobs-bigger-than 100M

Keep only src and docs directories
git filter-repo --path src --path docs --path-rewrite src: docs:
```

The `--analyze` step deserves a pause before proceeding. It produces several files in `.git/filter-repo/analysis/` that give you a data-driven picture of what is actually in your history. The most useful are:

- `path-all-sizes.txt`. every path sorted by total bytes across all commits
- `blob-shas-and-paths.txt`. large blobs with their commit context
- `renames.txt`. file renames across history

Feeding this analysis output to Claude Code lets it generate targeted commands rather than broad sweeps. For example, if `path-all-sizes.txt` shows that a single `assets/videos/` directory accounts for 90% of your repository size, Claude can help you craft a command that removes only that directory rather than setting an arbitrary size threshold that might catch legitimate large files.

## Automating Common Filter-Repo Tasks

Claude Code excels at generating precise filter-repo commands for specific scenarios. Here are common workflows:

## Removing Sensitive Data

To remove API keys or credentials that were accidentally committed:

```bash
Create a file listing patterns to match
echo "api_key=" > patterns.txt
echo "password:" >> patterns.txt
echo "AWS_SECRET" >> patterns.txt

Use filter-repo with regex matching
git filter-repo --replace-text expressions.txt
```

Claude can help you create the patterns file safely, ensuring you don't accidentally remove legitimate data.

The expressions file format is more powerful than it looks. Each line can use a literal match, a regex, or a replacement:

```
expressions.txt format
literal:AKIAIOSFODNN7EXAMPLE==>REMOVED_AWS_KEY
regex:password\s*=\s*\S+==>password=REDACTED
regex:ghp_[A-Za-z0-9]{36}==>REMOVED_GITHUB_TOKEN
```

The `==>` separator lets you replace the sensitive value with a placeholder rather than deleting the line entirely, which keeps your diff history readable. Ask Claude Code to review your expressions file before running it, it can catch patterns that are too broad (catching things you did not intend) or too narrow (missing variants of the same credential format).

## Extracting a Subdirectory

To create a new repository from a subdirectory:

```bash
Extract the 'frontend' subdirectory as root
git filter-repo --subdirectory-filter frontend
```

After this command, the history will look as if the `frontend` directory was always the root of the repository. All other directories are purged, commit messages are preserved, and commit authors and dates remain intact. This is the cleanest way to split a monorepo without losing attribution history.

If the subdirectory was at different paths at different points in history ( it was renamed from `client/` to `frontend/` two years ago), you need to handle both paths:

```bash
Handle directory renames across history
git filter-repo \
 --path client \
 --path frontend \
 --path-rename client:frontend
```

## Path Rewriting

To rename directories across all commits:

```bash
Change 'lib/' to 'library/' throughout history
git filter-repo --path-rewrite lib:library
```

## Combining Multiple Operations

A common real-world scenario combines several operations: extracting a subdirectory, removing large test fixtures, and cleaning up secrets. Claude Code can chain these into a single script:

```bash
#!/bin/bash
combined-filter.sh. generated with Claude Code assistance
set -e

Step 1: Back up
git clone --mirror git@github.com:yourorg/yourrepo.git repo-backup.git
git fsck --full repo-backup.git

Step 2: Work on a fresh clone
git clone git@github.com:yourorg/yourrepo.git repo-working
cd repo-working

Step 3: Run analysis
git filter-repo --analyze
echo "Review .git/filter-repo/analysis/ before continuing"
read -p "Press Enter to continue or Ctrl+C to abort..."

Step 4: Apply filters
git filter-repo \
 --subdirectory-filter packages/core \
 --strip-blobs-bigger-than 10M \
 --replace-text ../expressions.txt

Step 5: Verify result
git log --oneline -20
git fsck --full

echo "Filtered repository is ready. Review before force-pushing."
```

The `read -p` pause is intentional, it gives you a chance to review the analysis output before committing to the irreversible filter step.

## Safe Practices with Claude Code Assistance

Filter-repo operations are destructive and cannot be undone. Claude Code helps you follow these safety practices:

1. Always back up first - Create a mirror clone before any operation
2. Test on a copy - Run your filter-repo command on a test repository first
3. Use --dry-run - Filter-repo doesn't support dry-run, so test with a small subset
4. Update all clones - After pushing filtered history, all collaborators must re-clone

Claude can generate a checklist for your specific workflow:

```bash
Checklist for safe filter-repo operation
1. Notify all collaborators
2. Create backup: git clone --mirror
3. Verify backup integrity
4. Perform filter-repo operation
5. Verify result looks correct
6. Force push: git push --force --all
7. Force push all branches: git push --force --mirror
8. Notify collaborators to re-clone
```

The collaborator communication step is the one teams most often skip. When you rewrite history, every local clone held by every developer becomes permanently diverged from the new canonical history. Git will refuse to let them pull normally. If they push their diverged history before re-cloning, you end up with two competing histories merged together, a situation that is extremely difficult to recover from. Claude Code can draft the notification message for your team explaining exactly what happened, what they need to do, and why a simple `git pull` will not work.

## Handling Post-Filter Issues

After running filter-repo, you may encounter common issues that Claude Code can help troubleshoot:

## Detached HEAD or Missing Branches

```bash
Check current branch state
git status
git branch -a

Recreate main branch if needed
git checkout -b main
```

## Large Object References

If you see warnings about reachable objects:

```bash
Run garbage collection to clean up
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

This step is important for two reasons. First, until you run gc, the old large objects are still physically present in `.git/objects/`, the repository size on disk has not actually shrunk yet. Second, if you push before running gc, GitHub or your Git host may still serve the old objects from their object cache, meaning the sensitive data or large files remain accessible by SHA even after your filter operation. Running gc locally and then force-pushing ensures the cleaned state is what gets pushed.

## Push Rejection

Force pushing is rejected by branch protection rules:

```bash
Temporarily disable branch protection
Then force push
git push --force --all
git push --force --tags
```

On GitHub, you can temporarily disable branch protection rules through the repository Settings page under Branches. On self-hosted GitLab, the equivalent is under Settings > Repository > Protected Branches. Remember to re-enable protection immediately after the force push completes, this is another item Claude Code can add to your checklist.

## Verifying the Clean State

After force-pushing, verify that the sensitive data or large files are actually gone and not accessible via any remaining refs:

```bash
Search for a known sensitive string across all commits
git log --all --full-history --source -S "AKIAIOSFODNN7EXAMPLE"

Should return no results if the filter worked correctly
```

If this returns commits, your filter expressions file did not match every occurrence. You'll need to refine the expressions and run the entire process again from the backup.

## Integrating Filter-Repo into Your Development Workflow

For ongoing repository maintenance, consider these Claude Code enhanced practices:

- Pre-commit validation: Use pre-commit hooks to prevent large files from being added
- Regular cleanup: Schedule periodic filter-repo operations to maintain repository health
- Documentation: Keep a record of filter-repo operations performed on each repository

A simple pre-commit hook to block large files from being committed in the first place:

```bash
#!/bin/bash
.git/hooks/pre-commit
Block files over 10MB

LIMIT=$((10 * 1024 * 1024)) # 10MB in bytes

while IFS= read -r -d '' file; do
 size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")
 if [ "$size" -gt "$LIMIT" ]; then
 echo "ERROR: $file is $(( size / 1024 / 1024 ))MB, which exceeds the 10MB limit."
 echo "Use Git LFS for large files: git lfs track \"$file\""
 exit 1
 fi
done < <(git diff --cached --name-only -z HEAD 2>/dev/null || git ls-files -z)
```

Claude Code can customize this hook for your specific limits and file types, and can extend it to scan for credential patterns using the same regex approach as the filter-repo expressions file, preventing secrets from entering history rather than cleaning them out after the fact.

## Conclusion

Git filter-repo combined with Claude Code provides a powerful workflow for repository maintenance. Claude acts as your assistant, generating correct commands, helping you plan complex operations, and troubleshooting issues that arise. Start with small, safe operations and gradually tackle more complex history rewrites as you gain confidence.

Remember: the key to successful filter-repo use is careful planning, thorough backups, and methodical execution. Let Claude Code help you every step of the way.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-git-filter-repo-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Feature Flags Workflow Git Guide](/claude-code-feature-flags-workflow-git-guide/)
- [Claude Code for Cross-Repo Code Search Workflow Guide](/claude-code-for-cross-repo-code-search-workflow-guide/)
- [Claude Code for Delta Git Diff Workflow Guide](/claude-code-for-delta-git-diff-workflow-guide/)
- [Claude Code Git Workflow Guide](/claude-code-with-git-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Content Filter Triggered Refusal — Fix (2026)](/claude-code-content-filter-triggered-fix-2026/)
