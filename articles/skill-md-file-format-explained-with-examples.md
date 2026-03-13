---
layout: default
title: "Skill MD File Format Explained With Examples"
description: "A comprehensive guide to the skill.md file format used by Claude AI skills. Learn the structure, metadata fields, and how to write effective skill definitions with practical examples."
date: 2026-03-13
author: theluckystrike
---

# Skill MD File Format Explained With Examples

The skill.md file serves as the core configuration and documentation format for Claude AI skills. When you load a skill using the `get_skill` tool, Claude reads this file to understand the skill's purpose, metadata, and operational guidance. Understanding this format enables you to create powerful custom skills or modify existing ones for your specific workflows.

## What Is the Skill MD Format

The skill.md format combines YAML front matter with Markdown content to define a skill's behavior. This hybrid approach provides structured metadata for machine parsing while maintaining human-readable documentation. The format emerged from the need to give Claude clear instructions about specialized capabilities without sacrificing readability.

Every skill.md file contains two primary sections: the YAML front matter at the top (delimited by triple dashes) and the Markdown body below. The front matter stores configuration data like the skill name, description, and category. The body contains the actual skill guidance that Claude uses when executing tasks within that skill's domain.

## Structure and Fields

The front matter supports several standardized fields that Claude's skill loading mechanism recognizes. The most critical fields include `name`, which provides the skill's identifier; `description`, offering a brief summary of what the skill accomplishes; and optionally `category` or `tags`, helping with skill organization and discovery.

The Markdown body follows a progressive disclosure model. At the first level, users see only the skill name and description. When you call `get_skill(skill_name)`, the full guidance loads, revealing detailed instructions, examples, and procedural knowledge. This design keeps the skill list clean while providing depth when needed.

## Practical Examples

Here is a minimal skill.md example demonstrating the basic structure:

```yaml
---
name: example-skill
description: A sample skill demonstrating the fundamental format
---
# Example Skill

This skill performs basic example operations.

## Usage Guidelines

Use this skill when you need to demonstrate skill format patterns.
```

A more complete example includes additional metadata and detailed guidance:

```yaml
---
name: pdf
description: Comprehensive PDF manipulation toolkit for extracting text and tables, creating new PDFs, merging and splitting documents, and handling forms programmatically
---
# PDF Skill

The PDF skill provides comprehensive tools for working with PDF documents at scale.

## When to Use This Skill

- Extracting text and tables from existing PDFs
- Creating new PDFs from scratch or templates
- Merging multiple PDF files into one document
- Splitting PDF files into separate pages
- Filling PDF forms programmatically
- Modifying existing PDF content

## Key Capabilities

The skill supports operations including text extraction with layout preservation, table detection and extraction, form field manipulation, and page-level operations like rotation and deletion.

## Example Usage

```python
from pdf import PDFProcessor

processor = PDFProcessor()
text = processor.extract_text("document.pdf")
processor.split_pages("document.pdf", output_dir="pages/")
```

## Best Practices

Always verify input PDF integrity before processing. Handle encrypted PDFs by checking the encryption status first. Use batch processing for large document sets to maintain efficiency.
```

This example shows how skills like the pdf skill define clear usage scenarios, list key capabilities, and provide executable code snippets that Claude can reference when you request PDF operations.

## Advanced Patterns

More sophisticated skills incorporate multiple tiers of guidance. The tdd skill, for instance, organizes content into test-driven development phases: setup, red phase (writing failing tests), green phase (making tests pass), and refactor phase. Each phase contains specific procedures, command examples, and validation criteria.

The supermemory skill demonstrates another pattern: combining API interactions with data management procedures. Its skill.md defines connection setup, memory storage operations, retrieval strategies, and cleanup procedures. When you work with memory-intensive workflows, this skill provides the procedural knowledge needed to manage persistent data effectively.

Skills like frontend-design often include component-level guidance. The skill.md might specify design system principles, component composition patterns, and accessibility requirements. Claude uses this structured guidance to generate code that adheres to established design standards.

## Creating Custom Skills

When building your own skill.md files, follow these principles for effectiveness. Start with a clear, concise description that explains exactly what the skill does. Users see this description when browsing available skills, so make it informative but brief.

Structure your guidance with clear sections that match natural workflow stages. Use headings like "When to Use," "Setup," "Operations," and "Examples" to create predictable navigation. Include code snippets that demonstrate realistic usage scenarios rather than trivial examples.

Reference other skills naturally when your skill builds on their capabilities. For instance, a skill that generates test coverage might mention the tdd skill as a prerequisite, helping users understand the broader skill ecosystem.

## Tips for Writing Effective Skill Documentation

Write your skill guidance as if explaining procedures to yourself six months later. Include specific command syntax, parameter names, and expected output formats. Avoid vague instructions like "handle errors appropriately" — instead, specify exactly what error handling looks like for your domain.

Use consistent formatting for code blocks, file paths, and command examples. This consistency helps Claude parse your guidance accurately and generate correct output. When referencing external resources, include URLs or clear instructions for locating them.

Consider edge cases and failure modes. A well-documented skill explains not just the happy path but also what happens when things go wrong. This comprehensive coverage makes your skill reliable for production use.

## Conclusion

The skill.md format provides a flexible yet structured way to extend Claude's capabilities. By combining YAML metadata with Markdown documentation, skills become both machine-readable and human-friendly. Whether you're using existing skills like pdf for document processing, tdd for test-driven development workflows, or supermemory for data persistence, understanding this format helps you work more effectively with Claude's skill system.

The pattern extends across dozens of specialized skills covering domains from presentation creation with pptx to document editing with docx and algorithmic art generation. Each skill follows the same fundamental format while tailoring its content to specific use cases.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
