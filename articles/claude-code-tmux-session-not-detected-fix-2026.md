---
title: "tmux Session Not Detected Error — Fix (2026)"
permalink: /claude-code-tmux-session-not-detected-fix-2026/
description: "Fix tmux session not detected by Claude Code. Set TERM correctly and configure tmux for 256-color support to restore full terminal functionality."
last_tested: "2026-04-22"
---

## The Error

```
Warning: Claude Code detected unsupported terminal environment
  TERM=screen (expected: xterm-256color or similar)
  tmux session not properly detected — interactive features may be degraded
  Markdown rendering and syntax highlighting disabled
```

This appears when Claude Code runs inside tmux but the `TERM` variable is set to `screen` instead of a 256-color variant, disabling rich terminal features.

## The Fix

```bash
# Add to ~/.tmux.conf:
# set -g default-terminal "tmux-256color"
# set -ga terminal-overrides ",xterm-256color:Tc"

tmux kill-server
tmux
claude
```

1. Set the correct terminal type in tmux configuration.
2. Kill the tmux server to apply the changes (all sessions will close).
3. Start a new tmux session and run Claude Code.

## Why This Happens

tmux sets the `TERM` environment variable to `screen` by default, which advertises a limited set of terminal capabilities. Claude Code checks `TERM` to determine whether to use colors, Unicode box drawing, markdown rendering, and interactive widgets. When it sees `screen` instead of `xterm-256color`, it falls back to a degraded plain-text mode. The tmux session itself supports full color, but the `TERM` variable does not advertise this.

## If That Doesn't Work

Override TERM just for Claude Code:

```bash
TERM=xterm-256color claude
```

If tmux is stripping colors, enable true color support:

```bash
# Add to ~/.tmux.conf:
# set -as terminal-features ",xterm-256color:RGB"
tmux source-file ~/.tmux.conf
```

Verify tmux is passing through escape codes:

```bash
# Inside tmux:
printf '\033[38;2;255;100;0mTrue color test\033[0m\n'
# Should show orange text
```

## Prevention

```markdown
# CLAUDE.md rule
When using tmux, set TERM=tmux-256color in .tmux.conf. Always restart tmux after config changes. If colors look wrong, check TERM value with 'echo $TERM' — it should contain '256color'.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `Error reading configuration file`
- `JSON parse error in config`
- `Config key not recognized`
- `Error: TERM environment variable not set`
- `tmux: invalid LC_ALL, LC_CTYPE or LANG`

## Frequently Asked Questions

### Where does Claude Code store its configuration?

Configuration is stored in `~/.claude/config.json` for global settings and `.claude/config.json` in the project root for project-specific settings. Project settings override global settings for any overlapping keys.

### How do I reset Claude Code configuration?

Delete the configuration file and restart Claude Code: `rm ~/.claude/config.json && claude`. Claude Code recreates the file with default values on next startup. Back up the file first if you have custom settings you want to preserve.

### Can I share configuration across a team?

Yes. The project-level `.claude/config.json` and `CLAUDE.md` files can be committed to version control. Team members get consistent Claude Code behavior when they check out the repository. Keep API keys and personal preferences in the global config only.

### Does Claude Code work inside tmux?

Yes. Claude Code works inside tmux sessions. Ensure your tmux configuration sets the TERM variable correctly: add `set -g default-terminal 'screen-256color'` to your `~/.tmux.conf`. This prevents rendering issues with Claude Code's terminal output.


## Related Guides

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
