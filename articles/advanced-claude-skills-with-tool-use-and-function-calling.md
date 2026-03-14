---
layout: default
title: "Advanced Claude Skills with Tool Use and Function Calling"
description: "Design Claude skills with precise tool use: restrict tool access per skill, create custom MCP tools, and build reliable function-calling workflows."
date: 2026-03-13
categories: [guides]
tags: [claude-code, claude-skills, tool-use, function-calling, mcp]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /advanced-claude-skills-with-tool-use-and-function-calling/
---

# Advanced Claude Skills with Tool Use and Function Calling

[Claude's tool use capabilities transform skills from prompt-only text generators into agents](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/) that can read files, execute code, call APIs, and take real actions in your development environment. This guide covers the advanced patterns for designing skills that use tools precisely and reliably.

## How Tools Work Within Skills

[When a skill is invoked, it operates within a specific tool context](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/) That context determines:

1. Which tools are available (from the skill's `tools` front matter field)
2. How tool calls are logged and intercepted (via hooks)
3. What the model sees as the result of each tool call

Claude decides autonomously when to call a tool based on the task requirements and the guidance in the skill body. Your job as a skill author is to shape that decision-making.

## Declaring Tool Requirements

The `tools` field in a skill's front matter limits tool availability for that skill:

```yaml
---
name: pdf
description: Converts markdown documents to PDF files
tools:
  - Read
  - Write
  - Bash
---
```

This skill can only use `Read`, `Write`, and `Bash`. Even if the session has `WebFetch` enabled, the `pdf` skill cannot call it. This is useful for:

- **Security**: Preventing skills from making unintended network calls
- **Auditability**: A skill with a narrow tool set is easier to reason about
- **Performance**: Skills that don't need certain tools shouldn't try to use them

If you omit `tools` entirely, the skill inherits all session-level tools.

## Guiding Tool Use in the Skill Body

Restricting which tools are available is not enough for reliable behavior. You also need to tell the skill when and how to use each tool.

### Specify When to Read Files

Without guidance, Claude may or may not read relevant files before acting. Make it explicit:

```
Before writing any code:
1. Read the target file to understand its current structure
2. Read the project's style guide at docs/style-guide.md
3. Check for any existing similar implementations in src/

Do not guess at file contents. Always read them first.
```

### Specify bash Command Patterns

For skills that use bash, template the common commands to reduce variation:

```
When running tests, use: npm test -- --testPathPattern={test_file}
When checking TypeScript errors: npx tsc --noEmit
When formatting code: npx prettier --write {file_path}

Always run the formatter on any file you write before completing the task.
```

### Specify Output File Handling

For skills like `docx` and `pdf` that create files, be precise about file naming and location:

```
Write output files to the ./output/ directory.
File naming: {source_name}-{YYYY-MM-DD}.{extension}
Example: report.md -> output/report-2026-03-13.pdf

If ./output/ does not exist, create it with: mkdir -p ./output/
Confirm the output file path in your response.
```

## Building a Custom Tool via MCP

If the built-in tools don't do what you need, you can expose custom functionality through the Model Context Protocol (MCP). An MCP server exposes functions that Claude treats as tools.

Here's a minimal MCP server that provides a `run_eslint` tool:

```python
# .claude/mcp-servers/linting.py
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent
import subprocess
import json

server = Server("linting-tools")

@server.list_tools()
async def list_tools():
    return [
        Tool(
            name="run_eslint",
            description="Run ESLint on a file or directory and return structured results",
            inputSchema={
                "type": "object",
                "properties": {
                    "path": {"type": "string", "description": "File or directory to lint"},
                    "fix": {"type": "boolean", "description": "Auto-fix fixable issues", "default": False}
                },
                "required": ["path"]
            }
        )
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict):
    if name == "run_eslint":
        path = arguments["path"]
        fix = arguments.get("fix", False)
        cmd = ["npx", "eslint", "--format", "json", path]
        if fix:
            cmd.append("--fix")
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        return [TextContent(type="text", text=result.stdout or result.stderr)]

async def main():
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, server.create_initialization_options())

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
```

Register the MCP server in `.claude/settings.json`:

```json
{
  "mcpServers": {
    "linting": {
      "command": "python3",
      "args": [".claude/mcp-servers/linting.py"]
    }
  }
}
```

Now any skill can use `run_eslint` as a tool. For a code review skill:

```yaml
---
name: code-review
tools:
  - Read
  - run_eslint
  - Bash
---

When reviewing code:
1. Read the file with Read
2. Run ESLint with run_eslint and note any violations
3. Check for logical issues beyond what ESLint catches
4. Provide a structured review with: violations, suggestions, and a summary score
```

## Tool Chaining Patterns

Some tasks require chaining multiple tool calls in a specific sequence. Guide this explicitly in the skill body.

### Read-Modify-Write Pattern

For the `frontend-design` skill:

```
To add a new component:
1. Read: src/components/index.ts (check if component name is taken)
2. Read: docs/design-tokens.md (get current design tokens)
3. [generate component code in context]
4. Write: src/components/{ComponentName}/{ComponentName}.tsx
5. Write: src/components/{ComponentName}/index.ts (barrel export)
6. Read: src/components/index.ts (get current barrel file content)
7. Write: src/components/index.ts (add new export)
8. Bash: npx tsc --noEmit (verify no TypeScript errors)

If step 8 produces errors, fix them and re-run before completing.
```

### Test-Execute-Verify Pattern

For the `tdd` skill:

```
For any implementation task:
1. Write: {test_file} (write failing tests first)
2. Bash: npx jest {test_file} --no-coverage (verify tests fail as expected)
3. Write: {implementation_file} (write implementation)
4. Bash: npx jest {test_file} --no-coverage (verify tests pass)
5. If tests don't pass, debug and fix before completing

Never report success unless step 4 produces all passing tests.
```

## Handling Tool Errors

Claude needs explicit guidance on how to handle tool failures. Without it, it may either ignore errors or halt unexpectedly.

```
Error handling:
- If Read fails because the file doesn't exist: create a minimal file with
  appropriate boilerplate, then proceed
- If Bash returns a non-zero exit code: include the error output in your analysis
  and suggest a fix, do not silently ignore it
- If Write fails: report the failure and the attempted path, do not retry
  silently more than once
- If TypeScript compilation fails after your changes: fix the errors before
  completing the task, even if the user didn't ask you to
```

## Tool Use Limits

The `max_turns` field in skill front matter limits the total number of tool calls plus model turns the skill can take:

```yaml
max_turns: 10
```

For skills that need to read many files, this can be a bottleneck. Size appropriately: a `tdd` skill that might read 3 files, write 2 files, and run tests 3 times needs at least 8 turns plus model turns.

## Debugging Tool-Heavy Skills

To see exactly what tool calls a skill is making, watch the tool call output that Claude Code prints inline as the skill runs. Claude Code shows each tool call and its result in the terminal as they execute. Use this during skill development to verify the tool call sequence matches your design.

You can also ask Claude directly in the session: "What tool calls did you make in the last task?" and it will summarize the sequence from its context window.

---

## Related Reading

- [Skill .md File Format Explained With Examples](/claude-skills-guide/skill-md-file-format-explained-with-examples/) — The `tools` and `max_turns` fields that control tool access are fully documented here with annotated examples
- [How to Write a Skill .md File for Claude Code](/claude-skills-guide/how-to-write-a-skill-md-file-for-claude-code/) — A step-by-step guide covering how to write skill bodies that orchestrate tool calls effectively
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/) — Tool-heavy skills accumulate context quickly from tool outputs; this article explains how to keep that cost manageable

**Related guides:** [Best Way to Handle Claude Code Mistakes Efficiently](https://theluckystrike.github.io/claude-skills-guide/best-way-to-handle-claude-code-mistakes-efficiently/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
