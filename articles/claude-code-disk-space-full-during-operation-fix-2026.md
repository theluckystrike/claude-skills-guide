---
title: "Disk Space Full During Operation Fix"
permalink: /claude-code-disk-space-full-during-operation-fix-2026/
description: "Fix disk space full error during Claude Code operation. Free disk space by clearing caches, logs, and node_modules to resume file write operations."
last_tested: "2026-04-22"
render_with_liquid: false
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
