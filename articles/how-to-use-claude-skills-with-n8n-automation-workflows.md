---
layout: default
title: "How to Use Claude Skills with n8n Automation Workflows"
description: "A practical guide to connecting Claude Code skills with n8n automation workflows, enabling AI-powered nodes in your no-code and low-code pipelines."
date: 2026-03-13
author: theluckystrike
---

# How to Use Claude Skills with n8n Automation Workflows

n8n is a self-hostable workflow automation tool with a visual node editor. Pairing it with Claude skills unlocks AI-powered steps inside any automation — from processing incoming webhook data to summarizing documents and triggering downstream actions. This guide covers how to use Claude skills with n8n automation workflows using both the HTTP Request node and a custom Claude node configuration.

## What You Can Build

Before getting into setup, here are realistic automation patterns that combine n8n with Claude skills:

- Receive a GitHub webhook on PR open → run the `tdd` skill to review changed files → post a Slack message with findings
- Watch a Google Drive folder for new PDFs → process them with the `pdf` skill → store extracted data in a database
- Monitor RSS feeds → summarize articles with Claude → send a daily digest email
- Capture form submissions → use `supermemory` to store context → personalize follow-up responses

## Prerequisites

- n8n instance (self-hosted via Docker or n8n.cloud)
- Claude API key from console.anthropic.com
- Claude Code CLI installed on the same machine or accessible via a sidecar container

## Step 1: Store the API Key in n8n

In n8n, go to **Credentials > New Credential > HTTP Header Auth**:

- Name: `Claude API`
- Header Name: `x-api-key`
- Header Value: `your_claude_api_key`

Alternatively store it as a generic credential and reference it via `{{ $credentials.claudeApi.apiKey }}` in expressions.

## Step 2: Add an HTTP Request Node for Claude API

The quickest way to call Claude from n8n is a direct HTTP Request node pointed at the Anthropic API:

**HTTP Request node settings:**
- Method: `POST`
- URL: `https://api.anthropic.com/v1/messages`
- Headers:
  - `x-api-key`: `{{ $credentials.claudeApi.apiKey }}`
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

This gives you a basic Claude call. To invoke a specific skill, you extend the system prompt.

## Step 3: Invoke a Claude Skill via System Prompt

Claude skills activate when the system prompt instructs Claude to behave according to that skill's persona and capabilities. For example, to invoke the `tdd` skill:

```json
{
  "model": "claude-opus-4-6",
  "max_tokens": 2048,
  "system": "You are operating as the TDD skill for Claude Code. Your role is to review code for test coverage, identify untested paths, and suggest concrete unit tests using the project's existing test framework.",
  "messages": [
    {
      "role": "user",
      "content": "Review this code:\n\n{{ $json.code }}"
    }
  ]
}
```

For the `pdf` skill, adjust the system prompt to focus on document extraction and formatting.

## Step 4: Build a Full Workflow — PR Review Automation

Here is a concrete n8n workflow that triggers on GitHub PRs and posts a Claude review to Slack.

**Nodes in order:**

1. **Webhook** node — receives GitHub PR webhook
2. **HTTP Request** node — fetches the PR diff from GitHub API
3. **Code** node — extracts the diff text:
```javascript
const diff = $input.first().json.files
  .map(f => `### ${f.filename}\n${f.patch || ''}`)
  .join('\n\n');
return [{ json: { diff } }];
```
4. **HTTP Request** node (Claude) — sends diff to Claude with tdd system prompt
5. **Code** node — extracts response text:
```javascript
const content = $input.first().json.content;
const text = content[0].text;
return [{ json: { review: text } }];
```
6. **Slack** node — posts review to `#code-review` channel

## Step 5: Use Claude CLI via Execute Command Node

If you have Claude Code CLI installed on your n8n host, you can call skills directly from the **Execute Command** node for richer skill execution:

```bash
echo "{{ $json.fileContent }}" | \
  claude --skill pdf \
  --prompt "Extract all action items from this document" \
  --stdin
```

Set environment variables in the node:
- `CLAUDE_API_KEY`: `{{ $credentials.claudeApi.apiKey }}`

This is especially useful for `supermemory` skill calls that need persistent session state beyond a single HTTP call.

## Step 6: Handle Pagination and Long Outputs

n8n workflows can time out on long Claude responses. Use the Split In Batches node to process large inputs in chunks:

```javascript
// Code node: split text into 2000-char chunks
const text = $input.first().json.content;
const chunks = [];
for (let i = 0; i < text.length; i += 2000) {
  chunks.push({ json: { chunk: text.slice(i, i + 2000), index: i / 2000 } });
}
return chunks;
```

Then loop the HTTP Request node over each chunk and merge responses with a Merge node set to **Combine All**.

## Step 7: Error Handling and Retries

Wrap your Claude HTTP Request node in a **Try/Catch** using n8n's error workflow feature. Create a separate error workflow that:

1. Logs the failed node and input to a database
2. Waits 30 seconds using a **Wait** node
3. Re-triggers the original workflow via webhook

For rate limit (429) errors specifically:

```javascript
// Code node after HTTP Request
const statusCode = $input.first().json.statusCode;
if (statusCode === 429) {
  // Signal retry needed
  return [{ json: { retry: true, waitSeconds: 60 } }];
}
return [{ json: { retry: false, result: $input.first().json } }];
```

## Useful n8n + Claude Skill Patterns

| Trigger | Claude Skill | Output |
|---|---|---|
| New email (IMAP) | `supermemory` | Categorize and store context |
| File upload (S3) | `pdf` | Extract structured data |
| Code push (GitHub) | `tdd` | Review and suggest tests |
| Form submission | `frontend-design` | Validate UI copy and accessibility |

## Conclusion

Using Claude skills with n8n automation workflows puts AI decision-making inside any pipeline you can build visually. The HTTP Request node handles simple prompt calls, while the Execute Command node unlocks full skill execution for heavier workloads. Start with the PR review workflow above and layer in `supermemory` once you need state across workflow runs.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
