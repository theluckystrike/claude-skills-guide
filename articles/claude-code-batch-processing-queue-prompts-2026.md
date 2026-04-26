---
layout: post
title: "Claude Code Batch Processing (2026)"
description: "Queue and batch-process multiple prompts in Claude Code. Use shell scripts, task files, and parallel execution for automated multi-step workflows."
permalink: /claude-code-batch-processing-queue-prompts-2026/
date: 2026-04-21
last_tested: "2026-04-21"
---

## The Workflow

Process multiple Claude Code prompts sequentially or in parallel without manual intervention. Use shell scripts, task files, and piped commands to batch operations like code reviews, file generation, and refactoring across an entire project.

Expected time: 10 minutes setup
Prerequisites: Claude Code CLI installed, bash or zsh shell

## Setup

### 1. Create a Task File

```bash
mkdir -p .claude-tasks
cat > .claude-tasks/batch.txt << 'EOF'
Review src/auth/login.ts for security issues and write findings to reports/auth-review.md
Generate unit tests for src/utils/date-helpers.ts and save to src/utils/date-helpers.test.ts
Add JSDoc comments to all exported functions in src/api/handlers.ts
Create a README.md for the src/middleware/ directory documenting each middleware
EOF
```

Each line is a separate prompt that Claude Code will execute independently.

### 2. Create the Batch Runner Script

```bash
cat > .claude-tasks/run-batch.sh << 'EOF'
#!/bin/bash
set -euo pipefail

TASK_FILE="${1:-.claude-tasks/batch.txt}"
LOG_DIR=".claude-tasks/logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TOTAL=$(wc -l < "$TASK_FILE" | tr -d ' ')
CURRENT=0
FAILED=0

echo "Processing $TOTAL tasks from $TASK_FILE"
echo "Logs: $LOG_DIR/"
echo "---"

while IFS= read -r prompt; do
  # Skip empty lines and comments
  [[ -z "$prompt" || "$prompt" == \#* ]] && continue

  CURRENT=$((CURRENT + 1))
  LOGFILE="$LOG_DIR/task_${TIMESTAMP}_${CURRENT}.log"

  echo "[$CURRENT/$TOTAL] $prompt"

  if claude --print "$prompt" > "$LOGFILE" 2>&1; then
    echo "  ✓ Done ($(wc -c < "$LOGFILE" | tr -d ' ') bytes)"
  else
    echo "  ✗ Failed (see $LOGFILE)"
    FAILED=$((FAILED + 1))
  fi
done < "$TASK_FILE"

echo "---"
echo "Complete: $((CURRENT - FAILED))/$CURRENT succeeded"
[ $FAILED -gt 0 ] && exit 1
EOF
chmod +x .claude-tasks/run-batch.sh
```

### 3. Create a Parallel Runner for Independent Tasks

```bash
cat > .claude-tasks/run-parallel.sh << 'EOF'
#!/bin/bash
set -uo pipefail

TASK_FILE="${1:-.claude-tasks/batch.txt}"
MAX_PARALLEL="${2:-3}"
LOG_DIR=".claude-tasks/logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RUNNING=0
TASK_NUM=0

echo "Running tasks in parallel (max $MAX_PARALLEL concurrent)"

while IFS= read -r prompt; do
  [[ -z "$prompt" || "$prompt" == \#* ]] && continue

  TASK_NUM=$((TASK_NUM + 1))
  LOGFILE="$LOG_DIR/parallel_${TIMESTAMP}_${TASK_NUM}.log"

  echo "Starting task $TASK_NUM: ${prompt:0:60}..."

  claude --print "$prompt" > "$LOGFILE" 2>&1 &
  RUNNING=$((RUNNING + 1))

  if [ $RUNNING -ge $MAX_PARALLEL ]; then
    wait -n
    RUNNING=$((RUNNING - 1))
  fi
done < "$TASK_FILE"

wait
echo "All $TASK_NUM tasks complete. Logs in $LOG_DIR/"
EOF
chmod +x .claude-tasks/run-parallel.sh
```

### 4. Verify

```bash
# Test with a single-task file
echo "List the files in the current directory" > /tmp/test-batch.txt
.claude-tasks/run-batch.sh /tmp/test-batch.txt
# Expected output:
# [1/1] List the files in the current directory
#   ✓ Done (XXX bytes)
# ---
# Complete: 1/1 succeeded
```

## Usage Example

Batch-generate API documentation for all route files:

```bash
# Create task file from existing route files
cat > .claude-tasks/document-routes.txt << 'EOF'
# API Documentation Generation
Read src/routes/users.ts and generate OpenAPI 3.1 YAML for all endpoints. Save to docs/api/users.yaml
Read src/routes/products.ts and generate OpenAPI 3.1 YAML for all endpoints. Save to docs/api/products.yaml
Read src/routes/orders.ts and generate OpenAPI 3.1 YAML for all endpoints. Save to docs/api/orders.yaml
Read src/routes/auth.ts and generate OpenAPI 3.1 YAML for all endpoints. Save to docs/api/auth.yaml
Combine all YAML files in docs/api/ into a single openapi.yaml with proper $ref links
EOF

# Run sequentially (last task depends on previous ones)
.claude-tasks/run-batch.sh .claude-tasks/document-routes.txt
```

Batch code review for a pull request:

```bash
# Generate review tasks from git diff
git diff main --name-only -- '*.ts' | while read file; do
  echo "Review $file for bugs, type safety issues, and missing error handling. Be concise."
done > .claude-tasks/pr-review.txt

# Run reviews in parallel (independent tasks)
.claude-tasks/run-parallel.sh .claude-tasks/pr-review.txt 5

# Combine results
cat .claude-tasks/logs/parallel_*.log > pr-review-summary.md
```

Pipe-based batch processing without task files:

```bash
# Process multiple files through a single pattern
find src/components -name "*.tsx" -type f | head -10 | while read file; do
  echo "Processing $file..."
  claude --print "Add accessibility aria-labels to all interactive elements in $file. Output only the modified file." > "${file}.accessible"
done

# One-liner for quick batch queries
echo -e "Explain CORS\nExplain CSRF\nExplain XSS" | \
  while IFS= read -r q; do claude --print "$q" >> security-glossary.md; done
```

## Common Issues

- **Rate limiting with parallel execution:** Limit `MAX_PARALLEL` to 3-5 to avoid hitting API rate limits. Add `sleep 1` between task launches if you get 429 errors.
- **Context not shared between batch tasks:** Each `claude --print` call is stateless. If tasks depend on each other, use sequential mode or combine them into a single prompt.
- **Large outputs truncated in logs:** Increase your shell's pipe buffer or redirect directly to files as shown in the scripts above.

## Why This Matters

Batch processing turns a 2-hour manual code review into a 10-minute automated run. Teams use this to enforce consistent documentation, test coverage, and code style across entire repositories in a single command.



**Build yours →** Create a custom CLAUDE.md with our [Generator Tool](/generator/).

## Related Guides

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Best Way to Batch Claude Code Requests and Reduce API Calls](/best-way-to-batch-claude-code-requests-reduce-api-calls/)
- [How to Coordinate Multiple AI Agents in a Pipeline](/how-to-coordinate-multiple-ai-agents-in-pipeline/)
- [Claude Code Tmux Session Management](/claude-code-tmux-session-management-multi-agent-workflow/)


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
