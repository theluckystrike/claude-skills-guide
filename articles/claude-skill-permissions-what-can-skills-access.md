---
layout: default
title: "Claude Skill Permissions: What Can Skills Access?"
description: "A comprehensive guide to understanding Claude skill permissions, tool access controls, and what capabilities skills have within your development environment."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills, permissions, security, settings]
author: "Claude Skills Guide"
reviewed: true
score: 7
---

# Claude Skill Permissions: What Can Skills Access?

When you create or use a Claude skill, understanding what that skill can and cannot access is critical for security, reliability, and predictable behavior. This guide breaks down the permission model for Claude skills, showing developers and power users exactly what capabilities are available and how to control them.

## The Permission Model Overview

Claude skills operate within a defined permission boundary. This boundary determines three key things:

1. **Tool access**: Which tools the skill can call (read_file, write_file, bash, etc.)
2. **Resource access**: Which files, directories, and external services the skill can interact with
3. **Capability limits**: Constraints on execution time, token usage, and turn count

When a skill runs, it does not automatically get access to everything in your environment. Instead, it operates with the exact permissions you define.

## Tool Access: The Primary Permission Control

The most direct way to control what a skill can do is through the `tools` field in the skill's front matter. This field explicitly lists which tools are available to that skill.

### Declaring Allowed Tools

```yaml
---
name: pdf-generator
description: Converts markdown documents to formatted PDF files
tools:
  - read_file
  - write_file
  - bash
---
```

In this example, the `pdf-generator` skill can only use three specific tools. Even if your Claude session has additional tools enabled (like `web_fetch` or database connectors), this skill cannot access them. This is a fundamental security feature.

### Why Tool Restriction Matters

Limiting tool access serves several practical purposes:

- **Security**: A skill with narrow tool access cannot accidentally perform actions outside its intended scope
- **Predictability**: You can reason about what a skill will do by examining its tool list
- **Auditability**: When debugging, you know exactly which capabilities were available
- **Cost control**: Skills that cannot call expensive tools won't generate unexpected API costs

### The Default: Inheriting All Tools

If you omit the `tools` field entirely, the skill inherits all tools available in the current session:

```yaml
---
name: general-assistant
description: A general-purpose helper skill
# No tools field means: inherits all session tools
---
```

This default is convenient but should be used carefully. For production skills, explicitly declaring tools is the recommended practice.

## File System Access

Skills access the file system through the `read_file` and `write_file` tools. However, there are practical constraints and patterns you should understand.

### Path Restrictions

Skills can access any file path that the underlying Claude session has access to. If your session is running in a specific directory context, the skill operates within that context. There's no per-skill file system sandboxing at the directory level.

To restrict file access, combine tool restrictions with explicit instructions in the skill body:

```yaml
---
name: config-editor
description: Edits configuration files safely
tools:
  - read_file
  - write_file
---
# Skill body
You may only read and write files in the ./config/ directory.
Do not access any other directories.
```

### Reading Before Writing

A common pattern for file operations is the read-modify-write sequence:

```yaml
---
name: code-formatter
description: Formats code files according to project standards
tools:
  - read_file
  - write_file
  - bash
---
# Skill body
Before modifying any file:
1. read_file the current content
2. Identify the file type and applicable formatting rules
3. write_file the formatted version

After writing, run: npx prettier --write {file_path}
```

## Bash and Command Execution

The `bash` tool provides the most powerful capability but also carries the highest risk. When a skill has bash access, it can execute any command your user environment permits.

### Limiting Command Scope

You cannot restrict which specific bash commands a skill runs through front matter. Instead, provide explicit guidance in the skill body:

```yaml
---
name: test-runner
description: Runs project test suites
tools:
  - bash
  - read_file
---
# Skill body
You may only run the following commands:
- npm test (or yarn test)
- npx jest (for Jest-based projects)
- npx pytest (for Python projects)

Do not run any other bash commands. Do not install packages.
Do not modify git state or run git commands.
```

### Dangerous Combinations to Avoid

Certain tool combinations require extra scrutiny:

- `bash` + `write_file` + `web_fetch`: Could download and execute arbitrary code
- `bash` + database tools: Could modify production data
- `write_file` without `read_file` first: Could overwrite files unintentionally

Always audit skills that combine powerful tools.

## Turn Limits and Execution Constraints

The `max_turns` field controls how long a skill can run:

```yaml
---
name: complex-refactor
description: Performs large-scale code refactoring
tools:
  - read_file
  - write_file
  - bash
max_turns: 25
---
```

Each "turn" represents one model response, which may include multiple tool calls. A skill that needs to read 10 files, write 5 files, and run tests 3 times might consume 20+ turns. Set this number based on realistic task estimates.

## Environment Variables and Secrets

Skills access environment variables from the parent Claude session. There's no per-skill secret isolation. If your session has `API_KEY` in the environment, any skill with `bash` access can read it.

For sensitive workflows, consider:

1. Running skills in isolated sessions without sensitive env vars
2. Using MCP servers that handle authentication separately
3. Passing sensitive data as explicit parameters rather than environment variables

## Practical Example: Building a Restricted Skill

Here's a complete example of a well-structured, restricted skill:

```yaml
---
name: logger
description: Adds structured logging to JavaScript functions
tools:
  - read_file
  - write_file
max_turns: 15
---
# Skill body
You help developers add consistent logging to their JavaScript code.

Process:
1. read_file the target file to understand its structure
2. Identify functions that would benefit from logging
3. Add console.log statements with the format:
   `[FUNCTION_NAME] called with:`, arguments
4. write_file the modified file

Rules:
- Only modify .js and .ts files
- Do not modify test files
- Preserve all existing code
- Add logging at the function entry point only

If the file already has logging, report that and stop.
```

This skill demonstrates good permission hygiene: it has exactly the tools it needs, a reasonable turn limit, and clear behavioral constraints in the body.

## Verifying Skill Permissions

To audit what a skill can do, examine its front matter:

1. Check the `tools` list (or note if it's missing, meaning full access)
2. Review `max_turns` for execution limits
3. Read the skill body for behavioral constraints

You can also enable tool logging while a skill runs:

```
/tools log on
```

This shows every tool call in real time, helping you verify the skill behaves as expected.

## Summary

Claude skill permissions control what capabilities a skill has within your development environment. The primary mechanism is the `tools` front matter field, which explicitly lists allowed tools. Without this field, skills inherit all session tools.

Key principles:

- Always declare explicit `tools` lists for production skills
- Combine tool restrictions with behavioral guidance in the skill body
- Set appropriate `max_turns` based on task complexity
- Understand that environment variables and file access are shared with the parent session
- Audit skills that combine powerful tools like `bash` + `write_file`

By understanding and properly configuring these permissions, you can build reliable, secure skills that do exactly what you intend—no more, no less.

---

## Related Reading

- [Skill .md File Format Explained With Examples](/claude-skills-guide/skill-md-file-format-explained-with-examples/) — Complete reference for skill front matter fields including `tools` and `max_turns`
- [Advanced Claude Skills with Tool Use and Function Calling](/claude-skills-guide/advanced-claude-skills-with-tool-use-and-function-calling/) — Guide to building skills that orchestrate multiple tool calls effectively
- [How to Write a Skill .md File for Claude Code](/claude-skills-guide/how-to-write-a-skill-md-file-for-claude-code/) — Step-by-step guide for creating well-structured skills with proper permission boundaries

Built by theluckystrike — More at [zovo.one](https://zovo.one)
