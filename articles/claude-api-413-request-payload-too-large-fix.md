---
title: "Claude API 413 Request Payload Too"
description: "Fix Claude API 413 request entity too large. Chunk oversized payloads and compress base64 images. Step-by-step solution."
permalink: /claude-api-413-request-payload-too-large-fix/
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Error

```
Error 413: Request Entity Too Large
{
  "type": "error",
  "error": {
    "type": "request_too_large",
    "message": "Request body exceeded maximum size of 30 MB."
  }
}
```

Or with the SDK:

```
anthropic.BadRequestError: Error code: 413 -
  Request too large. The request body size (42,318,592 bytes) exceeds
  the maximum allowed size (31,457,280 bytes).
```

## The Fix

1. **Check your request payload size before sending**

```python
import json
import sys

request_body = {
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 1024,
    "messages": messages  # your messages list
}
payload_bytes = len(json.dumps(request_body).encode("utf-8"))
print(f"Payload size: {payload_bytes / 1024 / 1024:.1f} MB")
assert payload_bytes < 30_000_000, f"Payload too large: {payload_bytes} bytes"
```

2. **Compress images before embedding them as base64**

```python
from PIL import Image
import io
import base64

def compress_image_for_api(image_path, max_size_mb=5):
    img = Image.open(image_path)
    # Resize if dimensions are excessive
    max_dim = 1568  # Claude's recommended max
    img.thumbnail((max_dim, max_dim), Image.LANCZOS)
    # Compress to JPEG
    buffer = io.BytesIO()
    img.save(buffer, format="JPEG", quality=80)
    b64 = base64.b64encode(buffer.getvalue()).decode()
    print(f"Image: {len(b64) / 1024:.0f} KB base64")
    return b64
```

3. **Verify the fix:**

```bash
python3 -c "
import json
# Simulate a reasonable payload
body = {'model':'claude-sonnet-4-20250514','max_tokens':1024,'messages':[{'role':'user','content':'test ' * 1000}]}
size = len(json.dumps(body).encode())
print(f'Payload: {size/1024:.1f} KB — {\"OK\" if size < 30_000_000 else \"TOO LARGE\"}')
"
# Expected: Payload: X.X KB — OK
```

## Why This Happens

Anthropic enforces a 30 MB hard limit on the HTTP request body. The most common trigger is base64-encoded images: a single 10 MB PNG becomes ~13.3 MB in base64, and sending multiple images quickly exceeds the limit. Large code files pasted directly into messages, extensive conversation histories, and verbose tool definitions also contribute. The token limit and the payload size limit are separate checks — you can exceed the byte limit before hitting the token limit.

## If That Doesn't Work

- **Alternative 1:** Use image URLs instead of base64 when the image is publicly accessible — this eliminates the payload size issue entirely
- **Alternative 2:** Split long conversations into summarized context + recent messages to reduce payload
- **Check:** Run `echo '{"messages":...}' | wc -c` on your serialized request to identify which message is the size offender

## Prevention

Add to your `CLAUDE.md`:
```markdown
Compress all images to JPEG quality 80, max dimension 1568px before API submission. Check payload size before sending — abort if over 25 MB. Trim conversation history to last 20 turns for long sessions.
```

**Related articles:** [Claude API 413 Explained](/claude-api-error-413-requesttoolarge-explained/), [Context Window Management](/claude-code-context-window-management-guide/), [Claude API Error Handling](/claude-code-api-error-handling-standards/)

## See Also

- [Knowledge Base Exceeds 512KB Maximum — Fix (2026)](/claude-code-knowledge-base-too-large-fix-2026/)
- [Claude API System Prompt Too Long Error — Fix (2026)](/claude-api-system-prompt-too-long-error-fix/)
- [Tool Result Exceeds 100KB Truncating — Fix (2026)](/claude-code-tool-result-too-large-fix-2026/)
- [Claude API Billing Quota Exceeded — Fix (2026)](/claude-api-billing-quota-exceeded-mid-request-fix/)
