---
title: "Windows WSL Path Conflict Error — Fix"
permalink: /claude-code-windows-wsl-path-conflict-fix-2026/
description: "Fix Claude Code path conflicts between Windows and WSL. Use WSL-native node, not Windows node accessible via /mnt/c/."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
/mnt/c/Program Files/nodejs/node.exe: cannot execute binary file: Exec format error
$ which node
/mnt/c/Program Files/nodejs/node.exe
```

This error occurs in WSL when the PATH includes Windows directories, causing WSL to try running the Windows `node.exe` binary instead of a Linux-native node binary.

## The Fix

1. Install Node.js natively inside WSL:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.bashrc
nvm install 22
```

2. Remove Windows paths from WSL PATH:

```bash
echo '[interop]
appendWindowsPath = false' | sudo tee -a /etc/wsl.conf
```

3. Restart WSL:

```powershell
# In Windows PowerShell:
wsl --shutdown
```

4. Reinstall Claude Code inside WSL:

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

## Why This Happens

WSL2 by default appends Windows PATH entries to the Linux PATH. This means `node`, `npm`, and other commands resolve to their Windows `.exe` versions in `/mnt/c/Program Files/nodejs/`. These Windows binaries cannot execute in the Linux environment, causing "Exec format error." Claude Code must run with Linux-native Node.js inside WSL.

## If That Doesn't Work

- Manually override the PATH to prioritize WSL node:

```bash
export PATH="$HOME/.nvm/versions/node/v22.12.0/bin:$PATH"
echo 'export PATH="$HOME/.nvm/versions/node/v22.12.0/bin:$PATH"' >> ~/.bashrc
```

- Verify you are running the correct binary:

```bash
file $(which node)
# Should say: ELF 64-bit LSB executable (Linux)
# Not: PE32+ executable (Windows)
```

- If you need Windows interop for other tools, selectively remove only the nodejs path.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# WSL Configuration
- Set appendWindowsPath = false in /etc/wsl.conf.
- Install Node.js via nvm inside WSL, not from Windows.
- Always verify: file $(which node) shows ELF, not PE32+.
```

## See Also

- [Devcontainer Claude Code Path Missing Fix](/claude-code-devcontainer-path-missing-fix-2026/)
- [Certificate Pinning Conflict Error — Fix (2026)](/claude-code-certificate-pinning-conflict-fix-2026/)
- [Git Worktree Lock Conflict Fix](/claude-code-worktree-lock-conflict-fix-2026/)
- [Peer Dependency Conflict npm Error — Fix (2026)](/claude-code-peer-dependency-conflict-fix-2026/)
- [Claude Code Prettier Format Conflict — Fix (2026)](/claude-code-prettier-format-conflict-fix/)
