---
title: "claude: command not found After Install — Fix (2026)"
permalink: /claude-code-binary-not-found-after-install-fix-2026/
description: "Fix 'claude: command not found' after npm install. Add npm global bin directory to your PATH in .zshrc or .bashrc."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
zsh: command not found: claude
```

This error appears immediately after successfully running `npm install -g @anthropic-ai/claude-code`. The binary exists but your shell cannot find it.

## The Fix

1. Find where npm installed the binary:

```bash
npm bin -g
```

2. Add that directory to your PATH:

```bash
echo "export PATH=\"$(npm bin -g):\$PATH\"" >> ~/.zshrc
source ~/.zshrc
```

3. Verify the fix:

```bash
which claude
claude --version
```

4. If using bash instead of zsh:

```bash
echo "export PATH=\"$(npm bin -g):\$PATH\"" >> ~/.bashrc
source ~/.bashrc
```

## Why This Happens

npm installs global binaries to a directory that may not be in your shell's PATH. This is common when using a custom npm prefix, nvm, or when your shell profile has not been reloaded since npm was configured. The binary is installed correctly but the shell does not know where to find it.

## If That Doesn't Work

- Find the binary manually:

```bash
find / -name "claude" -type f 2>/dev/null | head -5
```

- If using nvm, ensure the nvm initialization is in your shell profile:

```bash
grep -c "nvm" ~/.zshrc
# Should return at least 1
```

- Create a symlink as a quick workaround:

```bash
sudo ln -sf "$(npm bin -g)/claude" /usr/local/bin/claude
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# PATH Setup
- After installing global npm packages, run: source ~/.zshrc
- Add npm bin -g output to PATH in your shell profile.
- Use nvm which automatically manages PATH for each Node version.
```
