---
layout: default
title: "Large File Committed Exceeds GitHub (2026)"
permalink: /claude-code-large-file-committed-github-limit-fix-2026/
date: 2026-04-20
description: "Fix large file committed exceeding GitHub 100MB limit. Remove the file from git history with git filter-repo or use Git LFS for legitimate large files."
last_tested: "2026-04-22"
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


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Related Guides

- [Tool Result Exceeds 100KB Truncating — Fix (2026)](/claude-code-tool-result-too-large-fix-2026/)
- [Knowledge Base Exceeds 512KB Maximum — Fix (2026)](/claude-code-knowledge-base-too-large-fix-2026/)
- [File Exceeds 10MB Limit in Claude Code — Fix (2026)](/claude-code-max-file-size-exceeded-fix-2026/)
- [System Prompt Exceeds Token Limit — Fix](/claude-code-system-prompt-too-many-tokens-fix-2026/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
