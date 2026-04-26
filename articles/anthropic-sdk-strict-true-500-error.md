---
layout: default
title: "Fix: Anthropic API 500 Error (2026)"
description: "Claude Code troubleshooting: fix: Anthropic API 500 Error — step-by-step fix with tested commands, error codes, and verified solutions for developers."
date: 2026-04-14
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /anthropic-sdk-strict-true-500-error/
reviewed: true
categories: [troubleshooting]
tags: [anthropic-sdk, typescript, error, troubleshooting, api, structured-output]
geo_optimized: true
---

# Fix: Anthropic API 500 Error with strict: true Tools

## The Error

When using `strict: true` with the structured outputs beta, the API returns a 500 [Claude internal server error fix](/claude-internal-server-error-fix/) for tool schemas with complex nested structures:

```json
{
 "type": "error",
 "error": {
 "type": "api_error",
 "message": "Internal server error"
 },
 "request_id": "req_011CXYasMqMAq6EP1aGLry8N"
}
```

The same request works perfectly when `strict: true` is removed. The error occurs after 17-55 seconds of processing, suggesting a server-side crash during grammar compilation.

## Quick Fix

Remove `strict: true` from tools with complex nested schemas:

```typescript
const tools = [{
 name: "create_booking",
 // strict: true, // Remove this
 input_schema: {
 type: "object",
 properties: { /* ... complex schema ... */ },
 required: ["field1", "field2"],
 additionalProperties: false
 }
}];
```

The model will still follow the schema in most cases. Validate the output yourself.

## What's Happening

When you set `strict: true` on a tool, the API compiles a **constrained decoding grammar** from your JSON Schema. This grammar ensures the model's output is guaranteed to be valid according to your schema. The compilation process converts the JSON Schema into a finite-state automaton.

For complex schemas, this compilation can fail or exceed internal limits. The factors that cause grammar explosion:

### 1. Nested Arrays of Objects

```typescript
// This pattern causes exponential grammar state growth:
{
 accommodationRate: {
 type: "array",
 items: {
 type: "object",
 properties: {
 roomId: { type: "string" },
 price: { type: "integer" }
 },
 required: ["roomId", "price"],
 additionalProperties: false
 }
 }
}
```

Each nested object with `required` fields and `additionalProperties: false` creates branching points in the grammar.

### 2. Multiple Complex Arrays in One Schema

Test results confirm the pattern:

| Configuration | Result |
|--------------|--------|
| 1 simple tool + `strict: true` | Works (7.8s) |
| 2 simple tools + `strict: true` | Works (8.2s) |
| 3 tools (including complex) + `strict: true` | 500 Error (17.3s) |
| Same 3 tools WITHOUT `strict: true` | Works (5.8s) |
| Complex tool + `strict: true` (no thinking) | 500 Error |

### 3. The Grammar Size Limit

The related error "compiled grammar is too large" (which returns a 400 instead of 500) triggers when the grammar exceeds a documented size threshold. The 500 error appears to be an unhandled edge case where the grammar compilation itself crashes before the size check.

## Step-by-Step Solution

### Option 1: Simplify the Schema

Flatten nested structures by using string-encoded JSON for complex inner types:

```typescript
// BEFORE: Complex nested schema (causes 500)
const schema = {
 type: "object",
 properties: {
 rooms: {
 type: "array",
 items: {
 type: "object",
 properties: {
 id: { type: "string" },
 rate: { type: "integer" },
 extras: {
 type: "array",
 items: {
 type: "object",
 properties: {
 name: { type: "string" },
 cost: { type: "integer" }
 },
 required: ["name", "cost"]
 }
 }
 },
 required: ["id", "rate"]
 }
 }
 }
};

// AFTER: Flattened schema (works with strict: true)
const schema = {
 type: "object",
 properties: {
 rooms: {
 type: "array",
 items: {
 type: "object",
 properties: {
 id: { type: "string" },
 rate: { type: "integer" },
 extras_json: { type: "string" } // JSON-encoded array
 },
 required: ["id", "rate", "extras_json"],
 additionalProperties: false
 }
 }
 },
 required: ["rooms"],
 additionalProperties: false
};

// Then parse extras_json yourself:
const extras = JSON.parse(result.rooms[0].extras_json);
```

### Option 2: Split Into Multiple Tools

Instead of one tool with a complex schema, split it into sequential calls:

```typescript
const tools = [
 {
 name: "create_booking_base",
 strict: true,
 input_schema: {
 type: "object",
 properties: {
 arrival: { type: "string" },
 departure: { type: "string" },
 firstName: { type: "string" },
 lastName: { type: "string" },
 numAdults: { type: "integer" }
 },
 required: ["arrival", "departure", "firstName", "lastName", "numAdults"],
 additionalProperties: false
 }
 },
 {
 name: "add_room_rates",
 strict: true,
 input_schema: {
 type: "object",
 properties: {
 bookingId: { type: "string" },
 roomId: { type: "string" },
 price: { type: "integer" }
 },
 required: ["bookingId", "roomId", "price"],
 additionalProperties: false
 }
 }
];
```

### Option 3: Selective strict: true

Apply `strict: true` only to simple tools, and validate complex tools manually:

```typescript
import { z } from "zod";

// Simple tool — use strict
const checkAvailability = {
 name: "check_availability",
 strict: true,
 input_schema: {
 type: "object",
 properties: {
 startDate: { type: "string" },
 endDate: { type: "string" }
 },
 required: ["startDate", "endDate"],
 additionalProperties: false
 }
};

// Complex tool — skip strict, validate with Zod
const createBooking = {
 name: "create_booking",
 // No strict: true
 input_schema: { /* complex schema */ }
};

// Manual validation for non-strict tools:
const BookingSchema = z.object({
 rooms: z.array(z.object({
 id: z.string(),
 rate: z.number(),
 extras: z.array(z.object({
 name: z.string(),
 cost: z.number()
 }))
 }))
});

function handleToolCall(name: string, input: unknown) {
 if (name === "create_booking") {
 const parsed = BookingSchema.safeParse(input);
 if (!parsed.success) {
 return { error: `Invalid input: ${parsed.error.message}` };
 }
 return processBooking(parsed.data);
 }
}
```

### Option 4: Use output_config Instead

For single-response structured output (not tool use), `output_config` may handle complex schemas better:

```typescript
const response = await client.messages.create({
 model: "claude-sonnet-4-5-20250929",
 max_tokens: 4096,
 messages: [{ role: "user", content: "Create a booking for..." }],
 output_config: {
 format: {
 type: "json_schema",
 schema: complexSchema
 }
 }
});
```

## Prevention

- **Keep strict tool schemas flat** — avoid more than 2 levels of nesting
- **Limit the number of strict tools** to 3-5 per request
- **Test schema complexity incrementally** — add properties one at a time and test
- **Use string-encoded JSON** for deeply nested sub-structures
- **Always have a non-strict fallback** with manual validation via Zod or similar

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=anthropic-sdk-strict-true-500-error)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Issues

- [Fix: "Compiled grammar is too large" Error](/anthropic-sdk-structured-output-grammar-too-large)
- [Fix: Claude API Error 400 Invalid Request](/claude-api-error-400-invalidrequesterror-explained/)
- [Advanced Claude Skills with Tool Use and Function Calling](/advanced-claude-skills-with-tool-use-and-function-calling/)

## Tools That Help

When debugging complex API integrations with structured outputs, a dev tool extension can help you inspect request/response payloads and identify which schema patterns trigger server-side failures.



