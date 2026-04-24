---
title: "Anthropic SDK TypeScript Tool Results"
description: "Fix Anthropic SDK TypeScript type mismatch on tool_result content blocks. Correct the ToolResultBlockParam type. Step-by-step solution."
permalink: /anthropic-sdk-typescript-type-mismatch-tool-results-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
error TS2322: Type '{ role: string; content: string; }' is not assignable
  to type 'MessageParam'.
  Types of property 'content' are incompatible.
    Type 'string' is not assignable to type 'ToolResultBlockParam[]'.

# Or:
error TS2345: Argument of type '{ tool_use_id: string; content: string; }'
  is not assignable to parameter of type 'ToolResultBlockParam'.
  Property 'type' is missing in type.
```

## The Fix

1. **Use the correct ToolResultBlockParam structure**

```typescript
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

// After receiving a tool_use block, send the result back:
const toolResult: Anthropic.MessageParam = {
  role: "user",
  content: [
    {
      type: "tool_result",
      tool_use_id: "toolu_abc123",  // from the tool_use response block
      content: "The weather in Tokyo is 22°C and sunny.",
    },
  ],
};

const response = await client.messages.create({
  model: "claude-sonnet-4-20250514",
  max_tokens: 1024,
  messages: [...previousMessages, toolResult],
});
```

2. **For multiple tool results, include all in one message**

```typescript
const multiToolResult: Anthropic.MessageParam = {
  role: "user",
  content: [
    {
      type: "tool_result",
      tool_use_id: "toolu_abc123",
      content: "Result 1",
    },
    {
      type: "tool_result",
      tool_use_id: "toolu_def456",
      content: "Result 2",
    },
  ],
};
```

3. **Verify the fix:**

```bash
npx ts-node -e "
import Anthropic from '@anthropic-ai/sdk';
const msg: Anthropic.MessageParam = {
  role: 'user',
  content: [{type: 'tool_result', tool_use_id: 'test', content: 'ok'}]
};
console.log('Type check passed:', msg.role, msg.content.length);
"
# Expected: Type check passed: user 1
```

## Why This Happens

The Anthropic TypeScript SDK uses discriminated union types for message content. A tool result message must have `role: "user"` with `content` as an array of `ToolResultBlockParam` objects, each including the `type: "tool_result"` discriminator. Passing a plain string as content or omitting the `type` field breaks TypeScript's type narrowing because the compiler cannot match the value to any variant in the union.

## If That Doesn't Work

- **Alternative 1:** Upgrade the SDK — `npm install @anthropic-ai/sdk@latest` — type definitions improve with each release
- **Alternative 2:** Use `as Anthropic.MessageParam` type assertion as a temporary escape hatch, but fix the structure
- **Check:** Run `npx tsc --noEmit` to see all type errors at once and identify which message params need fixing

## Prevention

Add to your `CLAUDE.md`:
```markdown
Always include type: "tool_result" in tool result content blocks. Tool results must be wrapped in an array under content, never as a bare string. Use Anthropic.MessageParam type annotation for all message objects.
```

**Related articles:** [Claude API Error 400 Fix](/claude-api-error-400-invalidrequesterror-explained/), [Claude API Error Handling](/claude-code-api-error-handling-standards/), [Claude tool_use Parsing Fix](/claude-tool-use-response-parsing-error-fix/)

## See Also

- [Anthropic SDK Python Async Context Manager — Fix (2026)](/anthropic-sdk-python-async-context-manager-error-fix/)
