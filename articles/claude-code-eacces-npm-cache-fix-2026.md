---
title: "EACCES npm Cache Permission Error — Fix (2026)"
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
