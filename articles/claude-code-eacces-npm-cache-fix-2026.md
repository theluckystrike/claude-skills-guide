---
title: "EACCES npm Cache Permission Error — Fix"
permalink: /claude-code-eacces-npm-cache-fix-2026/
description: "Fix EACCES permission denied on npm cache during Claude Code install. Fix ownership of ~/.npm cache directory."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
npm ERR! code EACCES
npm ERR! syscall open
npm ERR! path /Users/you/.npm/_cacache/index-v5/3a/bc/defg123
npm ERR! errno -13
npm ERR! permission denied
```

This error occurs during `npm install -g @anthropic-ai/claude-code` when the npm cache directory has incorrect ownership, usually caused by a previous `sudo npm install`.

## The Fix

1. Fix ownership of the npm cache:

```bash
sudo chown -R $(whoami) ~/.npm
```

2. Retry the installation:

```bash
npm install -g @anthropic-ai/claude-code
```

3. Verify it works:

```bash
claude --version
```

## Why This Happens

When you run `sudo npm install -g` even once, npm creates cache files owned by root in `~/.npm/`. Subsequent non-sudo npm commands cannot read or write to these root-owned cache files, causing EACCES errors. The cache is separate from the global install directory — fixing PATH does not help here.

## If That Doesn't Work

- Delete the entire cache and rebuild:

```bash
rm -rf ~/.npm/_cacache
npm cache verify
npm install -g @anthropic-ai/claude-code
```

- Check for other root-owned files in your home directory:

```bash
find ~ -maxdepth 3 -user root -type f 2>/dev/null | head -20
```

- If using nvm, reinstall nvm's node to get a clean npm environment:

```bash
nvm install 22 --reinstall-packages-from=current
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# npm Permissions
- Never use sudo with npm install. Use nvm instead.
- If EACCES appears, fix with: sudo chown -R $(whoami) ~/.npm
- Use npm config set prefix ~/.npm-global to avoid system directories.
```


## Related

- [process exited with code 1 fix](/claude-code-process-exited-code-1-fix/) — How to fix Claude Code process exited with code 1 error
- [Claude Code EACCES Permission Denied Global Install — Fix (2026)](/claude-code-eacces-permission-denied-npm-global-install-fix/)

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
