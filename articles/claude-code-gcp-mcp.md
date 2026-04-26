---
layout: default
title: "Claude Code GCP MCP Server Setup (2026)"
description: "Connect Claude Code to Google Cloud Platform through MCP for direct access to Cloud Run, GCS, BigQuery, and Pub/Sub from your terminal."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-gcp-mcp/
categories: [guides]
tags: [claude-code, claude-skills, gcp, mcp, google-cloud]
reviewed: true
score: 7
geo_optimized: true
---

Connecting Claude Code to Google Cloud Platform through MCP gives Claude direct access to your GCP resources like Cloud Storage buckets, BigQuery datasets, Cloud Run services, and Pub/Sub topics. This guide covers building a GCP MCP server that lets Claude manage infrastructure and query data without leaving the terminal.

## The Problem

GCP developers juggle the gcloud CLI, the Cloud Console web UI, and their code editor. Debugging a Cloud Run deployment means checking logs in one window, reading Dockerfile configs in another, and testing API endpoints in a third. Claude Code can edit your application code, but without MCP it has no visibility into your live GCP environment, making it impossible to diagnose deployment failures or data issues.

## Quick Solution

1. Install dependencies:

```bash
pip install mcp google-cloud-storage google-cloud-bigquery
gcloud auth application-default login
```

2. Create `gcp_mcp.py`:

```python
from mcp.server.fastmcp import FastMCP
from google.cloud import storage, bigquery
import subprocess

mcp = FastMCP("gcp-tools")

@mcp.tool()
def list_buckets(project: str) -> str:
    """List GCS buckets in a project."""
    client = storage.Client(project=project)
    buckets = [b.name for b in client.list_buckets()]
    return "\n".join(buckets) if buckets else "No buckets found."

@mcp.tool()
def run_bigquery(query: str, project: str) -> str:
    """Run a read-only BigQuery SQL query."""
    if not query.strip().upper().startswith("SELECT"):
        return "Error: Only SELECT queries are allowed."
    client = bigquery.Client(project=project)
    results = client.query(query).result()
    rows = [str(dict(row)) for row in results]
    return "\n".join(rows[:50]) if rows else "No results."

@mcp.tool()
def cloud_run_logs(service: str, region: str) -> str:
    """Get recent Cloud Run logs for a service."""
    result = subprocess.run(
        ["gcloud", "logging", "read",
         f'resource.type="cloud_run_revision" AND resource.labels.service_name="{service}"',
         "--limit=20", "--format=json",
         f"--project={region}"],
        capture_output=True, text=True, timeout=30
    )
    return result.stdout[:2000] if result.stdout else result.stderr
```

3. Add to `.mcp.json`:

```json
{
  "mcpServers": {
    "gcp-tools": {
      "command": "python",
      "args": ["gcp_mcp.py"],
      "env": {
        "GOOGLE_CLOUD_PROJECT": "your-project-id"
      }
    }
  }
}
```

4. Launch Claude Code and ask it to check your GCS buckets or query BigQuery.

## How It Works

The GCP MCP server uses Google Cloud client libraries to access GCP resources. Authentication flows through Application Default Credentials (ADC), which `gcloud auth application-default login` sets up. This means the MCP server uses your local developer credentials, with the same permissions you have in the Cloud Console.

Each MCP tool wraps a specific GCP operation. The BigQuery tool enforces read-only access by checking that queries start with SELECT. The Cloud Run logs tool uses the gcloud CLI as a subprocess since the logging API returns structured data more easily through the CLI.

Claude Code calls these tools during development when it needs to verify deployments, check data, or diagnose errors. Combined with CLAUDE.md documentation of your GCP architecture, Claude can autonomously debug issues that span your code and infrastructure.

## Common Issues

**Authentication fails with "could not find default credentials."** Run `gcloud auth application-default login` to create local credentials. This is separate from `gcloud auth login`, which only authenticates the CLI itself.

**BigQuery queries time out.** Large BigQuery scans can take minutes. Increase the timeout in `client.query()` or add a `LIMIT` clause to your queries. The MCP tool should enforce a maximum row count to prevent Claude from receiving megabytes of data.

**Cloud Run logs return empty.** Ensure the `--project` flag uses the correct project ID, not the region. Check that the service name exactly matches what appears in the Cloud Console, including case.

## Example CLAUDE.md Section

```markdown
# GCP Project Configuration

## Infrastructure
- Project ID: my-app-prod-12345
- Region: us-central1
- Cloud Run services: api-service, worker-service
- Database: Cloud SQL (PostgreSQL 15)
- Storage: GCS bucket my-app-uploads

## MCP Tools Available
- list_buckets: List GCS buckets
- run_bigquery: Read-only SQL queries
- cloud_run_logs: Recent service logs

## Rules
- Never run DELETE, UPDATE, or INSERT via BigQuery MCP
- Cloud Run deploys via CI/CD only, not from local
- Use staging project (my-app-staging) for testing
- All GCS operations should target staging bucket first

## Deploy Process
- Push to main triggers Cloud Build
- Cloud Build deploys to Cloud Run automatically
- Check logs via MCP after deploy to verify
```

## Best Practices

- **Enforce read-only access** in all MCP tools. Never allow mutation operations through Claude Code against production GCP resources.
- **Use a staging project** for MCP tools during development. Set the `GOOGLE_CLOUD_PROJECT` env variable to your staging project ID, not production.
- **Truncate large outputs** since BigQuery results and Cloud Run logs can be massive. Limit to 50 rows or 2000 characters to keep Claude's context window efficient.
- **Log all MCP tool invocations** to an audit file so you can review what GCP operations Claude triggered during a session.
- **Separate tools by service** rather than creating one mega-tool. A `cloud_run_logs` tool is safer and more discoverable than a generic `gcloud_run` tool.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-gcp-mcp)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Claude Code AWS Lambda Deployment Guide](/claude-code-aws-lambda-deployment-guide/)
- [Claude Code MCP Server Disconnected](/claude-code-mcp-server-disconnected/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
