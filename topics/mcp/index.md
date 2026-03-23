---
layout: default
title: "MCP Integration Guides"
description: "Connect Claude Code to external tools, databases, and APIs using Model Context Protocol (MCP) servers."
permalink: /topics/mcp/
---

# MCP Integration Guides

Connect Claude Code to databases, APIs, cloud services, and developer tools using the Model Context Protocol.

## Top Guides

- [MCP Integration Guide for Beginners](/mcp-integration-guide-for-claude-code-beginners/)
- [Building Your First MCP Tool](/building-your-first-mcp-tool-integration-guide-2026/)
- [AWS MCP Server: Cloud Automation](/aws-mcp-server-cloud-automation-with-claude-code/)
- [Brave Search MCP Server](/brave-search-mcp-server-research-automation/)
- [Ansible MCP Server: Configuration Management](/ansible-mcp-server-configuration-management/)
- [Apache Kafka MCP Server](/apache-kafka-mcp-server-event-streaming-guide/)
- [Datadog MCP Server: Monitoring](/datadog-mcp-server-monitoring-automation-claude/)

## All MCP Articles

{% assign mcps = site.pages | where_exp: "p", "p.path contains 'articles/'" | where_exp: "p", "p.title contains 'MCP'" | sort: "title" %}
{% for p in mcps %}{% if p.title %}
- [{{ p.title }}]({{ p.url }})
{% endif %}{% endfor %}
