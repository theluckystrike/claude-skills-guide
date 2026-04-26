---
title: "Claude Code Error Handling"
permalink: /error-handling/
description: "Complete Claude Code error reference — API errors, timeouts, SSL failures, permission issues, and how to fix each one systematically."
layout: default
date: 2026-04-20
---

# Claude Code Error Handling

Every Claude Code error has a root cause and a fix. This page organizes every documented error by type, links to step-by-step resolution guides, and teaches you a systematic diagnostic approach so you can fix new errors independently.

Bookmark this page. When Claude Code throws an error, start here.

<div style="background:linear-gradient(135deg,rgba(110,231,183,0.08),rgba(96,165,250,0.05));border:1px solid rgba(110,231,183,0.2);border-radius:8px;padding:16px 20px;margin:20px 0;">
<strong style="color:#6ee7b7;">Interactive Tool:</strong> Try our <a href="/diagnose/" style="color:#60a5fa;">Error Diagnostic Tool</a> — paste any error message, get an instant fix.
</div>

---

## API Errors (HTTP Status Codes)

API errors are the most common category. Each HTTP status code indicates a specific problem with your request, authentication, or the Anthropic service.

### 400 -- Bad Request
The API rejected your request due to malformed input, invalid parameters, or schema violations.
- [Fix: Claude API Error 400 InvalidRequestError](/claude-api-error-400-invalidrequesterror-explained/) -- parameter validation failures and request formatting

### 401 -- Authentication Error
Your API key is missing, expired, or malformed.
- [Fix: Claude API Error 401 AuthenticationError](/claude-api-error-401-authenticationerror-explained/) -- key rotation and environment variable troubleshooting
- [Fix Claude API Error 401](/claude-api-error-401-fix/) -- quick authentication repair steps

### 413 -- Request Too Large
Your prompt or context exceeds the model's input token limit.
- [Fix: Claude API Error 413 RequestTooLarge](/claude-api-error-413-requesttoolarge-explained/) -- context window management and chunking strategies

### 429 -- Rate Limit Exceeded
You have exceeded your API rate limit or token budget.
- [Fix: Claude API Error 429 Rate Limit](/anthropic-api-error-429-rate-limit/) -- rate limiting strategies and backoff patterns
- [Claude API Error 429 rate_limit_error](/claude-api-error-429-ratelimiterror-explained/) -- detailed rate limit error analysis
- [Fix Claude AI Rate Exceeded Error](/claude-ai-rate-exceeded-error-fix/) -- practical rate management

### 500 -- Internal Server Error
The Anthropic API encountered an internal failure.
- [Fix: Anthropic API 500 Error](/anthropic-sdk-strict-true-500-error/) -- workarounds and retry strategies
- [Fix Claude API Error 500](/claude-api-error-500-fix/) -- server-side error recovery
- [Fix Claude API Error 500 ApiError](/claude-api-error-500-apierror-explained/) -- understanding 500 error variants

### 529 -- Overloaded
The API is temporarily overloaded and cannot process your request.
- [Claude API 529 Overloaded Error](/claude-api-529-overloaded-error-handling-fix/) -- queuing and retry patterns during high load

---

## SDK and Runtime Errors

These errors occur within the Anthropic SDK itself, usually during streaming, tool use, or structured output processing.

- [Fix Anthropic SDK IndexError When Streaming](/anthropic-sdk-indexerror-streaming-fix/) -- index out of range during stream processing
- [Fix Anthropic API Streaming Interrupted](/anthropic-api-streaming-interrupted-fix/) -- connection drops mid-stream
- [Anthropic SDK Streaming Connection Dropped](/anthropic-sdk-streaming-connection-dropped-fix/) -- network-level stream failures
- [Fix Stream Idle Timeout in Claude Code](/anthropic-sdk-streaming-hang-timeout/) -- streams that hang without error
- [Fix: SDK TypeError: terminated](/anthropic-sdk-typeerror-terminated/) -- abrupt SDK termination
- [Anthropic SDK Python Async Context Manager Error](/anthropic-sdk-python-async-context-manager-error-fix/) -- Python async/await SDK issues
- [Anthropic SDK TypeScript Tool Results Type Mismatch](/anthropic-sdk-typescript-type-mismatch-tool-results-fix/) -- TypeScript type errors in tool results
- [Fix: Anthropic SDK toolRunner Drops Headers](/anthropic-sdk-toolrunner-drops-headers/) -- header propagation failures
- [Fix: Anthropic SDK Grammar Too Large](/anthropic-sdk-structured-output-grammar-too-large/) -- structured output schema size limits
- [Fix: Structured Output + Thinking + Tool Use Bug](/anthropic-sdk-structured-output-thinking-tool-use-bug/) -- interaction conflicts between features

---

## JSON Parse Errors

JSON parsing failures occur when Claude Code receives malformed responses or when configuration files contain syntax errors.

- [Fix Unexpected Token in JSON](/claude-code-error-unexpected-token-in-json-response-fix/) -- malformed API response handling
- [Fixing Claude Code's 'Unexpected End of Input'](/claude-code-unexpected-end-of-input-json-error/) -- truncated JSON responses
- [JSON Parse Error on Malformed Response](/claude-code-json-parse-error-malformed-response-fix-2026/) -- response corruption recovery
- [Response JSON Parse Failure](/claude-code-response-json-parse-failure-fix-2026/) -- systematic JSON debugging
- [Config File JSON Parse Error](/claude-code-config-json-corrupted-parse-error-fix-2026/) -- corrupted configuration files
- [Claude Code Config YAML Parse Error](/claude-code-config-yaml-parse-error-fix/) -- YAML syntax issues in config files

---

## Permission and Access Errors

Permission errors block Claude Code from reading, writing, or executing in your project.

- [Claude Code EACCES Permission Denied (npm)](/claude-code-eacces-permission-denied-npm-global-install-fix/) -- npm global install permissions
- [Fix Claude Code NPM Install EACCES](/claude-code-npm-install-eacces-permission-fix/) -- alternative npm permission fixes
- [npm Global Install Permission Denied](/claude-code-npm-global-install-permission-denied-fix-2026/) -- system-level permission repair
- [Claude Code Permission Denied Shell Commands](/claude-code-permission-denied-shell-commands-fix/) -- shell execution restrictions
- [Claude Code Permission Denied Sandbox](/claude-code-permission-denied-sandbox-mode-fix-2026/) -- sandbox mode conflicts
- [EACCES Permission Denied Config Dir](/claude-code-config-dir-permission-denied-fix-2026/) -- configuration directory access
- [XDG Config Directory Permissions](/claude-code-xdg-config-directory-permissions-fix-2026/) -- Linux XDG path permissions
- [Claude Code Docker Permission Denied](/claude-code-docker-permission-denied-bind-mount-error/) -- Docker bind mount access issues

---

## MCP Server Errors

MCP (Model Context Protocol) server errors occur during tool integration and external service communication.

- [Fix: MCP Server Disconnected Error](/claude-code-mcp-server-disconnected/) -- server connection drops
- [Fix Claude Code MCP Server Connection Closed](/claude-code-mcp-server-connection-closed-fix/) -- premature connection termination
- [Claude Code MCP Server Connection Refused](/claude-code-mcp-server-connection-refused-fix/) -- server unreachable
- [MCP Server stdio Timeout 30000ms](/claude-code-mcp-server-stdio-timeout-fix-2026/) -- stdio transport timeouts
- [Fix Claude Code MCP Timeout Settings](/claude-code-mcp-timeout-settings-configuration-guide/) -- configuring timeout values
- [Fix: Anthropic SDK MCP Tools Get Empty Arguments](/anthropic-sdk-mcp-empty-arguments-bug/) -- tool argument passing failures
- [Fix MCP Server Issues in Claude Code](/claude-code-mcp-server-incident-response-guide/) -- incident response for MCP failures

---

## Process and System Errors

These errors relate to Claude Code's runtime process, system resources, or integration with your development environment.

- [Claude Code EPIPE Broken Pipe Error](/claude-code-epipe-broken-pipe-long-operations-fix/) -- pipe failures during long operations
- [Fix Claude Code Large File Crashes](/claude-code-crashes-on-large-files-how-to-fix/) -- memory exhaustion on large files
- [Parallel Tool Calls Memory Exhaustion](/claude-code-parallel-tool-calls-memory-exhaustion-fix-2026/) -- out-of-memory during parallel execution
- [Fix Claude Code Crashing in VS Code](/claude-code-crashing-vscode/) -- VS Code extension host crashes
- [VS Code Extension Host Crash Fix](/claude-code-extension-host-crash-fix-2026/) -- extension host process recovery
- [Fix Claude Code Bun Crash](/claude-code-bun-crash/) -- Bun runtime crashes
- [Fix Claude Code 'Bun Has Crashed' Error](/claude-code-bun-has-crashed/) -- Bun crash recovery steps

---

## Diagnostic Approach

When you encounter an error not listed above, follow this systematic process:

1. **Read the error message carefully.** Claude Code errors include specific codes and descriptions. The error code alone often points to the fix.
2. **Check your configuration.** Most errors trace back to CLAUDE.md syntax, settings.json misconfigurations, or environment variable issues.
3. **Isolate the component.** Determine whether the error originates from the CLI, the API, an MCP server, or your project code.
4. **Use the diagnostic tool.** The [Claude Code Diagnostic Tool](/diagnose/) walks you through error identification and resolution interactively.
5. **Check API status.** For 500 and 529 errors, verify the Anthropic API status page before debugging your own configuration.

---

## Frequently Asked Questions

### What is the most common Claude Code error?
Error 429 (Rate Limit Exceeded) is the most frequently encountered error, especially for teams running multiple agents in parallel. The fix involves implementing exponential backoff, distributing requests across time windows, and optionally upgrading your API tier.

### How do I fix Claude Code permission denied errors?
Permission denied errors have three common causes: npm global install permissions (fix with nvm or npm config), sandbox mode restrictions (check your permission mode setting), and file system permissions in Docker containers (fix bind mount ownership). Start with the [Permission Denied Shell Commands](/claude-code-permission-denied-shell-commands-fix/) guide.

### Why does Claude Code crash on large files?
Claude Code loads file contents into the context window. Files exceeding the context limit cause crashes or truncation. Split large files, use .claudeignore to exclude generated files, and set max file size limits in your CLAUDE.md. See [Fix Claude Code Large File Crashes](/claude-code-crashes-on-large-files-how-to-fix/).

### How do I debug MCP server connection issues?
First, verify the MCP server process is running. Then check transport configuration (stdio vs HTTP). Next, test the connection independently using curl or the MCP inspector. Finally, review timeout settings. The [MCP Server Incident Response Guide](/claude-code-mcp-server-incident-response-guide/) covers all steps.

### What causes JSON parse errors in Claude Code?
Three sources: truncated API responses (network interruption), malformed configuration files (syntax errors in settings.json), and response schema mismatches (SDK version incompatibility). The fix depends on the source. See [Fix Unexpected Token in JSON](/claude-code-error-unexpected-token-in-json-response-fix/).

### How do I handle Claude API 500 errors?
API 500 errors are server-side issues at Anthropic. Implement retry logic with exponential backoff (initial delay 1s, max 3 retries). If errors persist beyond 5 minutes, check the Anthropic status page. Your code is not the problem. See [Fix Claude API Error 500](/claude-api-error-500-fix/).

### Can I prevent errors before they happen?
Yes. Add error-prevention rules to your CLAUDE.md (file size limits, forbidden patterns, required validations). Use pre-commit hooks to validate Claude's output before it commits. Enable the diagnostic tool for real-time error detection. See [CLAUDE.md for Error Handling](/claude-md-error-handling-patterns/).

### Where do I report Claude Code bugs?
Report bugs to the Anthropic Claude Code GitHub repository. Include your Claude Code version, the full error message, your operating system, and minimal reproduction steps. The [Bug Reporting Best Practices](/claude-code-bug-reporting-best-practices/) guide shows how to write effective bug reports.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the most common Claude Code error?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Error 429 (Rate Limit Exceeded) is the most frequently encountered error, especially for teams running multiple agents in parallel. The fix involves implementing exponential backoff, distributing requests across time windows, and optionally upgrading your API tier."
      }
    },
    {
      "@type": "Question",
      "name": "How do I fix Claude Code permission denied errors?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Permission denied errors have three common causes: npm global install permissions (fix with nvm or npm config), sandbox mode restrictions (check your permission mode setting), and file system permissions in Docker containers (fix bind mount ownership)."
      }
    },
    {
      "@type": "Question",
      "name": "Why does Claude Code crash on large files?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code loads file contents into the context window. Files exceeding the context limit cause crashes or truncation. Split large files, use .claudeignore to exclude generated files, and set max file size limits in your CLAUDE.md."
      }
    },
    {
      "@type": "Question",
      "name": "How do I debug MCP server connection issues?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First, verify the MCP server process is running. Then check transport configuration (stdio vs HTTP). Next, test the connection independently using curl or the MCP inspector. Finally, review timeout settings."
      }
    },
    {
      "@type": "Question",
      "name": "What causes JSON parse errors in Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Three sources: truncated API responses (network interruption), malformed configuration files (syntax errors in settings.json), and response schema mismatches (SDK version incompatibility). The fix depends on the source."
      }
    },
    {
      "@type": "Question",
      "name": "How do I handle Claude API 500 errors?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "API 500 errors are server-side issues at Anthropic. Implement retry logic with exponential backoff (initial delay 1s, max 3 retries). If errors persist beyond 5 minutes, check the Anthropic status page."
      }
    },
    {
      "@type": "Question",
      "name": "Can I prevent errors before they happen?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Add error-prevention rules to your CLAUDE.md (file size limits, forbidden patterns, required validations). Use pre-commit hooks to validate Claude's output before it commits. Enable the diagnostic tool for real-time error detection."
      }
    },
    {
      "@type": "Question",
      "name": "Where do I report Claude Code bugs?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Report bugs to the Anthropic Claude Code GitHub repository. Include your Claude Code version, the full error message, your operating system, and minimal reproduction steps."
      }
    }
  ]
}
</script>

## Explore More Guides

- [Non-error issues and fixes](/troubleshooting/)
- [Prevent errors with best practices](/best-practices/)
- [Configuration-related error prevention](/configuration/)
- [Beginner guide to Claude Code](/getting-started/)
- [Advanced debugging and monitoring](/advanced-usage/)
- [Diagnose your error interactively](/diagnose/)


<section class="related-hubs" style="margin-top: 3rem; padding: 2rem; background: #f8f9fa; border-radius: 12px; border: 1px solid #e9ecef;">
  <h2 style="margin-top: 0; font-size: 1.5rem;">Related Guides</h2>
  <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1rem;">
    <a href="/best-practices/" style="display: block; padding: 1.25rem; background: white; border-radius: 8px; border: 1px solid #dee2e6; text-decoration: none; color: inherit; transition: box-shadow 0.2s;">
      <strong style="color: #5436DA; font-size: 1.05rem;">Best Practices</strong>
      <p style="margin: 0.5rem 0 0; color: #666; font-size: 0.85rem;">Proven patterns for effective Claude Code usage</p>
    </a>
    <a href="/troubleshooting/" style="display: block; padding: 1.25rem; background: white; border-radius: 8px; border: 1px solid #dee2e6; text-decoration: none; color: inherit; transition: box-shadow 0.2s;">
      <strong style="color: #5436DA; font-size: 1.05rem;">Troubleshooting</strong>
      <p style="margin: 0.5rem 0 0; color: #666; font-size: 0.85rem;">Step-by-step troubleshooting for Claude Code issues</p>
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
  <a href="/diagnose/" style="color: #333; text-decoration: none; margin-left: 0.5rem;">Diagnose your Claude Code error instantly</a>
</div>

---

## Stop Debugging, Start Building

This error reference covers the documented error types. For proactive error prevention patterns, debugging workflows, and production monitoring configurations, the [Claude Code Mastery Playbook](/mastery/) ($99) includes 200 production-tested practices that help you avoid errors entirely.
