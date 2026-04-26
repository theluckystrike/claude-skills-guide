---
layout: default
title: "Fix: Anthropic SDK toolRunner Drops (2026)"
description: "Claude Code troubleshooting: fix the bug where Anthropic SDK toolRunner drops defaultHeaders on follow-up requests, breaking Cloudflare AI Gateway and..."
date: 2026-04-14
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /anthropic-sdk-toolrunner-drops-headers/
reviewed: true
categories: [troubleshooting]
tags: [anthropic-sdk, typescript, authentication, error, troubleshooting, api]
geo_optimized: true
---

# Fix: Anthropic SDK toolRunner Drops Headers

## The Error

Using `client.messages.toolRunner` with a proxy or gateway (like Cloudflare AI Gateway), the first tool call works, but follow-up calls fail with:

```json
{
 "type": "error",
 "error": {
 "type": "authentication_error",
 "message": "x-api-key header is required"
 }
}
```

The same setup works perfectly with `client.messages.create` for single calls.

## Quick Fix

Replace `toolRunner` with a manual tool-use loop:

```typescript
async function runWithTools(
 client: Anthropic,
 params: Anthropic.MessageCreateParams,
 toolHandlers: Record<string, (input: any) => Promise<string>>
): Promise<Anthropic.Message> {
 let messages = [...params.messages];

 while (true) {
 const response = await client.messages.create({
 ...params,
 messages,
 });

 if (response.stop_reason !== "tool_use") {
 return response;
 }

 const toolBlocks = response.content.filter(
 (b): b is Anthropic.ToolUseBlock => b.type === "tool_use"
 );

 messages.push({ role: "assistant", content: response.content });
 messages.push({
 role: "user",
 content: await Promise.all(
 toolBlocks.map(async (block) => ({
 type: "tool_result" as const,
 tool_use_id: block.id,
 content: String(await toolHandlers[block.name](block.input)),
 }))
 ),
 });
 }
}
```

## What's Happening

`client.messages.toolRunner` is a convenience helper that automatically handles the tool-use loop: it sends the initial message, executes tools locally when the model requests them, and sends tool results back in follow-up API calls.

The bug: **the follow-up API calls made internally by `toolRunner` do not include `defaultHeaders`** that were set on the client instance. Only the first call (initial prompt) includes all headers correctly.

This breaks any setup where custom headers are required for authentication:

```typescript
const client = new Anthropic({
 baseURL: "https://gateway.ai.cloudflare.com/v1/{account}/anthropic",
 apiKey: "not-used", // Proxy handles the real key
 defaultHeaders: {
 "cf-aig-authorization": "Bearer <CF_API_TOKEN>", // Dropped on follow-up calls
 },
});
```

**Call sequence:**

```
Call 1 (initial prompt):
 Headers: { "cf-aig-authorization": "Bearer ...", "x-api-key": "not-used" }
 Result: Model requests tool_use

Call 2 (tool results — INTERNAL to toolRunner):
 Headers: { "x-api-key": "not-used" } // cf-aig-authorization MISSING
 Result: 401 authentication_error
```

**Affected setups:**

- Cloudflare AI Gateway (unified billing via `cf-aig-authorization`)
- Cloudflare AI Gateway (BYOK via `cf-aig-authorization`)
- Any custom proxy using custom headers for authentication
- Any middleware that injects provider keys based on request headers

The bug affects both `client.messages.toolRunner` and `client.beta.messages.toolRunner`.

## Step-by-Step Solution

### Option 1: Manual Tool Loop (Recommended)

Replace `toolRunner` with an explicit loop. Each `client.messages.create` call independently sends all headers:

```typescript
import Anthropic from "@anthropic-ai/sdk";
import { zodTool } from "@anthropic-ai/sdk/helpers/zod";
import { z } from "zod";

const client = new Anthropic({
 baseURL: "https://gateway.ai.cloudflare.com/v1/{account_id}/{gateway_id}/anthropic",
 apiKey: "not-used",
 defaultHeaders: {
 "cf-aig-authorization": "Bearer <CF_API_TOKEN>",
 },
});

const tools = [
 {
 name: "get_weather",
 description: "Get weather for a location",
 input_schema: {
 type: "object" as const,
 properties: { location: { type: "string" } },
 required: ["location"],
 },
 },
];

const toolHandlers: Record<string, (input: any) => string> = {
 get_weather: (input) => `Sunny, 22C in ${input.location}`,
};

async function chat(userMessage: string): Promise<string> {
 const messages: Anthropic.MessageParam[] = [
 { role: "user", content: userMessage },
 ];

 for (let i = 0; i < 10; i++) { // Bounded loop — max 10 tool iterations
 const response = await client.messages.create({
 model: "claude-sonnet-4-20250514",
 max_tokens: 1024,
 tools,
 messages,
 });

 if (response.stop_reason === "end_turn") {
 const textBlock = response.content.find((b) => b.type === "text");
 return textBlock?.type === "text" ? textBlock.text : "";
 }

 if (response.stop_reason !== "tool_use") {
 return `Unexpected stop_reason: ${response.stop_reason}`;
 }

 const toolUseBlocks = response.content.filter(
 (b): b is Anthropic.ToolUseBlock => b.type === "tool_use"
 );

 messages.push({ role: "assistant", content: response.content });

 const toolResults: Anthropic.ToolResultBlockParam[] = toolUseBlocks.map(
 (block) => ({
 type: "tool_result" as const,
 tool_use_id: block.id,
 content: toolHandlers[block.name]?.(block.input) ?? "Unknown tool",
 })
 );

 messages.push({ role: "user", content: toolResults });
 }

 return "Max tool iterations reached";
}
```

### Option 2: Per-Request Headers

If you still want to use `toolRunner`, pass headers on each request via request options (if supported by your SDK version):

```typescript
// Check if your SDK version supports per-request options in toolRunner
const result = await client.messages.toolRunner({
 model: "claude-sonnet-4-20250514",
 max_tokens: 1024,
 messages: [{ role: "user", content: "What's the weather in London?" }],
 tools: [weatherTool],
}, {
 headers: {
 "cf-aig-authorization": "Bearer <CF_API_TOKEN>",
 },
});
```

### Option 3: Use Vercel AI SDK

The Vercel AI SDK (`@ai-sdk/anthropic`) makes independent `doGenerate` calls per step with headers intact:

```typescript
import { anthropic } from "@ai-sdk/anthropic";
import { generateText, tool } from "ai";
import { z } from "zod";

const result = await generateText({
 model: anthropic("claude-sonnet-4-20250514", {
 // Headers are sent on every call
 }),
 tools: {
 getWeather: tool({
 description: "Get weather",
 parameters: z.object({ location: z.string() }),
 execute: async ({ location }) => `Sunny in ${location}`,
 }),
 },
 prompt: "What's the weather in London?",
 maxSteps: 5,
});
```

## Prevention

- **Test multi-turn tool calls through your proxy** before going to production — the bug only appears on follow-up calls
- **Prefer manual tool loops** over `toolRunner` when using proxies or gateways
- **Log all outgoing headers** to detect when they get dropped
- **Pin your SDK version** and test header propagation after each upgrade

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=anthropic-sdk-toolrunner-drops-headers)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Issues

- [Fix: Anthropic SDK Streaming Hangs Indefinitely](/anthropic-sdk-streaming-hang-timeout)
- [Fix: Claude API Error 401 Authentication](/claude-api-error-401-authenticationerror-explained/)
- [Advanced Claude Skills with Tool Use and Function Calling](/advanced-claude-skills-with-tool-use-and-function-calling/)

## Tools That Help

When debugging proxy and gateway authentication issues, a dev tool extension can help inspect outgoing request headers to verify they are being sent correctly on each API call.


