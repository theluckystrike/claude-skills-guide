---
layout: default
title: "AI Agent Guides"
description: "Build autonomous agents, multi-agent systems, and orchestration patterns with Claude Code and Claude API."
permalink: /topics/agents/
---

# AI Agent Guides

Build autonomous agents, multi-agent orchestration, and production agent systems with Claude.

## Top Guides

- [Multi-Agent Orchestration Patterns](/claude-code-multi-agent-orchestration-patterns-guide/)
- [Building Production AI Agents](/building-production-ai-agents-with-claude-skills-2026/)
- [Stateful Agents Guide](/building-stateful-agents-with-claude-skills-guide/)
- [Agent Handoff Strategies for Long-Running Tasks](/agent-handoff-strategies-for-long-running-tasks-guide/)
- [Chain of Agents Pattern](/chain-of-agents-pattern-for-sequential-task-processing/)
- [Supervisor-Worker Agent Architecture](/building-supervisor-worker-agent-architecture-tutorial/)
- [Agent Goal Decomposition Explained](/ai-agent-goal-decomposition-how-it-works-explained/)
- [Agent Memory Types for Developers](/ai-agent-memory-types-explained-for-developers/)

## All Agent Articles

{% assign agents = site.pages | where_exp: "p", "p.path contains 'articles/'" | where_exp: "p", "p.title contains 'Agent'" | sort: "title" %}
{% for p in agents %}{% if p.title %}
- [{{ p.title }}]({{ p.url }})
{% endif %}{% endfor %}
