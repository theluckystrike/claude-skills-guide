---
sitemap: false
layout: default
title: "Claude Code ENOSPC Disk Full Error (2026)"
description: "Fix Claude Code ENOSPC disk full during operation. Free disk space and relocate temp directories. Step-by-step solution."
permalink: /claude-code-enospc-disk-full-fix/
date: 2026-04-20
last_tested: "2026-04-21"
---

## The Error

```
Error: ENOSPC: no space left on device, write
    at Object.writeSync (node:fs:920:3)
    at writeFileSync (node:fs:2254:26)

# Or:
npm ERR! code ENOSPC
npm ERR! syscall write
npm ERR! errno -28
npm ERR! nospc /tmp/npm-12345/package.tgz ENOSPC: no space left on device

# Or:
FATAL: Cannot write to /Users/you/.claude/cache — disk full
```

## The Fix

1. **Check disk usage and identify space consumers**

```bash
# Overall disk usage
df -h /

# Find largest directories in home
du -sh ~/Library/Caches/* 2>/dev/null | sort -rh | head -10
du -sh ~/.npm/ ~/.cache/ /tmp/ 2>/dev/null
```

2. **Clear caches that are safe to remove**

```bash
# npm cache
npm cache clean --force

# Claude Code conversation cache
rm -rf ~/.claude/cache/*

# System temp files
rm -rf /tmp/npm-*
rm -rf /tmp/claude-*

# macOS specific
rm -rf ~/Library/Caches/com.apple.dt.Xcode/  # if you use Xcode
```

3. **Verify the fix:**

```bash
df -h / | awk 'NR==2 {print "Available:", $4}'
claude --version
# Expected: Available: XX.XGi (enough free space) and version number
```

## Why This Happens

Claude Code writes temporary files during operations — conversation state, file diffs, command output captures, and intermediate build artifacts. When the disk has less than ~100 MB free, these writes fail with ENOSPC. Common space hogs on developer machines include npm/pnpm caches (often 5-20 GB), Docker images, old build outputs, and accumulated node_modules directories across projects. The issue is more frequent on CI runners with small disk allocations or Docker containers with limited storage.

## If That Doesn't Work

- **Alternative 1:** Move npm cache to a larger partition: `npm config set cache /mnt/data/.npm-cache`
- **Alternative 2:** In Docker, increase the container's disk allocation or mount a volume for temp files
- **Check:** Run `find / -xdev -type f -size +100M 2>/dev/null | head -20` to find unexpectedly large files consuming space

## Prevention

Add to your `CLAUDE.md`:
```markdown
Run `df -h /` before long Claude Code sessions. Keep at least 2 GB free on the working disk. Clear npm cache monthly with `npm cache clean --force`. In CI, use disk cleanup actions before Claude Code steps.
```

**Related articles:** [Claude Code Out of Memory Fix](/claude-code-error-out-of-memory-large-codebase-fix/), [Docker Build Failed Fix](/claude-code-docker-build-failed-fix/), [Troubleshooting Hub](/troubleshooting-hub/)

## See Also

- [Disk Space Full During Operation Fix](/claude-code-disk-space-full-during-operation-fix-2026/)
- [Output Channel Buffer Full Truncated — Fix (2026)](/claude-code-output-channel-buffer-full-fix-2026/)


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




**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code Full Stack Developer](/claude-code-full-stack-developer-feature-shipping-workflow/)
- [Full Stack Web App with Claude Skills](/full-stack-web-app-with-claude-skills-step-by-step/)
- [Claude Skill Metadata Header vs Full](/claude-skill-metadata-header-vs-full-body-loading/)
- [Claude Code vs Tabnine: Full Comparison](/claude-code-vs-tabnine-full-comparison-2026/)

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
