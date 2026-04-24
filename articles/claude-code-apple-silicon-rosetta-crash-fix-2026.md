---
title: "Apple Silicon Rosetta Crash Error — Fix"
permalink: /claude-code-apple-silicon-rosetta-crash-fix-2026/
description: "Fix Claude Code crashing on Apple Silicon Mac. Install arm64-native Node.js instead of x86 version running through Rosetta."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
[1]    12345 killed     claude
$ file $(which node)
/usr/local/bin/node: Mach-O 64-bit executable x86_64
```

Claude Code crashes or is killed immediately on Apple Silicon Macs when running an x86_64 (Intel) Node.js binary through Rosetta 2 translation. This causes excessive memory usage and eventual OOM kills.

## The Fix

1. Check if your Node is native ARM64:

```bash
file $(which node)
# Should say: Mach-O 64-bit executable arm64
```

2. Install native ARM64 Node via nvm:

```bash
arch -arm64 zsh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.zshrc
nvm install 22
```

3. Verify the architecture:

```bash
file $(which node)
# Must show: arm64
node -e "console.log(process.arch)"
# Must show: arm64
```

4. Reinstall Claude Code:

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

## Why This Happens

When Node.js is installed via an Intel-only installer or from an x86 terminal session (Terminal opened via Rosetta), you get the x86_64 binary. Rosetta 2 translates it at runtime, adding 30-50% memory overhead. Claude Code's Node process can exceed available memory during large operations and get killed by the OOM killer. Native ARM64 Node uses half the memory.

## If That Doesn't Work

- Ensure your terminal itself is not running under Rosetta:

```bash
# Check terminal architecture
uname -m
# Should say: arm64, not x86_64
```

- If iTerm2 or Terminal shows x86_64, uncheck "Open using Rosetta" in the app's Get Info panel.

- Remove all Intel Node installations:

```bash
sudo rm -rf /usr/local/lib/node_modules
brew uninstall node  # If installed via x86 Homebrew
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Apple Silicon
- Always verify: uname -m returns arm64 before installing tools.
- Use nvm with native ARM64 shell. Never install Node from x86 terminal.
- If crashes occur, check: file $(which node) — must show arm64.
```

## See Also

- [VS Code Extension Host Crash Fix](/claude-code-extension-host-crash-fix-2026/)
