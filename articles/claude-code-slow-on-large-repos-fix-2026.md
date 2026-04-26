---
layout: default
title: "Speed Up Claude Code on Large (2026)"
description: "Speed up Claude Code on large repos by configuring .claudeignore, scoping sessions to subdirectories, and optimizing file discovery."
permalink: /claude-code-slow-on-large-repos-fix-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Speed Up Claude Code on Large Repositories (2026)

Your monorepo has 10,000+ files. Claude Code takes 30 seconds to find the right file and burns tokens scanning directories it does not need. Simple tasks that should take 2 minutes consume 10.

## The Problem

On large repositories, Claude Code:
- Spends excessive tokens on file discovery (glob and grep operations)
- Reads irrelevant files (generated code, vendor directories, build output)
- Loses track of which files it has already examined
- Makes redundant tool calls searching the same directories

## Root Cause

Claude Code explores your repository through tool calls — each `glob`, `grep`, and `read` costs tokens and time. Without guidance, it searches broadly. A 10K-file repo means thousands of potential matches for any query, and the model must sift through them to find relevant results.

Generated files, `node_modules`, build output, and test fixtures add noise without adding signal.

## The Fix

Use the directory scoping techniques from [claude-howto](https://github.com/luongnv89/claude-howto) (28K+ stars), which provides visual guides for configuring Claude Code's file access patterns.

### Step 1: Create .claudeignore

Create `.claudeignore` in your project root (same syntax as `.gitignore`):

```
# Build output
dist/
build/
.next/
out/

# Dependencies
node_modules/
vendor/

# Generated files
*.generated.ts
*.min.js
*.min.css
coverage/

# Large binary assets
*.png
*.jpg
*.mp4
*.woff2

# IDE and OS
.idea/
.vscode/
.DS_Store

# Test fixtures (large)
__fixtures__/
__snapshots__/
```

### Step 2: Add Directory Map to CLAUDE.md

```markdown
## Directory Map — READ THIS FIRST
When looking for code, search in this order:
1. src/features/[feature-name]/ — feature-specific code
2. src/shared/ — shared utilities and components
3. src/lib/ — core libraries and configs
4. packages/[package-name]/src/ — monorepo package source

NEVER search in:
- node_modules/, dist/, build/, coverage/
- Any directory starting with . (except .github/)
```

### Step 3: Scope Sessions to Subdirectories

For monorepos, start Claude Code in the specific package:

```bash
cd packages/api && claude
```

Or add scope hints to your CLAUDE.md:

```markdown
## Monorepo Packages
- packages/api — Backend API (Node.js, Fastify)
- packages/web — Frontend (React, Vite)
- packages/shared — Shared types and utilities
- packages/mobile — React Native app

When working on API features, focus on packages/api/ and packages/shared/.
Do not read packages/web/ or packages/mobile/ unless explicitly needed.
```

## CLAUDE.md Code to Add

```markdown
## Performance Rules
- Search specific directories, not the entire repo
- When looking for a function, check the relevant feature directory first
- Limit grep results to 20 matches — if more exist, narrow the pattern
- Read files only when you need their content, not to explore
```

## Verification

1. Track token usage with [ccusage](https://github.com/ryoppippi/ccusage): `npx ccusage`
2. Compare before/after: a scoped session should use 30-50% fewer tokens
3. Time a simple task (add a function) — should complete in under 3 minutes

## Prevention

Maintain your `.claudeignore` as your project grows. The [claude-code-docs](https://github.com/ericbuess/claude-code-docs) repo includes hooks that detect when your ignore file is stale.

For more optimization techniques, see [The Claude Code Playbook](/playbook/). Learn about token cost tracking in our [productivity hacks roundup](/best-claude-code-productivity-hacks-2026/). For context management strategies, read the [context window guide](/claude-code-context-window-management-2026/).

## See Also

- [Claude Code ENOMEM Out of Memory Large Repos — Fix (2026)](/claude-code-enomem-out-of-memory-large-repos-fix/)


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.




**Estimate usage →** Calculate your token consumption with our [Token Estimator](/token-estimator/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [AI Speed Reader Chrome Extension Guide](/ai-speed-reader-chrome-extension/)
- [Downgrade Chrome Speed](/downgrade-chrome-speed/)
- [Speed Up Chrome: Performance Tips](/chrome-speed-up-tips-2026/)
- [Page Speed Insights Chrome Extension](/chrome-extension-page-speed-insights/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
