---
title: "Timezone Affecting Log Timestamps Fix"
permalink: /claude-code-timezone-affecting-log-timestamps-fix-2026/
description: "Fix timezone affecting log timestamps in Claude Code. Set TZ environment variable to UTC or your local timezone to get correct timestamps in output."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Warning: Log timestamps appear incorrect
  Claude Code session log: 2026-04-22T00:00:00Z (UTC)
  Expected local time: 2026-04-22T10:00:00-07:00 (PDT)
  Test assertions failing: expected "10:00 AM" but got "5:00 PM"
  Docker container timezone: UTC (does not match host timezone)
```

This appears when Claude Code or tools it runs produce timestamps in the wrong timezone, causing confusion in logs or failures in time-dependent tests.

## The Fix

```bash
export TZ="America/Los_Angeles"
claude
```

1. Set the TZ environment variable to your local timezone.
2. Verify it is correct: `date` should now show your local time.
3. Add the export to your shell profile for persistence.

## Why This Happens

Docker containers, CI runners, and remote servers default to UTC (Coordinated Universal Time). When Claude Code runs commands that generate timestamps (log files, test output, git commits), they use the system timezone. If you are in Pacific time but the environment is UTC, all timestamps are 7-8 hours ahead. Time-dependent test assertions fail because they expect local time values but get UTC.

## If That Doesn't Work

For Docker containers, set timezone at build time:

```dockerfile
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
```

For individual commands, prefix with TZ:

```bash
TZ="America/New_York" node test-runner.js
```

Install timezone data if missing (Alpine Linux):

```bash
apk add tzdata
cp /usr/share/zoneinfo/America/New_York /etc/localtime
```

Use UTC consistently and convert on display:

```bash
# In CLAUDE.md: All timestamps should use UTC (ISO 8601 format).
# Convert to local time only for display.
```

## Prevention

```markdown
# CLAUDE.md rule
Set TZ environment variable in all environments (local, Docker, CI). Use UTC for stored timestamps and logs. Set TZ=America/Los_Angeles (or your timezone) in shell profile and Dockerfiles for correct local time display.
```
