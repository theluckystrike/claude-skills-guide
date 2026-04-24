---
layout: default
title: "Claude Code Skills + Zapier (2026)"
description: "Connect Claude Code skills to Zapier using webhooks. Practical guide with real examples for automating workflows triggered by skill output."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [workflows]
tags: [claude-code, claude-skills, zapier, webhooks, automation]
author: "Claude Skills Guide"
reviewed: true
score: 9
permalink: /claude-code-skills-zapier-integration-step-by-step/
render_with_liquid: false
geo_optimized: true
---

{% raw %}
## Claude Code Skills + Zapier: Step-by-Step Integration

Connecting Claude Code skills to Zapier lets you route skill output into thousands of external services. Slack, Google Sheets, Notion, GitHub, and more. The integration works through webhooks: your shell sends data to Zapier, and Zapier acts on it.

This guide covers the full setup from creating a Zapier webhook endpoint to triggering downstream actions from Claude skill output.

## How the Integration Works

[Claude skills run locally inside Claude Code](/claude-skills-automated-social-media-content-workflow/). They do not natively speak HTTP. The bridge is a shell script or small helper program that:

1. Runs a Claude Code session and captures output
2. POSTs that output to a Zapier webhook URL
3. Zapier processes the payload and triggers configured actions

You never need a dedicated server. A simple `curl` call or Node.js script handles delivery.

## Step 1: Create a Zapier Webhook Endpoint

In Zapier, create a new Zap and set the trigger to Webhooks by Zapier:

1. Click Create Zap
2. Choose Webhooks by Zapier as the trigger app
3. Select Catch Hook as the trigger event
4. Copy the generated webhook URL. you will use this in your shell script

Keep this Zap in test mode until you have confirmed delivery.

## Step 2: Capture Claude Skill Output

[Run a Claude Code session and redirect output](/claude-skills-with-github-actions-ci-cd-pipeline/). Here is a shell script that invokes Claude Code in print mode, captures the output, and sends it to Zapier:

```bash
#!/bin/bash
zapier-send.sh. run a Claude prompt and POST output to Zapier

ZAPIER_WEBHOOK="https://hooks.zapier.com/hooks/catch/YOUR_ID/YOUR_KEY/"
PROMPT="$1"

Run Claude Code in print mode (-p) and capture stdout
OUTPUT=$(claude -p "$PROMPT" 2>/dev/null)

Send to Zapier as JSON
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

Example. generate a test summary with `/tdd` and post it to Zapier:

```bash
#!/bin/bash
ZAPIER_WEBHOOK="https://hooks.zapier.com/hooks/catch/YOUR_ID/YOUR_KEY/"

Claude Code session with /tdd skill context
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

Slack notification. map `{{output.summary}}` to a Slack message body:

```
Channel: #dev-alerts
Message: TDD analysis complete. {{output.summary}}
```

Google Sheets logging. append a row with timestamp and output:

```
Sheet: Coverage Log
Row: {{output.timestamp}} | {{output.event}} | {{output.summary}}
```

GitHub issue creation. open an issue when coverage gaps are found:

```
Title: Coverage gaps found. {{output.timestamp}}
Body: {{output.summary}}
Labels: testing, automated
```

## Securing Your Webhook

For production use, add a shared secret to your requests and verify it in Zapier's filter step:

```bash
Add a secret header
curl -s -X POST "$ZAPIER_WEBHOOK" \
 -H "Content-Type: application/json" \
 -H "X-Webhook-Secret: your-shared-secret" \
 -d "$PAYLOAD"
```

In Zapier, add a Filter step: only continue if `X-Webhook-Secret` equals your expected value.

## Keeping Context with /supermemory

If you want Claude to remember your Zapier endpoint across sessions, store it using the `/supermemory` skill:

```
/supermemory
Remember that my Zapier webhook for test notifications is stored in $ZAPIER_WEBHOOK env var
Remember to always include the event type and timestamp in webhook payloads
```

On future sessions, `/supermemory` surfaces this context so you maintain consistent payload structure without re-explaining it each time.

## Practical Example: PDF Report → Zapier → Email

When you [generate a report with `/pdf`](/automated-code-documentation-workflow-with-claude-skills/), send the output to Zapier, which emails it to stakeholders:

```bash
#!/bin/bash
Generate PDF report content and email via Zapier

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

## Multi-Step Zap Configurations for Developer Workflows

Single-action Zaps are a starting point. Real productivity comes from chaining steps. Here are three complete Zap configurations tuned for Claude skill output.

## Zap: Code Review Alert → Jira Ticket → Slack Notification

This three-step Zap handles the full handoff when Claude flags an issue during code review.

## Trigger: Webhooks by Zapier. Catch Hook

Step 1. Filter: Only continue if `event` equals `code_review_issue`. This prevents unrelated payloads from creating noise in Jira.

Step 2. Jira Software. Create Issue:
```
Project: BACKEND
Issue Type: Task
Automated review flag. {{output.timestamp}}
Description: {{output.summary}}
Priority: Medium
Labels: claude-automated, code-review
```

Step 3. Slack. Send Channel Message:
```
Channel: #code-review
Message: Jira ticket created: {{step2.key}}. {{output.summary}}
```

The shell side is straightforward. Run Claude with a review prompt and include `"event": "code_review_issue"` in the payload only when the output contains a flag phrase:

```bash
#!/bin/bash
ZAPIER_WEBHOOK="https://hooks.zapier.com/hooks/catch/YOUR_ID/YOUR_KEY/"
FILE="$1"

OUTPUT=$(claude -p "Review $FILE for security issues. If you find any, start your response with ISSUE_FOUND." 2>/dev/null)

if echo "$OUTPUT" | grep -q "ISSUE_FOUND"; then
 EVENT="code_review_issue"
else
 EVENT="code_review_clean"
fi

curl -s -X POST "$ZAPIER_WEBHOOK" \
 -H "Content-Type: application/json" \
 -d "{
 \"event\": \"$EVENT\",
 \"file\": \"$FILE\",
 \"summary\": $(echo "$OUTPUT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'),
 \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
 }"
```

The filter in Zapier stops the Jira+Slack chain when the review is clean, so you only create tickets for real issues.

## Zap: Daily Standup Report → Google Sheets → Email Digest

Claude can generate a standup summary from your git log and ship it automatically each morning.

Trigger: Schedule by Zapier. Every Day at 9:00 AM (or use a cron job to hit the webhook on a schedule)

Step 1. Google Sheets. Append Row:
```
Sheet: Standup Log
A: {{output.timestamp}}
B: {{output.summary}}
C: {{output.author}}
```

Step 2. Gmail. Send Email:
```
To: team@yourcompany.com
Subject: Daily standup. {{output.timestamp}}
Body: {{output.summary}}
```

The script generates the summary using your local git history and POSTs it:

```bash
#!/bin/bash
ZAPIER_WEBHOOK="https://hooks.zapier.com/hooks/catch/YOUR_ID/YOUR_KEY/"
GIT_LOG=$(git log --since="24 hours ago" --oneline 2>/dev/null)

OUTPUT=$(claude -p "Write a concise standup summary from these commits: $GIT_LOG" 2>/dev/null)

curl -s -X POST "$ZAPIER_WEBHOOK" \
 -H "Content-Type: application/json" \
 -d "{
 \"event\": \"standup\",
 \"author\": \"$(git config user.name)\",
 \"summary\": $(echo "$OUTPUT" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'),
 \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
 }"
```

Add this to your crontab with `crontab -e`:

```
0 9 * * 1-5 /path/to/standup.sh
```

Weekday standups delivered and logged automatically, zero manual effort.

## Error Handling and Retry Patterns

Zapier retries failed actions automatically for most app steps, but webhook delivery from your shell is fire-and-forget. Build retry logic into the sending side.

## Retry with Exponential Backoff

```bash
#!/bin/bash
ZAPIER_WEBHOOK="https://hooks.zapier.com/hooks/catch/YOUR_ID/YOUR_KEY/"
PAYLOAD="$1"
MAX_RETRIES=3
DELAY=2

for i in $(seq 1 $MAX_RETRIES); do
 HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$ZAPIER_WEBHOOK" \
 -H "Content-Type: application/json" \
 -d "$PAYLOAD")

 if [ "$HTTP_STATUS" = "200" ]; then
 echo "Delivered on attempt $i"
 exit 0
 fi

 echo "Attempt $i failed (HTTP $HTTP_STATUS), retrying in ${DELAY}s..."
 sleep $DELAY
 DELAY=$((DELAY * 2))
done

echo "ERROR: Failed to deliver after $MAX_RETRIES attempts" >&2
exit 1
```

Zapier returns HTTP 200 immediately on receipt. it does not wait for downstream steps. An HTTP 200 means your payload arrived; it does not mean Slack received the message. Check the Zapier task history for downstream step failures.

## Dead-Letter Logging

When delivery fails entirely, log the payload locally so you can replay it later:

```bash
LOG_DIR="$HOME/.zapier-failed"
mkdir -p "$LOG_DIR"

if ! ./send-with-retry.sh "$PAYLOAD"; then
 TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
 echo "$PAYLOAD" > "$LOG_DIR/failed-$TIMESTAMP.json"
 echo "Payload saved to $LOG_DIR/failed-$TIMESTAMP.json"
fi
```

Replay failed payloads by looping over the log directory once connectivity is confirmed:

```bash
for f in "$HOME/.zapier-failed"/*.json; do
 ./send-with-retry.sh "$(cat "$f")" && rm "$f"
done
```

## Structuring Payloads for Complex Zaps

As your Zaps grow past two or three steps, a flat payload gets unwieldy. Nest your data to keep field mapping readable in the Zapier editor.

```bash
PAYLOAD=$(python3 -c "
import json, sys

summary = sys.argv[1]
author = sys.argv[2]
event = sys.argv[3]

payload = {
 'meta': {
 'event': event,
 'timestamp': '$(date -u +%Y-%m-%dT%H:%M:%SZ)',
 'source': 'claude-code',
 'author': author
 },
 'content': {
 'summary': summary,
 'char_count': len(summary),
 'has_issues': 'ISSUE_FOUND' in summary
 }
}
print(json.dumps(payload))
" "$OUTPUT" "$(git config user.name)" "code_review")
```

In Zapier, you now reference `meta.event`, `meta.timestamp`, `content.summary`, and `content.has_issues` as distinct fields. Filters and formatters can branch on `content.has_issues` without parsing text.

## Troubleshooting

Zapier shows no data received: Check that your curl command succeeds locally with `--verbose`. Ensure the webhook URL is not expired. Zapier test webhooks time out after a few minutes.

JSON parse errors: Use `python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'` to safely encode any text output before embedding it in JSON.

Action not triggering: Put the Zap into test mode and send a sample payload manually. Confirm field names match what Zapier expects.

Zapier task history shows step errors: HTTP 200 from the webhook means Zapier received the payload, not that downstream steps succeeded. Always check the task history under Zap Runs in your Zapier dashboard. each step shows its status and error message independently.

Payload too large: Zapier webhooks accept up to 10MB. If Claude output is a long document, truncate or summarize before sending. Use Claude itself to condense: pipe the raw output back through a second `claude -p "Summarize this in 3 sentences: ..."` call before delivery.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-skills-zapier-integration-step-by-step)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/). Top skills every developer should know
- [Claude Skills vs Prompts: Which Is Better?](/claude-skills-vs-prompts-which-is-better/). Decide when skills beat plain prompts
- [Claude Skills Auto Invocation: How It Works](/claude-skills-auto-invocation-how-it-works/). How skills activate automatically
- [How to Use Lm Studio Local — Complete Developer (2026)](/claude-code-lm-studio-local-model-skill-integration-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


