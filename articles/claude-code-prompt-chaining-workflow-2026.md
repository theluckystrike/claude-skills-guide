---
layout: post
title: "Claude Code Prompt Chaining Workflow (2026)"
description: "Chain multiple Claude prompts into automated workflows. Sequential execution, conditional branching, and output piping with shell scripts."
permalink: /claude-code-prompt-chaining-workflow-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---
{% raw %}

## The Workflow

Build automated multi-step workflows by chaining Claude Code prompts together using shell scripts. Each prompt's output feeds into the next, enabling complex tasks like "analyze code, write tests, then generate documentation" in a single automated pipeline.

Expected time: 15-25 minutes to build a reusable chain
Prerequisites: Claude Code installed, bash or zsh shell, basic shell scripting knowledge

## Setup

### 1. Create a Chains Directory

```bash
mkdir -p ~/claude-chains && cd ~/claude-chains
```

### 2. Verify Claude Code Non-Interactive Mode

```bash
claude --print "echo hello" 2>/dev/null && echo "OK"
# Expected output:
# echo hello
# OK
```

The `--print` flag runs Claude in non-interactive mode and outputs the response to stdout, which is essential for piping between steps.

### 3. Create a Chain Runner Script

```bash
cat > ~/claude-chains/run-chain.sh << 'SCRIPT'
#!/bin/bash
set -euo pipefail

# Chain runner: executes prompts sequentially, piping output
CHAIN_DIR="${1:?Usage: run-chain.sh <chain-directory>}"
WORK_DIR="${2:-$(pwd)}"
LOG_FILE="${CHAIN_DIR}/chain-$(date +%Y%m%d-%H%M%S).log"

echo "=== Chain started: $(date) ===" | tee "$LOG_FILE"
echo "Working directory: $WORK_DIR" | tee -a "$LOG_FILE"

STEP=0
PREV_OUTPUT=""

for prompt_file in "$CHAIN_DIR"/step-*.md; do
  [ -f "$prompt_file" ] || continue
  STEP=$((STEP + 1))
  STEP_NAME=$(basename "$prompt_file" .md)

  echo "--- Step $STEP: $STEP_NAME ---" | tee -a "$LOG_FILE"

  # Read prompt template and inject previous output
  PROMPT=$(cat "$prompt_file")
  if [ -n "$PREV_OUTPUT" ]; then
    PROMPT=$(echo "$PROMPT" | sed "s|{{PREV_OUTPUT}}|$PREV_OUTPUT|g")
  fi

  # Execute with Claude Code
  PREV_OUTPUT=$(cd "$WORK_DIR" && claude --print "$PROMPT" 2>>"$LOG_FILE")

  echo "$PREV_OUTPUT" | tee -a "$LOG_FILE"
  echo "" | tee -a "$LOG_FILE"
done

echo "=== Chain complete: $STEP steps ===" | tee -a "$LOG_FILE"
SCRIPT
chmod +x ~/claude-chains/run-chain.sh
```

## Usage Example

Build a chain that analyzes a codebase, identifies issues, writes fixes, and generates a summary report:

```bash
mkdir -p ~/claude-chains/code-review-chain
```

Create step files:

```markdown
<!-- ~/claude-chains/code-review-chain/step-01-analyze.md -->
Analyze the current project structure and code quality.
List the top 5 issues found, ranked by severity.
For each issue provide:
- File path
- Line number range
- Issue description
- Severity (critical/high/medium/low)
Output as a numbered list, nothing else.
```

```markdown
<!-- ~/claude-chains/code-review-chain/step-02-fix-plan.md -->
Based on this analysis:
{{PREV_OUTPUT}}

For the top 3 issues by severity, write a specific fix plan.
Include the exact file to edit, the current problematic code,
and the corrected replacement code.
Output as markdown code blocks with file paths as headers.
```

```markdown
<!-- ~/claude-chains/code-review-chain/step-03-report.md -->
Based on this fix plan:
{{PREV_OUTPUT}}

Generate a markdown report with:
1. Executive summary (2 sentences)
2. Issues found table (severity, file, description)
3. Fixes applied section with before/after code
4. Remaining recommendations

Save the report to ./code-review-report.md
```

Run the chain:

```bash
~/claude-chains/run-chain.sh ~/claude-chains/code-review-chain /path/to/project
```

For conditional branching, use an advanced chain runner:

```bash
cat > ~/claude-chains/conditional-chain.sh << 'SCRIPT'
#!/bin/bash
set -euo pipefail

PROJECT_DIR="${1:?Usage: conditional-chain.sh <project-dir>}"
cd "$PROJECT_DIR"

# Step 1: Detect project type
PROJECT_TYPE=$(claude --print "Look at this project and respond with exactly one word: 'node', 'python', 'rust', 'go', or 'other'")
echo "Detected project type: $PROJECT_TYPE"

# Step 2: Branch based on type
case "$PROJECT_TYPE" in
  node|Node)
    TEST_CMD="npm test"
    LINT_CMD="npx eslint src/"
    ;;
  python|Python)
    TEST_CMD="pytest"
    LINT_CMD="ruff check ."
    ;;
  rust|Rust)
    TEST_CMD="cargo test"
    LINT_CMD="cargo clippy"
    ;;
  go|Go)
    TEST_CMD="go test ./..."
    LINT_CMD="golangci-lint run"
    ;;
  *)
    echo "Unknown project type: $PROJECT_TYPE"
    exit 1
    ;;
esac

# Step 3: Run tests and capture output
echo "Running tests with: $TEST_CMD"
TEST_OUTPUT=$($TEST_CMD 2>&1 || true)

# Step 4: Feed test results to Claude for analysis
ANALYSIS=$(claude --print "These are the test results for a $PROJECT_TYPE project:

$TEST_OUTPUT

Summarize: how many tests passed, how many failed, and what are the failing test names. If all passed, just say 'All tests passed.'")

echo "$ANALYSIS"

# Step 5: If failures, ask Claude to fix them
if echo "$ANALYSIS" | grep -qi "fail"; then
  echo "Failures detected. Requesting fixes..."
  claude --print "Fix the failing tests identified in this analysis:
$ANALYSIS

Read the test files, understand the failures, and apply minimal fixes."
else
  echo "All tests passed. Running linter..."
  LINT_OUTPUT=$($LINT_CMD 2>&1 || true)
  claude --print "Review these lint results and fix the top 3 issues:
$LINT_OUTPUT"
fi
SCRIPT
chmod +x ~/claude-chains/conditional-chain.sh
```

## Common Issues

- **Output truncation in pipes:** Claude's `--print` output can be large. Use temp files instead of shell variables for outputs over 100KB: `claude --print "..." > /tmp/step-output.txt`.
- **Special characters break sed substitution:** The `{{PREV_OUTPUT}}` replacement uses sed, which chokes on `/` and `&` in code output. Use `awk` instead: `awk -v replacement="$PREV_OUTPUT" '{gsub(/\{\{PREV_OUTPUT\}\}/, replacement)}1' "$prompt_file"`.
- **Chain fails mid-way:** The `set -e` flag halts on any error. Add `|| true` after non-critical steps, or wrap individual steps in their own error handling.

## Why This Matters

Single prompts hit complexity limits. Chaining breaks complex tasks into focused steps where each prompt does one thing well. A 5-step chain can accomplish what would require 20 minutes of manual back-and-forth.

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code Batch Processing: Queue Prompts 2026](/claude-code-batch-processing-queue-prompts-2026/)
- [Claude Opus Orchestrator Sonnet Worker Architecture](/claude-opus-orchestrator-sonnet-worker-architecture/)
- [Claude Code Tmux Session Management Multi-Agent Workflow](/claude-code-tmux-session-management-multi-agent-workflow/)

## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


## Best Practices

1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency.

2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed.

3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions.

4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops).

5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like "refactor auth, add tests, and update docs" produce better results when broken into three separate prompts, each building on the previous result.


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a CLAUDE.md file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring .claude/settings.json for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your .claude/ directory and CLAUDE.md to version control so the entire team uses the same configuration. Each developer can add personal preferences in ~/.claude/settings.json (user-level) without affecting the project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation."
      }
    }
  ]
}
</script>

{% endraw %}
