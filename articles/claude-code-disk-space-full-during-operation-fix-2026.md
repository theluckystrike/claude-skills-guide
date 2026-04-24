---
title: "Disk Space Full During Operation Fix (2026)"
permalink: /claude-code-disk-space-full-during-operation-fix-2026/
description: "Fix disk space full error during Claude Code operation. Free disk space by clearing caches, logs, and node_modules to resume file write operations."
last_tested: "2026-04-22"
---

## The Error

```
Error: ENOSPC: no space left on device, write '/project/src/generated/schema.ts'
  Disk usage: 100% (0 bytes available)
  Claude Code cannot write files, create commits, or save conversation state
  Operation aborted — partial writes may have corrupted files
```

This appears when the filesystem runs out of space during a Claude Code operation, potentially leaving files in a partially written state.

## The Fix

```bash
# Check disk usage:
df -h /

# Clear common space consumers:
rm -rf /tmp/claude-*
npm cache clean --force
docker system prune -f
```

1. Check available disk space with `df -h`.
2. Clear temporary files, npm cache, and Docker artifacts.
3. Verify files written during the failure are intact: `git diff`.

## Why This Happens

Claude Code writes files to disk, creates git commits (which consume space in `.git/`), and stores conversation history. On machines with small SSDs, CI runners with limited disk, or Docker containers with constrained storage, space can run out during operation. Large `node_modules` directories (often 500MB+), Docker images, and accumulated build artifacts are the most common space consumers. When the disk fills up mid-write, files can be truncated or corrupted.

## If That Doesn't Work

Find the largest directories consuming space:

```bash
du -sh /* 2>/dev/null | sort -rh | head -20
du -sh ~/Library/Caches/* 2>/dev/null | sort -rh | head -10
```

Clean up node_modules from old projects:

```bash
find ~ -name "node_modules" -type d -maxdepth 4 | xargs du -sh | sort -rh | head -10
# Delete unused ones:
rm -rf /path/to/old-project/node_modules
```

Clear git garbage collection:

```bash
git gc --aggressive --prune=now
```

Check for and fix corrupted files from the disk-full write:

```bash
git status
git checkout -- path/to/corrupted-file.ts
```

## Prevention

```markdown
# CLAUDE.md rule
Maintain at least 5GB free disk space. Run 'df -h' at session start to verify. Clean npm cache monthly with 'npm cache clean --force'. Add a CLAUDE.md reminder to check disk space before large operations.
```

## See Also

- [SIGTERM During Long Operation Fix](/claude-code-sigterm-during-long-operation-fix-2026/)
- [Claude Code ENOSPC Disk Full Error — Fix (2026)](/claude-code-enospc-disk-full-fix/)


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Guides

- [Claude Code Full Stack Developer](/claude-code-full-stack-developer-feature-shipping-workflow/)
- [Full Stack Web App with Claude Skills](/full-stack-web-app-with-claude-skills-step-by-step/)
- [Output Channel Buffer Full Truncated — Fix (2026)](/claude-code-output-channel-buffer-full-fix-2026/)
- [Claude Skill Metadata Header vs Full](/claude-skill-metadata-header-vs-full-body-loading/)

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
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows."
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
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
