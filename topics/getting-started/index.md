---
layout: default
title: "Getting Started with Claude Code"
description: "Beginner guides for Claude Code: installation, first project, setup, and essential workflows."
permalink: /topics/getting-started/
---

# Getting Started with Claude Code

Everything you need to go from zero to productive with Claude Code.

## Essentials

- [Complete Beginner Guide (2026)](/claude-code-for-beginners-complete-getting-started-2026/)
- [First Project Tutorial: Hello World](/claude-code-first-project-tutorial-hello-world/)
- [Setup on Mac: Step-by-Step](/claude-code-setup-on-mac-step-by-step/)
- [Tips for Absolute Beginners](/claude-code-tips-for-absolute-beginners-2026/)
- [Using Claude Code with an Existing GitHub Repo](/how-to-use-claude-code-with-existing-github-repo/)
- [How to Write Effective Prompts](/how-to-write-effective-prompts-for-claude-code/)
- [MCP Integration Guide for Beginners](/mcp-integration-guide-for-claude-code-beginners/)
- [Pair Programming for Beginner Developers](/claude-code-pair-programming-for-beginner-developers/)
- [Common Beginner Mistakes to Avoid](/claude-code-common-beginner-mistakes-to-avoid/)

## All Getting Started Articles

{% assign gs = site.pages | where_exp: "p", "p.path contains 'articles/'" | where_exp: "p", "p.tags contains 'getting-started' or p.tags contains 'beginners'" | sort: "title" %}
{% for p in gs %}{% if p.title %}
- [{{ p.title }}]({{ p.url }})
{% endif %}{% endfor %}
