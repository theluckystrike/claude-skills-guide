---
title: "Node 18+ Required Version Error — Fix (2026)"
permalink: /claude-code-node-version-18-required-fix-2026/
description: "Node 18+ Required Version Error — Fix — step-by-step fix with tested commands, error codes, and verified solutions for developers."
last_tested: "2026-04-22"
---

## The Error

```
Error: Claude Code requires Node.js 18 or higher. Current version: v16.20.2
Please upgrade Node.js: https://nodejs.org/
```

This error appears when you try to run Claude Code on a Node.js version older than 18. Claude Code uses ES module features and APIs that require Node 18+.

## The Fix

1. Check your current Node version:

```bash
node --version
```

2. Upgrade with nvm (recommended):

```bash
nvm install 22
nvm use 22
nvm alias default 22
```

3. Or upgrade with Homebrew on macOS:

```bash
brew update && brew upgrade node
```

4. Reinstall Claude Code on the new Node version:

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

## Why This Happens

Claude Code depends on Node.js features introduced in v18: native fetch API, structuredClone, stable AbortController, and ES module import assertions. These features do not exist in Node 16 or earlier. Many Linux distributions and Docker images ship with older Node versions by default.

## If That Doesn't Work

- If nvm is not installed:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
exec $SHELL
nvm install 22
```

- If using Docker, update your base image:

```dockerfile
FROM node:22-slim
RUN npm install -g @anthropic-ai/claude-code
```

- If system node is managed by your OS package manager and cannot be changed, use nvm to install a parallel version that takes priority in PATH.

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Node.js Version
- Minimum: Node 18. Recommended: Node 22 LTS.
- Add .nvmrc file to project root: echo "22" > .nvmrc
- In CI, always specify: node-version: '22' in GitHub Actions.
```

## See Also

- [Claude Code Node Version Mismatch — Fix (2026)](/claude-code-node-version-mismatch-fix/)
- [Wrong Node.js Version in PATH Fix](/claude-code-wrong-node-version-in-path-fix-2026/)
- [Workspace Trust Required for Claude Code — Fix (2026)](/claude-code-workspace-trust-required-fix-2026/)

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

- [CLAUDE.md Version Control Strategies](/claude-md-version-control-strategies/)
- [Claude Code for Version Matrix Workflow](/claude-code-for-version-matrix-workflow-tutorial-guide/)
- [Claude Code Version History and Changes](/claude-code-version-history-changes-2026/)
- [TLS Version Negotiation Failure — Fix](/claude-code-tls-version-negotiation-failure-fix-2026/)

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
