---
layout: default
title: "Ghost MCP Server: Blogging Automation Workflow"
description: "Connect Claude to Ghost using the Model Context Protocol. Automate blog post creation, scheduling, and content management workflows with MCP servers."
date: 2026-03-14
categories: [integrations]
tags: [claude-code, claude-skills, mcp, ghost, blogging, automation, workflow]
author: theluckystrike
reviewed: true
score: 8
---

# Ghost MCP Server: Blogging Automation Workflow

The Ghost MCP server enables Claude to interact directly with your Ghost blog, automating post creation, content updates, tag management, and publishing workflows through natural language commands. This guide shows developers and power users how to set up, configure, and leverage this integration for efficient content management.

## Prerequisites

Before configuring the Ghost MCP server, ensure you have:

- A Ghost site (self-hosted or Ghost Pro)
- Claude Code or Claude Desktop installed
- Node.js 18+ for running MCP servers locally
- A Ghost admin API key with content API access

You will need to generate an API key from your Ghost admin panel under **Settings → Integrations → Custom integrations**.

## Setting Up the Ghost MCP Server

The Ghost MCP server acts as a bridge between Claude and Ghost's Admin API. Install it using npm:

```bash
npm install -g @ghost/mcp-server
```

Configure your environment with your Ghost credentials:

```bash
export GHOST_URL="https://your-ghost-site.com"
export GHOST_API_KEY="your_admin_api_key"
```

Start the MCP server in the background:

```bash
npx @ghost/mcp-server &
```

In your Claude configuration, add the server connection:

```json
{
  "mcpServers": {
    "ghost": {
      "command": "npx",
      "args": ["@ghost/mcp-server"]
    }
  }
}
```

## Core MCP Tools Available

Once connected, Claude gains access to several Ghost-specific tools:

- **create_post**: Draft new blog posts with title, content, and metadata
- **update_post**: Modify existing posts, change status, or update tags
- **publish_post**: Move posts from draft to published
- **delete_post**: Remove posts from your blog
- **list_posts**: Query posts with filters for status, tag, or author
- **get_post**: Retrieve full post details including engagement metrics
- **manage_tags**: Create, update, or delete tags
- **upload_image**: Add images to your Ghost media library

Each tool maps directly to Ghost's Admin API, giving you programmatic control over your content.

## Automating Blog Post Creation

One of the most practical applications involves automating repetitive post creation workflows. Instead of manually writing posts in Ghost's editor, you can describe content in natural language and have Claude handle the drafting.

Consider a scenario where you want to create a series of technical tutorials. You can provide Claude with an outline and let it generate first drafts:

```
/ghost

Create a draft post titled "Getting Started with Claude Code Skills" 
with the following sections:
1. Introduction to Claude Skills
2. Setting Up Your First Skill
3. Practical Example: Automating Code Reviews
4. Conclusion

Use a conversational tone appropriate for developers.
Add tags: [claude-code, tutorial, productivity]
```

Claude will generate the content and create a draft post in your Ghost instance. You can then review, edit, and publish through Ghost's interface or continue refining with Claude.

## Integrating with Other Claude Skills

The Ghost MCP server becomes significantly more powerful when combined with other Claude skills. Here are several practical combinations:

### Using the PDF Skill for Content Conversion

If you have existing PDF content, the `pdf` skill can extract text that you then publish to Ghost:

```
/pdf /ghost

Extract all text from the file "whitepaper-ai-trends-2026.pdf"
and create a Ghost blog post from it. Split into a 3-part
series with appropriate subheadings.
```

### Using the TDD Skill for Technical Content

When writing technical tutorials, combining the `tdd` skill with Ghost automation ensures your code examples are accurate:

```
/tdd /ghost

Write a tutorial on "Unit Testing Python with pytest" including
working code examples. Create a Ghost post with the tutorial
content, and include the tag "testing".
```

### Using the Frontend-Design Skill for Visual Content

The `frontend-design` skill can generate HTML/CSS snippets that become part of your Ghost posts:

```
/frontend-design /ghost

Generate a responsive pricing table component in HTML/CSS.
Create a Ghost post titled "Our Pricing Plans" using this
component in the content.
```

### Using the Supermemory Skill for Context

The `supermemory` skill helps maintain context across multiple posts in a series:

```
/supermemory /ghost

What was the main topic of the last post in our "AI Tools"
series? Create a follow-up post that builds on that content
and maintains consistent tone and formatting.
```

## Scheduling and Workflow Automation

Beyond one-off post creation, you can build automated publishing workflows. Here's a practical example of a scheduled content pipeline:

```javascript
// Claude prompt for recurring content automation
// This would be part of a larger workflow

"Every Monday at 9am, create a draft post summarizing:
1. Top 3 tech news items from the past week
2. One tutorial based on recent documentation updates
3. A motivational quote for developers

Use the ghost MCP server to create these as drafts
tagged with 'weekly-roundup'. Notify me when ready
for review."
```

You can implement this using a cron job or CI/CD pipeline that triggers Claude with the appropriate prompts.

## Managing Tags and Categories

Organizing content with consistent tags improves discoverability. The Ghost MCP server handles tag management efficiently:

```
/ghost

List all existing tags in my Ghost blog. Then create
new tags for: [machine-learning, ai-agents, workflow-automation]
if they don't already exist. Finally, update the tag
descriptions to be more descriptive for SEO.
```

## Handling Image Assets

The image upload capability integrates with your content workflow:

```
/ghost /frontend-design

Generate a custom OG image for our blog in 1200x630px.
Then upload it to our Ghost media library and associate
it with the post "Announcing Our New Feature".
```

## Error Handling and Best Practices

When automating Ghost content creation, keep these considerations in mind:

- **Content validation**: Always review AI-generated content before publishing
- **API rate limits**: Ghost's Admin API has rate limits; batch operations when possible
- **Draft workflow**: Use drafts for initial creation, then publish manually or via scheduled automation
- **Backup content**: Maintain backups of important posts outside Ghost

## Conclusion

The Ghost MCP server transforms how you manage blog content with Claude. By connecting natural language commands to Ghost's Admin API, you can automate drafting, scheduling, tag management, and publishing workflows. Combined with other Claude skills like `pdf`, `tdd`, `frontend-design`, and `supermemory`, you have a powerful content management system that handles everything from technical tutorials to marketing posts.

For teams managing regular content schedules, this automation significantly reduces manual effort while maintaining quality control through human review of generated drafts.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
