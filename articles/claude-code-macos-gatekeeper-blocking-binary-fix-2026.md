---
title: "macOS Gatekeeper Blocking Binary Fix"
permalink: /claude-code-macos-gatekeeper-blocking-binary-fix-2026/
description: "Fix macOS Gatekeeper blocking Claude Code binary execution. Remove quarantine attribute with xattr to allow the downloaded binary to run."
last_tested: "2026-04-22"
render_with_liquid: false
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
