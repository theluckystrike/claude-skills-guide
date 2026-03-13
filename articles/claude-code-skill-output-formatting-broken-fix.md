---
layout: default
title: "Claude Code Skill Output Formatting Broken Fix"
description: "Fix broken output formatting in Claude Code skills. Covers markdown rendering, code block problems, instruction mismatches, and terminal vs. IDE display."
date: 2026-03-13
author: theluckystrike
---

# Claude Code Skill Output Formatting Broken Fix

Your Claude Code skill is producing output, but the formatting is wrong — code blocks render as plain text, markdown headings appear literally, lists collapse into one line, or the output structure does not match what the skill is supposed to produce. This guide covers every known cause of broken output formatting in Claude Code skills and gives you the fix.

## Understanding Output Formatting in Claude Code

Claude Code renders output differently depending on the context:

- **Terminal (non-interactive)** — raw text, markdown symbols visible
- **Terminal (interactive/iTerm2/Windows Terminal)** — partial markdown rendering
- **VS Code extension** — full markdown rendering
- **`--print` flag (piped output)** — plain text, no ANSI codes

If the same skill output looks correct in one context and broken in another, it is a rendering environment issue, not a skill issue. If it looks wrong everywhere, the skill instructions are producing the wrong output structure.

## Problem 1: Markdown Appearing as Raw Symbols

**Symptom:** You see `**bold**` instead of **bold**, `# Heading` as literal text, or `- item` not rendering as a bullet.

**Cause A: Running in a plain terminal without markdown rendering**

Claude Code outputs markdown-formatted text. If your terminal does not render markdown (most terminals do not by default), you see raw symbols.

**Fix — use the VS Code extension or a markdown-aware terminal.**

For terminal use, update your skill to produce plain text output instead:

```markdown
## Output Format
Write all output as plain text. Do not use markdown formatting.
Use CAPITALIZED WORDS for emphasis instead of asterisks.
Use numbered lists (1. 2. 3.) and hyphens for structure.
```

**Cause B: The skill file itself uses inconsistent formatting**

If the skill instructions mix markdown and plain text guidance, Claude produces mixed output. Keep the output format instruction unambiguous.

## Problem 2: Code Blocks Not Rendering Correctly

**Symptom:** Code inside backtick blocks appears with extra whitespace, wrong indentation, or without syntax highlighting.

**Cause: Language tag missing from fenced code block instruction**

If the skill does not specify language tags in its output instructions, Claude may omit them:

```markdown
# Bad — skill output produces:
```
const x = 1
```

# Good — skill output produces:
```javascript
const x = 1
```
```

**Fix — add explicit language tag instructions to the skill:**

```markdown
## Code Output Rules
Always use fenced code blocks with a language identifier:
- JavaScript/TypeScript → ```typescript
- Python → ```python
- Shell commands → ```bash
- JSON → ```json
Never use unlabeled fenced blocks.
```

## Problem 3: `tdd` Skill Tests Formatted Incorrectly

The `tdd` skill generates test code. If the test output is missing structure — tests not separated, assertions run together, describe blocks collapsed — the skill instructions likely do not specify the test format.

**Check what your `tdd.md` says about output format:**

```bash
grep -A 10 "format\|structure\|output" ~/.claude/skills/tdd.md
```

**Fix — add explicit test structure instructions:**

```markdown
## Test Output Format
Generate test files using this structure:
- One describe block per class or module
- One it/test block per behavior
- Each test block on its own line with blank lines between tests
- Import statements at the top of the file
- Follow the existing test file style in this project
```

## Problem 4: `pdf` Skill Output Losing Table Structure

When using the `pdf` skill to extract tables from PDFs, the output may lose column alignment or render as comma-separated text instead of a structured table.

**Fix — specify markdown table output explicitly:**

```
/pdf
Extract the pricing table from page 12 of catalog.pdf.
Format the output as a markdown table with | separators.
Preserve all column headers and row values exactly.
```

Or for plain-text output in environments that do not render markdown tables:

```
/pdf
Extract the pricing table. Format as tab-separated values (TSV)
with one row per line and headers on the first row.
```

## Problem 5: `docx` Skill Output Losing Heading Hierarchy

The `docx` skill parsing a Word document may flatten headings — converting H1, H2, H3 to the same level, or stripping heading markers entirely.

**Fix — instruct the skill to preserve hierarchy:**

```
/docx
Parse contract.docx and preserve the full heading hierarchy.
Use # for H1, ## for H2, ### for H3 in the output.
Maintain the original document structure.
```

## Problem 6: `frontend-design` Skill Generating Invalid JSX

The `frontend-design` skill may generate JSX or TSX with formatting problems: missing semicolons, inconsistent indentation, or props formatted incorrectly for your linter configuration.

**Fix — add formatter instructions to the skill:**

```markdown
## Code Style
All generated JSX/TSX must:
- Use 2-space indentation
- Use double quotes for JSX attributes
- Have a trailing newline
- Pass ESLint with project config (eslint.config.js)
After generating code, run: npx eslint --fix {filename}
```

## Problem 7: `supermemory` Reading Back Corrupted Entries

If `supermemory` stored entries with broken formatting (e.g., markdown inside a JSON value field), reading them back may produce garbled output.

**Check the raw store:**

```bash
ls ~/.claude-memory/
cat ~/.claude-memory/latest.json 2>/dev/null | python3 -m json.tool
```

**Fix — purge and re-write the corrupted entries:**

```
/supermemory
Delete all entries for project X.
```

Then re-build with clean entries. Going forward, instruct `supermemory` to store entries as plain text without embedded markdown:

```
/supermemory
Save checkpoint: [description as plain text, no markdown formatting]
```

## Problem 8: Output Truncated Mid-Way

If skill output consistently gets cut off before completing — lists that end abruptly, code blocks that do not close — the cause is usually hitting the response length limit.

**Fix — break the task into smaller output chunks:**

```
/tdd
Generate tests for UserService only.
Do not generate tests for any other class in this request.
```

Or ask for structured output with explicit completion markers:

```
/frontend-design
Generate the Button component only.
End your response with: <!-- DONE -->
```

If you do not see the `<!-- DONE -->` marker, the output was truncated. Request the remainder:

```
Continue from where you stopped. Start from the line after the last complete closing tag.
```

## Problem 9: Mixed Output Format (Some Markdown, Some Plain Text)

This happens when the skill instructions give formatting guidance that Claude applies inconsistently — usually because the instructions say "use markdown for X" without specifying what to do for Y.

**Fix — cover all output types explicitly in the skill:**

```markdown
## Output Format Rules
- Section headers: use ## markdown headings
- Code: always use fenced blocks with language tags
- Lists: use - for unordered, 1. for ordered
- Inline emphasis: use **bold** and `code` (not CAPS or quotes)
- File paths: always wrap in backticks
- Command output: always wrap in a bash fenced block
```

## Verifying Your Fix

After updating skill instructions, test with a controlled output request:

```
/tdd
Generate a single test for a function called `add(a, b)` that returns a+b.
Use Jest syntax.
```

The output should be a properly formatted Jest test in a typescript code block. If it is not, review the skill output format instructions.

---

## Related Reading

- [Skill .md File Format Explained With Examples](/claude-skills-guide/articles/skill-md-file-format-explained-with-examples/) — The skill body section is where output format instructions live; this guide shows annotated examples of well-structured format specifications
- [How to Write a Skill .md File for Claude Code](/claude-skills-guide/articles/how-to-write-a-skill-md-file-for-claude-code/) — Covers how to write clear output format instructions as part of authoring a skill from scratch
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) — Precise output format instructions reduce retries and wasted tokens from malformed responses

Built by theluckystrike — More at [zovo.one](https://zovo.one)
