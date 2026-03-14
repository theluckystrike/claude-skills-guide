---
layout: default
title: "CLAUDE.md Not Being Read by Claude Code Fix"
description: "Troubleshoot and fix CLAUDE.md files not being read by Claude Code. Practical solutions for developers and power users dealing with ignored project."
date: 2026-03-14
author: theluckystrike
permalink: /claude-md-not-being-read-by-claude-code-fix/
categories: [troubleshooting]
tags: [claude-code, claude-md, troubleshooting]
---

# CLAUDE.md Not Being Read by Claude Code Fix

Your CLAUDE.md file sits in your project root, packed with detailed instructions, coding conventions, and project-specific guidelines—yet Claude Code seems to ignore it completely. This is one of the most frustrating issues developers encounter when setting up their AI coding assistant. The good news: most causes have straightforward fixes.

## Why Claude Code Might Not Read Your CLAUDE.md

Claude Code automatically searches for and loads CLAUDE.md files from the current working directory and its parent directories. However, several issues can prevent this from working correctly.

### File Location and Naming Issues

The most basic problem is incorrect file placement or naming. Claude Code expects the file to be named exactly `CLAUDE.md` (case-sensitive) and located in the project root or current working directory. Variants like `Claude.md`, `claude.md`, or `CLAUDE.TXT` will not be recognized.

Ensure your file is in the correct location:

```bash
# Correct location and naming
project-root/
├── CLAUDE.md        # This gets loaded
├── src/
├── package.json
```

If you're working in a subdirectory, Claude Code searches parent directories upward. Running Claude Code from `/project/src/utils/` will check for CLAUDE.md in that directory, then `/project/src/`, then `/project/`, stopping at the first one found.

### File Encoding and Format Problems

CLAUDE.md files must be valid UTF-8 encoded text. Corrupted encoding, BOM (Byte Order Mark) characters, or special Unicode characters can prevent proper parsing. Most editors save UTF-8 by default, but if you're copying content from other sources, verify the encoding.

A simple test: open your CLAUDE.md in a text editor that displays encoding information. Alternatively, use the command line:

```bash
file -I CLAUDE.md
# Should output: CLAUDE.md: text/plain; charset=utf-8
```

### Syntax Errors in Your CLAUDE.md

Even though CLAUDE.md uses Markdown, certain syntax patterns can cause parsing issues. Avoid nested structures that might confuse the parser:

```markdown
# What works
## Project Conventions
- Use TypeScript strict mode
- Prefer functional components over class components

# What might cause issues
## Complex nested lists
- Item with
  - nested
    - indentation
```

## Verifying CLAUDE.md Is Being Loaded

Before troubleshooting further, confirm whether Claude Code is actually reading your file. Add a unique, easily recognizable instruction and see if it's followed:

```markdown
# TEST INSTRUCTION
Every time you respond, start your message with "CLAUDE.md LOADED" if you can read this file.
```

If Claude Code doesn't acknowledge the test instruction, the file isn't being loaded. If it does acknowledge, the issue lies elsewhere in your instructions.

## Configuration Conflicts

### Permission Issues

If your CLAUDE.md file has restrictive permissions, Claude Code might be unable to read it. Check file permissions:

```bash
ls -la CLAUDE.md
# Should be readable: -rw-r--r-- 
```

Fix with:

```bash
chmod 644 CLAUDE.md
```

### Directory Permission Problems

Claude Code needs execute permission on directories to traverse them. If parent directories lack execute permission, the file search fails:

```bash
chmod 755 /path/to/your/project
```

## Context Window and File Size

Extremely large CLAUDE.md files can cause problems. When your file exceeds a certain size, Claude Code might truncate or skip parts of it. The recommended maximum is around 8,000-10,000 characters.

If you need extensive documentation, consider splitting into multiple files:

```markdown
# Main CLAUDE.md (project root)
- Brief overview
- Key conventions
- Reference to detailed docs

# CLAUDE.conventions.md (detailed rules)
- Coding standards
- Naming patterns
- Testing requirements
```

Then reference the additional files in your main CLAUDE.md:

```markdown
# See Also
For detailed API conventions, see CLAUDE.api.md
For testing patterns, see CLAUDE.testing.md
```

## Interaction with Claude Skills

Claude Code's skill system operates alongside CLAUDE.md files, but they serve different purposes. Skills provide reusable workflows and tool definitions, while CLAUDE.md provides project-specific context. Both can be active simultaneously.

The supermemory skill, for example, maintains persistent context across sessions. If you're using supermemory to store project knowledge, ensure your CLAUDE.md instructions don't conflict with stored context. You can override stored context by including explicit instructions in CLAUDE.md.

## Common Scenarios and Solutions

### CLAUDE.md Works in One Project But Not Another

This usually indicates project-specific configuration. Check for:
- Hidden `.claude/` directory with conflicting settings
- Environment variables affecting Claude Code behavior
- Different working directory when launching Claude Code

### CLAUDE.md Works Locally But Not in CI/CD

CI/CD environments often run with different working directories. Explicitly specify the project root:

```bash
cd /path/to/project && claude --print
```

Or use the `--project` flag if available in your Claude Code version.

### Partial Loading

If Claude Code reads some sections but ignores others, the issue is likely instruction priority. Earlier instructions carry more weight. Move critical instructions toward the top of the file:

```markdown
# CRITICAL INSTRUCTIONS (highest priority)
- Never use console.log
- Always write tests before implementation

# Project Overview
This is a React application...
```

## Debugging Tips

Enable verbose logging if available:

```bash
claude --verbose
```

Review Claude Code's startup output for any warnings about missing or unreadable files.

Create a minimal test case:

```markdown
# Test
Respond with "OK" if you read this.
```

If the minimal version works, gradually add content back to identify what causes the issue.

## Best Practices Going Forward

1. **Start simple**: Begin with a minimal CLAUDE.md, verify it loads, then expand
2. **Test regularly**: Include test instructions to confirm loading
3. **Keep it focused**: One file under 10,000 characters works better than multiple large files
4. **Version control**: Include CLAUDE.md in your repository so team members benefit
5. **Validate location**: Double-check the file is in the directory where you invoke Claude Code

## When to Seek Additional Help

If you've tried all these solutions and CLAUDE.md still isn't loading, the issue might be:
- A bug in your Claude Code version (try updating)
- A conflicting configuration in your Claude Code settings
- An environment-specific issue

Check the Claude Code documentation for your version, and review any recent changes to the tool that might affect file loading behavior.

Building effective CLAUDE.md files takes iteration. Start with the basics, verify loading works, then progressively add complexity. The investment pays off in more productive Claude Code sessions where your project context is properly understood from the first prompt.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Code Troubleshooting Hub](/claude-skills-guide/troubleshooting-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
