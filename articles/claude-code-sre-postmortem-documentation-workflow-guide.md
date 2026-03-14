---

layout: default
title: "Claude Code SRE Postmortem Documentation Workflow Guide"
description: "Learn how to use Claude Code and skills to streamline SRE postmortem documentation. Practical examples for incident analysis, root cause analysis, and automated documentation workflows."
date: 2026-03-14
author: "theluckystrike"
permalink: /claude-code-sre-postmortem-documentation-workflow-guide/
categories: [workflows, sre]
tags: [claude-code, postmortem, documentation, sre]
---

{% raw %}

# Claude Code SRE Postmortem Documentation Workflow Guide

Every incident tells a story. As Site Reliability Engineers, our job is not just to fix the immediate problem but to capture the lessons learned so our teams can prevent recurrence. Postmortem documentation is the backbone of a learning culture, yet it often gets neglected in the rush to return to normal operations. Claude Code transforms this process from a tedious chore into an efficient, thorough workflow that produces better documentation with less effort.

This guide walks you through using Claude Code and its skill ecosystem to create comprehensive SRE postmortems that drive real organizational improvement.

## Understanding the Postmortem Challenge

Traditional postmortem writing involves multiple time-consuming steps: gathering data from various sources, synthesizing logs and metrics, identifying root cause, and structuring findings into a readable document. Claude Code accelerates each of these phases through its file operations, code analysis capabilities, and specialized skills.

The key advantage lies in context preservation. Claude Code maintains conversation context across lengthy analysis sessions, allowing you to iteratively explore incident details without repeating yourself. This is particularly valuable when investigating complex incidents spanning multiple services and time periods.

## Setting Up Your Postmortem Environment

Before diving into incident documentation, configure Claude Code for SRE workflows. The **internal-comms** skill provides structured templates for incident communications, while the **docx** skill enables generating polished postmortem documents in Microsoft Word format when your organization requires it.

Create a project directory for each incident:

```bash
mkdir -p incidents/INC-2026-0314-service-outage/{logs,metrics,screenshots}
```

This directory structure keeps all incident-related artifacts organized and accessible to Claude Code for analysis. When you later ask Claude to analyze the incident, it can reference files from this structured location.

## Phase One: Data Collection and Preservation

The moments following incident detection are critical for documentation. Preserve everything that might be relevant before starting remediation. Claude Code's bash execution skill helps automate this collection process.

Create a data collection script that your on-call process can trigger:

```bash
#!/bin/bash
# incident-data-collection.sh
INCIDENT_ID=$1
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Capture current state
kubectl get pods -o yaml > "incidents/${INCIDENT_ID}/pods_${TIMESTAMP}.yaml"
kubectl get events --sort-by='.lastTimestamp' > "incidents/${INCIDENT_ID}/events_${TIMESTAMP}.txt"
kubectl top nodes > "incidents/${INCIDENT_ID}/resources_${TIMESTAMP}.txt"

# Export logs from affected services
kubectl logs -l app=${AFFECTED_APP} --tail=10000 > "incidents/${INCIDENT_ID}/app_logs_${TIMESTAMP}.log"

# Capture relevant metrics from Prometheus
curl -s "http://prometheus/api/v1/query?query=up{job='${AFFECTED_APP}'}" > "incidents/${INCIDENT_ID}/metrics_${TIMESTAMP}.json"
```

This script captures infrastructure state, application logs, and metrics at incident time. Running this during an active incident preserves the exact conditions that led to the failure.

## Phase Two: Log Analysis with Claude Code

Once you have collected incident data, use Claude Code to analyze logs and identify patterns. The analysis skill can process large log files and extract meaningful insights.

When presenting logs to Claude, use targeted queries:

> "Analyze these Kubernetes events for the INC-2026-0314 incident. Identify any error patterns, resource constraints, or timing correlations that might explain why the payment service started failing at 14:32 UTC."

Claude Code processes the event log, looking for:
- Error frequency spikes
- Resource exhaustion indicators
- Pod restarts and their timing
- Dependence chain failures
- Configuration changes preceding the incident

The AI explains its findings in context, translating technical events into narrative descriptions that non-on-call team members can understand.

## Phase Three: Root Cause Analysis

Traditional root cause analysis often settles for surface-level explanations like "the database was down" or "the deployment failed." Claude Code helps you dig deeper using the "Five Whys" technique systematically.

When conducting root cause analysis, provide Claude with context:

> "We have an incident where the checkout service returned 500 errors for 23 minutes. The immediate cause was a database connection pool exhaustion. Using the Five Whys technique, help me identify the underlying root cause. Here are the relevant code sections from the database connection handling."

Claude guides you through layered questioning:
- Why did the connection pool exhaust? Because all connections were waiting on slow queries
- Why were queries slow? Because a missing index caused full table scans
- Why was the index missing? Because the migration that added it failed silently
- Why did the migration fail silently? Because error handling caught but didn't surface the failure

This systematic questioning reveals systemic issues that single-incident fixes miss.

## Phase Four: Document Generation

With analysis complete, generate the postmortem document. The **internal-comms** skill includes postmortem templates optimized for clarity and actionability.

Ask Claude to generate your document:

> "Create a postmortem document for INC-2026-0314 using our standard template. Include the incident timeline, root cause analysis using Five Whys, impact assessment (23 minutes, 4,200 failed transactions), resolution steps taken, and specific action items with owners and deadlines."

Claude generates structured content that follows your organization's documentation standards. You can refine specific sections through follow-up prompts.

For organizations requiring formal documentation, use the **docx** skill to create professionally formatted Word documents:

```bash
claude "Use the docx skill to create a formal postmortem document from the INC-2026-0314 analysis, applying our company template with logo placement in the header and compliance section in the footer."
```

## Phase Five: Action Item Tracking

Effective postmortems drive systemic improvement through tracked action items. Claude Code helps translate findings into actionable work.

For each identified improvement, generate a task:

> "Based on the root cause analysis showing that silent migration failures caused this incident, create a GitHub issue for adding migration verification steps to our deployment pipeline. Include the issue title, description with context from this postmortem, and appropriate labels."

This bridges incident analysis and engineering work, ensuring findings translate into preventions.

## Automating Postmortem Workflows

For high-volume incident teams, consider automating portions of the postmortem workflow. Create a Claude skill that combines these phases into a repeatable process.

A postmortem skill might include instructions like:

```yaml
name: postmortem
description: "Streamline SRE postmortem creation from incident data"
trigger: "when I mention incident documentation or postmortem"
actions:
  - Collect incident metadata (time, severity, affected services)
  - Analyze available logs and metrics
  - Generate root cause analysis using Five Whys
  - Create document using internal-comms templates
  - Suggest action items based on findings
```

This skill automates routine portions while preserving human judgment for analysis and conclusions.

## Best Practices for AI-Assisted Postmortems

**Preserve objectivity.** While Claude Code helps analyze data, ensure human reviewers validate root cause conclusions. AI can miss context that humans understand intuitively.

**Document decisions, not just facts.** The value of postmortems lies in understanding why teams made certain choices during incident response. Include decision rationale alongside technical findings.

**Make action items specific.** Vague items like "improve monitoring" rarely get completed. Use Claude to generate specific, measurable action items with clear owners.

**Follow up consistently.** Schedule periodic reviews of past action items to ensure systemic improvements actually happened. Document whether implemented changes achieved their intended effect.

## Conclusion

Claude Code transforms postmortem documentation from a burdensome chore into an efficient workflow that produces higher-quality learning materials. By automating data collection, accelerating analysis, and generating structured documents, your team can focus on what matters: preventing incidents from recurring.

The skills ecosystem—particularly **internal-comms** and **docx**—provides specialized capabilities for different documentation needs. As you develop your postmortem workflows, consider creating custom skills that encode your organization's specific templates and processes.

Effective postmortems build reliability culture. With Claude Code handling the mechanical aspects of documentation, your team can invest more energy in the thoughtful analysis that drives genuine improvement.

{% endraw %}
