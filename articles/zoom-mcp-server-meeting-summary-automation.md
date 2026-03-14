---
layout: default
title: "Zoom MCP Server Meeting Summary Automation"
description: "Automate Zoom meeting summaries with Claude Code and MCP servers. Complete setup guide with practical examples for developers and power users."
date: 2026-03-14
categories: [integrations]
tags: [claude-code, claude-skills, mcp, zoom, automation, meeting-summary]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /zoom-mcp-server-meeting-summary-automation/
---

# Zoom MCP Server Meeting Summary Automation

[Meeting documentation consumes significant developer time](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/) Recording decisions, tracking action items, and distributing summaries often become manual processes that interrupt deep work. Combining Zoom's meeting capabilities with Claude Code through the Model Context Protocol creates a powerful automation pipeline that transforms raw meeting data into actionable documentation.

This guide walks through building a complete Zoom meeting summary automation workflow using MCP servers, with practical code examples you can adapt for your team.

## How Zoom MCP Server Integration Works

[The Zoom MCP server connects Claude Code directly to your Zoom account](/claude-skills-guide/how-do-i-combine-two-claude-skills-in-one-workflow/) through the Zoom API. This connection enables Claude to:

- Fetch meeting recordings and transcripts
- Retrieve meeting participant lists
- Access chat messages from meetings
- Create and update meeting records

The key insight is that Claude Code can process these meeting artifacts intelligently, extracting key decisions, action items, and summaries without manual intervention.

## Setting Up Your Zoom MCP Server

First, you'll need to create a Zoom OAuth app to authenticate the MCP server:

1. Go to the [Zoom Marketplace](https://marketplace.zoom.us/)
2. Navigate to "Build App" and select "OAuth"
3. Choose "User-managed app" for personal use or "Account-level app" for team deployment
4. Set the redirect URL to `http://localhost:8080/callback`
5. Note your Client ID and Client Secret

Install the Zoom MCP server package:

```bash
npm install -g @modelcontextprotocol/server-zoom
```

Configure Claude Code to use the server by adding it to your configuration:

```json
{
  "mcpServers": {
    "zoom": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-zoom"],
      "env": {
        "ZOOM_CLIENT_ID": "your_client_id",
        "ZOOM_CLIENT_SECRET": "your_client_secret",
        "ZOOM_ACCOUNT_ID": "your_account_id"
      }
    }
  }
}
```

Restart Claude Code to load the new server configuration.

## Building the Meeting Summary Automation

With the Zoom MCP server connected, you can now build automation workflows. Here's a practical example that fetches recent meetings and generates summaries:

```javascript
// meeting-summarizer.js
// Claude Code skill for automated meeting summaries

const ZOOM_API_BASE = "https://api.zoom.us/v2";

async function getRecentMeetings(daysBack = 7) {
  const since = new Date();
  since.setDate(since.getDate() - daysBack);
  
  return await claude.mcpCall("zoom", "list_meetings", {
    from: since.toISOString().split('T')[0],
    type: "past"
  });
}

async function getMeetingTranscript(meetingId) {
  return await claude.mcpCall("zoom", "get_recording", {
    meetingId: meetingId
  });
}

async function generateSummary(transcript) {
  const prompt = `
    Analyze this meeting transcript and create a structured summary with:
    
    1. Key Decisions: List specific decisions made
    2. Action Items: Who committed to what
    3. Discussion Topics: Main points covered
    4. Next Steps: Planned follow-up actions
    
    Transcript:
    ${transcript}
  `;
  
  return await claude.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 2000,
    messages: [{ role: "user", content: prompt }]
  });
}
```

## Practical Workflow Examples

### Daily Standup Summary Automation

For teams running daily standups over Zoom, automate the documentation process:

```yaml
# Standup-automation-skill.md
name: daily-standup-summarizer
description: Automatically summarize daily standup meetings
tools:
  - name: zoom_meetings
    description: Access Zoom meeting data
  - name: slack_notify
    description: Send notifications to Slack
triggers:
  - cron: "0 11 * * 1-5"
    action: process_standup

actions:
  process_standup:
    - get_yesterday_standups
    - filter_zoom_meetings(type=standup)
    - generate_summary_bullet_points
    - post_to_slack(channel="#standups")
```

### Sprint Retrospective Processing

After sprint retrospectives, extract action items automatically using the tdd skill for test creation or the supermemory skill for persistent storage:

```javascript
// Process retrospective meeting
const retrospective = await getMeetingTranscript(retroMeetingId);

// Extract action items using Claude's analysis
const actionItems = await claude.analyze(retrospective, {
  extraction: {
    type: "action_items",
    fields: ["owner", "deadline", "description", "priority"]
  }
});

// Store in supermemory for tracking
await claude.mcpCall("supermemory", "store", {
  collection: "sprint-actions",
  items: actionItems
});
```

## Advanced: PDF Report Generation

Transform meeting summaries into professional PDF reports using the pdf skill for client deliverables:

```javascript
const { PDFDocument, rgb } = require('pdfkit');

async function generateMeetingReport(meetingData, summary) {
  const pdfDoc = new PDFDocument();
  
  // Add title
  pdfDoc.fontSize(20).text(`Meeting Summary: ${meetingData.topic}`, {
    align: 'center'
  });
  
  // Add metadata
  pdfDoc.fontSize(12)
    .text(`Date: ${meetingData.start_time}`)
    .text(`Duration: ${meetingData.duration} minutes`)
    .text(`Participants: ${meetingData.participants.length}`);
  
  // Add summary sections
  pdfDoc.addPage();
  pdfDoc.fontSize(16).text('Key Decisions', { underline: true });
  pdfDoc.fontSize(12).text(summary.decisions.join('\n\n'));
  
  pdfDoc.addPage();
  pdfDoc.fontSize(16).text('Action Items', { underline: true });
  summary.actionItems.forEach((item, i) => {
    pdfDoc.text(`${i + 1}. ${item.description} (${item.owner}) - ${item.deadline}`);
  });
  
  return pdfDoc;
}
```

## Security Considerations

When automating meeting data access, follow these security practices:

- **Scope permissions narrowly**: Only request OAuth scopes necessary for your automation
- **Rotate credentials regularly**: Set up automated credential refresh
- **Audit access logs**: Monitor which meetings are being accessed
- **Encrypt sensitive data**: Use environment variables for credentials, never commit them to version control

## Common Integration Patterns

Teams typically combine the Zoom MCP server with other integrations:

- **Slack**: Post summaries directly to channels using the slack-mcp-server
- **Notion**: Store meeting notes in team wikis via the Notion API
- **Linear**: Create tasks from action items automatically
- **Supermemory**: Maintain persistent context across meetings using the supermemory skill

## Troubleshooting

If your Zoom MCP server connection fails:

1. Verify OAuth credentials are correctly set in environment variables
2. Check that your Zoom app has the required scopes (meeting:read, recording:read)
3. Ensure your Zoom account has access to the meetings you're trying to retrieve
4. Test API connectivity with `curl` to the Zoom API endpoints directly

For transcription issues, ensure Cloud Recordings are enabled in your Zoom account settings and that you have permission to access the recordings.

## Conclusion

Automating Zoom meeting summaries with Claude Code transforms a manual, time-consuming task into a streamlined workflow. By connecting the Zoom MCP server to Claude's analysis capabilities, you can extract value from every meeting without the overhead of manual documentation.

Start with a simple use case like daily standups, then expand to more complex meeting types as you refine your automation. The combination of MCP servers and Claude Code provides flexibility to customize the workflow to your team's specific needs.

## Related Reading

- [Claude Code MCP Server Setup: Complete Guide 2026](/claude-skills-guide/claude-code-mcp-server-setup-complete-guide-2026/)
- [Slack MCP Server Team Notification Automation](/claude-skills-guide/slack-mcp-server-team-notification-automation/)
- [Telegram MCP Server Bot Automation Workflow](/claude-skills-guide/telegram-mcp-server-bot-automation-workflow/)
- [Integrations Hub](/claude-skills-guide/integrations-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
