---
layout: default
title: "How to Use Claude Skills with n8n Automation Workflows"
description: "Connect Claude Code skills to n8n workflows via Anthropic API. Practical patterns for PR review and document processing automation."
date: 2026-03-13
categories: [workflows]
tags: [claude-code, claude-skills, n8n, automation, anthropic-api, workflows]
author: "Claude Skills Guide"
reviewed: true
score: 8
---
{% raw %}

# How to Use Claude Skills with n8n Automation Workflows

n8n is a self-hostable workflow automation tool with a visual node editor. Pairing it with Claude unlocks AI-powered steps inside any automation — from processing incoming webhook data to summarizing documents and triggering downstream actions. This guide covers how to call Claude from n8n using the Anthropic API, with patterns that replicate skill behavior via system prompts.

## What You Can Build

Before getting into setup, here are realistic automation patterns that combine n8n with Claude intelligence:

- Receive a GitHub webhook on PR open, send the diff to Claude for [TDD review](/claude-skills-guide/best-claude-skills-for-developers-2026/), post findings to Slack
- Watch a Google Drive folder for new PDFs, extract content via [Claude's pdf skill](/claude-skills-guide/best-claude-skills-for-data-analysis/), store structured data in a database
- Monitor RSS feeds, summarize articles with Claude, send a daily digest email
- Capture form submissions, run through Claude for classification, route to the appropriate team

## Prerequisites

- n8n instance (self-hosted via Docker or n8n.cloud)
- Claude API key from console.anthropic.com

## Step 1: Store the API Key in n8n

In n8n, go to **Credentials > New Credential > HTTP Header Auth**:

- Name: `Claude API`
- Header Name: `x-api-key`
- Header Value: `your_claude_api_key`

## Step 2: Add an HTTP Request Node for the Anthropic API

Call Claude directly from n8n using an HTTP Request node:

**HTTP Request node settings:**
- Method: `POST`
- URL: `https://api.anthropic.com/v1/messages`
- Authentication: Header Auth (select your `Claude API` credential)
- Additional Headers:
  - `anthropic-version`: `2023-06-01`
  - `content-type`: `application/json`

**Body (JSON):**
```json
{
  "model": "claude-opus-4-6",
  "max_tokens": 1024,
  "messages": [
    {
      "role": "user",
      "content": "{{ $json.prompt }}"
    }
  ]
}
```

This gives you a basic Claude call. To invoke a specific skill's behavior, add a system prompt.

## Step 3: Apply Skill Behavior via System Prompts

Claude [skills are markdown files](/claude-skills-guide/skill-md-file-format-explained-with-examples/) that define how Claude should approach tasks. In n8n, you replicate this by including the skill's guidance as a system prompt. For TDD review behavior:

```json
{
  "model": "claude-opus-4-6",
  "max_tokens": 2048,
  "system": "You are a TDD-focused code reviewer. Analyze code for test coverage gaps, untested code paths, and missing error handling. Suggest concrete unit tests for each uncovered path. Be specific about test names and assertions.",
  "messages": [
    {
      "role": "user",
      "content": "Review this code:

{{ $json.code }}"
    }
  ]
}
```

For PDF document extraction behavior:

```json
{
  "model": "claude-opus-4-6",
  "max_tokens": 2048,
  "system": "You are a document analyst. Extract structured information from the provided text. Return JSON with: summary (2-3 sentences), key_points (array of strings), action_items (array), and entities (people, organizations, dates mentioned).",
  "messages": [
    {
      "role": "user",
      "content": "Extract information from this document:

{{ $json.documentText }}"
    }
  ]
}
```

## Step 4: Build a Full Workflow — PR Review Automation

Here is a concrete n8n workflow that triggers on GitHub PRs and posts a Claude review to Slack.

**Nodes in order:**

1. **Webhook** node — receives GitHub PR webhook
2. **HTTP Request** node — fetches the PR diff from GitHub API:
   - URL: `https://api.github.com/repos/{{ $json.body.repository.full_name }}/pulls/{{ $json.body.number }}/files`
   - Authentication: Header Auth (GitHub token)
3. **Code** node — extracts the diff text:
```javascript
const files = $input.all().map(item => item.json);
const diff = files
  .map(f => `### ${f.filename}\n${f.patch || '(binary or large file)'}`)
  .join('\n\n');
return [{ json: { diff } }];
```
4. **HTTP Request** node (Claude) — sends diff to Anthropic API with TDD system prompt
5. **Code** node — extracts response text:
```javascript
const content = $input.first().json.content;
const text = content[0].text;
return [{ json: { review: text } }];
```
6. **Slack** node — posts review to `#code-review` channel

## Step 5: Handle Long Documents with Batching

n8n workflows can time out on long Claude responses. Use the Split In Batches node to process large inputs in chunks:

```javascript
// Code node: split text into 3000-char chunks
const text = $input.first().json.content;
const chunks = [];
for (let i = 0; i < text.length; i += 3000) {
  chunks.push({ json: { chunk: text.slice(i, i + 3000), index: i / 3000 } });
}
return chunks;
```

Then loop the HTTP Request node over each chunk and merge responses with a Merge node set to **Combine All**.

## Step 6: Error Handling and Retries

Wrap your Claude HTTP Request node in a **Try/Catch** using n8n's error workflow feature. For rate limit (429) errors:

```javascript
// Code node after HTTP Request
const statusCode = $input.first().json.statusCode;
if (statusCode === 429) {
  return [{ json: { retry: true, waitSeconds: 60 } }];
}
return [{ json: { retry: false, result: $input.first().json } }];
```

Then connect a **Wait** node (60 seconds) and loop back to the Claude HTTP Request node.

## Useful n8n + Claude Patterns

| Trigger | System Prompt Persona | Output |
|---|---|---|
| New email (IMAP) | Email classifier | Category and routing |
| File upload (S3) | Document analyst | Extracted structured data |
| Code push (GitHub) | TDD code reviewer | Test coverage analysis |
| Form submission | Content validator | Validation result + suggestions |

## Conclusion

Connecting Claude to n8n automation uses the Anthropic API directly via HTTP Request nodes. The system prompt carries the skill behavior — you define what role Claude should play for each workflow step. Start with the PR review workflow above and layer in additional system prompt personas as you build out more automation pipelines.

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/) — Skills worth integrating into n8n pipelines
- [How to Connect Claude Skills to External APIs](/claude-skills-guide/how-to-connect-claude-skills-to-external-apis-guide/) — Tool use and API integration patterns
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/) — Keep n8n workflow API costs under control

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
