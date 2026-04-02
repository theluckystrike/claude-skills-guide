---
layout: default
title: "Claude Code Guides — Tutorials, Workflows & AI Agent Guides"
description: "2,500+ practical Claude Code tutorials for developers. Prompt engineering, API guides, MCP integrations, autonomous agents, and production workflows."
---

<div class="hero">
  <h1>Claude Code Guides</h1>
  <p class="hero-sub">Practical tutorials for developers who build with Claude. 2,500+ guides and counting.</p>
  <div class="stats">
    <div class="stat"><span class="number">2,500+</span><span class="label">Guides</span></div>
    <div class="stat"><span class="number">7</span><span class="label">Topics</span></div>
    <div class="stat"><span class="number">Daily</span><span class="label">Updates</span></div>
  </div>
</div>

<h2>Start Here</h2>
<div class="card-grid">
  <a href="/claude-code-for-beginners-complete-getting-started-2026/" class="card">
    <h3>Complete Beginner Guide</h3>
    <p>Installation, setup, and your first session</p>
  </a>
  <a href="/how-to-write-effective-prompts-for-claude-code/" class="card">
    <h3>How to Write Effective Prompts</h3>
    <p>Get better results from every prompt</p>
  </a>
  <a href="/mcp-integration-guide-for-claude-code-beginners/" class="card">
    <h3>MCP Integration Guide for Beginners</h3>
    <p>Connect Claude Code to external tools</p>
  </a>
  <a href="/claude-md-file-complete-guide-what-it-does/" class="card">
    <h3>CLAUDE.md Complete Guide</h3>
    <p>Project-level instructions that stick</p>
  </a>
  <a href="/building-a-rest-api-with-claude-code-tutorial/" class="card">
    <h3>Building a REST API with Claude Code</h3>
    <p>End-to-end walkthrough from scratch</p>
  </a>
</div>

<h2>Recently Updated</h2>
<div class="recent-list">
{% assign sorted_pages = site.pages | where_exp: "p", "p.path contains 'articles/'" | sort: "date" | reverse %}
{% for p in sorted_pages limit: 6 %}{% if p.title %}
<a href="{{ p.url }}" class="recent-item">{{ p.title }}</a>
{% endif %}{% endfor %}
</div>

<h2>Browse by Topic</h2>
<div class="topic-grid">
  <div class="topic-card">
    <h3>Getting Started</h3>
    <p>New to Claude Code? Start with the fundamentals.</p>
    <ul>
      <li><a href="/claude-code-first-project-tutorial-hello-world/">First Project Tutorial: Hello World</a></li>
      <li><a href="/claude-code-setup-on-mac-step-by-step/">Setup on Mac: Step-by-Step</a></li>
      <li><a href="/claude-code-tips-for-absolute-beginners-2026/">Tips for Absolute Beginners</a></li>
      <li><a href="/how-to-use-claude-code-with-existing-github-repo/">Using Claude Code with an Existing GitHub Repo</a></li>
    </ul>
    <a href="/topics/getting-started/" class="browse-link">Browse all &rarr;</a>
  </div>


  <div class="topic-card">
    <h3>Prompt Engineering</h3>
    <p>Write better prompts, get better results.</p>
    <ul>
      <li><a href="/how-to-write-effective-prompts-for-claude-code/">How to Write Effective Prompts</a></li>
      <li><a href="/claude-api-system-prompt-engineering-for-production-apps/">System Prompt Engineering for Production</a></li>
      <li><a href="/claude-skill-prompt-compression-techniques/">Prompt Compression Techniques</a></li>
    </ul>
    <a href="/topics/prompt-engineering/" class="browse-link">Browse all &rarr;</a>
  </div>


  <div class="topic-card">
    <h3>Claude API</h3>
    <p>Build production applications with the Claude API.</p>
    <ul>
      <li><a href="/building-apps-with-claude-api-anthropic-sdk-python-guide/">Building Apps with the Anthropic SDK (Python)</a></li>
      <li><a href="/claude-api-streaming-responses-implementation-tutorial/">Streaming Responses Implementation</a></li>
      <li><a href="/claude-api-tool-use-function-calling-deep-dive-guide/">Tool Use and Function Calling Deep Dive</a></li>
      <li><a href="/claude-api-cost-optimization-strategies-for-saas-application/">Cost Optimization Strategies</a></li>
    </ul>
    <a href="/topics/api/" class="browse-link">Browse all &rarr;</a>
  </div>


  <div class="topic-card">
    <h3>Agents</h3>
    <p>Build autonomous and multi-agent systems.</p>
    <ul>
      <li><a href="/claude-code-multi-agent-orchestration-patterns-guide/">Multi-Agent Orchestration Patterns</a></li>
      <li><a href="/building-production-ai-agents-with-claude-skills-2026/">Building Production AI Agents</a></li>
      <li><a href="/building-stateful-agents-with-claude-skills-guide/">Stateful Agents Guide</a></li>
      <li><a href="/agent-handoff-strategies-for-long-running-tasks-guide/">Agent Handoff Strategies</a></li>
    </ul>
    <a href="/topics/agents/" class="browse-link">Browse all &rarr;</a>
  </div>


  <div class="topic-card">
    <h3>MCP Integrations</h3>
    <p>Connect Claude Code to databases, APIs, and services.</p>
    <ul>
      <li><a href="/mcp-integration-guide-for-claude-code-beginners/">MCP Integration Guide for Beginners</a></li>
      <li><a href="/building-your-first-mcp-tool-integration-guide-2026/">Building Your First MCP Tool</a></li>
      <li><a href="/aws-mcp-server-cloud-automation-with-claude-code/">AWS MCP Server</a></li>
      <li><a href="/brave-search-mcp-server-research-automation/">Brave Search MCP Server</a></li>
    </ul>
    <a href="/topics/mcp/" class="browse-link">Browse all &rarr;</a>
  </div>


  <div class="topic-card">
    <h3>CLAUDE.md and Workflows</h3>
    <p>Configure projects and automate your workflow.</p>
    <ul>
      <li><a href="/claude-md-file-complete-guide-what-it-does/">CLAUDE.md Complete Guide</a></li>
      <li><a href="/claude-md-best-practices-for-large-codebases/">CLAUDE.md Best Practices for Large Codebases</a></li>
      <li><a href="/claude-code-git-hooks-pre-commit-automation/">Git Hooks and Pre-Commit Automation</a></li>
      <li><a href="/claude-code-2026-new-features-skills-and-hooks-roundup/">New Features: Skills and Hooks Roundup</a></li>
    </ul>
    <a href="/topics/workflows/" class="browse-link">Browse all &rarr;</a>
  </div>


  <div class="topic-card">
    <h3>Chrome Extensions</h3>
    <p>Guides for building, optimizing, and using Chrome extensions.</p>
    <ul>
      <li><a href="/ai-code-assistant-chrome-extension/">AI Code Assistant Chrome Extension</a></li>
      <li><a href="/chrome-extension-service-worker-inspector/">Chrome Extension Service Worker Inspector</a></li>
      <li><a href="/chrome-extension-performance-monitor/">Chrome Extension Performance Optimization</a></li>
    </ul>
    <a href="/topics/chrome-extensions/" class="browse-link">Browse all &rarr;</a>
  </div>

</div>

<div class="about-section">
  <h2>About</h2>
  <p>Tested, practical tutorials for developers building with Claude Code, Claude API, and Claude Desktop. Updated daily.</p>
  <a href="/about/" class="browse-link">Learn more &rarr;</a>
</div>

<div style="text-align:center; margin: 2rem 0;">
  <a href="/all-articles/" class="browse-link">Browse all 2,500+ guides &rarr;</a>
</div>
