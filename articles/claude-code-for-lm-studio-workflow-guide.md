---
layout: default
title: "Claude Code for LM Studio — Workflow Guide"
description: "Run local LLMs with LM Studio and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-lm-studio-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, lm-studio, workflow]
---

## The Setup

You are running local language models with LM Studio, a desktop application that downloads, manages, and serves open-source LLMs with an OpenAI-compatible API. LM Studio provides a GUI for model selection, quantization options, and an inference server that your applications can call. Claude Code can help build applications that use local LLMs, but it generates code targeting the OpenAI API at `api.openai.com` instead of the local LM Studio server.

## What Claude Code Gets Wrong By Default

1. **Points to OpenAI's API endpoint.** Claude configures `base_url="https://api.openai.com/v1"`. LM Studio runs locally at `http://localhost:1234/v1` — the base URL must point to the local server.

2. **Requires an API key.** Claude sets `api_key=os.environ["OPENAI_API_KEY"]`. LM Studio's local server does not require authentication by default — any API key value works (or set it to "not-needed").

3. **Hardcodes model names like `gpt-4`.** Claude uses `model="gpt-4"` in API calls. LM Studio serves whatever model is loaded — use the model identifier shown in LM Studio, or use `/v1/models` endpoint to list available models.

4. **Assumes unlimited context window.** Claude sends long prompts without considering model limits. Local models have specific context windows (4K, 8K, 32K) depending on the model and quantization — exceeding them causes truncation or errors.

## The CLAUDE.md Configuration

```
# LM Studio Local LLM Project

## AI
- Platform: LM Studio (local LLM inference)
- API: OpenAI-compatible at localhost:1234/v1
- Models: Downloaded GGUF models (various sizes)
- Auth: No API key required for local server

## LM Studio Rules
- Base URL: http://localhost:1234/v1
- API key: "not-needed" or any string
- Model: check /v1/models for loaded model name
- Context: respect model's context window limit
- Streaming: supported via SSE (same as OpenAI)
- Temperature/top_p: adjust for model behavior
- GPU offload: configured in LM Studio GUI

## Conventions
- Use OpenAI SDK with custom base_url for LM Studio
- Check model is loaded before making requests
- Set reasonable max_tokens for local inference speed
- Monitor GPU memory usage for large models
- Use quantized models (Q4_K_M, Q5_K_M) for speed/quality
- Batch requests carefully — local GPU has limited throughput
- Fallback to cloud API if local model unavailable
```

## Workflow Example

You want to build a code review tool that uses a local LLM. Prompt Claude Code:

"Create a Python script that sends code diffs to a local LLM running in LM Studio for review. Use the OpenAI SDK with the local endpoint. Parse the response for issues categorized as critical, warning, or suggestion. Handle the case where LM Studio is not running."

Claude Code should configure the OpenAI client with `base_url="http://localhost:1234/v1"` and `api_key="not-needed"`, query `/v1/models` to get the loaded model name, send the diff with a structured prompt, parse the categorized response, and wrap the call in try/except for connection errors when LM Studio is not running.

## Common Pitfalls

1. **Sending too many concurrent requests.** Claude creates async code that fires many parallel requests. Local LLMs process one request at a time (or very few with batching). Queue requests and process sequentially, or use LM Studio's built-in request queuing.

2. **Not accounting for inference speed.** Claude sets short timeouts like `timeout=10`. Local inference is much slower than cloud APIs — a response might take 30-60 seconds depending on the model and prompt length. Set generous timeouts.

3. **Model quantization mismatch.** Claude writes prompts optimized for GPT-4-level models. Smaller quantized models (7B Q4) have different capabilities — prompts that work with GPT-4 may produce poor results with smaller local models. Adjust prompt complexity to match model capability.

## Related Guides

- [Claude Code for Ollama Local LLM Workflow Guide](/claude-code-for-ollama-local-llm-workflow-guide/)
- [Claude Code for Groq Inference Workflow Guide](/claude-code-for-groq-inference-workflow-guide/)
- [Claude Code for LangChain Framework Workflow Guide](/claude-code-for-langchain-framework-workflow-guide/)

## Related Articles

- [Claude Code for Beekeeper Studio — Workflow Guide](/claude-code-for-beekeeper-studio-workflow-guide/)
- [Switching From Android Studio — Complete Developer Guide](/switching-from-android-studio-workflow/)
