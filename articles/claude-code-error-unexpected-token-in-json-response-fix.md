---
layout: default
title: "Fix Unexpected Token in JSON — Claude Code (2026)"
description: "Fix the unexpected token in JSON error in Claude Code with 4 practical solutions covering malformed responses, encoding, and streaming issues."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-error-unexpected-token-in-json-response-fix/
reviewed: true
score: 7
categories: [troubleshooting]
tags: [claude-code, claude-skills]
render_with_liquid: false
last_tested: "2026-04-21"
geo_optimized: true
---

{% raw %}
Claude Code Error: Unexpected Token in JSON Response Fix

The "unexpected token in JSON" error is one of the most common issues developers encounter when working with Claude Code. This error typically occurs when Claude attempts to parse a response that isn't valid JSON, breaking the communication pipeline between the AI and your tools. Understanding the root causes and having a toolkit of solutions ready will save you hours of frustration.

This guide covers diagnosis techniques, practical fixes, prevention strategies, and edge cases that catch developers off-guard. including some that aren't well-documented anywhere else.

## What Causes This Error

When Claude Code makes tool calls or interacts with external services, it expects JSON-formatted responses. The "unexpected token" error surfaces when the response contains malformed JSON. either from a tool output, an API call, or a skill that returns improperly formatted data.

The error message usually looks like one of these:

```
SyntaxError: Unexpected token < in JSON at position 0
SyntaxError: Unexpected token T in JSON at position 0
SyntaxError: Unexpected end of JSON input
JSON.parse: unexpected character at line 1 column 1
```

The specific token in the error message is actually a useful diagnostic clue. `<` almost always means you got an HTML response (often a 404 or error page). `T` usually means plain text starting with "The" or "TypeError". `Unexpected end of JSON input` points to truncation. the response was cut off mid-stream.

Common scenarios triggering this error include:

- API endpoints returning HTML or plain text instead of JSON
- Tool outputs containing special characters that break JSON parsing
- Custom skills returning markdown-formatted content instead of structured data
- Network responses with encoding issues or truncated data
- Authentication failures returning HTML login pages instead of API data
- Rate-limited responses returning plain-text error messages instead of JSON error objects
- Proxy or CDN error pages intercepting requests before they reach the API

## Understanding the Error in Context

Claude Code's tool-use system works by making structured calls and expecting structured responses. The pipeline looks roughly like this:

```
Claude Code -> Tool call (JSON) -> Tool / API -> Response -> Claude Code parses response
```

When that response isn't valid JSON, the parser throws immediately. The session doesn't recover gracefully. it halts with the unexpected token error and your work stops.

This is by design. Claude Code doesn't try to "guess" what a malformed response meant, because guessing incorrectly could lead to your code being written with bad assumptions about what the tool returned. The strict parsing behavior is actually a safety feature, even when it's annoying.

## Diagnosis Techniques

Before applying fixes, identify where the malformed JSON originates. Start by examining the error message itself. Claude Code usually indicates which tool or skill produced the invalid response.

Use the `Read` tool to inspect recent tool outputs in your conversation history. Look for responses that contain:
- Unescaped quotes or special characters
- Markdown formatting code blocks
- Incomplete JSON objects or arrays
- Non-UTF8 encoded characters

If you're using custom skills, check the skill definition for any double-curly-brace or percent-curly-brace Liquid template syntax that might interfere with JSON parsing.

A systematic debugging checklist:

```bash
Step 1: Test the endpoint directly in your terminal
curl -s -o /tmp/api_response.json -w "%{http_code}" https://api.example.com/endpoint
Check the HTTP status code. 200 doesn't guarantee JSON

Step 2: Inspect the raw response
cat /tmp/api_response.json | head -20
If it starts with <!DOCTYPE or <html, you got HTML back

Step 3: Validate the JSON explicitly
cat /tmp/api_response.json | python3 -m json.tool
This will show exactly where parsing fails with a line/column number

Step 4: Check the Content-Type header
curl -sI https://api.example.com/endpoint | grep -i content-type
Should be application/json, not text/html or text/plain
```

## Practical Solutions

## Solution 1: Validate API Responses

When calling external APIs, ensure they return valid JSON:

```python
import requests
import json

def call_api(url):
 response = requests.get(url)
 # Force JSON parsing to catch errors early
 try:
 data = response.json()
 return data
 except json.JSONDecodeError as e:
 print(f"Invalid JSON response: {e}")
 print(f"Response text: {response.text[:200]}")
 raise
```

This approach catches malformed responses before they reach Claude's parsing layer.

A more solid version that also handles HTTP error status codes:

```python
import requests
import json

def call_api_safe(url, headers=None):
 try:
 response = requests.get(url, headers=headers, timeout=10)
 response.raise_for_status() # Raises for 4xx and 5xx status codes
 except requests.exceptions.HTTPError as e:
 # Log the full response body. often contains clues
 raise RuntimeError(f"HTTP {response.status_code}: {response.text[:300]}") from e
 except requests.exceptions.Timeout:
 raise RuntimeError(f"Request to {url} timed out after 10 seconds")

 content_type = response.headers.get("Content-Type", "")
 if "application/json" not in content_type:
 raise RuntimeError(
 f"Expected JSON but got Content-Type: {content_type}\n"
 f"Response body: {response.text[:200]}"
 )

 return response.json()
```

The `raise_for_status()` call is especially important. Without it, a 401 Unauthorized response that returns an HTML login page will silently flow through to the JSON parser and produce the unexpected token error. and you'll waste time debugging JSON when the real issue is authentication.

## Solution 2: Escape Special Characters in Tool Outputs

If your tool produces text with quotes or special characters, escape them properly:

```bash
Instead of echoing raw JSON
echo '{"message": "Here's a quote"}' # Breaks!

Use proper escaping
echo '{"message": "Here'"'"'s a quote"}'
Or use printf
printf '{"message": "Here'\''s a quote"}\n'
```

For more complex scenarios, consider using a JSON library to generate properly escaped output.

In shell scripts, the safest pattern is to avoid building JSON by hand entirely. Use a tool that knows how to serialize JSON correctly:

```bash
Fragile. manual JSON construction breaks on special characters
echo "{\"name\": \"$USERNAME\", \"path\": \"$FILE_PATH\"}"

Robust. let python handle serialization
python3 -c "
import json, sys, os
print(json.dumps({
 'name': os.environ.get('USERNAME', ''),
 'path': os.environ.get('FILE_PATH', '')
}))
"

Or use jq for JSON construction from shell
jq -n --arg name "$USERNAME" --arg path "$FILE_PATH" \
 '{"name": $name, "path": $path}'
```

The jq approach is particularly clean for shell scripts because it handles all escaping automatically, including newlines, tabs, and Unicode characters that would silently corrupt manually constructed JSON.

## Solution 3: Configure Your Skills Correctly

When creating custom skills using tools like the skill-creator, ensure your skill definitions don't interfere with JSON parsing. Avoid placing unescaped curly braces in skill descriptions:

```yaml
---
name: my-skill
description: Processes data using the (variable) pattern
This causes issues! Use escaped brackets or rephrase
---
```

Instead, structure your skill descriptions without template variables that could confuse the JSON parser.

If your skill's markdown file needs to reference code that contains curly braces or percent-brace syntax, use literal description language rather than embedding the actual syntax. For example: "processes Jinja2-style template variables" rather than embedding a literal `{{ variable }}` example inside the skill definition itself.

## Solution 4: Handle Truncated Responses

Truncation is a less-discussed cause of this error but a real one. Long API responses, streaming endpoints, or responses from slow network connections can arrive incomplete. The JSON parser sees a valid opening but no closing brace.

```python
def fetch_with_length_validation(url):
 response = requests.get(url, timeout=30)
 content = response.text

 # Check that the response ends where JSON should end
 content_stripped = content.strip()
 if not (
 (content_stripped.startswith("{") and content_stripped.endswith("}")) or
 (content_stripped.startswith("[") and content_stripped.endswith("]"))
 ):
 raise ValueError(
 f"Response appears truncated. First 50 chars: {content_stripped[:50]!r} "
 f"Last 50 chars: {content_stripped[-50:]!r}"
 )

 return json.loads(content)
```

This won't catch all truncation cases (a truncated nested object will still start and end with braces), but it catches the most common form where the response cuts off mid-field.

## Working with Claude Skills

Claude skills like pdf, tdd, and frontend-design often interact with external tools and APIs. When these skills produce errors, the "unexpected token" issue frequently stems from how they handle their outputs.

For instance, when using the pdf skill to generate documents from markdown, ensure your markdown doesn't contain inline JSON-like patterns that get misinterpreted. The docx skill handles similar scenarios by providing clearer output formatting.

The supermemory skill may encounter this error when storing or retrieving metadata. Always validate the data structure before passing it to skills that expect specific JSON schemas.

When debugging skill-related JSON errors, check whether the skill's output is being piped into another tool. Skills that produce rich text or markdown may work fine as standalone output but fail when another skill tries to parse that output as structured data. If you're chaining skills, make sure intermediate outputs are either valid JSON or explicitly converted to JSON before the next skill receives them.

## Prevention Strategies

## Implement Response Validation

Create a wrapper function that validates all responses before they reach Claude:

```javascript
function validateJsonResponse(response) {
 try {
 const parsed = JSON.parse(response);
 return { valid: true, data: parsed };
 } catch (error) {
 return {
 valid: false,
 error: error.message,
 raw: response.substring(0, 100)
 };
 }
}
```

A more complete version that also normalizes common non-JSON responses:

```javascript
function safeParseJson(responseText, context = "") {
 if (typeof responseText !== "string") {
 throw new TypeError(`Expected string response${context ? ` for ${context}` : ""}, got ${typeof responseText}`);
 }

 const trimmed = responseText.trim();

 if (trimmed === "") {
 throw new SyntaxError(`Empty response body${context ? ` from ${context}` : ""}`);
 }

 // Detect common non-JSON responses and give actionable errors
 if (trimmed.startsWith("<!DOCTYPE") || trimmed.startsWith("<html")) {
 throw new SyntaxError(
 `Got HTML instead of JSON${context ? ` from ${context}` : ""}. ` +
 "Check authentication headers and endpoint URL."
 );
 }

 if (trimmed.startsWith("Error:") || trimmed.startsWith("TypeError")) {
 throw new SyntaxError(
 `Got plain-text error instead of JSON: ${trimmed.substring(0, 100)}`
 );
 }

 try {
 return JSON.parse(trimmed);
 } catch (err) {
 throw new SyntaxError(
 `JSON parse failed${context ? ` for ${context}` : ""}: ${err.message}. ` +
 `Response starts with: ${trimmed.substring(0, 80)!r}`
 );
 }
}
```

The context parameter is valuable in production. when you have 20 different API calls, knowing which one produced the bad response saves significant debugging time.

## Use Type-Safe APIs

When building integrations, prefer APIs that guarantee JSON responses. Check documentation for content-type headers and implement fallback handling for non-JSON responses.

## Test Skills in Isolation

Before deploying custom skills to production, test them with varied inputs using the xlsx skill to validate JSON outputs across different data scenarios. This is particularly important for skills that handle user-generated content.

A simple test pattern for skills:

```bash
Test a custom skill with edge-case inputs before relying on it in workflows
claude --print "Using the my-custom-skill skill: process this input: O'Brien & Associates <test@example.com>"
Check whether special characters in the input cause the skill output to break JSON parsing
```

## Error Recovery

When you encounter this error during a session:

1. Pause the current operation. Don't continue with corrupted data
2. Identify the source. Check which tool or skill produced the invalid response
3. Clear and retry. Use Claude Code's reset capability to clear the problematic context
4. Fix the root cause. Apply the appropriate solution from above
5. Resume with validation. Implement checks to prevent recurrence

For persistent errors that keep recurring despite fixes, consider whether the tool or API you're calling is genuinely returning valid JSON under load. Some APIs return JSON in development but serve plain-text errors under rate limiting or high traffic. Building a retry wrapper with exponential backoff that also validates the response type on each attempt can catch this class of intermittent failures.

## Conclusion

The "unexpected token in JSON response" error is manageable once you understand its origins and have a systematic approach to debugging. By validating API responses, properly escaping special characters, and carefully configuring your skills, you can prevent this error from disrupting your workflow.

Remember to test your integrations thoroughly, especially when combining multiple skills like supermemory with custom API calls. Most importantly, always implement error handling that catches JSON parsing failures early. before they reach Claude Code's processing layer. The error message's unexpected token character is your first diagnostic clue: use it to narrow down whether you're dealing with an HTML response, a plain-text error, truncated data, or a genuine JSON syntax problem, then apply the appropriate fix from this guide.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-error&utm_campaign=claude-code-error-unexpected-token-in-json-response-fix)**

47/500 founding spots. Price goes up when they're gone.

</div>

Related Reading

- [Claude Skill Invalid YAML Syntax Error: How to Debug](/claude-code-skill-invalid-yaml-syntax-error-how-to-debug/). See also
- [Claude Skill YAML Front Matter Parsing Error Fix](/claude-skill-yaml-front-matter-parsing-error-fix/). See also
- [Skill MD File Format Explained With Examples](/claude-skill-md-format-complete-specification-guide/). See also
- [Claude Skills Troubleshooting Hub](/troubleshooting-hub/). See also

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


