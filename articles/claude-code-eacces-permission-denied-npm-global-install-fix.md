---
title: "Claude Code EACCES Permission Denied"
description: "Fix Claude Code EACCES permission denied on npm global install. Change npm prefix to home directory. Step-by-step solution."
permalink: /claude-code-eacces-permission-denied-npm-global-install-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
npm ERR! code EACCES
npm ERR! syscall mkdir
npm ERR! path /usr/local/lib/node_modules/@anthropic-ai/claude-code
npm ERR! errno -13
npm ERR! Error: EACCES: permission denied, mkdir '/usr/local/lib/node_modules/@anthropic-ai/claude-code'
npm ERR! Please try running this command again as root/Administrator.
```

## The Fix

1. **Set npm's global prefix to a user-owned directory (never use sudo)**

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
```

2. **Add the new path to your shell profile**

```bash
# For zsh (macOS default):
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# For bash:
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

3. **Verify the fix:**

```bash
npm install -g @anthropic-ai/claude-code
claude --version
# Expected: @anthropic-ai/claude-code/X.X.X
```

## Why This Happens

The default npm global install directory (`/usr/local/lib/node_modules`) is owned by root on most systems. Running `npm install -g` as your user account fails because it cannot write to root-owned directories. Using `sudo npm install -g` creates files owned by root that cause further permission issues later. The correct fix is changing npm's prefix to a directory your user account controls.

## If That Doesn't Work

- **Alternative 1:** Use `npx @anthropic-ai/claude-code` to run without global install — it downloads and executes in one step
- **Alternative 2:** Install via `nvm` which manages its own prefix: `nvm install 20 && npm install -g @anthropic-ai/claude-code`
- **Check:** Run `npm config get prefix` and `ls -la $(npm config get prefix)/lib/node_modules/` to verify ownership

## Prevention

Add to your `CLAUDE.md`:
```markdown
Never use sudo for npm install -g. Set npm prefix to ~/.npm-global. Use nvm or volta for Node.js version management to avoid system permission conflicts.
```

**Related articles:** [Claude Code Command Not Found Fix](/claude-code-command-not-found-after-install-fix/), [NPM Install EACCES Fix](/claude-code-npm-install-eacces-permission-fix/), [Troubleshooting Hub](/troubleshooting-hub/)


## Related

- [process exited with code 1 fix](/claude-code-process-exited-code-1-fix/) — How to fix Claude Code process exited with code 1 error
- [npm Global Install Permission Denied — Fix (2026)](/claude-code-npm-global-install-permission-denied-fix-2026/)
- [EACCES npm Cache Permission Error — Fix (2026)](/claude-code-eacces-npm-cache-fix-2026/)
