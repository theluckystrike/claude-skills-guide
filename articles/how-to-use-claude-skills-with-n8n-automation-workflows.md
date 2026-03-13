---
layout: post
title: "How to Use Claude Skills with n8n Automation Workflows"
description: "Integrate Claude Code skills into n8n pipelines using the Anthropic API. Real patterns for PDF processing, TDD, and document generation automation."
date: 2026-03-13
categories: [workflows]
tags: [claude-code, claude-skills, n8n, automation, anthropic-api, pdf, tdd]
author: "Claude Skills Guide"
reviewed: true
score: 5
---

# How to Use Claude Skills with n8n Automation Workflows

n8n is a workflow automation tool that connects APIs, services, and data sources into repeatable pipelines. Claude skills are `.md` files in `~/.claude/skills/` designed to be invoked inside Claude Code sessions. Connecting these two systems requires understanding what each one actually does — and where the boundary sits.

## How the Integration Actually Works

Claude Code skills run inside interactive Claude Code sessions; they are not an HTTP API you can call from n8n's HTTP Request node on `localhost:11434` (that port belongs to Ollama). The correct integration point is the **Anthropic Messages API** (`https://api.anthropic.com/v1/messages`).

The pattern is: n8n calls the Anthropic API and passes the skill's instructions as part of the system prompt. You copy the relevant skill content from `~/.claude/skills/<skill-name>.md` and embed it in the system prompt so Claude behaves as if the skill is active.

```
n8n trigger → HTTP Request node (Anthropic API) → parse response → downstream action
```

This is a practical, working architecture. It does not require Claude Code to be running on the same machine as n8n.

## Setting Up the Anthropic API Node in n8n

In n8n, add an **HTTP Request** node with:

- **Method:** POST
- **URL:** `https://api.anthropic.com/v1/messages`
- **Headers:**
  - `x-api-key: {{ $env.ANTHROPIC_API_KEY }}`
  - `anthropic-version: 2023-06-01`
  - `content-type: application/json`
- **Body (JSON):**

```json
{
  "model": "claude-opus-4-6",
  "max_tokens": 2048,
  "system": "{{ $json.systemPrompt }}",
  "messages": [
    {
      "role": "user",
      "content": "{{ $json.userMessage }}"
    }
  ]
}
```

A preceding **Code** node builds `systemPrompt` by injecting the skill instructions. For example, to use the pdf skill's behavior:

```javascript
// n8n Code node
const pdfSkillInstructions = `You are operating with the pdf skill active.
When given a PDF file path or base64 content, extract:
- All text, preserving structure
- Tables as JSON arrays
- Named entities (dates, amounts, parties)
Return results as structured JSON.`;

return {
  json: {
    systemPrompt: pdfSkillInstructions,
    userMessage: `Extract invoice data from this document: ${$input.first().json.fileContent}`
  }
};
```

## Document Processing Pipeline

A practical invoice-processing workflow in n8n:

```
Trigger: Watch folder (new file)
→ Read file (base64 encode PDF)
→ Code node (build pdf skill prompt)
→ HTTP Request (Anthropic API)
→ Code node (parse JSON response)
→ Google Sheets / database insert
```

The Code node that builds the prompt:

```javascript
const fileContent = $input.first().json.fileContentBase64;
const fileName = $input.first().json.fileName;

const systemPrompt = `You are a document extraction assistant using the pdf skill.
Extract the following fields from invoices and return valid JSON only:
{
  "vendor_name": string,
  "invoice_number": string,
  "total_amount": number,
  "due_date": "YYYY-MM-DD",
  "line_items": [{"description": string, "quantity": number, "unit_price": number}]
}`;

return {
  json: {
    systemPrompt,
    userMessage: `Extract invoice data. File: ${fileName}\nContent (base64): ${fileContent}`
  }
};
```

## Test Generation with TDD Skill Instructions

For a GitHub webhook workflow that auto-generates tests on push:

```
Trigger: GitHub webhook (push event)
→ Filter: only .js/.ts files changed
→ HTTP Request (fetch changed file content from GitHub API)
→ Code node (build tdd skill prompt)
→ HTTP Request (Anthropic API)
→ GitHub API (create PR comment with suggested tests)
```

The tdd-skill Code node:

```javascript
const changedFile = $input.first().json.fileContent;
const filePath = $input.first().json.filePath;

const systemPrompt = `You are operating with the tdd skill active.
Given source code, generate a complete test file using Jest.
Follow these conventions:
- One describe block per exported function
- Cover happy path, edge cases, and error cases
- Use descriptive test names in plain English
Return only the test file content, no explanation.`;

return {
  json: {
    systemPrompt,
    userMessage: `Generate tests for ${filePath}:\n\n${changedFile}`
  }
};
```

## Memory-Augmented Workflows

The supermemory skill maintains context across sessions inside Claude Code. For n8n workflows, you replicate this by storing and retrieving context yourself — typically in a database or n8n's built-in key-value store — and injecting it into the system prompt on each run.

Customer support example:

```javascript
// Code node: load previous interactions from database
const customerEmail = $input.first().json.email;
const previousTickets = await $db.query(
  'SELECT summary FROM tickets WHERE customer_email = ? ORDER BY created_at DESC LIMIT 5',
  [customerEmail]
);

const contextSummary = previousTickets.map(t => t.summary).join('\n');

const systemPrompt = `You are a support assistant.
Previous interactions with this customer:
${contextSummary}

Use this history to provide continuity without asking the customer to repeat themselves.`;

return {
  json: {
    systemPrompt,
    userMessage: $input.first().json.newMessage
  }
};
```

## Report Generation with docx/pptx Skills

For scheduled report generation:

```
Trigger: Schedule (every Monday 9am)
→ HTTP Request (query your analytics API)
→ Code node (build docx skill prompt with data)
→ HTTP Request (Anthropic API)
→ Code node (write response to .docx file or send via email)
```

The docx skill prompt:

```javascript
const metrics = $input.first().json.weeklyMetrics;

const systemPrompt = `You are operating with the docx skill.
Generate a Word document structure as markdown that can be converted to .docx.
Use ## for section headings, | for tables, and **bold** for key metrics.`;

const userMessage = `Generate a weekly metrics report with this data:
- Total users: ${metrics.users}
- Revenue: $${metrics.revenue}
- Conversion rate: ${metrics.conversionRate}%
- Top 3 issues by volume: ${metrics.topIssues.join(', ')}`;

return { json: { systemPrompt, userMessage } };
```

## Error Handling

n8n workflows calling the Anthropic API should handle:

- **Rate limits (429):** Add a Wait node and retry with exponential backoff
- **Context length errors (400):** Truncate input in the preceding Code node
- **Empty or malformed JSON responses:** Validate with a Code node before downstream steps

```javascript
// Code node: validate Anthropic response
const responseContent = $input.first().json.content[0].text;

let parsed;
try {
  parsed = JSON.parse(responseContent);
} catch (e) {
  // Return error state for n8n error branch
  return { json: { error: true, rawResponse: responseContent } };
}

return { json: { error: false, data: parsed } };
```

## What to Expect

n8n + Anthropic API is a proven, production-ready combination. The skill layer adds value by giving you tested, reusable system prompts for specific domains — document extraction, test generation, report formatting — rather than writing one-off prompts for each workflow. The skill `.md` file becomes the canonical source of the system prompt; update it once and all workflows that reference it pick up the change.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
