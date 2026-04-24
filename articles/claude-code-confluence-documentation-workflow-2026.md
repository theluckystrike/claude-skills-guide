---
layout: post
title: "Claude Code for Confluence (2026)"
description: "Sync code documentation to Confluence with Claude Code. Auto-generate pages, update API docs, and maintain living documentation workflows."
permalink: /claude-code-confluence-documentation-workflow-2026/
date: 2026-04-21
last_tested: "2026-04-21"
---

## The Workflow

Automate Confluence documentation generation and synchronization using Claude Code. This covers API documentation auto-generation, architecture decision records, runbook creation, and continuous sync pipelines that keep wiki pages current with your codebase.

Expected time: 30-45 minutes for pipeline setup
Prerequisites: Confluence Cloud or Server with API access, Confluence API token, Claude Code installed, Node.js 18+

## Setup

### 1. Configure Confluence Credentials

```bash
# Store in your shell profile (never commit these)
export CONFLUENCE_BASE_URL="https://your-company.atlassian.net/wiki"
export CONFLUENCE_EMAIL="your.email@company.com"
export CONFLUENCE_API_TOKEN="your-api-token-here"
export CONFLUENCE_SPACE_KEY="ENG"
```

Generate an API token at: id.atlassian.com/manage-profile/security/api-tokens

### 2. Install the Confluence CLI Helper

```bash
cat > ~/bin/confluence-push << 'SCRIPT'
#!/bin/bash
set -euo pipefail

# Usage: confluence-push "Page Title" content.md [parent-page-id]
TITLE="$1"
CONTENT_FILE="$2"
PARENT_ID="${3:-}"

# Convert markdown to Confluence storage format (basic)
CONTENT=$(cat "$CONTENT_FILE" | sed \
  -e 's/^# \(.*\)/<h1>\1<\/h1>/' \
  -e 's/^## \(.*\)/<h2>\1<\/h2>/' \
  -e 's/^### \(.*\)/<h3>\1<\/h3>/' \
  -e 's/^- \(.*\)/<li>\1<\/li>/' \
  -e 's/```\([a-z]*\)/<ac:structured-macro ac:name="code"><ac:parameter ac:name="language">\1<\/ac:parameter><ac:plain-text-body><![CDATA[/' \
  -e 's/```/]]><\/ac:plain-text-body><\/ac:structured-macro>/' \
)

# Check if page exists
EXISTING=$(curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_API_TOKEN" \
  "$CONFLUENCE_BASE_URL/rest/api/content?title=$(echo "$TITLE" | jq -sRr @uri)&spaceKey=$CONFLUENCE_SPACE_KEY" \
  | jq -r '.results[0].id // empty')

if [ -n "$EXISTING" ]; then
  # Update existing page
  VERSION=$(curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_API_TOKEN" \
    "$CONFLUENCE_BASE_URL/rest/api/content/$EXISTING" \
    | jq '.version.number')

  curl -s -X PUT \
    -u "$CONFLUENCE_EMAIL:$CONFLUENCE_API_TOKEN" \
    -H "Content-Type: application/json" \
    "$CONFLUENCE_BASE_URL/rest/api/content/$EXISTING" \
    -d "{
      \"id\": \"$EXISTING\",
      \"type\": \"page\",
      \"title\": \"$TITLE\",
      \"space\": {\"key\": \"$CONFLUENCE_SPACE_KEY\"},
      \"body\": {\"storage\": {\"value\": $(echo "$CONTENT" | jq -sR), \"representation\": \"storage\"}},
      \"version\": {\"number\": $((VERSION + 1))}
    }" | jq -r '.id'
  echo "Updated page: $TITLE (id: $EXISTING)"
else
  # Create new page
  BODY="{
    \"type\": \"page\",
    \"title\": \"$TITLE\",
    \"space\": {\"key\": \"$CONFLUENCE_SPACE_KEY\"},
    \"body\": {\"storage\": {\"value\": $(echo "$CONTENT" | jq -sR), \"representation\": \"storage\"}}
  }"

  if [ -n "$PARENT_ID" ]; then
    BODY=$(echo "$BODY" | jq ". + {\"ancestors\": [{\"id\": \"$PARENT_ID\"}]}")
  fi

  curl -s -X POST \
    -u "$CONFLUENCE_EMAIL:$CONFLUENCE_API_TOKEN" \
    -H "Content-Type: application/json" \
    "$CONFLUENCE_BASE_URL/rest/api/content" \
    -d "$BODY" | jq -r '.id'
  echo "Created page: $TITLE"
fi
SCRIPT
chmod +x ~/bin/confluence-push
```

### 3. Verify Connection

```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_API_TOKEN" \
  "$CONFLUENCE_BASE_URL/rest/api/space/$CONFLUENCE_SPACE_KEY" | jq '.name'
# Expected output:
# "Engineering" (or your space name)
```

## Usage Example

### Auto-Generate API Documentation

```bash
#!/bin/bash
# sync-api-docs.sh — Generate API docs from code and push to Confluence

PROJECT_DIR="${1:-.}"
OUTPUT="/tmp/api-docs.md"

# Claude Code analyzes the codebase and generates documentation
claude --print "Analyze all API route handlers in $PROJECT_DIR/src/api/.
Generate complete API documentation in markdown with:

# API Reference

For each endpoint:
## [HTTP_METHOD] /path
**Description:** what it does
**Authentication:** required/optional
**Parameters:**
| Name | Type | Required | Description |
**Request Body:**
\`\`\`json
{example}
\`\`\`
**Response (200):**
\`\`\`json
{example}
\`\`\`
**Error Responses:** list common errors

Sort endpoints by resource path. Include curl examples." > "$OUTPUT"

# Push to Confluence
confluence-push "API Reference — $(basename "$PROJECT_DIR")" "$OUTPUT"
echo "API docs synced to Confluence"
```

### Architecture Decision Records Pipeline

```bash
#!/bin/bash
# generate-adr.sh — Create ADR from discussion and push to Confluence

TITLE="$1"
CONTEXT="$2"

ADR_FILE="/tmp/adr-$(date +%Y%m%d).md"

claude --print "Generate an Architecture Decision Record with this structure:

# ADR: $TITLE

## Status
Proposed

## Context
$CONTEXT

## Decision
[Analyze the context and recommend a decision with clear reasoning]

## Consequences
### Positive
- [list benefits]

### Negative
- [list tradeoffs]

### Risks
- [list risks with mitigation strategies]

## Alternatives Considered
[List 2-3 alternatives with reasons for rejection]

## References
[Relevant documentation or resources]" > "$ADR_FILE"

confluence-push "ADR: $TITLE" "$ADR_FILE" "$ADR_PARENT_PAGE_ID"
echo "ADR published to Confluence"
```

### Continuous Documentation Sync (Git Hook)

```bash
cat > .git/hooks/post-merge << 'EOF'
#!/bin/bash
# Sync docs on every merge to main

CHANGED_API=$(git diff --name-only HEAD~1 -- 'src/api/' | head -1)
CHANGED_SCHEMA=$(git diff --name-only HEAD~1 -- 'prisma/schema.prisma' | head -1)

if [ -n "$CHANGED_API" ]; then
  echo "API files changed — syncing documentation..."
  bash scripts/sync-api-docs.sh . &
fi

if [ -n "$CHANGED_SCHEMA" ]; then
  echo "Database schema changed — syncing ERD..."
  claude --print "Read prisma/schema.prisma and generate a database
  schema documentation page with table descriptions, relationships,
  and migration notes" > /tmp/db-docs.md
  confluence-push "Database Schema Reference" /tmp/db-docs.md &
fi

wait
echo "Documentation sync complete"
EOF
chmod +x .git/hooks/post-merge
```

### Runbook Generation from Code

```bash
#!/bin/bash
# generate-runbook.sh — Create operational runbooks from code analysis

SERVICE="$1"
SERVICE_DIR="$2"

claude --print "Analyze $SERVICE_DIR and generate an operational runbook:

# $SERVICE Runbook

## Service Overview
- What it does, architecture, dependencies

## Health Checks
- Endpoints to monitor
- Expected responses
- Alert thresholds

## Common Issues and Resolutions
For each issue:
### Issue: [description]
**Symptoms:** what operators see
**Cause:** root cause
**Resolution:**
1. [exact commands to run]
2. [verification steps]
**Prevention:** how to avoid recurrence

## Deployment
- Deploy commands
- Rollback procedure
- Canary validation steps

## Scaling
- When to scale
- How to scale (commands)
- Capacity limits

## Contacts
- On-call rotation
- Escalation path" > "/tmp/runbook-${SERVICE}.md"

confluence-push "$SERVICE Runbook" "/tmp/runbook-${SERVICE}.md"
```

## Common Issues

- **Confluence storage format renders incorrectly:** The basic markdown-to-storage conversion misses complex elements. Use a proper converter like `markdown-to-confluence` npm package for production: `npm install -g markdown-to-confluence`.
- **API token permissions insufficient:** Ensure your token has "Write" permissions on the target space. Space admins can grant page creation rights at Space Settings > Permissions.
- **Rate limiting on Confluence API:** Atlassian limits API calls. Add a 1-second delay between batch operations: `sleep 1` between consecutive curl calls in loops.

## Why This Matters

Documentation rot kills developer productivity. Automated sync between code and Confluence ensures documentation is always current, eliminating the most common complaint about enterprise wikis: "the docs are outdated."

## Related Guides

- [Claude Code Confluence Documentation Guide](/claude-code-confluence-documentation-guide/)
- [Automated Code Documentation Workflow with Claude Skills](/automated-code-documentation-workflow-with-claude-skills/)
- [Claude Code for Technical Documentation Workflow Guide](/claude-code-for-technical-documentation-workflow-guide/)
