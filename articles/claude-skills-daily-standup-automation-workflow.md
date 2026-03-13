---
layout: default
title: "Claude Skills Daily Standup Automation Workflow"
description: "Automate daily standup reports using Claude Code skills. Pull git activity, format updates, and deliver to Slack or Teams with minimal manual effort."
date: 2026-03-13
author: "Claude Skills Guide"
categories: [guides]
reviewed: true
score: 8
tags: [claude-code, claude-skills, automation, standup, workflow]
---

# Daily Standup Automation with Claude Skills

Daily standups are a cornerstone of agile development, but manually compiling status updates eats into valuable coding time. With Claude skills, you can automate this ritual, transforming how your team captures and shares progress. This guide walks through building a practical daily standup automation workflow using Claude's specialized capabilities.

Claude skills are Markdown files stored in `~/.claude/skills/` and invoked with `/skill-name` inside a Claude Code session. Skills give Claude specific instructions and context for recurring tasks—they're not Python packages or shell commands.

## Why Automate Standups with Claude Skills

Developers spend an average of 10–15 minutes each morning crafting standup messages—time that compounds across a team. Rather than treating standups as a chore, automation lets you capture what actually matters: blockers, progress, and upcoming priorities.

The real power comes from treating your development activity as structured data. Git commits, issue trackers, and project management tools all contain the information your standup needs. Claude Code sessions can execute shell commands to pull this data, and skills provide the formatting and synthesis instructions.

## Core Skills You Will Need

Several Claude skills work together to make this workflow function:

- [**supermemory**](/claude-skills-guide/articles/claude-skills-token-optimization-reduce-api-costs/) — Maintains context about your projects, tasks, and ongoing work across sessions
- [**tdd**](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) — Helps structure testable code and tracks development progress
- [**pdf**](/claude-skills-guide/articles/best-claude-skills-for-data-analysis/) — Generates formatted standup documents when needed

Each skill plays a specific role in the pipeline, from data collection to final output.

## Building the Automation Pipeline

### Step 1: Configure Data Sources

Your standup needs three types of information: what you completed yesterday, what you're working on today, and any blockers. For GitHub-based projects, fetch recent activity via the shell:

```bash
# Fetch your commits from yesterday
gh api search/commits --method GET -f query="repo:yourorg/project author:@me" --jq '.items[] | {sha: .sha[0:7], message: .commit.message}'
```

Store project configurations in a YAML file your standup skill can reference:

```yaml
# standup-config.yaml
data_sources:
  github:
    org: yourorg
    projects:
      - backend-api
      - frontend-app
  linear:
    team_id: engineering
  jira:
    project_key: PROJ
```

### Step 2: Create the Standup Generator Skill

Build a custom skill at `~/.claude/skills/standup-generator.md`:

```markdown
# Standup Generator

Generate a daily standup report from development activity.

## Instructions

1. Run `git log --since="yesterday" --author="$(git config user.email)" --oneline` in each configured project directory
2. Fetch open issues labeled "in-progress" from the configured issue tracker
3. Ask the user if there are any blockers not captured in the tracker
4. Format the results as a standup message using the template below

## Output Template

## Daily Standup - {date}

### Yesterday
- {bullet per commit or completed task}

### Today
- {bullet per open in-progress issue}

### Blockers
- {bullet per blocker, or "None"}
```

Invoke it each morning with:

```
/standup-generator
```

Claude executes the shell commands, fetches the relevant data, and produces the formatted standup.

### Step 3: Example Output

Once your skill collects the data, it produces a clean standup format:

```markdown
## Daily Standup - March 13, 2026

### Yesterday
- Completed PR #247: Add user authentication flow
- Fixed bug in payment processing API
- Code review for team member's feature branch

### Today
- Working on implementing rate limiting for API endpoints
- Starting integration tests for user profile module

### Blockers
- Waiting on design specs for new dashboard components
- Need access to staging environment for testing
```

### Step 4: Delivery Integration

Automate delivery to your team's communication channel using a webhook script:

```python
import os
import requests

def deliver_standup(message: str, webhook_url: str) -> bool:
    """Send standup to team channel via webhook."""
    payload = {
        "text": message,
        "username": "Standup Bot",
        "icon_emoji": ":robot_face:"
    }
    response = requests.post(webhook_url, json=payload)
    return response.status_code == 200

if __name__ == "__main__":
    webhook = os.environ.get("SLACK_WEBHOOK_URL")
    standup_message = os.environ.get("STANDUP_MESSAGE")
    deliver_standup(standup_message, webhook)
```

Schedule this with a cron job or GitHub Actions workflow that runs every morning at your team's standup time.

## Advanced Enhancements

### Using supermemory for Context

The supermemory skill maintains long-term context about your projects. Use it to track recurring blockers that span multiple days:

```
/supermemory store: 2026-03-12 blocker - waiting on design specs for dashboard, still unresolved
/supermemory find: unresolved blockers from this week
```

When generating standups, supermemory surfaces blockers that are still open, ensuring nothing falls through the cracks.

### Handling Multiple Projects

If you work across several projects, modify your standup skill to aggregate activity per project:

```bash
# Collect commits from multiple repos
for project in backend-api frontend-app mobile-app; do
    echo "## $project"
    cd ~/projects/$project
    git log --since="yesterday" --author="$(git config user.email)" --oneline
done
```

Pass this output to Claude with your `/standup-generator` skill for formatting.

### PDF Generation for Records

For teams that maintain meeting records, the **pdf** skill generates formal standup documents:

```
/pdf
Convert this standup message into a formatted PDF document titled "Daily Standup - March 13, 2026" and save it to standups/2026-03-13.pdf
```

Store these in a shared drive for historical reference and sprint reviews.

## Common Pitfalls and Solutions

**Problem**: The generated standup includes irrelevant commits.

**Solution**: Add filtering in your git log command. Exclude dependency updates and chore commits using `grep -v "chore\|deps\|bump"`.

**Problem**: Webhook delivery fails silently.

**Solution**: Implement error handling with retry logic and notify via email when the primary delivery method fails.

**Problem**: Standup feels too generic.

**Solution**: Add a manual override step. After `/standup-generator` produces the draft, review and append custom notes before running the delivery script.

## Putting It All Together

The complete workflow runs in under a minute once configured. Each morning, invoke `/standup-generator` in Claude Code. Claude pulls your development activity via shell commands, filters and formats it, and produces a polished standup. Run the delivery script to post it to your team channel.

This automation pairs well with the **tdd** skill—test-driven development produces well-structured commits that translate directly into clear progress updates. Pair the two workflows, and standups become a byproduct of good development practices rather than an extra task.

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/articles/best-claude-skills-for-developers-2026/) — Full developer skill stack including tdd
- [Best Claude Skills for DevOps and Deployment](/claude-skills-guide/articles/best-claude-skills-for-devops-and-deployment/) — Automate deployments with Claude skills
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/articles/claude-skills-auto-invocation-how-it-works/) — How skills activate automatically


Built by theluckystrike — More at [zovo.one](https://zovo.one)
