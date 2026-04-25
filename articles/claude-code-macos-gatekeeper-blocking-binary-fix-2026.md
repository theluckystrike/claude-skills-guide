---
layout: default
title: "macOS Gatekeeper Blocking Binary — Fix (2026)"
permalink: /claude-code-macos-gatekeeper-blocking-binary-fix-2026/
date: 2026-04-20
description: "Fix macOS Gatekeeper blocking Claude Code binary execution. Remove quarantine attribute with xattr to allow the downloaded binary to run."
last_tested: "2026-04-22"
---

## The Error

```
"claude" cannot be opened because the developer cannot be verified.
  macOS cannot verify that this app is free from malware.
  Gatekeeper blocked execution of /usr/local/bin/claude
  com.apple.quarantine attribute set on binary
```

This appears when macOS Gatekeeper blocks the Claude Code binary because it was downloaded from the internet and is not signed with an Apple-recognized developer certificate.

## The Fix

```bash
xattr -d com.apple.quarantine $(which claude)
```

1. Remove the quarantine extended attribute from the Claude Code binary.
2. Try running `claude` again — Gatekeeper should no longer block it.
3. If `which claude` returns nothing, find the binary: `npm root -g`/@anthropic-ai/claude-code.

## Why This Happens

macOS Gatekeeper adds a quarantine extended attribute (`com.apple.quarantine`) to files downloaded from the internet. npm packages downloaded via `npm install -g` can inherit this attribute. When you try to execute the binary, Gatekeeper sees the quarantine flag and blocks it because it is not notarized by Apple. This is a macOS security feature, not a Claude Code bug.

## If That Doesn't Work

Allow the binary through System Settings:

```
System Settings > Privacy & Security > scroll down
> "claude" was blocked > Allow Anyway
```

Remove quarantine from the entire package:

```bash
xattr -rd com.apple.quarantine $(npm root -g)/@anthropic-ai/claude-code
```

Reinstall without quarantine by using a package manager:

```bash
# If installed via Homebrew, quarantine is usually not applied:
brew install claude-code
```

Check for quarantine attribute:

```bash
xattr -l $(which claude)
# Look for com.apple.quarantine in output
```

## Prevention

```markdown
# CLAUDE.md rule
After installing Claude Code on macOS, run 'xattr -d com.apple.quarantine $(which claude)' to remove Gatekeeper restrictions. Or install via Homebrew which handles code signing automatically.
```

## Related Error Messages

This fix also applies if you see these related error messages:

- `npm ERR! code EACCES`
- `npm ERR! code ERESOLVE`
- `npm ERR! peer dep missing`
- `'claude' cannot be opened because it is from an unidentified developer`
- `macOS blocked the app from running`

## Frequently Asked Questions

### Should I use npm or pnpm with Claude Code?

Claude Code works with any Node.js package manager. If your project uses pnpm, add `Use pnpm instead of npm for all package operations` to your CLAUDE.md so Claude Code respects your toolchain choice.

### Why does Claude Code sometimes run npm commands that fail?

Claude Code infers the package manager from lock files. If both `package-lock.json` and `pnpm-lock.yaml` exist, it may pick the wrong one. Delete the unused lock file or add an explicit instruction in CLAUDE.md.

### How do I verify my npm installation is working?

Run `npm doctor` to check your npm environment. It validates the registry connection, permissions, cache integrity, and Node.js compatibility in one command.

### Why does macOS block Claude Code?

macOS Gatekeeper blocks applications that are not signed with an Apple Developer ID or downloaded from the App Store. Binaries installed via npm may not have the required code signature, triggering Gatekeeper restrictions.


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
