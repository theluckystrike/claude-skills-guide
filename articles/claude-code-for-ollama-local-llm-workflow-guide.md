---
layout: default
title: "Claude Code for Ollama — Workflow Guide (2026)"
description: "Claude Code for Ollama — Workflow Guide — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-04-18
permalink: /claude-code-for-ollama-local-llm-workflow-guide/
categories: [workflow, niche-tools]
tags: [claude-code, ollama, workflow]
---

## The Setup

You are using Ollama to run LLMs locally on your machine for development, testing, and privacy-sensitive applications. Ollama provides an API compatible with the OpenAI format, making it easy to swap between local and cloud models. Claude Code can help integrate Ollama, but it configures cloud API endpoints and ignores local model management.

## What Claude Code Gets Wrong By Default

1. **Points to cloud API endpoints.** Claude configures `https://api.openai.com/v1` as the base URL. Ollama runs locally at `http://localhost:11434` with its own API format and an OpenAI-compatible endpoint at `/v1`.

2. **Uses cloud model names.** Claude references `gpt-4` or `claude-3`. Ollama uses model tags like `llama3.3`, `mistral`, `codellama` — pulled and managed locally with `ollama pull`.

3. **Adds API key authentication.** Claude includes `Authorization: Bearer sk-...` headers. Ollama's local API requires no authentication by default — adding auth headers causes connection failures.

4. **Ignores model pulling and management.** Claude assumes models are always available. Ollama models must be pulled first: `ollama pull llama3.3` downloads the model. Claude skips this step and gets "model not found" errors.

## The CLAUDE.md Configuration

```
# Ollama Local LLM Project

## AI/LLM
- Runtime: Ollama (local LLM inference)
- API: http://localhost:11434 (native) or /v1 (OpenAI-compatible)
- Models: pulled locally with ollama pull <model>
- No API key required for local access

## Ollama Rules
- Base URL: http://localhost:11434 (NOT cloud endpoints)
- Model names: llama3.3, mistral, codellama (NOT gpt-4)
- No authentication headers needed
- Pull models first: ollama pull <model-name>
- List models: ollama list
- Chat API: POST /api/chat with model and messages
- OpenAI compat: POST /v1/chat/completions (same format)
- Streaming: stream: true returns NDJSON chunks

## Conventions
- Ollama client in lib/ollama.ts
- OLLAMA_HOST env var for non-default host
- Check model availability before requests
- Use OpenAI SDK with baseURL for compatibility
- Modelfile for custom model configurations
- GPU detection: ollama runs on GPU automatically if available
- Fallback to cloud API if Ollama is unavailable
```

## Workflow Example

You want to create a development tool that uses Ollama for code review. Prompt Claude Code:

"Create a local code review tool that sends diffs to Ollama's Llama model for analysis. Use the OpenAI-compatible API so it can easily switch to a cloud model. Handle the case where Ollama is not running."

Claude Code should configure the OpenAI SDK with `baseURL: 'http://localhost:11434/v1'` and no API key, use `llama3.3` as the model, send the diff as a user message with a code review system prompt, handle connection errors gracefully with a message to start Ollama, and support streaming for real-time review output.

## Common Pitfalls

1. **Model not pulled before first request.** Claude makes API calls assuming the model exists. Ollama returns a 404 if the model has not been pulled. Check `ollama list` or catch the error and prompt the user to run `ollama pull <model>`.

2. **Memory requirements not considered.** Claude selects large models (70B parameters) without checking available RAM. Each model needs roughly its parameter count in GB of memory (7B ~ 8GB, 70B ~ 48GB). Choose models that fit the development machine.

3. **Context window differences.** Claude sets high `max_tokens` values from cloud API habits. Local models have different context windows (typically 4K-8K for small models). Check the model's context length with `ollama show <model>` and adjust accordingly.

## Related Guides

- [Claude Code for AI Agent Tool Calling](/claude-code-for-ai-agent-tool-calling-implementation/)
- [Building Production AI Agents with Claude Skills 2026](/building-production-ai-agents-with-claude-skills-2026/)
- [Claude Code for Embedding Pipeline Workflow](/claude-code-for-embedding-pipeline-workflow/)


## Common Questions

### What AI models work best with this approach?

Claude Opus 4 and Claude Sonnet 4 handle complex reasoning tasks. For simpler operations, Claude Haiku 3.5 offers faster responses at lower cost. Match model capability to task complexity.

### How do I handle AI agent failures gracefully?

Implement retry logic with exponential backoff, set clear timeout boundaries, and design fallback paths for critical operations. Log all failures for pattern analysis.

### Can this workflow scale to production?

Yes. Add rate limiting, request queuing, and monitoring before production deployment. Most AI agent architectures scale horizontally by adding worker instances behind a load balancer.

## Related Resources

- [Claude Code Academic Workflow Guide](/claude-code-academic-workflow-guide-2026/)
- [Claude Code Debugging Workflow Guide](/claude-code-debugging-workflow-guide-2026/)
- [Claude Code for Ark UI — Workflow Guide](/claude-code-for-ark-ui-workflow-guide/)
