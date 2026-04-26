---
layout: default
title: "EACCES Permission Denied Config Dir — Fix (2026)"
permalink: /claude-code-config-dir-permission-denied-fix-2026/
date: 2026-04-20
description: "Fix ownership of the .config/claude-code directory with sudo chown command. Resolves EACCES permission denied errors on config.json read/write."
last_tested: "2026-04-21"
---

## The Error

```
EACCES: permission denied, open '/home/user/.config/claude-code/config.json'
```

## The Fix

```bash
# Fix ownership of the config directory
sudo chown -R $(whoami) ~/.config/claude-code/

# Verify correct permissions
ls -la ~/.config/claude-code/
```

## Why This Works

The config directory was likely created by a process running as root (e.g., `sudo claude` or a system-level installation script). When Claude Code later runs as your normal user, it cannot read or write files owned by root. Restoring ownership to your user account gives Claude Code the read/write access it needs for config, cache, and session data.

## If That Doesn't Work

```bash
# If the directory doesn't exist yet, create it with correct permissions
mkdir -p ~/.config/claude-code && chmod 700 ~/.config/claude-code

# If running in a container where you can't chown, set a custom config path
export CLAUDE_CONFIG_DIR="/tmp/claude-code-config"
mkdir -p "$CLAUDE_CONFIG_DIR"

# On macOS, the path is different:
sudo chown -R $(whoami) ~/Library/Application\ Support/claude-code/
```

In Docker containers, ensure your Dockerfile sets the correct user before installing Claude Code. Running `npm install -g` as root then switching users causes this exact permission mismatch.

## Prevention

Add to your CLAUDE.md:
```
Never run Claude Code with sudo. If the config directory has wrong ownership, fix with: sudo chown -R $(whoami) ~/.config/claude-code/ — Do not chmod 777 as that is a security risk.
```

## See Also

- [npm Global Install Permission Denied — Fix (2026)](/claude-code-npm-global-install-permission-denied-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `EACCES: permission denied, open '/path/to/file'`
- `Error: EPERM: operation not permitted`
- `sudo: a terminal is required to read the password`
- `EACCES: permission denied, mkdir '/usr/local/lib/node_modules'`
- `npm ERR! Error: EACCES: permission denied, rename`

## Frequently Asked Questions

### Should I run Claude Code with sudo?

No. Running Claude Code with sudo is strongly discouraged because it changes the ownership of cached files and configuration to root, which causes permission failures in subsequent non-sudo sessions. Instead, fix the underlying permission issue on the specific file or directory.

### How do I check file ownership?

Run `ls -la /path/to/file` to see the owner and group. If the file is owned by root but you run Claude Code as a regular user, run `sudo chown $(whoami) /path/to/file` to reclaim ownership.

### Does this affect CI/CD environments?

Yes. Docker containers and CI runners often execute as root, which creates files that a non-root user cannot modify later. Set `USER node` in your Dockerfile or use `--user $(id -u):$(id -g)` with `docker run` to match the host user.

### Why does npm need special permissions?

When Node.js is installed via system package managers, the global `node_modules` directory is owned by root. Running `npm install -g` as a regular user fails because the user lacks write access. Use `nvm` or configure npm to use a user-owned prefix directory to avoid this.


## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

## Step-by-Step Configuration Audit

To verify your configuration is working correctly and saving tokens:

**Step 1: Check file locations.** Run `ls -la .claude/settings.json CLAUDE.md .claudeignore 2>/dev/null` to confirm all configuration files exist in the project root.

**Step 2: Validate JSON syntax.** Run `python3 -m json.tool .claude/settings.json` to check for JSON parsing errors. A common mistake is trailing commas after the last item in an array.

**Step 3: Test permission rules.** Start a Claude Code session and attempt a command from your allow list. It should execute without a confirmation prompt. Then attempt a command from your deny list. It should be blocked.

**Step 4: Measure token savings.** Compare a session with and without settings.json by checking token usage in the API dashboard at console.anthropic.com. A properly configured project typically shows 30-50% lower token consumption.

**Step 5: Share with team.** Commit `.claude/settings.json` to version control so all team members benefit from the same optimized configuration. Add it to your repository's README as part of the developer setup instructions.


## Common Configuration Mistakes

**Using relative paths in MCP server config.** The `command` and `args` fields in MCP server configuration must use absolute paths. Relative paths fail because the working directory when Claude Code spawns the server may differ from your project root.

**Overly broad allow patterns.** Allowing `Bash(*)` defeats the purpose of permission controls. Instead, allow specific command prefixes like `Bash(npm test*)` and `Bash(git diff*)`.

**Missing the `.claude/` directory prefix.** The settings file goes in `.claude/settings.json`, not `settings.json` in the project root. This is a different location from `CLAUDE.md`, which does go in the project root.

**Not restarting after changes.** Claude Code reads settings.json at startup. Changes during a session take effect only in the next session. Always start a new session after modifying settings.
