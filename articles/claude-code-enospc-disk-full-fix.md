---
title: "Claude Code ENOSPC Disk Full Error"
description: "Fix Claude Code ENOSPC disk full during operation. Free disk space and relocate temp directories. Step-by-step solution."
permalink: /claude-code-enospc-disk-full-fix/
last_tested: "2026-04-21"
render_with_liquid: false
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
