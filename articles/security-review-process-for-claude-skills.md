---
title: "Security Review Process for Claude Code"
description: "Review checklist for SKILL.md files covering allowed-tools risks, script injection, env var exposure, and permission boundaries in shared skills."
permalink: /security-review-process-for-claude-skills/
render_with_liquid: false
categories: [skills, 2026]
tags: [claude-code, claude-skills, security, review, permissions]
last_updated: 2026-04-19
---

## The Specific Situation

A developer submits a PR adding a skill with `allowed-tools: Bash(*)`. This pre-approves every shell command without prompting. The skill also includes a script that reads `~/.ssh/id_rsa` and posts it to an external URL "for backup purposes." Without a security review process, this merges and executes on every team member's machine the next time the skill triggers. Here is the review process that catches this.

## Technical Foundation

Skills execute within Claude Code's permission system. The `allowed-tools` field grants tool access without user confirmation. The `Bash()` tool pattern uses glob matching -- `Bash(*)` matches every command. Scripts bundled in `scripts/` run with the same filesystem and network access as the developer's user account.

Permission boundaries:

- `allowed-tools` grants access (additive only, never restrictive)
- Deny rules in `/permissions` override `allowed-tools`
- `disableSkillShellExecution: true` prevents `!`command`` execution in skills
- Managed settings can enforce global deny rules that no skill can bypass

Dynamic context injection (`!`command``) runs shell commands before Claude sees the skill content. These commands execute immediately when the skill loads -- no user confirmation.

## The Working SKILL.md (Security Auditor)

```yaml
---
name: audit-skill-security
description: >
  Audit a SKILL.md file for security risks before deployment. Use
  when reviewing skill PRs or checking existing skills for
  vulnerabilities.
disable-model-invocation: true
argument-hint: "[path-to-skill-md]"
allowed-tools: Read Grep
---

# Security Audit: SKILL.md

Audit the skill file at $ARGUMENTS for security risks.

## Check 1: Overly Broad Tool Permissions

Read the allowed-tools field. Flag:
- `Bash(*)` - approves ALL commands (CRITICAL)
- `Bash(rm *)` - file deletion (HIGH)
- `Bash(curl *)` - network access (MEDIUM)
- `Bash(ssh *)` - remote access (HIGH)
- Any pattern without specific command prefix (MEDIUM)

SAFE patterns: `Bash(git status *)`, `Bash(npm test *)`

## Check 2: Script Content

Read all files in scripts/ directory. Flag:
- Network requests (curl, wget, fetch, http)
- File reads outside project directory (~/, /etc/, /var/)
- Environment variable access ($HOME, $SSH_*, $AWS_*)
- Base64 encoding (data exfiltration pattern)
- Write to /tmp or other shared directories

## Check 3: Dynamic Context Injection

Search for !` patterns. Flag:
- Commands that read sensitive files
- Commands that make network requests
- Commands that access environment variables with secrets

## Check 4: Skill Scope

Flag if:
- Side-effect skill missing disable-model-invocation: true
- Description is vague enough to trigger unintentionally
- No paths field on a skill with broad allowed-tools

## Output

```
SECURITY AUDIT: [skill-name]
=============================
CRITICAL: [issue]
HIGH: [issue]
MEDIUM: [issue]
LOW: [issue]

VERDICT: APPROVE / NEEDS_CHANGES / REJECT
```
```

## The 5-Point Security Review

### 1. Audit allowed-tools Patterns

Narrow is safe. Broad is dangerous.

```yaml
# SAFE: specific command with specific subcommand
allowed-tools: Bash(git add *) Bash(git commit *) Bash(npm test *)

# RISKY: broad command access
allowed-tools: Bash(docker *) Bash(curl *)

# DANGEROUS: unrestricted
allowed-tools: Bash(*)
```

Review rule: every `Bash()` pattern should specify a command and subcommand. `Bash(git *)` is acceptable for git workflows. `Bash(*)` is never acceptable in shared skills.

### 2. Review Bundled Scripts

Every script in `scripts/` must be read by a human reviewer. Check for:

- **Network calls**: Does the script send data anywhere?
- **File access**: Does it read files outside the project?
- **Env vars**: Does it access `$AWS_SECRET_ACCESS_KEY`, `$GITHUB_TOKEN`, etc.?
- **Execution**: Does it run other scripts or download/execute code?

### 3. Check Dynamic Context Injection

The `!`command`` syntax executes immediately when the skill loads:

```yaml
# This runs BEFORE Claude sees anything:
- Current API keys: !`env | grep API`

# This is a security risk -- exposes secrets to Claude's context
```

Rule: Dynamic injection should only read project-specific data (`gh pr diff`, `git log`), never system or environment data.

### 4. Verify Invocation Controls

Side-effect skills MUST have `disable-model-invocation: true`:

```yaml
# These MUST be manual-only:
# - deploy, push, publish, send, delete, drop, migrate
# - Any skill that modifies external state

disable-model-invocation: true
```

Without this flag, Claude auto-triggers the skill when the description matches casual conversation. "Can you help me deploy?" should not auto-start a production deployment.

### 5. Check Scope Boundaries

Skills with broad `allowed-tools` should have narrow `paths`:

```yaml
# Scoped: only activates for test files
paths: "**/*.test.ts"
allowed-tools: Bash(npx jest *)

# Unscoped with broad tools: risky
allowed-tools: Bash(docker *) Bash(kubectl *)
# This needs: paths: "**/k8s/**" or similar
```

## Common Problems and Fixes

**allowed-tools cannot be restricted by deny rules**: Incorrect. Deny rules in `/permissions` always override `allowed-tools`. If the team denies `Bash(rm *)` globally, no skill can override that with `allowed-tools`.

**Script passes code review but behavior changes**: Scripts can call other scripts or download code at runtime. Check for `eval`, `source`, `bash -c`, and `curl | bash` patterns.

**Skill reads environment variables**: `!`env`` in dynamic context injection exposes all environment variables to Claude's context. This may include API keys, database passwords, and other secrets. Never use `!`env`` in shared skills.

**Developer disables security with personal skill**: A developer can create a personal skill with `allowed-tools: Bash(*)`. This only affects their own session. You cannot prevent it through project-level controls, but you can enforce `permissions.deny` via managed settings.

## Production Gotchas

The `disableSkillShellExecution` setting prevents `!`command`` execution for user, project, and plugin skills. Bundled (Anthropic-provided) and managed skills are unaffected. Consider enabling this setting in security-sensitive environments and relying on Claude's direct tool calls instead.

CODEOWNERS on GitHub can require specific reviewers for `.claude/skills/` changes. Add a rule like `/.claude/skills/ @security-team` to enforce review.

There is no sandboxing for skill scripts. A Python script in `scripts/` has the same access as any Python script the developer runs locally. The security boundary is code review, not technical isolation.

## Checklist

- [ ] `allowed-tools` uses specific command patterns, not `Bash(*)`
- [ ] All scripts in `scripts/` reviewed for network and file access
- [ ] No `!`command`` reads environment variables or secrets
- [ ] Side-effect skills have `disable-model-invocation: true`
- [ ] CODEOWNERS configured for `.claude/skills/` directory

## Related Guides

- [Claude Skills CI/CD Patterns](/claude-skills-ci-cd-patterns/)
- [Managing Claude Skills Across Team Members](/managing-claude-skills-across-team-members/)
- [Fix Claude Code Spawn Unknown Error Skills](/fix-claude-code-spawn-unknown-error-skills/)

## Related Articles

- [OpenCLAW Skill Security Risks and Mitigations](/openclaw-skill-security-risks-and-mitigations/)
