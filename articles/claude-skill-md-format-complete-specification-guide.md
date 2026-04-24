---
layout: default
title: "Claude Skill .md Format"
description: "Master the Claude skill .md file format with structure, placement, invocation, and body content rules. Includes working examples you can copy and adapt."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills, skill-format, markdown, reference]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-skill-md-format-complete-specification-guide/
geo_optimized: true
last_tested: "2026-04-21"
---

# Claude Skill .md Format: Complete Specification Guide

[Every Claude skill is a Markdown file](/best-claude-code-skills-to-install-first-2026/) The format is straightforward, but getting it wrong means your skill either fails silently or never fires. This guide covers every field and edge case.

What Is a Skill File?

A skill file is a plain Markdown document placed in `.claude/skills/` in your project (or `~/.claude/skills/` globally). Claude Code scans these directories and registers each `.md` file as a callable skill.

The format has two parts: [YAML front matter](/claude-skill-yaml-front-matter-parsing-error-fix/) between `---` delimiters, and a Markdown body that serves as the system prompt.

```
---
name: my-skill
description: Does something useful
---

You are a specialized assistant. When invoked, you will...
```

## Front Matter Fields

name (required): The canonical identifier. Used for manual invocation via `/skill-name`. Rules: lowercase, hyphens only, no spaces.

description (required): Human-readable explanation. Used for auto-invocation semantic matching. Write as a precise, complete sentence.

triggers (optional but strongly recommended): Array of phrase objects defining auto-invocation conditions. Without triggers, the skill only activates via explicit `/skill-name` invocation.

```yaml
triggers:
 - phrase: create a component
 - phrase: build a new page
 - phrase: design the UI for
```

Matching is semantic. "Can you design the login screen?" matches `design the UI for`.

## The Skill Body

Everything after the closing `---` is the skill body. This becomes the system prompt Claude receives when the skill is invoked.

Effective skill bodies:
1. State the role the skill plays
2. Define expected input format
3. Specify output format
4. Include constraints or guardrails
5. Provide 1-2 examples if non-obvious

Example for a tdd skill:

```
You are a test-driven development assistant. When given a feature description:

1. Write failing tests first (using the project test framework)
2. Write minimum implementation to pass those tests
3. Refactor implementation without changing tests

Always check existing test files for naming conventions.
Never write implementation before tests.

Output: test file(s), then implementation, then brief explanation.
```

## Injecting Project Context

Instruct the skill body to read specific files for project-specific context:

```
---
name: frontend-design
description: Builds React components using the project design system
---

At the start of every invocation, read:
- docs/design-tokens.md
- src/components/Button.tsx (as a reference example)

Build all components following the established patterns.
```

## File Placement and Loading Order

1. Built-in skills bundled with Claude Code
2. Global skills: `~/.claude/skills/*.md`
3. Project skills: `{project_root}/.claude/skills/*.md`

Later-loaded skills win on name conflicts. Project skills always override global skills with the same name.

## Optional Front Matter Fields

Beyond the required `name` and `description`, skill files support additional metadata:

tools (optional): Specify which Claude Code tools the skill should use. Without this field, Claude decides which tools to use based on the task.

```yaml
tools: [Read, Write, Bash, Glob]
```

model (optional): Override the default model for this skill if you want a faster or more capable model for specific tasks.

temperature (optional): Control response randomness. Lower values (0.0–0.3) produce more consistent, predictable output; higher values (0.7–1.0) allow more creativity.

## Writing Effective Skill Bodies

A few principles make skill bodies more effective:

- Be specific about inputs. Tell Claude exactly what to ask the user for if it's missing. Skills that silently guess at missing inputs produce inconsistent results.
- Describe the output format. Whether you want a markdown table, a numbered list, or a code block, state it explicitly.
- Define scope boundaries. What should the skill NOT do? A code-review skill that also rewrites your code is often unwanted. Add explicit "do not" constraints.
- Reference files by convention. If your skill depends on project-specific files, instruct Claude to read them at the start of every invocation rather than hardcoding their content.

## Common Mistakes

Missing triggers: Without triggers, users must invoke manually.

Overly broad trigger phrases: `- phrase: help me` matches almost everything.

Wrong directory: Files must be in `.claude/skills/` (not `.claude/skill/`).

## Trigger Phrase Design: Getting Auto-Invocation Right

Trigger phrases are the most misunderstood part of the format. Claude does semantic matching, not substring matching. That means you do not need to predict the exact words a user will type. you need to describe the intent.

Too narrow (misses real usage):
```yaml
triggers:
 - phrase: write jest test for component
```

Too broad (fires on unrelated requests):
```yaml
triggers:
 - phrase: write code
 - phrase: help me
```

Right-sized (matches the intent, not the wording):
```yaml
triggers:
 - phrase: write unit tests for this
 - phrase: add test coverage
 - phrase: TDD this feature
```

A good trigger phrase is 3–6 words that describe a specific action a user would want to accomplish. Test your triggers by asking yourself: "Would a developer who has never heard of this skill use phrasing close to this?" If yes, include it.

You can also stack multiple triggers to catch the same intent phrased different ways without making any single phrase too broad:

```yaml
triggers:
 - phrase: review this PR
 - phrase: review my pull request
 - phrase: check this diff
 - phrase: code review
```

## Complete Real-World Skill Examples

## Code Review Skill

```
---
name: code-review
description: Reviews staged changes or a specified file for correctness, style, and security issues
triggers:
 - phrase: review this code
 - phrase: check this file
 - phrase: code review
tools: [Read, Bash, Glob]
temperature: 0.2
---

You are a senior code reviewer. When invoked:

1. If a file path is provided, read that file. Otherwise, run `git diff --cached` to get staged changes.
2. Review for: logic errors, security issues (injection, hardcoded secrets, unsafe deserialization), style inconsistencies, missing error handling.
3. Do NOT rewrite the code unless explicitly asked to fix issues.

Output format:
- one sentence overall assessment
- Issues: numbered list, each with severity (critical / warning / suggestion) and line reference
- Positives: one or two things done well

If there are no issues, say so directly. Do not invent problems.
```

## Database Migration Skill

```
---
name: db-migrate
description: Generates a database migration file for a new table or schema change
triggers:
 - phrase: create a migration
 - phrase: add a database table
 - phrase: migrate the schema
tools: [Read, Write, Glob]
---

You are a database migration assistant. When invoked:

1. Ask for: table name, columns with types, any indexes or foreign keys needed.
2. Read `migrations/` to determine the naming convention and current highest migration number.
3. Generate a new migration file following the same naming pattern.
4. Output the full file content and the filename to use.

Constraints:
- Use only the migration library already present in the project (check package.json or requirements.txt).
- Do not add soft-delete columns unless the user requests them.
- Do not modify existing migration files.
```

## Commit Message Skill

```
---
name: commit
description: Writes a conventional commit message based on staged changes
triggers:
 - phrase: write a commit message
 - phrase: commit this
 - phrase: generate commit
tools: [Bash]
temperature: 0.1
---

You are a commit message writer. When invoked:

1. Run `git diff --cached --stat` to see which files changed.
2. Run `git diff --cached` to read the actual diff.
3. Write a conventional commit message: type(scope): short summary, followed by a blank line and a body paragraph if the change is non-trivial.

Allowed types: feat, fix, refactor, test, docs, chore, perf.
Keep the subject line under 72 characters.
Do not include "Co-Authored-By" lines unless the user asks.

Output: just the commit message, ready to paste.
```

## Advanced Front Matter: Tools and Model Control

The `tools` field limits which Claude Code tools the skill can access. This matters for two reasons: security (a documentation skill has no reason to run Bash) and predictability (scoping tools reduces unexpected behavior).

```yaml
---
name: doc-writer
description: Writes or updates documentation for a function or module
tools: [Read, Write, Glob]
---
```

If you omit `tools`, Claude decides at runtime which tools to use. For most skills this is fine. For skills operating on sensitive files or production systems, explicit scoping is safer.

The `model` field lets you pin a specific model:

```yaml
---
name: quick-summary
description: Summarizes the current file in one paragraph
model: claude-haiku-4-5
---
```

Use a faster, cheaper model for skills that do lightweight tasks (summarize, rename, format). Reserve the default frontier model for skills that require multi-step reasoning, security review, or complex code generation.

The `temperature` field controls how deterministic the output is. For any skill that generates code, SQL, or structured output you want to reproduce consistently, set it low:

```yaml
temperature: 0.1
```

For skills that write prose, brainstorm names, or generate creative content, a higher value gives more varied output:

```yaml
temperature: 0.8
```

## Injecting Dynamic Context at Invocation Time

The skill body is a static document, but you can instruct it to pull fresh context on every run. This is how you keep skills project-aware without hardcoding project details into the skill file itself.

```
---
name: api-handler
description: Generates a new API route handler following project conventions
triggers:
 - phrase: add an API route
 - phrase: create an endpoint
---

At the start of every invocation:
1. Read `src/routes/` to understand existing route structure.
2. Read `src/middleware/auth.ts` to understand how authentication is applied.
3. Read `docs/api-conventions.md` if it exists.

Then generate the new route handler matching the patterns you found.
Ask the user for: HTTP method, path, and what the endpoint should do.
```

This pattern is far more resilient than embedding project knowledge directly in the skill body. When conventions change, developers update one source-of-truth file, not the skill.

## Validating Your Skill

Invoke directly to test:

```
/your-skill-name test this
```

If the skill does not respond as expected, check: file is in `.claude/skills/` (not `.claude/skill/`), YAML parses cleanly, and the name uses only lowercase letters and hyphens.

YAML parse errors are the most common failure mode. The YAML block must be valid: strings with colons need quotes, arrays must use proper list syntax, and there must be no tabs (use spaces only). Validate with any online YAML linter before saving.

Silent non-invocation usually means a trigger phrase is too narrow or the file is in the wrong directory. Run `/your-skill-name directly` to confirm the skill is loaded at all. If that works, the trigger matching is the issue.

Unexpected tool use (or refusal to use a tool) is typically a `tools` field mismatch. If you scoped tools and the skill needs one you excluded, it will fail silently. If you see the skill reaching for a tool you did not expect, add an explicit "do not use X" line in the body.

## Skill Naming Conventions Worth Adopting

A consistent naming scheme across a project or team makes skills easier to discover and less likely to conflict:

- Use a verb-noun pattern: `review-pr`, `generate-migration`, `write-test`
- Scope by domain when you have many skills: `db-migrate`, `db-seed`, `db-rollback`
- Keep names under 30 characters. long names are awkward to type manually
- Never reuse a name across project and global scopes unless you intend the project version to override the global one

For teams, document all skill names in a single `SKILLS.md` at the project root. Claude will not surface a skill list to users unless you build that explicitly.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-skill-md-format-complete-specification-guide)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Skill .md File Format Explained With Examples](/claude-skill-md-format-complete-specification-guide/)
- [How to Write a Skill .md File for Claude Code](/how-to-write-a-skill-md-file-for-claude-code/)
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/)

Built by theluckystrike - More at [zovo.one](https://zovo.one)


