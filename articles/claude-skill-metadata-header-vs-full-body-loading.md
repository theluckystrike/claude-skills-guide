---
layout: default
title: "Claude Skill Metadata Header vs Full"
description: "Understand how Claude skills load metadata versus the full body, and when each component matters for performance and functionality."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, claude-skills, skill-authoring, front-matter]
reviewed: true
score: 8
permalink: /claude-skill-metadata-header-vs-full-body-loading/
geo_optimized: true
---

# Claude Skill Metadata Header vs Full Body Loading

[invoke a Claude skill with `/skill-name`](/claude-skills-auto-invocation-how-it-works/), Claude reads the entire `.md` file from `~/.claude/skills/`. There is no separate metadata-only loading phase. the front matter and the skill body load together. This guide explains what belongs in each section and how to structure skills for clarity.

What Is Skill Metadata?

Skill metadata lives in the YAML front matter at the top of your skill file. [only recognized front matter fields](/claude-skill-yaml-front-matter-parsing-error-fix/):

```yaml
---
name: pdf-editor
description: Edit and manipulate PDF documents
---
```

These two fields identify the skill. Fields like `version`, `tags`, `author`, `permissions`, `tools`, and `auto_invoke` are not recognized by Claude Code. Do not add them. they have no effect and can mislead readers.

The `name` field determines how you invoke the skill. If `name` is `pdf-editor`, you type `/pdf-editor` to activate it. The `description` is a short plain-text summary that helps you remember what the skill does when you browse your skills directory. It does not get passed to the model as a special instruction. it becomes part of the body content Claude reads, but it holds no privileged status.

Keep both fields concise. A name like `git-commit-message-generator-with-conventional-commits-support` works technically but is painful to type. Prefer short, memorable identifiers. The description can be one sentence; it does not need to be comprehensive documentation.

What Is the Skill Body?

The skill body is everything after the closing `---` in your Markdown file. This content becomes part of the context when the skill runs:

```markdown
---
name: tdd-helper
description: Assist with test-driven development workflows
---

TDD Helper Skill

You are a test-driven development assistant. When the user shares code:

1. First, write failing tests that specify expected behavior
2. Then implement the minimum code to pass those tests
3. Finally, refactor while keeping tests green

Always ask clarifying questions before writing tests.
```

The body contains the instructions, examples, and guidance that shape Claude's behavior during the skill session. This is where you define what the skill does and how it operates.

Unlike system prompts in API usage, the skill body is not injected into a privileged position in the conversation. it is read as context, much like any other document. This matters for how you write it. Imperative instructions work well. Long preambles and marketing language do not. Claude responds best to clear, direct prose that describes the task, the constraints, and any specific output format required.

The body can include Markdown structure: headings, bullet lists, numbered steps, code blocks, and tables. Claude uses these structural cues when interpreting instructions. A well-organized body is easier for Claude to follow than a wall of unformatted text.

## When the Skill Loads

When you type `/skill-name` in a Claude Code session, Claude reads the complete file. front matter and body together. There is no separate initialization phase that parses metadata before the body.

[Skills are discovered by filename](/how-do-i-know-which-claude-skill-is-currently-active/). Typing `/my-skill` looks for `~/.claude/skills/my-skill.md`. There is no search registry and no CLI command to list or filter skills. To see what skills are available, list the files in your skills directory:

```bash
ls ~/.claude/skills/
```

Because loading is synchronous and complete, the moment you invoke a skill, the entire file is already in context. You cannot defer loading of optional sections or conditional branches. Everything in the file. all the examples, all the reference tables, all the inline documentation. loads every time, whether relevant to the current task or not.

This has an important implication: skills are not modules you can compose at runtime. They are static documents. If you want to combine two skill behaviors, you either write a new skill that includes both, or you accept that you will invoke them separately and direct Claude to maintain context between invocations manually.

## Why the Distinction Matters

## Keeping Skills Focused

The front matter should be minimal. just `name` and `description`. The body should contain everything Claude needs to perform the task. A common mistake is trying to configure behavior through front matter fields that Claude Code does not recognize.

For example, a skill like `/[maintains project context](/building-stateful-agents-with-claude-skills-guide/) about how to store and retrieve memories in the body:

```markdown
---
name: supermemory
description: Maintain persistent context and memory across Claude Code sessions
---

Supermemory Skill

You help maintain project context across sessions. When invoked:

1. Ask what the user wants to remember or retrieve
2. Store important decisions, architectural choices, and conventions
3. Reference stored context when answering questions about the project

Keep memories concise and organized by topic.
```

This works because the behavior is entirely defined in the body. Adding `auto_invoke: true` to the front matter would accomplish nothing. Claude Code does not read that field.

## Body Length and Performance

[Large skill bodies consume more context tokens](/claude-md-too-long-context-window-optimization/) at each turn. To keep skills manageable:

- Put only the instructions Claude needs in the skill body
- Move reference material to separate files and instruct Claude to read them when needed using the `Read` tool
- Break very large workflows into smaller, focused skills

The token budget matters in practice. A skill body with 200 lines of examples consumes context at every turn of the conversation, leaving less room for the actual work being done. If your skill body contains lengthy lookup tables, API reference lists, or multi-page templates, consider whether all that content is needed at invocation time or only occasionally.

A pattern that works well for large skills: keep the core instructions concise in the skill body, then instruct Claude to read a companion file when it needs detailed reference material.

```markdown
---
name: openapi-generator
description: Generate OpenAPI specifications from code
---

OpenAPI Generator

Generate OpenAPI 3.0 YAML specifications from route handlers and controllers.

When you need field-by-field reference for OpenAPI properties, read:
~/.claude/skills/references/openapi-3.0-field-reference.md

Core Workflow

1. Identify all route handlers in the provided code
2. Extract HTTP methods, paths, parameters, and response shapes
3. Generate a complete OpenAPI 3.0 YAML document

Always validate the output structure before presenting it.
```

This keeps the invocation-time token cost low while giving Claude access to detailed reference material on demand.

## The Role of the H1 Heading

Including an H1 heading at the start of the skill body is a common convention and a useful one, but it is not required. The heading orients Claude to the skill's purpose and provides a natural landmark when you read the file yourself. In the body, it functions as context. telling Claude "this skill is called X and its purpose is Y."

If you omit the H1, the skill still works. But the heading adds clarity both for Claude and for human readers reviewing the skill later. Think of it as documentation within the skill itself.

## Practical Examples

A minimal skill with a clear, focused body:

```markdown
---
name: sql-formatter
description: Format and validate SQL queries
---

Format SQL queries according to these rules:
- UPPERCASE keywords
- Indent joins and subqueries
- Use trailing commas in column lists
- Add inline comments for complex logic
```

A skill with extended body content for a richer workflow:

```markdown
---
name: api-documentation
description: Generate API documentation from code
---

API Documentation Generator

Generate OpenAPI 3.0 documentation from code.

Supported Frameworks
- Express.js
- FastAPI
- Flask
- Spring Boot

Output Format
Always produce valid OpenAPI YAML with:
- Operation summaries from route names
- Request/response schemas
- Example payloads
```

Notice that both examples put all behavior in the body. Neither tries to declare supported frameworks or output format in front matter. because front matter cannot convey that information to Claude Code.

## Comparing Structure Approaches

Here is a side-by-side view of effective versus ineffective skill structure:

| Aspect | Effective | Ineffective |
|--------|-----------|-------------|
| Front matter fields | `name`, `description` only | Extra fields like `version`, `tags`, `tools` |
| Behavior definition | In the Markdown body | Attempted in front matter |
| Instructions | Direct, imperative prose | Vague marketing language |
| Reference material | External file, loaded on demand | Embedded tables for every edge case |
| Skill scope | Single, well-defined task | Catch-all for many unrelated workflows |
| Body length | Under 100 lines for most skills | Hundreds of lines of inlined examples |

This does not mean skills must be tiny. A complex workflow can justify a longer body. But every line should earn its place. If you find yourself writing generic content that applies to any task rather than this specific skill, cut it.

## Authoring Skills for Clarity and Longevity

Well-structured skills are easier to maintain. When you return to a skill file six months later, a clear body with organized sections is much easier to update than a wall of undifferentiated instructions.

A few conventions that improve skill maintainability:

Use headings to organize the body. If a skill has multiple phases. discovery, transformation, validation, output. use Markdown headings to separate them. This makes it easy to update one phase without accidentally touching another.

Put constraints and edge cases in a dedicated section. Rather than scattering caveats throughout the instructions, collect them under a "Constraints" or "Important Rules" heading at the end of the body. This makes them visible without interrupting the main workflow.

Write the description as if explaining to a colleague. The description field appears when you list your skills directory. A description like "Helps with code" tells you nothing. A description like "Review pull request diffs and suggest improvements following the team's style guide" gives you what you need to remember why the skill exists.

Test with a minimal body first. When authoring a new skill, start with three to five lines in the body and invoke it to verify the basic behavior works. Then expand incrementally. This approach makes it easier to identify which additions actually change Claude's behavior versus which are just noise.

## Best Practices for Skill Authors

Keep front matter minimal. Use only `name` and `description`. Any additional fields are ignored.

Put all behavior in the body. Instructions, examples, rules, and context all belong in the Markdown body, not in front matter.

Separate core instructions from reference material. Put essential instructions directly in the body. Reference external files for examples and templates by instructing Claude to read them with `Read`.

Keep the body focused. A skill that does one thing well is easier to invoke correctly than one that handles every possible case. If a skill covers too many scenarios, split it into multiple focused skills.

Name skills for their action. Names like `format-sql`, `review-pr`, and `generate-tests` are clear and memorable. Names like `my-skill-v2-final` are not.

Use consistent naming conventions across your skills. If you use hyphens in one skill name (`sql-formatter`), use them in all skill names. Mixing conventions (`sqlFormatter`, `sql_formatter`, `sql-formatter`) creates confusion when you are trying to remember which name to type.

## Common Mistakes to Avoid

Adding unsupported front matter fields. Fields like `version`, `tags`, `permissions`, `auto_invoke`, and `tools` are not recognized. They do nothing.

Putting behavior in front matter. The body defines what Claude does. Front matter is for identification only.

Making skills too large. Skills that load hundreds of lines of examples for every invocation consume context unnecessarily. Use external file references for non-essential content.

Writing vague instructions. "Help with code" is not a useful instruction. "Review the provided code for correctness, performance, and readability, then list specific improvements as numbered suggestions" is.

Duplicating logic across skills. If multiple skills share the same foundational rules, extract those rules into a shared reference file and have each skill instruct Claude to read it. Duplication means you will need to update multiple files whenever the rules change.

Creating skills for one-time tasks. Skills shine for recurring workflows. If you need something done once, just ask Claude directly. Skills are worth authoring when the workflow is complex, repeatable, or requires specific constraints that are easy to forget.

## Conclusion

Claude Code skills have a simple structure: minimal front matter with `name` and `description`, followed by a Markdown body with all instructions. The entire file loads when you invoke the skill. There is no complex metadata system, no permission declarations, and no separate loading phases. Design each section with this in mind, and your skills will be clear, correct, and maintainable.

The front matter identifies the skill. The body defines its behavior. Everything else. version numbers, tags, permissions. belongs outside the skill file entirely, in a README or team documentation. Keep this separation clear and your skill library will stay organized as it grows.

---

---

<div class="mastery-cta">

I've tried them all. Claude Code wins — but only if you set it up right.

The gap isn't the tool. It's the CLAUDE.md, the prompts, the workflow. I run 5 Claude Max subscriptions in parallel with autonomous agent fleets. These are my actual configs — the ones that let a solo dev outproduce a small team.

**[See the full setup →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-compare&utm_campaign=claude-skill-metadata-header-vs-full-body-loading)**

$99. Once. Everything I use to ship.

</div>

Related Reading

- [How Do I Test a Claude Skill Before Deploying to Team](/how-do-i-test-a-claude-skill-before-deploying-to-team/). Validate skill structure and behavior before sharing with teammates
- [Open Source Claude Skills Ecosystem Outlook 2026](/open-source-claude-skills-ecosystem-outlook-2026/). How community skills are structured and shared
- [Claude Skills Getting Started Hub](/getting-started-hub/). Start with the basics of skill authoring and invocation

Built by theluckystrike. More at [zovo.one](https://zovo.one)


