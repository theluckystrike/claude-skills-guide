---
layout: default
title: "Claude Code Notification Setup for Long Tasks"
description: "Learn how to configure notifications in Claude Code to stay informed during long-running operations. Practical examples and code snippets for developers."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-notification-setup-for-long-tasks/
---

{% raw %}
Long-running tasks are a common challenge when working with AI-assisted development. Whether you're refactoring a large codebase, generating documentation across multiple files, or running extensive test suites, knowing when your task completes—without constantly monitoring the terminal—improves your workflow significantly.

This guide covers how to set up notification systems for Claude Code to alert you when long tasks finish, using native macOS and Linux tools plus practical integration patterns.

## Understanding Claude Code Task Notifications

Claude Code runs in your terminal, which means standard terminal output keeps you informed while the process runs. However, for tasks that take minutes or longer, you need external notification mechanisms to avoid wasting time checking the terminal.

The key is combining Claude Code with system-level notification tools that can trigger alerts based on exit codes, output patterns, or elapsed time.

## Setting Up macOS Notifications with Terminal Notifiers

macOS users have several options for sending notifications. The `terminal-notifier` gem provides a reliable way to send alerts from command-line scripts:

```bash
# Install terminal-notifier
gem install terminal-notifier

# Send a notification when a task completes
terminal-notifier -title "Claude Code" -message "Task completed successfully"
```

For Claude Code workflows, wrap your commands with notification triggers:

```bash
# Run a long task and notify on completion
claude --print "Analyze the entire codebase for security issues" && \
  terminal-notifier -title "Claude Code" -message "Security analysis complete"
```

The `&&` ensures the notification only fires on successful completion. Use `||` if you want notifications for failures instead.

## Linux Desktop Notifications

Linux users can use `notify-send` from the `libnotify` package:

```bash
# Install on Debian/Ubuntu
sudo apt install libnotify-bin

# Send notification
notify-send "Claude Code" "Long-running task finished"
```

Combine this with Claude Code in your shell:

```bash
claude --print "Generate documentation for all modules" ; \
  notify-send "Claude Code" "Documentation generation complete"
```

Unlike the `&&` operator, `;` runs the notification regardless of the previous command's exit status—useful when you want alerts for both successes and failures.

## Practical Example: Notification Scripts

Create reusable notification scripts for common scenarios. This pattern works across macOS and Linux:

```bash
#!/bin/bash
# notify-complete.sh

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

# Usage with Claude Code
claude --print "Run full test suite" && \
  ~/scripts/notify-complete.sh "Test suite finished" "CI Update"
```

## Advanced: Notification Based on Task Output

For more sophisticated scenarios, parse Claude Code output and send different notifications based on results:

```bash
#!/bin/bash
# notify-result.sh

OUTPUT=$(claude --print "$1")
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  STATUS="Success"
else
  STATUS="Failed with exit code $EXIT_CODE"
fi

# Extract summary from output (adjust grep pattern for your needs)
SUMMARY=$(echo "$OUTPUT" | tail -5 | head -3)

if [[ "$(uname)" == "Darwin" ]]; then
  terminal-notifier -title "Claude Code: $STATUS" -message "$SUMMARY"
else
  notify-send "Claude Code: $STATUS" "$SUMMARY"
fi
```

## Integration with Claude Skills

Several Claude skills enhance notification workflows for specific tasks:

- **pdf skill**: Generate reports and get notified when batch PDF processing completes
- **tdd skill**: Run test-driven development cycles and receive alerts when test suites pass or fail
- **frontend-design skill**: Generate multiple design iterations and get notified when all renders are complete
- **supermemory skill**: Process large knowledge bases and receive notification when indexing finishes

Each skill can be wrapped with notification scripts to keep you informed without terminal monitoring.

## Using Aliases for Quick Notification Access

Add shell aliases to your `.bashrc` or `.zshrc` for faster usage:

```bash
# Quick notify aliases
alias cn='terminal-notifier -title "Claude Code"'
alias cn_success='terminal-notifier -title "Claude Code" -message "Task succeeded"'
alias cn_fail='terminal-notifier -title "Claude Code" -message "Task failed"'
```

Then use them directly:

```bash
claude --print "Migrate database schema" && cn_success || cn_fail
```

## Notification Sounds and Critical Alerts

For important tasks, enable sound alerts alongside visual notifications:

```bash
# macOS with sound
terminal-notifier -title "Claude Code" -message "Deployment complete" -sound default

# Linux with sound
notify-send -u critical "Claude Code" "Deployment complete"
```

The `-u critical` flag on Linux raises the notification priority, ensuring it appears even when Do Not Disturb is enabled.

## Troubleshooting Notification Issues

If notifications aren't appearing, check these common issues:

1. **Permission problems**: macOS requires notification permissions. Go to System Preferences > Notifications > Terminal and enable alerts.

2. **PATH issues**: Ensure notification tools are in your PATH. Use full paths if needed: `/usr/local/bin/terminal-notifier`

3. **Background process limitations**: Notifications from background jobs may not display. Use `wait` or foreground the notification call.

4. **Display server issues**: On Linux, ensure DBus is running for libnotify to communicate with notification daemons.

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

## Final Thoughts

Setting up notifications for long-running Claude Code tasks transforms your development experience. Rather than watching terminal output, you receive alerts when work completes—whether you're reviewing code, generating documentation, or running comprehensive tests.

Start with simple notifications using the scripts above, then customize based on your workflow. The investment of a few minutes pays dividends in focused, efficient development sessions.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
{% endraw %}
