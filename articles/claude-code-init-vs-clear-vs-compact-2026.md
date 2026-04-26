---
layout: default
title: "Claude Code /init vs /clear vs /compact (2026)"
description: "When to use /init, /clear, and /compact in Claude Code. Side-by-side comparison with decision flowchart and real examples."
permalink: /claude-code-init-vs-clear-vs-compact-2026/
date: 2026-04-26
---

# Claude Code /init vs /clear vs /compact (2026)

Three commands. Three completely different purposes. Yet developers constantly confuse them, using `/clear` when they mean `/compact`, or running `/init` when they should not. Each command solves a distinct problem, and using the wrong one wastes time or destroys context you need.

Here is exactly when to use each one. For the full interactive reference, see the [Command Reference tool](/commands/).

## Quick Comparison

| Feature | /init | /clear | /compact |
|---------|-------|--------|----------|
| Purpose | Create project context | Reset conversation | Compress conversation |
| Affects conversation | No | Deletes everything | Summarizes and continues |
| Affects files | Creates/overwrites CLAUDE.md | No | No |
| Token cost | Small (one-time generation) | Zero | Medium (summarization call) |
| Reversible | Yes (edit CLAUDE.md) | No | Partially (summary may lose details) |
| When to use | Project setup or refresh | Conversation is broken | Context window is filling up |

## /init: Project Setup

The `/init` command creates a `CLAUDE.md` file in your current directory. This file is project context that Claude reads at the start of every session.

```
/init
```

**What it does:**
1. Scans your project structure (files, directories, package.json, etc.)
2. Identifies the language, framework, and build system
3. Generates a `CLAUDE.md` with project description, key files, build commands, and conventions
4. Saves the file to your project root

**When to use /init:**
- Starting a brand new project with Claude Code
- Joining an existing project that has no `CLAUDE.md`
- After major refactoring that changed the project structure significantly

**When NOT to use /init:**
- Mid-conversation when you want to "reset" (use `/clear` instead)
- When your context window is full (use `/compact` instead)
- On a project with a carefully curated `CLAUDE.md` (it will overwrite your edits)

The generated `CLAUDE.md` is a starting point. Always review and customize it. See [CLAUDE.md templates for every project type](/10-claude-md-templates-project-types/) for guidance on what makes a good context file.

## /clear: Nuclear Reset

The `/clear` command deletes your entire conversation history. Every message, every code change discussion, every decision — gone.

```
/clear
```

**What it does:**
1. Wipes all conversation messages from memory
2. Reloads `CLAUDE.md` and any active memory entries
3. Starts a fresh conversation in the same terminal session

**When to use /clear:**
- The conversation has gone completely off track and compacting will not help
- Claude keeps referencing deleted code or reversed decisions
- You are switching to a completely different task in the same project
- Context is "poisoned" with incorrect assumptions

**When NOT to use /clear:**
- When you just want to reduce token usage (use `/compact`)
- When you have important decisions in the conversation you want to preserve
- As a habit at the start of each task (wasteful if context is clean)

The key indicator for `/clear` over `/compact` is whether the existing context is actively harmful. If Claude keeps making mistakes because of stale context, clearing is faster than trying to compact around the bad data.

For more detail on this decision, see [/compact vs /clear: when to use each](/claude-code-compact-vs-clear-when-to-use/).

## /compact: Smart Compression

The `/compact` command summarizes your conversation into a shorter form without losing the thread. Claude rewrites the history, keeping key decisions and discarding noise.

```
/compact
/compact focus on the payment integration
/compact preserve error handling decisions, drop exploration
```

**What it does:**
1. Claude reads the full conversation history
2. Generates a compressed summary that captures the essential state
3. Replaces the history with the summary
4. Continues the conversation from the compressed state

**When to use /compact:**
- Token usage is climbing (check with `/cost`)
- Response times are getting slower
- You have hit 40-60% of the context window
- After completing a sub-task within a larger project

**When NOT to use /compact:**
- When you need exact code snippets from earlier in the conversation
- When the conversation is already short (minimal savings)
- When the entire context is wrong (use `/clear` instead)

The focused variant (`/compact focus on X`) is almost always better than bare `/compact`. It tells Claude what matters, preventing it from discarding important details about your current priority. Monitor your usage with the [Token Estimator](/token-estimator/).

## Decision Flowchart

Use this when you are not sure which command to run:

```
Start
  |
  v
Is this a new project or major restructure?
  |
  Yes → /init
  No ↓
  |
  v
Is the conversation actively causing wrong results?
  |
  Yes → /clear
  No ↓
  |
  v
Is the context window filling up (/cost shows > 40%)?
  |
  Yes → /compact [focus on current task]
  No ↓
  |
  v
Keep working. No command needed.
```

## Real-World Scenarios

### Scenario 1: Starting a new feature

You just cloned a repo and want Claude to help build a new API endpoint.

**Correct sequence:** `/init` (if no CLAUDE.md exists), then start working. Do not `/clear` or `/compact` because there is nothing to clear or compress.

### Scenario 2: Context window at 70% mid-task

You have been working for an hour. Responses are getting slow. You still need context about what you have built.

**Correct command:** `/compact focus on the API endpoint implementation`

This preserves your work while freeing context space. `/clear` would be wrong because you would lose all context about the current task.

### Scenario 3: Claude keeps using your old approach

You abandoned approach A thirty minutes ago and switched to approach B. But Claude keeps suggesting approach-A patterns.

**Correct command:** `/clear`, then re-explain approach B in one message.

Compacting might keep traces of approach A in the summary. A clean start with a clear statement of the current approach is faster.

### Scenario 4: Switching tasks in the same project

You finished the API endpoint and now want to work on the frontend.

**Correct command:** `/compact focus on project structure only` or `/clear` if the previous task is completely irrelevant.

## Common Mistakes

**Running /init repeatedly** — Each run overwrites your `CLAUDE.md`. If you have customized it, running `/init` again loses those customizations. Back up first or skip it.

**Using /clear as a performance fix** — If responses are slow because of context size, `/compact` solves the problem without losing everything. Only `/clear` when context is wrong, not just large.

**Never compacting** — Some developers work until they hit the context limit, then `/clear` and start over. Regular `/compact` commands (every 30-40 minutes in active sessions) prevent this.

## Try It Yourself

Open the [Command Reference](/commands/) and search for these three commands side by side. The interactive tool shows usage examples and helps you understand when each command applies to your situation.

Start practicing the decision flowchart above. Within a week, choosing the right command becomes instinctive.

## Frequently Asked Questions

**Can I undo a /clear?**

No. Once you clear, the conversation history is permanently deleted. If you might need the context later, use `/compact` instead or copy important information before clearing.

**Does /compact cost tokens?**

Yes. The summarization requires an API call that consumes tokens. However, the cost is typically small compared to the tokens you save by having a compressed context for all subsequent interactions.

**Should I run /init every session?**

No. Run `/init` once when setting up a project. After that, Claude automatically reads the existing `CLAUDE.md` at session start. Only re-run if your project structure has changed dramatically.

**What if /compact drops information I needed?**

Use the focused variant: `/compact preserve [specific topic]`. If critical information was lost, you can re-state it in your next message. The [context window management guide](/claude-code-context-window-management-2026/) has strategies for preventing this.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Can I undo a /clear?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Once you clear, the conversation history is permanently deleted. If you might need the context later, use /compact instead or copy important information before clearing."
      }
    },
    {
      "@type": "Question",
      "name": "Does /compact cost tokens?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. The summarization requires an API call that consumes tokens. However, the cost is typically small compared to the tokens saved by having a compressed context for subsequent interactions."
      }
    },
    {
      "@type": "Question",
      "name": "Should I run /init every session?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Run /init once when setting up a project. Claude automatically reads the existing CLAUDE.md at session start. Only re-run if your project structure has changed dramatically."
      }
    },
    {
      "@type": "Question",
      "name": "What if /compact drops information I needed?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Use the focused variant: /compact preserve [specific topic]. If critical information was lost, re-state it in your next message."
      }
    }
  ]
}
</script>

## Related Guides

- [Command Reference](/commands/) — Interactive command explorer
- [/compact vs /clear: When to Use](/claude-code-compact-vs-clear-when-to-use/) — Detailed two-command comparison
- [CLAUDE.md Templates](/10-claude-md-templates-project-types/) — Project context templates
- [Context Window Management](/claude-code-context-window-management-2026/) — Full context strategy guide
- [Token Estimator](/token-estimator/) — Check your current token usage
