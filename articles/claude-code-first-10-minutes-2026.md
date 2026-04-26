---
layout: default
title: "Claude Code: First 10 Minutes (2026)"
description: "Get productive with Claude Code in 10 minutes. Installation, first session, essential commands, and your first real task completed."
permalink: /claude-code-first-10-minutes-2026/
date: 2026-04-26
---

# Claude Code: First 10 Minutes (2026)

You have ten minutes. By the end, you will have Claude Code installed, configured, and you will have completed your first real coding task with it. No theory. No philosophy. Just the fastest path from zero to productive.

For a guided project setup after this quickstart, use the [Project Starter tool](/starter/).

## Minute 0-2: Install

### Prerequisites

You need Node.js 18+ and an Anthropic API key.

```bash
# Check Node version
node --version
# Should show v18.x or higher

# Install Claude Code globally
npm install -g @anthropic-ai/claude-code
```

### Set your API key

```bash
export ANTHROPIC_API_KEY="sk-ant-your-key-here"
```

Add this to your `~/.zshrc` or `~/.bashrc` so it persists across terminal sessions:

```bash
echo 'export ANTHROPIC_API_KEY="sk-ant-your-key-here"' >> ~/.zshrc
source ~/.zshrc
```

## Minute 2-3: First Launch

Navigate to any project directory and start Claude Code:

```bash
cd ~/your-project
claude
```

You are now in a Claude Code session. The blinking cursor is waiting for your first instruction.

### Run /init

```
/init
```

This creates a `CLAUDE.md` file that tells Claude about your project. It scans your directory structure, detects your tech stack, and generates context. Review the output, but do not spend time editing it now — you can refine it later with guidance from our [CLAUDE.md templates](/10-claude-md-templates-project-types/).

## Minute 3-5: Essential Commands

You need to know four commands right now. Everything else can wait.

| Command | What it does | When to use it |
|---------|-------------|---------------|
| `/help` | Lists all commands | When you forget a command |
| `/cost` | Shows token usage | When you want to check spending |
| `/compact` | Compresses conversation | When responses get slow |
| `/clear` | Resets conversation | When starting a new task |

That is it. Four commands. For the complete reference, visit the [Command Reference tool](/commands/) later.

## Minute 5-8: Your First Real Task

Ask Claude to do something real in your project. Not "hello world" — something you actually need done.

### Option A: Fix a bug

```
There's a bug in src/utils/date.ts where formatDate returns
"Invalid Date" for ISO strings without timezone. Fix it and
add a test.
```

### Option B: Add a feature

```
Add a health check endpoint at GET /health that returns
{ status: "ok", timestamp: Date.now(), version: process.env.APP_VERSION }
```

### Option C: Write tests

```
Write unit tests for src/services/auth.service.ts.
Cover the happy path and error cases for login, logout, and tokenRefresh.
Use the existing test patterns in tests/ as a guide.
```

### Option D: Refactor

```
The function processOrder in src/services/order.service.ts is 200 lines long.
Break it into smaller functions, each under 50 lines, without changing behavior.
```

Claude will read the relevant files, make changes, and explain what it did. When it asks for permission to read or write files, type `a` to approve all similar actions (saves time).

## Minute 8-10: Review and Iterate

Claude made changes. Now review them:

```
Show me a diff of everything you changed
```

If something is wrong:

```
The error handling in the new validateToken function should
return a Result type, not throw. Fix that.
```

If it looks good:

```
Run the tests to make sure nothing is broken
```

## You Are Done

In ten minutes you have:
1. Installed Claude Code
2. Initialized it in your project
3. Completed a real coding task
4. Reviewed and iterated on the results

Everything from here is optimization and deeper features.

## Try It Yourself: Next Steps

The [Project Starter](/starter/) helps you set up Claude Code properly for your specific project type. It generates:
- A customized CLAUDE.md
- Permission settings for your tools
- Custom commands for your workflow

Spend ten more minutes there and your Claude Code experience will be significantly better.

## What to Learn Next

In order of impact on your productivity:

### Week 1: Permissions (save 5 minutes per session)

Configure [allowedTools](/claude-code-allowed-tools-config-2026/) so Claude does not ask permission for safe operations. The [Permissions Configurator](/permissions/) generates the right settings for your workflow.

### Week 2: Context management (save money)

Learn when to `/compact` and when to `/clear`. Check `/cost` regularly. The [context window guide](/claude-code-context-window-management-2026/) and [Token Estimator](/token-estimator/) help you manage this.

### Week 3: Custom commands (save 10 minutes per day)

Create `.claude/commands/` scripts for tasks you repeat. See the [hidden commands guide](/claude-code-hidden-commands-2026/) for examples.

### Week 4: Model switching (save 50% on tokens)

Use `/model claude-sonnet-4` for routine tasks and `/model claude-opus-4` for complex work. The [cost optimization guide](/claude-code-cost-optimization-15-techniques/) has the full strategy.

## Common First-Session Mistakes

| Mistake | Fix |
|---------|-----|
| Typing `y` for every permission prompt | Type `a` to approve all similar actions |
| Asking Claude to "understand the entire codebase" | Point Claude at specific files for your task |
| Never running /cost | Check after every 10 messages |
| Writing pages of instructions in one message | Start with one clear task, iterate |
| Ignoring the generated CLAUDE.md | Review and customize it after /init |

## Keyboard Shortcuts to Memorize Now

| Shortcut | Action |
|----------|--------|
| `Enter` | Send message |
| `Shift+Enter` | New line |
| `Up Arrow` | Previous message from history |
| `Ctrl+C` | Cancel current operation |
| `a` (at permission prompt) | Approve all similar actions |

See the [keyboard shortcuts guide](/claude-code-keyboard-shortcuts-2026/) for the complete list.

## Frequently Asked Questions

**How much does a typical session cost?**

A 30-minute session with Sonnet costs $0.20-0.80. With Opus, $1-5. Your first 10-minute session should cost under $0.50. See [how many tokens per session](/how-many-tokens-per-claude-session-2026/) for benchmarks.

**Do I need the API key, or does the Max plan work?**

Both work. With an API key, you pay per token. With the Max plan, you get included usage with rate limits. Either approach lets you use Claude Code.

**What if Claude makes a mistake?**

Tell it what is wrong and it will fix it. Claude Code works iteratively. Expect 2-3 rounds of refinement for complex tasks, similar to working with a human teammate.

**Can I use Claude Code with VS Code?**

Claude Code is a CLI tool that runs in your terminal. It works alongside any editor. Keep Claude Code in a terminal panel while editing in VS Code. There is also a VS Code extension for tighter integration.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "How much does a typical Claude Code session cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "A 30-minute session with Sonnet costs $0.20-0.80. With Opus, $1-5. A first 10-minute session should cost under $0.50."
      }
    },
    {
      "@type": "Question",
      "name": "Do I need the API key, or does the Max plan work?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Both work. With an API key you pay per token. With the Max plan you get included usage with rate limits. Either approach lets you use Claude Code."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Tell it what is wrong and it will fix it. Claude Code works iteratively. Expect 2-3 rounds of refinement for complex tasks, similar to working with a human teammate."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use Claude Code with VS Code?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code is a CLI tool that runs in your terminal. It works alongside any editor. Keep Claude Code in a terminal panel while editing in VS Code."
      }
    }
  ]
}
</script>



**Which model? →** Take the 5-question quiz in our [Model Selector](/model-selector/).

## Related Guides

- [Project Starter](/starter/) — Guided project setup after your first session
- [Command Reference](/commands/) — Complete interactive command reference
- [Token Estimator](/token-estimator/) — Track and estimate token costs
- [Permissions Configurator](/permissions/) — Set up permissions properly
- [CLAUDE.md Templates](/10-claude-md-templates-project-types/) — Optimize your project context
