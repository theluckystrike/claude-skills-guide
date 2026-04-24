---
title: "Homebrew Formula Outdated Error — Fix (2026)"
permalink: /claude-code-homebrew-formula-outdated-fix-2026/
description: "Homebrew Formula Outdated Error — Fix — step-by-step fix with tested commands, error codes, and verified solutions for developers."
last_tested: "2026-04-22"
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

## See Also

- [Homebrew vs System Python Conflict Fix](/claude-code-homebrew-vs-system-python-conflict-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `npm ERR! code EACCES`
- `npm ERR! code ERESOLVE`
- `npm ERR! peer dep missing`
- `fatal: not a git repository`
- `error: failed to push some refs`

## Frequently Asked Questions

### Should I use npm or pnpm with Claude Code?

Claude Code works with any Node.js package manager. If your project uses pnpm, add `Use pnpm instead of npm for all package operations` to your CLAUDE.md so Claude Code respects your toolchain choice.

### Why does Claude Code sometimes run npm commands that fail?

Claude Code infers the package manager from lock files. If both `package-lock.json` and `pnpm-lock.yaml` exist, it may pick the wrong one. Delete the unused lock file or add an explicit instruction in CLAUDE.md.

### How do I verify my npm installation is working?

Run `npm doctor` to check your npm environment. It validates the registry connection, permissions, cache integrity, and Node.js compatibility in one command.

### Why does Claude Code require git?

Claude Code uses git for several core operations: tracking file changes, creating commits, reading blame information, searching history with `git log`, and managing branches. Without git, these operations fail and Claude Code falls back to less efficient alternatives.


## Related Guides

- [Claude Code For Homebrew Formula](/claude-code-for-homebrew-formula-workflow-tutorial/)
- [Claude Code for Homebrew Bundle](/claude-code-for-homebrew-bundle-workflow-tutorial/)
- [Fix Claude Code Using Outdated Patterns](/claude-code-generates-outdated-patterns-fix-2026/)

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
