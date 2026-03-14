---
layout: default
title: "Claude Skills for Enterprise Security & Compliance Guide"
description: "Deploy Claude Code skills in enterprise environments with security controls, audit logging, access management, and compliance requirements."
date: 2026-03-13
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, claude-skills, enterprise, security, compliance]
reviewed: true
score: 8
---

# Claude Skills for Enterprise Security and Compliance Guide

Deploying Claude Code in an enterprise environment means dealing with requirements that don't exist in personal or small-team use: access control, audit trails, data residency, secret management, and compliance frameworks. This guide covers how to configure Claude skills to meet these requirements without gutting their utility.

## The Enterprise Security Stack for Claude Code

A production enterprise deployment of Claude Code typically involves five layers of control:

1. **Identity and access**: Who can run Claude Code, and which skills can they invoke
2. **Secret management**: Ensuring API keys and credentials are handled safely
3. **Audit logging**: Complete, tamper-evident records of what Claude did
4. **Data boundary enforcement**: Preventing sensitive data from leaving approved systems
5. **Change management**: Tracking skill modifications and their approval status

## Identity and Access Control

### Team-Based Skill Access

Use `pre-skill` hooks to enforce skill access policies based on user identity:

```python
#!/usr/bin/env python3
# .claude/hooks/enterprise-acl.py
import sys, json, subprocess, os

data = json.load(sys.stdin)
skill_name = data.get("skill_name", "")

# Get git identity
try:
    git_email = subprocess.check_output(
        ["git", "config", "user.email"],
        stderr=subprocess.DEVNULL
    ).decode().strip()
except:
    git_email = os.environ.get("CLAUDE_USER_EMAIL", "unknown")

# Load access control list
import yaml  # pip install pyyaml
with open(".claude/enterprise/acl.yaml") as f:
    acl = yaml.safe_load(f)

skill_config = acl.get("skills", {}).get(skill_name, {})
allowed_users = skill_config.get("allowed_users", [])
allowed_teams = skill_config.get("allowed_teams", [])
requires_approval = skill_config.get("requires_approval", False)

# Check email-based access
if allowed_users and git_email not in allowed_users:
    # Check team membership
    user_teams = acl.get("users", {}).get(git_email, {}).get("teams", [])
    if not any(team in allowed_teams for team in user_teams):
        print(f"ACCESS DENIED: {git_email} does not have permission to invoke {skill_name}", file=sys.stderr)
        sys.exit(1)

print(json.dumps(data))
sys.exit(0)
```

The access control list (`acl.yaml`):

```yaml
skills:
  pdf:
    allowed_teams: [engineers, data-team]
    requires_approval: false
  docx:
    allowed_users: [alice@company.com, bob@company.com]
    requires_approval: true
  tdd:
    allowed_teams: [engineers]
    requires_approval: false
  frontend-design:
    allowed_teams: [engineers, design-engineering]
    requires_approval: false

users:
  alice@company.com:
    teams: [engineers, leads]
  bob@company.com:
    teams: [engineers, data-team]
  carol@company.com:
    teams: [design-engineering]
```

### LDAP/Active Directory Integration

For larger teams, replace the static YAML with LDAP/AD lookups:

```python
import ldap3

def get_user_groups(email):
    server = ldap3.Server("ldap.company.com", use_ssl=True)
    conn = ldap3.Connection(
        server,
        user=os.environ["LDAP_SERVICE_ACCOUNT"],
        password=os.environ["LDAP_SERVICE_PASSWORD"],
        auto_bind=True
    )
    conn.search(
        "dc=company,dc=com",
        f"(mail={email})",
        attributes=["memberOf"]
    )
    if conn.entries:
        return [str(g).split(",")[0].replace("CN=", "") for g in conn.entries[0].memberOf]
    return []
```

## Secret Management

### Never Let Claude See Secrets Directly

The biggest risk in AI coding tools: accidentally giving Claude access to production credentials. Skills like the [**tdd** skill](/claude-skills-guide/best-claude-skills-for-developers-2026/) need access to run tests, while the [`pdf` skill](/claude-skills-guide/best-claude-skills-for-data-analysis/) reads documents — scope each appropriately. Claude might log them, include them in generated code, or surface them in responses.

**Rule**: Secrets should be in environment variables or a secrets manager, never in files that a skill's instructions might reference.

If a skill body tells Claude to read specific files, ensure those files contain only code structure — not secret values. For example:

```
# BAD skill instruction — could expose secrets
Read .env to understand the environment configuration.

# GOOD skill instruction — references code only
Read src/config/database.ts to understand the database configuration schema.
```

Note: `context_files` is not a valid skill front matter field. Use prose instructions in the skill body to specify which files Claude should read.

### Vault Integration for Skill Tool Calls

If a skill needs to authenticate to an external service, use a vault-backed credential provider via a pre-tool hook:

```python
#!/usr/bin/env python3
# .claude/hooks/vault-credentials.py
import sys, json, subprocess

data = json.load(sys.stdin)

# For bash commands that need AWS credentials, inject short-lived credentials
if data["tool_name"] == "bash":
    cmd = data["tool_input"].get("command", "")
    if "aws" in cmd:
        # Get short-lived credentials from Vault
        creds = json.loads(subprocess.check_output([
            "vault", "read", "-format=json", "aws/creds/claude-code-role"
        ]).decode())["data"]
        
        # Inject as env vars into the command
        data["tool_input"]["command"] = (
            f"AWS_ACCESS_KEY_ID={creds['access_key']} "
            f"AWS_SECRET_ACCESS_KEY={creds['secret_key']} "
            f"AWS_SESSION_TOKEN={creds['security_token']} "
            f"{cmd}"
        )

print(json.dumps(data))
sys.exit(0)
```

## Audit Logging for Compliance

### SIEM-Compatible Audit Logs

Compliance frameworks like SOC 2 and ISO 27001 require structured, tamper-evident logs. Use post-tool hooks to write to a SIEM-compatible format:

```python
#!/usr/bin/env python3
# .claude/hooks/siem-audit.py
import sys, json, datetime, os, hashlib, hmac

data = json.load(sys.stdin)
log_key = os.environ.get("AUDIT_LOG_HMAC_KEY", "").encode()

log_entry = {
    "event_type": "claude_tool_call",
    "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
    "source": "claude-code",
    "severity": "INFO",
    "actor": {
        "user": os.environ.get("GIT_AUTHOR_EMAIL", "unknown"),
        "hostname": os.uname().nodename,
        "pid": os.getpid()
    },
    "action": {
        "tool": data.get("tool_name"),
        "skill": data.get("skill"),
        "session_id": data.get("session_id"),
        "project": data.get("project_root", "").split("/")[-1]
    },
    "details": {
        "input_summary": str(data.get("tool_input", {}))[:500],  # Truncate sensitive data
        "duration_ms": data.get("duration_ms"),
        "success": data.get("tool_error") is None
    }
}

# Add HMAC signature for tamper detection
if log_key:
    content = json.dumps(log_entry, sort_keys=True).encode()
    log_entry["_signature"] = hmac.new(log_key, content, hashlib.sha256).hexdigest()

# Write to audit log file (or pipe to syslog/Splunk/Datadog)
audit_log_path = os.environ.get("CLAUDE_AUDIT_LOG", "/var/log/claude-code/audit.jsonl")
os.makedirs(os.path.dirname(audit_log_path), exist_ok=True)
with open(audit_log_path, "a") as f:
    f.write(json.dumps(log_entry) + "\n")

sys.exit(0)
```

### Tracking Skill Invocations for Access Reviews

For periodic access reviews, track which users invoked which skills:

```python
# In the pre-skill hook, maintain a usage log
usage_entry = {
    "timestamp": datetime.datetime.utcnow().isoformat(),
    "user": git_email,
    "skill": skill_name,
    "project": os.path.basename(project_root)
}

usage_log = "/var/log/claude-code/skill-usage.jsonl"
with open(usage_log, "a") as f:
    f.write(json.dumps(usage_entry) + "\n")
```

Run quarterly access reviews by analyzing this log to verify users still need the skills they're invoking.

## Data Boundary Enforcement

### Blocking PII Exfiltration

Use pre-tool hooks to scan for PII in web_fetch and web_search calls:

```python
import re

PII_PATTERNS = [
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',  # email
    r'\b\d{3}-\d{2}-\d{4}\b',  # SSN
    r'\b4[0-9]{12}(?:[0-9]{3})?\b',  # Visa card numbers
]

if data["tool_name"] in ["web_fetch", "web_search"]:
    url_or_query = str(data.get("tool_input", {}))
    for pattern in PII_PATTERNS:
        if re.search(pattern, url_or_query):
            print(f"BLOCKED: Potential PII in outbound request", file=sys.stderr)
            sys.exit(1)
```

### Restricting Write Access to Non-Production Paths

For environments where Claude Code might have access to production config:

```python
PROTECTED_PATHS = [
    "/etc/",
    "/etc/nginx/",
    "k8s/production/",
    "terraform/prod/",
    ".github/workflows/deploy-prod"
]

if data["tool_name"] == "write_file":
    path = data["tool_input"].get("path", "")
    for protected in PROTECTED_PATHS:
        if path.startswith(protected) or protected in path:
            print(f"BLOCKED: write to protected path {path} requires manual review", file=sys.stderr)
            sys.exit(1)
```

## Skill Version Control and Change Management

In enterprise deployments, skill changes should go through the same review process as code changes.

Store all skills in a `skills/` directory tracked in your git repository:

```
.claude/
  skills/
    tdd.md
    frontend-design.md
    pdf.md
    docx.md
  enterprise/
    acl.yaml
    hooks/
      enterprise-acl.py
      siem-audit.py
      vault-credentials.py
```

Require PR approval for any change to `.claude/skills/` or `.claude/enterprise/` — add a CODEOWNERS rule:

```
# .github/CODEOWNERS
/.claude/enterprise/  @security-team
/.claude/skills/      @engineering-leads
```

This ensures no single developer can quietly modify skill behavior or security hooks without review.

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/) — Understanding which skills are most powerful helps security teams prioritize which ones need the strictest enterprise controls
- [Skill .md File Format Explained With Examples](/claude-skills-guide/skill-md-file-format-explained-with-examples/) — The `tools` field and YAML structure are the first things to audit when reviewing skills for enterprise compliance
- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-guide/claude-skills-token-optimization-reduce-api-costs/) — Enterprise deployments at scale need both security controls and cost management; these techniques address the latter

Built by theluckystrike — More at [zovo.one](https://zovo.one)
