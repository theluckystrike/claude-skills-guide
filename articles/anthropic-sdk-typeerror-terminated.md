---
layout: default
title: "Fix: SDK TypeError: terminated (2026)"
description: "Fix intermittent TypeError: terminated failures in the Anthropic TypeScript SDK when streaming large inputs with undici."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /anthropic-sdk-typeerror-terminated/
reviewed: true
score: 8
categories: [troubleshooting]
tags: [claude-code, sdk, typescript, streaming, undici, error]
geo_optimized: true
---

# Fix: Anthropic SDK TypeError: terminated Streaming

## The Error

When using the Anthropic TypeScript SDK with streaming and large inputs, you intermittently get:

```
TypeError: terminated
```

This happens specifically when handling large inputs combined with multiple tool calls, and is more frequent with models like Sonnet 4.5, Sonnet 4.6, and Haiku 4.5.

## Quick Fix

Add retry logic with exponential backoff:

```typescript
import Anthropic from "@anthropic-ai/sdk";

async function createWithRetry(
 client: Anthropic,
 params: Anthropic.MessageCreateParamsStreaming,
 maxRetries = 3
): Promise<Anthropic.Message> {
 for (let attempt = 0; attempt < maxRetries; attempt++) {
 try {
 const stream = client.messages.stream(params);
 return await stream.finalMessage();
 } catch (error) {
 if (
 error instanceof TypeError &&
 error.message === "terminated" &&
 attempt < maxRetries - 1
 ) {
 const backoff = Math.min(1000 * 2 ** attempt, 10_000);
 await new Promise((r) => setTimeout(r, backoff));
 continue;
 }
 throw error;
 }
 }
 throw new Error("Max retries exceeded");
}
```

## What Causes This

The `TypeError: terminated` error originates from Node.js's `undici` HTTP client (the default `fetch` implementation in Node.js 18+). It occurs when the HTTP connection is terminated unexpectedly during a streaming response.

The error chain:

1. Your code sends a streaming API request with a large input (many messages, large context)
2. The server begins streaming the response
3. The underlying TCP connection is closed mid-stream (by the server, a proxy, or a network intermediary)
4. `undici` converts the premature connection close into a `TypeError: terminated`
5. The SDK propagates this as an unrecoverable error

**Why large inputs trigger this more frequently:**

- Large inputs mean longer server processing time, increasing the window for network interruptions
- Multiple tool calls in a session accumulate context, increasing payload sizes
- Some reverse proxies have request body size limits or connection timeouts that trigger on large requests

## Full Solution

### Option 1: Retry Wrapper with Classification

```typescript
import Anthropic from "@anthropic-ai/sdk";

function isRetryableError(error: unknown): boolean {
 if (error instanceof TypeError && error.message === "terminated") {
 return true;
 }
 if (error instanceof Anthropic.APIConnectionError) {
 return true;
 }
 if (
 error instanceof Anthropic.APIError &&
 (error.status === 429 || error.status === 500 || error.status === 503)
 ) {
 return true;
 }
 return false;
}

async function resilientStream(
 client: Anthropic,
 params: Anthropic.MessageCreateParamsStreaming,
 options: {
 maxRetries?: number;
 baseDelayMs?: number;
 onRetry?: (attempt: number, error: unknown) => void;
 } = {}
): Promise<Anthropic.Message> {
 const { maxRetries = 3, baseDelayMs = 1000, onRetry } = options;

 for (let attempt = 0; attempt <= maxRetries; attempt++) {
 try {
 const stream = client.messages.stream(params);
 return await stream.finalMessage();
 } catch (error) {
 if (!isRetryableError(error) || attempt === maxRetries) {
 throw error;
 }
 const delay = Math.min(baseDelayMs * 2 ** attempt, 30_000);
 onRetry?.(attempt + 1, error);
 await new Promise((resolve) => setTimeout(resolve, delay));
 }
 }

 throw new Error("Unreachable");
}
```

### Option 2: Reduce Input Size

Manage conversation context to keep inputs manageable:

```typescript
function trimMessages(
 messages: Anthropic.MessageParam[],
 maxTokenEstimate: number
): Anthropic.MessageParam[] {
 // Rough estimate: 1 token ~= 4 characters
 const estimateTokens = (msg: Anthropic.MessageParam): number => {
 if (typeof msg.content === "string") {
 return Math.ceil(msg.content.length / 4);
 }
 return msg.content.reduce((acc, block) => {
 if ("text" in block) return acc + Math.ceil(block.text.length / 4);
 return acc + 100; // Estimate for non-text blocks
 }, 0);
 };

 let totalTokens = 0;
 const kept: Anthropic.MessageParam[] = [];

 // Keep the last N messages that fit within the budget
 for (let i = messages.length - 1; i >= 0; i--) {
 const msgTokens = estimateTokens(messages[i]);
 if (totalTokens + msgTokens > maxTokenEstimate) break;
 totalTokens += msgTokens;
 kept.unshift(messages[i]);
 }

 return kept;
}
```

### Option 3: Use Non-Streaming for Large Inputs

Switch to non-streaming mode when input size is large. For long-running non-streaming requests, the SDK validates that the request is not expected to exceed a 10-minute timeout. Use streaming or override the timeout for very large inputs.

```typescript
async function adaptiveRequest(
 client: Anthropic,
 params: Anthropic.MessageCreateParamsNonStreaming | Anthropic.MessageCreateParamsStreaming
): Promise<Anthropic.Message> {
 const inputSize = JSON.stringify(params.messages).length;
 const LARGE_INPUT_THRESHOLD = 200_000; // characters

 if (inputSize > LARGE_INPUT_THRESHOLD) {
 // Large input: use non-streaming to avoid undici termination
 const nonStreamParams = {
 ...params,
 stream: false,
 } as Anthropic.MessageCreateParamsNonStreaming;
 return await client.messages.create(nonStreamParams);
 }

 // Normal input: use streaming
 const streamParams = {
 ...params,
 stream: true,
 } as Anthropic.MessageCreateParamsStreaming;
 const stream = client.messages.stream(streamParams);
 return await stream.finalMessage();
}
```

## Prevention

- **Always wrap streaming calls with retry logic** -- `TypeError: terminated` is intermittent and retries usually succeed
- **Monitor input sizes** -- break up conversations when context grows large
- **Use non-streaming mode for large inputs** when you do not need progressive output
- **Set explicit timeouts** on the Anthropic client (default is 10 minutes)

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=anthropic-sdk-typeerror-terminated)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Guides

- [Fix: Anthropic SDK Streaming Hangs Indefinitely](/anthropic-sdk-streaming-hang-timeout/)
- [Fix: Claude API Error 429 Rate Limit](/anthropic-api-error-429-rate-limit/)
- [Claude Code API Client TypeScript Guide](/claude-code-api-client-typescript-guide/)
- [Claude API Streaming Responses Implementation Tutorial](/claude-api-streaming-responses-implementation-tutorial/)
- [Claude API Error 400 Invalid Request Fix](/claude-api-error-400-invalidrequesterror-explained/)



- [Claude internal server error fix](/claude-internal-server-error-fix/) — Fix Claude internal server error (500/overloaded)
## Related Articles

- [Fix Anthropic SDK IndexError When Streaming](/anthropic-sdk-indexerror-streaming-fix/)
- [Fix: Anthropic SDK toolRunner Drops Headers](/anthropic-sdk-toolrunner-drops-headers/)
- [Fix: Anthropic API 500 Error with strict: true Tools](/anthropic-sdk-strict-true-500-error/)
- [Fix: Anthropic SDK Grammar Too Large Error](/anthropic-sdk-structured-output-grammar-too-large/)

