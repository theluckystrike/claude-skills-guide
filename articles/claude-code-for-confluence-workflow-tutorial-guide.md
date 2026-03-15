---

layout: default
title: "Claude Code for Confluence Workflow Tutorial Guide"
description: "Learn how to build Claude skills that integrate with Confluence to automate documentation workflows, create pages from templates, and streamline team collaboration."
date: 2026-03-15
categories: [guides]
tags: [claude-code, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-for-confluence-workflow-tutorial-guide/
reviewed: true
score: 8
---


# Claude Code for Confluence Workflow Tutorial Guide

[Confluence](https://www.atlassian.com/software/confluence) is the backbone of documentation for countless development teams, yet creating and maintaining pages remains a manual, time-consuming process. This guide shows you how to build Claude skills that integrate directly with Confluence's REST API to automate page creation, apply templates, manage spaces, and keep your team wiki always up-to-date.

## Why Integrate Claude with Confluence?

Manual Confluence workflows typically involve logging into the browser, navigating to the right space, creating a new page, applying formatting, and manually updating any related pages. This process breaks down at scale:

- **Inconsistent templates**: Different team members apply different formatting standards
- **Outdated documentation**: Pages rarely get updated after initial creation
- **Time sink**: Engineers spend hours on administrative documentation tasks

A Claude skill for Confluence can handle all of this automatically, following your team's conventions precisely while you focus on writing the actual content.

## Prerequisites and Setup

Before building a Confluence integration skill, ensure you have:

1. A Confluence Cloud or Data Center instance with API access
2. An API token (for Cloud) or personal access token (for Data Center)
3. Your Confluence domain and space keys

You'll store credentials in environment variables rather than hardcoding them:

```bash
export CONFLUENCE_DOMAIN="your-company.atlassian.net"
export CONFLUENCE_EMAIL="you@company.com"
export CONFLUENCE_API_TOKEN="your-api-token"
```

For security, never commit API tokens to version control. Consider using a `.env` file with `.gitignore` protection or your system's credential manager.

## Creating Your First Confluence Skill

The foundation of any Confluence skill is the ability to authenticate and make API calls. Here's a basic skill structure:

```yaml
---
name: confluence-page-creator
description: Creates new Confluence pages from structured input
tools: [Bash, Write]
---

# Confluence Page Creator

You help create Confluence pages using the Confluence REST API. When asked to create a page, follow this process:

1. Gather required information: space key, page title, and content
2. Use the create-page script to add the page to Confluence
3. Return the URL of the newly created page

## Available Commands

Use the `create-confluence-page` function with these parameters:
- SPACE_KEY: The Confluence space (e.g., "ENG", "TEAM")
- TITLE: Page title
- CONTENT: Page content in Confluence storage format
```

Now you need the underlying bash script that performs the actual API call:

```bash
#!/bin/bash
# create-confluence-page.sh

SPACE_KEY="$1"
TITLE="$2"
CONTENT="$3"

DOMAIN="${CONFLUENCE_DOMAIN}"
EMAIL="${CONFLUENCE_EMAIL}"
TOKEN="${CONFLUENCE_API_TOKEN}"

API_RESPONSE=$(curl -s -X POST \
  "https://${DOMAIN}/wiki/api/v2/pages" \
  -u "${EMAIL}:${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"spaceId\": \"${SPACE_KEY}\",
    \"status\": \"current\",
    \"title\": \"${TITLE}\",
    \"body\": {
      \"representation\": \"storage\",
      \"value\": \"${CONTENT}\"
    }
  }")

echo "$API_RESPONSE"
```

Make this script executable and place it in your skills' scripts directory:

```bash
chmod +x /path/to/your/skills/scripts/create-confluence-page.sh
```

## Working with Confluence Storage Format

Confluence uses a storage format based on XHTML. Your skill needs to handle this format correctly. The most common elements you'll need:

```xml
<h1>Page Title</h1>
<p>Paragraph text with <strong>bold</strong> and <em>italic</em>.</p>
<h2>Subsection</h2>
<ul>
  <li>Bullet point one</li>
  <li>Bullet point two</li>
</ul>
<ac:structured-macro ac:name="code">
  <ac:plain-text-body><![CDATA[your code here]]></ac:plain-text-body>
</ac:structured-macro>
<ac:link ac:title="Related Page"><ri:page ri:content-title="Another Page"/></ac:link>
```

For complex pages, consider building content as markdown first, then converting to Confluence storage format using a tool like Pandoc:

```bash
pandoc -f markdown -t confluence -o output.html input.md
```

## Building a Meeting Notes Automation Skill

One of the most practical Confluence automations is a skill that generates meeting notes from a template. Here's how to build it:

```yaml
---
name: meeting-notes
description: Creates formatted meeting notes in Confluence
tools: [Bash, Write]
---

# Meeting Notes Generator

You create standardized meeting notes in Confluence using the team's template.

## Process

When asked to create meeting notes:

1. Ask for: Meeting title, date, attendees, and agenda items
2. Use the `create-meeting-notes` script to generate and store the page
3. Provide the Confluence URL to the user

## Template Structure

Use this structure for all meeting notes:
- **Attendees**: List all participants
- **Agenda**: Bullet points of topics to cover
- **Discussion**: Main notes section
- **Action Items**: Tasks with owners and due dates
- **Next Meeting**: Scheduled follow-up time
```

The corresponding script populates your template:

```bash
#!/bin/bash
# create-meeting-notes.sh

SPACE_KEY="$1"
MEETING_TITLE="$2"
DATE="$3"
ATTENDEES="$4"

CONTENT="<h1>${MEETING_TITLE}</h1>
<p><strong>Date:</strong> ${DATE}</p>
<p><strong>Attendees:</strong> ${ATTENDEES}</p>

<h2>Agenda</h2>
<p>Add agenda items here...</p>

<h2>Discussion</h2>
<p>Meeting notes go here...</p>

<h2>Action Items</h2>
<table>
  <tbody>
    <tr>
      <th>Task</th>
      <th>Owner</th>
      <th>Due Date</th>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
</table>

<h2>Next Meeting</h2>
<p>TBD</p>"

./create-confluence-page.sh "$SPACE_KEY" "$MEETING_TITLE" "$CONTENT"
```

## Automating Technical Documentation Updates

For engineering teams, keeping runbooks and API docs current is critical. A skill can automate this:

```yaml
---
name: update-runbook
description: Updates Confluence runbooks with latest deployment info
tools: [Bash, Write, read_file]
---

# Runbook Updater

You maintain up-to-date runbooks in Confluence by:
1. Reading the current page content via API
2. Identifying sections that need updates (version numbers, URLs, etc.)
3. Generating updated content
4. Updating the page in Confluence
```

This skill uses Confluence's page version API to retrieve existing content, make modifications, and push updates—all while preserving page history and attachments.

## Best Practices for Confluence Skills

When building production Confluence integrations, follow these guidelines:

- **Always use page IDs, not titles**: Page titles can change; IDs are permanent
- **Handle conflicts**: Check for existing pages with the same title before creating
- **Implement retry logic**: API calls can fail transiently; wrap in retry logic
- **Log everything**: Store API responses for debugging failed operations
- **Respect rate limits**: Confluence enforces API rate limits; space out requests
- **Use macros sparingly**: Complex macros can break the API; stick to basic elements

## Advanced: Webhooks and Real-Time Updates

For more sophisticated workflows, combine your skill with Confluence webhooks. Set up a webhook to trigger on page updates, then have your skill process changes:

```bash
# Example webhook handler
curl -X POST webhook-endpoint \
  -H "Content-Type: application/json" \
  -d '{
    "webhookEvent": "page_updated",
    "page": {
      "id": "123456789",
      "title": "Updated Page",
      "space": {"key": "ENG"}
    }
  }'
```

This enables scenarios like notifying Slack when critical docs change, automatically translating pages, or triggering CI/CD pipelines from documentation updates.

## Conclusion

Claude Code skills for Confluence transform static documentation into dynamic, automated workflows. Start with simple page creation, then expand to templates, automated updates, and webhook-driven automation. Your team will save hours each week while maintaining consistent, well-structured documentation that actually stays current.

The key is treating Confluence as an API-first platform rather than a web application. By abstracting away the browser interface through Claude skills, you enable developers to focus on writing content while automation handles the administrative overhead.
