---
layout: default
title: "Claude API Guides"
description: "Tutorials for building with the Claude API: SDKs, streaming, tool use, cost optimization, and production patterns."
permalink: /topics/api/
---

# Claude API Guides

Build production applications with the Claude API. SDKs, streaming, tool use, authentication, and cost optimization.

## Top Guides

- [Building Apps with the Anthropic SDK (Python)](/building-apps-with-claude-api-anthropic-sdk-python-guide/)
- [Streaming Responses Implementation](/claude-api-streaming-responses-implementation-tutorial/)
- [Tool Use and Function Calling Deep Dive](/claude-api-tool-use-function-calling-deep-dive-guide/)
- [Cost Optimization Strategies for SaaS](/claude-api-cost-optimization-strategies-for-saas-application/)
- [Batch Processing Large Datasets](/claude-api-batch-processing-large-datasets-workflow-guide/)
- [API Rate Limiting Implementation](/claude-code-api-rate-limiting-implementation/)
- [API Key vs Pro Subscription Billing](/claude-code-api-key-vs-pro-subscription-billing/)

## All API Articles

{% assign apis = site.pages | where_exp: "p", "p.path contains 'articles/'" | where_exp: "p", "p.title contains 'API'" | sort: "title" %}
{% for p in apis %}{% if p.title %}
- [{{ p.title }}]({{ p.url }})
{% endif %}{% endfor %}
