---

layout: default
title: "Claude Code for Trello Automation (2026)"
description: "Learn how to use Claude Code CLI to automate Trello workflows, from basic board management to complex automation pipelines."
date: 2026-03-15
last_modified_at: 2026-04-17
author: Claude Skills Guide
permalink: /claude-code-for-trello-automation-workflow-guide/
categories: [guides, workflows]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---

Trello is a powerful project management tool, but managing boards, lists, and cards manually can become time-consuming as projects scale. By combining Claude Code CLI with Trello's REST API, you can automate repetitive tasks, create custom workflows, and integrate Trello smoothly into your development pipeline. Claude Code acts as an intelligent orchestration layer. it can understand your intent, write and run API calls, handle errors, and even suggest improvements to your board structure.

This guide walks you through setting up Claude Code for Trello automation, from basic credential configuration to real-time webhook-driven pipelines, with practical examples you can adapt and deploy today.

Why Automate Trello Through Claude Code?

Before diving into setup, it's worth understanding why Claude Code is a particularly good fit for Trello automation compared to alternatives like Zapier, Make, or custom scripts alone.

| Approach | Strengths | Limitations |
|---|---|---|
| Zapier / Make | No-code, easy triggers | Limited logic, expensive at scale, rigid templates |
| Raw Python scripts | Full control, free | Requires manual maintenance, no natural language |
| Trello Power-Ups | Native integration | JavaScript only, limited to browser context |
| Claude Code + API | Natural language + code, flexible logic, free | Requires API credentials setup |

Claude Code lets you describe what you want in plain language ("move all cards older than 14 days to the Backlog list") and it will generate, test, and run the API calls to make it happen. You can iterate on the logic conversationally, which is significantly faster than editing and re-running scripts manually.

## Setting Up Your Trello API Integration

Before automating Trello with Claude Code, you'll need to generate an API key and token from the [Trello Developer Portal](https://developer.atlassian.com/cloud/trello/guides/rest-api/api-introduction/).

## Step 1: Obtain Your API Credentials

1. Visit https://trello.com/app-key and log in to your Trello account
2. Copy your API key
3. Click the link to generate a token (or use the authorization URL)

The token grants access to your boards, so treat it like a password. The token authorization page will show you the permission scope. for automation scripts that need to create, move, and archive cards, you'll want read and write access.

## Step 2: Configure Environment Variables

Store your credentials securely using environment variables:

```bash
export TRELLO_API_KEY="your_api_key_here"
export TRELLO_TOKEN="your_token_here"
```

For persistent configuration, add these to your shell profile (`~/.zshrc` or `~/.bashrc`). Reload after adding:

```bash
source ~/.zshrc
Verify the variables are set
echo "API key set: ${TRELLO_API_KEY:+yes}"
echo "Token set: ${TRELLO_TOKEN:+yes}"
```

For team workflows, consider using a `.env` file with `python-dotenv` rather than exporting to the shell, so credentials stay project-local and out of your shell history:

```bash
.env (add to .gitignore immediately)
TRELLO_API_KEY=your_api_key_here
TRELLO_TOKEN=your_token_here
```

```python
Load in your script
from dotenv import load_dotenv
import os

load_dotenv() # reads .env from current directory
API_KEY = os.environ["TRELLO_API_KEY"]
TOKEN = os.environ["TRELLO_TOKEN"]
```

## Basic Board Operations with Claude Code

Claude Code can interact with Trello using curl commands or a Python script. Here's a practical example of creating a board management script that covers the most common operations.

## Creating a Trello Management Script

```python
#!/usr/bin/env python3
"""
trello_manager.py. Core Trello API wrapper for Claude Code automation.
Requires TRELLO_API_KEY and TRELLO_TOKEN environment variables.
"""

import os
import time
import requests

API_KEY = os.environ.get("TRELLO_API_KEY")
TOKEN = os.environ.get("TRELLO_TOKEN")
BASE_URL = "https://api.trello.com/1"

def _get(path: str, extra_params: dict = None) -> dict:
 """Shared GET helper with auth params."""
 params = {"key": API_KEY, "token": TOKEN}
 if extra_params:
 params.update(extra_params)
 response = requests.get(f"{BASE_URL}{path}", params=params)
 response.raise_for_status()
 return response.json()

def _put(path: str, extra_params: dict = None) -> dict:
 """Shared PUT helper with auth params."""
 params = {"key": API_KEY, "token": TOKEN}
 if extra_params:
 params.update(extra_params)
 response = requests.put(f"{BASE_URL}{path}", params=params)
 response.raise_for_status()
 return response.json()

def _post(path: str, extra_params: dict = None) -> dict:
 """Shared POST helper with auth params."""
 params = {"key": API_KEY, "token": TOKEN}
 if extra_params:
 params.update(extra_params)
 response = requests.post(f"{BASE_URL}{path}", params=params)
 response.raise_for_status()
 return response.json()

def get_boards() -> list:
 """Fetch all Trello boards for the authenticated user."""
 return _get("/members/me/boards")

def get_lists(board_id: str) -> list:
 """Fetch all lists on a board."""
 return _get(f"/boards/{board_id}/lists")

def get_cards(list_id: str) -> list:
 """Fetch all open cards in a list."""
 return _get(f"/lists/{list_id}/cards")

def create_card(list_id: str, card_name: str, card_desc: str = "") -> dict:
 """Create a new card in a specified list."""
 return _post("/cards", {
 "idList": list_id,
 "name": card_name,
 "desc": card_desc
 })

def move_card(card_id: str, new_list_id: str) -> dict:
 """Move a card to a different list."""
 return _put(f"/cards/{card_id}", {"idList": new_list_id})

def archive_card(card_id: str) -> dict:
 """Archive (close) a card."""
 return _put(f"/cards/{card_id}", {"closed": "true"})

def add_label(card_id: str, label_color: str) -> dict:
 """Add a color label to a card. Colors: green, yellow, orange, red, purple, blue."""
 return _put(f"/cards/{card_id}", {"color": label_color})

def add_comment(card_id: str, comment_text: str) -> dict:
 """Post a comment on a card."""
 return _post(f"/cards/{card_id}/actions/comments", {"text": comment_text})

if __name__ == "__main__":
 boards = get_boards()
 print(f"Found {len(boards)} board(s):")
 for board in boards:
 print(f" - {board['name']} (ID: {board['id']})")
```

## Using the Script with Claude Code

Once saved as `trello_manager.py`, you can call it from Claude Code directly or ask Claude to invoke it for you:

```bash
python3 trello_manager.py
```

This outputs all your boards, making it easy to copy board IDs for further automation. You can also ask Claude Code things like "list all cards in the In Progress list on my Dev board" and it will use this script to fetch and display that data.

## Discovering Board and List IDs

The most common first stumbling block is finding the right IDs. Add this helper to your script for quick discovery:

```python
def print_board_structure(board_id: str) -> None:
 """Print all lists and their card counts for a board."""
 lists = get_lists(board_id)
 print(f"\nBoard structure for {board_id}:")
 for lst in lists:
 cards = get_cards(lst["id"])
 print(f" [{lst['id']}] {lst['name']}. {len(cards)} card(s)")
 for card in cards[:3]: # show first 3 cards as sample
 print(f" • [{card['id']}] {card['name']}")
 if len(cards) > 3:
 print(f" ... and {len(cards) - 3} more")
```

Run this once per board to capture all the IDs you'll reference in your automation scripts.

## Automating Recurring Workflows

One of the most powerful use cases is automating recurring tasks. Here are practical automation patterns that cover the most common scenarios teams encounter.

## Daily Standup Card Creator

Automatically create daily standup cards at the start of each workday:

```bash
#!/bin/bash
daily-standup.sh
Creates a dated standup card in the To Do list each morning.

TODO_LIST_ID="your_todo_list_id"
DATE=$(date +%Y-%m-%d)
DAY=$(date +%A)

python3 -c "
import sys
sys.path.insert(0, '$(pwd)')
from trello_manager import create_card
card = create_card(
 '$TODO_LIST_ID',
 'Standup - $DATE ($DAY)',
 'What did I do yesterday?\n\nWhat am I doing today?\n\nAny blockers?'
)
print(f'Created: {card[\"name\"]} (ID: {card[\"id\"]})')
"
```

Add this to your crontab for automatic execution on weekday mornings:

```bash
Edit crontab
crontab -e

Add this line to run at 9:00 AM Monday-Friday
0 9 * * 1-5 /path/to/daily-standup.sh >> /var/log/trello-standup.log 2>&1
```

## Card Archival Automation

Keep your boards clean by automatically archiving completed cards older than a threshold:

```python
import datetime

def archive_stale_completed_cards(done_list_id: str, days_threshold: int = 7) -> int:
 """
 Archive cards in the Done list that haven't been updated recently.
 Returns the count of archived cards.
 """
 cards = get_cards(done_list_id)
 cutoff = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(days=days_threshold)
 archived_count = 0

 for card in cards:
 # Trello timestamps use ISO 8601 format
 last_activity = datetime.datetime.fromisoformat(
 card["dateLastActivity"].replace("Z", "+00:00")
 )
 if last_activity < cutoff:
 archive_card(card["id"])
 print(f"Archived: '{card['name']}' (last active: {last_activity.date()})")
 archived_count += 1
 time.sleep(0.1) # respect rate limits

 print(f"\nArchived {archived_count} of {len(cards)} cards in Done list.")
 return archived_count

if __name__ == "__main__":
 # Archive cards in Done that haven't moved in 7+ days
 DONE_LIST_ID = "your_done_list_id"
 archive_stale_completed_cards(DONE_LIST_ID, days_threshold=7)
```

## Bulk Card Labeler

When starting a new sprint, quickly label all existing cards by type based on their title keywords:

```python
def auto_label_cards(list_id: str) -> None:
 """
 Scan card titles and apply color labels based on keywords.
 Green = feature, Red = bug, Orange = debt, Blue = docs.
 """
 keyword_map = {
 "green": ["feat", "feature", "add", "new"],
 "red": ["bug", "fix", "error", "crash", "broken"],
 "orange": ["refactor", "debt", "cleanup", "improve"],
 "blue": ["docs", "readme", "guide", "documentation"],
 }

 cards = get_cards(list_id)
 for card in cards:
 title_lower = card["name"].lower()
 for color, keywords in keyword_map.items():
 if any(kw in title_lower for kw in keywords):
 add_label(card["id"], color)
 print(f"Labeled '{card['name']}' as {color}")
 time.sleep(0.1)
 break
```

## Sprint Rollover Script

At sprint end, move all unfinished In Progress cards back to Backlog:

```python
def rollover_sprint(in_progress_list_id: str, backlog_list_id: str) -> None:
 """Move all cards from In Progress back to Backlog and add a rollover comment."""
 cards = get_cards(in_progress_list_id)
 today = datetime.date.today().isoformat()

 print(f"Rolling over {len(cards)} card(s) to Backlog...")
 for card in cards:
 move_card(card["id"], backlog_list_id)
 add_comment(card["id"], f"Rolled over to Backlog on {today} (sprint end).")
 print(f" Moved: {card['name']}")
 time.sleep(0.1)

 print("Sprint rollover complete.")
```

## Integrating with Claude Skills

You can create a custom Claude Skill for Trello management. This enables natural language interactions with your boards directly inside a Claude Code session, without having to remember command-line syntax or card IDs.

Create a skill file at `~/.claude/skills/trello.md`:

```markdown
---
name: trello
description: Manage Trello boards, lists, and cards using natural language commands.
---

You are a Trello management assistant with access to the trello_manager.py script
located at ~/scripts/trello_manager.py.

When the user asks to perform a Trello action, use the Bash tool to call the
appropriate function from trello_manager.py. Always confirm before archiving
or deleting cards. Present results in a readable format with card names and IDs.

Common actions:
- "list my boards" → call get_boards()
- "show cards in [list name]" → call get_lists() then get_cards()
- "create a card [name] in [list]" → call create_card()
- "move [card] to [list]" → call move_card()
- "archive done cards" → call archive_stale_completed_cards()
```

Once installed, you can ask Claude Code things like "move the authentication bug card to In Review" and it will look up the board structure, find the right card and list, and execute the move. no manual ID lookup required.

## Advanced: Webhook-Based Automation

For real-time automation, set up Trello webhooks that trigger Claude Code actions whenever something changes on your board. This is particularly useful for integrating Trello with CI/CD pipelines, Slack notifications, or other services.

## Registering a Webhook

First, register your webhook endpoint with the Trello API:

```python
def register_webhook(callback_url: str, model_id: str, description: str = "") -> dict:
 """
 Register a webhook to receive events for a board or card.
 model_id can be a board ID or card ID.
 callback_url must be publicly accessible (use ngrok for local dev).
 """
 return _post("/webhooks", {
 "callbackURL": callback_url,
 "idModel": model_id,
 "description": description,
 })

Register a webhook for your board
webhook = register_webhook(
 callback_url="https://your-server.com/trello-webhook",
 model_id="your_board_id",
 description="Dev board activity handler"
)
print(f"Webhook registered: {webhook['id']}")
```

## Building the Webhook Handler

```python
from flask import Flask, request, jsonify
import subprocess
import json

app = Flask(__name__)

@app.route("/trello-webhook", methods=["HEAD", "POST"])
def trello_webhook():
 # Trello sends a HEAD request to verify the endpoint is reachable
 if request.method == "HEAD":
 return "", 200

 data = request.json
 action_type = data.get("action", {}).get("type", "")
 action_data = data.get("action", {}).get("data", {})

 # Card moved to Done. trigger archival check or notification
 if action_type == "updateCard" and "listAfter" in action_data:
 card_name = action_data.get("card", {}).get("name", "Unknown")
 list_after = action_data.get("listAfter", {}).get("name", "")

 if list_after == "Done":
 print(f"Card completed: {card_name}")
 # Example: post to Slack, trigger a CI check, send an email
 notify_slack(card_name)

 elif list_after == "In Review":
 card_id = action_data.get("card", {}).get("id")
 # Automatically assign the reviewer label
 from trello_manager import add_label
 add_label(card_id, "purple")
 print(f"Added review label to: {card_name}")

 # New card created. auto-assign to current sprint label
 elif action_type == "createCard":
 card_id = action_data.get("card", {}).get("id")
 card_name = action_data.get("card", {}).get("name", "")
 print(f"New card: {card_name}. applying sprint label")

 return jsonify({"status": "ok"})

def notify_slack(card_name: str) -> None:
 """Send a Slack notification when a card is completed."""
 import requests as req
 webhook_url = os.environ.get("SLACK_WEBHOOK_URL", "")
 if webhook_url:
 req.post(webhook_url, json={"text": f"Trello card completed: *{card_name}*"})

if __name__ == "__main__":
 app.run(port=5000, debug=False)
```

For local development, use `ngrok` to expose your local Flask server:

```bash
Terminal 1: start the webhook server
python3 webhook_server.py

Terminal 2: expose it publicly for Trello to reach
ngrok http 5000
Copy the https://xxxxx.ngrok.io URL and use it as your callback_url
```

## Handling Rate Limits in Webhooks

When webhook events arrive in bursts (e.g., bulk card moves during a sprint transition), you'll hit Trello's rate limit of 100 requests per 10-second window. Add a simple queue to smooth out the request rate:

```python
import queue
import threading
import time

request_queue = queue.Queue()

def worker():
 """Process queued Trello API calls at a controlled rate."""
 while True:
 func, args, kwargs = request_queue.get()
 try:
 func(*args, kwargs)
 except Exception as e:
 print(f"Queue worker error: {e}")
 finally:
 time.sleep(0.12) # ~8 requests/second, well under the 10/second limit
 request_queue.task_done()

Start the worker thread on import
threading.Thread(target=worker, daemon=True).start()

def enqueue(func, *args, kwargs):
 """Add a Trello API call to the rate-limited queue."""
 request_queue.put((func, args, kwargs))
```

Use `enqueue(move_card, card_id, list_id)` instead of calling `move_card` directly when processing bulk operations from webhooks.

## Best Practices and Security Tips

When automating Trello with Claude Code, keep these recommendations in mind to avoid common pitfalls.

Security First
- Never commit API keys or tokens to version control. Run `git status` and verify your `.env` file is in `.gitignore` before every commit.
- Use environment variables for all credentials in development; use a secrets manager (AWS Secrets Manager, HashiCorp Vault, or 1Password Secrets Automation) for production workflows.
- Rotate your Trello token every 90 days, especially if you share the codebase with others. Revoke tokens from https://trello.com/your-name/account.
- Scope webhook endpoints with a shared secret in the URL to prevent spoofed POST requests.

Error Handling
- Always wrap API calls in try/except and handle `requests.HTTPError` specifically. A 401 means an expired or invalid token; a 429 means you've hit the rate limit.
- Log failures with enough context to debug: include the card ID, list ID, and timestamp, not just the exception message.
- Validate board and list IDs before running bulk operations. a wrong list ID can move hundreds of cards to the wrong place with no confirmation prompt.

```python
def safe_move_card(card_id: str, new_list_id: str) -> bool:
 """Move a card with error handling and retry on rate limit."""
 max_retries = 3
 for attempt in range(max_retries):
 try:
 move_card(card_id, new_list_id)
 return True
 except requests.HTTPError as e:
 if e.response.status_code == 429:
 wait = 2 attempt # exponential backoff: 1s, 2s, 4s
 print(f"Rate limited. Waiting {wait}s before retry {attempt + 1}/{max_retries}")
 time.sleep(wait)
 else:
 print(f"API error moving card {card_id}: {e}")
 return False
 return False
```

Rate Limiting
- Trello allows up to 100 requests per 10 seconds per token. For bulk operations on large boards (100+ cards), add `time.sleep(0.15)` between calls to stay within limits.
- Cache board and list metadata locally for scripts that run on a schedule. Board structures rarely change, so there's no reason to fetch list IDs from the API on every run.
- For webhook handlers that might receive bursts of events, use the queue pattern shown above rather than making synchronous API calls per event.

## Putting It All Together: A Complete Workflow

Here is how you might combine everything into a weekly board maintenance workflow that runs automatically:

```bash
#!/bin/bash
weekly-board-maintenance.sh
Runs every Friday at 6pm to prep the board for Monday

echo "=== Weekly Trello Maintenance ==="
python3 -c "
from trello_manager import *
import datetime

DONE_LIST_ID = 'your_done_list_id'
BACKLOG_LIST_ID = 'your_backlog_list_id'
IN_PROG_LIST_ID = 'your_in_progress_list_id'

1. Archive done cards older than 7 days
print('Step 1: Archiving stale done cards...')
archive_stale_completed_cards(DONE_LIST_ID, days_threshold=7)

2. Roll over in-progress cards that weren't finished
print('Step 2: Rolling over unfinished sprint cards...')
rollover_sprint(IN_PROG_LIST_ID, BACKLOG_LIST_ID)

3. Auto-label any unlabeled backlog cards
print('Step 3: Labeling backlog cards...')
auto_label_cards(BACKLOG_LIST_ID)

print('Board maintenance complete.')
"
```

Schedule it with cron:

```bash
0 18 * * 5 /path/to/weekly-board-maintenance.sh >> /var/log/trello-maintenance.log 2>&1
```

This runs every Friday at 6 PM, archives old done cards, rolls over unfinished work, and labels the backlog. with no manual effort.

## Conclusion

Claude Code combined with Trello's API opens up a wide range of automation possibilities. The approach scales from a simple board-listing script all the way to real-time webhook-driven pipelines that integrate with Slack, CI systems, and deployment tools. Start with the basic `trello_manager.py` wrapper, then progressively add the patterns that match your team's workflow problems.

The key to maintaining these automations long-term is treating your Trello scripts like production code: version-control them, add error handling, log failures, and rotate credentials on a schedule. With proper setup and security measures, you'll have a reliable automation layer that keeps your boards organized without manual effort.

## Automating Card Lifecycle Management

Beyond creating and moving cards, a complete Trello automation handles the entire card lifecycle: creation from templates, assignment, due date management, checklist completion tracking, and archiving when work is done. Claude Code generates the full lifecycle manager that responds to card events via webhooks and enforces your team's workflow rules automatically.

For cards that represent recurring tasks, Claude Code generates the template cloner that creates a new card from a template when the previous instance is moved to Done, pre-populating the description, checklist, and labels from the template. This eliminates the manual setup overhead for tasks that repeat on a regular cadence.

Due date management is another area where automation saves time. Claude Code generates the due date monitor that runs daily, finds cards approaching their due date without assignees, and sends a Slack message to the board owner asking for assignment. Cards that pass their due date without being moved get a red label added automatically, making overdue work visible in the board view without manual tracking.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-trello-automation-workflow-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading


- [Advanced Usage Guide](/advanced-usage/). Power user techniques and advanced patterns
- [Claude Code for Mailchimp Automation Workflow Guide](/claude-code-for-mailchimp-automation-workflow-guide/)
- [Claude Code for SRE Toil Automation Workflow](/claude-code-for-sre-toil-automation-workflow/)
- [Claude Code Data Retention Policy Workflow](/claude-code-data-retention-policy-workflow/)
- [Claude Code for Workspace Automation Workflow](/claude-code-for-workspace-automation-workflow/)
- [Claude Code for Runbook Automation Workflow Guide](/claude-code-for-runbook-automation-workflow-guide/)
- [Claude Code for Taskfile Workflow Automation Guide](/claude-code-for-taskfile-workflow-automation-guide/)
- [Claude Code for Review Comment Automation Workflow](/claude-code-for-review-comment-automation-workflow/)
- [Claude Code for MLflow Model Registry Workflow Automation](/claude-code-mlflow-model-registry-workflow-automation/)
- [Claude Code Twilio Voice Call Automation Workflow Guide](/claude-code-twilio-voice-call-automation-workflow-guide/)
- [Claude Code Reporting Automation Workflow](/claude-code-reporting-automation-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

