---
layout: default
title: "How to Use Telegram MCP Server (2026)"
description: "Automate Telegram bots with MCP server and Claude Code. Setup guide for message handling, workflow automation, and secure bot integration."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [tutorials]
tags: [claude-code, claude-skills, telegram, mcp, bot-automation, workflow]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /telegram-mcp-server-bot-automation-workflow/
geo_optimized: true
---

# Telegram MCP Server Bot Automation Workflow

The Telegram Model Context Protocol server enables Claude Code to interact with Telegram bots through natural language. This integration opens powerful possibilities for building responsive automation workflows, from handling customer support queries to managing team notifications. This guide walks through setting up the Telegram MCP server and creating practical automation workflows that can handle real production use cases.

## Prerequisites and Initial Setup

Before building Telegram bot automations, you need a Telegram bot token and the MCP server configured. Create a new bot through @BotFather on Telegram if you do not already have one. The BotFather will provide an API token that authenticates your bot. For guidance on storing bot tokens safely, see the [MCP credential management and secrets handling guide](/mcp-credential-management-and-secrets-handling/).

Install the Telegram MCP server package:

```bash
npm install -g @modelcontextprotocol/server-telegram
```

Configure the MCP server in your `~/.claude/mcp-servers.json` file:

```json
{
 "mcpServers": {
 "telegram": {
 "command": "npx",
 "args": ["-y", "@modelcontextprotocol/server-telegram"],
 "env": {
 "TELEGRAM_BOT_TOKEN": "your-bot-token-here"
 }
 }
 }
}
```

Replace `your-bot-token-here` with the token from BotFather. Restart Claude Code and verify the connection by asking it to list your bot information.

## Verifying the Connection

After restarting Claude Code, run a quick sanity check to confirm the MCP server is available and authenticated:

```
Ask Claude Code: "Using the Telegram MCP server, get my bot's information and list any recent updates."
```

If the server is configured correctly, Claude Code will call the `getMe` method and return your bot's username, ID, and capabilities. If you see an authentication error, double-check that your token is copied exactly as BotFather provided it, with no leading or trailing whitespace.

## Configuring Webhook vs Polling

The Telegram Bot API supports two update delivery modes: long polling and webhooks. For local development, long polling is simpler because it does not require a publicly accessible server. For production, webhooks are more reliable and efficient.

With the MCP server, you typically use polling during development sessions since Claude Code initiates the requests. For production deployments where your automation needs to respond to messages even when you are not actively running Claude Code, set up a webhook endpoint:

```bash
Register a webhook URL with Telegram
curl -X POST "https://api.telegram.org/bot<YOUR_TOKEN>/setWebhook" \
 -H "Content-Type: application/json" \
 -d '{"url": "https://yourserver.com/webhook/telegram"}'

Verify webhook status
curl "https://api.telegram.org/bot<YOUR_TOKEN>/getWebhookInfo"
```

The webhook response will confirm whether Telegram can reach your endpoint and show any pending error counts that might indicate connection problems.

## Building Your First Automated Response

The Telegram MCP server exposes tools for sending messages, handling updates, and managing bot interactions. You can combine these capabilities with Claude skills to create sophisticated responses.

For instance, integrate the pdf skill to automatically generate and send documents when users request them:

```javascript
// Skill: auto-invoice-generator

When the user requests an invoice or receipt, generate a PDF using the pdf skill
and send it to their Telegram chat. Extract the relevant details from their message
or ask for clarification on amount, date, and description.
```

This pattern demonstrates how MCP server tools work alongside Claude skills. The skill defines the behavior while the MCP server handles the actual Telegram communication.

## Sending Rich Messages with Telegram Formatting

Telegram supports several message formatting modes. Markdown and HTML both work well for structured responses. Here is how to send formatted messages with the MCP server:

```javascript
// Skill: formatted-status-responder

When responding with system status, format the message using Telegram's MarkdownV2:
- Use *bold* for critical metrics
- Use `monospace` for values and counts
- Use > for block quotes when referencing previous user messages
- Use numbered lists for sequential steps

Example output structure:
*System Status Report*
CPU Usage: `78%`
Memory: `4\.2 GB / 8 GB`
Uptime: `14 days, 3 hours`

> Your last check was 2 hours ago
```

Note that MarkdownV2 requires escaping special characters like dots, parentheses, and hyphens with a backslash. This is easy to forget when building templates, so keep a reference handy.

## Inline Keyboards for Interactive Workflows

One of Telegram's most powerful bot features is inline keyboards. buttons that appear beneath messages and trigger callback queries. This turns your bot from a one-way notification system into an interactive tool:

```javascript
// Skill: approval-workflow-bot

When a deployment request arrives:
1. Send a message with the deployment details
2. Attach an inline keyboard with two buttons: "Approve" and "Reject"
3. When the user taps a button, handle the callback_query
4. Update the original message to show the decision and who made it
5. Trigger the appropriate downstream action based on approval or rejection
```

This pattern is extremely useful for team workflows where you want a human in the loop before consequential actions execute.

## Handling Different Message Types

Your bot can process various message types including text, photos, documents, and voice messages. Create separate workflows for each type using Claude Code's conditional logic.

Text messages work well for command-based interactions:

```javascript
// Skill: telegram-command-handler

Process incoming Telegram messages with these rules:
- Messages starting with "/status" - respond with system health check
- Messages containing "help" - list available commands
- Messages with "alert" or "warning" - escalate to priority queue
- All other messages - use supermemory skill to search for relevant context before responding
```

Document and photo uploads require additional processing. Use the frontend-design skill to generate preview images for documents, or apply the tdd skill to create test cases from user-submitted specifications.

## Processing File Uploads

When users send documents or photos to your bot, Telegram stores them on its servers and provides a `file_id` you can use to download them. This enables a wide range of document processing workflows:

```javascript
// Skill: document-processor-bot

When a user sends a document:
1. Extract the file_id from the message's document field
2. Call getFile to retrieve the download path
3. Download the file using the provided URL
4. Detect the file type:
 - PDF: use the pdf skill to extract text and summarize
 - Image: describe the content using vision capabilities
 - CSV/XLSX: parse the data and generate a summary with key statistics
5. Send the analysis back to the user
6. Store the result in supermemory keyed by file name and user ID
```

Voice message transcription is another high-value workflow. Users who prefer speaking over typing can send voice messages, and your bot can transcribe and process them:

```javascript
// Skill: voice-message-handler

When a voice message arrives:
1. Retrieve the audio file from Telegram's servers
2. Transcribe the audio using available speech-to-text tools
3. Process the transcription as if it were a text message
4. Respond in text, and optionally offer to send a voice reply
```

## Handling Group vs Private Messages

Bots behave differently in group chats versus private conversations. In groups, bots only receive messages if they are mentioned by username or if the message is a reply to one of the bot's previous messages (unless the bot has read access explicitly enabled). Factor this into your command parsing:

```javascript
// Skill: group-aware-command-handler

Check the chat type before processing:
- chat.type === "private": process all messages normally
- chat.type === "group" or "supergroup":
 - Only respond to messages that mention @YourBotUsername
 - Or messages that are replies to the bot
 - Strip the @mention from the command before processing
 - Keep responses concise to avoid flooding group chats
```

## Creating Workflow Automation Chains

Build multi-step automation workflows by chaining Claude skills together. A common pattern involves receiving user input, processing it through one or more skills, and then sending formatted results back to Telegram.

Consider a bug reporting workflow:

```javascript
// Skill: telegram-bug-reporter

1. Parse the bug report from the user's message
2. Use the tdd skill to generate a minimal reproduction test case
3. Create a formatted report with:
 - Bug description
 - Suggested test case
 - Severity assessment
4. Send the report to the designated bug tracker channel
5. Confirm submission to the user with a reference number
```

This workflow demonstrates the power of combining MCP server capabilities with specialized Claude skills. Each skill handles its domain while the Telegram MCP server manages the communication layer.

## CI/CD Integration Workflow

Teams that use CI/CD pipelines can route build and deployment notifications through Telegram, enabling engineers to monitor and control deployments from their phones:

```javascript
// Skill: cicd-notification-bot

Receive CI/CD webhook events and route them appropriately:

On build failure:
1. Send a message to the #builds channel with the commit SHA, branch, and error summary
2. Tag the engineer who pushed the commit
3. Include an inline keyboard: "View Logs" | "Retry Build" | "Skip for Now"

On deployment success:
1. Send a success message to #deployments with version number and timestamp
2. List the changes included in this deployment
3. Provide a rollback button that triggers the previous version deployment

On test failures:
1. Use the tdd skill to analyze the failure patterns
2. Group failures by test suite and summarize root causes
3. Create a threaded message with detailed failure output
```

This kind of integration replaces email notifications with actionable, interactive messages that engineers actually read.

## GitHub Issues to Telegram Bridge

Connect your GitHub repository to Telegram to get notified of issues and pull requests without constantly checking the GitHub UI:

```javascript
// Skill: github-telegram-bridge

Process GitHub webhook events:

New issue opened:
- Format: " New Issue #123: [title]" with labels and assignees
- Send to project channel
- If labeled "urgent" or "critical", also send to team leads group

PR opened/updated:
- Show diff summary and reviewer assignments
- Include inline buttons: "View on GitHub" | "Request Review" | "Assign to Me"

Issue closed:
- Summarize the resolution
- Update thread if using Telegram's thread feature for issue tracking
```

## Managing Conversations and State

Effective bot automation requires maintaining conversation context across multiple messages. The [Claude supermemory skill](/claude-supermemory-skill-persistent-context-explained/) provides persistent memory that your Telegram bot can use:

```javascript
// Skill: telegram-support-bot

Use supermemory to maintain conversation history with this user.
When handling support requests:
1. Check supermemory for previous interactions related to the issue
2. Reference past solutions that worked for similar problems
3. Update supermemory with the resolution once the issue is resolved
4. If the issue requires escalation, gather context from supermemory first
```

For more complex state management, use the [MCP memory server for persistent agent storage](/mcp-memory-server-persistent-storage-for-claude-agents/) to maintain shared conversation state across sessions.

## Implementing Conversation Flows

Some workflows require multi-turn conversations where the bot needs to collect several pieces of information before executing an action. Implement these as state machines stored in memory:

```javascript
// Skill: multi-step-form-bot

Manage a multi-step data collection flow using this state machine:

States:
- IDLE: waiting for a trigger command like /new_report
- COLLECTING_TITLE: asked for report title, waiting for response
- COLLECTING_DESCRIPTION: asked for description, waiting for response
- COLLECTING_PRIORITY: showing priority selection keyboard, waiting for callback
- CONFIRMING: showing summary, waiting for confirm/cancel
- SUBMITTING: processing submission

At each state, store the collected data in memory keyed by chat_id.
When the user sends a message, check their current state and transition accordingly.
Handle /cancel at any state to abort and clear stored data.
```

This approach keeps each conversation's state isolated and makes the flow predictable regardless of how many users are interacting simultaneously.

## Broadcasting and Scheduled Notifications

Automate team communications by setting up scheduled broadcasts. Create a skill that handles periodic messages:

```javascript
// Skill: daily-team-standup

1. Query your project management system for today's tasks
2. Use the tdd skill to identify tests that ran overnight
3. Compile a summary message with:
 - Today's priorities
 - Yesterday's completed items
 - Any blocking issues
4. Send to the team's Telegram channel
5. Tag team members whose input is needed
```

You can schedule skills using cron expressions or external triggers. The key is structuring your skill to gather information dynamically rather than sending static messages.

## Building a Metrics Dashboard via Telegram

Instead of building a web dashboard, deliver daily metrics summaries directly to Telegram. This is particularly useful for small teams that want visibility without the overhead of maintaining a dashboard infrastructure:

```javascript
// Skill: daily-metrics-digest

Every morning at 9 AM (scheduled via cron):
1. Query your analytics API for yesterday's key metrics
2. Compare against the 7-day rolling average
3. Flag any metrics that deviate more than 15% from average
4. Format the digest with:
 - Headline numbers (visits, conversions, revenue)
 - Trend indicators (up/down arrows with percentage change)
 - Anomaly alerts for unusual values
 - A "View Full Report" link
5. Send to the team channel
6. If any critical anomalies exist, also send to the on-call group
```

## Rate Limiting Broadcasts

Telegram enforces rate limits on bot message sending. For groups and channels, the limit is roughly 20 messages per minute. When broadcasting to many users, implement a queue with delays:

```javascript
// Skill: bulk-notification-sender

When sending announcements to multiple users:
1. Build the full recipient list first
2. Send messages in batches of 20
3. Wait 1 second between batches
4. Track delivery status for each recipient
5. Retry failed deliveries up to 3 times with exponential backoff
6. Report final delivery statistics to the admin
```

Respecting rate limits prevents your bot from being temporarily blocked by Telegram's infrastructure.

## Error Handling and Fallbacks

Good automation requires proper error handling. Configure fallback responses for scenarios your primary workflows do not cover:

```javascript
// Skill: telegram-fallback-handler

When a message doesn't match any automation pattern:
1. Acknowledge receipt of the message
2. Explain that a human will review it
3. Forward to the appropriate team channel with priority tag
4. Store in supermemory for future reference
5. Provide estimated response time
```

This ensures users always receive acknowledgment even when their request falls outside automated workflows.

## Handling Telegram API Errors

The Telegram Bot API returns structured error codes that you can handle gracefully. The most common errors and how to address them:

| Error Code | Meaning | Recommended Action |
|------------|---------|-------------------|
| 400 Bad Request | Malformed message or invalid parameters | Log the request body, fix formatting |
| 401 Unauthorized | Invalid bot token | Check token, alert admin immediately |
| 403 Forbidden | Bot was blocked by user | Mark user as inactive, stop sending |
| 429 Too Many Requests | Rate limit exceeded | Implement exponential backoff |
| 500 Internal Server Error | Telegram server issue | Retry after a short delay |

```javascript
// Skill: resilient-telegram-sender

When sending any message:
1. Attempt the send operation
2. On 429 error: read the retry_after value from the response and wait that many seconds
3. On 403 error: update the user record to mark them as having blocked the bot
4. On 500 error: retry up to 3 times with 5-second intervals
5. If all retries fail: queue the message for manual review
6. Log all errors with full context for debugging
```

## Monitoring Bot Health

Set up a health monitoring skill that periodically checks whether your bot is functioning correctly:

```javascript
// Skill: bot-health-monitor

Every 15 minutes:
1. Call getMe to verify the bot token is still valid
2. Send a test message to a designated health-check chat
3. Verify the message was delivered successfully
4. Check the pending updates queue length
5. If queue length exceeds 100: alert the admin and process the backlog
6. If any check fails: send an alert to the admin's personal chat

Track uptime percentage and send a weekly summary report.
```

## Security Considerations

When building Telegram bot automations, follow security best practices. Never expose your bot token in public repositories. Use environment variables for sensitive configuration. Implement rate limiting to prevent abuse.

The MCP server's permission system controls what your bot can access. Review permissions regularly and grant only necessary access levels to each automation workflow.

## Validating Incoming Requests

If you are using webhooks, validate that incoming requests genuinely come from Telegram. One approach is to check the IP ranges that Telegram uses for webhook delivery, though this can change. A more solid approach is to use a secret token in the webhook URL:

```bash
Set a webhook with a secret token
curl -X POST "https://api.telegram.org/bot<TOKEN>/setWebhook" \
 -H "Content-Type: application/json" \
 -d '{
 "url": "https://yourserver.com/webhook/telegram",
 "secret_token": "your-random-secret-here"
 }'
```

Telegram then includes this token in the `X-Telegram-Bot-Api-Secret-Token` header of every webhook request. Reject any requests that do not include the correct token.

## Restricting Bot Access by User

For internal tools, restrict bot access to authorized users only. Maintain an allowlist of Telegram user IDs that are permitted to use each command:

```javascript
// Skill: access-controlled-bot

Before processing any command:
1. Extract the sender's user_id from the update
2. Check the allowlist for this command type
3. If the user is not in the allowlist:
 - Send a polite "access denied" message
 - Log the attempt with user ID, username, and requested command
 - Alert the admin if the same user attempts access more than 3 times
4. If authorized, proceed with the command

Maintain separate allowlists for:
- /status commands (broader access)
- /deploy commands (engineering team only)
- /admin commands (bot admin only)
```

## Conclusion

The Telegram MCP server transforms Claude Code into a powerful bot development platform. By combining MCP server tools with specialized skills like pdf, tdd, supermemory, and frontend-design, you can create sophisticated automation workflows that handle complex interactions. Start with simple command responses and gradually build toward multi-step workflows as your requirements grow.

The patterns in this guide. from inline keyboards and multi-step forms to CI/CD integrations and health monitoring. represent the range of what is possible when you treat Telegram not just as a messaging app but as an interface layer for your automation infrastructure. The key is to design workflows around what users actually need, handle errors gracefully, and keep security constraints in mind from the beginning.

---

---

<div class="mastery-cta">

I hit this exact error six months ago. Then I wrote a CLAUDE.md that tells Claude my stack, my conventions, and my error handling patterns. Haven't seen it since.

I run 5 Claude Max subs, 16 Chrome extensions serving 50K users, and bill $500K+ on Upwork. These CLAUDE.md templates are what I actually use. Not theory — production configs.

**[Grab the templates — $99 once, free forever →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-mcp&utm_campaign=telegram-mcp-server-bot-automation-workflow)**

47/500 founding spots. Price goes up when they're gone.

</div>

Related Reading

- [Claude Code MCP Server Setup: Complete Guide 2026](/building-your-first-mcp-tool-integration-guide-2026/)
- [Discord MCP Server Community Automation Guide](/discord-mcp-server-community-automation-guide/)
- [Slack MCP Server Team Notification Automation](/slack-mcp-server-team-notification-automation/)
- [Integrations Hub: MCP Servers and Claude Skills](/integrations-hub/)
- [Mailchimp MCP Server Marketing Automation Guide](/mailchimp-mcp-server-marketing-automation-guide/)
- [Intercom MCP Server: Automating Customer Data Workflows](/intercom-mcp-server-customer-data-automation/)
- [Notion MCP Server Knowledge Base Automation](/notion-mcp-server-knowledge-base-automation/)
- [Datadog MCP Server Monitoring Automation with Claude](/datadog-mcp-server-monitoring-automation-claude/)
- [Ghost MCP Server: Blogging Automation Workflow](/ghost-mcp-server-blogging-automation-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



**Configure it →** Build your MCP config with our [MCP Config Generator](/mcp-config/).

## See Also

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Best Claude Code Workflow Automations (2026)](/best-claude-code-workflow-automations-2026/)
