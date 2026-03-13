---
layout: default
title: "Claude Skills Directory: Where to Find Skills"
description: "Discover where to find Claude skills, how to access the official directory, and how to use community-built skills for enhanced AI assistance."
date: 2026-03-13
author: theluckystrike
---

# Claude Skills Directory: Where to Find Skills

Finding the right Claude skills for your workflow can significantly enhance your productivity as a developer or power user. This guide walks you through the available directories, repositories, and methods for discovering and accessing skills that match your needs.

## Official Claude Skills Locations

Claude Code ships with a curated collection of built-in skills that cover common development tasks. These official skills live within the Claude desktop application and are automatically available when you start a session. The primary skills include **pdf** for document manipulation, **docx** for Word document handling, **pptx** for presentations, and **xlsx** for spreadsheet operations.

These skills load dynamically when needed, following a progressive disclosure model. At the first level, you see skill names and descriptions in your startup context. At the second level, you can load a skill's complete guidance using the `get_skill()` function. Some skills even provide additional resources and scripts at deeper levels.

For example, to access the PDF skill documentation, you would use:

```bash
get_skill(skill_name="pdf")
```

This command loads the complete guidance for working with PDF files, including extraction methods, form filling, and document generation capabilities.

## Community Repository Access

The Claude skills ecosystem extends far beyond built-in skills through community contributions. The primary community repository at [github.com/anthropics/claude-code](https://github.com/anthropics/claude-code) contains dozens of user-submitted skills covering specialized domains.

When exploring community skills, you'll find categories including:

- **Development tools**: Skills for specific frameworks and languages
- **Data processing**: Skills for working with various file formats
- **Design utilities**: Skills for visual design and theming
- **Productivity enhancers**: Skills for documentation and communication

To use a community skill, you typically clone the repository and configure your local environment to recognize the skill files. Most community skills follow the skill-md format, which uses YAML front matter to define metadata and capabilities.

## Finding Skills by Use Case

Different tasks require different skills. Here's a practical breakdown of where to look based on your needs:

### Document Processing

For PDF operations beyond basic extraction, the **pdf** skill handles complex tasks like form filling, multi-document merging, and table extraction. The **docx** skill manages Microsoft Word documents with support for tracked changes, comments, and formatting preservation. If you need to create presentations programmatically, the **pptx** skill provides comprehensive PowerPoint manipulation.

### Spreadsheet and Data Work

The **xlsx** skill serves as your primary tool for spreadsheet operations. It supports formula creation, data visualization, and preserves existing formulas during edits. This skill handles CSV, TSV, and XLSX formats, making it versatile for data migration and reporting tasks.

### Frontend Development

The **canvas-design** skill generates visual assets in PNG and PDF formats using design philosophy principles. Combined with **theme-factory**, you can apply consistent styling across artifacts. For testing frontend applications, the **webapp-testing** skill uses Playwright for comprehensive verification including screenshot capture and console monitoring.

### Knowledge Management

The **supermemory** skill addresses information organization across projects. It indexes your codebase, documentation, and communications, making everything searchable through natural language queries. This proves invaluable when working with large codebases or maintaining multiple projects.

### Testing and Development Practices

The **tdd** skill guides developers through test-driven development cycles with intelligent test generation. The **skill-creator** skill enables building custom skills tailored to specific workflows, supporting both Python (FastMCP) and Node/TypeScript (MCP SDK) implementations.

## Verifying Skill Quality

Not all skills are created equal. When evaluating community skills, consider these factors:

1. **Maintenance activity**: Check recent commits and issue responses
2. **Documentation quality**: Look for clear examples and usage instructions
3. **Installation requirements**: Ensure compatibility with your environment
4. **User feedback**: Review any available testimonials or issues

Official skills maintained by Anthropic undergo rigorous testing and documentation standards. Community skills vary in quality, so evaluating before adoption saves troubleshooting time later.

## Installation and Configuration

Most skills follow a standard installation pattern. After obtaining the skill files, you place them in your Claude skills directory and restart your session. The skill becomes available alongside built-in skills.

For custom skills using the skill-creator framework, the process involves:

```python
# Example: Creating a custom MCP server with FastMCP
from fastmcp import FastMCP

mcp = FastMCP("my-custom-skill")

@mcp.tool()
def process_custom_task(input_data):
    # Your implementation
    return processed_result
```

This flexibility allows you to extend Claude's capabilities to match your exact requirements.

## Staying Updated

The Claude skills directory continues evolving with new community contributions. To stay informed about new skills and updates:

- Monitor the official GitHub repository for new submissions
- Follow the Claude Code documentation for feature announcements
- Participate in community discussions about skill development

Skills receive periodic updates that add capabilities, fix bugs, and improve integration. Keeping your local skill definitions current ensures you have access to the latest features.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
