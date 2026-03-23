---
layout: default
title: "Claude Code for Incident Management Workflow Tutorial"
description: "Learn how to build Claude skills for incident management workflows. Create automated response systems, on-call escalation handlers, and post-incident."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /claude-code-for-incident-management-workflow-tutorial/
categories: [guides, tutorials]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
---

{% raw %}
Claude Code for Incident Management Workflow Tutorial

Incident management is one of the most valuable areas to automate with Claude Code skills. Whether you're handling service outages, security breaches, or production issues, well-designed Claude skills can reduce response times, ensure consistent processes, and free your team from repetitive triage work. This tutorial walks you through building a complete incident management workflow using Claude skills.

Understanding Incident Management in Claude Code

Before diving into code, let's establish what an incident management workflow needs to accomplish. Traditional incident response follows a structured lifecycle: detection, triage, mitigation, resolution, and post-incident review. Each stage generates specific artifacts, status updates, escalation notifications, runbook links, and RCA documents.

Claude skills excel at this because they can:
- Parse incoming alerts and categorize them by severity
- Execute diagnostic commands to gather context
- Generate and send notifications to appropriate channels
- Create and update incident documentation in real-time
- Guide responders through runbooks step-by-step

The key is designing skills that handle one responsibility well, then composing them together for complex workflows.

Building Your First Incident Triage Skill

Every incident workflow starts with triage, quickly understanding what happened and how serious it is. Let's create a skill that accepts an alert and produces a structured incident assessment.

Create a file called `incident-triage.md` in your skills directory:

```markdown
---
name: incident-triage
description: Triages incoming incidents by analyzing alert data, determining severity, and recommending initial actions
tools: [read_file, bash, write_file]
trigger: "incident triage"
---

Incident Triage Skill

You are an experienced on-call engineer performing incident triage. Analyze the provided alert information and produce a structured assessment.

Input Format

When invoked, you will receive:
- Alert summary from {{alert_summary}}
- Error messages from {{error_messages}}
- Relevant metrics from {{metrics}}

Your Task

1. Classify the incident type: Is this a performance issue, availability failure, security concern, or data problem?

2. Determine severity using this matrix:
   - SEV1: Complete service outage, data loss, or security breach
   - SEV2: Significant degradation affecting major functionality
   - SEV3: Minor impact with workaround available
   - SEV4: Cosmetic or informational only

3. Identify affected components from the error patterns

4. Recommend initial actions:
   - Which runbook to consult
   - Whether immediate escalation is required
   - What diagnostic commands to run first

Output Format

Produce your assessment in this structure:
- Incident Type: [classification]
- Severity: [SEV1-4]
- Affected Systems: [list]
- Initial Actions: [numbered list]
- Escalation Recommendation: [yes/no and reason]
```

This skill uses front matter variables (`{{alert_summary}}`, etc.) to receive dynamic input. When you call this skill from another automation, you pass values for these variables.

Creating an On-Call Escalation Handler

Once triage identifies an incident, you need to notify the right people. The escalation skill handles this by determining who to contact based on severity, time of day, and incident type.

```markdown
---
name: incident-escalation
description: Handles incident escalation based on severity, on-call schedules, and incident type
tools: [read_file, bash]
trigger: "escalate incident"
---

Incident Escalation Handler

You manage incident escalation for the platform team. Your job is ensuring the right people are notified quickly.

On-Call Configuration

You have access to on-call rotation data in `/etc/oncall/rotations.yaml`:
- Primary on-call engineer
- Secondary (backup) engineer  
- Manager contact for SEV1 incidents
- Security team alias for security incidents

Escalation Rules

By Severity
- SEV1: Notify primary + secondary + manager immediately
- SEV2: Notify primary; escalate to secondary if no acknowledgment in 5 minutes
- SEV3: Notify primary only
- SEV4: Log for next business day

By Type
- Security incidents: Also notify security-team@company.com
- Database issues: Include dba-team in the notification
- API failures: Include API team lead

Time-Based Rules
- During business hours (9am-6pm local): Use standard escalation
- After hours: Always notify both primary and secondary for SEV2+

Your Task

1. Read the current on-call rotation to identify who is primary/secondary
2. Determine the appropriate escalation path based on the incident details
3. Format the notification message with:
   - Incident summary
   - Severity level
   - Link to incident doc
   - Direct contact info for on-call
4. Execute the appropriate notification command:
   ```
   ./scripts/notify-oncall.sh --severity {{severity}} --type {{incident_type}} --message "{{notification_message}}"
   ```

Output

Confirm the escalation was sent and list all notified parties.
```

Building a Post-Incident Review Automator

After an incident is resolved, teams need to conduct post-incident reviews (PIRs) or root cause analyses (RCAs). This skill automates gathering the necessary data and generating a template.

```markdown
---
name: post-incident-review
description: Generates post-incident review documentation by gathering metrics, logs, and timeline data
tools: [read_file, bash, write_file]
trigger: "generate incident review"
---

Post-Incident Review Generator

You help teams conduct thorough post-incident reviews by automatically gathering relevant data and generating structured documentation.

Input

- Incident ID: {{incident_id}}
- Incident start time: {{start_time}}
- Incident end time: {{end_time}}
- Affected services: {{affected_services}}

Data Gathering Tasks

Execute these commands to collect incident data:

1. Fetch relevant metrics:
   ```bash
   ./scripts/export-metrics.sh --service {{affected_services}} --start {{start_time}} --end {{end_time}}
   ```

2. Retrieve incident timeline from your ticketing system:
   ```bash
   ./scripts/get-incident-timeline.py --id {{incident_id}}
   ```

3. Collect relevant logs from the incident window:
   ```bash
   ./scripts/aggregate-logs.py --services {{affected_services}} --window {{start_time}}-{{end_time}}
   ```

4. Pull alert history leading up to the incident:
   ```bash
   ./scripts/get-alert-history.sh --services {{affected_services}} --hours 2
   ```

Documentation Template

Generate a PIR document with these sections:

Summary
Brief overview of what happened, impact, and duration

Timeline
- Time of first alert
- Time to acknowledge
- Time to mitigation
- Time to resolution

Root Cause Analysis
Technical explanation of the failure

What Went Well
Positive observations and successful mitigations

Action Items
Specific, assignable improvements with owners

Lessons Learned
Process and communication improvements

Output

Write the complete PIR to `/incident-reviews/{{incident_id}}-pir.md` and confirm the file was created.
```

Composing Skills into a Complete Workflow

The real power of Claude skills comes from composing multiple skills together. You can create a master skill that orchestrates the entire incident lifecycle:

```markdown
---
name: incident-commander
description: Orchestrates the complete incident management lifecycle from detection through resolution
tools: [bash]
trigger: "handle incident"
---

Incident Commander

You coordinate the response to production incidents, orchestrating specialized skills at each stage.

Workflow

Stage 1: Triage
Call the incident-triage skill with:
```
alert_summary: {{alert_summary}}
error_messages: {{error_messages}}
metrics: {{metrics}}
```

Stage 2: Escalation
Based on triage results, call incident-escalation:
```
severity: [from triage output]
incident_type: [from triage output]
notification_message: [generated from triage]
```

Stage 3: Resolution
Guide the responder through relevant runbooks. Execute diagnostic commands as needed.

Stage 4: Post-Incident
Once resolved, call post-incident-review:
```
incident_id: {{incident_id}}
start_time: [from incident creation]
end_time: [current timestamp]
affected_services: [from triage]
```

Response Time Targets

- SEV1: Full workflow complete within 30 minutes
- SEV2: Full workflow complete within 2 hours
- SEV3: Resolution within same business day

Output

Provide a summary of actions taken at each stage and confirm all documentation is complete.
```

Best Practices for Incident Management Skills

When building your own incident management skills, keep these principles in mind:

Start simple and iterate. Begin with a single skill that handles one scenario well. Add complexity only when you've validated the basic flow works.

Separate concerns. One skill should do one thing, triage, escalate, document, or diagnose. Composing skills is easier than debugging monolithic skills.

Always generate artifacts. Every incident should produce documentation. This creates an audit trail and enables future analysis.

Include human judgment points. Automated workflows should flag decisions that need human approval. Don't let skills make business decisions autonomously.

Test with simulation. Before deploying, simulate incidents and verify your skills respond correctly. Run tabletop exercises where Claude handles the incident.

Conclusion

Claude skills transform incident management from reactive firefighting into structured, reproducible processes. By building skills for triage, escalation, resolution guidance, and post-incident reviews, you create a system that scales with your organization while maintaining consistency.

Start with the triage skill, add escalation handling, then layer in resolution guidance. Before long, you'll have a complete incident management system that reduces response times and improves outcomes.

The key is treating skills as composable building blocks, each one focused, well-tested, and designed to work with others. Your incident management workflow will only be as strong as its weakest skill, so invest time in making each one solid.


Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

{% endraw %}
