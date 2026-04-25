---
title: "Timezone Affecting Log Timestamps — Fix (2026)"
permalink: /claude-code-timezone-affecting-log-timestamps-fix-2026/
description: "Fix timezone affecting log timestamps in Claude Code. Set TZ environment variable to UTC or your local timezone to get correct timestamps in output."
last_tested: "2026-04-22"
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

## Related Error Messages

This fix also applies if you see these related error messages:

- `fatal: not a git repository`
- `error: failed to push some refs`
- `fatal: refusing to merge unrelated histories`
- `Error: Claude Code requires Node.js 18 or later`
- `SyntaxError: Unexpected token '??' — Node 14 detected`

## Frequently Asked Questions

### Why does Claude Code require git?

Claude Code uses git for several core operations: tracking file changes, creating commits, reading blame information, searching history with `git log`, and managing branches. Without git, these operations fail and Claude Code falls back to less efficient alternatives.

### Can Claude Code work in a non-git directory?

Yes, but with reduced functionality. File search and editing work normally, but version control operations (commit, diff, blame) are unavailable. Claude Code displays a warning when opened in a directory without git initialization.

### How do I prevent Claude Code from making unwanted git operations?

Add rules to your CLAUDE.md: `Do not create commits automatically. Do not run git push. Always ask before any git operation that modifies history.` Claude Code respects these constraints and asks for confirmation before proceeding.

### What Node.js version does Claude Code require?

Claude Code requires Node.js 18 or later. Node.js 20 LTS is recommended for the best compatibility and performance. Check your version with `node --version`.


## Related Guides

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions
