---
layout: default
title: "Claude Code Ignores .md Instructions Fix"
description: "Troubleshooting guide for when Claude Code ignores skill instructions in .md files. Practical solutions for developers and power users."
date: 2026-03-14
categories: [troubleshooting]
tags: [claude-code, claude-skills, troubleshooting, skill-md, claude-code-issues]
author: theluckystrike
permalink: /claude-code-ignores-claude-md-instructions-fix/
---

# Claude Code Ignores .md Instructions Fix

Your Claude skill `.md` file sits in `~/.claude/skills/`, but Claude Code seems to ignore your carefully written instructions. This is a common issue that most developers encounter when building custom skills. Here is a practical guide to diagnosing and fixing the problem.

## Why Claude Code May Ignore Your .md Instructions

Several factors can cause Claude Code to overlook or misinterpret skill instructions. Understanding the root cause is the first step toward a reliable fix.

### Encoding and Formatting Issues

Claude Code expects UTF-8 encoded Markdown files. If your `.md` file contains special characters, non-standard quotes, or hidden formatting from word processors, the parser may fail silently. Always create skill files using a plain text editor and save as UTF-8.

### Incorrect File Placement

Skills must reside in the correct directory structure. Claude Code searches for skills in `~/.claude/skills/`. The skill file must be named with a `.md` extension and should not contain spaces or special characters in its filename. For example, a skill named `pdf` should be at `~/.claude/skills/pdf.md`, not `~/.claude/skills/my-pdf-skill.md`.

### YAML Front Matter Conflicts

If your skill file contains YAML front matter, it may interfere with instruction parsing. While some skills include front matter for organizational purposes, Claude Code typically reads content after the front matter delimiters. Ensure your core instructions appear after the closing `---` line.

## Practical Fixes

### Fix 1: Verify Skill File Structure

A properly formatted skill file should look like this:

```
~/.claude/skills/
├── pdf.md
├── tdd.md
├── frontend-design.md
└── xlsx.md
```

Each file contains only the instructions, without additional metadata that could confuse the parser. Place one skill per file, with clear action-oriented language.

### Fix 2: Use Explicit Invocation Commands

When invoking a skill, use the full command format:

```
/pdf extract tables from contract.pdf
```

```
/tdd write tests for authentication module
```

```
/xlsx create spreadsheet with monthly sales data
```

Avoid abbreviated commands or assumptions about context. Some users report that adding explicit context improves results:

```
/frontend-design create a responsive navbar with mobile hamburger menu using tailwind
```

### Fix 3: Rebuild the Skills Index

Claude Code maintains an internal index of available skills. If you add or modify a skill file, the index may not update immediately. You can force a refresh by:

1. Restarting your Claude Code session
2. Running `/help` to verify skill registration
3. Creating a new session where the skill is invoked first

### Fix 4: Simplify Instruction Language

Complex or ambiguous instructions reduce accuracy. Instead of writing elaborate paragraphs, use concise bullet points:

```
# PDF Skill Instructions

- Extract text from specified pages
- Merge multiple PDF files in order
- Fill form fields using provided data
- Output results as markdown
```

This structure works better than narrative descriptions. The **pdf** skill responds more reliably to bullet-point commands than to paragraph-style requests.

### Fix 5: Check Skill Naming Conflicts

If you have multiple skills with similar names or if a custom skill conflicts with a native skill, Claude Code may default to the built-in version. Rename your custom skill to avoid collisions:

```
# Instead of conflicting with native 'tdd' skill:
~/.claude/skills/tdd-custom.md
~/.claude/skills/tdd-internal.md
```

### Fix 6: Debug with Minimal Examples

When troubleshooting, create a minimal skill file to isolate the issue:

```
# ~/.claude/skills/test-skill.md
Test skill - respond with "Skill loaded successfully"
```

Invoke it with `/test-skill` and observe the response. If this minimal version works, gradually add complexity to identify what breaks the instructions.

## Advanced Troubleshooting

### Using the Supermemory Skill for Reference

If you have the **supermemory** skill installed, you can query it for past successful skill invocations:

```
/supermemory find examples of successful pdf skill usage
```

This helps you understand the exact phrasing patterns that work well with each skill.

### Examining Claude Code Logs

When skills continue to misbehave, check Claude Code's debug output. Run with verbose logging enabled to see which skills load and how instructions parse:

```
claude --verbose [your command]
```

The output reveals whether a skill loaded successfully and what instructions Claude Code received.

### Skill Priority and Fallback Behavior

Claude Code has built-in priority for native skills over custom skills with the same name. If you want your custom implementation to take precedence, ensure the filename matches exactly and test in a fresh session.

## Common Pitfalls to Avoid

Do not include Liquid template syntax like `{{ }}` or `{% %}` in skill instructions unless properly escaped. These can interfere with Jekyll processing if your skills repository uses static site generation. If you need to reference template syntax, write it as literal text without the delimiters.

Avoid excessive instruction length. Skills with more than 500 words of instructions often see reduced accuracy. Break complex workflows into multiple skills rather than cramming everything into one file.

## Summary

When Claude Code ignores your `.md` instructions, systematically check file placement, encoding, naming, and instruction format. Start with the simplest possible skill file to verify basic functionality, then add complexity incrementally. Use explicit invocation commands and concise bullet-point instructions for best results.

For developers working with specific domains, skills like **pdf**, **tdd**, **xlsx**, and **frontend-design** demonstrate well-structured instruction patterns worth emulating. Study how these skills format their instructions and apply similar conventions to your custom skills.


## Related Reading

- [Claude Skills Troubleshooting Hub](/claude-skills-guide/troubleshooting-hub/)
- [Claude Code Output Quality: How to Improve Results](/claude-skills-guide/claude-code-output-quality-how-to-improve-results/)
- [Claude Code Keeps Making the Same Mistake: Fix Guide](/claude-skills-guide/claude-code-keeps-making-same-mistake-fix-guide/)
- [Best Way to Scope Tasks for Claude Code Success](/claude-skills-guide/best-way-to-scope-tasks-for-claude-code-success/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
