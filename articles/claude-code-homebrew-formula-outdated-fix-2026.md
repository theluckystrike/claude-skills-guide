---
title: "Homebrew Formula Outdated Error — Fix (2026)"
permalink: /claude-code-homebrew-formula-outdated-fix-2026/
description: "Fix outdated Homebrew Node formula blocking Claude Code install. Run brew update and brew upgrade node to get latest."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
$ brew install node
Warning: node 18.19.0 is already installed and up-to-date.
$ npm install -g @anthropic-ai/claude-code
npm ERR! engine Unsupported engine: wanted: >=20.0.0
npm ERR! notsup Required: {"node":">=20.0.0"}
```

This error occurs when Homebrew's node formula is pinned to an older version that does not meet Claude Code's minimum requirements.

## The Fix

1. Update Homebrew and upgrade node:

```bash
brew update
brew upgrade node
```

2. If Homebrew is still on an old version:

```bash
brew uninstall node
brew install node@22
brew link node@22 --force --overwrite
```

3. Verify and reinstall Claude Code:

```bash
node --version
npm install -g @anthropic-ai/claude-code
claude --version
```

## Why This Happens

Homebrew sometimes lags behind official Node.js releases, especially when the formula maintainers are slow to update. If you installed a specific versioned formula like `node@18`, it will not automatically upgrade to `node@22`. Claude Code may raise its minimum Node version with updates, leaving Homebrew-managed installations behind.

## If That Doesn't Work

- Unpin the node formula if it was pinned:

```bash
brew unpin node
brew upgrade node
```

- Switch from Homebrew to nvm for better version control:

```bash
brew uninstall node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.zshrc
nvm install 22
```

- Clean up conflicting installations:

```bash
brew cleanup node
which -a node
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Node.js Management
- Prefer nvm over Homebrew for Node.js version management.
- If using Homebrew, run brew upgrade node monthly.
- Never pin Node.js to a specific version unless a project requires it.
```
