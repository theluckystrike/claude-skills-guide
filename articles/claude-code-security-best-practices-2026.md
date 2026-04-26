---
layout: post
title: "Claude Code Security Best Practices (2026)"
description: "Secure Claude Code for enterprise use: permission controls, secrets management, allowedTools and disallowedTools config, and audit logging setup."
permalink: /claude-code-security-best-practices-2026/
date: 2026-04-21
last_tested: "2026-04-21"
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

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [CLAUDE.md Security Rules](/claude-md-security-rules/)
- [Understanding Claude Code Hooks System Complete Guide](/understanding-claude-code-hooks-system-complete-guide/)
- [How Do I Limit What a Claude Skill Can Access on Disk](/how-do-i-limit-what-a-claude-skill-can-access-on-disk/)

- [dangerously skip permissions guide](/claude-code-dangerously-skip-permissions-guide/) — Complete guide to [--dangerously-skip-permissions flag](/claude-dangerously-skip-permissions-flag/) and safer alternatives



## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>
