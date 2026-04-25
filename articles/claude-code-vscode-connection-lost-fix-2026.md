---
title: "VS Code Connection Lost — Fix"
permalink: /claude-code-vscode-connection-lost-fix-2026/
description: "Restart the VS Code extension host to restore the dropped connection. Fixes the persistent reconnecting loop when Claude Code loses server contact."
last_tested: "2026-04-21"
---

## The Error

```
Connection to Claude Code lost. Reconnecting...
```

## The Fix

```bash
# In VS Code, open Command Palette (Cmd+Shift+P / Ctrl+Shift+P) and run:
Developer: Restart Extension Host
```

## Why This Works

The VS Code extension host process crashes or enters a deadlock state when memory pressure spikes during long sessions. Restarting the extension host re-establishes the WebSocket connection between the extension and the Claude Code language server without reloading the entire window.

## If That Doesn't Work

```bash
# Kill orphaned Claude Code processes and reload the window
pkill -f "claude-code" && sleep 2
# Then in VS Code Command Palette:
# Developer: Reload Window
```

Check if your VS Code version is outdated. Claude Code requires VS Code 1.85 or later. Run `code --version` and update if below that threshold. On macOS, also verify that the system did not put the process to sleep via App Nap — disable it for VS Code in Activity Monitor if reconnection failures correlate with periods of inactivity.

## Prevention

Add to your CLAUDE.md:
```
When using Claude Code in VS Code, save work frequently. If sessions exceed 2 hours, manually restart the extension host before the connection degrades. Keep VS Code updated to latest stable release.
```

## See Also

- [VS Code Extension Connection Timeout Fix](/claude-code-vscode-extension-connection-timeout-fix-2026/)
- [Claude Code VS Code Extension Fails to Activate — Fix (2026)](/claude-code-vscode-extension-fails-to-activate-fix/)
- [VS Code Extension Consuming Excessive CPU Fix](/claude-code-vscode-extension-excessive-cpu-fix-2026/)

## Related Error Messages

This fix also applies if you see these related error messages:

- `ETIMEDOUT: connection timed out`
- `RequestTimeout: request took longer than 120000ms`
- `ESOCKETTIMEDOUT`
- `ECONNRESET: connection reset by peer`
- `ECONNREFUSED: connection refused`

## Frequently Asked Questions

### What is the default timeout for Claude Code API requests?

The default timeout is 120 seconds (120000ms). For complex operations involving large codebases or multi-file edits, this may be insufficient. Increase it with `claude config set api_timeout 300000` for a 5-minute timeout.

### Can network latency cause timeouts?

Yes. Corporate proxies, VPNs, and DNS filtering services add round-trip latency. Measure your baseline latency with `curl -o /dev/null -s -w '%{time_total}' https://api.anthropic.com/v1/messages`. If it exceeds 5 seconds, route API traffic outside the proxy.

### Do timeouts consume API credits?

Partially. If the server began processing your request before the client timed out, the input tokens are consumed even though you never received a response. Long timeouts reduce wasted credits by allowing the response to complete.

### Why does Claude Code lose connection during long operations?

Long-running operations can exceed keep-alive timeouts on intermediate proxies and load balancers. If a proxy closes an idle connection after 60 seconds and Claude Code's request takes 90 seconds, the connection is severed before the response arrives.


## Related Guides

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

## Making the Right Choice

When deciding between these options, consider these practical factors:

**Project requirements.** The best tool depends on what your project actually needs, not which is more popular. A small personal project has different requirements than an enterprise application with compliance needs.

**Team familiarity.** Choosing a tool your team already knows reduces onboarding time. The productivity gains from familiarity often outweigh the theoretical advantages of switching to a newer tool.

**Ecosystem maturity.** Check the package ecosystem, community size, and documentation quality. A tool with 10,000 npm packages and active Stack Overflow answers will be easier to work with than a newer tool with cutting-edge features but sparse documentation.

**Migration cost.** If you are considering switching, estimate the migration effort realistically. Include time for rewriting tests, updating CI/CD pipelines, retraining the team, and handling edge cases that only appear in production.

## Decision Framework

| Factor | Weight | Option A | Option B |
|--------|--------|----------|----------|
| Performance | Medium | Score 1-5 | Score 1-5 |
| Ecosystem | High | Score 1-5 | Score 1-5 |
| Learning curve | Medium | Score 1-5 | Score 1-5 |
| Long-term viability | High | Score 1-5 | Score 1-5 |

Score each factor for your specific situation, multiply by weight, and compare totals. This structured approach prevents decisions based on hype or recency bias.
