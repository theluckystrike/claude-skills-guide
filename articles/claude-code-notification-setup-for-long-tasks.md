---

layout: default
title: "Claude Code Notification Setup for Long"
description: "Learn how to configure notifications in Claude Code to stay informed during long-running operations. Practical examples and code snippets for developers."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-notification-setup-for-long-tasks/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
geo_optimized: true
---


Long-running tasks are a common challenge when working with AI-assisted development. Whether you're refactoring a large codebase, generating documentation across multiple files, or running extensive test suites, knowing when your task completes, without constantly monitoring the terminal, improves your workflow significantly.

This guide covers how to set up notification systems for Claude Code to alert you when long tasks finish, using native macOS and Linux tools plus practical integration patterns. By the end, you'll have a complete notification toolkit that keeps you productive while Claude handles heavy lifting in the background.

## Why Long-Running Claude Code Tasks Need Notifications

Modern AI-assisted development introduces a new category of task: operations that take anywhere from two minutes to twenty. Traditional development tools, compilers, linters, test runners, usually finish in seconds. Claude Code is different. Analyzing a 50,000-line codebase for security vulnerabilities, generating comprehensive API documentation, or migrating an entire test suite to a new framework can occupy Claude for five, ten, or fifteen minutes.

Without notifications, developers face a bad tradeoff: either stay glued to the terminal (wasting attention) or switch to other work and forget to check back (wasting Claude's output). A good notification system eliminates both failure modes.

The productivity math is straightforward. If a Claude Code task takes eight minutes and you have a five-second setup time to add a notification wrapper, you recover those eight minutes of attention for focused work. Over a week of regular Claude Code usage, that adds up to hours of reclaimed focus time.

## Understanding Claude Code Task Notifications

Claude Code runs in your terminal, which means standard terminal output keeps you informed while the process runs. However, for tasks that take minutes or longer, you need external notification mechanisms to avoid wasting time checking the terminal.

The key is combining Claude Code with system-level notification tools that can trigger alerts based on exit codes, output patterns, or elapsed time.

Claude Code's `--print` flag is particularly important for notification workflows. It causes Claude to output its response to stdout and exit, making it easy to chain with shell operators and capture output for parsing. Without `--print`, Claude runs interactively and notification wrappers behave differently.

## Setting Up macOS Notifications with Terminal Notifiers

macOS users have several options for sending notifications. The `terminal-notifier` gem provides a reliable way to send alerts from command-line scripts:

```bash
Install terminal-notifier
gem install terminal-notifier

Send a notification when a task completes
terminal-notifier -title "Claude Code" -message "Task completed successfully"
```

For Claude Code workflows, wrap your commands with notification triggers:

```bash
Run a long task and notify on completion
claude --print "Analyze the entire codebase for security issues" && \
 terminal-notifier -title "Claude Code" -message "Security analysis complete"
```

The `&&` ensures the notification only fires on successful completion. Use `||` if you want notifications for failures instead.

You can also use the built-in `osascript` command without installing any additional tools:

```bash
macOS built-in notification (no install required)
osascript -e 'display notification "Security analysis complete" with title "Claude Code"'

Full workflow with built-in tools only
claude --print "Analyze the entire codebase for security issues" && \
 osascript -e 'display notification "Analysis complete" with title "Claude Code" sound name "Glass"'
```

The `osascript` approach works on any Mac without dependencies, making it a good choice for teams where installing gems requires approval.

macOS Notification Comparison

| Tool | Install Required | Sound Support | Click Actions | Best For |
|------|-----------------|---------------|---------------|----------|
| `terminal-notifier` | Yes (gem) | Yes | Open URL/App | Power users |
| `osascript` | No (built-in) | Yes | None | Zero-setup teams |
| `alerter` | Yes (brew) | Yes | Button callbacks | Advanced automation |

## Linux Desktop Notifications

Linux users can use `notify-send` from the `libnotify` package:

```bash
Install on Debian/Ubuntu
sudo apt install libnotify-bin

Install on Fedora/RHEL
sudo dnf install libnotify

Install on Arch
sudo pacman -S libnotify

Send notification
notify-send "Claude Code" "Long-running task finished"
```

Combine this with Claude Code in your shell:

```bash
claude --print "Generate documentation for all modules" ; \
 notify-send "Claude Code" "Documentation generation complete"
```

Unlike the `&&` operator, `;` runs the notification regardless of the previous command's exit status, useful when you want alerts for both successes and failures.

Linux also supports urgency levels and expiration times, which `terminal-notifier` on macOS lacks:

```bash
Low urgency (fades quickly)
notify-send -u low "Claude Code" "Background task started"

Normal urgency (default)
notify-send "Claude Code" "Task complete"

Critical urgency (stays until dismissed)
notify-send -u critical "Claude Code" "Deployment pipeline failed"

Auto-expire after 10 seconds (in milliseconds)
notify-send -t 10000 "Claude Code" "Refactoring complete"
```

## Practical Example: Cross-Platform Notification Scripts

Create reusable notification scripts for common scenarios. This pattern works across macOS and Linux:

```bash
#!/bin/bash
notify-complete.sh

MESSAGE="${1:-Task complete}"
TITLE="${2:-Claude Code}"

if [[ "$(uname)" == "Darwin" ]]; then
 terminal-notifier -title "$TITLE" -message "$MESSAGE"
else
 notify-send "$TITLE" "$MESSAGE"
fi
```

Make it executable and use it in your Claude Code workflows:

```bash
chmod +x ~/scripts/notify-complete.sh

Usage with Claude Code
claude --print "Run full test suite" && \
 ~/scripts/notify-complete.sh "Test suite finished" "CI Update"
```

A more complete version handles edge cases and logs results:

```bash
#!/bin/bash
claude-notify.sh. full-featured notification wrapper

TASK="$1"
TITLE="${2:-Claude Code}"
LOG_FILE="$HOME/.claude-notify.log"

if [ -z "$TASK" ]; then
 echo "Usage: claude-notify.sh 'task description' ['notification title']"
 exit 1
fi

START_TIME=$(date +%s)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting: $TASK" >> "$LOG_FILE"

Run Claude Code task
claude --print "$TASK"
EXIT_CODE=$?

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ $EXIT_CODE -eq 0 ]; then
 STATUS="Completed"
 MSG="$TASK. finished in ${DURATION}s"
else
 STATUS="Failed"
 MSG="$TASK. failed after ${DURATION}s (exit $EXIT_CODE)"
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] $STATUS: $TASK (${DURATION}s, exit $EXIT_CODE)" >> "$LOG_FILE"

Send platform-appropriate notification
if [[ "$(uname)" == "Darwin" ]]; then
 if command -v terminal-notifier &> /dev/null; then
 terminal-notifier -title "$TITLE: $STATUS" -message "$MSG" -sound default
 else
 osascript -e "display notification \"$MSG\" with title \"$TITLE: $STATUS\""
 fi
else
 URGENCY="normal"
 [ $EXIT_CODE -ne 0 ] && URGENCY="critical"
 notify-send -u "$URGENCY" "$TITLE: $STATUS" "$MSG"
fi

exit $EXIT_CODE
```

This version logs every task with timestamps and duration, making it easy to audit how long Claude Code tasks take over time.

## Advanced: Notification Based on Task Output

For more sophisticated scenarios, parse Claude Code output and send different notifications based on results:

```bash
#!/bin/bash
notify-result.sh

OUTPUT=$(claude --print "$1")
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
 STATUS="Success"
else
 STATUS="Failed with exit code $EXIT_CODE"
fi

Extract summary from output (adjust grep pattern for your needs)
SUMMARY=$(echo "$OUTPUT" | tail -5 | head -3)

if [[ "$(uname)" == "Darwin" ]]; then
 terminal-notifier -title "Claude Code: $STATUS" -message "$SUMMARY"
else
 notify-send "Claude Code: $STATUS" "$SUMMARY"
fi
```

You can extend this pattern to trigger different actions based on what Claude found. For example, if you're running a security audit:

```bash
#!/bin/bash
security-audit-notify.sh

OUTPUT=$(claude --print "Scan the codebase for security vulnerabilities and summarize findings")
EXIT_CODE=$?

Count vulnerability mentions in output
CRITICAL=$(echo "$OUTPUT" | grep -ic "critical")
HIGH=$(echo "$OUTPUT" | grep -ic "high severity")

if [ "$CRITICAL" -gt 0 ]; then
 # Critical findings: sound + critical urgency
 if [[ "$(uname)" == "Darwin" ]]; then
 terminal-notifier -title "SECURITY ALERT" \
 -message "Claude found $CRITICAL critical issues. review immediately" \
 -sound Basso
 else
 notify-send -u critical "SECURITY ALERT" \
 "Claude found $CRITICAL critical issues. review immediately"
 fi
elif [ "$HIGH" -gt 0 ]; then
 # High severity: normal notification
 notify-send "Security Scan" "Found $HIGH high-severity issues"
else
 # Clean: simple success
 notify-send "Security Scan" "No critical or high-severity issues found"
fi
```

## Integration with Claude Skills

Several Claude skills enhance notification workflows for specific tasks:

- pdf skill: Generate reports and get notified when batch PDF processing completes
- tdd skill: Run test-driven development cycles and receive alerts when test suites pass or fail
- frontend-design skill: Generate multiple design iterations and get notified when all renders are complete
- supermemory skill: Process large knowledge bases and receive notification when indexing finishes

Each skill can be wrapped with notification scripts to keep you informed without terminal monitoring.

A practical TDD workflow with notifications looks like this:

```bash
#!/bin/bash
tdd-cycle.sh. run TDD cycle and notify on each phase

echo "Phase 1: Generating test cases..."
claude --print "Use the tdd skill to generate test cases for the auth module" && \
 notify-send "TDD" "Test cases generated. review before implementation"

read -p "Press Enter when you've reviewed the tests..."

echo "Phase 2: Implementing to pass tests..."
claude --print "Implement the auth module to pass the generated tests" && \
 notify-send "TDD" "Implementation complete. running tests"

echo "Phase 3: Verifying tests pass..."
npm test 2>&1 | tail -20
[ $? -eq 0 ] && notify-send -u critical "TDD" "All tests passing. cycle complete"
```

## Using Aliases for Quick Notification Access

Add shell aliases to your `.bashrc` or `.zshrc` for faster usage:

```bash
Quick notify aliases
alias cn='terminal-notifier -title "Claude Code"'
alias cn_success='terminal-notifier -title "Claude Code" -message "Task succeeded"'
alias cn_fail='terminal-notifier -title "Claude Code" -message "Task failed"'
```

Then use them directly:

```bash
claude --print "Migrate database schema" && cn_success || cn_fail
```

For teams, it's worth putting these aliases in a shared dotfile or a team `.env` that everyone sources:

```bash
~/.zshrc. Claude Code notification helpers

Cross-platform notify function
_ccnotify() {
 local title="$1"
 local msg="$2"
 local urgency="${3:-normal}"
 if [[ "$(uname)" == "Darwin" ]]; then
 terminal-notifier -title "$title" -message "$msg" -sound default 2>/dev/null || \
 osascript -e "display notification \"$msg\" with title \"$title\""
 else
 notify-send -u "$urgency" "$title" "$msg"
 fi
}

alias cc_done='_ccnotify "Claude Code" "Task complete"'
alias cc_fail='_ccnotify "Claude Code" "Task FAILED" critical'

Usage: cc_run "my long task description"
cc_run() {
 claude --print "$1" && _ccnotify "Claude Code" "Done: $1" || _ccnotify "Claude Code" "Failed: $1" critical
}
```

## Notification Sounds and Critical Alerts

For important tasks, enable sound alerts alongside visual notifications:

```bash
macOS with sound
terminal-notifier -title "Claude Code" -message "Deployment complete" -sound default

macOS with specific system sound
terminal-notifier -title "Claude Code" -message "Tests passed" -sound Glass
terminal-notifier -title "Claude Code" -message "Build failed" -sound Basso

Linux with sound (requires paplay or aplay)
notify-send -u critical "Claude Code" "Deployment complete"
paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null

Linux combined notification + sound in one script
notify_with_sound() {
 notify-send "$1" "$2"
 paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || \
 aplay /usr/share/sounds/alsa/Front_Left.wav 2>/dev/null || true
}
```

The `-u critical` flag on Linux raises the notification priority, ensuring it appears even when Do Not Disturb is enabled. On macOS, critical system alerts bypass Focus modes when using `alerter` instead of `terminal-notifier`.

Available macOS system sounds for `terminal-notifier -sound`: `Basso`, `Blow`, `Bottle`, `Frog`, `Funk`, `Glass`, `Hero`, `Morse`, `Ping`, `Pop`, `Purr`, `Sosumi`, `Submarine`, `Tink`, and `default`.

## Troubleshooting Notification Issues

If notifications aren't appearing, check these common issues:

1. Permission problems on macOS: macOS requires notification permissions. Go to System Settings > Notifications > Terminal (or iTerm2) and enable alerts. After installing `terminal-notifier`, you may need to run it once interactively to trigger the permission dialog.

2. PATH issues: Ensure notification tools are in your PATH when running from scripts. Use full paths if needed: `/usr/local/bin/terminal-notifier`. Check with `which terminal-notifier`.

3. Background process limitations: Notifications from background jobs may not display in some terminal configurations. Use `wait` to ensure the parent shell is still active, or foreground the notification call explicitly.

4. Display server issues on Linux: Ensure DBus is running for libnotify to communicate with notification daemons. Check with `dbus-launch echo test`. On headless servers or in SSH sessions without X forwarding, desktop notifications won't work, use email or Slack notifications instead (see below).

5. Focus/Do Not Disturb: On macOS, notifications is suppressed during Focus modes. Use `terminal-notifier` with the `-ignoreDnD` flag (if your version supports it) or switch to `alerter` for critical tasks.

6. Ruby gem path issues: If `terminal-notifier` was installed with a specific Ruby version, it may not be in the default PATH. Use `gem environment` to find the gem binaries directory and add it to your PATH.

## Fallback: SMS or Email Notifications

For truly long-running tasks (30+ minutes) or headless servers, consider email or SMS fallbacks:

```bash
#!/bin/bash
long-task-notify.sh. email fallback for server-side tasks

TASK="$1"
EMAIL="${NOTIFY_EMAIL:-your@email.com}"

claude --print "$TASK"
EXIT_CODE=$?

STATUS="completed"
[ $EXIT_CODE -ne 0 ] && STATUS="FAILED"

Send email via sendmail (if available)
echo "Subject: Claude Code task $STATUS
Your Claude Code task has $STATUS.

Task: $TASK
Exit code: $EXIT_CODE
Time: $(date)" | sendmail "$EMAIL" 2>/dev/null

Or use curl with a webhook (e.g., ntfy.sh)
curl -s -d "$TASK $STATUS" "https://ntfy.sh/your-topic-name" 2>/dev/null

exit $EXIT_CODE
```

The `ntfy.sh` approach works for mobile notifications, subscribe to your topic in the ntfy app and receive push notifications on your phone when server-side Claude Code tasks finish.

## Automating Notifications for Repeated Tasks

For recurring workflows, create shell functions in your profile:

```bash
claude_notify() {
 claude --print "$1"
 EXIT=$?
 if [ $EXIT -eq 0 ]; then
 terminal-notifier -title "Claude Code" -message "Completed: $1"
 else
 terminal-notifier -title "Claude Code" -message "Failed: $1 (exit $EXIT)"
 fi
 return $EXIT
}
```

Usage becomes straightforward:

```bash
claude_notify "Analyze code coverage for all services"
```

For teams with multiple Claude Code users, a shared notification configuration keeps everyone consistent:

```bash
/etc/profile.d/claude-notify.sh or ~/.claude-notify-config.sh
Source this in your .bashrc or .zshrc

CLAUDE_NOTIFY_TITLE="${CLAUDE_NOTIFY_TITLE:-Claude Code}"
CLAUDE_NOTIFY_SOUND="${CLAUDE_NOTIFY_SOUND:-default}"
CLAUDE_NOTIFY_LOG="${CLAUDE_NOTIFY_LOG:-$HOME/.claude-task-log}"

claude_run() {
 local task="$1"
 local start=$(date +%s)

 claude --print "$task"
 local exit_code=$?
 local duration=$(( $(date +%s) - start ))

 # Log to shared file
 echo "$(date '+%Y-%m-%d %H:%M:%S') | $USER | ${duration}s | exit:$exit_code | $task" \
 >> "$CLAUDE_NOTIFY_LOG"

 # Notify
 if [ $exit_code -eq 0 ]; then
 terminal-notifier \
 -title "$CLAUDE_NOTIFY_TITLE" \
 -message "Done in ${duration}s: $task" \
 -sound "$CLAUDE_NOTIFY_SOUND"
 else
 terminal-notifier \
 -title "$CLAUDE_NOTIFY_TITLE: FAILED" \
 -message "Failed after ${duration}s: $task" \
 -sound Basso
 fi

 return $exit_code
}
```

The shared log gives engineering managers visibility into how the team uses Claude Code and which task types take the longest, useful data for capacity planning and workflow optimization.

## Final Thoughts

Setting up notifications for long-running Claude Code tasks transforms your development experience. Rather than watching terminal output, you receive alerts when work completes, whether you're reviewing code, generating documentation, or running comprehensive tests.

The right notification setup depends on your workflow: simple `&&` chains work for occasional use, shell functions serve regular users, and full logging wrappers benefit teams that want visibility into AI tool usage patterns.

Start with simple notifications using the scripts above, then customize based on your workflow. The investment of a few minutes pays dividends in focused, efficient development sessions. Once the habit forms, you'll find yourself queuing multiple Claude Code tasks in sequence and working on other priorities while the AI does the heavy lifting, checking your screen only when the notification arrives.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-notification-setup-for-long-tasks)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Agent Handoff Strategies for Long Running Tasks Guide](/agent-handoff-strategies-for-long-running-tasks-guide/)
- [Claude Code Inngest Durable Workflow for Long Running Tasks](/claude-code-inngest-durable-workflow-long-running-tasks/)
- [Claude Code Upstash QStash Scheduled Tasks Setup Guide](/claude-code-upstash-qstash-scheduled-tasks-setup-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## See Also

- [Claude Code EPIPE Broken Pipe Error — Fix (2026)](/claude-code-epipe-broken-pipe-long-operations-fix/)
- [SIGTERM During Long Operation Fix](/claude-code-sigterm-during-long-operation-fix-2026/)
