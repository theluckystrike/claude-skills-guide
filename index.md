---
layout: default
title: "Claude Code Guides — Tutorials, Workflows & AI Agent Guides"
description: "2,500+ practical Claude Code tutorials for developers. Prompt engineering, API guides, MCP integrations, autonomous agents, and production workflows."
---

<style>
/* --- Hero Bio & CTA --- */
.hero-bio {
  color: #9a9590;
  font-size: 0.92rem;
  max-width: 620px;
  margin: 0 auto 1.25rem;
  line-height: 1.6;
}
.hero-cta {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  color: #d97757;
  font-weight: 600;
  font-size: 0.95rem;
  padding: 10px 22px;
  border: 1px solid #3a3a35;
  border-radius: 8px;
  transition: all 0.2s ease;
  text-decoration: none;
}
.hero-cta:hover {
  color: #e8856a;
  border-color: #d97757;
  background: rgba(217, 119, 87, 0.06);
  text-decoration: none;
  transform: translateY(-1px);
}

/* --- Community Section --- */
.community-section {
  margin: 2.5rem 0;
  padding: 2.5rem 2rem;
  background: linear-gradient(135deg, #1c1c1a 0%, #2a2420 40%, #141413 100%);
  border-radius: 14px;
  border: 1px solid #3a3a35;
  position: relative;
  overflow: hidden;
}
.community-section::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, #d97757, transparent);
}
.community-section h2 {
  color: #faf9f5;
  font-size: 1.35rem;
  border: none;
  padding: 0;
  margin: 0 0 0.75rem 0;
}
.community-section h2::after {
  display: none;
}
.community-lead {
  color: #b0aea5;
  font-size: 0.95rem;
  line-height: 1.7;
  max-width: 640px;
  margin-bottom: 1.25rem;
}
.community-perks {
  list-style: none;
  padding: 0;
  margin: 0 0 1.75rem 0;
}
.community-perks li {
  color: #e8e6dc;
  font-size: 0.92rem;
  padding: 4px 0 4px 20px;
  position: relative;
  margin-bottom: 0.3rem;
}
.community-perks li::before {
  content: '';
  position: absolute;
  left: 0;
  top: 12px;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #d97757;
}
.community-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}
.community-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  color: #d97757;
  font-weight: 600;
  font-size: 0.9rem;
  padding: 10px 20px;
  border: 1px solid #3a3a35;
  border-radius: 8px;
  transition: all 0.2s ease;
  text-decoration: none;
}
.community-btn:hover {
  color: #e8856a;
  border-color: #d97757;
  background: rgba(217, 119, 87, 0.06);
  text-decoration: none;
  transform: translateY(-1px);
}
.community-btn-primary {
  background: #d97757;
  color: #141413;
  border-color: #d97757;
}
.community-btn-primary:hover {
  background: #e8856a;
  color: #141413;
  border-color: #e8856a;
}

@media (max-width: 768px) {
  .hero-bio {
    font-size: 0.85rem;
  }
  .community-section {
    padding: 2rem 1.25rem;
  }
  .community-buttons {
    flex-direction: column;
  }
  .community-btn {
    justify-content: center;
  }
}
</style>

<div class="hero">
  <h1>Claude Code Guides</h1>
  <p class="hero-sub">Practical tutorials for developers who build with Claude. 2,500+ guides and counting.</p>
  <div class="stats">
    <div class="stat"><span class="number">2,500+</span><span class="label">Guides</span></div>
    <div class="stat"><span class="number">7</span><span class="label">Topics</span></div>
    <div class="stat"><span class="number">Daily</span><span class="label">Updates</span></div>
  </div>
  <p class="hero-bio">Built by Michael Lip — solo founder of Zovo, 20+ Chrome extensions, $400K+ on Upwork, 670+ open source contributions.</p>
  <a href="https://discord.com/invite/QeHxTFbqmC" target="_blank" rel="noopener noreferrer" class="hero-cta">Join the Builder Community &rarr;</a>
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

<section class="community-section" aria-label="Builder community">
  <h2>Join the Builder Community</h2>
  <p class="community-lead">These guides are one piece of a larger developer ecosystem. Zovo is where developers building with AI and Chrome extensions connect, share, and ship together.</p>
  <ul class="community-perks">
    <li>2,500+ Claude Code guides (you're here)</li>
    <li>20+ Chrome extensions (zovo.one)</li>
    <li>Private Discord with verified builders</li>
    <li>Monthly live calls &amp; extension teardowns</li>
    <li>In-person meetups: Da Nang, Bangkok, Bali</li>
  </ul>
  <div class="community-buttons">
    <a href="https://discord.com/invite/QeHxTFbqmC" target="_blank" rel="noopener noreferrer" class="community-btn community-btn-primary">Join Discord (Free) &rarr;</a>
    <a href="https://zovo.one" target="_blank" rel="noopener noreferrer" class="community-btn">Explore Zovo &rarr;</a>
    <a href="https://zovo.one/pricing" target="_blank" rel="noopener noreferrer" class="community-btn">View Pricing &rarr;</a>
  </div>
</section>

<div class="about-section">
  <h2>About</h2>
  <p>Tested, practical tutorials for developers building with Claude Code, Claude API, and Claude Desktop. Updated daily.</p>
  <a href="/about/" class="browse-link">Learn more &rarr;</a>
</div>

<div style="text-align:center; margin: 2rem 0;">
  <a href="/all-articles/" class="browse-link">Browse all 2,500+ guides &rarr;</a>
</div>
