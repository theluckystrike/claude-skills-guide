---
title: "Claude tool_use Response Parsing Error"
description: "Fix Claude tool_use response parsing errors. Handle mixed content blocks and validate tool input schema. Step-by-step solution."
permalink: /claude-tool-use-response-parsing-error-fix/
last_tested: "2026-04-21"
---

## The Error

```
KeyError: 'text'
# When accessing response.content[0].text but the block is type tool_use

# Or:
json.decoder.JSONDecodeError: Expecting value: line 1 column 1
# When parsing tool_use input that contains non-JSON content

# Or:
ValidationError: 1 validation error for ToolUseBlock
input -> location
  field required (type=value_error.missing)
```

## The Fix

1. **Handle mixed content blocks by checking the block type**

```python
import anthropic

response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    tools=[{"name": "get_weather", "description": "Get weather",
            "input_schema": {"type": "object",
                           "properties": {"location": {"type": "string"}},
                           "required": ["location"]}}],
    messages=[{"role": "user", "content": "What's the weather in Tokyo?"}]
)

for block in response.content:
    if block.type == "text":
        print(block.text)
    elif block.type == "tool_use":
        print(f"Tool: {block.name}, Input: {block.input}")
        # block.input is already a dict — do NOT json.loads() it
```

2. **Validate tool inputs before processing**

```python
def handle_tool_call(block):
    assert block.type == "tool_use", f"Expected tool_use, got {block.type}"
    assert isinstance(block.input, dict), "Tool input must be a dict"

    if block.name == "get_weather":
        location = block.input.get("location")
        assert location is not None, "Missing required field: location"
        return fetch_weather(location)
```

3. **Verify the fix:**

```bash
python3 -c "
import anthropic
client = anthropic.Anthropic()
r = client.messages.create(
    model='claude-sonnet-4-20250514', max_tokens=256,
    tools=[{'name':'test','description':'Test tool','input_schema':{'type':'object','properties':{'q':{'type':'string'}},'required':['q']}}],
    messages=[{'role':'user','content':'Use the test tool with q=hello'}])
for b in r.content:
    print(f'{b.type}: {getattr(b, \"text\", None) or getattr(b, \"input\", None)}')
"
# Expected: tool_use: {'q': 'hello'}
```

## Why This Happens

Claude's tool_use responses return `content` as a list of mixed block types — both `text` and `tool_use` blocks can appear in a single response. Code that assumes `response.content[0].text` exists will crash when the first block is a tool call. Additionally, the SDK already deserializes `tool_use.input` into a Python dict, so calling `json.loads()` on it produces a TypeError or JSONDecodeError.

## If That Doesn't Work

- **Alternative 1:** Use `response.stop_reason == "tool_use"` to detect when tool calls are present before iterating blocks
- **Alternative 2:** Add `tool_choice={"type": "auto"}` explicitly to let the model decide whether to use tools or respond with text
- **Check:** Print `[b.type for b in response.content]` to see the exact block layout you're receiving

## Prevention

Add to your `CLAUDE.md`:
```markdown
Always iterate response.content blocks and check block.type before accessing .text or .input. Never assume the first content block is text. Tool input is already a dict — never call json.loads() on it.
```

**Related articles:** [Claude API Error 400 Fix](/claude-api-error-400-invalidrequesterror-explained/), [Claude API Error Handling](/claude-code-api-error-handling-standards/), [Errors Atlas](/errors-atlas/)

## See Also

- [Claude Tool Use Hidden Token Costs Explained](/claude-tool-use-hidden-token-costs-explained/)


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

- [Claude Code for Lambda Response](/claude-code-for-lambda-response-streaming-workflow/)
- [Claude Code API Response Caching Guide](/claude-code-api-response-caching-guide/)
- [Fix Slow Response Latency (2026)](/claude-code-slow-response-how-to-fix-latency-issues/)
- [Response Truncation Max Tokens Hit Fix](/claude-code-response-truncation-max-tokens-fix-2026/)

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
        "text": "This error can occur on macOS, Linux, and Windows (WSL). The exact error message may differ slightly between platforms, but the root cause and fix are the same. macOS users may see additional Gatekeeper or notarization prompts. Linux users should check that the relevant system packages are installed. Windows users should ensure they are running inside WSL2, not native Windows."
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
        "text": "No, this error occurs before or during an operation and does not corrupt existing files. Claude Code's edit operations are atomic — they either complete fully or not at all. However, if the error occurs during a multi-step operation, you may have partial changes that need to be reviewed with `git diff` before continuing."
      }
    },
    {
      "@type": "Question",
      "name": "How do I report this error to Anthropic if the fix does not work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Open an issue at github.com/anthropics/claude-code with: (1) the full error message including stack trace, (2) your Node.js version (`node --version`), (3) your Claude Code version (`claude --version`), (4) your operating system and version, and (5) the command or operation that triggered the error."
      }
    }
  ]
}
</script>
