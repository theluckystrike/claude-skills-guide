---
layout: default
title: "Claude Code Skills + Zapier: Step-by-Step"
description: "Connect Claude Code skills to Zapier using webhooks. Practical guide with real examples for automating workflows triggered by skill output."
date: 2026-03-13
categories: [workflows]
tags: [claude-code, claude-skills, zapier, webhooks, automation]
author: "Claude Skills Guide"
reviewed: true
score: 9
permalink: /claude-code-skills-zapier-integration-step-by-step/
---
{% raw %}

# Claude Code Skills + Zapier: Step-by-Step Integration

Connecting Claude Code skills to Zapier lets you route skill output into thousands of external services — Slack, Google Sheets, Notion, GitHub, and more. The integration works through webhooks: your shell sends data to Zapier, and Zapier acts on it.

This guide covers the full setup from creating a Zapier webhook endpoint to triggering downstream actions from Claude skill output.

## How the Integration Works

[Claude skills run locally inside Claude Code](/claude-skills-guide/claude-skills-automated-social-media-content-workflow/). They do not natively speak HTTP. The bridge is a shell script or small helper program that:

1. Runs a Claude Code session and captures output
2. POSTs that output to a Zapier webhook URL
3. Zapier processes the payload and triggers configured actions

You never need a dedicated server. A simple `curl` call or Node.js script handles delivery.

## Step 1: Create a Zapier Webhook Endpoint

In Zapier, create a new Zap and set the trigger to **Webhooks by Zapier**:

1. Click **Create Zap**
2. Choose **Webhooks by Zapier** as the trigger app
3. Select **Catch Hook** as the trigger event
4. Copy the generated webhook URL — you will use this in your shell script

Keep this Zap in test mode until you have confirmed delivery.

## Step 2: Capture Claude Skill Output

[Run a Claude Code session and redirect output](/claude-skills-guide/claude-skills-with-github-actions-ci-cd-pipeline/). Here is a shell script that invokes Claude Code in print mode, captures the output, and sends it to Zapier:

```bash
#!/bin/bash
# zapier-send.sh — run a Claude prompt and POST output to Zapier

ZAPIER_WEBHOOK="https://hooks.zapier.com/hooks/catch/YOUR_ID/YOUR_KEY/"
PROMPT="$1"

# Run Claude Code in print mode (-p) and capture stdout
OUTPUT=$(claude -p "$PROMPT" 2>/dev/null)

# Send to Zapier as JSON
curl -s -X POST "$ZAPIER_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"output\": $(echo "$OUTPUT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'), \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"
```

Call it like:

```bash
chmod +x zapier-send.sh
./zapier-send.sh "Summarize the test results in /tmp/results.txt"
```

## Step 3: Use Skill Output as the Payload

Skills like `/pdf` and `/tdd` produce structured text output. You can include the skill invocation in your prompt and ship the result to Zapier.

Example — generate a test summary with `/tdd` and post it to Zapier:

```bash
#!/bin/bash
ZAPIER_WEBHOOK="https://hooks.zapier.com/hooks/catch/YOUR_ID/YOUR_KEY/"

# Claude Code session with /tdd skill context
OUTPUT=$(claude -p "/tdd Analyze src/auth/ and summarize test coverage gaps" 2>/dev/null)

PAYLOAD=$(python3 -c "
import json, sys
output = sys.argv[1]
print(json.dumps({
    'event': 'tdd_analysis',
    'skill': 'tdd',
    'summary': output,
    'timestamp': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
}))
" "$OUTPUT")

curl -s -X POST "$ZAPIER_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"
```

## Step 4: Configure Zapier Actions

In your Zap, add an action after the webhook trigger. Common patterns:

**Slack notification** — map `{{output.summary}}` to a Slack message body:

```
Channel: #dev-alerts
Message: TDD analysis complete — {{output.summary}}
```

**Google Sheets logging** — append a row with timestamp and output:

```
Sheet: Coverage Log
Row: {{output.timestamp}} | {{output.event}} | {{output.summary}}
```

**GitHub issue creation** — open an issue when coverage gaps are found:

```
Title: Coverage gaps found — {{output.timestamp}}
Body: {{output.summary}}
Labels: testing, automated
```

## Securing Your Webhook

For production use, add a shared secret to your requests and verify it in Zapier's filter step:

```bash
# Add a secret header
curl -s -X POST "$ZAPIER_WEBHOOK" \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Secret: your-shared-secret" \
  -d "$PAYLOAD"
```

In Zapier, add a **Filter** step: only continue if `X-Webhook-Secret` equals your expected value.

## Keeping Context with /supermemory

If you want Claude to remember your Zapier endpoint across sessions, store it using the `/supermemory` skill:

```
/supermemory
Remember that my Zapier webhook for test notifications is stored in $ZAPIER_WEBHOOK env var
Remember to always include the event type and timestamp in webhook payloads
```

On future sessions, `/supermemory` surfaces this context so you maintain consistent payload structure without re-explaining it each time.

## Practical Example: PDF Report → Zapier → Email

When you [generate a report with `/pdf`](/claude-skills-guide/automated-code-documentation-workflow-with-claude-skills/), send the output to Zapier, which emails it to stakeholders:

```bash
#!/bin/bash
# Generate PDF report content and email via Zapier

REPORT=$(claude -p "/pdf Generate a deployment summary report from /tmp/deploy.log" 2>/dev/null)

curl -s -X POST "$ZAPIER_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{
    \"event\": \"report_ready\",
    \"skill\": \"pdf\",
    \"report\": $(echo "$REPORT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'),
    \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
  }"
```

In Zapier, route this to Gmail or SendGrid with the report content in the email body.

## Troubleshooting

**Zapier shows no data received**: Check that your curl command succeeds locally with `--verbose`. Ensure the webhook URL is not expired — Zapier test webhooks time out after a few minutes.

**JSON parse errors**: Use `python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'` to safely encode any text output before embedding it in JSON.

**Action not triggering**: Put the Zap into test mode and send a sample payload manually. Confirm field names match what Zapier expects.

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/) — Top skills every developer should know
- [Claude Skills vs Prompts: Which Is Better?](/claude-skills-guide/claude-skills-vs-prompts-which-is-better/) — Decide when skills beat plain prompts
- [Claude Skills Auto Invocation: How It Works](/claude-skills-guide/claude-skills-auto-invocation-how-it-works/) — How skills activate automatically


Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
