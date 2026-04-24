---
layout: default
title: "Claude Code for Dify AI Platform (2026)"
description: "Claude Code for Dify AI Platform — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-dify-ai-platform-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, dify, workflow]
---

## The Setup

You are building AI applications with Dify, an open-source platform that provides a visual workflow builder for LLM apps, RAG pipelines, and AI agents. Dify offers a web UI for designing workflows, a built-in vector store, and API endpoints for deploying AI features. Claude Code can help build AI applications, but it generates raw LangChain or OpenAI SDK code instead of Dify's workflow-based approach.

## What Claude Code Gets Wrong By Default

1. **Writes LangChain pipeline code.** Claude creates Python scripts with LangChain chains and retrievers. Dify replaces this with a visual workflow — you configure nodes in the UI, not in code.

2. **Implements RAG from scratch.** Claude writes vector store setup, embedding generation, and retrieval code. Dify has built-in RAG with document upload, automatic chunking, embedding, and retrieval — no custom code needed.

3. **Ignores Dify's API.** Claude builds standalone Flask/FastAPI servers for AI endpoints. Dify generates REST API endpoints automatically for every workflow — you call the Dify API from your application.

4. **Hardcodes prompt templates in code.** Claude embeds prompts in Python strings. Dify manages prompts in the UI with variable interpolation — prompts are versioned and editable without code changes.

## The CLAUDE.md Configuration

```
{% raw %}
# Dify AI Platform Project

## AI Platform
- Platform: Dify (open-source LLM app builder)
- Workflows: Visual node-based workflow editor
- RAG: Built-in document processing and retrieval
- API: Auto-generated REST endpoints per workflow

## Dify Rules
- Workflows built in Dify UI, not in code
- RAG: upload documents to Dify knowledge base
- API calls: use Dify's REST API from application code
- Prompts: managed in Dify UI with {{variable}} syntax
- Models: configured per node in workflow
- Tools: custom tools via API or Dify tool plugins

## Conventions
- Application code calls Dify API, not LLM directly
- API key in environment variables
- Dify endpoint: POST /v1/chat-messages or /v1/completion-messages
- Stream responses with SSE for chat interfaces
- Knowledge bases for document-grounded responses
- Custom tools: register external APIs as Dify tools
- Self-hosted: Docker Compose for Dify deployment
{% endraw %}
```

## Workflow Example

You want to integrate a Dify-powered chatbot into your Next.js application. Prompt Claude Code:

"Create an API route in Next.js that proxies chat messages to our Dify chatbot workflow. Support streaming responses, pass the conversation ID for context, and handle the Dify API response format. The Dify instance is self-hosted at DIFY_API_URL."

Claude Code should create a Next.js API route that sends POST requests to `${DIFY_API_URL}/v1/chat-messages` with the user message, conversation_id, and API key header, handle SSE streaming from Dify, and forward the stream to the client.

## Common Pitfalls

1. **Bypassing Dify for simple changes.** Claude modifies prompt logic in application code when it should be changed in the Dify UI. Prompts, model selection, and workflow logic live in Dify — application code should only handle the API integration.

2. **Not using conversation_id for context.** Claude sends each message as a new conversation. Dify uses `conversation_id` to maintain chat history — pass the ID returned from the first message in subsequent requests.

3. **Ignoring Dify's rate limits.** Claude sends rapid parallel requests to Dify. Self-hosted Dify has concurrency limits based on your infrastructure. Implement request queuing or throttling in your application layer.

## Related Guides

- [Claude Code for LangChain Framework Workflow Guide](/claude-code-for-langchain-framework-workflow-guide/)
- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
- [Claude Code API Authentication Patterns Guide](/claude-code-api-authentication-patterns-guide/)

## See Also

- [Claude Code Spacelift Platform Guide](/claude-code-spacelift-platform-guide/)
