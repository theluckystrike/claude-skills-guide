---
layout: post
title: "Claude Skills Email Drafting Automation Workflow"
description: "Build an email drafting workflow using custom Claude skills: incident reports, API deprecation notices, and sprint updates with consistent structure."
date: 2026-03-13
categories: [workflows, claude-skills]
tags: [claude-code, claude-skills, email, automation, productivity]
author: "Claude Skills Guide"
reviewed: true
score: 9
---

# Claude Skills Email Drafting Automation Workflow

Developers spend more time writing emails than they should. Incident reports, API deprecation notices, sprint retrospectives sent to stakeholders, onboarding emails for new team members — these follow predictable patterns but take real effort to write well every time. Claude skills let you encode those patterns once and invoke them on demand, producing draft emails in seconds that match your tone and contain the right structure.

This guide covers building a practical email drafting workflow using Claude skills. No external email API required — this works directly inside Claude Code sessions and produces drafts you copy into your email client.

## The Core Approach

Claude skills are Markdown files in `~/.claude/skills/`. You invoke them with `/skill-name` inside a Claude Code session. For email drafting, you create one skill per email type — each skill encodes the format, tone, required fields, and any relevant conventions for that type of communication.

The `supermemory` skill stores your personal context: your name, role, communication preferences, and frequently used boilerplate. Combining a typed email skill with your supermemory context produces drafts that read like you wrote them.

## Step 1: Set Up Your Communication Profile in Supermemory

Before writing any email skills, load your communication context into supermemory:

```
/supermemory
Store my communication profile:
- Name: [your name]
- Role: Senior Backend Engineer
- Team: Platform Infrastructure
- Company: [company name]
- Communication style: direct, minimal pleasantries, technical precision
- Sign-off: "[name] | Platform Infra"
- Common stakeholders:
  - Engineering team (technical, can handle jargon)
  - Product managers (semi-technical, need context)
  - Executives (non-technical, need impact summary)
- I do not use phrases like "hope this finds you well" or "please do not hesitate"
```

Retrieve this at the start of any email drafting session:

```
/supermemory
Retrieve my communication profile before drafting any emails.
```

## Step 2: Create an Incident Report Email Skill

Incident communications follow a strict format: what happened, when, impact, root cause, resolution, and prevention steps. Inconsistent incident emails erode trust. A skill ensures every incident report has the same structure.

Create `~/.claude/skills/incident-email.md`:

```markdown
# incident-email

You are drafting a post-incident email to be sent to stakeholders after a production incident has been resolved.

Required inputs from the user:
- Incident title/description
- Start and end time (include timezone)
- Services affected
- User impact (number of users, functionality degraded)
- Root cause (be specific, no vague "infrastructure issue")
- Resolution steps taken
- Prevention measures (specific action items with owners if known)

Email structure:
Subject: [RESOLVED] Incident: {title} — {date}

Body:
1. One-sentence summary of what happened and that it is resolved
2. Timeline (bullet list: detected at X, resolved at Y, duration Z)
3. Impact (who was affected and how)
4. Root Cause (technical precision is fine for engineering stakeholders; adjust if audience is non-technical)
5. What we did to fix it
6. What we are doing to prevent recurrence (specific action items)

Tone: factual, no apologetic hedging, no marketing language. Acknowledge impact without over-dramatizing.
```

Use it after any incident:

```
/incident-email
Retrieve my communication profile from supermemory first.

Incident details:
- Title: Payment API timeout causing checkout failures
- Start: 2026-03-13 14:32 UTC
- End: 2026-03-13 15:17 UTC
- Services: /api/payments, /api/checkout
- Impact: ~2,400 users unable to complete purchases during window
- Root cause: database connection pool exhausted due to slow query introduced in deploy v2.4.1
- Fix: rolled back v2.4.1, increased connection pool limit as temporary measure
- Prevention: query review added to PR checklist, connection pool monitoring alert added
```

The output is a complete, ready-to-send incident report in under ten seconds.

## Step 3: Create an API Deprecation Notice Skill

API deprecation emails need to be clear about timelines, migration paths, and impact. Ambiguous deprecation notices generate follow-up emails and support tickets. A skill enforces clarity.

Create `~/.claude/skills/deprecation-notice.md`:

```markdown
# deprecation-notice

You are drafting an API deprecation notice to send to developers who use an endpoint or feature that will be removed.

Required inputs:
- What is being deprecated (endpoint path, SDK version, feature name)
- Deprecation announcement date
- End-of-life date (when it stops working entirely)
- Replacement (new endpoint, new SDK version, migration guide URL)
- Breaking changes (what will stop working exactly)
- Migration effort estimate (how long does migration typically take)

Email structure:
Subject: Action Required: {what} deprecating on {EOL date}

Body:
1. What is being deprecated and when it stops working (no ambiguity)
2. Why (brief — framework upgrade, security, performance)
3. What to migrate to (specific replacement with code example)
4. Migration steps (numbered list, copy-paste commands where possible)
5. Timeline summary (announcement date, final deprecation date)
6. How to get help (Slack channel, docs link, support email)

Include a short before/after code snippet showing the old call and the new equivalent.

Tone: developer-to-developer. Assume they are busy. Front-load the timeline.
```

Example invocation:

```
/deprecation-notice
Retrieve my communication profile.

Deprecation details:
- Deprecated: GET /api/v1/users endpoint
- Announcement date: 2026-03-13
- EOL date: 2026-06-01
- Replacement: GET /api/v2/users (same parameters, adds pagination meta)
- Breaking changes: v1 returns array, v2 returns {data: [], meta: {}}
- Migration effort: 30 minutes for most integrations
- Docs: https://docs.example.com/api/v2/users
- Help: #api-support Slack channel
```

## Step 4: Build a Sprint Update Email Skill

End-of-sprint emails to stakeholders follow a pattern: what shipped, what did not, what is next, any blockers that need attention. Most engineers write these from scratch each sprint.

Create `~/.claude/skills/sprint-update.md`:

```markdown
# sprint-update

You are drafting a sprint update email from an engineering team to non-technical stakeholders.

Required inputs:
- Sprint number and dates
- Completed items (feature names, ticket IDs optional)
- Items not completed (and one-sentence reason)
- Upcoming sprint goals
- Blockers or decisions needed from stakeholders

Email structure:
Subject: Sprint {number} Update — {date range}

Body:
1. One-sentence sprint outcome (delivered/partially delivered/did not deliver — be honest)
2. What shipped (bullet list, plain English descriptions, avoid jargon)
3. What did not ship (bullet list with brief reason — scope change, dependency, complexity)
4. Next sprint focus (top 3 goals)
5. Blockers needing input (only include if action is needed from reader)

Tone: factual, no hype. If it was a bad sprint, say so plainly. Stakeholders respect honesty over spin.
Maximum length: 300 words. Force brevity.
```

## Step 5: Create a pdf-Formatted Email Package

For important communications that need a paper trail, combine your email draft with the `pdf` skill to generate a formatted record:

```
/sprint-update
[provide sprint details]

After drafting the email, use /pdf to create a formatted sprint summary document I can attach or archive.
```

The `pdf` skill packages the content with proper formatting, date, and section headers. Store these in a `communications/` folder in your project for future reference.

## Step 6: Batch Email Generation

When you need to send multiple communications at once — say, deprecation notices for five endpoints, or update emails for three teams — use supermemory to store the shared context and iterate:

```
/supermemory
Store this deprecation batch context:
- All notices are for the v1 API sunset on 2026-06-01
- Replacement is the v2 API at the same paths with new response format
- Docs at https://docs.example.com/api/v2
- Help via #api-support

Now draft deprecation notices for these three endpoints:
1. GET /api/v1/users
2. POST /api/v1/orders
3. DELETE /api/v1/sessions/{id}
```

Claude generates all three drafts in sequence, each with the correct endpoint-specific details pulled from the shared context.

## Organizing Your Email Skills

As you build out more skills, name them consistently:

```
~/.claude/skills/
  incident-email.md
  deprecation-notice.md
  sprint-update.md
  onboarding-welcome.md
  vendor-escalation.md
  security-disclosure.md
```

Commit these to your dotfiles repo so they transfer to new machines:

```bash
cp ~/.claude/skills/*.md ~/dotfiles/claude/skills/
cd ~/dotfiles && git add claude/skills/ && git commit -m "chore: add email drafting skills"
```

The investment is about 20 minutes to write each skill. A well-written incident email skill pays for itself the first time you use it during an actual outage, when clarity matters most and time is short.

---

## Related Reading

- [Claude Skills Daily Standup Automation Workflow](/claude-skills-guide/articles/claude-skills-daily-standup-automation-workflow/) — Automate daily team communications
- [Build Personal AI Assistant with Claude Skills Guide](/claude-skills-guide/articles/build-personal-ai-assistant-with-claude-skills-guide/) — Build a broader personal assistant on top of Claude skills
- [Automated Code Documentation Workflow with Claude Skills](/claude-skills-guide/articles/automated-code-documentation-workflow-with-claude-skills/) — Apply the same workflow approach to code docs

Built by theluckystrike — More at [zovo.one](https://zovo.one)
