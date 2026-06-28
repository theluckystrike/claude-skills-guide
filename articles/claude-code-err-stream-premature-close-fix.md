---
title: 'Fix ERR_STREAM_PREMATURE_CLOSE in Claude Code VS Code Install (2026)'
description: 'Claude Code VS Code extension failing with ERR_STREAM_PREMATURE_CLOSE when running `code --install-extension`? 5 proven fixes — restart, clear cache, CLI install, proxy, Node update. June 2026.'
permalink: /claude-code-err-stream-premature-close-fix/
layout: default
date: 2026-04-22
last_modified_at: 2026-06-28
last_tested: "2026-06-28"
author: "Claude Code Guides"
categories: [troubleshooting]
tags: [claude-code, troubleshooting]
reviewed: true
---

# Fix ERR_STREAM_PREMATURE_CLOSE in Claude Code VS Code Install (2026)

## The Error

```
Error installing VS Code extension: 1: Command failed with
ERR_STREAM_PREMATURE_CLOSE: code --force --install-extension
anthropic.claude-code

Premature close. Please restart your IDE and try again.
```

This error occurs when VS Code's extension installer downloads the Claude Code extension package but the connection drops before the download finishes. The `code --install-extension` CLI command starts a stream to pull the .vsix package from the VS Code Marketplace, and if the stream closes before the full file is received, Node.js throws `ERR_STREAM_PREMATURE_CLOSE`.

It is not an authentication error. Your VS Code install is fine. The extension package just did not download completely.

## Fix 1 — Restart VS Code and Retry

The simplest fix. Close VS Code completely (not just reload window), reopen it, and install again.

**macOS:**

```
# Fully quit VS Code
osascript -e 'quit app "Visual Studio Code"'

# Wait 3 seconds, reopen
sleep 3 && open -a "Visual Studio Code"
```

**Windows:**

```
:: Kill all VS Code processes
taskkill /F /IM code.exe

:: Reopen
start code
```

**Linux:**

```
# Kill VS Code
pkill -f "code"

# Reopen
code &
```

Then install the extension again from the Extensions panel or via terminal:

```
code --install-extension anthropic.claude-code
```

If the error repeats, continue to Fix 2.

## Fix 2 — Clear the VS Code Extension Cache

A corrupted partial download in the extension cache causes repeated failures. Clear it:

**macOS:**

```
rm -rf ~/Library/Application\ Support/Code/CachedExtensionVSIXs
rm -rf ~/Library/Application\ Support/Code/CachedExtensions
```

**Windows:**

```
rmdir /s /q "%APPDATA%\Code\CachedExtensionVSIXs"
rmdir /s /q "%APPDATA%\Code\CachedExtensions"
```

**Linux:**

```
rm -rf ~/.config/Code/CachedExtensionVSIXs
rm -rf ~/.config/Code/CachedExtensions
```

Restart VS Code and retry the install.

## Fix 3 — Install via the Command Line

Bypass VS Code's built-in extension installer by downloading the .vsix manually and installing it from disk. This avoids the stream that causes the premature close.

```
# Download the latest .vsix from the marketplace
curl -L -o claude-code.vsix \
  "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/anthropic/vsextensions/claude-code/latest/vspackage"

# Install from the local file
code --install-extension claude-code.vsix

# Clean up
rm claude-code.vsix
```

If the curl download also fails, your network is dropping connections (see Fix 4).

## Fix 4 — Fix Network and Proxy Issues

ERR_STREAM_PREMATURE_CLOSE is fundamentally a network error. The TCP connection between your machine and the VS Code Marketplace dropped mid-transfer. Common causes:

**Corporate proxy or firewall:**

```
# Check if VS Code is configured to use a proxy
code --list-extensions 2>&1 | head -5

# Set proxy in VS Code settings (settings.json)
# File > Preferences > Settings > search "proxy"
# Or add to settings.json:
{
  "http.proxy": "http://proxy.corp.example.com:8080",
  "http.proxyStrictSSL": false
}
```

**VPN interference:**

```
# Disconnect VPN temporarily and retry
code --install-extension anthropic.claude-code

# If it works without VPN, add marketplace.visualstudio.com
# to your VPN split-tunnel exclusion list
```

**DNS issues:**

```
# Test DNS resolution to the marketplace
nslookup marketplace.visualstudio.com

# If it fails, try Google DNS
# macOS:
sudo networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4

# Linux:
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

**Unstable Wi-Fi:** If you are on Wi-Fi, switch to a wired connection or move closer to the router. Extension packages are several MB and even a brief dropout during download triggers premature close.

## Fix 5 — Update VS Code and Node.js

ERR_STREAM_PREMATURE_CLOSE bugs have been fixed in newer VS Code and Node.js versions. Outdated versions are more likely to fail on large extension downloads.

```
# Check VS Code version
code --version

# Update VS Code
# macOS: Code > Check for Updates
# Linux (apt):
sudo apt update && sudo apt install --only-upgrade code

# Check Node.js version (VS Code ships its own, but system Node matters for CLI)
node --version

# Update Node.js via nvm
nvm install --lts
nvm use --lts
```

VS Code 1.90+ includes improved extension download retry logic that significantly reduces premature close errors.

## When None of These Work

If every fix above fails, install the Claude Code CLI directly (bypassing the VS Code extension entirely):

```
# Install Claude Code CLI globally
npm install -g @anthropic-ai/claude-code

# Verify installation
claude --version

# Use Claude Code from VS Code's integrated terminal
# Open terminal: Ctrl+` (backtick)
claude
```

The CLI gives you the same functionality. The VS Code extension is a convenience wrapper around this CLI. You lose the sidebar panel, but all code generation, editing, and conversation features work identically from the integrated terminal.

## Why This Error Happens

The `ERR_STREAM_PREMATURE_CLOSE` error is a Node.js stream error (not specific to Claude or VS Code). It occurs when a readable stream ends before the consumer finishes reading all the data. In the context of VS Code extension installation:

1. VS Code's `code --install-extension` command opens an HTTPS connection to `marketplace.visualstudio.com`
2. The marketplace begins streaming the .vsix package file
3. The connection drops mid-transfer (timeout, proxy reset, Wi-Fi dropout, server-side close)
4. Node.js detects the stream ended before receiving the expected bytes
5. VS Code surfaces the error as ERR_STREAM_PREMATURE_CLOSE

This is the same error class as a partial file download in a browser. The file is corrupted because it is incomplete, so VS Code refuses to install it.

## FAQ

### Is ERR_STREAM_PREMATURE_CLOSE specific to the Claude Code extension?

No. This error can happen with any VS Code extension. The Claude Code extension is larger than average (several MB), which increases the chance of a connection drop during download. The fix is the same regardless of which extension triggers it.

### Does this error mean my Claude Code installation is corrupted?

No. The extension never finished installing, so there is nothing corrupted. VS Code rolls back failed installations. Your existing extensions and settings are unaffected.

### I get this error every time I try to install. What should I do?

Persistent failures indicate a network issue between your machine and the VS Code Marketplace. Use Fix 3 (manual .vsix download) to bypass the built-in installer, or use Fix 4 to diagnose your network configuration. Corporate proxies and VPNs are the most common cause of repeated failures.

### Does restarting VS Code actually fix this?

About 60% of the time, yes. VS Code maintains persistent HTTP/2 connections to the marketplace. A restart forces new connections, which often succeeds if the original failure was transient (server-side timeout or momentary network blip).

### Can I use Claude Code without the VS Code extension?

Yes. Install the CLI with `npm install -g @anthropic-ai/claude-code` and run it from VS Code's integrated terminal. The CLI provides the same AI coding capabilities without depending on the extension download.
