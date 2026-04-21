---
title: "Claude tool_use Response Parsing Error — Fix (2026)"
description: "Fix Claude tool_use response parsing errors. Handle mixed content blocks and validate tool input schema. Step-by-step solution."
permalink: /claude-tool-use-response-parsing-error-fix/
last_tested: "2026-04-21"
render_with_liquid: false
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
