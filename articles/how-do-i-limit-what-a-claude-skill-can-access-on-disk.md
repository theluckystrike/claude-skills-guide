---
layout: default
title: "Limit Claude Skill Disk Access (2026)"
description: "Restrict Claude skill file system access with allowlists, directory scoping, and permission hooks. Prevent unauthorized reads and writes to your disk."
date: 2026-03-14
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, claude-skills, permissions, security, file-access]
reviewed: true
score: 9
permalink: /how-do-i-limit-what-a-claude-skill-can-access-on-disk/
render_with_liquid: false
geo_optimized: true
---

{% raw %}
[Claude Code skills extend the AI assistant's capabilities by loading custom instructions from Markdown files](/claude-skill-md-format-complete-specification-guide/) While these skills provide powerful automation for tasks like PDF processing with the pdf skill, spreadsheet automation with xlsx, or test-driven development with tdd, understanding how to control their file system access becomes essential when working with sensitive projects or shared environments.

Disk access control is not just a security nicety. it is a practical requirement for any team that shares codebases, runs automated pipelines, or works on projects that contain credentials, production configurations, or client data. Getting this wrong can mean a skill that helpfully "cleans up" your project directory ends up deleting a `.env` file, touching a migration script you were not ready to run, or reading a secrets vault your CI pipeline expected to stay private. This guide covers the full spectrum of control mechanisms available, from quick shell-level isolation to per-skill path allowlists.

## Understanding Claude Skill File Access

Claude skills operate within the context of your active project directory. When you invoke a skill like `/pdf merge these documents` or `/xlsx analyze this spreadsheet`, the skill executes within your current working directory and can read, write, and modify files based on your terminal's permissions. This default behavior provides flexibility but requires deliberate configuration for security-sensitive scenarios.

The file system access model for skills mirrors Claude Code's core permissions system. Skills inherit the access level of the Claude Code session itself, meaning they can interact with any files your user account can reach. This design choice prioritizes developer convenience but creates potential risks when running skills on unfamiliar repositories or production systems.

## What "Inheriting Session Permissions" Actually Means

When Claude Code launches, it runs as your current OS user. Every skill invoked during that session has the same read, write, and execute permissions your shell session has. If you are running as a user with access to `/etc/nginx/`, `/var/secrets/`, and `~/.ssh/`, a skill can in principle read those locations too. unless you add explicit controls.

This is different from how many containerized tools work. There is no automatic sandbox. The skill does not get a virtualized filesystem or a restricted user namespace unless you set one up deliberately. The practical implication: treat skill invocations on sensitive directories with the same care you would treat running an unfamiliar shell script.

## Configuring Permission Scopes

Claude Code implements a hierarchical permission system that controls what operations the AI can perform. You configure these boundaries at the project level using the `CLAUDE_PERMISSION_FILE` environment variable or by creating a `.claude/permissions.md` file in your project root.

For restricting skill access to specific directories, create a permissions file with explicit allowed paths:

```markdown
.claude/permissions.md
allowed_directories:
 - ./src
 - ./tests
 - ./docs

denied_directories:
 - ./secrets
 - ./credentials
 - ./env

max_file_size: 10485760
```

When a skill attempts to access files outside the allowed directories, Claude Code blocks the operation and notifies you. This approach works particularly well when you want to restrict skills like supermemory from accessing sensitive configuration files while still allowing normal development operations.

## Environment Variable Override

The `CLAUDE_PERMISSION_FILE` variable lets you point to a permissions file located outside the project tree, which is useful when you share a single permissions policy across multiple repositories:

```bash
export CLAUDE_PERMISSION_FILE=/home/developer/shared-policies/standard-dev.md
cd /projects/my-app
claude
```

This means every Claude Code session launched from any project on this machine will apply the same baseline restrictions, and you only need to maintain one policy file. For team environments, store this file in a shared network location or commit it to an internal tooling repository.

## Comparing Permissions Approaches

| Approach | Scope | Maintenance effort | Best for |
|---|---|---|---|
| `.claude/permissions.md` per project | Project-only | Low. per-repo file | Varying policies across projects |
| `CLAUDE_PERMISSION_FILE` env var | Session-wide | Medium. one file, many projects | Consistent baseline across machine |
| Per-skill `allowed_paths` in settings.json | Individual skill | Higher. update per skill | Fine-grained control per tool |
| `CLAUDE_PROJECT_ROOT` env var | Session root only | Minimal | Quick one-off isolation |
| OS-level user account restriction | Entire user session | High. needs sysadmin | Shared CI/CD runners |

## Project-Level Isolation Strategies

For teams working on multiple projects, isolating skill access per-project prevents accidental cross-contamination. Each project directory can have its own `.claude/settings.json` defining which skills are available and their access parameters.

Create a project-specific configuration:

```json
{
 "skills": {
 "pdf": {
 "enabled": true,
 "allowed_paths": ["./documents", "./reports"]
 },
 "xlsx": {
 "enabled": true,
 "allowed_paths": ["./data", "./exports"]
 },
 "tdd": {
 "enabled": true,
 "allowed_paths": ["./src", "./tests"]
 }
 },
 "read_only_mode": false,
 "blocked_operations": ["delete", "sudo"]
}
```

This configuration ensures that even if you invoke a skill like `/tdd run all tests`, the skill only operates within designated directories. The frontend-design skill, for instance, can be restricted to your assets and template directories while blocking access to build outputs or deployment configurations.

## Disabling Skills Entirely Per Project

Some projects should not allow certain skills at all. A data warehouse repository, for example, might prohibit the tdd skill to prevent accidental test scaffolding against production schemas. Set `"enabled": false` in `.claude/settings.json` for any skill you want unavailable in that project context:

```json
{
 "skills": {
 "tdd": { "enabled": false },
 "xlsx": { "enabled": false },
 "pdf": {
 "enabled": true,
 "allowed_paths": ["./output-reports"],
 "read_only": true
 }
 }
}
```

This pattern is especially useful when onboarding new team members who may invoke skills out of habit without understanding the project's intended workflow.

## Read-Only Mode for Entire Sessions

If you need to audit a codebase, review documentation, or run analytical skills without any risk of modification, enable read-only mode at the session level:

```bash
export CLAUDE_READ_ONLY=true
claude
```

In this mode, any skill that attempts a write or delete operation will be blocked. The session remains fully functional for inspection and analysis tasks. This is the safest option when exploring an unfamiliar codebase for the first time or when a teammate asks Claude to review their code without touching anything.

## Skill-Specific Access Controls

Individual skills can define their own file access constraints through metadata in their skill definition files. When creating or configuring a skill, specify explicit file patterns that the skill should handle:

```markdown
---
name: secure-pdf-processor
description: Process PDF files in the input directory without modifying source files
---

Secure PDF Processor

This skill processes PDF files in the input directory without modifying source files.
```

The `read_only: true` setting prevents the pdf skill from creating or modifying files outside the designated workspace, making it safe for processing sensitive documents without risking unintended modifications.

## Glob Pattern Denylists

The `denied_patterns` field in skill configuration accepts glob patterns, which gives you precise control over which files a skill should never touch regardless of directory:

```json
{
 "skills": {
 "tdd": {
 "allowed_paths": ["./src", "./tests"],
 "denied_patterns": [
 "/production/",
 "/.env*",
 "/*.pem",
 "/*.key",
 "/secrets/",
 "/credentials/",
 "/*.tfstate"
 ]
 }
 }
}
```

The glob patterns above cover the most common categories of sensitive file exposure: environment files, TLS certificates, private keys, Terraform state files, and directories explicitly named secrets or credentials. You can extend this list with patterns specific to your stack. for example, `/*.kubeconfig` if you work with Kubernetes, or `/vault-tokens/` if you use HashiCorp Vault.

## Pattern Priority: Allow vs. Deny

When both `allowed_paths` and `denied_patterns` are present, the deny patterns take precedence. A file that matches a denied pattern is blocked even if its parent directory is in the allowed list. This precedence behavior is intentional and mirrors how firewall rules typically work: explicit denials override permits.

## Directory-Based Skill Invocation

When you need temporary restrictions without modifying global settings, use directory-specific invocation patterns. Navigate to the restricted directory before invoking skills:

```bash
cd /path/to/restricted/project
claude
```

Within this session, skills operate from that directory as their root. Combine this with the `CLAUDE_PROJECT_ROOT` environment variable to establish clear boundaries:

```bash
export CLAUDE_PROJECT_ROOT=/workspace/my-app
claude
```

Skills like the xlsx skill will only see files within `/workspace/my-app` and its subdirectories, preventing accidental access to sibling directories containing other projects or sensitive data.

## Using a Subshell for Temporary Isolation

For one-off tasks where you do not want to change your current session environment, wrap the Claude invocation in a subshell with a scoped export:

```bash
(export CLAUDE_PROJECT_ROOT=/workspace/limited-scope && claude)
```

When the subshell exits, your outer shell environment is unchanged. This technique is useful in scripts or CI steps where you want guaranteed cleanup of the environment after the skill finishes.

## Chroot and Container-Based Isolation

For maximum isolation. such as when running skills against untrusted third-party codebases. combine `CLAUDE_PROJECT_ROOT` with OS-level directory isolation:

```bash
Using Docker for hard isolation
docker run --rm \
 -v /workspace/untrusted-repo:/workspace:ro \
 -e CLAUDE_PROJECT_ROOT=/workspace \
 -e CLAUDE_READ_ONLY=true \
 your-claude-code-image \
 claude -c "analyze this codebase for security issues"
```

The `:ro` mount flag makes the entire directory read-only at the container level, providing a hard enforcement layer that no application-level configuration can override. This is the appropriate approach for automated review pipelines processing external code submissions.

## Practical Examples

Consider a scenario where you want to use the tdd skill for test-driven development while preventing it from touching production configuration files:

```json
{
 "skills": {
 "tdd": {
 "allowed_paths": ["./src", "./tests", "./test-utils"],
 "denied_patterns": ["/production/", "/.env*"]
 }
 }
}
```

For a documentation workflow using the pdf skill:

```json
{
 "skills": {
 "pdf": {
 "allowed_paths": ["./docs", "./manuals"],
 "denied_paths": ["./internal/Confidential"]
 }
 }
}
```

The frontend-design skill benefits from similar restrictions, ensuring design automation only touches source assets:

```json
{
 "skills": {
 "frontend-design": {
 "allowed_paths": ["./src/assets", "./src/components", "./designs"]
 }
 }
}
```

## Monorepo Scenario: Per-Package Skill Scoping

Monorepos present a particular challenge because they contain many distinct packages within a single tree. A skill operating at the repo root can inadvertently touch packages it has no business accessing. The recommended pattern for monorepos is to define a workspace-aware configuration that mirrors your package structure:

```json
{
 "skills": {
 "tdd": {
 "allowed_paths": [
 "./packages/auth/src",
 "./packages/auth/tests",
 "./packages/auth/test-utils"
 ],
 "denied_patterns": [
 "./packages/payments/",
 "./packages/infrastructure/",
 "./deploy/"
 ]
 },
 "xlsx": {
 "allowed_paths": ["./packages/analytics/data"]
 }
 }
}
```

When a developer working on the `auth` package invokes a skill, it cannot drift into `payments` or `infrastructure` directories even if the root `.claude/settings.json` is the active configuration. This separation is particularly valuable in organizations where different teams own different packages within the same monorepo.

## CI/CD Pipeline Configuration

In automated environments, the safest configuration is one that explicitly disables all write operations and limits skills to read-only analysis:

```bash
.github/workflows/claude-review.yml (excerpt)
env:
 CLAUDE_READ_ONLY: "true"
 CLAUDE_LOG_LEVEL: "debug"
 CLAUDE_LOG_FILE: "/tmp/claude-audit.log"
 CLAUDE_PROJECT_ROOT: "${{ github.workspace }}"
```

Pairing read-only mode with a fixed project root means the skill can never write outside the checked-out workspace, and the audit log captures every file it reads. After the workflow completes, you can archive the audit log as a workflow artifact for compliance purposes.

## Monitoring and Audit Trails

Beyond configuration, maintain visibility into skill file operations. Enable logging for all file system activities:

```bash
export CLAUDE_LOG_LEVEL=debug
export CLAUDE_LOG_FILE=/var/log/claude/audit.log
```

Review these logs periodically to identify any skill behavior that exceeds intended boundaries. The [supermemory skill](/claude-supermemory-skill-persistent-context-explained/), which persists conversation context, particularly benefits from audit logging since it writes to hidden directories that aren't immediately visible during normal development.

## Parsing Audit Logs for Anomalies

The debug-level log records each file operation with a timestamp, skill name, operation type, and path. You can run a quick scan against a completed session to verify no unexpected paths were touched:

```bash
Show all file write operations from the last session
grep '"operation":"write"' /var/log/claude/audit.log | \
 jq '{skill: .skill, path: .path, ts: .timestamp}'

Alert on any access outside the expected project root
grep '"path":' /var/log/claude/audit.log | \
 jq -r '.path' | \
 grep -v '^/workspace/my-app' | \
 sort -u
```

If unexpected paths appear in the output, cross-reference them with the skill that generated the access and tighten that skill's `allowed_paths` configuration. Building this review step into a post-run script gives you an automated tripwire for configuration drift.

## Log Rotation and Retention

For long-running development machines where Claude Code is used daily, log files can grow quickly at debug level. Configure log rotation to prevent disk exhaustion:

```bash
/etc/logrotate.d/claude
/var/log/claude/audit.log {
 daily
 rotate 30
 compress
 missingok
 notifempty
 create 0640 developer developer
}
```

Keep at least 30 days of audit logs in environments where you might need to investigate a past incident. For compliance-sensitive environments, ship logs to a centralized logging system so they remain available even after local rotation.

## Best Practices Summary

Restricting Claude skill file access requires a layered approach:

1. Start with project-level permissions using `.claude/permissions.md` to establish baseline restrictions
2. Configure skill-specific controls for each skill based on its intended function
3. Use directory isolation for sensitive projects or when experimenting with new skills
4. Enable audit logging to track access patterns and identify potential issues
5. Review and adjust permissions as project requirements evolve
6. Use `CLAUDE_READ_ONLY=true` anytime you are exploring an unfamiliar codebase and do not intend to make changes
7. Apply glob denylists that explicitly block credential file patterns regardless of what directories are allowed
8. In CI/CD pipelines, combine `CLAUDE_PROJECT_ROOT`, read-only mode, and audit logging as a standard hardened baseline

## Quick Reference: Key Environment Variables

| Variable | Purpose | Example value |
|---|---|---|
| `CLAUDE_PROJECT_ROOT` | Limits session root directory | `/workspace/my-app` |
| `CLAUDE_PERMISSION_FILE` | Points to an external permissions policy | `/etc/claude/policy.md` |
| `CLAUDE_READ_ONLY` | Blocks all write operations session-wide | `true` |
| `CLAUDE_LOG_LEVEL` | Controls audit log verbosity | `debug` |
| `CLAUDE_LOG_FILE` | Directs audit output to a file | `/var/log/claude/audit.log` |

These controls give you the flexibility to use skills like pdf, xlsx, tdd, and frontend-design while maintaining security boundaries appropriate for your development environment.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=how-do-i-limit-what-a-claude-skill-can-access-on-disk)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Code Permissions Model and Security Guide 2026](/claude-code-permissions-model-security-guide-2026/). Understand the full Claude Code permissions system that governs what skills can access by default
- [Claude Code Secret Scanning: Prevent Credential Leaks Guide](/claude-code-secret-scanning-prevent-credential-leaks-guide/). Complement disk access controls with scanning to prevent sensitive credentials from leaking through skills
- [How Do I Set Environment Variables for a Claude Skill](/how-do-i-set-environment-variables-for-a-claude-skill/). Configure skill-specific environment variables to further isolate API keys and paths from disk access
- [Claude Skills: Getting Started Hub](/getting-started-hub/). Explore foundational Claude Code security patterns and permission configuration approaches

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

