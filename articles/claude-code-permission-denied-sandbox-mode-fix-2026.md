---
layout: default
title: "Claude Code Permission Denied Sandbox — Fix (2026)"
permalink: /claude-code-permission-denied-sandbox-mode-fix-2026/
date: 2026-04-20
description: "Add operation to permissions.allow in settings to fix sandbox denial. Or run with --dangerously-skip-permissions for fully trusted projects."
last_tested: "2026-04-21"
---

## The Error

```
Permission denied: sandbox mode blocks this operation
```

## The Fix

```bash
# Allow specific operations through the sandbox by updating settings
# In .claude/settings.json:
cat > .claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(npm run build)",
      "Bash(npm test)",
      "Bash(git *)"
    ]
  }
}
EOF

# Or approve the operation interactively when prompted
# Type 'y' when Claude asks for permission
```

## Why This Works

Claude Code's sandbox mode restricts operations that could modify system state, access the network, or execute arbitrary code. Each blocked operation must be explicitly allowlisted in settings or approved at runtime. The sandbox intercepts the syscall and rejects it before execution, so the operation never partially completes.

## If That Doesn't Work

```bash
# Run Claude Code with the --dangerously-skip-permissions flag for trusted projects
claude --dangerously-skip-permissions "Run the full deploy pipeline"

# Or use the Bash tool's dangerouslyDisableSandbox parameter
# (only available when running as an SDK integration)

# Check if the issue is OS-level (macOS sandbox) vs Claude sandbox:
ls -la /path/to/blocked/resource
```

The `--dangerously-skip-permissions` flag bypasses all permission checks (see the [dangerously skip permissions guide](/claude-code-dangerously-skip-permissions-guide/)). Use only in trusted, local development environments.

## Prevention

Add to your CLAUDE.md:
```
Pre-approve all known build and test commands in .claude/settings.json under permissions.allow. Use glob patterns for command families (e.g., "Bash(npm *)"). Never use --dangerously-skip-permissions in shared or production environments.
```

## See Also

- [EACCES Permission Denied Config Dir — Fix (2026)](/claude-code-config-dir-permission-denied-fix-2026/)
- [File Descriptor Leak in Watch Mode Fix](/claude-code-file-descriptor-leak-watch-mode-fix-2026/)

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




**Set it up →** Build your permission config with our [Permission Configurator](/permissions/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)