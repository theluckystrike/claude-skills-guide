---
layout: default
title: "CLAUDE.md and Workflow Guides"
description: "Configure Claude Code projects with CLAUDE.md files, Git hooks, and automation workflows."
permalink: /topics/workflows/
---

# CLAUDE.md and Workflow Guides

Configure projects, automate workflows, and get the most out of Claude Code's project-level features.

## CLAUDE.md

- [CLAUDE.md Complete Guide](/claude-md-file-complete-guide-what-it-does/)
- [How to Write an Effective CLAUDE.md](/how-to-write-effective-claude-md-for-your-project/)
- [CLAUDE.md Best Practices for Large Codebases](/claude-md-best-practices-for-large-codebases/)
- [CLAUDE.md Template for New Projects](/claude-md-template-for-new-projects-starter-guide/)
- [CLAUDE.md for Frontend Projects](/claude-md-for-frontend-projects-best-practices/)
- [CLAUDE.md for Backend Projects](/claude-md-for-backend-projects-best-practices/)
- [CLAUDE.md for Fullstack Projects](/claude-md-for-fullstack-projects-complete-guide/)

## Hooks and Automation

- [Git Hooks and Pre-Commit Automation](/claude-code-git-hooks-pre-commit-automation/)
- [New Features: Skills and Hooks Roundup (2026)](/claude-code-2026-new-features-skills-and-hooks-roundup/)

## All CLAUDE.md Articles

{% assign claudes = site.pages | where_exp: "p", "p.path contains 'articles/'" | where_exp: "p", "p.title contains 'CLAUDE.md' or p.title contains 'claude.md' or p.title contains 'Claude.md'" | sort: "title" %}
{% for p in claudes %}{% if p.title %}
- [{{ p.title }}]({{ p.url }})
{% endif %}{% endfor %}
