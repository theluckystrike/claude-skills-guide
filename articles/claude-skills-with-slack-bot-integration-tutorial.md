---
layout: default
title: "Claude Skills with Slack Bot Integration Tutorial"
description: "Build a Slack bot that invokes Claude skills on demand for code review, document processing, and memory recall directly from Slack using Node.js."
date: 2026-03-13
categories: [tutorials]
tags: [claude-code, claude-skills, slack, bot, node-js, integration]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-skills-with-slack-bot-integration-tutorial/
---
author: "Claude Skills Guide"
reviewed: true
score: 9
---

# Claude Skills with Slack Bot Integration Tutorial

A Slack bot backed by Claude skills gives your team an AI assistant that lives inside their daily workspace. Team members can trigger code reviews with the [`tdd` skill](/claude-skills-guide/best-claude-skills-for-developers-2026/), process documents via `pdf`, recall project context through `supermemory`, or get UI feedback from `frontend-design` — all without leaving Slack. This tutorial covers the full Claude skills with Slack bot integration from app creation to skill invocation.

## Architecture Overview

```
Slack App (Bolt SDK)
    ↓  slash command / mention
Express Server (Node.js)
    ↓  HTTP POST
Anthropic API (Claude)
    ↓  skill-specific system prompt
Slack API (post message)
```

The bot uses Slack Bolt for Node.js, listens for slash commands or app mentions, routes them to Claude with the appropriate skill system prompt, and posts the response back.

## Prerequisites

- Node.js 18+
- A Slack workspace where you can create apps
- Claude API key from console.anthropic.com
- A server or tunneling tool (ngrok for local dev, or a platform like Railway/Render for production)

## Step 1: Create the Slack App

1. Go to [api.slack.com/apps](https://api.slack.com/apps) and click **Create New App**
2. Choose **From scratch**, name it "Claude Skills Bot", select your workspace
3. Under **OAuth & Permissions**, add Bot Token Scopes:
   - `app_mentions:read`
   - `chat:write`
   - `commands`
   - `files:read`
4. Under **Slash Commands**, create `/claude` with:
   - Request URL: `https://your-server.com/slack/events`
   - Short description: `Invoke Claude skills`
   - Usage hint: `[skill] [prompt]`
5. Enable **Event Subscriptions** and subscribe to `app_mention`
6. Install the app to your workspace and note:
   - Bot User OAuth Token (`xoxb-...`)
   - Signing Secret
   - App-Level Token (for Socket Mode)

## Step 2: Set Up the Node.js Project

```bash
mkdir claude-slack-bot && cd claude-slack-bot
npm init -y
npm install @slack/bolt @anthropic-ai/sdk dotenv
```

Create `.env`:
```
SLACK_BOT_TOKEN=xoxb-your-token
SLACK_SIGNING_SECRET=your-signing-secret
SLACK_APP_TOKEN=xapp-your-app-token
ANTHROPIC_API_KEY=your-claude-api-key
PORT=3000
```

## Step 3: Create the Bot Server

Create `index.js`:

```javascript
require('dotenv').config();
const { App } = require('@slack/bolt');
const Anthropic = require('@anthropic-ai/sdk');

const app = new App({
  token: process.env.SLACK_BOT_TOKEN,
  signingSecret: process.env.SLACK_SIGNING_SECRET,
  socketMode: true,
  appToken: process.env.SLACK_APP_TOKEN,
});

const claude = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

// Skill system prompts
const SKILLS = {
  tdd: `You are the TDD skill for Claude Code. Review code for test coverage gaps, 
identify untested paths, and suggest concrete unit tests. Be specific and actionable.`,
  
  pdf: `You are the PDF processing skill for Claude Code. Extract key information, 
summarize content, identify action items, and return structured output.`,
  
  'frontend-design': `You are the frontend-design skill for Claude Code. Review UI 
components, copy, and accessibility. Flag WCAG violations and suggest improvements.`,
  
  supermemory: `You are the supermemory skill for Claude Code. Help the user store, 
recall, and organize project context and information across sessions.`,
  
  default: `You are Claude Code, an expert software development assistant. 
Help with code, architecture, debugging, and technical questions.`,
};

async function callClaude(skill, prompt) {
  const systemPrompt = SKILLS[skill] || SKILLS.default;
  
  const message = await claude.messages.create({
    model: 'claude-opus-4-6',
    max_tokens: 1024,
    system: systemPrompt,
    messages: [{ role: 'user', content: prompt }],
  });
  
  return message.content[0].text;
}

// Handle /claude slash command: /claude tdd <code to review>
app.command('/claude', async ({ command, ack, respond }) => {
  await ack();
  
  const parts = command.text.trim().split(' ');
  const skill = SKILLS[parts[0]] ? parts[0] : 'default';
  const prompt = skill !== 'default' ? parts.slice(1).join(' ') : command.text;
  
  if (!prompt) {
    await respond('Usage: `/claude [skill] [your prompt]`\nSkills: tdd, pdf, frontend-design, supermemory');
    return;
  }
  
  await respond({ text: '_Claude is thinking..._', response_type: 'ephemeral' });
  
  try {
    const response = await callClaude(skill, prompt);
    await respond({
      text: `*Claude (${skill} skill):*\n${response}`,
      response_type: 'in_channel',
    });
  } catch (err) {
    await respond(`Error calling Claude: ${err.message}`);
  }
});

// Handle @mentions: @Claude-Skills-Bot tdd review this function...
app.event('app_mention', async ({ event, say }) => {
  const text = event.text.replace(/<@[A-Z0-9]+>/, '').trim();
  const parts = text.split(' ');
  const skill = SKILLS[parts[0]] ? parts[0] : 'default';
  const prompt = skill !== 'default' ? parts.slice(1).join(' ') : text;
  
  if (!prompt) {
    await say('Mention me with a skill and prompt. Example: `@Claude-Bot tdd review this code`');
    return;
  }
  
  try {
    const response = await callClaude(skill, prompt);
    await say({
      thread_ts: event.ts,
      text: `*Claude (${skill} skill):*\n${response}`,
    });
  } catch (err) {
    await say({ thread_ts: event.ts, text: `Error: ${err.message}` });
  }
});

(async () => {
  await app.start(process.env.PORT || 3000);
  console.log('Claude Skills Slack bot running');
})();
```

## Step 4: Handle File Uploads for PDF Skill

When users share files in Slack and mention the bot, fetch the file content before sending to Claude:

```javascript
app.event('app_mention', async ({ event, say, client }) => {
  let prompt = event.text.replace(/<@[A-Z0-9]+>/, '').trim();
  let fileContent = '';
  
  // Check for attached files
  if (event.files && event.files.length > 0) {
    const file = event.files[0];
    if (file.mimetype === 'text/plain' || file.name.endsWith('.md')) {
      const fileResp = await fetch(file.url_private, {
        headers: { Authorization: `Bearer ${process.env.SLACK_BOT_TOKEN}` },
      });
      fileContent = await fileResp.text();
      prompt = `pdf ${prompt}\n\nFile content:\n${fileContent.slice(0, 6000)}`;
    }
  }
  
  const skill = 'pdf';
  const response = await callClaude(skill, prompt);
  await say({ thread_ts: event.ts, text: response });
});
```

## Step 5: Add Conversation Threading with Supermemory

Use the [`supermemory` skill](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/) to give the bot memory across threads:

```javascript
const threadHistory = new Map(); // In production, use Redis

app.event('app_mention', async ({ event, say }) => {
  const threadKey = event.thread_ts || event.ts;
  const history = threadHistory.get(threadKey) || [];
  
  const userText = event.text.replace(/<@[A-Z0-9]+>/, '').trim();
  history.push({ role: 'user', content: userText });
  
  const message = await claude.messages.create({
    model: 'claude-opus-4-6',
    max_tokens: 1024,
    system: SKILLS.supermemory,
    messages: history.slice(-10), // keep last 10 turns
  });
  
  const reply = message.content[0].text;
  history.push({ role: 'assistant', content: reply });
  threadHistory.set(threadKey, history);
  
  await say({ thread_ts: event.ts, text: reply });
});
```

## Step 6: Deploy to Production

For production, deploy to Railway or Render:

```bash
# Railway deployment
npm install -g @railway/cli
railway login
railway init
railway add --plugin redis  # for thread history
railway up
```

Set environment variables in the Railway dashboard matching your `.env` file. Railway gives you a public URL to use as the Slack Request URL.

## Step 7: Format Responses for Slack

Claude's markdown doesn't map perfectly to Slack's mrkdwn format. Add a formatting helper:

```javascript
function toSlackMarkdown(text) {
  return text
    .replace(/\*\*(.*?)\*\*/g, '*$1*')        // bold
    .replace(/`{3}(\w+)?\n?([\s\S]*?)`{3}/g, '```$2```') // code blocks
    .replace(/^#{1,3} (.+)$/gm, '*$1*');       // headings to bold
}
```

## Conclusion

This Claude skills with Slack bot integration tutorial covers the full stack from app creation to multi-skill routing and production deployment. The pattern of mapping slash command arguments to skill system prompts is flexible — add new skills by adding entries to the `SKILLS` object. With `supermemory` thread history and `pdf` file handling, your team gets a genuinely useful AI assistant living inside Slack.

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/) — The full skills list to consider for Slack bot routing, including tdd, pdf, supermemory, and frontend-design
- [How to Share Claude Skills With Your Team](/claude-skills-guide/how-to-share-claude-skills-with-your-team/) — Guidance on distributing skills across a team, relevant to deploying a shared Slack bot backed by team-maintained skills
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/) — Managing API costs is critical for Slack bots that handle high message volumes; these techniques apply directly

Built by theluckystrike — More at [zovo.one](https://zovo.one)
