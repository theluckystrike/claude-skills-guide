---
layout: default
title: "Speed Up Claude Code with Commands (2026)"
description: "Use Claude Code commands strategically to reduce latency, save tokens, and finish tasks faster. Practical command workflows inside."
permalink: /speed-up-claude-code-with-commands-2026/
date: 2026-04-26
---

# Speed Up Claude Code with Commands (2026)

Speed in Claude Code is not about typing faster. It is about giving Claude less unnecessary work. Every extra token of context slows response time. Every permission prompt breaks your flow. Every ambiguous instruction triggers exploratory tool calls that burn time and money.

Commands are the fastest lever you have. They execute instantly, manage context efficiently, and eliminate the overhead that accumulates during long sessions. This guide shows you how to use commands strategically for maximum speed.

For a complete command reference, visit the [Command Reference tool](/commands/).

## The Three Speed Killers

Before diving into solutions, understand what actually slows Claude Code down:

1. **Bloated context** — Large conversation histories make every API call slower and more expensive
2. **Permission interrupts** — Stopping to approve every file read or shell command breaks momentum
3. **Vague prompts** — Ambiguous instructions cause Claude to explore broadly instead of acting precisely

Commands address all three. Here is how.

## Speed Strategy 1: Aggressive Context Management

### Compact early and often

Do not wait until Claude warns you about context limits. Check your usage with `/cost` and compact proactively:

```
/cost
# If over 40% of context window: compact
/compact focus on current task only
```

A session at 80% context is measurably slower than one at 30%. The API processes the entire context on every call, so halving your context roughly halves your latency.

The focused compact is key. Writing `/compact focus on the API endpoint changes` produces a much tighter summary than bare `/compact`. Claude keeps only what you need, discarding dead-end explorations and resolved discussions.

For detailed context window strategies, see the [context window management guide](/claude-code-context-window-management-2026/).

### Clear when context is poisoned

Sometimes the conversation has gone so far off track that compacting cannot save it. Signs of poisoned context:

- Claude keeps referencing old code that you have already changed
- Responses contradict earlier decisions without acknowledging the change
- You find yourself re-explaining things Claude should already know

When this happens, `/clear` and start fresh. You lose the history but gain accurate, fast responses. The [Token Estimator](/token-estimator/) can help you understand how much context you are actually consuming.

## Speed Strategy 2: Eliminate Permission Prompts

Every permission prompt costs you 3-5 seconds of decision time plus the context switch penalty. In a typical session, you might face 20-50 prompts. That is minutes of wasted time.

### Bulk approval shortcut

When a permission prompt appears, press `a` instead of `y`. This approves all similar actions for the rest of the session. One keypress instead of fifty.

### Pre-configure permissions

For permanent speed, configure [allowedTools in your settings.json](/claude-code-permission-rules-settings-json-guide/):

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(git *)",
      "Bash(pnpm *)",
      "Bash(npm test*)"
    ]
  }
}
```

This pre-approves safe operations while still requiring approval for file writes and arbitrary shell commands. Use the [Permissions Configurator](/permissions/) to generate this configuration interactively.

## Speed Strategy 3: Custom Commands for Repeated Work

If you type the same multi-line prompt more than twice, make it a command. Create `.claude/commands/quick-fix.md`:

```markdown
Look at the error in the terminal output, identify the root cause,
and fix it. Make the minimal change necessary. Do not refactor
surrounding code. Run the relevant test after fixing.
```

Now `/quick-fix` replaces a paragraph of typing with ten characters. Across a workday with dozens of error-fix cycles, this saves meaningful time.

### High-value custom commands for speed

| Command file | Purpose | Time saved per use |
|-------------|---------|-------------------|
| `quick-fix.md` | Fix the current error minimally | 15-30 seconds |
| `test-this.md` | Run tests for the file I just changed | 10-20 seconds |
| `explain-error.md` | Explain the last error in plain English | 10-15 seconds |
| `commit-this.md` | Stage, commit with a good message | 20-30 seconds |
| `type-check.md` | Run TypeScript compiler and fix errors | 15-25 seconds |

See more examples in [10 commands you did not know](/10-claude-code-commands-you-didnt-know/).

## Speed Strategy 4: Use the Right Model

The `/model` command lets you switch models mid-session. Use faster models for simple tasks:

```
/model claude-sonnet-4
# Do quick file edits, simple searches, routine changes

/model claude-opus-4
# Switch back for complex architecture decisions, debugging
```

Sonnet responds faster and costs less. For tasks that do not require deep reasoning, it is the speed-optimal choice. The [cost optimization guide](/claude-code-cost-optimization-15-techniques/) covers model selection in detail.

## Speed Strategy 5: Non-Interactive Mode for Automation

The `-p` flag runs Claude Code as a single-shot command. No session overhead, no history loading, no permission prompts:

```bash
claude -p "Add error handling to src/api/users.ts"
claude -p "Write a unit test for the calculateTotal function"
cat error.log | claude -p "Explain this error and suggest a fix"
```

This is the fastest possible Claude Code interaction because it skips session initialization entirely. Use it in git hooks, build scripts, and quick one-off tasks.

## Try It Yourself

Open the [Command Reference](/commands/) and search for the commands mentioned in this guide. The interactive tool shows you exactly what each command does and helps you find related commands you might benefit from.

Start with these three changes today:
1. Run `/cost` before your next compact
2. Press `a` instead of `y` on the next permission prompt
3. Create one custom command for your most common task

## Speed Measurement

Track your speed improvements by noting session metrics before and after:

| Metric | Before | After |
|--------|--------|-------|
| Avg response time | Varies | Lower with regular compacting |
| Permission prompts per session | 20-50 | 0-5 with allowedTools |
| Time to repeat common tasks | 30+ seconds typing | 2 seconds with custom commands |
| Token spend per session | Higher with bloated context | Lower with proactive compacting |

Use the [Token Estimator](/token-estimator/) to quantify the before and after token usage.

## Frequently Asked Questions

**Which single command saves the most time?**

The `a` (approve all) permission shortcut, hands down. It eliminates the most frequent interruption in most workflows. For command-line commands, `/compact` with a focus parameter has the highest impact.

**Does /compact actually make responses faster?**

Yes. Claude processes the entire context window on every API call. A smaller context means faster processing. The effect is proportional: halving context roughly halves latency.

**Should I always use the fastest model?**

No. Faster models sacrifice capability. Use Sonnet for routine tasks like file edits, test writing, and simple bug fixes. Switch to Opus for architectural decisions, complex debugging, and tasks requiring deep reasoning.

**How do custom commands compare to CLAUDE.md instructions?**

CLAUDE.md instructions apply to every prompt in the session. Custom commands execute only when you invoke them. Use CLAUDE.md for always-on conventions and custom commands for on-demand workflows.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Which single command saves the most time?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The 'a' (approve all) permission shortcut eliminates the most frequent interruption in most workflows. For slash commands, /compact with a focus parameter has the highest impact."
      }
    },
    {
      "@type": "Question",
      "name": "Does /compact actually make responses faster?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Claude processes the entire context window on every API call. A smaller context means faster processing. The effect is proportional to the reduction in context size."
      }
    },
    {
      "@type": "Question",
      "name": "Should I always use the fastest model?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Faster models sacrifice capability. Use Sonnet for routine tasks like file edits and simple bug fixes. Switch to Opus for architectural decisions and complex debugging."
      }
    },
    {
      "@type": "Question",
      "name": "How do custom commands compare to CLAUDE.md instructions?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "CLAUDE.md instructions apply to every prompt in the session. Custom commands execute only when you invoke them. Use CLAUDE.md for always-on conventions and custom commands for on-demand workflows."
      }
    }
  ]
}
</script>

## Related Guides

- [Command Reference](/commands/) — Interactive command explorer
- [Every Claude Code Slash Command](/every-claude-code-slash-command-explained/) — Complete command reference
- [Token Estimator](/token-estimator/) — Forecast token usage before you start
- [Claude Code Cost Optimization](/claude-code-cost-optimization-15-techniques/) — 15 cost-saving techniques
- [Permissions Configurator](/permissions/) — Set up fast permission workflows
