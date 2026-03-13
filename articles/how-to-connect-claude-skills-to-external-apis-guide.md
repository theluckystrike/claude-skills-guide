---
layout: post
title: "How to Connect Claude Skills to External APIs Guide"
description: "Connect Claude Code skills to external APIs: tool use patterns, authentication, rate limiting, and building reliable AI-powered integrations."
date: 2026-03-13
author: "Claude Skills Guide"
reviewed: true
score: 8
categories: [guides, integrations]
tags: [claude-code, claude-skills, api, integration]
---

# How to Connect Claude Skills to External APIs Guide

Claude Code skills become significantly more powerful when they can call external APIs to fetch real data, trigger actions, or store results. Whether you are extending the [`tdd` skill](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) to pull test results from a CI API, using [`supermemory`](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) to store context in an external memory service, or having [`pdf`](/claude-skills-guide/articles/best-claude-skills-for-data-analysis/) push extracted data to a CRM — the pattern for connecting Claude skills to external APIs follows consistent principles. This guide covers how to connect Claude skills to external APIs with practical code and production-ready patterns.

## The Core Pattern: Tool Use

Claude communicates with external APIs through **tool use** (also called function calling). You define tools with JSON Schema, Claude decides when to call them based on context, the results come back to Claude, and it continues reasoning. This loop is the foundation of all external API integration.

```
User → Claude (with skill system prompt)
           ↓
     Decides to call tool
           ↓
     Your code calls external API
           ↓
     Result returned to Claude
           ↓
     Claude continues + responds
```

## Step 1: Define Your Tools

Tools are JSON Schema objects describing the function signature:

```javascript
const weatherTool = {
  name: 'get_weather',
  description: 'Get current weather for a location. Use this when the user asks about weather.',
  input_schema: {
    type: 'object',
    properties: {
      location: {
        type: 'string',
        description: 'City name or coordinates, e.g. "London" or "51.5,-0.1"',
      },
      units: {
        type: 'string',
        enum: ['celsius', 'fahrenheit'],
        description: 'Temperature units',
        default: 'celsius',
      },
    },
    required: ['location'],
  },
};

const githubTool = {
  name: 'get_github_pr',
  description: 'Fetch a GitHub pull request diff and metadata for code review',
  input_schema: {
    type: 'object',
    properties: {
      owner: { type: 'string', description: 'Repo owner' },
      repo: { type: 'string', description: 'Repository name' },
      pr_number: { type: 'integer', description: 'PR number' },
    },
    required: ['owner', 'repo', 'pr_number'],
  },
};
```

## Step 2: Build the Tool Execution Loop

```javascript
require('dotenv').config();
const Anthropic = require('@anthropic-ai/sdk');

const claude = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

// Map tool names to handler functions
const toolHandlers = {
  get_weather: async (args) => {
    const resp = await fetch(
      `https://api.openweathermap.org/data/2.5/weather?q=${args.location}&appid=${process.env.WEATHER_API_KEY}&units=metric`
    );
    const data = await resp.json();
    return {
      location: data.name,
      temperature: data.main.temp,
      description: data.weather[0].description,
      humidity: data.main.humidity,
    };
  },
  
  get_github_pr: async (args) => {
    const resp = await fetch(
      `https://api.github.com/repos/${args.owner}/${args.repo}/pulls/${args.pr_number}`,
      { headers: { Authorization: `token ${process.env.GITHUB_TOKEN}` } }
    );
    const pr = await resp.json();
    return {
      title: pr.title,
      body: pr.body,
      additions: pr.additions,
      deletions: pr.deletions,
      changed_files: pr.changed_files,
      state: pr.state,
    };
  },
};

async function runWithTools(systemPrompt, userMessage, tools) {
  const messages = [{ role: 'user', content: userMessage }];
  
  while (true) {
    const response = await claude.messages.create({
      model: 'claude-opus-4-6',
      max_tokens: 2048,
      system: systemPrompt,
      tools,
      messages,
    });
    
    // No tool calls — return final response
    if (response.stop_reason === 'end_turn') {
      const textBlock = response.content.find(b => b.type === 'text');
      return textBlock?.text || '';
    }
    
    // Process tool calls
    if (response.stop_reason === 'tool_use') {
      messages.push({ role: 'assistant', content: response.content });
      
      const toolResults = [];
      
      for (const block of response.content) {
        if (block.type !== 'tool_use') continue;
        
        const handler = toolHandlers[block.name];
        if (!handler) {
          toolResults.push({
            type: 'tool_result',
            tool_use_id: block.id,
            content: `Error: unknown tool ${block.name}`,
            is_error: true,
          });
          continue;
        }
        
        try {
          const result = await handler(block.input);
          toolResults.push({
            type: 'tool_result',
            tool_use_id: block.id,
            content: JSON.stringify(result),
          });
        } catch (err) {
          toolResults.push({
            type: 'tool_result',
            tool_use_id: block.id,
            content: `Error: ${err.message}`,
            is_error: true,
          });
        }
      }
      
      messages.push({ role: 'user', content: toolResults });
    }
  }
}
```

## Step 3: Apply Skill System Prompts

Combine tool use with skill prompts to get skill-specific behavior with API access:

```javascript
const TDD_WITH_GITHUB = `You are the TDD skill for Claude Code. 
When reviewing code, use the get_github_pr tool to fetch PR details. 
Focus on test coverage, untested paths, and concrete test suggestions.`;

// Run TDD review on a GitHub PR
const review = await runWithTools(
  TDD_WITH_GITHUB,
  'Review PR #123 in the acme/backend repo for test coverage',
  [githubTool]
);
console.log(review);
```

## Step 4: Handle Authentication Patterns

Different APIs use different auth methods. Build reusable auth helpers:

```javascript
// OAuth2 Bearer token
function bearerAuth(token) {
  return { Authorization: `Bearer ${token}` };
}

// API Key header
function apiKeyHeader(key, headerName = 'X-API-Key') {
  return { [headerName]: key };
}

// Basic auth
function basicAuth(user, pass) {
  const encoded = Buffer.from(`${user}:${pass}`).toString('base64');
  return { Authorization: `Basic ${encoded}` };
}

// Refresh OAuth tokens automatically
async function refreshAndCall(url, options, refreshFn) {
  let resp = await fetch(url, options);
  if (resp.status === 401) {
    const newToken = await refreshFn();
    options.headers.Authorization = `Bearer ${newToken}`;
    resp = await fetch(url, options);
  }
  return resp;
}
```

## Step 5: Rate Limiting and Retry Logic

Most APIs enforce rate limits. Implement exponential backoff:

```javascript
async function fetchWithRetry(url, options, maxRetries = 3) {
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    const resp = await fetch(url, options);
    
    if (resp.status === 429) {
      const retryAfter = parseInt(resp.headers.get('retry-after') || '1', 10);
      const delay = Math.max(retryAfter * 1000, Math.pow(2, attempt) * 1000);
      console.warn(`Rate limited. Waiting ${delay}ms (attempt ${attempt + 1}/${maxRetries})`);
      await new Promise(r => setTimeout(r, delay));
      continue;
    }
    
    if (!resp.ok && attempt < maxRetries) {
      await new Promise(r => setTimeout(r, Math.pow(2, attempt) * 500));
      continue;
    }
    
    return resp;
  }
  throw new Error(`Failed after ${maxRetries} retries`);
}
```

## Step 6: Validate and Sanitize API Responses

Never pass raw API responses directly to Claude without sanitization:

```javascript
function sanitizeForClaude(data, maxLength = 10000) {
  // Remove potentially sensitive fields
  const cleaned = JSON.parse(JSON.stringify(data, (key, val) => {
    if (['password', 'secret', 'token', 'key'].some(k => key.toLowerCase().includes(k))) {
      return '[REDACTED]';
    }
    return val;
  }));
  
  // Truncate to avoid token overflows
  const str = JSON.stringify(cleaned, null, 2);
  if (str.length > maxLength) {
    return str.slice(0, maxLength) + '\n... [truncated]';
  }
  return str;
}
```

## Step 7: Caching API Results

Reduce latency and API costs by caching tool results:

```javascript
const cache = new Map();

async function cachedToolCall(toolName, args, handler, ttlMs = 60000) {
  const key = `${toolName}:${JSON.stringify(args)}`;
  const cached = cache.get(key);
  
  if (cached && Date.now() - cached.timestamp < ttlMs) {
    return cached.data;
  }
  
  const data = await handler(args);
  cache.set(key, { data, timestamp: Date.now() });
  return data;
}
```

## Step 8: Production Patterns

For production Claude skills with API integrations:

```javascript
// Structured logging for tool calls
function logToolCall(name, args, result, durationMs) {
  console.log(JSON.stringify({
    event: 'tool_call',
    tool: name,
    args_keys: Object.keys(args),
    success: !result?.error,
    duration_ms: durationMs,
    timestamp: new Date().toISOString(),
  }));
}

// Circuit breaker for flaky APIs
class CircuitBreaker {
  constructor(threshold = 5, timeout = 60000) {
    this.failures = 0;
    this.threshold = threshold;
    this.timeout = timeout;
    this.lastFailure = null;
    this.state = 'closed'; // closed, open, half-open
  }
  
  async call(fn) {
    if (this.state === 'open') {
      if (Date.now() - this.lastFailure > this.timeout) {
        this.state = 'half-open';
      } else {
        throw new Error('Circuit breaker open — API unavailable');
      }
    }
    
    try {
      const result = await fn();
      this.failures = 0;
      this.state = 'closed';
      return result;
    } catch (err) {
      this.failures++;
      this.lastFailure = Date.now();
      if (this.failures >= this.threshold) this.state = 'open';
      throw err;
    }
  }
}

const githubBreaker = new CircuitBreaker();
```

## Common API Integration Patterns by Skill

| Claude Skill | External API | Tool Purpose |
|---|---|---|
| `tdd` | GitHub API | Fetch PR diffs, CI status |
| `pdf` | AWS S3 / Cloudflare R2 | Download documents for processing |
| `supermemory` | Supabase / Redis | Persist and recall context |
| `frontend-design` | Figma API | Fetch design tokens and components |

## Conclusion

Connecting Claude skills to external APIs transforms static prompts into dynamic workflows that operate on live data. The tool use loop in Step 2 is the foundation — everything else (auth, retries, caching, circuit breakers) makes it production-ready. Start by wiring one skill to one API, verify the tool use loop works correctly, then add resilience patterns as you scale.

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) — Profiles the skills most commonly wired to external APIs (tdd, pdf, supermemory) with practical invocation patterns
- [Skill .md File Format Explained With Examples](/claude-skills-guide/articles/skill-md-file-format-explained-with-examples/) — Understanding the `tools` field in skill YAML is essential for giving skills access to the custom API tools you define
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) — API response caching and sanitization are also key token cost reduction strategies worth pairing with external API integrations

Built by theluckystrike — More at [zovo.one](https://zovo.one)
