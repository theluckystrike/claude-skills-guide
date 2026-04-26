---
layout: default
title: "Claude Code API Mode vs Interactive (2026)"
description: "Compare Claude Code API mode and interactive mode for CI/CD automation, batch processing, and when to use each for maximum efficiency."
permalink: /claude-code-api-mode-vs-interactive-2026/
date: 2026-04-20
last_tested: "2026-04-22"
render_with_liquid: false
---

# Claude Code API Mode vs Interactive Mode (2026)

Claude Code runs in two modes: interactive (terminal conversation) and API (headless, scriptable). Choosing the wrong mode wastes time on manual approvals or misses opportunities for automation.

## Mode Comparison

| Feature | Interactive | API Mode |
|---------|-----------|----------|
| Interface | Terminal conversation | Headless CLI |
| Approval | Manual per action | Pre-approved |
| Slash commands | Yes | No |
| CLAUDE.md | Yes | Yes |
| Hooks | Yes | Yes |
| MCP servers | Yes | Yes |
| Best for | Exploration, complex tasks | Automation, CI/CD, batch |

## Interactive Mode

Interactive mode is the default. You type a message, Claude Code responds, and you approve or reject each action.

```bash
claude
```

### Strengths
- Full control over every action
- Can course-correct in real time
- Slash commands available
- Best for unfamiliar or risky tasks

### Weaknesses
- Requires constant attention
- Cannot run unattended
- Slower for repetitive tasks
- Not suitable for CI/CD pipelines

### When to Use
- Exploring a new codebase
- Complex refactoring with many decisions
- Tasks where you want to review each change
- Learning Claude Code's behavior for new project types

## API Mode

API mode runs Claude Code without interactive prompts. It executes a task and returns the result.

```bash
claude -p "Add input validation to the signup form" --allowedTools "Edit,Read,Bash"
```

### Key Flags
- `-p` or `--prompt`: The task instruction (non-interactive)
- `--allowedTools`: Which tools Claude Code can use without asking
- `--output-format`: Output format (text, json, stream-json)
- `--max-turns`: Maximum number of tool-use turns

### Strengths
- Runs unattended
- Scriptable and composable
- Works in CI/CD pipelines
- Batch processing friendly

### Weaknesses
- No real-time oversight
- Must pre-approve tool access
- Cannot course-correct mid-task
- Slash commands not available

### When to Use
- CI/CD code review automation
- Batch file processing
- Generating boilerplate for multiple components
- Automated test generation
- Documentation generation from code

## API Mode in CI/CD

### GitHub Actions Example

{% raw %}
```yaml
name: AI Code Review
on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Review PR changes
        run: |
          claude -p "Review the changes in this PR for security issues and code quality. Output a structured review." \
            --allowedTools "Read,Bash" \
            --output-format text > review.txt
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
      - name: Post review comment
        run: gh pr comment ${{ github.event.number }} --body-file review.txt
```
{% endraw %}

### Batch Processing Example

Process multiple files with a shell loop:

```bash
for file in src/components/*.tsx; do
  claude -p "Add JSDoc comments to all exported functions in $file" \
    --allowedTools "Read,Edit" \
    --max-turns 10
done
```

### Test Generation Example

```bash
claude -p "Generate Vitest unit tests for src/services/billing.ts. Cover happy path, edge cases, and error conditions." \
  --allowedTools "Read,Write,Bash" \
  --output-format text
```

## Combining Modes

Many teams use both modes in their workflow:

1. **Interactive:** Developer writes feature with Claude Code guidance
2. **API mode:** CI runs automated review on the PR
3. **Interactive:** Developer addresses review feedback
4. **API mode:** CI generates documentation for the merged changes

## CLAUDE.md in API Mode

CLAUDE.md files are read in both modes. Your project rules, architecture definitions, and coding conventions apply regardless of how Claude Code is invoked.

The [claude-task-master](https://github.com/eyaltoledano/claude-task-master) (27K+ stars) integrates with API mode for structured task execution:

```bash
task-master run --task 5 --ai claude-api
```

## Security in API Mode

API mode deserves extra security attention because it runs unattended:

- **Restrict `--allowedTools`** to only what the task needs (Read,Edit — not Bash)
- **Use `--max-turns`** to prevent runaway sessions
- **Review outputs** before merging or deploying
- **Set cost limits** on the API key
- **Do not grant write access** to production configurations

The [claude-code-ultimate-guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide) threat model section covers API mode security in detail.

## Output Formats

### Text (Default)
```bash
claude -p "Explain this function" --output-format text
```
Returns plain text. Good for human-readable output and PR comments.

### JSON
```bash
claude -p "List all TODO comments" --output-format json
```
Returns structured JSON. Good for piping into other tools.

### Stream JSON
```bash
claude -p "Refactor this module" --output-format stream-json
```
Returns JSON events as they happen. Good for real-time monitoring of long tasks.

## FAQ

### Can API mode run slash commands?
No. Slash commands require interactive input. Use the prompt flag (-p) with the full instructions instead.

### Is API mode cheaper?
Token costs are the same. API mode may use fewer tokens because there is no back-and-forth conversation, but it may use more tokens if the task is ambiguous (no opportunity to clarify).

### Can I mix modes in one session?
No. A session is either interactive or API mode. You can run sequential sessions of different modes on the same project.

### What happens if API mode makes a mistake?
Use git to review and revert changes. This is why API mode should always run on a branch, not on main. The [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) principle of "Surface Tradeoffs" is especially important when configuring unattended runs.

For CI/CD integration patterns, see the [CI/CD guide](/claude-code-ci-cd-integration-guide-2026/). For cost optimization in automated runs, read the [pricing guide](/claude-code-pricing-plans-comparison-2026/). For security in automated workflows, see the [threat model guide](/claude-code-security-threat-model-2026/).




**Set it up →** Build your permission config with our [Permission Configurator](/permissions/).

## Related

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code hooks](/claude-code-hooks-complete-guide/) — hook into API mode tool execution
- [Claude Code spec workflow](/claude-code-spec-workflow-guide/) — feed specs into API mode
- [Claude Agent SDK](/claude-agent-sdk-complete-guide/) — build custom agents with the SDK
- [--dangerously-skip-permissions flag](/claude-dangerously-skip-permissions-flag/) — Understanding the --dangerously-skip-permissions CLI flag
- [Interactive Rebase Unsupported Error Fix](/claude-code-interactive-rebase-unsupported-fix-2026/)
