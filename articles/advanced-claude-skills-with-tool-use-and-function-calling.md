---
layout: post
title: "Advanced Claude Skills: Tool Use Patterns"
description: "Design Claude skills that use tools precisely. Patterns for reading files, running bash commands, MCP custom tools, and reliable tool chaining."
date: 2026-03-13
categories: [skills, advanced]
tags: [claude-code, claude-skills, tool-use, mcp, advanced]
author: "Claude Skills Guide"
reviewed: true
score: 4
---

# Advanced Claude Skills: Tool Use and Function Calling Patterns

Claude's tool use capabilities transform skills from prompt-only text generators into agents that can read files, execute code, call APIs, and take real actions in your development environment. This guide covers the advanced patterns for designing skills that use tools precisely and reliably.

## How Tools Work Within Skills

When you invoke a skill with `/skill-name`, Claude runs with access to a set of tools — `read_file`, `write_file`, `bash`, and others depending on your session configuration. Claude decides autonomously when to call a tool based on the task requirements and the guidance in the skill body. Your job as a skill author is to shape that decision-making through the skill's system prompt.

The skill body (everything after the front matter in your `.md` file) is the system prompt Claude receives at invocation time. This is where you tell Claude when and how to use each tool.

## Guiding Tool Use in the Skill Body

### Specify When to Read Files

Without explicit guidance, Claude may or may not read relevant files before acting. Be explicit:

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

For skills like `docx` and the [`pdf` skill](/claude-skills-guide/articles/best-claude-skills-for-data-analysis/) that create files, be precise about file naming and location:

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

Now any skill invocation in Claude Code can use `run_eslint` as a tool. For a code review skill, write a `code-review.md` skill body like:

```
When reviewing code:
1. Read the file with read_file
2. Run ESLint with run_eslint and note any violations
3. Check for logical issues beyond what ESLint catches
4. Provide a structured review with: violations, suggestions, and a summary score
```

## Tool Chaining Patterns

Some tasks require chaining multiple tool calls in a specific sequence. Guide this explicitly in the skill body.

### Read-Modify-Write Pattern

For the [`frontend-design` skill](/claude-skills-guide/articles/best-claude-code-skills-for-frontend-development/):

```
To add a new component:
1. read_file: src/components/index.ts (check if component name is taken)
2. read_file: docs/design-tokens.md (get current design tokens)
3. [generate component code in context]
4. write_file: src/components/{ComponentName}/{ComponentName}.tsx
5. write_file: src/components/{ComponentName}/index.ts (barrel export)
6. read_file: src/components/index.ts (get current barrel file content)
7. write_file: src/components/index.ts (add new export)
8. bash: npx tsc --noEmit (verify no TypeScript errors)

If step 8 produces errors, fix them and re-run before completing.
```

### Test-Execute-Verify Pattern

For the [`tdd` skill](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/):

```
For any implementation task:
1. write_file: {test_file} (write failing tests first)
2. bash: npx jest {test_file} --no-coverage (verify tests fail as expected)
3. write_file: {implementation_file} (write implementation)
4. bash: npx jest {test_file} --no-coverage (verify tests pass)
5. If tests don't pass, debug and fix before completing

Never report success unless step 4 produces all passing tests.
```

## Handling Tool Errors

Claude needs explicit guidance on how to handle tool failures. Without it, it may either ignore errors or halt unexpectedly.

```
Error handling:
- If read_file fails because the file doesn't exist: create a minimal file with 
  appropriate boilerplate, then proceed
- If bash returns a non-zero exit code: include the error output in your analysis
  and suggest a fix, do not silently ignore it
- If write_file fails: report the failure and the attempted path, do not retry 
  silently more than once
- If TypeScript compilation fails after your changes: fix the errors before 
  completing the task, even if the user didn't ask you to
```

## Debugging Tool-Heavy Skills

To see exactly what tool calls a skill is making during development, run Claude Code with verbose output or check the session transcript after the session. Claude Code logs tool calls to the terminal during interactive sessions — you can watch them appear in real time as the skill runs.

When a skill behaves unexpectedly, start a fresh session and add explicit output instructions to the skill body:

```
After each tool call, briefly state: "Called [tool_name] on [target], result: [summary]"
This helps trace the tool call sequence.
```

Remove this debugging instruction once the skill is working correctly.

---

## Related Reading

- [Skill .md File Format Explained With Examples](/claude-skills-guide/articles/skill-md-file-format-explained-with-examples/) — The `tools` and `max_turns` fields that control tool access are fully documented here with annotated examples
- [How to Write a Skill .md File for Claude Code](/claude-skills-guide/articles/how-to-write-a-skill-md-file-for-claude-code/) — A step-by-step guide for writing skill bodies that orchestrate tool calls effectively
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) — Tool-heavy skills accumulate context quickly from tool outputs; this article explains how to keep per-session costs manageable

Built by theluckystrike — More at [zovo.one](https://zovo.one)
