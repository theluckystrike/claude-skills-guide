---
layout: default
title: "Claude Code Developer Portal Setup Guide"
description: "A practical guide to building a developer portal for Claude Code skills, with Jekyll setup, skill documentation structure, and automation tips."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-developer-portal-setup-guide/
reviewed: true
score: 7
categories: [guides]
tags: [claude-code, claude-skills]
---

# Claude Code Developer Portal Setup Guide

Developer portals serve as the central hub for organizing, documenting, and distributing Claude skills across teams. This guide walks you through building a functional developer portal from scratch using Jekyll, with practical patterns for skill documentation, search optimization, and maintenance workflows.

## Why Build a Developer Portal for Claude Skills

As your collection of Claude skills grows, finding the right skill for a specific task becomes increasingly difficult. A dedicated developer portal solves this problem by providing a searchable, organized interface for your skill library. Beyond discovery, a portal enables version tracking, usage analytics, and team collaboration around skill development.

Many teams start with simple markdown files scattered across repositories. This approach works initially but becomes unwieldy as the skill count increases. A structured portal with consistent metadata, search capabilities, and categorization transforms your skill library into a professional knowledge base.

## Setting Up Your Jekyll Foundation

Jekyll remains a popular choice for developer portals due to its simplicity, GitHub Pages integration, and flexible templating system. Start by initializing a new Jekyll site:

```bash
gem install jekyll bundler
jekyll new claude-skills-portal
cd claude-skills-portal
```

Configure your `_config.yml` with the necessary collections for skills:

```yaml
collections:
  skills:
    output: true
    permalink: /skills/:name/

defaults:
  - scope:
      path: "_skills"
      type: skills
    values:
      layout: skill
      published: true
```

Create the skills collection directory and add your first skill document. Each skill file lives in `_skills/` with front matter that describes its capabilities, usage patterns, and dependencies.

## Structuring Skill Documentation

Consistent documentation structure helps users quickly understand each skill's purpose and implementation. Define a standard template that every skill follows:

```markdown
---
name: frontend-design
description: "Generate frontend code with modern frameworks and responsive layouts"
tools: [Read, Write, Bash]
---

# Frontend Design Skill

## Overview
This skill accelerates frontend development by generating component code based on descriptions.

## Prerequisites
- Node.js 18 or higher
- Access to project directory structure

## Usage Example

Provide a clear example showing how to invoke the skill:

```
Claude, use the frontend-design skill to create a responsive navigation component
```

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| framework | string | "react" | Target framework |
| styling | string | "tailwind" | CSS approach |
| typescript | boolean | true | Enable TypeScript |
```

This structure ensures every skill document contains the same essential information, making your portal consistent and navigable.

## Implementing Search Functionality

Search is critical for portals with many skills. Jekyll offers several approaches, from simple client-side solutions to full-text search engines. For most use cases, a lightweight JavaScript-based search suffices:

```javascript
// assets/js/search.js
const skills = [
  {% for skill in site.skills %}
  {
    title: "{{ skill.name }}",
    description: "{{ skill.description }}",
    tags: {{ skill.tags | jsonify }},
    url: "{{ skill.url }}"
  }{% unless forloop.last %},{% endunless %}
  {% endfor %}
];

function searchSkills(query) {
  const results = skills.filter(skill => 
    skill.title.toLowerCase().includes(query.toLowerCase()) ||
    skill.description.toLowerCase().includes(query.toLowerCase())
  );
  displayResults(results);
}
```

Integrate this script into your search page and results display. The approach iterates through your skills collection and filters based on the search query, providing instant results without server-side processing.

## Automating Skill Discovery with MCP

Model Context Protocol (MCP) servers extend your portal's capabilities by enabling dynamic skill discovery. Configure an MCP server that indexes your skills and exposes them to Claude Code:

```python
# mcp-skill-registry/server.py
from mcp.server import Server
from mcp.types import Tool, TextContent
import json

server = Server("skill-registry")

@server.list_tools()
async def list_skills():
    with open('_skills/*.md') as files:
        skills = []
        for f in files:
            frontmatter = parse_frontmatter(f.read())
            skills.append(Tool(
                name=f"skill_{frontmatter['name']}",
                description=frontmatter['description'],
                inputSchema={}
            ))
    return skills

@server.call_tool()
async def call_tool(name: str, arguments: dict):
    skill_name = name.replace('skill_', '')
    return [TextContent(type="text", text=f"Redirecting to skill: {skill_name}")]
```

This MCP server reads your skill files and exposes them as callable tools within Claude Code, creating a seamless bridge between your portal and the AI assistant.

## Organizing Skills by Domain

Grouping skills by functional domain improves discoverability and helps users find relevant tools quickly. Common categories include:

- **Code Generation**: Skills like `frontend-design`, `backend-scaffold`, and `api-client` that generate code from specifications
- **Testing**: The `tdd` skill and similar testing-focused tools that create test suites
- **Documentation**: Skills such as `pdf` for generating documentation, `docx` for technical specs
- **Data Processing**: Skills for working with `xlsx`, CSV, and database operations
- **Memory and Context**: Skills like `supermemory` for maintaining conversation context

Create category pages that aggregate skills by domain:

```liquid
{% for tag in site.tags %}
## {{ tag[0] }}
<ul>
{% for post in tag[1] %}
  <li><a href="{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
</ul>
{% endfor %}
```

## Adding Version Tracking

Skill versions matter as your team updates capabilities and fixes bugs. Implement version tracking in your front matter and display it prominently:

```yaml
---
name: pdf
description: "Create and manipulate PDF documents"

changelog:
  - 
    date: 2026-03-10
    changes: ["Added form filling support", "Improved table extraction"]
  - version: 2.0.0
    date: 2026-02-15
    changes: ["Complete rewrite", "New MCP integration"]
---
```

Display the changelog on each skill page so users understand what changed and whether they should upgrade.

## Deployment and Maintenance

Deploy your portal to GitHub Pages for free hosting with automatic SSL:

```bash
git add .
git commit -m "Add developer portal"
git push origin gh-pages
```

Set up a GitHub Actions workflow to validate skill documents automatically:

```yaml
name: Validate Skills
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Check front matter
        run: |
          for f in _skills/*.md; do
            grep -q "^---$" "$f" || { echo "Missing front matter: $f"; exit 1; }
          done
```

This workflow catches missing front matter, broken links, and other issues before they reach production.

## Conclusion

A well-structured developer portal transforms your Claude skills from an ad-hoc collection into a professional, searchable knowledge base. Start with Jekyll for simplicity, implement search early, and establish consistent documentation patterns from the beginning. As your skill library grows, these foundational decisions pay dividends in discoverability and team productivity.

Extend your portal with MCP integration for dynamic skill discovery, version tracking for changelog visibility, and automated validation for quality assurance. The investment in building a proper portal pays returns through improved skill reuse and reduced duplication across your development workflow.


## Related Reading

- [What Is the Best Claude Skill for Generating Documentation?](/claude-skills-guide/what-is-the-best-claude-skill-for-generating-documentation/)
- [Claude Code Guides Hub](/claude-skills-guide/guides-hub/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [How to Write Effective CLAUDE.md for Your Project](/claude-skills-guide/how-to-write-effective-claude-md-for-your-project/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
