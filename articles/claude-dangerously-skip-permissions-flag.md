---
title: "Claude --dangerously-skip-permissions Flag (2026)"
description: "How to use the claude --dangerously-skip-permissions flag for unattended CI/CD, batch scripting, and headless automation. Syntax, use cases, and risks."
permalink: /claude-dangerously-skip-permissions-flag/
canonical_url: /claude-code-dangerously-skip-permissions-guide/
last_tested: "2026-04-24"
render_with_liquid: false
---

## The Flag

```bash
claude --dangerously-skip-permissions
```

This flag tells Claude Code to skip all interactive permission prompts. Normally, Claude Code asks for your approval before running shell commands, writing files, or executing potentially destructive operations. With this flag, every action is auto-approved.

For the complete guide covering security implications, sandboxing, allowlists, and production hardening, see the **[full --dangerously-skip-permissions guide](/claude-code-dangerously-skip-permissions-guide/)**.

## Exact Syntax

```bash
# Basic usage
claude --dangerously-skip-permissions

# With a prompt (non-interactive mode)
claude -p "Run the test suite and fix any failures" --dangerously-skip-permissions

# Combined with model selection
claude --model claude-sonnet-4-20250514 --dangerously-skip-permissions

# In a CI pipeline with output format
claude -p "Lint and fix all TypeScript errors" --dangerously-skip-permissions --output-format json
```

The flag must be passed at startup. You cannot enable it mid-session.

## 3 Use Cases

### 1. CI/CD Pipeline Automation

Run Claude Code as a step in your CI pipeline where no human is present to approve actions:

```yaml
# GitHub Actions example
- name: Fix lint errors with Claude
  run: |
    claude -p "Fix all ESLint errors in src/" \
      --dangerously-skip-permissions \
      --output-format json
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

Without the flag, Claude Code would hang waiting for interactive approval that nobody can give. See the [full guide](/claude-code-dangerously-skip-permissions-guide/) for how to combine this with Docker sandboxing to limit blast radius.

### 2. Batch Scripting Across Multiple Repositories

Process many repositories in sequence without manually approving each action:

```bash
#!/bin/bash
for repo in ~/projects/*/; do
  echo "Processing: $repo"
  cd "$repo"
  claude -p "Update all dependencies and run tests" \
    --dangerously-skip-permissions
done
```

This pattern is useful for organization-wide migrations, dependency updates, or code standard enforcement. The [complete guide](/claude-code-dangerously-skip-permissions-guide/) covers how to set up CLAUDE.md rules that constrain what Claude Code does even when permissions are skipped.

### 3. Headless Server Automation

On servers without a terminal (cron jobs, systemd services, remote task runners), interactive prompts are impossible:

```bash
# Cron job: nightly code cleanup
0 2 * * * cd /opt/app && claude -p "Run database migrations and verify schema" \
  --dangerously-skip-permissions >> /var/log/claude-maintenance.log 2>&1
```

## What This Flag Does and Does Not Do

**It skips:** File write approval, shell command approval, destructive operation warnings, and any other interactive confirmation prompt.

**It does not skip:** API authentication, rate limit enforcement, model availability checks, or CLAUDE.md instruction parsing. Claude Code still reads and follows your CLAUDE.md rules.

## Risks

Using this flag means Claude Code can execute any shell command, modify any file, and delete any data without asking first. In production environments, always pair it with:

- **Docker containers** to isolate the filesystem
- **Read-only mounts** for directories that should not be modified
- **CLAUDE.md rules** that explicitly restrict allowed operations
- **Git branch protection** so destructive changes can be reviewed before merging

The [full --dangerously-skip-permissions guide](/claude-code-dangerously-skip-permissions-guide/) covers each of these safeguards in detail with working configurations.

## Setting Up Safe Automation Environments

When using the `--dangerously-skip-permissions` flag, the environment you run Claude Code in becomes your primary safety mechanism. Here are detailed setups for common automation scenarios.

### Docker Isolation (Recommended)

Running Claude Code inside a Docker container limits the blast radius of any operation. Even with permissions skipped, Claude Code cannot affect files outside the container.

```dockerfile
FROM node:20-slim

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Create a non-root user
RUN useradd -m coder
USER coder
WORKDIR /home/coder/project

# Copy your project in
COPY --chown=coder:coder . .

# Run with permissions skipped
CMD ["claude", "-p", "Run tests and report results", "--dangerously-skip-permissions"]
```

Build and run:

```bash
docker build -t claude-ci .
docker run --rm \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  -v "$(pwd)/output:/home/coder/output" \
  claude-ci
```

This setup ensures that Claude Code can only modify files within the container. The output volume mount gives you a controlled way to extract results.

### Read-Only Source Mounts

For code review tasks where Claude should read but not modify your source:

```bash
docker run --rm \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  -v "$(pwd)/src:/project/src:ro" \
  -v "$(pwd)/output:/project/output" \
  claude-ci -p "Review all files in /project/src and write a report to /project/output/review.md" \
  --dangerously-skip-permissions
```

The `:ro` flag makes the source directory read-only inside the container. Claude Code can read the code but cannot modify it, even with permissions skipped.

### GitHub Actions with Timeouts

Add timeout controls to prevent runaway sessions:

```yaml
- name: Claude Code automated fix
  timeout-minutes: 10
  run: |
    npx @anthropic-ai/claude-code \
      -p "Fix all type errors in src/" \
      --dangerously-skip-permissions \
      --output-format json
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

The `timeout-minutes` directive kills the step if it runs too long, preventing unbounded API costs.

### Using CLAUDE.md as a Safety Rail

Even with permissions skipped, Claude Code reads and follows instructions in your CLAUDE.md file. Use this to constrain behavior:

```markdown
# CLAUDE.md

## Rules
- Never modify files in the /config directory
- Never run git push or git force push
- Never delete files without creating a backup first
- Only modify files matching src/**/*.ts
- Always run tests after making changes
```

Claude Code will respect these instructions. While they are not enforced at the system level (unlike Docker mounts), they provide a practical safety layer for most automation use cases.

### Combining Multiple Safety Layers

The most robust setup combines several layers:

1. **Docker container** for filesystem isolation
2. **Read-only mounts** for source code that should not change
3. **CLAUDE.md rules** for behavioral constraints
4. **Timeout limits** to cap execution time and cost
5. **Git branch protection** so that any changes must pass review before merging

This defense-in-depth approach means that no single failure can cause damage.

## Logging and Auditing

When running Claude Code with skipped permissions, you lose the interactive approval step that normally serves as an audit trail. Replace it with explicit logging.

### Structured Output Logging

```bash
claude -p "Fix lint errors in src/" \
  --dangerously-skip-permissions \
  --output-format json > /var/log/claude-run-$(date +%Y%m%d-%H%M%S).json 2>&1
```

The JSON output includes every tool call, file edit, and command execution. Store these logs for post-run review.

### Git Diff as Audit

After an automated Claude Code run, generate a diff to see exactly what changed:

```bash
git diff --stat
git diff > /tmp/claude-changes.patch
```

Review the patch before committing or merging.

## FAQ

### Can I use an allowlist instead of skipping all permissions?

Yes. Claude Code supports `settings.json` configuration with `allowedTools` that lets you approve specific tools while still prompting for others. This is safer than the blanket skip flag. See the [full guide](/claude-code-dangerously-skip-permissions-guide/) for allowlist configuration.

### Is there a way to log what actions Claude Code takes when permissions are skipped?

Claude Code outputs its actions to the terminal. Redirect stdout and stderr to a log file (`>> log.txt 2>&1`) to capture a full audit trail. For structured output, use `--output-format json`.

### Should I use this flag during local development?

Generally no. During local development, the permission prompts protect you from accidental file deletions, unintended git operations, and runaway shell commands. Reserve the flag for automated, sandboxed, or disposable environments.

## Related Guides

- [Full --dangerously-skip-permissions Guide](/claude-code-dangerously-skip-permissions-guide/)
- [The Claude Code Playbook](/the-claude-code-playbook/)
- [Fix Claude Code Rate Limit 429 Error](/claude-code-rate-limit-429-retry-after-fix/)
- [Fix Claude Internal Server Error](/claude-internal-server-error-fix/)
- [Fix Claude Code ETIMEOUT Corporate Proxy](/claude-code-etimeout-corporate-proxy-fix/)
- [Fix Claude Code Docker Cannot Reach API Endpoint](/claude-code-docker-cannot-reach-api-endpoint-fix/)
- [Fix Claude Rate Exceeded Error](/claude-rate-exceeded-error-fix/)
- [Fix Claude Code Model Not Available in Region](/claude-code-model-not-available-region-fix/)
