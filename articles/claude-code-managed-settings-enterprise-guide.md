---
layout: default
title: "Claude Code Managed Settings Enterprise Guide"
description: "Deploy organization-wide Claude Code settings with managed policies for permissions, hooks, MCP servers, and security controls."
date: 2026-04-15
permalink: /claude-code-managed-settings-enterprise-guide/
categories: [guides, claude-code]
tags: [enterprise, managed-settings, security, MDM, organization]
---

# Claude Code Managed Settings Enterprise Guide

## The Problem

You need to enforce consistent Claude Code policies across your organization: standardized permissions, approved MCP servers, mandatory hooks, and security controls that individual developers cannot override.

## Quick Fix

Create a managed settings file at the appropriate system location:

macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`
Linux: `/etc/claude-code/managed-settings.json`
Windows: `C:\Program Files\ClaudeCode\managed-settings.json`

```json
{
  "permissions": {
    "deny": [
      "Bash(curl *)",
      "Bash(wget *)",
      "Read(./.env)",
      "Read(./secrets/**)"
    ]
  }
}
```

## What's Happening

Claude Code uses a scope system where managed settings have the highest priority. They cannot be overridden by user, project, or local settings. This makes them ideal for enforcing organization-wide security policies.

Managed settings can be delivered through three mechanisms: server-managed settings from Anthropic's admin console, MDM/OS-level policies (macOS configuration profiles, Windows Group Policy), and file-based deployment to system directories. All use the same JSON format.

## Step-by-Step Fix

### Step 1: Choose a delivery mechanism

| Mechanism | Platform | Best for |
|-----------|----------|----------|
| Server-managed | All | Cloud-managed orgs using Claude.ai admin console |
| MDM policies | macOS/Windows | Existing device management infrastructure |
| File-based | All | Direct deployment via config management |

### Step 2: Create the managed settings file

Start with a baseline security policy:

```json
{
  "permissions": {
    "deny": [
      "Bash(curl *)",
      "Bash(wget *)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ]
  },
  "disableAutoMode": "disable",
  "forceLoginMethod": "console",
  "companyAnnouncements": [
    "Review security guidelines at docs.company.com/security"
  ]
}
```

### Step 3: Restrict MCP servers

Control which MCP servers developers can use:

```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverName": "jira" }
  ],
  "deniedMcpServers": [
    { "serverName": "filesystem" }
  ]
}
```

When `allowedMcpServers` is set, only listed servers can be configured. The deny list takes precedence over the allow list.

### Step 4: Enforce mandatory hooks

Deploy hooks that must run for all users:

```json
{
  "allowManagedHooksOnly": true,
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/usr/local/bin/claude-audit-command.sh"
          }
        ]
      }
    ]
  }
}
```

Setting `allowManagedHooksOnly` to `true` blocks user, project, and plugin hooks. Only managed hooks and SDK hooks run.

### Step 5: Restrict model selection

Limit which models developers can use:

```json
{
  "availableModels": ["sonnet", "haiku"]
}
```

This prevents developers from selecting Opus, which helps control costs.

### Step 6: Require specific organization login

Force authentication to a specific org:

```json
{
  "forceLoginOrgUUID": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

### Step 7: Deploy via MDM on macOS

Create a configuration profile for the `com.anthropic.claudecode` preferences domain. Deploy through Jamf, Kandji, or other MDM tools.

For file-based deployment, place the settings at:

```bash
sudo mkdir -p "/Library/Application Support/ClaudeCode"
sudo cp managed-settings.json "/Library/Application Support/ClaudeCode/"
```

### Step 8: Use drop-in directories for modular policies

For teams managing different policy aspects independently, use the drop-in directory:

```text
/Library/Application Support/ClaudeCode/
  managed-settings.json          # Base config
  managed-settings.d/
    10-security.json             # Security team policies
    20-compliance.json           # Compliance policies
    30-developer-tools.json      # Approved tools
```

Files are sorted alphabetically and deep-merged. Later files override scalar values; arrays are concatenated and deduplicated.

### Step 9: Block bypass permissions mode

Prevent developers from using unrestricted modes:

```json
{
  "permissions": {
    "disableBypassPermissionsMode": "disable"
  },
  "disableAutoMode": "disable"
}
```

## Prevention

Start with a minimal managed settings policy and expand as needed. Test policies with a small pilot group before organization-wide rollout. Use the drop-in directory approach to let different teams manage their policies independently without editing a single file.

Monitor compliance through the `PreToolUse` hook for audit logging, and use `companyAnnouncements` to communicate policy changes to developers at startup.

---

### Level Up Your Claude Code Workflow

The developers who get the most out of Claude Code aren't just fixing errors — they're running multi-agent pipelines, using battle-tested CLAUDE.md templates, and shipping with production-grade operating principles.

**[Claude Code Mastery →](https://claudecodeguides.com/mastery/?utm_source=ccg&utm_medium=article&utm_campaign=claude-code-managed-settings-enterprise-guide)**
Templates, configs, and orchestration playbooks used by a Top Rated Plus developer with $400K+ earned building with Claude Code.

$19/month · $149 lifetime · No fluff, no courses, just tools that ship.

---

## Related Guides

- [AI Coding Tools Security Concerns Enterprise Guide](/ai-coding-tools-security-concerns-enterprise-guide/)
- [AI Coding Tools Governance Policy for Enterprises](/ai-coding-tools-governance-policy-for-enterprises/)
- [Best Way to Integrate Claude Code into Team Workflow](/best-way-to-integrate-claude-code-into-team-workflow/)
- [Understanding Claude Code Hooks System Complete Guide](/understanding-claude-code-hooks-system-complete-guide/)
