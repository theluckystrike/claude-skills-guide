---
layout: default
title: "File Watcher EMFILE Too Many Open Files — Fix (2026)"
permalink: /claude-code-file-watcher-emfile-too-many-open-files-fix-2026/
date: 2026-04-20
description: "Fix EMFILE too many open files error from file watchers in Claude Code. Increase ulimit and exclude large directories to stay within OS limits."
last_tested: "2026-04-22"
---

## The Error

```
Error: EMFILE: too many open files, watch at '/project/node_modules'
  at FSReqCallback.oncomplete (node:fs:198:21)
  System limit for open file descriptors reached (current: 256)
  Claude Code and VS Code file watchers exhausted available descriptors
```

This appears when the combined file watchers from Claude Code, your IDE, and build tools exceed the operating system's file descriptor limit.

## The Fix

```bash
ulimit -n 65536
```

1. Increase the file descriptor limit for the current shell.
2. Add `ulimit -n 65536` to your `~/.zshrc` or `~/.bashrc` for persistence.
3. Restart your terminal, IDE, and Claude Code.

## Why This Happens

macOS has a low default file descriptor limit (256 per process in some configurations). Each file watcher consumes one descriptor per watched file or directory. A typical Node.js project with `node_modules` contains 30,000-50,000 files. Claude Code, VS Code, and tools like webpack/vite each create their own set of watchers, compounding the problem. When the combined total exceeds the OS limit, new watch attempts fail with EMFILE.

## If That Doesn't Work

Set a permanent higher limit on macOS:

```bash
sudo launchctl limit maxfiles 65536 200000
```

Create a launch daemon for persistent settings:

```bash
sudo tee /Library/LaunchDaemons/limit.maxfiles.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>limit.maxfiles</string>
  <key>ProgramArguments</key>
  <array><string>launchctl</string><string>limit</string><string>maxfiles</string><string>65536</string><string>200000</string></array>
  <key>RunAtLoad</key><true/>
</dict>
</plist>
PLIST
```

Exclude large directories from watching:

```bash
echo "node_modules" >> .claudeignore
echo "dist" >> .claudeignore
```

## Prevention

```markdown
# CLAUDE.md rule
Set ulimit -n 65536 in your shell profile. Maintain a .claudeignore with node_modules, dist, and .git exclusions. On macOS, configure launchctl maxfiles for system-wide fix.
```

## See Also

- [File Descriptor Leak in Watch Mode Fix](/claude-code-file-descriptor-leak-watch-mode-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `fatal: not a git repository`
- `error: failed to push some refs`
- `fatal: refusing to merge unrelated histories`
- `Error: Claude Code requires Node.js 18 or later`
- `SyntaxError: Unexpected token '??' — Node 14 detected`

## Frequently Asked Questions

### Why does Claude Code require git?

Claude Code uses git for several core operations: tracking file changes, creating commits, reading blame information, searching history with `git log`, and managing branches. Without git, these operations fail and Claude Code falls back to less efficient alternatives.

### Can Claude Code work in a non-git directory?

Yes, but with reduced functionality. File search and editing work normally, but version control operations (commit, diff, blame) are unavailable. Claude Code displays a warning when opened in a directory without git initialization.

### How do I prevent Claude Code from making unwanted git operations?

Add rules to your CLAUDE.md: `Do not create commits automatically. Do not run git push. Always ask before any git operation that modifies history.` Claude Code respects these constraints and asks for confirmation before proceeding.

### What Node.js version does Claude Code require?

Claude Code requires Node.js 18 or later. Node.js 20 LTS is recommended for the best compatibility and performance. Check your version with `node --version`.


## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions
