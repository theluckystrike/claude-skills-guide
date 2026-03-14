---
layout: default
title: "Claude Code Skills SendGrid Email Automation Setup"
description: "Set up SendGrid email automation using Claude Code skills. Build skills that connect to SendGrid API, send transactional emails, and manage email templates programmatically."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills, sendgrid, email-automation, api-integration]
author: theluckystrike
---

# Claude Code Skills SendGrid Email Automation Setup

Email automation is a fundamental requirement for modern applications. Whether you need to send welcome emails, order confirmations, password resets, or scheduled newsletters, integrating a reliable email service with your development workflow saves hours of manual work. SendGrid is one of the most widely used email delivery services, and when combined with Claude Code skills, it becomes a powerful automation tool that developers can invoke on demand.

This guide walks you through setting up SendGrid email automation using custom Claude skills. You will learn how to create skills that authenticate with SendGrid, send different types of emails, manage templates, and handle common automation scenarios without leaving your Claude Code session.

## Prerequisites

Before building SendGrid skills, ensure you have the necessary credentials and tools in place. First, create a SendGrid account and generate an API key from the SendGrid dashboard. The API key should have permissions for Mail Send and, optionally, Templates and Stats depending on your automation needs.

You also need Node.js installed on your system since the SendGrid client library runs on Node. Verify your installation:

```bash
node --version  # Should be 18.0.0 or higher
npm --version   # Should be 8.0.0 or higher
```

Install the SendGrid package locally:

```bash
npm install @sendgrid/mail
```

## Creating the SendGrid Skill Structure

Claude skills live in `~/.claude/skills/` as Markdown files. Create a new skill directory for SendGrid automation:

```bash
mkdir -p ~/.claude/skills/sendgrid-email
```

The skill file structure follows the standard format. Create `skill.md` inside the directory with the necessary configuration and instructions.

## Skill Configuration and Authentication

The core of any SendGrid skill is authentication. Store your API key securely using environment variables rather than hardcoding credentials. Create a skill that sets up the SendGrid client properly:

```markdown
---
name: sendgrid-email
description: Send emails via SendGrid API. Supports transactional emails, templates, and batch sends.
version: 1.0.0
---

# SendGrid Email Automation Skill

This skill provides email sending capabilities through SendGrid's API. Use it for transactional emails, template-based messages, and batch operations.

## Setup Required

Before sending emails, ensure you have:
- A SendGrid API key with Mail Send permissions
- Node.js 18+ installed
- @sendgrid/mail package installed

## Available Actions

### Send Single Email
To send a single email, provide: to email, from email, subject, and body (text or HTML).

### Send Template Email
To send a template-based email, provide: to email, from email, and template ID.

### Send Batch Emails
To send multiple emails at once, provide an array of email objects.
```

## Building the Email Sending Script

The skill needs a companion script that actually executes the SendGrid API calls. Create `send-email.js` in your skill directory:

```javascript
#!/usr/bin/env node

const sgMail = require('@sendgrid/mail');

// Initialize with API key from environment
const apiKey = process.env.SENDGRID_API_KEY;
if (!apiKey) {
  console.error('Error: SENDGRID_API_KEY environment variable not set');
  process.exit(1);
}

sgMail.setApiKey(apiKey);

// Parse command line arguments
const args = process.argv.slice(2);
const action = args[0];

async function sendEmail(to, from, subject, text, html) {
  const msg = {
    to,
    from,
    subject,
    text: text || '',
    html: html || '',
  };

  try {
    await sgMail.send(msg);
    console.log(`Email sent successfully to ${to}`);
    return { success: true };
  } catch (error) {
    console.error('Error sending email:', error.message);
    if (error.response) {
      console.error('SendGrid error:', error.response.body);
    }
    return { success: false, error: error.message };
  }
}

async function sendTemplateEmail(to, from, templateId, dynamicData) {
  const msg = {
    to,
    from,
    templateId,
    dynamicTemplateData: dynamicData || {},
  };

  try {
    await sgMail.send(msg);
    console.log(`Template email sent to ${to}`);
    return { success: true };
  } catch (error) {
    console.error('Error sending template email:', error.message);
    return { success: false, error: error.message };
  }
}

// Handle different actions
if (action === 'send') {
  const [, , , to, from, subject, text] = process.argv;
  sendEmail(to, from, subject, text).then(process.exit);
} else if (action === 'template') {
  const [, , , to, from, templateId] = process.argv;
  sendTemplateEmail(to, from, templateId).then(process.exit);
} else {
  console.log('Usage:');
  console.log('  node send-email.js send <to> <from> <subject> <text>');
  console.log('  node send-email.js template <to> <from> <templateId>');
}
```

Make the script executable:

```bash
chmod +x ~/.claude/skills/sendgrid-email/send-email.js
```

## Creating a Reusable Email Skill

Now build the main skill file that provides a user-friendly interface for common email operations. This skill should handle the complexity of different email types while presenting simple prompts to the user:

```markdown
---
name: sendgrid-email
description: Send transactional and template emails via SendGrid
---

# SendGrid Email Skill

Send emails through SendGrid without leaving Claude Code.

## Prerequisites

Run this once to install dependencies:

```bash
mkdir -p ~/sendgrid-skill && cd ~/sendgrid-skill
npm init -y
npm install @sendgrid/mail
```

Set your API key:

```bash
export SENDGRID_API_KEY=your_api_key_here
```

## Sending Emails

### Simple Text Email

Provide these details:
- Recipient email address
- Sender email address (must be verified in SendGrid)
- Email subject line
- Email body text

### HTML Email

Provide:
- Recipient and sender addresses
- Subject line
- HTML content for the email body

### Template Email

For dynamic templates:
- Recipient and sender addresses
- Template ID from your SendGrid dashboard
- Dynamic data as JSON (name-value pairs for template variables)

## Error Handling

The skill reports SendGrid API errors clearly. Common issues include:
- Invalid API key (check SENDGRID_API_KEY)
- Unverified sender email (verify in SendGrid dashboard)
- Rate limiting (implement retry logic for bulk sends)
- Invalid recipient address (validate emails before sending)
```

## Automating Common Email Scenarios

With the skill in place, you can now handle several common automation scenarios. For welcome emails, create a skill that sends when new user accounts are created. Store the email template ID in SendGrid and pass user-specific data like name and activation link as dynamic template data.

For order confirmations, build a workflow that receives order details and sends a formatted confirmation email with order number, items, and estimated delivery date. The skill can format this data into HTML and send via SendGrid.

For scheduled digests, consider combining this skill with a cron job or another Claude skill that handles scheduling. The email skill handles the sending portion while the scheduler triggers it at appropriate intervals.

## Testing Your Setup

Verify your setup works before deploying to production. First, test with a single email to your own address:

```bash
export SENDGRID_API_KEY=your_key
node ~/.claude/skills/sendgrid-email/send-email.js send \
  "your-email@example.com" \
  "verified-sender@example.com" \
  "Test Email" \
  "This is a test from Claude Code skill"
```

Check your inbox and the SendGrid dashboard for delivery status. Once confirmed working, extend the skill for your specific use cases.

## Security Considerations

Never commit API keys to version control. Use environment variables or a secrets management system. For production deployments, restrict the API key to only necessary permissions. Rotate keys periodically and monitor usage for anomalies.

When handling recipient data, comply with relevant regulations including GDPR and CAN-SPAM. Provide unsubscribe mechanisms in commercial emails and honor opt-out requests promptly.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
