---
title: "File Watcher EMFILE Too Many Open Files Fix"
permalink: /claude-code-file-watcher-emfile-too-many-open-files-fix-2026/
description: "Fix EMFILE too many open files error from file watchers in Claude Code. Increase ulimit and exclude large directories to stay within OS limits."
last_tested: "2026-04-22"
render_with_liquid: false
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
