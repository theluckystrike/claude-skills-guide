---
layout: default
title: "Fix: Claude API Error 413 (2026)"
description: "Fix Claude API 413 request_too_large error. Covers request size limits for Messages, Batch, and Files endpoints with solutions for large payloads."
date: 2026-04-15
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-api-error-413-requesttoolarge-explained/
reviewed: true
score: 7
categories: [troubleshooting]
tags: [claude-api, sdk-python, api-errors, request-limits]
geo_optimized: true
last_tested: "2026-04-22"
---

# Claude API Error 413 request_too_large Fix

The 413 `request_too_large` error means your API request exceeds the maximum allowed size. This error is returned by Cloudflare before the request even reaches Anthropic's servers.

## The Error

```json
{
 "type": "error",
 "error": {
 "type": "request_too_large",
 "message": "Request exceeds the maximum allowed number of bytes."
 }
}
```

## Quick Fix

1. Check that your request body is under the size limit for your endpoint.
2. For Messages API: maximum is 32 MB.
3. For Batch API: maximum is 256 MB.
4. For large documents, compress or chunk your input.

## What Causes This

The request size (entire HTTP body in bytes) exceeds the endpoint's maximum:

| Endpoint | Maximum Request Size |
|----------|---------------------|
| Messages API | 32 MB |
| Token Counting API | 32 MB |
| Batch API | 256 MB |
| Files API | 500 MB |

This is a raw byte limit on the HTTP request body, which includes all message content, base64-encoded images, tool definitions, and system prompts.

Base64 encoding increases the size of binary content by approximately 33%. A 24 MB image becomes approximately 32 MB when base64-encoded, which would hit the Messages API limit.

## Full Solution

### Check Your Request Size

```python
import anthropic
import json

client = anthropic.Anthropic()

# Build your request
request_body = {
 "model": "claude-sonnet-4-6",
 "max_tokens": 1024,
 "messages": [{"role": "user", "content": "Your content here..."}]
}

# Check size before sending
size_bytes = len(json.dumps(request_body).encode("utf-8"))
size_mb = size_bytes / (1024 * 1024)
print(f"Request size: {size_mb:.2f} MB")

if size_mb > 32:
 print("WARNING: Exceeds 32 MB Messages API limit")
```

### Handle Large Images

Base64-encoded images are a common cause. Resize or compress images before sending:

```python
import anthropic
import base64
from pathlib import Path

client = anthropic.Anthropic()

# Check image size before encoding
image_path = Path("large_image.png")
raw_size_mb = image_path.stat().st_size / (1024 * 1024)
encoded_size_mb = raw_size_mb * 1.33 # Base64 overhead

print(f"Raw: {raw_size_mb:.1f} MB, Encoded: {encoded_size_mb:.1f} MB")

if encoded_size_mb > 20: # Leave room for other request content
 print("Image too large. Resize or compress first.")
else:
 image_data = base64.b64encode(image_path.read_bytes()).decode("utf-8")
 message = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{
 "role": "user",
 "content": [
 {"type": "image", "source": {"type": "base64", "media_type": "image/png", "data": image_data}},
 {"type": "text", "text": "Describe this image"}
 ]
 }]
 )
```

### Chunk Large Text Inputs

Split large documents across multiple requests:

```python
import anthropic

client = anthropic.Anthropic()

def chunk_text(text, max_chars=100000):
 """Split text into chunks at paragraph boundaries."""
 chunks = []
 current = ""
 for paragraph in text.split("\n\n"):
 if len(current) + len(paragraph) > max_chars:
 if current:
 chunks.append(current)
 current = paragraph
 else:
 current = current + "\n\n" + paragraph if current else paragraph
 if current:
 chunks.append(current)
 return chunks

large_document = "..." # Your large text
chunks = chunk_text(large_document)

summaries = []
for i, chunk in enumerate(chunks):
 assert i < 100, "Too many chunks" # Bounded loop
 response = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": f"Summarize this section:\n\n{chunk}"}]
 )
 summaries.append(response.content[0].text)
```

### Use the Batch API for Large Workloads

The Batch API supports 256 MB per request, 4x more than the Messages API:

```python
import anthropic
from anthropic.types.message_create_params import MessageCreateParamsNonStreaming
from anthropic.types.messages.batch_create_params import Request

client = anthropic.Anthropic()

# Up to 256 MB of requests
batch = client.messages.batches.create(
 requests=[
 Request(
 custom_id=f"doc-{i}",
 params=MessageCreateParamsNonStreaming(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": f"Analyze: {doc}"}]
 )
 )
 for i, doc in enumerate(documents[:100000]) # Up to 100k per batch
 ]
)
```

### Catch the Error

```python
import anthropic

client = anthropic.Anthropic()

try:
 message = client.messages.create(
 model="claude-sonnet-4-6",
 max_tokens=1024,
 messages=[{"role": "user", "content": very_large_content}]
 )
except anthropic.APIStatusError as e:
 if e.status_code == 413:
 print(f"Request too large. Reduce content size.")
 else:
 raise
```

## Prevention

1. **Check size before sending**: Calculate `len(json.dumps(body).encode('utf-8'))` before making the request.
2. **Compress images**: Use JPEG instead of PNG, and resize to reasonable dimensions before base64 encoding.
3. **Use the Batch API**: For large workloads, the 256 MB limit gives you 8x more room.
4. **Chunk documents**: Split large documents into sections and process them individually.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-api-error-413-requesttoolarge-explained)**

47/500 founding spots. Price goes up when they're gone.

</div>

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude API Error 400 invalid_request_error Fix](/claude-api-error-400-invalidrequesterror-explained/) -- handle format errors that occur before the size check.
- [Claude API Error 429 rate_limit_error Fix](/claude-api-error-429-ratelimiterror-explained/) -- understand token-based limits separate from byte-based limits.
- [Claude Prompt Caching API Guide](/claude-prompt-caching-api-guide/) -- cache large system prompts to reduce repeated transfer overhead.
- [Claude Streaming API Guide](/claude-streaming-api-guide/) -- streaming does not change request size limits but improves response handling.
- [Claude Python SDK Getting Started](/claude-python-sdk-getting-started-example/) -- basic SDK setup.


