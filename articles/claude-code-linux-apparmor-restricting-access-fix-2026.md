---
title: "Linux AppArmor Restricting Access Fix"
permalink: /claude-code-linux-apparmor-restricting-access-fix-2026/
description: "Fix Linux AppArmor restricting Claude Code file access. Create an AppArmor profile or set complain mode to allow Claude Code filesystem operations."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: EACCES: permission denied, open '/home/user/project/src/app.ts'
  AppArmor DENIED operation="open" profile="node" name="/home/user/project/src/app.ts"
  audit: type=1400 msg=apparmor="DENIED" operation="open" class="file"
  Claude Code blocked by AppArmor mandatory access control
```

This appears on Linux systems where AppArmor restricts the Node.js process (running Claude Code) from accessing files outside its allowed paths.

## The Fix

```bash
sudo aa-complain /usr/bin/node
```

1. Set the Node.js AppArmor profile to complain mode (logs violations but does not block).
2. Run Claude Code and verify it can access your project files.
3. Review AppArmor logs to create a proper allow-list profile.

## Why This Happens

AppArmor is a Linux mandatory access control system that restricts what files and operations a program can perform. Some Linux distributions (Ubuntu, SUSE) ship with AppArmor profiles for common programs. If a Node.js profile exists, it may restrict file access to a narrow set of directories, blocking Claude Code from reading or writing your project files. The EACCES error looks like a standard permission issue, but `dmesg` or `/var/log/syslog` reveals the AppArmor denial.

## If That Doesn't Work

Check AppArmor status for Node.js:

```bash
sudo aa-status | grep node
```

Create a custom AppArmor profile for Claude Code:

```bash
sudo tee /etc/apparmor.d/claude-code << 'EOF'
#include <tunables/global>
/usr/local/bin/node {
  #include <abstractions/base>
  #include <abstractions/nameservice>
  /home/** rw,
  /tmp/** rw,
  /usr/** r,
  /etc/** r,
}
EOF
sudo apparmor_parser -r /etc/apparmor.d/claude-code
```

Disable AppArmor for Node.js entirely (not recommended for production):

```bash
sudo aa-disable /usr/bin/node
```

Check audit logs for the exact denial:

```bash
sudo dmesg | grep apparmor | tail -20
```

## Prevention

```markdown
# CLAUDE.md rule
On Linux with AppArmor enabled, ensure the Node.js profile allows access to your project directory. Run 'sudo aa-status' to check. Use complain mode during development and enforce mode in production with a proper profile.
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
