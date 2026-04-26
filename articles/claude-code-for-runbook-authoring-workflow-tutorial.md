---
layout: default
title: "Claude Code for Runbook Authoring (2026)"
description: "Learn how to use Claude Code to create comprehensive runbooks for DevOps and SRE workflows. This tutorial covers practical techniques for documenting."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-runbook-authoring-workflow-tutorial/
categories: [tutorials]
tags: [claude-code, claude-skills]
score: 7
reviewed: true
geo_optimized: true
---


Claude Code for Runbook Authoring Workflow Tutorial

Runbooks are the backbone of reliable operational procedures. Whether you're handling incident response, deployment rollback, or routine maintenance, well-authored runbooks ensure consistency and reduce mean time to recovery (MTTR). In this tutorial, you'll learn how to use Claude Code to create, maintain, and evolve comprehensive runbooks that your team can actually use.

## Why Use Claude Code for Runbook Authoring

Traditional runbook creation is often a tedious documentation exercise that quickly becomes outdated. Claude Code transforms this workflow by acting as an intelligent collaborator that understands your infrastructure, suggests best practices, and helps maintain living documentation that evolves with your systems.

When you use Claude Code for runbook authoring, you gain several advantages:

- Contextual awareness: Claude Code understands your codebase and can reference actual configurations
- Iterative improvement: You can continuously refine runbooks through conversational feedback
- Cross-team consistency: Standardized templates and language across all runbooks
- Validation: Claude Code can verify that procedures are actually executable

## Traditional Runbook Authoring vs. Claude Code Assisted Authoring

The difference in quality and velocity between the old approach and the Claude Code workflow is significant. Here is how the two approaches compare across dimensions that matter to SRE and DevOps teams:

| Dimension | Traditional Approach | Claude Code Assisted |
|---|---|---|
| Initial creation time | 2-4 hours per runbook | 20-40 minutes per runbook |
| Accuracy of commands | Depends on author's memory | Commands pulled from actual config files |
| Consistency across runbooks | Varies by author | Enforced by template + Claude's style |
| Keeping runbooks current | Rarely happens | Triggered by code/config changes |
| Executable validation | Manual spot-check | Claude checks command syntax |
| Rollback coverage | Often missing | Claude asks for rollback steps explicitly |
| Onboarding new team members | Slow, runbooks unclear | Runbooks explain the why, not just the what |

The biggest win is not speed, it is quality. Claude Code asks questions a junior engineer writing their first runbook would not think to ask: What do you do if step 4 fails? What permissions are required? Is there a time window when this procedure should not run?

## Setting Up Your Runbook Project

Before diving into authoring, set up a dedicated structure for your runbooks. This makes them discoverable and maintainable.

```bash
mkdir -p runbooks/{incidents,deployments,maintenance,troubleshooting}
cd runbooks
```

Initialize a simple structure that Claude Code can understand:

```
runbooks/
 README.md
 incidents/
 database-outage.md
 service-degradation.md
 deployments/
 rollback-procedure.md
 blue-green-deploy.md
 maintenance/
 database-backup.md
 certificate-renewal.md
```

The README.md should serve as an index with quick links to each runbook and their current status.

## Writing a Useful CLAUDE.md for Runbook Projects

Before your first authoring session, create a `CLAUDE.md` file at the root of your runbooks directory. This file tells Claude about your infrastructure so the runbooks it generates use your actual tool names, cluster names, and environment variables rather than generic placeholders.

```markdown
Runbook Project Context

Infrastructure
- Kubernetes: EKS clusters named `prod-us-east-1`, `prod-eu-west-1`, `staging`
- Database: PostgreSQL 15 on RDS, connection via `db.internal:5432`
- Container registry: ECR at `123456789.dkr.ecr.us-east-1.amazonaws.com`
- Monitoring: Datadog + PagerDuty
- Secrets: AWS Secrets Manager, prefix `/prod/` for production

Tools Available to On-Call Engineers
- kubectl (configured for all clusters)
- aws CLI (SSO auth)
- psql
- datadog CLI
- our internal `sre-tools` CLI at /usr/local/bin/sre

Severity Levels
- SEV-1: Revenue impact or full outage. 5 min response, wake people up
- SEV-2: Significant degradation. 15 min response, no need to wake
- SEV-3: Minor issues. next business day

Notification Channels
- SEV-1: #incidents-critical Slack + PagerDuty high urgency
- SEV-2: #incidents Slack + PagerDuty low urgency
- SEV-3: #eng-ops Slack only

Required Sections in Every Runbook
1. Severity and estimated resolution time
2. Prerequisites (access, tools, prior notifications)
3. Symptoms / how you know this is the right runbook
4. Diagnosis steps with expected output
5. Resolution steps numbered and atomic
6. Verification steps
7. Rollback steps if applicable
8. Post-incident / post-maintenance actions
```

With this context in place, every runbook Claude generates will use your real cluster names, your severity definitions, and your notification channels. This is the difference between a generic template and a runbook your team will actually trust under pressure.

## Authoring Your First Runbook

Let's walk through creating a runbook for a common scenario: database connection pool exhaustion. Start by invoking Claude Code with your project context:

```bash
claude --print "Create a runbook for diagnosing and resolving database connection pool exhaustion. Include prerequisites, symptom identification, resolution steps, and verification procedures. Use clear numbered steps."
```

Claude Code will generate a comprehensive runbook. Here's a refined example structure you'll receive:

```markdown
Database Connection Pool Exhaustion Response

Severity
- Level: SEV-2 (Service Impact)
- Response Time: 15 minutes

Prerequisites
- Access to production Kubernetes cluster
- Database admin credentials
- Monitoring dashboard access

Symptoms
1. Application returns connection timeout errors
2. Database CPU usage appears normal
3. Active connections at maximum capacity
4. Connection pool metrics show steady increase

Diagnosis Steps
1. Identify affected service: `kubectl get pods -n production`
2. Check current connection count: `SELECT count(*) FROM pg_stat_activity`
3. Review application logs for connection leaks
4. Examine connection pool configuration

Resolution Steps
1. Scale down affected pods to release connections
2. Restart application pods to clear stale connections
3. Increase connection pool size if necessary
4. Verify resolution

Verification
- Confirm connection count returns to baseline
- Test application functionality
- Monitor for 30 minutes
```

## Iterating the Runbook with Follow-up Prompts

The first generation is a skeleton. The real value comes from iterating. A sequence of follow-up prompts that produces a production-ready runbook:

Prompt 2: "Expand the Diagnosis Steps section. Add the actual SQL queries to identify which application is consuming the most connections, and the kubectl commands to check pod logs for connection leak errors."

Prompt 3: "Add a Rollback section covering what to do if increasing the pool size makes things worse. Include the commands to revert the configuration change."

Prompt 4: "Add a Post-Incident section listing what metrics to monitor for the next 24 hours and what threshold should trigger reopening the incident."

After these iterations, the runbook becomes significantly more specific and actionable:

```markdown
Database Connection Pool Exhaustion Response

Severity
- Level: SEV-2 (Service Impact)
- Response Time: 15 minutes
- Estimated Resolution Time: 30-60 minutes

Prerequisites
- kubectl access to `prod-us-east-1` cluster
- Read access to RDS via psql or the `sre` CLI
- Datadog read access
- Slack: post to #incidents

Symptoms

You are likely looking at this runbook if:
- Alerts firing: `DB Connection Pool Near Limit` or `DB Connection Refused Errors`
- Application logs contain: `too many connections` or `connection pool exhausted`
- HTTP 500s increasing on endpoints that write to the database
- Database CPU is normal (rules out a slow query spiral)

Diagnosis Steps

Step 1: Identify current connection count by application

```sql
SELECT
 application_name,
 state,
 count(*) AS connection_count
FROM pg_stat_activity
WHERE datname = 'myapp_production'
GROUP BY application_name, state
ORDER BY connection_count DESC;
```

Expected output: You should see which service is consuming disproportionate connections. Normal steady state is < 80 connections total.

Step 2: Check for idle connections that should have been closed

```sql
SELECT count(*)
FROM pg_stat_activity
WHERE state = 'idle'
 AND query_start < NOW() - INTERVAL '10 minutes';
```

More than 20 idle connections older than 10 minutes suggests a connection leak.

Step 3: Find the offending pods

```bash
Get pods for the service identified in Step 1
kubectl get pods -n production -l app=api-server

Check logs on the most recently restarted pod for connection errors
kubectl logs -n production -l app=api-server --since=15m | grep -i "connection"
```

Step 4: Check current pool configuration

```bash
kubectl get configmap -n production api-server-config -o yaml | grep -i pool
```

Resolution Steps

Option A: Pod restart (fastest, low risk)

Use this when you have confirmed a connection leak (idle connections > 20, older than 10 minutes).

1. Identify the pods with the issue:
 ```bash
 kubectl get pods -n production -l app=api-server
 ```

2. Perform a rolling restart to avoid downtime:
 ```bash
 kubectl rollout restart deployment/api-server -n production
 ```

3. Watch the rollout complete:
 ```bash
 kubectl rollout status deployment/api-server -n production
 ```

4. Monitor connection count recovery (see Verification).

Option B: Scale down then up (use if rolling restart is insufficient)

1. Scale to zero:
 ```bash
 kubectl scale deployment api-server --replicas=0 -n production
 ```

2. Verify all connections released (run Step 1 query; count should drop to 0 or near 0).

3. Scale back up:
 ```bash
 kubectl scale deployment api-server --replicas=4 -n production
 ```

Option C: Increase pool size (use only if load is genuinely higher than pool allows)

1. Edit the configmap:
 ```bash
 kubectl edit configmap api-server-config -n production
 ```
 Change `DB_POOL_SIZE` from current value to `current + 10`. Do not exceed 50 without DBA approval.

2. Trigger a rolling restart to pick up the new configuration:
 ```bash
 kubectl rollout restart deployment/api-server -n production
 ```

Rollback

If Option C (increasing pool size) worsens the situation (database CPU spikes, other services start timing out):

1. Revert pool size to original value:
 ```bash
 kubectl edit configmap api-server-config -n production
 # Set DB_POOL_SIZE back to previous value
 ```

2. Restart pods to apply:
 ```bash
 kubectl rollout restart deployment/api-server -n production
 ```

3. If database is still overwhelmed, consider temporarily reducing replicas:
 ```bash
 kubectl scale deployment api-server --replicas=2 -n production
 ```

Verification

After any resolution step:

```sql
SELECT count(*) FROM pg_stat_activity WHERE datname = 'myapp_production';
```

Target: total connections below 80. Check every 2 minutes for 10 minutes to confirm the count is stable and not climbing again.

Also verify application health:
```bash
kubectl get pods -n production -l app=api-server
All pods should show Running and READY 1/1
```

Post-Incident Actions

1. Post a summary in #incidents with: what happened, which option resolved it, and time to resolution.
2. Open a follow-up ticket if you used Option C (pool size increase). this needs a permanent fix with proper load analysis.
3. Monitor Datadog `DB Connections` dashboard for the next 24 hours. Reopen incident if connections exceed 90 before the follow-up fix is deployed.
4. Schedule a 30-minute blameless postmortem if MTTR exceeded 45 minutes.
```

This is a dramatically more useful runbook than the initial skeleton. The diagnosis steps have real SQL. The resolution options are labeled with when to use each. Rollback is explicit. Post-incident actions are specific.

## Enhancing Runbooks with Claude Code Features

## Adding Interactive Prompts

Modern runbooks can include interactive elements that Claude Code can execute directly. Add executable blocks that your team can run:

```bash
Diagnostic command example
kubectl top pods -n production --sort-by=memory | head -20
```

When authoring, mark executable sections clearly:

```markdown
Execute Diagnostics

Run the following to check current database connections:

```bash
psql -h $DB_HOST -U $DB_USER -c "SELECT datname, count(*) FROM pg_stat_activity GROUP BY datname;"
```
```

## Integrating Monitoring Links

Include direct links to your monitoring infrastructure:

```markdown
Check Metrics
- [Grafana Dashboard](https://grafana.example.com/d/db-connections)
- [Datadog Service Map](https://app.datadoghq.com/service/map)
```

Claude Code can help you generate these links dynamically based on your environment configuration.

## Creating Runbook Diagnostic Scripts

For frequently-run diagnostics, Claude can generate standalone scripts that your team can run directly, rather than copying commands from markdown. Prompt: "Create a bash script that collects all diagnostic information for the database connection pool runbook and outputs a summary report."

```bash
#!/bin/bash
db-connection-diagnostic.sh
Run this at the start of a connection pool incident to collect all relevant state

set -euo pipefail

NAMESPACE="${1:-production}"
DB_HOST="${DB_HOST:-db.internal}"
DB_NAME="${DB_NAME:-myapp_production}"

echo "=== Database Connection Pool Diagnostic Report ==="
echo "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "Namespace: $NAMESPACE"
echo ""

echo "=== Pod Status ==="
kubectl get pods -n "$NAMESPACE" -l app=api-server
echo ""

echo "=== Recent Pod Restarts ==="
kubectl get pods -n "$NAMESPACE" -l app=api-server \
 -o custom-columns="NAME:.metadata.name,RESTARTS:.status.containerStatuses[0].restartCount,AGE:.metadata.creationTimestamp"
echo ""

echo "=== Connection Count by Application ==="
psql -h "$DB_HOST" -U sre_readonly -d "$DB_NAME" -c "
 SELECT application_name, state, count(*)
 FROM pg_stat_activity
 WHERE datname = '$DB_NAME'
 GROUP BY application_name, state
 ORDER BY count(*) DESC;" 2>/dev/null || echo "Could not connect to database"
echo ""

echo "=== Idle Connections Older Than 10 Minutes ==="
psql -h "$DB_HOST" -U sre_readonly -d "$DB_NAME" -c "
 SELECT count(*)
 FROM pg_stat_activity
 WHERE state = 'idle'
 AND query_start < NOW() - INTERVAL '10 minutes';" 2>/dev/null || echo "Could not connect to database"
echo ""

echo "=== Current Pool Configuration ==="
kubectl get configmap -n "$NAMESPACE" api-server-config \
 -o jsonpath='{.data}' | python3 -m json.tool | grep -i pool || echo "Could not read configmap"
echo ""

echo "=== Diagnostic Complete ==="
echo "Copy this output into the #incidents thread before starting resolution."
```

Store this script at `runbooks/incidents/scripts/db-connection-diagnostic.sh` and reference it from the runbook. Claude can generate equivalent scripts for any diagnostic procedure once it understands your tooling.

## Maintaining Runbooks Over Time

The real value of Claude Code comes from ongoing maintenance. Here's how to keep runbooks current:

## Review Triggers

Establish triggers for runbook updates:

```markdown
<!-- Review this runbook when:
- New database version released
- Application architecture changes
- After any SEV-2 or higher incident
- Quarterly baseline review -->
```

## Using Claude Code for Updates

When you need to update a runbook, engage Claude Code contextually:

```bash
claude --print "Update the database connection pool runbook to include new connection pooler (PgBouncer) configuration steps. Include pre-deployment checklist."
```

This approach ensures your runbooks evolve with your infrastructure.

## Runbook Review Workflow

A structured review process prevents runbook rot. Here is a practical workflow using Claude Code to assist with quarterly reviews:

Step 1: Inventory review. Prompt Claude: "Review the runbooks directory and list each runbook with its last-reviewed date from the front matter. Flag any that have not been reviewed in 90 days."

Step 2: Command validation. For each runbook under review, prompt Claude: "Check the commands in this runbook against the current Kubernetes API version (1.29) and flag any deprecated kubectl commands or flags."

Step 3: Gap analysis. Prompt Claude: "Compare this runbook against our CLAUDE.md infrastructure context and flag any references to old tool names, deprecated APIs, or services that no longer exist."

Step 4: Post-incident enhancement. After every SEV-1 or SEV-2 incident, run: "We just resolved a database connection pool incident. Here are notes from the postmortem: [paste notes]. Update the runbook to incorporate these learnings."

This turns each incident into a runbook improvement cycle. Over 6 months, your runbooks become significantly more accurate and complete than anything written purely from memory.

## Version-Controlling Runbooks with Code

Treat runbooks as code by storing them in the same repository as your infrastructure definitions, or in a dedicated repository with the same review process as code.

```bash
After updating a runbook, commit with context
git add runbooks/incidents/database-connection-pool.md
git commit -m "runbook: add PgBouncer steps after Q1 2026 incident

Incorporated lessons from 2026-03-10 SEV-2 incident.
Added Option C (pool size increase) with explicit rollback steps.
Added post-incident monitoring thresholds.

Reviewed by: @alice, @bob
Time-to-resolution improvement estimated: -15 minutes"
```

Git history becomes your runbook audit trail. When an incident occurs, you can see exactly when a procedure was last updated and why.

## Advanced: Creating Runbook Templates

For organizations with multiple similar procedures, create reusable templates. Here's a template structure Claude Code understands:

```markdown
---
title: {PROCEDURE_NAME}
severity: {SEV-1|SEV-2|SEV-3}
estimated_time: {MINUTES}
author: {TEAM_MEMBER}
last_reviewed: {DATE}
---

Overview
{Brief description of what this procedure accomplishes}

Prerequisites
- [ ] Access to {SYSTEM}
- [ ] Required permissions
- [ ] Notification sent to {CHANNEL}

Pre-checks
1. Verify current state
2. Confirm backup exists
3. Notify stakeholders

Steps
1. {Step one}
2. {Step two}
3. {Step three}

Rollback
{Steps to reverse if something goes wrong}

Post-procedure
- [ ] Verify success
- [ ] Update status page
- [ ] Document in incident tracker
```

## Specialized Templates by Category

A single template does not fit all runbook categories. Build a template library with Claude's help. Here are the key template variants and what makes each one different:

Incident Response Template. Optimized for speed under stress. Steps are numbered, terse, and command-heavy. Includes severity matrix, escalation path, and customer communication templates.

Deployment Runbook Template. Structured around go/no-go checkpoints. Includes pre-deployment validation, deployment execution, smoke test checklist, and rollback trigger criteria.

Maintenance Window Template. Focused on change control. Includes stakeholder notification timeline, maintenance window scheduling, change advisory board (CAB) checklist, and post-maintenance sign-off.

Troubleshooting Guide Template. Decision-tree format. Each diagnostic step leads to one of several next steps based on the output. Less linear than incident response, more like a flowchart in text form.

Here is a more detailed deployment runbook template that Claude can populate for any service:

```markdown
---
title: Deploy {SERVICE_NAME} to Production
severity: N/A (planned change)
estimated_time: {MINUTES}
rollback_time: {MINUTES}
author: {TEAM_MEMBER}
last_reviewed: {DATE}
---

Pre-deployment Checklist

Complete ALL items before beginning deployment:

- [ ] Change ticket created and approved: {TICKET_LINK}
- [ ] Deployment announced in #deploys: "Deploying {SERVICE_NAME} {VERSION} to production, ETA {TIME}"
- [ ] Monitoring dashboards open: {DASHBOARD_LINK}
- [ ] On-call engineer notified: @{ONCALL_HANDLE}
- [ ] Previous deployment succeeded (check CI/CD pipeline)
- [ ] Database migrations reviewed if applicable
- [ ] Feature flags configured for gradual rollout if applicable

Deployment Steps

1. Tag and push the release

```bash
git tag v{VERSION} {COMMIT_HASH}
git push origin v{VERSION}
```

2. Trigger the deployment pipeline

```bash
Using your CI/CD system
{CI_DEPLOY_COMMAND}
```

Monitor pipeline: {PIPELINE_LINK}

3. Monitor the rollout

Watch for new pods to become healthy:
```bash
kubectl rollout status deployment/{SERVICE_NAME} -n production --timeout=5m
```

4. Smoke tests

Run immediately after rollout completes:
```bash
{SMOKE_TEST_COMMAND}
```

Expected output: {EXPECTED_OUTPUT}

Go/No-Go Criteria

Proceed if:
- All pods in Running state and READY
- Smoke tests pass
- Error rate on Datadog within baseline (< 0.1%)
- p99 latency within 20% of pre-deployment baseline

Rollback immediately if:
- Any pod fails to start within 3 minutes
- Error rate exceeds 1% for more than 2 minutes
- Smoke tests fail
- On-call receives PagerDuty alert within 5 minutes of deployment

Rollback Procedure

If rollback criteria are met:

```bash
Roll back to previous version
kubectl rollout undo deployment/{SERVICE_NAME} -n production

Verify rollback
kubectl rollout status deployment/{SERVICE_NAME} -n production
```

Confirm rollback completed and error rate returns to baseline before closing the deployment.

Post-deployment Actions

- [ ] Confirm in #deploys: "Deployment complete" or "Rollback executed. investigating"
- [ ] Update deployment log: {DEPLOYMENT_LOG_LINK}
- [ ] Close change ticket
- [ ] Monitor for 30 minutes post-deployment
```

Prompt Claude to fill in the variables for each service: "Populate this deployment template for the api-server service. The smoke test is `curl -f https://api.example.com/health`. The CI deploy command is `gh workflow run deploy.yml -f service=api-server -f version=VERSION`."

## Building a Runbook Quality Checklist

Before any runbook goes into production use, run it through a quality checklist. Claude can both help you build this checklist and evaluate runbooks against it.

| Quality Criterion | What to Check | Fail Example | Pass Example |
|---|---|---|---|
| Commands are copy-paste ready | No `<placeholder>` syntax left in commands | `kubectl get pods -n <namespace>` | `kubectl get pods -n production` |
| Expected outputs are documented | Each diagnosis step says what good output looks like | "Check the logs" | "Logs should show `connected` within 10 seconds" |
| Rollback is explicit | Rollback steps are numbered, not described in prose | "Undo the change if needed" | "1. Run `kubectl rollout undo...` 2. Verify with..." |
| Severity is accurate | Severity matches actual business impact | All runbooks labeled SEV-2 | Severity set based on user impact |
| Time estimates are realistic | Estimates come from actual drill or incident data | "5 minutes" for a 30-minute procedure | "30-45 minutes based on 2026-01-15 incident" |
| Ownership is clear | A specific team or role owns each step | "Someone should notify the team" | "Incident commander posts in #incidents" |
| Post-incident actions exist | Runbook does not end at resolution | Last step: "Verify service is up" | Includes monitoring duration and ticket follow-up |

Prompt Claude: "Evaluate this runbook against the quality checklist and list any criteria it fails with specific line numbers."

## Best Practices Summary

1. Start small: Begin with your most critical procedures
2. Make it executable: Include actual commands, not just descriptions
3. Version control: Store runbooks alongside your code
4. Test regularly: Treat runbooks as code, test them in staging
5. Get feedback: Have operators note what worked and what didn't
6. Automate where possible: Convert manual steps to scripts over time
7. Run game days: Schedule quarterly drills where on-call engineers execute runbooks in staging to validate they still work
8. Write for 3am: Assume the reader is sleep-deprived and stressed. Every ambiguity will cause a mistake under pressure. Ask Claude to review for ambiguity with: "Flag any step in this runbook that is interpreted in more than one way."

## Conclusion

Claude Code transforms runbook authoring from a documentation chore into a collaborative, maintainable practice. By treating runbooks as living documents and using Claude Code's contextual understanding, you create operational procedures that actually get used when incidents occur.

The workflow is clear: start with a solid CLAUDE.md that describes your infrastructure, generate a skeleton runbook with a focused prompt, iterate with follow-up prompts to add specificity, validate commands against your real environment, and establish a review cycle tied to incidents and infrastructure changes.

Start with one critical runbook, refine it through actual use, and gradually expand your library. Your future self, and your on-call team, will thank you.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-for-runbook-authoring-workflow-tutorial)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code for Codemod Authoring Workflow Tutorial](/claude-code-for-codemod-authoring-workflow-tutorial/)
- [Claude Code Algolia GeoSearch Filtering Workflow Tutorial](/claude-code-algolia-geosearch-filtering-workflow-tutorial/)
- [Claude Code CloudFormation Template Generation Workflow Guid](/claude-code-cloudformation-template-generation-workflow-guid/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)




