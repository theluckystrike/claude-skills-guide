---
layout: default
title: "Claude Code Sandbox Mode Guide (2026)"
description: "Run Claude Code in sandbox mode for safe experimentation. How sandboxing works, when to use it, and configuration options."
permalink: /claude-code-sandbox-mode-guide-2026/
date: 2026-04-26
---

# Claude Code Sandbox Mode Guide (2026)

Sandbox mode isolates Claude Code from your real file system and environment. When you want Claude to experiment freely without risk — testing destructive commands, exploring unfamiliar code patterns, or letting junior developers learn safely — sandboxing provides the guardrails.

This guide covers how sandboxing works in Claude Code, when to use it, and how to configure it alongside your [permission settings](/permissions/).

## What Sandbox Mode Does

In sandbox mode, Claude Code operates in a restricted environment:

- **File system isolation** — Writes go to a temporary directory, not your actual project files
- **Command restrictions** — Shell commands execute in a contained context
- **Network limitations** — External network access may be restricted depending on configuration
- **Process isolation** — Commands cannot affect processes outside the sandbox

The key benefit is safety. Claude can run `rm -rf *`, attempt to install packages, or rewrite entire files — and none of it affects your real project. When the sandbox session ends, the temporary environment is cleaned up.

## When to Use Sandbox Mode

### Learning and experimentation

New Claude Code users can explore features without fear of breaking things:

```bash
# Safe to try anything
claude --sandbox
> Delete all files in the project and start from scratch
> Run npm install every-package-on-npm
```

Nothing actually happens to your project. The sandbox catches everything.

### Testing destructive operations

Before running a complex refactoring or migration in your real project:

```bash
claude --sandbox
> Refactor every class component to functional components
> Run the migration script and show me what would change
```

Review the results in the sandbox, then apply the changes to your real project with confidence.

### Untrusted code review

When reviewing code from untrusted sources (open-source contributions, vendor deliverables):

```bash
claude --sandbox
> Clone this repo and analyze it for security issues
> Run the test suite and see if anything suspicious happens
```

If the code does something malicious, the sandbox contains the damage.

### Training and demos

For workshops, conference talks, and onboarding sessions where you want to demonstrate Claude Code without risking live environments:

```bash
claude --sandbox
> Show me what happens when I run git push --force to main
```

The audience sees the result without any actual damage.

## Configuring Sandbox Behavior

### Basic sandbox activation

```bash
claude --sandbox
```

This uses the default sandbox configuration: temporary directory for file writes, restricted shell, no network access.

### Sandbox with specific permissions

Combine sandbox mode with permission configuration:

```bash
claude --sandbox --allowedTools "Read,Glob,Grep,Bash(git *),Write"
```

This creates a sandbox where Claude can read your real files (for reference) but writes go to the sandbox directory. Useful for generating code based on your existing project without modifying it.

### Sandbox in settings.json

For permanent sandbox configuration:

```json
{
  "sandbox": {
    "enabled": true,
    "networkAccess": false,
    "writeDirectory": "/tmp/claude-sandbox"
  }
}
```

See the [settings.json guide](/claude-code-settings-json-explained-2026/) for all available sandbox settings.

## Sandbox vs Permission Modes

Understanding when to use sandbox mode versus permission configuration:

| Feature | Sandbox Mode | Permission Allowlist | YOLO Mode |
|---------|-------------|---------------------|-----------|
| File writes | Redirected to temp dir | Controlled by rules | Unrestricted |
| Shell commands | Contained | Controlled by patterns | Unrestricted |
| Network access | Blocked (by default) | Controlled by rules | Unrestricted |
| Real file reads | Allowed (read-only) | Controlled by rules | Unrestricted |
| Best for | Experimentation, learning | Daily development | CI/CD pipelines |
| Risk level | Minimal | Low-medium | High |

For most developers, permission configuration with an allowlist is the right daily driver. Sandbox mode is for specific scenarios where you want extra isolation. See the [permissions guide](/claude-code-permissions-complete-guide-2026/) for setting up daily-use permissions.

## Sandbox Limitations

### No persistent changes

By design, sandbox changes do not persist. If Claude builds something useful in the sandbox, you need to manually copy the results to your real project. This is the trade-off for safety.

### Performance overhead

Sandbox mode adds overhead from file system redirection and process isolation. Expect 10-20% slower file operations compared to normal mode. For most workflows this is unnoticeable.

### Partial context

Claude can read your real project files but its writes go to the sandbox. This means Claude sees the original state of files even after modifying them, which can cause confusion in long sessions. Compact more frequently in sandbox mode to keep context aligned.

### Not a security boundary

Sandbox mode provides safety against accidents, not against adversarial attacks. It is not a replacement for proper container isolation when running genuinely untrusted code. For high-security scenarios, run Claude Code inside a Docker container or VM.

## Try It Yourself

The [Permissions Configurator](/permissions/) helps you decide between sandbox mode and permission-based control. It evaluates your use case and recommends the right approach.

For a quick test, start a sandbox session right now:

```bash
claude --sandbox
```

Try running commands you would never run in your real project. See how Claude operates with full freedom while your actual files remain untouched.

## Sandbox with Docker

For maximum isolation, run Claude Code inside a Docker container:

```dockerfile
FROM node:20
RUN npm install -g @anthropic/claude-code
WORKDIR /workspace
COPY . .
CMD ["claude", "--dangerously-skip-permissions"]
```

This provides both file system and network isolation at the container level. The `--dangerously-skip-permissions` flag is safe here because the container is the security boundary.

See the [Docker workflow guide](/claude-code-docker-compose-api-tutorial-guide/) for detailed container setup.

## Common Issues and Fixes

### "Permission denied in sandbox mode"

The sandbox directory needs write permissions. Check that `/tmp/claude-sandbox` (or your configured directory) is writable by your user.

See [permission denied sandbox mode fix](/claude-code-permission-denied-sandbox-mode-fix-2026/) for step-by-step troubleshooting.

### "File not found after editing"

In sandbox mode, Claude's writes go to the sandbox directory, but reads come from your real project. The edited version exists in the sandbox, not in the location Claude expects. This is expected behavior.

### "Tests fail in sandbox"

Test frameworks may depend on file paths that do not exist in the sandbox. Configure your test runner to use relative paths or set the sandbox directory to mirror your project structure.

## Frequently Asked Questions

**Is sandbox mode the same as a Docker container?**

No. Sandbox mode redirects file writes and restricts commands but runs in your native environment. Docker provides full OS-level isolation. Sandbox is lighter but less secure against adversarial scenarios.

**Can I recover files from a sandbox session?**

Yes, until the session ends. The sandbox writes to a temporary directory (check your config for the exact path). Copy any files you want to keep before ending the session.

**Does sandbox mode affect token usage?**

Minimally. The sandbox adds a small amount of overhead to tool definitions (explaining the sandbox constraints to Claude), but the difference is typically under 100 tokens.

**Should I use sandbox mode in production CI/CD?**

No. In CI/CD, you want Claude to actually make changes (fix tests, update files). Use YOLO mode in disposable containers instead, since the container itself is your sandbox.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Is sandbox mode the same as a Docker container?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Sandbox mode redirects file writes and restricts commands but runs in your native environment. Docker provides full OS-level isolation. Sandbox is lighter but less secure."
      }
    },
    {
      "@type": "Question",
      "name": "Can I recover files from a sandbox session?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes, until the session ends. The sandbox writes to a temporary directory. Copy any files you want to keep before ending the session."
      }
    },
    {
      "@type": "Question",
      "name": "Does sandbox mode affect token usage?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Minimally. The sandbox adds small overhead to tool definitions, but the difference is typically under 100 tokens."
      }
    },
    {
      "@type": "Question",
      "name": "Should I use sandbox mode in production CI/CD?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. In CI/CD you want Claude to actually make changes. Use YOLO mode in disposable containers instead, since the container itself is your sandbox."
      }
    }
  ]
}
</script>



**Fix it instantly →** Paste your error into our [Error Diagnostic Tool](/diagnose/) for step-by-step resolution.

## Related Guides

**Quick setup →** Launch your project with our [Project Starter](/starter/).

- [Permissions Configurator](/permissions/) — Choose between sandbox and permissions
- [Permissions Guide](/claude-code-permissions-complete-guide-2026/) — Complete permission system reference
- [Permission Denied Sandbox Fix](/claude-code-permission-denied-sandbox-mode-fix-2026/) — Troubleshoot sandbox errors
- [Docker Workflow Guide](/claude-code-docker-compose-api-tutorial-guide/) — Container-based isolation
- [Security Best Practices](/claude-code-security-best-practices-2026/) — Enterprise security guide
