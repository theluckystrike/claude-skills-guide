---
layout: default
title: "VS Code Extension Consuming Excessive (2026)"
permalink: /claude-code-vscode-extension-excessive-cpu-fix-2026/
date: 2026-04-20
description: "Fix VS Code Claude Code extension consuming excessive CPU. Disable file watchers on large directories and limit workspace indexing to reduce CPU load."
last_tested: "2026-04-22"
---

## The Error

```
[Extension Host] High CPU usage detected: claude-code extension (92% CPU, 1.4GB RAM)
  File watcher processing 48,000+ files in workspace
  VS Code becoming unresponsive — extension host consuming all available cores
```

This appears in VS Code's process explorer (Help > Open Process Explorer) showing the Claude Code extension using abnormally high CPU.

## The Fix

```json
// .vscode/settings.json
{
  "files.watcherExclude": {
    "**/node_modules/**": true,
    "**/dist/**": true,
    "**/.git/objects/**": true,
    "**/build/**": true
  }
}
```

1. Add large directories to VS Code's watcher exclude list.
2. Create a `.claudeignore` file with the same exclusions.
3. Reload VS Code window: `Cmd+Shift+P > Developer: Reload Window`.

## Why This Happens

The Claude Code VS Code extension indexes your workspace to provide context-aware suggestions. In large monorepos with many files (node_modules alone can contain 50,000+ files), the file watcher and indexer consume significant CPU. The extension re-indexes on every file change, and if the workspace includes generated files or build outputs that change frequently, the indexer enters a loop of continuous reprocessing.

## If That Doesn't Work

Disable the extension's file watcher entirely:

```json
// .vscode/settings.json
{
  "claude-code.fileWatcher.enabled": false
}
```

Reduce the workspace scope to just the source directory:

```bash
code src/
# Instead of: code .
```

Check VS Code's process explorer and kill runaway processes:

```
Help > Open Process Explorer
# Right-click on high-CPU extension host > Kill Process
```

## Prevention

```markdown
# CLAUDE.md rule
Always maintain a .claudeignore that excludes node_modules, dist, build, .git/objects, and any directory with more than 1,000 generated files. Open only the relevant subdirectory in VS Code for large monorepos.
```

## See Also

- [VS Code Extension Connection Timeout Fix](/claude-code-vscode-extension-connection-timeout-fix-2026/)
- [Claude Code VS Code Extension Fails to Activate — Fix (2026)](/claude-code-vscode-extension-fails-to-activate-fix/)
- [Claude Code VS Code Connection Lost — Fix (2026)](/claude-code-vscode-connection-lost-fix-2026/)


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Related Guides

- [Stop Claude Code Writing Excessive Code](/claude-code-writes-too-much-code-fix-2026/)
- [Fix Claude Code MCP Tools Excessive](/claude-code-mcp-tools-excessive-context-fix/)
- [Virtual Background Chrome Extension](/virtual-background-chrome-extension/)
- [Spending Tracker Chrome Extension Guide](/chrome-extension-spending-tracker-chrome/)

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
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json."
      }
    }
  ]
}
</script>
