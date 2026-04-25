---
title: "Hook Script Not Executable — Fix"
permalink: /claude-code-hook-script-not-executable-fix-2026/
description: "Claude Code troubleshooting: run chmod +x on hook script to fix not-executable permission error. Ensure valid shebang line and Unix line endings are..."
last_tested: "2026-04-21"
---

## The Error

```
Hook failed: /path/to/hook.sh is not executable
```

## The Fix

```bash
# Make the hook script executable
chmod +x /path/to/hook.sh

# Verify the permission was set
ls -la /path/to/hook.sh
# Should show: -rwxr-xr-x
```

## Why This Works

Claude Code hooks invoke external scripts through the system shell. Unix systems require the executable bit set on any file invoked directly (as opposed to being passed as an argument to an interpreter). Without `+x`, the OS rejects execution at the syscall level before the script content is even read.

## If That Doesn't Work

```bash
# Ensure the script has a valid shebang line
head -1 /path/to/hook.sh
# Must be: #!/bin/bash or #!/usr/bin/env bash

# If missing, add it:
sed -i '1i#!/usr/bin/env bash' /path/to/hook.sh

# Also check the file doesn't have Windows line endings
file /path/to/hook.sh
# If it says "CRLF", fix with:
sed -i 's/\r$//' /path/to/hook.sh
```

Windows line endings cause the shebang to be read as `#!/bin/bash\r` which points to a nonexistent interpreter.

## Prevention

Add to your CLAUDE.md:
```
All hook scripts must have: (1) chmod +x applied, (2) a #!/usr/bin/env bash shebang on line 1, (3) Unix line endings (LF not CRLF). Verify with `file script.sh` before registering as a hook.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `Hook execution failed with exit code 1`
- `pre-commit hook rejected the commit`
- `Hook script exited with signal SIGKILL`
- `bash: command not found: claude`
- `zsh: command not found: claude`

## Frequently Asked Questions

### What are Claude Code hooks?

Claude Code hooks are user-defined scripts that run at specific lifecycle points: before/after file edits, before/after bash commands, and before/after commits. They are configured in `.claude/hooks/` or via the Claude Code settings file.

### How do I debug a failing hook?

Run the hook script manually from the command line to see its output: `bash .claude/hooks/pre-edit.sh`. Add `set -x` at the top of the script for verbose execution tracing. Check that all commands in the script exist in the container or environment where Claude Code runs.

### Can hooks block Claude Code operations?

Yes. A hook that returns a non-zero exit code blocks the operation it is attached to. This is by design — it allows you to enforce code quality rules, prevent edits to protected files, or require approval for destructive operations.

### Why is the claude command not found after installation?

The installation directory is not in your PATH. Run `which claude` to check if it is accessible. If not, add the npm global bin directory to your PATH: `export PATH=$(npm bin -g):$PATH` and add this line to your shell profile (`~/.bashrc` or `~/.zshrc`).


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
