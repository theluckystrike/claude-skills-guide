---
title: "Migrating OpenAI Assistants to Claude (2026)"
description: "Convert OpenAI Assistants (instructions, tools, file search) to Claude Code SKILL.md files. Covers instruction mapping, tool equivalents, and feature gaps."
permalink: /migrating-openai-assistants-to-claude-skills/
categories: [skills, 2026]
tags: [claude-code, claude-skills, openai-migration, comparison]
last_updated: 2026-04-19
---

## The Specific Situation

You have 5 OpenAI Assistants in production: a code reviewer, a documentation generator, a test writer, a deployment checker, and a data analyzer. Each assistant has instructions (system prompt), tools (code interpreter, file search, function calling), and attached files. You are moving to Claude Code and need to convert these to skills without losing functionality. Some features map directly; others require architectural changes.

## Technical Foundation

OpenAI Assistants are cloud-hosted objects with properties: `instructions` (system prompt), `model`, `tools` (array of tool types), `file_ids` (attached files), and `metadata`. Conversations happen in threads with runs. State is managed server-side.

Claude Code skills are SKILL.md files with frontmatter (name, description, allowed-tools, paths, context, agent) and a markdown body containing instructions. They run locally with filesystem access. State is session-scoped.

The migration maps Assistant properties to SKILL.md fields. Instructions become the skill body. Tools map to `allowed-tools` and native Claude Code capabilities. File attachments become local reference files.

## The Working SKILL.md

Mapping an OpenAI Assistant to a Claude Code skill:

OpenAI Assistant (Python):
```python
assistant = client.beta.assistants.create(
    name="code-reviewer",
    instructions="""Review code for:
    1. Unused imports
    2. Missing error handling
    3. Security vulnerabilities
    4. Test coverage gaps
    Output as a checklist with severity ratings.""",
    model="gpt-4o",
    tools=[
        {"type": "code_interpreter"},
        {"type": "file_search"}
    ],
    file_ids=["file-abc123"]  # coding standards doc
)
```

Equivalent Claude Code skill:

```yaml
---
name: code-reviewer
description: >
  Review code for quality, security, and test coverage. Checks
  unused imports, error handling, security patterns, and test
  gaps. Outputs a formatted checklist with severity ratings.
allowed-tools: Read Grep Glob Bash(node *)
---

# Code Reviewer

Review code for:
1. Unused imports — grep for import statements, verify each is referenced
2. Missing error handling — check async operations for try/catch
3. Security vulnerabilities — hardcoded secrets, SQL injection, XSS
4. Test coverage gaps — find functions without corresponding test files

## Output Format
For each file, produce a checklist:
- [ ] Issue description (severity: info/warning/error)
- File path and line number
- Suggested fix

## Reference Standards
For coding standards, see `references/coding-standards.md`.
```

## Migration Field Mapping

| OpenAI Assistant Field | Claude Code Skill Equivalent |
|----------------------|---------------------------|
| `name` | `name` in frontmatter |
| `instructions` | SKILL.md body (markdown content) |
| `model` | `model` in frontmatter (optional) |
| `tools: code_interpreter` | `allowed-tools: Bash(python3 *)` |
| `tools: file_search` | `allowed-tools: Read Grep Glob` |
| `tools: function calling` | MCP servers or `allowed-tools: Bash(*)` |
| `file_ids` | Local files in `references/` directory |
| `metadata` | Not directly mapped (use SKILL.md comments) |
| Thread persistence | Session-scoped (write to files for persistence) |
| Runs/Steps | Invocation via `/skill-name` |

## Step-by-Step Migration Process

**Step 1: Extract instructions.** Copy the Assistant's `instructions` text. This becomes the body of your SKILL.md, below the frontmatter.

**Step 2: Map tools.** For each tool in the Assistant's `tools` array:
- `code_interpreter` → `allowed-tools: Bash(python3 *)` (Claude runs Python locally)
- `file_search` → `allowed-tools: Read Grep Glob` (Claude searches local files)
- `function` (custom functions) → Either wrap as bash scripts in `scripts/` or set up MCP servers for API integrations

**Step 3: Migrate files.** Download each attached file from the Assistant. Save to `references/` or `data/` directories within the skill. Update instructions to reference local paths instead of file IDs.

**Step 4: Add frontmatter.** Add YAML frontmatter with name, description, and any relevant fields (paths, allowed-tools, context).

**Step 5: Test.** Invoke the skill with `/skill-name` and verify output matches the original Assistant's behavior. Adjust instructions for differences in Claude's response style vs GPT-4.

## Features That Do Not Map Directly

**Vector store file search.** OpenAI's file_search indexes documents into a vector store for semantic search. Claude Code reads files directly via Grep (text search) and Read (full file read). For large document collections, set up a vector database MCP server or restructure documents so Grep-based search suffices.

**Persistent threads.** Assistant threads maintain conversation history server-side across sessions. Claude Code sessions are ephemeral. For state that must persist, write to files: `reports/`, `.claude/staging/`, or a database. Claude Code's auto-memory (MEMORY.md) captures behavioral preferences but not conversation history.

**Server-side execution.** Assistants run in OpenAI's cloud. Claude Code skills run locally. This is a fundamental architecture change -- you gain filesystem access but lose cloud-hosted statelessness.

## Common Problems and Fixes

**Claude's response style differs from GPT-4.** The same instructions produce different output formatting and verbosity. Adjust instructions to be more explicit about output format. Add structured output templates in the skill body.

**File search results differ.** Grep finds exact text matches; OpenAI's file_search uses semantic embedding similarity. For questions like "what does this document say about X," semantic search may find relevant passages that exact-match Grep misses. Structure your reference documents with clear headings and keywords to improve Grep-based discovery.

**Function calling migration.** OpenAI Assistants call custom functions with structured JSON inputs. The closest Claude Code equivalent is MCP server tools (typed interfaces) or bash script wrappers. For simple functions, a bash script in `scripts/` works. For complex API integrations, set up an MCP server.

**Thread-based workflows break.** If your workflow depends on returning to a thread 3 days later, skills do not support this. Redesign: write state to files at the end of each session, and read state files at the start of the next session.

## Production Gotchas

OpenAI Assistants API is still in beta and has changed between v1 and v2. If your Assistant code uses v1 patterns (like the old `file_ids` field instead of the new `tool_resources`), update your understanding before migrating -- the Claude Code skill may need to mirror the latest functionality, not the legacy version.

Skills follow the agentskills.io open standard, which means your migrated skills also work in Codex, Gemini CLI, Cursor, and other compliant tools. This portability is not available with Assistants, making migration a one-time cost with multi-platform benefits.

## Checklist

- [ ] All Assistant instructions copied to SKILL.md body
- [ ] Tools mapped: code_interpreter, file_search, functions
- [ ] Attached files downloaded and saved to `references/`
- [ ] Frontmatter fields added (name, description, allowed-tools)
- [ ] Output tested and adjusted for Claude's response style

## Related Guides

- [Claude Skills vs OpenAI Assistants API](/claude-skills-vs-openai-assistants-api/) -- detailed capability comparison
- [Claude Skills vs MCP Servers](/claude-skills-vs-mcp-servers-comparison/) -- replacing function calling with MCP
- [Hybrid Patterns: Skills, MCP, and Custom Tools](/hybrid-patterns-skills-mcp-custom-tools/) -- combining tools for complex migrations

## See Also

- [Claude Skills vs OpenAI Assistants API Compared (2026)](/claude-skills-vs-openai-assistants-api-2026/)
