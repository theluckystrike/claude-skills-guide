---
layout: default
title: "Claude Code Git Lfs Large Files"
description: "A practical workflow for handling large binary files with Git LFS while using Claude Code for development. Includes configuration tips and common pitfalls."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-git-lfs-large-files-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
render_with_liquid: false
geo_optimized: true
---
{% raw %}
## Git LFS with Claude Code: Managing Large Files Effectively

Working with large binary files in Git repositories can quickly become a nightmare without proper tooling. Git LFS (Large File Storage) provides an elegant solution, and when combined with Claude Code, creates a powerful workflow for managing assets, documentation, and data files in your projects.

## Understanding the Git LFS Problem

Standard Git repositories store every version of every file. When you commit a 50MB asset file, Git keeps that entire file in your repository history. Over time, this balloons your repository size, slows down clones, and eats up bandwidth. Git LFS solves this by storing large files externally while maintaining Git-like workflow semantics.

The problem compounds quickly in real projects. A machine learning team that commits model checkpoints after each training run can easily accumulate hundreds of gigabytes inside a repository. A design team committing Figma exports, video mockups, and PSD source files faces the same issue. Even modest projects adding a few binary assets per week end up with unwieldy repositories within a year.

Common scenarios where developers encounter large files include:

- Design assets and images in documentation-heavy projects
- Machine learning model files and datasets
- Compiled binaries and dependencies
- Video and audio files for media applications
- Database dump files used in testing
- Jupyter notebook outputs with embedded images or data
- Game asset packages including textures, audio, and mesh files

Here is a concrete illustration of the cost. Say your team commits a single 30MB compressed model file ten times a day for a month. Without LFS, your repository has absorbed roughly 9GB of binary data that must be cloned by every new contributor. With LFS, the repository holds only a text pointer file for each version, typically under 200 bytes, while the actual content lives in LFS object storage and is fetched on demand.

## Git LFS vs. Alternatives

Before adopting LFS, it helps to understand how it compares to other strategies for handling large files.

| Approach | How It Works | Best For | Drawbacks |
|---|---|---|---|
| Git LFS | Stores pointers in Git; content on LFS server | Binary assets, ML models, media | Requires LFS server; storage costs scale |
| Git Submodules | Separate repo referenced by pointer commit | Shared code libraries | Complex workflow; still clones everything |
| Artifact Registries (e.g., S3, Artifactory) | Store files outside Git entirely | Build artifacts, large datasets | Manual linking; not integrated with git commands |
| `.gitignore` + manual sharing | Never commit the file | Secrets and local config | Files drift; no versioning |
| Git Annex | Similar to LFS but older and more complex | Academic/research projects | Steep learning curve; less hosting support |

Git LFS wins for most teams because it preserves the familiar Git workflow. You still use `git add`, `git commit`, and `git push`. LFS intercepts the large files transparently through Git's smudge and clean filter hooks.

## Setting Up Git LFS in Your Project

Before integrating with Claude Code, you need LFS properly configured in your repository. Install Git LFS first, then initialize it in your project:

```bash
Install LFS (macOS with Homebrew)
brew install git-lfs

Install LFS (Ubuntu/Debian)
sudo apt-get install git-lfs

Initialize LFS for your user account (run once)
git lfs install

Track specific file patterns in the current repo
git lfs track "*.psd"
git lfs track "*.mp4"
git lfs track "*.model"
git lfs track "*.h5"
git lfs track "*.safetensors"
```

The `git lfs track` command tells LFS which file types to handle. Add the patterns to your `.gitattributes` file, which should look something like this:

```
*.psd filter=lfs diff=lfs merge=lfs -text
*.mp4 filter=lfs diff=lfs merge=lfs -text
*.model filter=lfs diff=lfs merge=lfs -text
*.h5 filter=lfs diff=lfs merge=lfs -text
*.safetensors filter=lfs diff=lfs merge=lfs -text
```

The `-text` flag is important. It tells Git not to perform line-ending normalization on these files, which would corrupt binary content. Always include it for binary file types.

Now when you add and commit these files, Git LFS automatically handles them differently, storing pointers in your repository while keeping the actual content in LFS storage.

## Verifying Your LFS Setup

After configuration, verify that LFS is intercepting files correctly:

```bash
Check which files are tracked by LFS in the repo
git lfs ls-files

Confirm a specific file is stored as an LFS pointer
git lfs pointer --file path/to/large-file.psd

Check LFS environment and configuration
git lfs env
```

The output of `git lfs pointer` should show something like:

```
version https://git-lfs.github.com/spec/v1
oid sha256:4d7a214614ab2935c943f9e0ff69d22eadbb8f32b1258daaa5e2ca24d17e2393
size 12345678
```

If you see the actual binary content instead of this pointer format, LFS is not intercepting the file correctly. Double-check your `.gitattributes` and run `git lfs install` again.

## Setting Size-Based Tracking

Rather than tracking by extension, you can set up a pre-commit hook that warns when files exceed a size threshold:

```bash
#!/bin/bash
.git/hooks/pre-commit
Warn when files larger than 5MB are staged without LFS tracking

LIMIT=5242880 # 5MB in bytes

while IFS= read -r -d '' file; do
 size=$(git cat-file -s ":$file" 2>/dev/null || echo 0)
 if [ "$size" -gt "$LIMIT" ]; then
 # Check if already tracked by LFS
 if ! git check-attr filter "$file" | grep -q "lfs"; then
 echo "WARNING: Large file not tracked by LFS: $file ($size bytes)"
 echo "Consider running: git lfs track \"$file\""
 fi
 fi
done < <(git diff --cached --name-only -z HEAD 2>/dev/null || git diff --cached --name-only -z)

exit 0
```

Make the hook executable with `chmod +x .git/hooks/pre-commit`. This will warn you before a large file slips into a commit without LFS tracking.

## Integrating Git LFS with Claude Code Workflows

Claude Code works smoothly with Git LFS once properly configured. The key is ensuring your LFS hooks are in place before you start development. When Claude Code runs git commands, it will automatically interact with LFS-tracked files correctly.

For projects using the supermemory skill for persistent context, you can maintain LFS tracking patterns in your project notes. Similarly, when using the tdd skill for test-driven development, ensure your test fixtures don't inadvertently bypass LFS handling.

## Creating a CLAUDE.md with LFS Instructions

A practical approach involves creating a Claude.md file in your project root:

```markdown
Project LFS Configuration

This project uses Git LFS for the following file types:
- `*.psd` - Adobe Photoshop files
- `*.ai` - Adobe Illustrator files
- `models/*` - ML model files
- `assets/` - Design assets

Do not commit large files directly, ensure LFS tracking is configured.

Adding New Large File Types

If you need to track a new file type:
1. Run `git lfs track "*.ext"` to update .gitattributes
2. Stage and commit the updated .gitattributes file first
3. Then add and commit the large files

Checking LFS Status

Run `git lfs ls-files` to see all LFS-tracked files in the repo.
Run `git lfs status` to see pending LFS changes.
```

This guides Claude Code to handle large files appropriately during development sessions. When you ask Claude Code to commit changes, it will read the CLAUDE.md context and know to check LFS status before committing.

## Practical Session Example

Here is how a typical session with Claude Code and LFS looks in practice:

```
You: Add the new model checkpoint to the repository

Claude Code: I'll check your LFS configuration before adding the checkpoint file.

[runs: git lfs ls-files]
[runs: git check-attr filter models/checkpoint_v2.h5]

The file type .h5 is already tracked by LFS. I'll stage and commit it.

[runs: git add models/checkpoint_v2.h5]
[runs: git lfs status]
[runs: git commit -m "Add model checkpoint v2"]
```

Claude Code automatically runs the verification steps because they are documented in CLAUDE.md. Without that context, it might attempt a plain `git add` and `git commit` without confirming LFS handling.

## LFS in CI/CD Pipelines

When Claude Code helps you set up CI/CD workflows, LFS requires specific handling. Here is a GitHub Actions example:

```yaml
name: Build and Test

on: [push, pull_request]

jobs:
 build:
 runs-on: ubuntu-latest
 steps:
 - name: Checkout with LFS
 uses: actions/checkout@v4
 with:
 lfs: true

 - name: Cache LFS objects
 uses: actions/cache@v3
 id: lfs-cache
 with:
 path: .git/lfs
 key: lfs-${{ hashFiles('.gitattributes') }}

 - name: Pull LFS objects (if not cached)
 if: steps.lfs-cache.outputs.cache-hit != 'true'
 run: git lfs pull

 - name: Run tests
 run: npm test
```

The `lfs: true` flag on the checkout action automatically runs `git lfs pull` after cloning. The caching step avoids re-downloading LFS content on every run, which saves both time and bandwidth.

## Handling Common Git LFS Pitfalls

Even with proper setup, developers encounter issues. Here are solutions for the most common problems.

## Forgotten LFS Tracking

If you've already committed large files without LFS, you need to migrate them. The process involves converting existing large files to LFS pointers:

```bash
git lfs migrate import --include="*.psd,*.mp4"
git push origin main
```

This rewrites your git history, so coordinate with your team before running this on shared branches.

For a safer approach on shared branches, use the `--no-rewrite` option which creates a new commit rather than rewriting history:

```bash
git lfs migrate import --include="*.psd,*.mp4" --no-rewrite -m "Migrate large files to LFS"
git push origin main
```

After the push, your collaborators need to run:

```bash
git pull
git lfs pull
```

## Diagnosing Files That Should Be in LFS

To find large files already in your repository that are not LFS-tracked:

```bash
Find the 20 largest objects in your git history
git rev-list --objects --all |
 git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' |
 awk '/^blob/ {print substr($0,6)}' |
 sort -k2 -rn |
 head -20 |
 awk '{system("git log --oneline --follow -1 -- "$3" 2>/dev/null | head -1 | tr -d \"\\n\"; printf \" %s\\n\" $3)}'
```

This command reveals which files are bloating your repository. Any file over a few megabytes that appears in this list is a candidate for LFS migration.

## Storage Limits and Costs

Git LFS provides generous free tiers, but large teams may hit limits. Monitor your usage with:

```bash
git lfs ls-files
git lfs fetch --recent
```

If you're working on open-source projects, GitHub provides unlimited LFS for public repositories. Private repos have different limits depending on your plan.

Here is a comparison of LFS storage options across major Git hosting providers:

| Provider | Free LFS Storage | Free Bandwidth | Paid Plans |
|---|---|---|---|
| GitHub | 1 GB | 1 GB/month | $5/50GB storage + bandwidth packs |
| GitLab | 5 GB (SaaS free tier) | Varies by tier | Included in paid tiers |
| Bitbucket | 1 GB | 1 GB/month | $10/month for additional packs |
| Self-hosted Gitea | Unlimited (your disk) | Unlimited (your bandwidth) | Infrastructure cost only |
| AWS CodeCommit + S3 | 0 (pay per use) | $0.09/GB out | Very cost-effective at scale |

For teams exceeding free tiers, self-hosted LFS servers using tools like `lfs-test-server` or third-party solutions like Nexus Repository or Artifactory can provide more economical large-scale storage.

## Clone and Fetch Performance

When cloning repositories with LFS files, use `--filter` to control what downloads:

```bash
git clone --filter=blob:none git@github.com:user/repo.git
git lfs checkout
```

This performs a "lazy clone," downloading only LFS pointers initially and fetching actual content on demand.

For teams with slow connections, you can also fetch only recent LFS content:

```bash
Only fetch LFS files from commits in the last 30 days
git lfs fetch --recent

Fetch LFS files referenced by specific commits
git lfs fetch origin ref1 ref2

Prune locally cached LFS files not referenced by recent commits
git lfs prune
```

## LFS Locking for Binary Files

One limitation of Git LFS is that binary files cannot be merged. If two developers edit the same PSD or model file simultaneously, you end up with a conflict that has no good resolution. Git LFS provides a file locking mechanism to prevent this:

```bash
Lock a file before editing
git lfs lock path/to/design-file.psd

List currently locked files
git lfs locks

Unlock after committing your changes
git lfs unlock path/to/design-file.psd
```

File locking requires your Git server to support it (GitHub and GitLab do). Add the `lockable` attribute to files that should enforce exclusive access:

```
*.psd filter=lfs diff=lfs merge=lfs -text lockable
*.ai filter=lfs diff=lfs merge=lfs -text lockable
```

With `lockable` set, Git will make the files read-only locally until you explicitly lock them, giving you a hard reminder to acquire a lock before editing.

## Best Practices for Claude Code Projects

When combining Claude Code with Git LFS, consider these workflow optimizations.

Use Separate Repositories for Large Assets: For very large projects, consider splitting repositories. Keep your code in one repo and assets in another, using Git submodules or package management to reference external assets.

Document LFS Requirements in CLAUDE.md: If your project requires specific LFS setup, document it clearly. Claude Code respects the instructions in CLAUDE.md and will follow your LFS guidance. Include the specific commands needed to verify LFS is working, since a new contributor or a fresh Claude Code session will not know the project's LFS history.

Use Skills for Specialized Tasks: When working with PDF documentation using the pdf skill, ensure any generated or processed large PDF files are handled appropriately. Similarly, the frontend-design skill works well with image assets that should use LFS.

Automate LFS File Detection: Create git aliases or shell functions that warn when you're about to commit large files:

```bash
Add to .gitconfig
[alias]
 untracked-size = !git ls-files --others --exclude-standard | xargs du -h | sort -rh | head -10
 lfs-check = !git diff --cached --name-only | xargs -I{} sh -c 'size=$(git cat-file -s :{}); if [ $size -gt 1048576 ]; then echo "Large file: {} ($size bytes)"; fi'
```

Keep .gitattributes in Sync: When onboarding contributors, the first thing they should do after cloning is run `git lfs install` and verify that `.gitattributes` is present. Document this step in your project README and CLAUDE.md so that Claude Code can remind contributors automatically.

Audit LFS Usage Regularly: Schedule periodic audits of your LFS storage. Use `git lfs ls-files --size` to see how much space each tracked file is consuming. Files that are no longer needed but remain in history can be pruned with `git lfs prune` after removing references in your branch history.

## Advanced LFS Configuration

For teams with specific requirements, Git LFS offers advanced configuration options.

Custom Transfer Servers: If you need to host LFS files on your own infrastructure, configure custom transfer endpoints in your `.gitconfig`:

```bash
git config lfs.url https://your-internal-lfs-server.com/info/lfs
```

You can also scope this to specific repositories by placing the configuration in the repo's local `.git/config`:

```ini
[lfs]
 url = https://your-internal-lfs-server.com/info/lfs

[lfs "https://your-internal-lfs-server.com/info/lfs"]
 access = basic
```

LFS Pre-Push Hooks: Ensure LFS files are properly pushed before regular git pushes by using the pre-push hook:

```bash
git lfs pre-push --dry-run
```

This validates that all LFS objects exist remotely before your push completes.

Batch Size Tuning: For slow networks or large file transfers, you can tune LFS transfer settings:

```bash
Increase concurrent transfers (default is 3)
git config lfs.concurrenttransfers 8

Set a longer timeout for large file uploads
git config lfs.activitytimeout 120
```

Partial Clones with LFS: In Git 2.22 and later, you can combine partial clones with LFS for maximum flexibility:

```bash
Clone without any blobs (fastest initial clone)
git clone --filter=blob:none --no-checkout git@github.com:user/repo.git
cd repo

Only download what you actually need for your current work
git sparse-checkout init --cone
git sparse-checkout set src/
git checkout main

Fetch LFS objects only for the files you checked out
git lfs pull --include="src/"
```

This approach is particularly useful on large monorepos where most contributors only work in a fraction of the codebase.

## Configuring LFS for Different Environments

Development, staging, and production environments often have different needs for LFS content. Here is a pattern for handling this:

```bash
.env.lfs (not committed)
LFS_FETCH_RECENT_REFS_DAYS=7
LFS_SKIP_SMUDGE=0

In CI, set this to avoid fetching LFS until explicitly needed
LFS_SKIP_SMUDGE=1
```

The `GIT_LFS_SKIP_SMUDGE=1` environment variable tells LFS not to download file contents when checking out, leaving only pointers on disk. This is useful in build pipelines where you only need specific large files for the current job.

```bash
CI job that doesn't need LFS files
GIT_LFS_SKIP_SMUDGE=1 git clone git@github.com:user/repo.git

Selectively fetch only what this job needs
git lfs pull --include="models/production/*.onnx"
```

## Conclusion

Git LFS combined with Claude Code creates a solid workflow for managing large files in development projects. By properly tracking binary assets, documenting requirements, and following best practices, you keep repository sizes manageable while maintaining full functionality.

The key is establishing LFS configuration early in your project and ensuring all team members understand the workflow. With these patterns in place, large files no longer become a bottleneck in your development process.

Investing time in a solid CLAUDE.md that documents your LFS setup pays dividends every time you start a new Claude Code session. The assistant can read your configuration, verify LFS health, and remind you of the right commands, turning what can be a confusing workflow into a reliable, automated routine.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-git-lfs-large-files-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Git Workflow Best Practices Guide](/claude-code-git-workflow-best-practices-guide/). LFS is part of git best practices for large repos
- [Claude Code Git Submodules Management Guide](/claude-code-git-submodules-management-guide/). Another large-repo management technique
- [Claude Code Error Out of Memory Large Codebase Fix](/claude-code-error-out-of-memory-large-codebase-fix/). Large files often cause OOM issues
- [Claude Skills Workflows Hub](/workflows/). Git workflow automation guides
- [Claude Code for OpenObserve Workflow Tutorial](/claude-code-for-openobserve-workflow-tutorial/)
- [Claude Code For Uma Oracle — Complete Developer Guide](/claude-code-for-uma-oracle-workflow-tutorial/)
- [Claude Code for Elastic SIEM Workflow Guide](/claude-code-for-elastic-siem-workflow-guide/)
- [Claude Code for Split.io Experimentation Workflow](/claude-code-for-split-io-experimentation-workflow/)
- [Claude Code For Go Benchmark — Complete Developer Guide](/claude-code-for-go-benchmark-workflow-tutorial-guide/)
- [Claude Code for New Relic APM Workflow Guide](/claude-code-for-new-relic-apm-workflow-guide/)
- [Claude Code For Chargebee — Complete Developer Guide](/claude-code-for-chargebee-subscription-workflow/)
- [Claude Code for Clojure re-frame Workflow Guide](/claude-code-for-clojure-re-frame-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}

## See Also

- [Claude Code git diff too large -- reducing context size](/claude-code-git-diff-too-large-reducing-context/)
