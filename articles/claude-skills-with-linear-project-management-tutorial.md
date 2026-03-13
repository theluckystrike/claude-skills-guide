---
layout: default
title: "Claude Skills with Linear Project Management Tutorial"
description: "Learn how to integrate Claude AI skills with Linear for streamlined project management, automated status updates, and efficient team workflows."
date: 2026-03-13
author: theluckystrike
---

# Claude Skills with Linear Project Management Tutorial

Linear has become one of the most popular project management tools for engineering teams, offering a fast, intuitive interface with powerful API capabilities. Combining Linear with Claude skills creates a powerful automation system that can transform how your team manages projects, tracks issues, and communicates progress.

## Why Combine Claude Skills with Linear?

Linear's API-first approach makes it ideal for automation. By leveraging Claude skills, you can create sophisticated workflows that connect Linear to your entire development ecosystem. Whether you need automated status updates, intelligent issue triage, or seamless documentation generation, the combination of Linear and Claude skills provides the flexibility to build exactly what your team needs.

The **supermemory** skill proves invaluable here, indexing your Linear projects and allowing you to search across issues using natural language. Instead of manually filtering through dozens of tickets, you can ask "Show me all critical bugs from last sprint" and receive instant results.

## Setting Up the Integration

Before creating automation workflows, you'll need to configure the connection between Linear and Claude Code. This requires generating an API key from your Linear workspace settings.

```bash
# Store your Linear API key securely
export LINEAR_API_KEY="lin_api_xxxxxxxxxxxxx"

# Verify the connection works
curl -H "Authorization: $LINEAR_API_KEY" \
  https://api.linear.app/graphql \
  -d '{"query":"{ me { name } }"}'
```

Once authenticated, you can use the **skill-creator** skill to build a custom Linear integration skill tailored to your team's specific workflows. This follows the same MCP (Model Context Protocol) pattern that powers other Claude skills.

## Automating Issue Creation

One of the most practical applications combines the **docx** skill with Linear to automatically generate issue documentation. When a new issue is created, Claude can automatically produce technical specifications, test plans, or design documents.

```javascript
// Example: Auto-generate issue documentation
const { LinearClient } = require('@linear/sdk');
const linear = new LinearClient({ apiKey: process.env.LINEAR_API_KEY });

async function createIssueWithDocs(issueData) {
  const issue = await linear.issueCreate({
    teamId: issueData.teamId,
    title: issueData.title,
    description: issueData.description,
    labels: issueData.labels
  });

  // Use docx skill to generate technical specification
  const specDoc = await generateTechSpec(issue);
  
  // Attach document to issue
  await linear.attachmentCreate({
    issueId: issue.id,
    title: "Technical Specification",
    url: specDoc.url
  });

  return issue;
}
```

This automation ensures every issue has proper documentation from the start, reducing back-and-forth communication and helping developers understand requirements quickly.

## Streamlining Sprint Planning

The **xlsx** skill pairs excellently with Linear for sprint planning and capacity management. You can extract Linear data and transform it into useful reports for planning meetings.

```python
# Generate sprint capacity report using xlsx skill
import requests
import xlsx from 'xlsx'

def generate_sprint_report(team_id, sprint_id):
    # Fetch issues from Linear GraphQL API
    query = """
    query($teamId: String!, $sprintId: String!) {
        issues(filter: { team: { id: { eq: $teamId } }, sprint: { id: { eq: $sprintId } } }) {
            nodes {
                title
                estimate
                assignee { name }
                labels { nodes { name } }
            }
        }
    }
    """
    
    response = requests.post(
        'https://api.linear.app/graphql',
        json={'query': query, 'variables': {'teamId': team_id, 'sprintId': sprint_id}},
        headers={'Authorization': f'Bearer {LINEAR_API_KEY}'}
    )
    
    issues = response.json()['data']['issues']['nodes']
    
    # Create spreadsheet with xlsx skill
    workbook = xlsx.Workbook()
    sheet = workbook.add_worksheet('Sprint Capacity')
    
    sheet.write_row(['Issue', 'Estimate', 'Assignee', 'Labels'])
    for issue in issues:
        sheet.write_row([
            issue['title'],
            issue['estimate'] or 0,
            issue['assignee']['name'],
            ', '.join([l['name'] for l in issue['labels']['nodes']])
        ])
    
    workbook.save('sprint-capacity.xlsx')
```

This report helps team leads quickly understand sprint load distribution and identify potential bottlenecks before sprint planning meetings.

## Creating Feedback Loops with Slack Notifications

Many teams use Slack for daily communication. By combining Linear webhooks with Claude skills, you can create intelligent notification workflows that keep everyone informed without overwhelming channels.

```javascript
// Slack notification workflow
const { WebClient } = require('@slack/web-api');
const slack = new WebClient(process.env.SLACK_TOKEN);

async function handleLinearWebhook(payload) {
  const { action, issue, user } = payload;
  
  // Use supermemory to find related context
  const context = await supermemory.search(
    `previous discussions about ${issue.labels?.map(l => l.name).join(', ')}`
  );
  
  const message = formatIssueMessage(issue, action, user, context);
  
  // Route to appropriate channel based on issue type
  const channel = issue.labels?.includes('bug') ? '#bugs' : '#features';
  await slack.chat.postMessage({ channel, text: message });
}
```

The supermemory skill adds context by retrieving previous discussions about similar issues, making notifications more informative.

## Automating Code Review Links

For teams using GitHub or GitLab, connecting Linear issues to pull requests creates a clear traceability chain. You can automate this connection using the **tdd** skill to ensure test coverage is tracked alongside issue progress.

```bash
# GitHub Action to link PRs to Linear issues
name: Link Linear Issue

on:
  pull_request:
    branches: [main]

jobs:
  link-linear:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/github-script@v6
        with:
          script: |
            const pr = context.payload.pull_request;
            const issueMatch = pr.body.match(/LINEAR-(\d+)/);
            
            if (issueMatch) {
              const linearId = issueMatch[1];
              // Update Linear issue with PR link
              await linear.issueUpdate(linearId, {
                description: `${pr.body}\n\n🔗 [PR #${pr.number}](${pr.html_url})`
              });
            }
```

When developers reference Linear issue IDs in pull request descriptions, the integration automatically links the PR and updates the issue with the relevant code review link.

## Weekly Status Reports with PDF Generation

The **pdf** skill enables automatic weekly status report generation. Instead of manually compiling updates, Claude can aggregate Linear data and produce professional reports for stakeholders.

```python
# Automated weekly status report
from datetime import datetime, timedelta
from pdf import PDFDocument

def generate_weekly_status(linear_client, team_id):
    week_ago = datetime.now() - timedelta(days=7)
    
    # Fetch completed issues
    completed = linear_client.issues(
        filter={
            'team': {'id': {'eq': team_id}},
            'completedAt': {'gte': week_ago.isoformat()}
        }
    )
    
    # Fetch in-progress issues
    in_progress = linear_client.issues(
        filter={
            'team': {'id': {'eq': team_id}},
            'state': {'name': {'eq': 'In Progress'}}
        }
    )
    
    # Generate PDF report
    pdf = PDFDocument()
    pdf.add_heading('Weekly Status Report', level=1)
    pdf.add_paragraph(f"Generated: {datetime.now().strftime('%Y-%m-%d')}")
    
    pdf.add_heading('Completed This Week', level=2)
    for issue in completed:
        pdf.add_paragraph(f"✓ {issue.title} ({issue.labels})")
    
    pdf.add_heading('In Progress', level=2)
    for issue in in_progress:
        pdf.add_paragraph(f"→ {issue.title}")
    
    pdf.save('weekly-status.pdf')
    return pdf
```

## Best Practices for Linear-Claude Integration

When building these workflows, consider starting with one automation that addresses your team's biggest pain point. The skill-creator skill makes it straightforward to extend integrations as your needs evolve.

Maintain clear naming conventions for automated actions so team members understand what changed issues and when. Use Linear's built-in automation rules alongside Claude skills for complementary functionality—Linear handles straightforward state transitions while Claude manages more complex logic.

Regularly review which automations are actually being used and producing value. Some integrations might seem useful in theory but end up adding noise rather than helping. The **supermemory** skill can help you analyze usage patterns by tracking which queries your team makes most frequently.

The combination of Linear's clean API and Claude's flexible skill system opens up countless possibilities for project management automation. Start simple, measure impact, and iterate based on what your team actually needs.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
