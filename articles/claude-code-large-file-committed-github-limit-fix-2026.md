---
title: "Large File Committed Exceeds GitHub"
permalink: /claude-code-large-file-committed-github-limit-fix-2026/
description: "Fix large file committed exceeding GitHub 100MB limit. Remove the file from git history with git filter-repo or use Git LFS for legitimate large files."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
remote: error: File data/training-set.csv is 142.50 MB; this exceeds GitHub's
file size limit of 100.00 MB
remote: error: GH001: Large files detected. You may want to try Git Large File Storage.
To github.com:user/repo.git
 ! [remote rejected] main -> main (pre-receive hook declined)
```

This appears when Claude Code commits a large file (over 100MB) and you push to GitHub, which rejects files exceeding its size limit.

## The Fix

```bash
git filter-repo --path data/training-set.csv --invert-paths
```

1. Install `git-filter-repo` if needed: `brew install git-filter-repo`.
2. Remove the large file from the entire git history.
3. Add the file to `.gitignore` to prevent re-committing.
4. Force push to update the remote: `git push --force-with-lease`.

## Why This Happens

Claude Code does not check file sizes before committing. When it processes data files, generates database dumps, or creates test fixtures, it may produce files well over 100MB. These get committed normally to the local repository, but GitHub's pre-receive hook rejects the push. The file is now embedded in git history, so simply deleting it and committing again does not help — the blob remains in previous commits.

## If That Doesn't Work

If `git-filter-repo` is not available, use BFG Repo Cleaner:

```bash
brew install bfg
bfg --strip-blobs-bigger-than 100M
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force-with-lease
```

Set up Git LFS for legitimate large files:

```bash
git lfs install
git lfs track "*.csv" "*.sqlite" "*.bin"
git add .gitattributes
git commit -m "Track large files with LFS"
```

If the commit was recent, use interactive reset:

```bash
git reset HEAD~1
git add --all -- ':!data/training-set.csv'
git commit -m "Commit without large file"
```

## Prevention

```markdown
# CLAUDE.md rule
Never commit files larger than 50MB. Add *.csv, *.sqlite, *.bin, *.tar.gz to .gitignore. For legitimate large files, use Git LFS. Always check file size before staging.
```

## See Also

- [.env File Not Loaded by Claude Fix](/claude-code-env-file-not-loaded-fix-2026/)
- [Large File Read Memory Spike Fix](/claude-code-large-file-read-memory-spike-fix-2026/)
- [Declaration File .d.ts Missing Error — Fix (2026)](/claude-code-declaration-file-dts-missing-fix-2026/)
- [Claude Code Concurrent Sessions 5/5 — Fix (2026)](/claude-code-concurrent-session-limit-fix-2026/)
- [Claude Code Subagent Spawn Limit Reached — Fix (2026)](/claude-code-subagent-spawn-limit-fix-2026/)
