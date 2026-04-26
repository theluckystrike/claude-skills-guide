---
layout: default
title: "XDG Config Directory Permissions — Fix (2026)"
permalink: /claude-code-xdg-config-directory-permissions-fix-2026/
date: 2026-04-20
description: "Fix XDG config directory permission denied error in Claude Code. Reset ownership and permissions on ~/.config/claude-code to restore configuration access."
last_tested: "2026-04-22"
---

## The Error

```
Error: EACCES: permission denied, mkdir '/home/user/.config/claude-code'
  Cannot create configuration directory
  XDG_CONFIG_HOME=/home/user/.config is owned by root (installed via sudo)
  Claude Code needs write access to store settings and conversation history
```

This appears when Claude Code cannot write to its configuration directory because the parent directory has incorrect ownership or permissions.

## The Fix

```bash
sudo chown -R $(whoami) ~/.config/claude-code
chmod -R 755 ~/.config/claude-code
```

1. Fix the ownership of the Claude Code config directory.
2. Set appropriate permissions (read/write for owner, read for others).
3. Restart Claude Code — it should now write configuration normally.

## Why This Happens

The `~/.config` directory (XDG_CONFIG_HOME) sometimes gets created with root ownership when software is installed with `sudo`. If `sudo npm install -g @anthropic-ai/claude-code` created the config directory, it is owned by root. Subsequent runs as your normal user cannot write to it. This is especially common on Linux systems where `npm install -g` requires `sudo`.

## If That Doesn't Work

Fix the entire `.config` directory if the problem is broader:

```bash
sudo chown -R $(whoami) ~/.config
```

Use a custom config directory:

```bash
export XDG_CONFIG_HOME="$HOME/.claude-config"
mkdir -p "$XDG_CONFIG_HOME/claude-code"
claude
```

If npm's global directory has permission issues, fix that too:

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
export PATH="$HOME/.npm-global/bin:$PATH"
npm install -g @anthropic-ai/claude-code
```

## Prevention

```markdown
# CLAUDE.md rule
Never install Claude Code with sudo. Use npm prefix or nvm to avoid root-owned directories. If you see EACCES errors, fix ownership with chown before proceeding. Check directory permissions after any sudo operation.
```

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
