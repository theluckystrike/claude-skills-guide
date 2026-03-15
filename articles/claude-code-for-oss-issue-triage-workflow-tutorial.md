---
layout: default
title: "Claude Code for OSS Issue Triage Workflow Tutorial"
description: "A hands-on tutorial for building an automated issue triage workflow using Claude Code. Learn to create skills that categorize, prioritize, and route GitHub issues efficiently."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /claude-code-for-oss-issue-triage-workflow-tutorial/
categories: [tutorials]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
---

{% raw %}

Open source maintainers often spend more time organizing issues than solving them. When your project grows beyond a handful of contributors, the volume of incoming issues can become overwhelming. This tutorial walks you through building an automated issue triage workflow using Claude Code skills, transforming how you handle incoming bug reports, feature requests, and community contributions.

## What You'll Build

By the end of this tutorial, you'll have a Claude Code skill that can:

- Automatically classify issues by type (bug, feature, question, documentation)
- Extract and validate essential information from bug reports
- Suggest priority levels based on issue content
- Flag issues that need additional information
- Apply appropriate labels and project assignments

## Prerequisites

Before starting, ensure you have:

- Claude Code installed locally (`claude --version` should return a valid version)
- A GitHub repository where you have admin or triage permissions
- Basic familiarity with YAML configuration
- A GitHub Personal Access Token with `repo` scope

## Step 1: Creating the Triage Skill Structure

Create a new skill file for your triage workflow. Skills live in `~/.claude/skills/` directory:

```bash
mkdir -p ~/.claude/skills
touch ~/.claude/skills/issue-triage.md
```

Now populate the skill file with the core triage logic:

```markdown
# Issue Triage Skill

## Description
Automatically triage incoming GitHub issues by classifying type, validating completeness, suggesting priority, and applying labels.

## Instructions
When analyzing GitHub issues, follow this triage workflow:

1. **Classify the Issue Type**
   - Bug: Reports a software defect or unexpected behavior
   - Feature: Requests new functionality or capabilities
   - Question: Seeks clarification or help
   - Documentation: Relates to docs improvements
   - Enhancement: Improves existing features

2. **Validate Bug Report Completeness**
   For bug reports, check for:
   - Reproduction steps (numbered list)
   - Expected vs actual behavior
   - Environment details (OS, version, browser if applicable)
   - Error messages or stack traces if applicable

3. **Assign Priority**
   - Critical: Security issues, data loss, complete breakage
   - High: Major features broken, significant workarounds needed
   - Medium: Moderate impact, reasonable workarounds exist
   - Low: Minor issues, cosmetic problems, nice-to-have

4. **Check for Duplicates**
   Search existing issues for similar titles or keywords

5. **Generate Triage Response**
   Provide a structured response with:
   - Classification decision
   - Missing information (if any)
   - Suggested labels
   - Suggested priority
   - Duplicate candidates (if found)

## Auto-Invoke Triggers
- When user mentions "triage" or "triaging"
- When user shares an issue URL or content
- When user asks to "analyze issue" or "categorize issue"
```

## Step 2: Configuring GitHub Integration

To interact with GitHub issues programmatically, you need to configure the GitHub CLI or API access. Create a configuration file in your project:

```yaml
# .claude/triage-config.yml
github:
  owner: your-username
  repo: your-repo-name
  token_env: GITHUB_TOKEN

triage:
  default_labels:
    - triage
  
  type_labels:
    bug: ["bug", "triage-needed"]
    feature: ["enhancement", "triage-needed"]
    question: ["question"]
    documentation: ["docs"]
    enhancement: ["enhancement"]
  
  priority_labels:
    critical: ["priority: critical"]
    high: ["priority: high"]
    medium: ["priority: medium"]
    low: ["priority: low"]
  
  # Issues missing these fields get flagged
  required_for_bug:
    - reproduction_steps
    - expected_behavior
    - actual_behavior
    - environment
```

Set your GitHub token as an environment variable:

```bash
export GITHUB_TOKEN=ghp_your_personal_access_token
```

## Step 3: Building the Triage Command

Create a shell script that Claude Code can invoke to fetch and process issues:

```bash
#!/bin/bash
# ~/.claude/scripts/triage-issue.sh

ISSUE_NUMBER=$1
REPO_OWNER=$2
REPO_NAME=$3

if [ -z "$ISSUE_NUMBER" ] || [ -z "$REPO_OWNER" ] || [ -z "$REPO_NAME" ]; then
    echo "Usage: $0 <issue-number> <repo-owner> <repo-name>"
    exit 1
fi

# Fetch issue details
gh issue view $ISSUE_NUMBER --repo "$REPO_OWNER/$REPO_NAME" --json title,body,labels,state
```

Make it executable:

```bash
chmod +x ~/.claude/scripts/triage-issue.sh
```

## Step 4: Creating an Interactive Triage Session

Here's how to use your triage skill in practice. Start a Claude Code session and try:

```
/issue-triage

Please help me triage this issue:

Title: "Application crashes when uploading large files"
Body:
## Description
When I try to upload files larger than 100MB, the app crashes.

## Steps to Reproduce
1. Open the application
2. Click upload button
3. Select a file > 100MB
4. App crashes immediately

## Expected Behavior
File should upload successfully or show error message

## Actual Behavior
App crashes with no error message

## Environment
- OS: Windows 11
- App version: 2.1.0
- Browser: Chrome 120
```

Claude Code will analyze this issue and provide:

- **Classification**: Bug (clearly describes unexpected behavior)
- **Completeness**: Missing error messages/stack traces
- **Priority**: Medium (workaround exists - use smaller files)
- **Suggested Labels**: `bug`, `triage-needed`, `priority: medium`

## Step 5: Automating Label Application

Extend your skill to apply labels automatically. Add this to your triage skill:

```markdown
## Label Application Commands

After triage analysis, apply labels using GitHub CLI:

```bash
# Apply type labels
gh issue edit $ISSUE_NUMBER --add-label "bug"

# Apply priority labels  
gh issue edit $ISSUE_NUMBER --add-label "priority: medium"

# Apply multiple labels at once
gh issue edit $ISSUE_NUMBER --add-label "bug,triage-needed,priority: medium"
```

You can also request label application from Claude:

"Please apply the suggested labels to issue #42"
```

## Step 6: Handling Missing Information

A key triage function is requesting missing information. Create a response template:

```markdown
## Incomplete Issue Response Template

When issues lack required information, generate a friendly request:

```markdown
Thank you for reporting this issue! To help us investigate, could you please provide:

{% if missing.reproduction_steps %}
- **Steps to Reproduce**: A numbered list of actions that trigger the bug
{% endif %}

{% if missing.environment %}
- **Environment**: Your operating system, browser, and application version
{% endif %}

{% if missing.error_messages %}
- **Error Messages**: Any error output or stack traces (if applicable)
{% endif %}

Please add this information as a comment on this issue, and we'll be happy to help troubleshoot!
```
```

## Step 7: Batch Triage for Multiple Issues

For processing multiple issues at once, create a batch processing script:

```bash
#!/bin/bash
# ~/.claude/scripts/batch-triage.sh

REPO=$1
STATE=${2:-open}  # Default to open issues

echo "Fetching all $STATE issues from $REPO..."

# Get issue numbers
issues=$(gh issue list --repo "$REPO" --state "$STATE" --json number --jq '.[].number')

for issue in $issues; do
    echo "--- Triage Issue #$issue ---"
    gh issue view $issue --repo "$REPO" --json title,body
    echo ""
done
```

Use this in Claude Code:

```
Please run the batch triage script for issues in myrepo/my-project and summarize what you find.
```

## Best Practices for Triage Workflows

As you refine your triage workflow, keep these tips in mind:

**Start Simple**: Begin with basic classification before adding complexity. You can always enhance your skill later based on real-world usage.

**Human Review Required**: Automated triage should suggest, not decide. Maintain human oversight for critical decisions like priority assignment.

**Iterate on Templates**: Your issue templates and triage prompts will evolve. Treat them as living documents that improve over time.

**Track Accuracy**: Periodically review triage decisions to identify patterns and improve your skill's accuracy.

**Community Feedback**: Let contributors know when their issues have been triaged. This encourages better bug reports in the future.

## Testing Your Triage Skill

Before deploying your triage workflow to production, test it with sample issues:

1. Create test issues in a sandbox repository
2. Run your triage workflow against each
3. Compare results against manual triage
4. Adjust classification rules as needed
5. Document edge cases for future improvement

## Conclusion

Building an automated issue triage workflow with Claude Code transforms how your project handles incoming issues. What started as hours of manual categorization becomes a streamlined process that provides contributors with fast feedback while giving maintainers more time for actual development work.

Start with the basic skill structure provided in this tutorial, then customize it to match your project's specific needs. The flexibility of Claude Code skills means you can continuously improve your triage workflow as you learn what works best for your community.

---

**Next Steps**: Explore additional automation like auto-responding to issues with welcome messages, setting up issue templates that integrate with your triage workflow, or creating separate skills for specific issue types like security vulnerabilities.

{% endraw %}
