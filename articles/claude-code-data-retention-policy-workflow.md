---
layout: default
title: "How to Use Claude Data Access (2026)"
description: "Configure Claude connectors data access permissions and retention policies. Automate cleanup, manage history, and optimize storage in Claude Code."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [workflows, guides]
tags: [claude-code, claude-skills, data-retention, automation, workflow]
author: theluckystrike
reviewed: true
score: 8
permalink: /claude-code-data-retention-policy-workflow/
geo_optimized: true
---

# Claude Code Data Retention Policy Workflow

Managing conversation history and temporary data is essential when working extensively with Claude Code. Whether you're handling sensitive client information, managing disk space on development machines, or maintaining compliance requirements, implementing a data retention policy prevents accumulation of unnecessary files while preserving what matters.

This guide covers practical approaches to automate data retention in your Claude Code workflows, including conversation archiving, temporary file cleanup, and session management strategies. See also [Automate Code Reviews with Claude Code](/claude-code-code-review-automation-guide/) for more on this topic.

## Understanding Claude Code Data Storage

Claude Code stores several types of data that factor into retention planning:

- Conversation transcripts in `~/.claude/projects/`
- Session snapshots saved during long-running operations
- Skill cache files in `~/.claude/skills/` subdirectories
- Temporary artifacts generated during code execution

The default behavior keeps conversation history indefinitely unless you configure otherwise. For developers running multiple projects daily, this accumulates several gigabytes within months.

## Basic Cleanup Script

Create a simple retention script to manage conversation history:

```bash
#!/bin/bash
retention-cleanup.sh - Keep last 30 days of conversations

RETENTION_DAYS=30
CLAUDE_DATA_DIR="$HOME/.claude/projects"

find "$CLAUDE_DATA_DIR" -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null

echo "Cleaned conversations older than $RETENTION_DAYS days"
```

Run this weekly via cron:

```bash
0 2 * * 0 /path/to/retention-cleanup.sh
```

This approach works for developers who want hands-off cleanup without additional dependencies.

## Using the Supermemory Skill for Selective Archiving

The supermemory skill provides intelligent conversation indexing and retrieval. Combine it with your retention policy to archive important discussions before cleanup:

```
/supermemory archive --project my-project --label important
```

This extracts key decisions and code snippets into a searchable database. Run your cleanup script afterward:

```bash
Archive first, then clean
claude --print "/supermemory archive --project client-api --label compliance"
./retention-cleanup.sh
```

The workflow ensures valuable information survives the automated cleanup cycle.

## Implementing Policy by Project

Different projects demand different retention periods. A personal experiment might need zero retention, while client work requires 90-day minimum storage.

Create project-specific configurations:

```bash
~/.claude/retention-policies.yaml
projects:
 client-work:
 retention_days: 90
 archive_before_delete: true
 skill: supermemory
 
 internal-tools:
 retention_days: 30
 archive_before_delete: false
 
 experiments:
 retention_days: 7
 archive_before_delete: false
```

Reference this configuration in your cleanup script to apply appropriate policies per project.

## PDF Skill Integration for Report Generation

Generate compliance reports using the pdf skill after each retention cycle:

```
/pdf create-report --title "Data Retention Report" --content "Cleaned $(date)"
```

This creates auditable documentation of your retention practices, useful for organizations with regulatory requirements.

## Automating with Scheduled Skills

Claude Code supports skill invocation through CLI. Chain skills for complete automation:

```bash
Full retention workflow
#!/bin/bash

CLAUDE_PROJECTS="$HOME/.claude/projects"

Step 1: Archive important conversations using supermemory
claude -p "/supermemory export --format json --output /tmp/claude-archive-$(date +%Y%m%d).json"

Step 2: Apply retention policy
find "$CLAUDE_PROJECTS" -type d -mtime +30 -exec rm -rf {} \; 2>/dev/null

Step 3: Generate compliance report using pdf
claude -p "/pdf create-report --title 'Retention Report $(date)' --output /tmp/retention-report.pdf"

echo "Retention workflow completed"
```

Schedule this script weekly and forget about manual cleanup.

## Handling Sensitive Data

For projects involving sensitive information, add encryption before retention cleanup:

```bash
#!/bin/bash
Encrypt sensitive projects before standard cleanup

ENCRYPTION_KEY_FILE="$HOME/.claude/encryption.key"
SENSITIVE_PROJECTS=("client-a" "client-b" "healthcare-app")

for project in "${SENSITIVE_PROJECTS[@]}"; do
 project_dir="$HOME/.claude/projects/$project"
 if [ -d "$project_dir" ]; then
 tar -czf "$project_dir.tar.gz" -C "$HOME/.claude/projects" "$project"
 gpg --symmetric --passphrase-file "$ENCRYPTION_KEY_FILE" \
 --batch "$project_dir.tar.gz"
 rm -rf "$project_dir"
 fi
done
```

Encrypted archives maintain compliance while freeing disk space.

## Session-Level Retention Control

Control retention at the session level using Claude Code flags:

```bash
Start session with no persistence
claude

Start session with ephemeral only (no disk writes)
claude
```

Use `--no-persist` for sensitive one-off tasks where you don't need conversation history afterward.

## Monitoring Disk Usage

Track storage trends to refine your retention policy:

```bash
Check current Claude data usage
du -sh ~/.claude
du -sh ~/.claude/projects
du -sh ~/.claude/skills
```

Run this monthly and adjust retention days if storage grows unexpectedly.

## Tagging Conversations for Smarter Retention

Flat time-based deletion works for most cases, but high-value conversations deserve more nuanced treatment. A session where you worked through a complex architecture decision with Claude is not the same as a session where you asked it to rename some variables. Treating them identically wastes the archive value of the former.

Build a tagging habit into your workflow. At the end of any session that produced a decision worth keeping, add a brief marker:

```bash
At end of a significant session
claude -p "Add note to this session: architecture-decision, auth-redesign, 2026-03-15"
```

Your retention script can then query for tagged sessions before applying the standard time-based policy:

```bash
#!/bin/bash
Tagged sessions bypass normal deletion
CLAUDE_PROJECTS="$HOME/.claude/projects"
RETENTION_DAYS=30

for dir in "$CLAUDE_PROJECTS"/*/; do
 project=$(basename "$dir")
 # Skip if tagged as keep-forever
 if [ -f "$dir/.keep" ]; then
 echo "Skipping tagged project: $project"
 continue
 fi
 find "$dir" -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null
done
```

Creating a `.keep` file inside a project directory is a low-friction way to mark it for indefinite retention. The script costs nothing extra in complexity and saves you from accidentally deleting a conversation you need six months later.

## Retention Policies for Team Environments

Individual developer workflows and shared team environments have different retention requirements. On a shared development server where multiple engineers run Claude Code sessions, a single flat policy is not appropriate. one developer's client project should not be deleted because a colleague's experiment triggered a sweep.

Structure shared environments with per-user subdirectories:

```
/shared/claude-data/
 alice/
 projects/
 retention-policy.yaml
 bob/
 projects/
 retention-policy.yaml
 team-shared/
 projects/
 retention-policy.yaml
```

Each user owns their subdirectory and configures their own policy. A team-shared directory holds conversations and artifacts that belong to the group rather than any individual. Apply a longer default retention period to the team-shared directory since those sessions typically carry higher business value.

Coordinate cleanup timing so multiple engineers' cron jobs do not run simultaneously and compete for the same resources. Stagger them by user. Alice's cron runs at 2am, Bob's at 3am. This is a small detail that prevents confusing log entries and the occasional file-lock conflict on shared storage.

## Integrating Retention with Git Workflows

Conversation history often maps to code changes in your repository. A session where you designed a new API endpoint with Claude's help is directly related to the pull request that implemented it. Linking the two gives you a richer audit trail than either provides alone.

Add a convention to your git commit messages when a session was significant:

```bash
Reference the Claude session hash in your commit
git commit -m "Redesign auth token flow

Implementation based on architecture discussion.
Claude session: ~/.claude/projects/api-service/sessions/2026-03-15-auth"
```

Your retention script can then respect the git reference before deleting:

```bash
#!/bin/bash
Find sessions referenced in git history and protect them
referenced=$(git log --all --format="%B" | grep "Claude session:" | \
 awk '{print $NF}')

for session_path in $referenced; do
 touch "$session_path/.keep"
done
```

Running this script before your cleanup pass automatically protects any session that a commit message references. Sessions that never made it into a meaningful commit get cleaned up on schedule. This turns your git history into a natural signal for retention importance without requiring manual tagging.

## Verifying Your Retention Policy Works

A retention policy that runs silently is difficult to trust. You need a way to verify that cleanup actually happened, that the right files were deleted, and that archives were created correctly before deletion.

Add a dry-run mode to your cleanup script:

```bash
#!/bin/bash
Add --dry-run flag for verification
DRY_RUN=false
if [ "$1" == "--dry-run" ]; then
 DRY_RUN=true
 echo "DRY RUN - no files will be deleted"
fi

CLAUDE_PROJECTS="$HOME/.claude/projects"
RETENTION_DAYS=30

find "$CLAUDE_PROJECTS" -type d -mtime +$RETENTION_DAYS | while read dir; do
 if [ "$DRY_RUN" == "true" ]; then
 echo "Would delete: $dir ($(du -sh "$dir" | cut -f1))"
 else
 rm -rf "$dir"
 fi
done
```

Run the dry-run version before your first live execution against any environment. Review the output to confirm the script is targeting the right directories and nothing critical is in scope. Once you are satisfied, run it live and compare the before/after disk usage numbers.

Schedule a monthly verification run:

```bash
Monthly audit cron - dry run only, sends output to log
0 6 1 * * /path/to/retention-cleanup.sh --dry-run >> /var/log/claude-retention-audit.log 2>&1
```

Reviewing this log quarterly tells you whether your retention window is correctly calibrated. If the dry run shows hundreds of directories that would be deleted, your actual cleanup is running correctly. If it shows almost nothing, either your cleanup is working well or there is a bug. the log history helps you tell which.

## Best Practices Summary

- Define retention periods per project based on client requirements and personal needs
- Archive before deleting using supermemory to preserve searchable history
- Generate compliance reports with pdf skill for audit trails
- Encrypt sensitive data before applying aggressive retention policies
- Monitor storage trends and adjust policies quarterly
- Test cleanup scripts on non-critical data first
- Tag high-value sessions with `.keep` files to bypass time-based deletion
- Use dry-run mode to verify scripts target the correct directories before live runs
- Link sessions to git commits for automatic protection of architecturally significant conversations
- Stagger cron schedules in shared environments to avoid resource conflicts

## Conclusion

A data retention policy for Claude Code prevents unbounded storage growth while preserving important conversation context. Start with a simple 30-day cleanup script, then layer in project-specific policies, archiving with supermemory, and compliance reporting with pdf as your needs evolve.

The key is automation, set up scheduled runs and let the system manage itself. Your future self will appreciate clean storage and searchable archives when you need to reference decisions from last month.




**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [save Claude Code conversations](/claude-code-save-conversation-guide/) — How to save and export conversation history
---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-data-retention-policy-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Cookie Consent Implementation](/claude-code-cookie-consent-implementation/). Cookie consent and data retention work together
- [Claude Skills Compliance SOC2 ISO27001 Guide](/claude-skills-compliance-soc2-iso27001-guide/). Compliance frameworks require data retention policies
- [Claude Code Permissions Model Security Guide 2026](/claude-code-permissions-model-security-guide-2026/). Security and data retention are linked
- [Claude Skills for Enterprise Security and Compliance](/claude-skills-for-enterprise-security-compliance-guide/). Enterprise compliance includes data retention

Built by theluckystrike. More at [zovo.one](https://zovo.one)


