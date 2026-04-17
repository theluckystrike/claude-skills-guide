---
layout: default
title: "Claude Code GitHub Actions MCP Setup"
description: "Connect Claude Code to GitHub Actions through MCP for workflow management, run monitoring, and automated CI/CD debugging from your terminal."
date: 2026-04-17
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-github-actions-mcp/
categories: [guides]
tags: [claude-code, claude-skills, github-actions, mcp, ci-cd]
reviewed: true
score: 7
geo_optimized: true
---

A GitHub Actions MCP server gives Claude Code direct access to your CI/CD pipeline status, workflow runs, logs, and artifacts. Instead of switching to the GitHub web UI to check why a build failed, Claude can pull the logs, diagnose the issue, and suggest a fix all within your terminal session.

## The Problem

CI/CD failures are a major productivity drain. A test fails in GitHub Actions, you open the web UI, navigate through workflow runs, expand log groups, find the error, then switch back to your editor to fix it. With an MCP server connected to the GitHub Actions API, Claude Code can query workflow status, read failure logs, and diagnose issues without you ever leaving the terminal.

## Quick Solution

1. Create a GitHub personal access token with `actions:read` and `contents:read` permissions.

2. Create `github_actions_mcp.py`:

```python
from mcp.server.fastmcp import FastMCP
import subprocess
import json

mcp = FastMCP("github-actions")

@mcp.tool()
def list_runs(repo: str, limit: int = 5) -> str:
    """List recent workflow runs for a repository."""
    result = subprocess.run(
        ["gh", "run", "list", "--repo", repo,
         "--limit", str(limit), "--json",
         "databaseId,status,conclusion,name,headBranch,createdAt"],
        capture_output=True, text=True, timeout=30
    )
    if result.returncode != 0:
        return f"Error: {result.stderr}"
    runs = json.loads(result.stdout)
    lines = []
    for r in runs:
        lines.append(f"{r['databaseId']} | {r['status']} | {r['conclusion']} | {r['name']} | {r['headBranch']}")
    return "\n".join(lines) if lines else "No runs found."

@mcp.tool()
def get_run_logs(repo: str, run_id: str) -> str:
    """Get logs for a specific workflow run."""
    result = subprocess.run(
        ["gh", "run", "view", str(run_id),
         "--repo", repo, "--log-failed"],
        capture_output=True, text=True, timeout=60
    )
    output = result.stdout + result.stderr
    return output[:3000] if output else "No logs available."

@mcp.tool()
def rerun_workflow(repo: str, run_id: str) -> str:
    """Re-run a failed workflow."""
    result = subprocess.run(
        ["gh", "run", "rerun", str(run_id),
         "--repo", repo, "--failed"],
        capture_output=True, text=True, timeout=30
    )
    return result.stdout + result.stderr
```

3. Install dependencies:

```bash
pip install mcp
gh auth login
```

4. Add to `.mcp.json`:

```json
{
  "mcpServers": {
    "github-actions": {
      "command": "python",
      "args": ["github_actions_mcp.py"],
      "env": {
        "GH_TOKEN": "ghp_your_token_here"
      }
    }
  }
}
```

5. Launch Claude Code and ask it to check your latest workflow runs.

## How It Works

The MCP server wraps the GitHub CLI (`gh`) to interact with the GitHub Actions API. Using `gh` instead of raw API calls simplifies authentication and provides structured JSON output. Claude Code invokes these tools when it needs to check build status or diagnose CI failures.

The `list_runs` tool shows recent workflow runs with their status and conclusion (success, failure, cancelled). When Claude sees a failure, it calls `get_run_logs` with the `--log-failed` flag to fetch only the error output, keeping the response focused.

The `rerun_workflow` tool lets Claude trigger a re-run of failed jobs after fixing the underlying code issue. This creates a complete debug loop: check status, read logs, fix code, re-run, verify.

CLAUDE.md should document your workflow structure so Claude understands which jobs are critical and which are informational.

## Common Issues

**`gh` CLI not authenticated.** The MCP server subprocess needs `gh` to be authenticated. Set `GH_TOKEN` in the environment variables of your `.mcp.json` or run `gh auth login` before starting Claude Code.

**Log output too large.** GitHub Actions logs can be massive. The `--log-failed` flag filters to only failed steps, and the tool truncates output to 3000 characters. For deeper investigation, Claude can ask you to check the full logs in the web UI.

**Rate limiting on the GitHub API.** The GitHub API limits unauthenticated requests to 60/hour and authenticated to 5000/hour. Ensure your token is set correctly to avoid hitting the lower limit during active debugging sessions.

## Example CLAUDE.md Section

```markdown
# GitHub Actions CI/CD

## Workflows
- ci.yml: Runs on every push (lint, test, build)
- deploy.yml: Runs on merge to main (deploy to prod)
- nightly.yml: Scheduled tests at 2am UTC

## MCP Tools
- list_runs: Check recent workflow status
- get_run_logs: Read failed step logs
- rerun_workflow: Re-run failed jobs

## Repository
- Owner/repo: myorg/myapp
- Default branch: main
- Protected branches: main, staging

## CI Debugging Rules
- Always check logs before modifying workflow files
- Common failures: flaky tests (retry), OOM (increase runner)
- If deploy fails, check the deploy.yml logs first
- Never modify workflow files without running locally first
```

## Best Practices

- **Use `--log-failed` by default** to reduce noise. Full logs from passing steps rarely help debug failures.
- **Set the GH_TOKEN as an environment variable** in `.mcp.json` rather than hardcoding it in the MCP server script.
- **Limit re-run capabilities** by requiring confirmation before Claude triggers a `rerun_workflow`. Add a comment-based gate or restrict to specific branches.
- **Cache workflow run IDs** to avoid repeated API calls when debugging the same failure across multiple Claude interactions.
- **Document your workflow structure** in CLAUDE.md so Claude knows which workflow file to check for specific types of failures.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-github-actions-mcp)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code MCP Server Setup](/claude-code-mcp-server-setup/)
- [Best Way to Integrate Claude Code into Team Workflow](/best-way-to-integrate-claude-code-into-team-workflow/)
- [Claude Code Docker Compose Development Workflow](/claude-code-docker-compose-development-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
