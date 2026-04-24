---
layout: post
title: "Claude Code Security Best Practices"
description: "Secure Claude Code for enterprise use: permission controls, secrets management, allowedTools and disallowedTools config, and audit logging setup."
permalink: /claude-code-security-best-practices-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Workflow

Lock down Claude Code for enterprise and team environments by configuring tool permissions, preventing secret exposure, enabling audit logs, and restricting file system access. This guide covers the security controls available in Claude Code and how to enforce them organization-wide.

Expected time: 30-45 minutes for full security configuration
Prerequisites: Claude Code installed, admin access to repository, understanding of your team's security requirements

## Setup

### 1. Create Permission Configuration

```bash
mkdir -p .claude && cat > .claude/settings.json << 'EOF'
{
  "permissions": {
    "allowedTools": [
      "Read",
      "Glob",
      "Grep",
      "Edit",
      "Write",
      "Bash(npm test*)",
      "Bash(npm run*)",
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(git log*)",
      "Bash(ls*)",
      "Bash(cat*)"
    ],
    "disallowedTools": [
      "Bash(curl*)",
      "Bash(wget*)",
      "Bash(ssh*)",
      "Bash(scp*)",
      "Bash(rm -rf*)",
      "Bash(git push --force*)",
      "Bash(git reset --hard*)",
      "Bash(docker*)",
      "Bash(kubectl*)",
      "Bash(aws*)",
      "Bash(gcloud*)",
      "Bash(az *)",
      "Bash(sudo*)",
      "Bash(chmod 777*)",
      "Bash(env)",
      "Bash(printenv*)",
      "Bash(export*)"
    ]
  }
}
EOF
```

This configuration uses an allowlist approach: only explicitly permitted tools can execute.

### 2. Create a .claudeignore File

```bash
cat > .claudeignore << 'EOF'
# Secrets and credentials
.env
.env.*
*.pem
*.key
*.p12
*.pfx
credentials.json
service-account*.json
**/secrets/**
**/.secrets/**

# Infrastructure
terraform.tfstate
terraform.tfstate.backup
*.tfvars

# CI/CD secrets
.github/secrets/
.gitlab-ci-secrets/

# Database
*.sql.gz
**/dumps/**
**/backups/**

# IDE and personal config
.claude/personal/
EOF
```

Files matching these patterns will not be readable by Claude Code.

### 3. Verify Restrictions Work

```bash
# This should be blocked:
claude --print "Run: printenv | grep KEY"
# Expected: tool use denied

# This should work:
claude --print "Run: npm test"
# Expected: executes normally
```

## Usage Example

A complete enterprise security setup including audit logging:

```bash
# Create audit hook that logs all Claude Code tool invocations
cat > .claude/hooks/audit-log.sh << 'SCRIPT'
#!/bin/bash
# Audit log hook for Claude Code
# Logs every tool invocation to a centralized log

LOG_DIR="${HOME}/.claude/audit-logs"
mkdir -p "$LOG_DIR"

LOG_FILE="${LOG_DIR}/$(date +%Y-%m-%d).jsonl"

# Received via environment variables from Claude Code hooks system
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
USER=$(whoami)
PROJECT=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")

cat >> "$LOG_FILE" << ENTRY
{"timestamp":"${TIMESTAMP}","user":"${USER}","project":"${PROJECT}","tool":"${CLAUDE_TOOL_NAME}","command":"${CLAUDE_TOOL_INPUT}","cwd":"$(pwd)"}
ENTRY
SCRIPT
chmod +x .claude/hooks/audit-log.sh
```

Configure hooks in settings:

```json
{
  "hooks": {
    "preToolUse": [
      {
        "matcher": "Bash",
        "hook": ".claude/hooks/audit-log.sh"
      }
    ]
  },
  "permissions": {
    "allowedTools": [
      "Read",
      "Glob",
      "Grep",
      "Edit",
      "Write",
      "Bash(npm test*)",
      "Bash(npm run lint*)",
      "Bash(git status)",
      "Bash(git diff*)"
    ],
    "disallowedTools": [
      "Bash(curl*)",
      "Bash(wget*)",
      "Bash(rm -rf*)",
      "Bash(sudo*)",
      "Bash(env)",
      "Bash(printenv*)"
    ]
  }
}
```

Add secret scanning to CLAUDE.md:

```markdown
# Security Rules

## NEVER DO
- Never print, log, or output environment variables
- Never read .env files or files matching *.key, *.pem
- Never include API keys, tokens, or passwords in code output
- Never execute commands that access cloud provider credentials
- Never bypass .claudeignore restrictions
- Never run network commands (curl, wget, ssh, nc)

## ALWAYS DO
- Use placeholder values for secrets: process.env.DATABASE_URL
- Reference secrets by name, never by value
- Use .env.example for documenting required variables
- Validate that no secrets appear in generated code before writing files
```

Enforce organization-wide with managed settings (macOS MDM example):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>permissions</key>
    <dict>
        <key>disallowedTools</key>
        <array>
            <string>Bash(curl*)</string>
            <string>Bash(wget*)</string>
            <string>Bash(ssh*)</string>
            <string>Bash(docker push*)</string>
            <string>Bash(kubectl apply*)</string>
            <string>Bash(sudo*)</string>
            <string>Bash(env)</string>
            <string>Bash(printenv*)</string>
        </array>
    </dict>
</dict>
</plist>
```

Deploy to all developer machines:

```bash
# Copy to managed settings location (macOS)
sudo cp claude-code-security.plist \
  "/Library/Application Support/ClaudeCode/settings.plist"

# Verify it is loaded (developer machine)
claude --print "What tools are restricted?"
```

## Common Issues

- **Tool blocked but developer needs it for a task:** Add specific narrow patterns to allowedTools. `Bash(docker build*)` is safer than `Bash(docker*)` because it prevents `docker push` and `docker exec`.
- **Secrets still appear in Claude output:** Add explicit rules to CLAUDE.md. Claude respects written instructions about secret handling. Also verify .claudeignore covers all sensitive file patterns.
- **Managed settings not loading:** On macOS, check path is exactly `/Library/Application Support/ClaudeCode/`. On Linux, check `/etc/claude-code/`. Restart Claude Code after changes.

## Why This Matters

One leaked API key costs an average of $28,000 in incident response. Proper Claude Code security configuration prevents credential exposure and unauthorized system access across your entire engineering organization.

## Related Guides

- [CLAUDE.md Security Rules](/claude-md-security-rules/)
- [Understanding Claude Code Hooks System Complete Guide](/understanding-claude-code-hooks-system-complete-guide/)
- [How Do I Limit What a Claude Skill Can Access on Disk](/how-do-i-limit-what-a-claude-skill-can-access-on-disk/)

- [dangerously skip permissions guide](/claude-code-dangerously-skip-permissions-guide/) — Complete guide to [--dangerously-skip-permissions flag](/claude-dangerously-skip-permissions-flag/) and safer alternatives

