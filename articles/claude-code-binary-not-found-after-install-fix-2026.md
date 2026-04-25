---
title: "claude: command not found After Install — Fix (2026)"
permalink: /claude-code-binary-not-found-after-install-fix-2026/
description: "claude: command not found After Install — Fix — step-by-step fix with tested commands, error codes, and verified solutions for developers."
last_tested: "2026-04-22"
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


## Related Guides

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions
