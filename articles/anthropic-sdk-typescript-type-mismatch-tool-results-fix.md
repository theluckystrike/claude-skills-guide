---
sitemap: false
layout: default
title: "Anthropic SDK TypeScript Tool Results (2026)"
description: "Fix Anthropic SDK TypeScript type mismatch on tool_result content blocks. Correct the ToolResultBlockParam type. Step-by-step solution."
permalink: /anthropic-sdk-typescript-type-mismatch-tool-results-fix/
date: 2026-04-20
last_tested: "2026-04-21"
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


## Related Error Messages

This fix also applies if you see variations of this error:

- Connection or process errors with similar root causes in the same subsystem
- Timeout variants where the operation starts but does not complete
- Permission variants where access is denied to the same resource
- Configuration variants where the same setting is missing or malformed

If your specific error message differs slightly from the one shown above, the fix is likely the same. The key indicator is the operation that failed (shown in the stack trace) rather than the exact wording of the message.


## Frequently Asked Questions

### Does this error affect all operating systems?

This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows.

### Will this error come back after updating Claude Code?

Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes.

### Can this error cause data loss?

No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing.

### How do I report this error to Anthropic if the fix does not work?

Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error.


## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Building TypeScript APIs with Claude](/claude-code-hono-framework-typescript-api-workflow/)
- [Fix TypeScript Strict Mode Errors](/claude-code-typescript-strict-mode-errors-fix/)
- [Claude Code JSDoc TypeScript](/claude-code-jsdoc-typescript-documentation/)
- [TypeScript Playground Chrome Extension](/chrome-extension-typescript-playground/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Does this error affect all operating systems?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts."
      }
    },
    {
      "@type": "Question",
      "name": "Will this error come back after updating Claude Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Updates can occasionally reintroduce this error if the update changes default configurations or dependency requirements. After updating Claude Code, verify your project still builds and runs correctly. If the error returns, reapply the fix and check the changelog for breaking changes."
      }
    },
    {
      "@type": "Question",
      "name": "Can this error cause data loss?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with git..."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (node --version), (3) your Claude Code version (claude --version), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
