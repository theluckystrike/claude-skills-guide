---
layout: default
title: "Claude Code Guides — Ship Faster with AI"
description: "Practical Claude Code, Claude API, and AI coding tutorials."
---

# Claude Code Guides

Practical guides for getting real work done with Claude Code, Claude API, and Claude Desktop. From prompt engineering to autonomous agents to production deployments. Written by a developer who ships with Claude daily.

## Start Here

<div class="card">
  <a href="/claude-code-for-beginners-complete-getting-started-2026/">Complete Beginner Guide</a>
  <p>Installation, setup, and your first session</p>
</div>

<div class="card">
  <a href="/how-to-write-effective-prompts-for-claude-code/">How to Write Effective Prompts</a>
  <p>Get better results from every prompt</p>
</div>

<div class="card">
  <a href="/mcp-integration-guide-for-claude-code-beginners/">MCP Integration Guide for Beginners</a>
  <p>Connect Claude Code to external tools</p>
</div>

<div class="card">
  <a href="/claude-md-file-complete-guide-what-it-does/">CLAUDE.md Complete Guide</a>
  <p>Project-level instructions that stick</p>
</div>

<div class="card">
  <a href="/building-a-rest-api-with-claude-code-tutorial/">Building a REST API with Claude Code</a>
  <p>End-to-end walkthrough from scratch</p>
</div>

## Recently Updated

{% assign sorted_pages = site.pages | where_exp: "p", "p.path contains 'articles/'" | sort: "date" | reverse %}
{% for p in sorted_pages limit: 6 %}{% if p.title %}
- [{{ p.title }}]({{ p.url }})
{% endif %}{% endfor %}

## Browse by Topic

### Getting Started
New to Claude Code? Start with the fundamentals.

- [First Project Tutorial: Hello World](/claude-code-first-project-tutorial-hello-world/)
- [Setup on Mac: Step-by-Step](/claude-code-setup-on-mac-step-by-step/)
- [Tips for Absolute Beginners](/claude-code-tips-for-absolute-beginners-2026/)
- [Using Claude Code with an Existing GitHub Repo](/how-to-use-claude-code-with-existing-github-repo/)

[Browse all Getting Started guides -->](/topics/getting-started/)

### Prompt Engineering
Write better prompts, get better results.

- [How to Write Effective Prompts](/how-to-write-effective-prompts-for-claude-code/)
- [System Prompt Engineering for Production](/claude-api-system-prompt-engineering-for-production-apps/)
- [Prompt Compression Techniques](/claude-skill-prompt-compression-techniques/)

[Browse all Prompt guides -->](/topics/prompt-engineering/)

### Claude API
Build production applications with the Claude API.

- [Building Apps with the Anthropic SDK (Python)](/building-apps-with-claude-api-anthropic-sdk-python-guide/)
- [Streaming Responses Implementation](/claude-api-streaming-responses-implementation-tutorial/)
- [Tool Use and Function Calling Deep Dive](/claude-api-tool-use-function-calling-deep-dive-guide/)
- [Cost Optimization Strategies](/claude-api-cost-optimization-strategies-for-saas-application/)

[Browse all API guides -->](/topics/api/)

### Agents
Build autonomous and multi-agent systems.

- [Multi-Agent Orchestration Patterns](/claude-code-multi-agent-orchestration-patterns-guide/)
- [Building Production AI Agents](/building-production-ai-agents-with-claude-skills-2026/)
- [Stateful Agents Guide](/building-stateful-agents-with-claude-skills-guide/)
- [Agent Handoff Strategies](/agent-handoff-strategies-for-long-running-tasks-guide/)

[Browse all Agent guides -->](/topics/agents/)

### MCP Integrations
Connect Claude Code to databases, APIs, and services.

- [MCP Integration Guide for Beginners](/mcp-integration-guide-for-claude-code-beginners/)
- [Building Your First MCP Tool](/building-your-first-mcp-tool-integration-guide-2026/)
- [AWS MCP Server](/aws-mcp-server-cloud-automation-with-claude-code/)
- [Brave Search MCP Server](/brave-search-mcp-server-research-automation/)

[Browse all MCP guides -->](/topics/mcp/)

### CLAUDE.md and Workflows
Configure projects and automate your workflow.

- [CLAUDE.md Complete Guide](/claude-md-file-complete-guide-what-it-does/)
- [CLAUDE.md Best Practices for Large Codebases](/claude-md-best-practices-for-large-codebases/)
- [Git Hooks and Pre-Commit Automation](/claude-code-git-hooks-pre-commit-automation/)
- [New Features: Skills and Hooks Roundup](/claude-code-2026-new-features-skills-and-hooks-roundup/)

[Browse all Workflow guides -->](/topics/workflows/)

## About

Claude Code Guides publishes tested, practical tutorials for developers working with Claude. [Read more -->](/about/)
