---
title: "VS Code Extension Connection Timeout (2026)"
permalink: /claude-code-vscode-extension-connection-timeout-fix-2026/
description: "Fix VS Code extension connection timeout for Claude Code. Restart the extension host and check WebSocket port to restore the editor integration."
last_tested: "2026-04-22"
---

## The Error

```
[Claude Code Extension] Connection timeout after 10000ms
  Failed to establish WebSocket connection to ws://127.0.0.1:19836
  Extension status: Disconnected — Claude Code CLI not detected
```

This appears in VS Code's output panel when the Claude Code extension cannot connect to the Claude Code CLI process running in the integrated terminal.

## The Fix

```bash
# In VS Code, press Ctrl+Shift+P / Cmd+Shift+P:
# > Developer: Restart Extension Host
```

1. Restart the VS Code extension host from the command palette.
2. If that does not work, close and reopen the integrated terminal where Claude Code is running.
3. Verify Claude Code is running: check for the process with `ps aux | grep claude`.

## Why This Happens

The VS Code Claude Code extension communicates with the CLI via a local WebSocket connection. The connection can time out if Claude Code was started before the extension loaded, if the WebSocket port is blocked by a firewall, or if VS Code's extension host crashed and restarted without re-establishing the connection. Network-level firewalls or VPN software can also block localhost WebSocket connections.

## If That Doesn't Work

Kill and restart Claude Code in the terminal:

```bash
# Close existing session with Ctrl+C, then:
claude
```

Check if the WebSocket port is in use:

```bash
lsof -i :19836
```

Reinstall the VS Code extension:

```bash
code --uninstall-extension anthropic.claude-code
code --install-extension anthropic.claude-code
```

## Prevention

```markdown
# CLAUDE.md rule
If the VS Code extension shows "Disconnected", restart the extension host first. If that fails, restart Claude Code in the terminal. Keep the Claude Code extension updated to the latest version.
```

## See Also

- [Connection Reset by Peer Error — Fix (2026)](/claude-code-connection-reset-by-peer-fix-2026/)
- [Garbage Collection Pause Causing Timeout Fix](/claude-code-gc-pause-causing-timeout-fix-2026/)
- [DNS Resolution Timeout Error — Fix (2026)](/claude-code-dns-resolution-timeout-fix-2026/)
- [Claude Code vs VS Code IntelliSense: Completion Compared](/claude-code-vs-vscode-intellisense-comparison/)
- [Claude Code VS Code Extension Fails to Activate — Fix (2026)](/claude-code-vscode-extension-fails-to-activate-fix/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


## Related Guides

- [Fix WebSocket Connection Failures](/claude-code-websocket-connection-failed-fix/)
- [Fix Claude Code MCP Server Connection](/claude-code-mcp-server-connection-closed-fix/)
- [Claude Code MCP Server Connection](/claude-code-mcp-server-connection-refused-fix/)
- [Claude Code VS Code Connection Lost — Fix (2026)](/claude-code-vscode-connection-lost-fix-2026/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json. When working with Claude Code on this topic, keep these implementation details in mind: **Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations. **Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code. **Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%. **Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results."
      }
    }
  ]
}
</script>
