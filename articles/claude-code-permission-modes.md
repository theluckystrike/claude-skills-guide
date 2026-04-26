---
layout: default
title: "Claude Code Permission Modes Explained (2026)"
last_tested: "2026-04-22"
description: "Understand and configure Claude Code permission modes — default, allowEdits, bypassPermissions. Includes settings.json examples and hook-based automation."
date: 2026-04-14
last_modified_at: 2026-04-17
author: "Claude Code Guides"
permalink: /claude-code-permission-modes/
reviewed: true
categories: [Permissions & Security]
tags: ["claude-code", "permissions", "security", "configuration"]
geo_optimized: true
---

# Claude Code Permission Modes Explained

> **TL;DR:** Claude Code has three permission modes — default (prompts for everything), `allowEdits` (auto-approves file edits, prompts for commands), and `bypassPermissions` (auto-approves everything). Configure via CLI flag, settings.json, or PreToolUse hooks.

## The Problem

Claude Code keeps asking for permission on every tool call, slowing down your workflow:

```
Permission rule Bash requires confirmation for this command:
 cat package.json

 Allow? [y/n]
```

Or conversely, you want to restrict Claude Code from running certain commands but the permission system does not seem configurable enough.

## Why This Happens

Claude Code defaults to the safest permission mode — prompting for confirmation on every impactful tool call (file writes, shell commands, etc.). This is intentional for security, but becomes friction for experienced users who want more autonomy.

## The Fix

### Step 1 — Choose Your Permission Mode

| Mode | File Edits | Shell Commands | Use Case |
|------|-----------|----------------|----------|
| `default` | Prompt | Prompt | New users, shared machines |
| `allowEdits` | Auto-allow | Prompt | Trusted projects, edit-heavy workflows |
| `bypassPermissions` | Auto-allow | Auto-allow | CI/CD, sandboxed environments, power users |

### Step 2 — Configure via CLI Flag

```bash
# Allow file edits without prompts
claude --permission-mode allowEdits

# Bypass all permissions (use with caution)
claude --dangerously-skip-permissions
```

### Step 3 — Configure via Settings File

For persistent configuration, edit `~/.claude/settings.json`:

```json
{
 "defaultMode": "bypassPermissions",
 "skipDangerousModePermissionPrompt": true,
 "permissions": {
 "allow": [
 "Bash(npm test)",
 "Bash(npm run *)",
 "Bash(git *)",
 "Read(*)",
 "Write(src/*)"
 ],
 "deny": [
 "Bash(rm -rf *)",
 "Bash(sudo *)"
 ]
 }
}
```

### Step 4 — Fine-Grained Control with PreToolUse Hooks

For the most control, use a PreToolUse hook that programmatically decides permissions:

```json
{
 "hooks": {
 "PreToolUse": [
 {
 "matcher": "Bash",
 "hooks": [
 {
 "type": "command",
 "command": "/path/to/permission-hook.sh",
 "timeout": 30
 }
 ]
 }
 ]
 }
}
```

**permission-hook.sh:**

```bash
#!/bin/bash
# Read the tool input from stdin
INPUT=$(cat)

# Extract the command being run
COMMAND=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('input',{}).get('command',''))" 2>/dev/null)

# Allow safe commands, deny dangerous ones
case "$COMMAND" in
 rm\ -rf*|sudo*|chmod\ 777*)
 echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","reason":"Blocked by safety hook"}}'
 ;;
 *)
 echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
 ;;
esac
```

```bash
chmod +x /path/to/permission-hook.sh
```

### Step 5 — Verify Your Configuration

```bash
# Start Claude Code and check the active mode
claude --permission-mode allowEdits

# In the session, run a test command
> Read the file package.json
# Should auto-approve without prompting

> Run: echo "hello world"
# In allowEdits mode, this should still prompt
```

## Common Variations

| Scenario | Cause | Quick Fix |
|----------|-------|-----------|
| Permissions reset after background task | Known bug (issue #47810) | Use hook-based permissions as workaround |
| `bypassPermissions` still prompts | Settings not loaded | Check file path, restart Claude Code |
| Hook not being called | Wrong matcher pattern | Use `"matcher": ".*"` to match all tools |
| Want to allow `git` but deny `rm` | Need fine-grained rules | Use `permissions.allow` and `permissions.deny` arrays |
| Sandbox mode overrides settings | Sandbox has its own rules | Set `sandbox.autoAllowBashIfSandboxed: true` |

## Prevention

- **Start with `allowEdits`:** It is a good balance between safety and productivity for most developers.
- **Use project-level settings:** Put permissive settings in project `.claude/settings.json` rather than global settings to limit scope.
- **Review hook logs:** If using PreToolUse hooks, log every decision for auditability.

---


<div class="author-bio">

**Written by Michael** — solo dev, Da Nang, Vietnam. 50K+ Chrome extension users. $500K+ on Upwork (100% Job Success). Runs 5 Claude Max subs in parallel. Built this site with autonomous agent fleets. [See what I'm building →](https://zovo.one)

</div>

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-permission-modes)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

## Related Issues

- [Claude Code API Security OWASP Guide](/claude-code-api-security-owasp-guide/) — When permissions are ignored
- [Claude Code PreToolUse Hooks Bypassed Fix](/claude-code-pretooluse-hooks-bypassed/) — Preventing dangerous operations
- [Claude Code Permission Modes Explained](/claude-code-permission-modes/) — Browse all permissions guides

---

*Last verified: 2026-04-14. Found an issue? [Open a GitHub issue](https://github.com/theluckystrike/extension-insiders/issues).*



- [dangerously skip permissions guide](/claude-code-dangerously-skip-permissions-guide/) — Complete guide to --dangerously-skip-permissions and safer alternatives
- [--dangerously-skip-permissions flag](/claude-dangerously-skip-permissions-flag/) — Understanding the --dangerously-skip-permissions CLI flag
## Related Articles

- [Why Claude Code Keeps Asking Permission (2026)](/why-does-claude-code-keep-asking-for-permission-repeatedly/)
- [Claude Code Permission Rules in settings.json](/claude-code-permission-rules-settings-json-guide/)
- [Claude Code Permission Modes: How They Affect Token Usage](/claude-code-permission-modes-affect-token-usage/)


## Common Questions

### How do I get started with claude code permission modes?

Begin with the setup instructions in this guide. Install the required dependencies, configure your environment, and test with a small project before scaling to your full codebase.

### What are the prerequisites?

You need a working development environment with Node.js or Python installed. Familiarity with the command line and basic Git operations is helpful. No advanced AI knowledge is required.

### Can I use this with my existing development workflow?

Yes. These techniques integrate with standard development tools and CI/CD pipelines. Start by adding them to a single project and expand once you have verified the benefits.

### Where can I find more advanced techniques?

Explore the related resources below for deeper coverage. The Claude Code documentation and community forums also provide advanced patterns and real-world case studies.

## Related Resources

- [Claude Code Permission Modes](/claude-code-permission-modes-affect-token-usage/)
- [Claude Code Config Hierarchy Explained](/claude-code-configuration-hierarchy-explained-2026/)
- [Claude Code Docker Permission Denied](/claude-code-docker-permission-denied-bind-mount-error/)
