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

## See Also

- [PATH Not Updated After Install — Fix (2026)](/claude-code-path-not-updated-after-install-fix-2026/)
- [macOS Gatekeeper Blocking Binary Fix](/claude-code-macos-gatekeeper-blocking-binary-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `npm ERR! code EACCES`
- `npm ERR! code ERESOLVE`
- `npm ERR! peer dep missing`
- `Error: Claude Code requires Node.js 18 or later`
- `SyntaxError: Unexpected token '??' — Node 14 detected`

## Frequently Asked Questions

### Should I use npm or pnpm with Claude Code?

Claude Code works with any Node.js package manager. If your project uses pnpm, add `Use pnpm instead of npm for all package operations` to your CLAUDE.md so Claude Code respects your toolchain choice.

### Why does Claude Code sometimes run npm commands that fail?

Claude Code infers the package manager from lock files. If both `package-lock.json` and `pnpm-lock.yaml` exist, it may pick the wrong one. Delete the unused lock file or add an explicit instruction in CLAUDE.md.

### How do I verify my npm installation is working?

Run `npm doctor` to check your npm environment. It validates the registry connection, permissions, cache integrity, and Node.js compatibility in one command.

### What Node.js version does Claude Code require?

Claude Code requires Node.js 18 or later. Node.js 20 LTS is recommended for the best compatibility and performance. Check your version with `node --version`.
