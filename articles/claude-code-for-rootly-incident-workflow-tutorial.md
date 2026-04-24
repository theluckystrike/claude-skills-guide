---

layout: default
title: "Claude Code for Rootly Incident (2026)"
description: "Learn how to integrate Claude Code with Rootly incident management to automate runbooks, streamline response workflows, and reduce MTTR. Practical."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
categories: [tutorials]
tags: [claude-code, rootly, incident-management, devops, automation, claude-skills]
permalink: /claude-code-for-rootly-incident-workflow-tutorial/
reviewed: true
score: 7
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Claude Code for Rootly Incident Workflow Tutorial

When production incidents strike, every minute counts. Teams need (MTTR) Claude Code Rootly incident response 

## Rootly incident management runbookSLO post-mortem Claude Code incident response

- Rootly Rootly 
- Rootly API Rootly API 
- Claude Code 
- Node.js 16+ Python 3.8+

## Rootly Claude Code

## Rootly API

## Rootly Settings → API API

```bash

export ROOTLY_API_KEY="your_api_key_here"
export ROOTLY_ORGANIZATION="your_org_slug"
```

## Rootly MCP Server

## Claude Code MCP (Model Context Protocol) Rootly MCP server

```json
{
 "mcpServers": {
 "rootly": {
 "command": "npx",
 "args": ["-y", "@rootly/mcp-server"],
 "env": {
 "ROOTLY_API_KEY": "{{env.ROOTLY_API_KEY}}",
 "ROOTLY_ORGANIZATION": "{{env.ROOTLY_ORGANIZATION}}"
 }
 }
 }
}
```

 Claude Code (`claude_settings.json`) 

## MCP server

```bash
claude # Claude Code MCP server 
```

 rootly server

## Incident Workflow

## Incident

## Rootly incident

```typescript
// create-incident.ts
import { Rootly } from '@rootly/node';

const rootly = new Rootly({
 apiKey: process.env.ROOTLY_API_KEY!,
 organization: process.env.ROOTLY_ORGANIZATION!
});

interface IncidentPayload {
 title: string;
 severity: 'critical' | 'high' | 'medium' | 'low';
 description: string;
 commander?: string;
}

export async function createIncident(payload: IncidentPayload) {
 const incident = await rootly.incidents.create({
 data: {
 type: 'incident',
 attributes: {
 title: payload.title,
 severity: payload.severity,
 description: payload.description,
 status: 'triggered'
 }
 }
 });

 // incident commander
 if (payload.commander) {
 await rootly.incident_roles.assign(incident.data.id, {
 role: 'commander',
 email: payload.commander
 });
 }

 return incident;
}

// 
await createIncident({
 title: 'API 500 Error Rate Spike',
 severity: 'critical',
 description: 'Error rate exceeded 5% threshold in the last 5 minutes',
 commander: 'on-call@company.com'
});
```

## Runbook

## Claude Code

```python
runbook_executor.py
import subprocess
import json
from typing import List, Dict, Any

class RunbookExecutor:
 def __init__(self, rootly_api_key: str, org: str):
 self.rootly_api_key = rootly_api_key
 self.org = org
 self.incident_id = None

 def start_runbook(self, incident_id: str, runbook_id: str):
 """ Rootly runbook """
 self.incident_id = incident_id
 
 # Rootly runbook 
 runbook = self._get_runbook(runbook_id)
 steps = runbook['attributes']['steps']
 
 results = []
 for step in steps:
 result = self._execute_step(step)
 results.append(result)
 
 # Rootly
 self._update_incident_status(step, result)
 
 return results

 def _execute_step(self, step: Dict) -> Dict[str, Any]:
 """ runbook """
 step_type = step['type']
 
 if step_type == 'command':
 # shell 
 cmd = step['command']
 output = subprocess.run(
 cmd, shell=True, capture_output=True, text=True
 )
 return {
 'step': step['title'],
 'status': 'success' if output.returncode == 0 else 'failed',
 'output': output.stdout,
 'error': output.stderr
 }
 
 elif step_type == 'http_request':
 # HTTP 
 import requests
 response = requests.request(
 method=step['method'],
 url=step['url'],
 headers=step.get('headers', {}),
 timeout=10
 )
 return {
 'step': step['title'],
 'status': 'success' if response.ok else 'failed',
 'output': response.text
 }
 
 return {'step': step['title'], 'status': 'skipped'}

 def _get_runbook(self, runbook_id: str) -> Dict:
 import requests
 response = requests.get(
 f"https://api.rootly.com/runbooks/{runbook_id}",
 headers=self._auth_headers()
 )
 return response.json()

 def _auth_headers(self) -> Dict:
 return {
 'Authorization': f'Bearer {self.rootly_api_key}',
 'Content-Type': 'application/vnd.api+json'
 }

 Claude Code 
CLAUDE_PROMPT = """
 incidentAPI 2 

1. API 
2. 
3. 
4. 

"""

def run_ai_diagnosis(prompt: str) -> str:
 """ Claude Code AI """
 # Claude API
 pass
```

## Post-Mortem

## Incident post-mortem

```typescript
// auto-postmortem.ts
interface IncidentTimeline {
 timestamp: Date;
 action: string;
 actor: string;
 details: string;
}

export async function generatePostmortem(incidentId: string): Promise<string> {
 // 1. incident 
 const incident = await rootly.incidents.get(incidentId);
 const timeline = await rootly.incidents.timeline(incidentId);
 
 // 2. 
 const metrics = await fetchIncidentMetrics(incidentId);
 
 // 3. Claude Code post-mortem
 const prompt = `
 incident post-mortem

Incident 
- : ${incident.data.attributes.title}
- : ${incident.data.attributes.severity}
- : ${calculateDuration(incident)}
- : ${incident.data.attributes.impact}

${formatTimeline(timeline)}

${JSON.stringify(metrics, null, 2)}

1. (Summary)
2. (Root Cause)
3. (Trigger)
4. (Impact)
5. (Timeline)
6. (Resolution)
7. (Prevention)
 `;
 
 // Claude API 
 const postmortem = await callClaudeAPI(prompt);
 
 // 4. Rootly
 await rootly.incident_documents.create(incidentId, {
 title: 'Post-Mortem',
 content: postmortem,
 document_type: 'postmortem'
 });
 
 return postmortem;
}
```

## AI-Driven Incident Response

```yaml
.claude/workflows/incident-response.md
Claude Code Incident Response

- PagerDuty 
- Datadog 
- 

1. 
- incident 
- 
- 

2. 
 Claude Code 
```

{{error_logs}}

{{metrics_data}}
```

3. 

- 
- 
- 

4. 
 runbook 
- 
- 
- incident 

5. 

- on-call 
- incident channel Slack
- escalation 

1. 
 AI 

```typescript
const APPROVED_ACTIONS = [
 'read_logs',
 'check_metrics',
 'run_diagnostics',
 'update_status'
];

const REQUIRES_APPROVAL = [
 'rollback_deployment',
 'scale_infrastructure',
 'clear_cache',
 'execute_rollback'
];

async function executeAction(action: string, params: any) {
 if (REQUIRES_APPROVAL.includes(action)) {
 const approval = await requestHumanApproval(action, params);
 if (!approval.granted) return;
 }
 await performAction(action, params);
}
```

2. 
 incident 

- 
- MTTR 
- 

3. 
- AI 
- 
- 

 Claude Code Rootly incident response 

1. AI 
2. 
3. 
4. 

Practical Integration Patterns

Routing Alerts from Multiple Sources

The most effective Rootly and Claude Code setups pipe alerts from PagerDuty, Datadog, and custom webhooks into one standardized Rootly incident. A routing function maps each source into a consistent incident payload:

```typescript
// alert-router.ts
interface AlertPayload {
 source: string;
 severity: 'critical' | 'high' | 'medium' | 'low';
 title: string;
 description: string;
}

async function routeAlertToRootly(alert: AlertPayload) {
 const incident = await createIncident({
 title: `[${alert.source.toUpperCase()}] ${alert.title}`,
 severity: alert.severity,
 description: alert.description
 });

 // Tag incident with originating source for retrospectives
 await rootly.incident_attributes.set(incident.data.id, {
 alert_source: alert.source,
 auto_created: true
 });

 return incident;
}
```

This centralizes incident creation so your team works from one view regardless of which monitoring tool fired.

Auto-Creating Slack Channels

Automatically create a dedicated Slack channel when an incident is declared:

```typescript
import { WebClient } from '@slack/web-api';
const slack = new WebClient(process.env.SLACK_BOT_TOKEN);

async function createIncidentChannel(incident: any) {
 const channelName = `inc-${incident.data.id}`.toLowerCase();
 const channel = await slack.conversations.create({ name: channelName });

 await slack.chat.postMessage({
 channel: channel.channel!.id!,
 text: `Incident: ${incident.data.attributes.title} | Severity: ${incident.data.attributes.severity}`
 });

 await rootly.incident_attributes.set(incident.data.id, {
 slack_channel_id: channel.channel!.id
 });

 return channel;
}
```

Common Pitfalls to Avoid

Over-automating too quickly: Start with read-only diagnosis. log analysis, metric queries, runbook retrieval. Only expand to write operations after the read-only workflow has proven reliable over several real incidents. Moving too fast to automated remediation before the analysis is accurate leads to automation making things worse during an outage.

Missing human approval gates: Even well-tested automation can execute destructive actions at the wrong moment. Keep the `REQUIRES_APPROVAL` list from the workflow example, and expand it conservatively. Rollbacks, cache clears, and infrastructure scaling should always require an explicit human confirmation before execution.

Ignoring rate limits: The Rootly API enforces rate limits per organization. During a major outage, dozens of alerts can fire simultaneously. Implement exponential backoff and use Rootly's `unique_identifier` field to deduplicate incidents. Pass a hash of the alert title and affected service name so Rootly links subsequent alerts to the existing incident rather than creating duplicates.

Severity case sensitivity: In the Rootly API, severity values must be lowercase (`critical`, `high`, `medium`, `low`). Passing `CRITICAL` or `Critical` returns a 422 validation error that can silently drop incident creation in automated pipelines.

Measuring Impact Over Time

Track these metrics to quantify improvement after deployment:

- MTTA (Mean Time to Acknowledge): Should decrease as Claude Code auto-assigns incidents and creates channels instantly. Establish a baseline before deployment.
- MTTR (Mean Time to Resolve): Improves when automated runbook execution handles the first 15-20 minutes of triage. Compare incidents where runbooks fired versus those that required full manual response.
- False positive remediation rate: How often automated responses ran unnecessarily. Use this signal to tighten alert thresholds and improve runbook decision logic over time.
- Post-mortem completion rate: With auto-generation, this typically rises from 60-70% to near 100% because the skeleton is pre-filled before the incident closes.

Review metrics weekly for the first month after deployment. If MTTA improves but MTTR does not, the bottleneck has shifted to the resolution phase. that becomes your next automation target.

Troubleshooting Common Issues

MCP server fails to connect on startup: Verify `ROOTLY_API_KEY` is exported in your shell before launching Claude Code. The MCP server reads credentials at startup, not lazily per request. Restart Claude Code after setting the variable.

Runbook steps time out: The default HTTP timeout in the Python executor is 10 seconds. For steps that call slow internal services, increase it to 30-60 seconds and add idempotency checks so retries do not double-execute destructive steps.

Post-mortem call returns 409: The `incident_documents.create` endpoint requires the incident to be in `resolved` or `monitoring` status. Calling it while the incident is still `triggered` returns a 409 conflict. Add a status check before generating the post-mortem, or subscribe to the Rootly `incident.resolved` webhook event to trigger generation automatically at the right time.



---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-rootly-incident-workflow-tutorial)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Load Test Scenario Workflow Tutorial](/claude-code-for-load-test-scenario-workflow-tutorial/)
- [Claude Code for Statuspage Workflow Tutorial](/claude-code-for-statuspage-workflow-tutorial/)
- [Claude Code SonarQube Code Quality Workflow](/claude-code-sonarqube-code-quality-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
```

## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


## Best Practices

1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency.

2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed.

3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions.

4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops).

5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like "refactor auth, add tests, and update docs" produce better results when broken into three separate prompts, each building on the previous result.


## Common Issues

**Claude Code ignores the configuration:** Ensure the configuration file is in the correct location. CLAUDE.md must be in the project root (the directory where you run `claude`). Settings go in `.claude/settings.json`. Verify with `ls -la CLAUDE.md .claude/settings.json`.

**Changes are not taking effect:** Claude Code reads CLAUDE.md at the start of each session. If you modify it during a session, the changes apply to new conversations but not the current one. Start a new session to pick up configuration changes.

**Slow performance on large projects:** Add a `.claudeignore` file to exclude large directories (node_modules, .git, dist, build, vendor). This reduces file scanning time and prevents Claude from reading irrelevant files. The format is identical to `.gitignore`.

**Unexpected file modifications:** Check `.claude/settings.json` for overly broad permission patterns. Narrow the allow list to specific commands and file patterns. For sensitive directories, add explicit deny rules.


## Related Guides

- [Claude Code for Incident Management](/claude-code-for-incident-management-workflow-tutorial/)
- [Claude Code for Incident Tracking](/claude-code-for-incident-tracking-workflow-tutorial/)
- [Claude Code Sre On Call Incident](/claude-code-sre-on-call-incident-response-workflow-guide/)
- [Claude Code for Incident Communication](/claude-code-for-incident-communication-workflow-guide/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., \"Always use single quotes\" or \"Never modify files in the config/ directory\"). 1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency. 2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed. 3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions. 4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops). 5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like \"refactor auth, add tests, and update docs\" produce better results when broken into three separate prompts, each building on the previous result. **Claude Code ignores the configuration:** Ensure the configuration file is in the correct location. CLAUDE.md must be in the project root (the directory where you run `claude`). Settings go in `.claude/settings.json`. Verify with `ls -la CLAUDE.md .claude/settings.json`. **Changes are not taking effect:** Claude Code reads CLAUDE.md at the start of each session. If you modify it during a session, the changes apply to new conversations but not the current one. Start a new session to pick up configuration changes. **Slow performance on large projects:** Add a `.claudeignore` file to exclude large directories (node_modules, .git, dist, build, vendor). This reduces file scanning time and prevents Claude from reading irrelevant files. The format is identical to `.gitignore`. **Unexpected file modifications:** Check `.claude/settings.json` for overly broad permission patterns. Narrow the allow list to specific commands and file patterns. For sensitive directories, add explicit deny rules. - [Claude Code for Incident Management](/claude-code-for-incident-management-workflow-tutorial/) - [Claude Code for Incident Tracking](/claude-code-for-incident-tracking-workflow-tutorial/) - [Claude Code Sre On Call Incident](/claude-code-sre-on-call-incident-response-workflow-guide/) - [Claude Code for Incident Communication](/claude-code-for-incident-communication-workflow-guide/)"
      }
    }
  ]
}
</script>

{% endraw %}


