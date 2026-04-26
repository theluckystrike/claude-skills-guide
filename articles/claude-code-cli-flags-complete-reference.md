---
layout: default
title: "Claude Code CLI Flags: Complete Reference (2026)"
description: "Every Claude Code CLI flag with usage examples — --model, --print, --resume, --max-turns, --system-prompt, --api-key, --allowedTools, and more."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /claude-code-cli-flags-complete-reference/
reviewed: true
categories: [reference]
tags: [claude, claude-code, cli, flags, reference, automation, scripting]
---

# Claude Code CLI Flags: Complete Reference (2026)

CLI flags transform Claude Code from an interactive assistant into a scriptable automation tool. The right combination of flags lets you pipe code through Claude in CI/CD pipelines, control model selection per-task, limit autonomous behavior, and format output for downstream tools. This reference covers every flag grouped by purpose, with practical examples for each. For the full interactive reference, see the [Command Reference](/commands/).

## Output and Display Flags

### --print (-p)

Runs Claude Code in non-interactive mode. Processes the prompt and prints the response to stdout, then exits. Essential for scripting.

```bash
# Get a one-shot answer
claude --print "What does the main function in src/index.ts do?"

# Pipe file contents to Claude
cat error.log | claude --print "Summarize the errors in this log"

# Use in scripts
SUMMARY=$(claude --print "List the exported functions in src/api.ts")
echo "$SUMMARY" > api-summary.txt
```

### --output-format

Controls the format of Claude's response. Options: `text` (default), `json`, `stream-json`.

```bash
# JSON output for programmatic parsing
claude --print "List all TODO comments in src/" --output-format json

# Stream JSON for real-time processing
claude --print "Explain this codebase" --output-format stream-json
```

### --verbose

Enables detailed logging including tool calls, token counts, and timing information.

```bash
claude --verbose "Fix the TypeScript errors in src/auth.ts"

# Shows:
# [tool:read] Reading src/auth.ts (234 tokens)
# [tool:edit] Editing src/auth.ts lines 45-67
# [tokens] Input: 12,450 Output: 3,200 Cache: 78%
```

## Model Selection Flags

### --model

Specifies which model to use for the session.

```bash
# Use a specific model
claude --model claude-sonnet-4-20250514 "Quick fix for this typo"

# Use Opus for complex tasks
claude --model claude-opus-4-20250414 "Redesign the authentication architecture"
```

### --api-key

Provides an API key directly instead of using the stored credential. Useful in CI/CD environments.

```bash
# Use a specific API key
claude --api-key "sk-ant-xxx" --print "Run the test suite"

# In CI/CD (key from environment)
claude --api-key "$ANTHROPIC_API_KEY" --print "Generate migration SQL"
```

## Session Management Flags

### --resume

Continues the most recent session or a specific session by ID.

```bash
# Resume last session
claude --resume

# Resume specific session
claude --resume session_abc123def

# Resume and immediately add a new instruction
claude --resume "Now implement the database migration we discussed"
```

### --continue (-c)

Similar to `--resume` but specifically designed for adding new context to the previous session.

```bash
# Continue with new instruction
claude --continue "Add error handling to the function you just wrote"
```

### --max-turns

Limits the number of agentic tool-use turns Claude can take before pausing. Each tool call (file read, edit, command) counts as one turn.

```bash
# Limit to 5 tool calls
claude --max-turns 5 "Refactor the auth module"

# Single lookup (read only, no multi-step)
claude --max-turns 1 --print "What's in package.json?"

# Unlimited (default behavior)
claude --max-turns 0 "Build the entire feature"
```

## Prompt and Behavior Flags

### --system-prompt

Replaces the default system prompt entirely. Use with caution — this overrides Claude Code's built-in capabilities.

```bash
claude --system-prompt "You are a SQL expert. Only output SQL queries, no explanations." \
  --print "Create a users table with email, name, and created_at"
```

### --append-system-prompt

Adds instructions to the default system prompt without replacing it. Safer than `--system-prompt`.

```bash
# Add project-specific instructions
claude --append-system-prompt "Always use snake_case for database columns. Prefer CTEs over subqueries."

# CI/CD constraint
claude --append-system-prompt "Never modify files outside the src/ directory" \
  --print "Fix the failing tests"
```

## Permission and Security Flags

### --allowedTools

Restricts which tools Claude can use during the session. Accepts a comma-separated list.

```bash
# Read-only mode (no file edits, no commands)
claude --allowedTools "Read,Grep,Glob" --print "Analyze the codebase structure"

# Allow edits but no command execution
claude --allowedTools "Read,Write,Edit,Grep,Glob" "Fix all TypeScript errors"
```

### --dangerously-skip-permissions

Skips all permission prompts. Claude executes tool calls without confirmation. Only use in controlled environments like CI/CD.

```bash
# WARNING: Use only in sandboxed/CI environments
claude --dangerously-skip-permissions --print "Run npm test and fix any failures" --max-turns 10
```

## Input Flags

### --input-format

Specifies the format of piped input. Options: `text` (default), `json`.

```bash
# Pipe JSON data
echo '{"users": [{"name": "Alice"}, {"name": "Bob"}]}' | \
  claude --input-format json --print "Generate TypeScript types for this data"
```

## Practical Flag Combinations

### CI/CD Pipeline: Fix and Test

```bash
claude --api-key "$ANTHROPIC_API_KEY" \
  --print "Fix the failing test in src/auth.test.ts" \
  --max-turns 5 \
  --allowedTools "Read,Edit,Bash" \
  --dangerously-skip-permissions \
  --output-format json
```

### Code Review in Scripts

```bash
git diff HEAD~1 | claude --print "Review this diff for security issues" \
  --append-system-prompt "Focus on: SQL injection, XSS, auth bypass, secrets exposure" \
  --max-turns 1
```

### Batch File Processing

```bash
for file in src/components/*.tsx; do
  claude --print "Add JSDoc comments to all exported functions in $file" \
    --max-turns 3 \
    --allowedTools "Read,Edit"
done
```

### Documentation Generation

```bash
claude --print "Generate API documentation for src/routes/" \
  --output-format json \
  --max-turns 10 \
  --append-system-prompt "Output markdown. Include request/response examples for each endpoint."
```

## Flag Quick Reference Table

| Flag | Short | Purpose |
|------|-------|---------|
| `--print` | `-p` | Non-interactive output to stdout |
| `--model` | | Select specific model |
| `--resume` | | Continue previous session |
| `--continue` | `-c` | Resume with new context |
| `--max-turns` | | Limit tool-use turns |
| `--output-format` | | Control response format |
| `--verbose` | | Enable detailed logging |
| `--system-prompt` | | Replace system prompt |
| `--append-system-prompt` | | Add to system prompt |
| `--api-key` | | Provide API key directly |
| `--allowedTools` | | Restrict available tools |
| `--dangerously-skip-permissions` | | Skip all permission checks |
| `--input-format` | | Specify input format |

## Try It Yourself

Explore every flag interactively with the [Command Reference](/commands/). Search by flag name, browse by category, and copy example commands directly.

<details>
<summary>Can I combine --print with --resume?</summary>
Yes. This continues a previous session in non-interactive mode, adds your new prompt, and outputs the result to stdout. Useful for scripted multi-step workflows that span multiple script invocations.
</details>

<details>
<summary>What is the default --max-turns value?</summary>
The default is unlimited (0). Claude will continue using tools until it completes the task or you press Ctrl+C. Setting a value like 5 or 10 is recommended for automated scripts to prevent runaway execution.
</details>

<details>
<summary>Does --dangerously-skip-permissions affect MCP servers?</summary>
Yes. With this flag, Claude can call any MCP server tool without asking for permission. This includes write operations like creating GitHub issues or modifying database records. Only use this flag in sandboxed environments.
</details>

<details>
<summary>How do I pass multi-line prompts via CLI flags?</summary>
Use heredoc syntax or pipe from a file. For example: <code>claude --print "$(cat prompt.txt)"</code> or <code>cat prompt.txt | claude --print -</code>. Both approaches handle multi-line content correctly.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Can I combine --print with --resume?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. This continues a previous session in non-interactive mode, adds your new prompt, and outputs the result to stdout. Useful for scripted multi-step workflows that span multiple script invocations."
      }
    },
    {
      "@type": "Question",
      "name": "What is the default --max-turns value?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The default is unlimited (0). Claude will continue using tools until it completes the task or you press Ctrl+C. Setting a value like 5 or 10 is recommended for automated scripts to prevent runaway execution."
      }
    },
    {
      "@type": "Question",
      "name": "Does --dangerously-skip-permissions affect MCP servers?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. With this flag, Claude can call any MCP server tool without asking for permission. This includes write operations like creating GitHub issues or modifying database records. Only use this flag in sandboxed environments."
      }
    },
    {
      "@type": "Question",
      "name": "How do I pass multi-line prompts via CLI flags?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Use heredoc syntax or pipe from a file. For example: claude --print \"$(cat prompt.txt)\" or cat prompt.txt | claude --print -. Both approaches handle multi-line content correctly."
      }
    }
  ]
}
</script>



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

- [Command Reference](/commands/) — Interactive command and flag explorer
- [Permissions and Security](/permissions/) — Understanding tool access controls
- [Claude Code Configuration Guide](/configuration/) — Settings and project configuration
- [Model Selector](/model-selector/) — Compare and choose the right model
- [Advanced Usage Patterns](/advanced-usage/) — Automation and scripting techniques
