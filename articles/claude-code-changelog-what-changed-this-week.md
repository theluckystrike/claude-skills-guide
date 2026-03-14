---

layout: default
title: "Claude Code Changelog: What Changed This Week"
description: "A weekly roundup of Claude Code updates, new skills, and feature changes. Stay current with the latest Claude Code enhancements and skill additions."
date: 2026-03-14
categories: [changelog, updates]
tags: [claude-code, changelog, updates, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-changelog-what-changed-this-week/
reviewed: true
score: 7
---


# Claude Code Changelog: What Changed This Week

Keeping track of Claude Code updates helps developers and power users stay productive with the latest features, skill releases, and capability improvements. This weekly changelog covers the most significant updates affecting how you work with Claude skills and the Claude Code CLI.

## Recent Skill Framework Updates

The Claude skills system has seen several refinements that improve how skills interact with tools and manage complex workflows. These changes directly impact skill authors building custom capabilities.

The skill loading mechanism now supports lazy initialization for skills with heavy dependencies. This means skills using the `pdf` skill for document processing or the `xlsx` skill for spreadsheet operations load faster when you first invoke them, rather than at startup. The benefit shows most clearly when you have many skills installed but only use a subset in any given session.

The `get_skill()` function now returns metadata alongside the skill content, including the skill name, description, and available tools. This enables dynamic skill selection in agent workflows where you might want to choose between the `frontend-design` skill for UI prototyping or the `pptx` skill for presentation generation based on context.

## Tool Integration Improvements

Tool calling within skills received stability improvements this week. The execution context now properly isolates tool state between skill invocations, preventing cross-contamination when chaining multiple skills together.

A new hook system allows skills to intercept and modify tool results before they're returned to the model. This proves particularly useful when working with the `webapp-testing` skill, where you might want to filter browser console logs or extract specific DOM elements from screenshots before Claude processes them.

The bash tool gained support for background execution with explicit timeout configuration. Skills that spawn long-running processes—like those using the `algorithmic-art` skill to generate procedural visuals—can now manage execution time more precisely:

```bash
# Run a long task with timeout (example syntax)
timeout 300 uv run python generate_art.py --output artwork.png
```

## New Skill Capabilities

Several new features expanded what skills can accomplish:

**Canvas Design Skill Enhancements**: The `canvas-design` skill now supports PDF export alongside PNG output. This matters when you need vector-quality output for print materials or want to include generated designs in documentation built with the `docx` skill.

**Supermemory Integration**: The `supermemory` skill now supports vector-based semantic search across your knowledge base. You can query past conversations, notes, and research with natural language rather than exact keyword matches. This creates powerful workflows where Claude can reference relevant prior context automatically.

**MCP Builder Updates**: Skills built using the `mcp-builder` framework now support streaming responses. If you're building an MCP server that connects to real-time data sources—stock prices, server metrics, or live feeds—the server can push updates to Claude as they arrive rather than waiting for a complete response.

## Bug Fixes and Performance

The team addressed several issues affecting developer experience:

- Fixed a race condition in skill auto-reloading that caused intermittent tool unavailability
- Resolved memory leaks when skills maintained persistent connections (common with `webapp-testing` and browser automation)
- Corrected path resolution in Windows environments for skills using relative file references
- Fixed YAML parsing for skills with complex front matter containing special characters

## Deprecation Notices

The legacy skill format using `+description` front matter fields is now deprecated. Migration to the standard `description` field completes by the end of the month. Skills still using the old format will continue working but will emit warnings during loading. Check your installed skills with:

```bash
claude skills list --verbose
```

The deprecated format looks like:
```yaml
+description: "Legacy format"
```

Replace it with:
```yaml
description: "Current format"
```

## Coming Soon

Preview features landing next week include:

- Native support for multi-file skill packages (bundling related skills together)
- Enhanced debugging output for skill authors tracking execution flow
- A skill marketplace integration for discovering community-built capabilities

## Staying Updated

To check your current Claude Code version and installed skills:

```bash
claude --version
claude skills list
```

Run `claude skills update` regularly to pull the latest versions of installed skills. Many skill authors release improvements weekly, particularly for skills like `tdd` that benefit from frequent test pattern updates.

The `internal-comms` skill received a significant update this week with new templates for project status reports. If you regularly communicate team progress, this skill now generates formatted updates in multiple formats compatible with the `docx` skill for Word documents or direct Markdown output.

## Practical Example: Chaining Skills

Here's how multiple skills work together in a real workflow:

```python
# Example: Generate a technical report using multiple skills
# 1. Use tdd to generate test cases
# 2. Use pdf to document the test plan
# 3. Use docx to create a formatted report
```

The key insight is that skills now communicate more reliably through shared context, enabling these multi-step workflows without manual state management.

---

Each weekly update improves either skill authoring, tool integration, or runtime performance. Bookmark this changelog to stay informed about changes that affect your Claude Code workflows.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
