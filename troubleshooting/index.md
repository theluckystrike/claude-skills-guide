---
title: "Claude Code Troubleshooting"
permalink: /troubleshooting/
description: "Fix any Claude Code issue — performance problems, installation failures, configuration conflicts, and IDE integration troubleshooting."
layout: default
date: 2026-04-20
---

# Claude Code Troubleshooting

This page covers non-error issues: Claude Code running slowly, refusing to start, producing wrong output, ignoring your instructions, or behaving unexpectedly. If you are looking for specific error codes and messages, see the [Error Handling](/error-handling/) reference instead.

Every issue below links to a detailed troubleshooting guide with verified solutions.

<div style="background:linear-gradient(135deg,rgba(110,231,183,0.08),rgba(96,165,250,0.05));border:1px solid rgba(110,231,183,0.2);border-radius:8px;padding:16px 20px;margin:20px 0;">
<strong style="color:#6ee7b7;">Interactive Tool:</strong> Try our <a href="/diagnose/" style="color:#60a5fa;">Error Diagnostic Tool</a> — troubleshoot any Claude Code issue step-by-step.
</div>

---

## Performance Issues

When Claude Code feels slow, the problem is usually token-heavy context, network latency, or suboptimal configuration. These guides help you identify and fix the bottleneck.

- [Fix Claude Code Slow Response](/claude-code-slow-fix/) -- general slow response diagnosis
- [Fix: Claude Code Slow Response Latency](/claude-code-slow-response-fix/) -- latency-specific troubleshooting
- [Fix Slow Response Latency](/claude-code-slow-response-how-to-fix-latency-issues/) -- network and API latency fixes
- [Speed Up Claude Code on Large Repos](/claude-code-slow-on-large-repos-fix-2026/) -- large codebase optimization
- [Make Claude Code Consider Performance](/claude-code-ignores-performance-fix-2026/) -- forcing performance-aware code generation
- [Claude Code MCP tools loading slowly](/claude-code-mcp-tools-loading-slowly-token-cost/) -- MCP tool initialization delays
- [Find Performance Bottlenecks](/claude-code-performance-bottleneck-finding/) -- systematic performance profiling
- [Claude Skills Slow Performance Speed-Up Guide](/claude-skills-slow-performance-speed-up-guide/) -- skill-specific performance tuning

---

## Installation Problems

Installation failures prevent Claude Code from running at all. These guides cover every platform and package manager.

- [Install Claude Code](/claude-code-install-guide/) -- canonical installation guide
- [Claude Code Setup on Mac](/claude-code-setup-on-mac-step-by-step/) -- macOS-specific installation steps
- [Fix 'command not found' After Install](/claude-code-command-not-found-after-install-fix/) -- PATH configuration issues
- [Fix Claude Command Not Found After Install](/claude-code-command-not-found-after-install-troubleshooting/) -- extended PATH troubleshooting
- [claude: command not found After Install](/claude-code-binary-not-found-after-install-fix-2026/) -- binary location issues
- [Fix zsh: command not found: claude](/zsh-command-not-found-claude-fix/) -- zsh-specific shell configuration
- [PATH Not Updated After Install](/claude-code-path-not-updated-after-install-fix-2026/) -- manual PATH repair
- [Fix Claude Code Install Killed on Linux](/claude-code-install-killed-low-memory-linux-fix/) -- low-memory Linux installation
- [Apple Silicon Rosetta Crash Error](/claude-code-apple-silicon-rosetta-crash-fix-2026/) -- M1/M2/M3 chip compatibility
- [Claude Code Bun Install Setup Guide](/claude-code-bun-install/) -- Bun runtime installation

---

## CLAUDE.md Not Working

The most frustrating category: you wrote a CLAUDE.md but Claude Code ignores it, reads it partially, or applies conflicting rules.

- [Claude Code Ignoring CLAUDE.md Entirely](/claude-ignoring-claude-md-entirely/) -- Claude not reading your config at all
- [Fix How To Fix Claude Code Ignoring My CLAUDE.md](/how-to-fix-claude-code-ignoring-my-claude-md-file/) -- systematic debugging checklist
- [CLAUDE.md Not Loading in Claude Code](/claude-md-not-loading-fix/) -- file location and naming issues
- [Fix Claude Md Not Being Read By Claude Code](/claude-md-not-being-read-by-claude-code-fix/) -- parsing and detection problems
- [CLAUDE.md Being Partially Read](/claude-md-being-partially-read/) -- truncation and token limit issues
- [Fix Claude Md Changes Not Taking Effect](/claude-md-changes-not-taking-effect-fix-guide/) -- stale cache and reload issues
- [Fix Conflicting CLAUDE.md Instructions](/claude-md-conflicting-instructions-fix/) -- contradictory rule resolution
- [Claude Code CLAUDE.md Not Found Fix](/claude-code-claude-md-not-found-parent-directories-fix/) -- parent directory search behavior

---

## Unexpected Behavior

Claude Code works but produces wrong output, modifies files you did not mention, or ignores your explicit instructions.

- [Why Is Claude Code Changing Files I Did Not Mention?](/why-is-claude-code-changing-files-i-did-not-mention/) -- unwanted file modifications
- [Fix Claude Code Touching Unrelated Files](/karpathy-surgical-changes-debugging-2026/) -- surgical change debugging
- [Fix Claude Code Changing Indentation](/claude-code-keeps-changing-my-indentation-style/) -- style drift prevention
- [Fix Claude Code Forgetting Variable Names](/claude-code-keeps-losing-track-of-my-variable-names/) -- context window loss
- [Claude Code Keeps Suggesting The Same Broken Solution](/claude-code-keeps-suggesting-the-same-broken-solution/) -- escaping solution loops
- [Fix Claude Code Suggesting Wrong Framework](/claude-code-keeps-suggesting-wrong-framework-2026/) -- framework confusion
- [Make Claude Code Explain Its Changes](/claude-code-doesnt-explain-changes-fix-2026/) -- forcing change explanations
- [Fix Claude Code Poor Variable Naming](/claude-code-poor-variable-names-fix-2026/) -- improving generated code quality
- [Claude Code Breaks Existing Tests After Changes](/claude-code-breaks-existing-tests-after-changes-fix/) -- preventing test regressions

---

## IDE Integration Issues

Problems specific to VS Code, JetBrains, Neovim, and other editors.

- [Fix Claude Code Not Working in VS Code](/claude-code-not-working-in-vscode/) -- VS Code integration troubleshooting
- [Fix Claude Code Not Working VSCode](/claude-code-not-working-vscode/) -- alternative VS Code fixes
- [Fix Claude Code Crashing in VS Code](/claude-code-crashing-vscode/) -- VS Code crash recovery
- [VS Code Extension Host Crash Fix](/claude-code-extension-host-crash-fix-2026/) -- extension host process failures
- [Claude Code + WebStorm JetBrains Setup](/claude-code-webstorm-jetbrains-setup-2026/) -- JetBrains IDE integration
- [How to Set Up Claude Code in Ghostty](/claude-code-ghostty-terminal-setup-2026/) -- Ghostty terminal configuration

---

## Authentication and Login Issues

Problems connecting Claude Code to your Anthropic account or API.

- [Fix Claude Code OAuth Login Paste Not Working](/claude-code-oauth-login-paste-not-working/) -- browser-to-terminal auth flow
- [Fix: Claude Code Auth Fails on Headless Linux](/claude-code-headless-linux-auth/) -- headless server authentication
- [Fix: Claude Isn't Working Right Now](/claude-not-working-right-now-fix/) -- service availability troubleshooting
- [Claude Code Not Working After Update](/claude-code-not-working-after-update-how-to-fix/) -- post-update breakage recovery
- [Fix Claude Code Not Responding Terminal Hangs](/claude-code-not-responding-terminal-hangs-fix/) -- terminal freeze during authentication

---

## Skill and Tool Issues

Problems with Claude Code skills, custom commands, and tool integrations.

- [Fix Claude Skill Not Triggering Automatically](/claude-skill-not-triggering-automatically-troubleshoot/) -- skill activation failures
- [Claude Code Crashes When Loading Skill](/claude-code-crashes-when-loading-skill-debug-steps/) -- skill load crashes
- [Fix Claude Code Output Formatting Broken](/claude-code-skill-output-formatting-broken-fix/) -- output rendering issues
- [Fix Bash Command Not Found in Skills](/claude-code-bash-command-not-found-in-skill/) -- skill environment problems
- [Claude Code Skill Permission Denied](/claude-code-skill-permission-denied-error-fix-2026/) -- skill execution permissions
- [Fix Claude Tool Use Not Working](/claude-tool-use-not-working/) -- tool invocation failures
- [Fix Claude Extended Thinking Not Working](/claude-extended-thinking-not-working/) -- extended thinking activation issues
- [Fix Claude Streaming Not Working](/claude-streaming-not-working/) -- streaming output failures

---

## Docker and Container Issues

Troubleshooting Claude Code inside Docker containers, dev containers, and WSL.

- [Fix Docker Networking with Claude Code](/claude-code-docker-networking-troubleshooting-guide/) -- container networking
- [How to Run Claude Code in Docker](/claude-code-docker-container-setup-2026/) -- Docker setup guide
- [How to Use Claude Code with WSL2](/claude-code-wsl2-windows-setup-2026/) -- Windows Subsystem for Linux
- [How to Use Dev Containers with Claude Code](/claude-code-dev-containers-devcontainer-json-setup-guide/) -- devcontainer.json configuration
- [Fix Claude Code Python Venv Not Detected](/claude-code-not-detecting-my-virtual-environment-python-fix/) -- Python virtual environment detection

---

## Interactive Diagnostic Tool

For issues not covered above, use the [Claude Code Diagnostic Tool](/diagnose/). It walks you through a decision tree that identifies your problem category, narrows the root cause, and links to the specific fix.

---

## Frequently Asked Questions

### Why is Claude Code so slow?
Three common causes: oversized context (too many files loaded), network latency to the Anthropic API, and MCP server initialization overhead. Start by checking your CLAUDE.md size and excluding unnecessary directories. See [Fix Claude Code Slow Response](/claude-code-slow-fix/).

### Claude Code says 'command not found' after I installed it. What do I do?
Your shell PATH does not include the Claude Code binary location. Run {% raw %}`which claude`{% endraw %} to check, and add the npm global bin directory to your PATH. The fix differs between bash, zsh, and fish shells. See [Fix 'command not found'](/claude-code-command-not-found-after-install-fix/).

### Why does Claude Code ignore my CLAUDE.md file?
Four common reasons: the file is in the wrong directory (must be in the project root or a parent directory), the file has a casing mismatch (must be CLAUDE.md, not claude.md), the file exceeds the token limit (split it), or a cached version is being used. See [CLAUDE.md Not Loading](/claude-md-not-loading-fix/).

### Claude Code keeps modifying files I did not ask about. How do I stop it?
Add explicit scoping rules to your CLAUDE.md: "Only modify files I explicitly mention" and "Never touch files in /config, /migrations, or /generated." The [Surgical Changes](/karpathy-surgical-changes-debugging-2026/) guide covers this in depth.

### How do I fix Claude Code in VS Code?
First, check that the extension is updated. Then verify your API key configuration. If Claude Code crashes the extension host, disable other extensions one-by-one to find conflicts. See [Fix Claude Code Not Working in VS Code](/claude-code-not-working-in-vscode/).

### Can I use Claude Code on a headless server?
Yes. Claude Code supports headless authentication via API key environment variables. Set {% raw %}`ANTHROPIC_API_KEY`{% endraw %} in your environment and use {% raw %}`--dangerously-skip-permissions`{% endraw %} for non-interactive mode. See [Headless Linux Auth](/claude-code-headless-linux-auth/).

### Why does Claude Code keep suggesting the same broken solution?
Claude Code lacks persistent memory of failed attempts within a session context. Explicitly tell it "That approach failed because [reason]. Try a different approach." Adding failure context to your prompt breaks the loop. See [Keeps Suggesting Same Broken Solution](/claude-code-keeps-suggesting-the-same-broken-solution/).

### How do I troubleshoot MCP server connections?
Check the server process status, verify transport configuration (stdio vs HTTP), test the connection independently, and review timeout settings. The [MCP Server Incident Response Guide](/claude-code-mcp-server-incident-response-guide/) provides a complete diagnostic workflow.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Why is Claude Code so slow?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Three common causes: oversized context (too many files loaded), network latency to the Anthropic API, and MCP server initialization overhead. Start by checking your CLAUDE.md size and excluding unnecessary directories."
      }
    },
    {
      "@type": "Question",
      "name": "Claude Code says 'command not found' after I installed it. What do I do?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Your shell PATH does not include the Claude Code binary location. Run 'which claude' to check, and add the npm global bin directory to your PATH. The fix differs between bash, zsh, and fish shells."
      }
    },
    {
      "@type": "Question",
      "name": "Why does Claude Code ignore my CLAUDE.md file?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Four common reasons: the file is in the wrong directory (must be in the project root or a parent directory), the file has a casing mismatch (must be CLAUDE.md, not claude.md), the file exceeds the token limit (split it), or a cached version is being used."
      }
    },
    {
      "@type": "Question",
      "name": "Claude Code keeps modifying files I did not ask about. How do I stop it?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Add explicit scoping rules to your CLAUDE.md: 'Only modify files I explicitly mention' and 'Never touch files in /config, /migrations, or /generated.'"
      }
    },
    {
      "@type": "Question",
      "name": "How do I fix Claude Code in VS Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First, check that the extension is updated. Then verify your API key configuration. If Claude Code crashes the extension host, disable other extensions one-by-one to find conflicts."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use Claude Code on a headless server?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Claude Code supports headless authentication via API key environment variables. Set ANTHROPIC_API_KEY in your environment and use --dangerously-skip-permissions for non-interactive mode."
      }
    },
    {
      "@type": "Question",
      "name": "Why does Claude Code keep suggesting the same broken solution?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code lacks persistent memory of failed attempts within a session context. Explicitly tell it 'That approach failed because [reason]. Try a different approach.' Adding failure context to your prompt breaks the loop."
      }
    },
    {
      "@type": "Question",
      "name": "How do I troubleshoot MCP server connections?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Check the server process status, verify transport configuration (stdio vs HTTP), test the connection independently, and review timeout settings."
      }
    }
  ]
}
</script>

## Explore More Guides

- [Error messages and how to fix them](/error-handling/)
- [Configuration and settings reference](/configuration/)
- [Prevent issues with best practices](/best-practices/)
- [Installation and setup guide](/getting-started/)
- [Advanced patterns for complex issues](/advanced-usage/)
- [Run the diagnostic tool on your issue](/diagnose/)


<section class="related-hubs" style="margin-top: 3rem; padding: 2rem; background: #f8f9fa; border-radius: 12px; border: 1px solid #e9ecef;">
  <h2 style="margin-top: 0; font-size: 1.5rem;">Related Guides</h2>
  <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1rem;">
    <a href="/best-practices/" style="display: block; padding: 1.25rem; background: white; border-radius: 8px; border: 1px solid #dee2e6; text-decoration: none; color: inherit; transition: box-shadow 0.2s;">
      <strong style="color: #5436DA; font-size: 1.05rem;">Best Practices</strong>
      <p style="margin: 0.5rem 0 0; color: #666; font-size: 0.85rem;">Proven patterns for effective Claude Code usage</p>
    </a>
    <a href="/error-handling/" style="display: block; padding: 1.25rem; background: white; border-radius: 8px; border: 1px solid #dee2e6; text-decoration: none; color: inherit; transition: box-shadow 0.2s;">
      <strong style="color: #5436DA; font-size: 1.05rem;">Error Handling</strong>
      <p style="margin: 0.5rem 0 0; color: #666; font-size: 0.85rem;">Fix common Claude Code errors and exceptions</p>
    </a>
    <a href="/getting-started/" style="display: block; padding: 1.25rem; background: white; border-radius: 8px; border: 1px solid #dee2e6; text-decoration: none; color: inherit; transition: box-shadow 0.2s;">
      <strong style="color: #5436DA; font-size: 1.05rem;">Getting Started</strong>
      <p style="margin: 0.5rem 0 0; color: #666; font-size: 0.85rem;">Quick start guide for new Claude Code users</p>
    </a>
    <a href="/configuration/" style="display: block; padding: 1.25rem; background: white; border-radius: 8px; border: 1px solid #dee2e6; text-decoration: none; color: inherit; transition: box-shadow 0.2s;">
      <strong style="color: #5436DA; font-size: 1.05rem;">Configuration</strong>
      <p style="margin: 0.5rem 0 0; color: #666; font-size: 0.85rem;">Configure Claude Code, CLAUDE.md, and MCP servers</p>
    </a>
    <a href="/advanced-usage/" style="display: block; padding: 1.25rem; background: white; border-radius: 8px; border: 1px solid #dee2e6; text-decoration: none; color: inherit; transition: box-shadow 0.2s;">
      <strong style="color: #5436DA; font-size: 1.05rem;">Advanced Usage</strong>
      <p style="margin: 0.5rem 0 0; color: #666; font-size: 0.85rem;">Power user techniques and advanced workflows</p>
    </a>
  </div>
</section>

<div style="margin-top: 1.5rem; padding: 1.25rem; background: linear-gradient(135deg, #5436DA15, #7c5ce015); border-radius: 12px; border: 1px solid #5436DA30;">
  <strong style="color: #5436DA;">Try our Diagnostic Tool →</strong>
  <a href="/diagnose/" style="color: #333; text-decoration: none; margin-left: 0.5rem;">Run the diagnostic tool on your error</a>
</div>

---

## Beyond Troubleshooting

This page helps you fix what is broken. The [Claude Code Mastery Playbook](/mastery/) ($99) helps you build systems that rarely break in the first place, with 200 production-tested practices covering prevention, monitoring, and recovery.
