---
layout: default
title: "Claude Skill Metadata Header vs Full Body Loading: What Gets Loaded When"
description: "Understand how Claude skills load metadata versus the full body, and when each component matters for performance and functionality."
date: 2026-03-14
author: theluckystrike
---

# Claude Skill Metadata Header vs Full Body Loading

When you invoke a Claude skill with `/skill-name`, the system loads different components at different times. Understanding the distinction between skill metadata (the header/front matter) and the full skill body directly impacts how you design, organize, and optimize your custom skills. This guide breaks down what gets loaded when, and why it matters for your workflow.

## What Is Skill Metadata?

Skill metadata lives in the YAML front matter at the top of your skill file. This is the section between the `---` delimiters that contains structured information about the skill:

```yaml
---
name: pdf-editor
description: Edit and manipulate PDF documents
version: 1.2.0
tags: [documents, pdf, manipulation]
author: yourname
permissions: [file-read, file-write]
---
```

This metadata serves several purposes. First, it provides search and discovery capabilities when browsing available skills. Second, it defines configuration parameters like version, author, and required permissions. Third, it enables skill management operations such as listing, filtering, and updating skills programmatically.

The metadata loads immediately when Claude initializes your skill session. This means essential information like the skill name, description, and permissions are available before the full skill body executes.

## What Is the Skill Body?

The skill body is everything after the closing `---` in your markdown file. This is the actual content that becomes the system prompt when the skill runs:

```markdown
---
name: tdd-helper
description: Assist with test-driven development workflows
---

# TDD Helper Skill

You are a test-driven development assistant. When the user shares code:

1. First, write failing tests that specify expected behavior
2. Then implement the minimum code to pass those tests
3. Finally, refactor while keeping tests green

Always ask clarifying questions before writing tests.
```

The body contains the actual instructions, prompts, examples, and guidance that Claude follows during the skill session. This is where you define the skill's behavior, persona, and specific workflows.

## When Each Component Loads

The loading sequence matters for performance and behavior:

1. **Metadata loads first** — When you invoke `/skill-name`, Claude's skill system parses the front matter immediately. This happens during session initialization and is fast because it's just YAML parsing.

2. **Body loads on execution** — The full skill body loads when the skill actually executes. This involves reading the markdown file, processing any includes or references, and constructing the system prompt.

For built-in skills like `frontend-design`, `pdf`, or `pptx`, the system optimizes this process. The metadata helps quickly determine if the skill is applicable to your request before loading the full body.

## Why the Distinction Matters

### Performance Optimization

Large skills with extensive documentation, examples, or reference material benefit from separating metadata from body content. The system can quickly filter skills by metadata before committing to loading heavy content.

Consider a skill like `supermemory` that includes hundreds of example queries and response patterns. By keeping the core instructions lean and placing extensive examples in a separate file referenced by the body, you maintain fast initialization while still providing rich context when needed.

### Skill Discovery and Filtering

Metadata enables powerful skill management:

```bash
# List skills by author
/skills list --author theluckystrike

# Find skills with specific tags
/skills list --tags "pdf,documents"

# Check skill permissions before invocation
/skills info pdf-editor
```

This metadata-driven approach means you can find the right skill without loading every skill's full body content.

### Permission and Security Boundaries

The metadata section declares required permissions explicitly:

```yaml
---
name: file-operations
permissions: [file-read, file-write, bash-execute]
---
```

This allows Claude to validate permission boundaries before executing potentially destructive operations. The body might contain additional guidance, but the permissions are checked against metadata first.

## Practical Examples

### Example 1: Minimal Skill with Clear Metadata

```yaml
---
name: sql-formatter
description: Format and validate SQL queries
version: 1.0.0
tags: [sql, database, formatting]
---

Format SQL queries according to these rules:
- UPPERCASE keywords
- Indent joins and subqueries
- Use trailing commas for columns
- Add comments for complex logic
```

The metadata tells you exactly what the skill does. The body contains only the essential instructions.

### Example 2: Rich Skill with Extended Body

```yaml
---
name: api-documentation
description: Generate API documentation from code
version: 2.1.0
tags: [api, documentation, openapi, swagger]
---

# API Documentation Generator

You generate OpenAPI 3.0 documentation from code.

## Supported Frameworks
- Express.js
- FastAPI
- Flask
- Spring Boot

## Output Format
Always produce valid OpenAPI YAML with:
- Operation summaries from route names
- Request/response schemas
- Example payloads

[Extended examples and patterns follow...]
```

Here, the metadata provides quick filtering capability while the body contains the detailed guidance.

### Example 3: Conditional Loading with Includes

Some skills reference external files for extended content:

```yaml
---
name: tdd-guide
description: Comprehensive TDD methodology guide
---

# Test-Driven Development Guide

Follow the principles in /reference/tdd-principles.md

For JavaScript projects, use the patterns in /examples/js-tdd.js
```

This pattern keeps the core skill file manageable while allowing access to extensive reference material when needed.

## Best Practices for Skill Authors

### Keep Metadata Accurate

Ensure your metadata reflects what the skill actually does. Misleading descriptions frustrate users and break trust in skill discovery.

### Separate Core Instructions from Examples

Put essential instructions directly in the body. Move extensive examples, templates, and reference material to separate files or use the skill's include mechanism if available.

### Use Descriptive Tags

Tags like `pdf`, `pptx`, `xlsx`, `tdd`, `frontend-design` help users find your skill. Use consistent naming across your skill library.

### Version Your Skills

Increment the version in metadata when you update behavior. This helps users track changes and allows the system to identify outdated skills.

## Common Mistakes to Avoid

**Putting critical instructions only in metadata.** Metadata is for discovery and configuration, not behavior. Always include core instructions in the body.

**Ignoring the permissions field.** Explicit permissions protect users and prevent unexpected behavior.

**Overloading the body with everything.** If your skill body exceeds a few hundred lines, consider splitting into a core skill and reference files.

## Conclusion

Understanding the distinction between skill metadata and the full skill body helps you build better, more maintainable Claude skills. Metadata drives discovery and configuration while the body defines actual behavior. Design each component with its purpose in mind, and your skills will be more discoverable, performant, and maintainable.

For skills like `pdf` that handle complex document operations, or `tdd` that guide development workflows, this separation allows the system to quickly determine skill applicability while providing rich, detailed guidance when executing.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
