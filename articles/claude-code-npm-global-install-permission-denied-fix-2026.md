---
title: "npm Global Install Permission Denied"
permalink: /claude-code-npm-global-install-permission-denied-fix-2026/
description: "Fix EACCES permission denied on npm install -g @anthropic-ai/claude-code. Use nvm or fix npm prefix to avoid sudo."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
npm ERR! Error: EACCES: permission denied, mkdir '/usr/local/lib/node_modules/@anthropic-ai'
npm ERR! code EACCES
npm ERR! syscall mkdir
npm ERR! path /usr/local/lib/node_modules/@anthropic-ai/claude-code
```

This error occurs when running `npm install -g @anthropic-ai/claude-code` without sufficient permissions to write to the global node_modules directory.

## The Fix

1. The best fix is to use nvm (Node Version Manager) which installs to your home directory:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.zshrc
nvm install 22
nvm use 22
npm install -g @anthropic-ai/claude-code
```

2. Alternatively, change npm's default directory:

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
npm install -g @anthropic-ai/claude-code
```

3. Verify the installation:

```bash
which claude
claude --version
```

## Why This Happens

On macOS and Linux, the default npm global prefix is `/usr/local` which is owned by root. Running `npm install -g` tries to write there without permission. Using `sudo npm install -g` is dangerous because it creates root-owned files in your project and can break future installs. The correct fix is to change where npm installs global packages.

## If That Doesn't Work

- If nvm is already installed but still failing, ensure you are using the nvm-managed node:

```bash
nvm which current
which npm
```

- Fix ownership of the npm cache:

```bash
sudo chown -R $(whoami) ~/.npm
```

- On macOS, if Homebrew manages node, use Homebrew instead:

```bash
brew install node
npm install -g @anthropic-ai/claude-code
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Node.js Setup
- Use nvm for Node.js version management. Never use sudo with npm.
- Minimum Node version: 18. Recommended: 22 LTS.
- Global npm prefix should be in home directory, not /usr/local.
```

## See Also

- [EACCES Permission Denied Config Dir — Fix (2026)](/claude-code-config-dir-permission-denied-fix-2026/)
- [Claude Code EACCES Permission Denied Global Install — Fix (2026)](/claude-code-eacces-permission-denied-npm-global-install-fix/)
