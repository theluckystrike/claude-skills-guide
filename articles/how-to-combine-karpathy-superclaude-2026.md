---
layout: default
title: "Combine Karpathy Skills + SuperClaude (2026)"
description: "Run Karpathy's 4 behavioral principles alongside SuperClaude's 30 commands without conflicts. Step-by-step integration with conflict resolution tips."
permalink: /how-to-combine-karpathy-superclaude-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# How to Combine Karpathy Skills + SuperClaude (2026)

Karpathy Skills gives Claude better judgment. SuperClaude gives Claude structured commands. Together, they create an agent that reasons well and has specialized tools. Here is how to run both without conflicts.

## Prerequisites

- Claude Code installed
- Python 3.10+ with pipx (for SuperClaude)
- A project directory

## Step 1: Install SuperClaude

```bash
pipx install superclaude
superclaude install
```

Verify SuperClaude is active:
```bash
claude
# Type /help — should list 30+ commands
```

## Step 2: Add Karpathy Skills

Download the Karpathy CLAUDE.md:

```bash
curl -o /tmp/karpathy.md https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md
```

Do NOT overwrite your existing CLAUDE.md — SuperClaude may have added content to it. Instead, prepend Karpathy's principles:

```bash
cd /path/to/your/project

# Back up current CLAUDE.md
cp CLAUDE.md CLAUDE.md.backup

# Prepend Karpathy principles
cat /tmp/karpathy.md > CLAUDE.md.combined
echo "" >> CLAUDE.md.combined
echo "---" >> CLAUDE.md.combined
echo "" >> CLAUDE.md.combined
cat CLAUDE.md.backup >> CLAUDE.md.combined
mv CLAUDE.md.combined CLAUDE.md
```

## Step 3: Resolve Potential Conflicts

Karpathy's "Don't Assume" principle and SuperClaude's "autonomous" mode can conflict. In autonomous mode, Claude is supposed to make decisions independently. "Don't Assume" tells Claude to ask questions.

Resolution: add a priority rule to your CLAUDE.md:

```markdown
# Priority Rules
- When in autonomous mode (/mode autonomous), Karpathy's "Don't Assume" is relaxed — make reasonable assumptions and document them rather than asking questions.
- In all other modes, follow "Don't Assume" strictly.
```

## Step 4: Test the Integration

Start Claude Code and verify both systems work:

```bash
claude
```

**Test Karpathy**: Give an ambiguous task:
```
Add caching to the API
```
Claude should ask clarifying questions (Don't Assume principle).

**Test SuperClaude**: Use a slash command:
```
/review
```
Claude should perform a structured code review (SuperClaude's review agent).

**Test both together**: Switch to careful mode and give an ambiguous architecture task:
```
/mode careful
Design the notification system
```
Claude should ask clarifying questions (Karpathy) while following careful mode's thorough approach (SuperClaude).

## Step 5: Fine-Tune the Balance

After a week of use, adjust the integration based on your experience:

- If Claude asks too many questions in autonomous mode, strengthen the priority rule
- If Claude does not surface tradeoffs during `/architect` sessions, add an explicit reminder
- If mode switching feels inconsistent, document which Karpathy principles apply in each mode

## Per-Mode Principle Mapping

Not every Karpathy principle applies equally in every SuperClaude mode. Here is a practical mapping:

| SuperClaude Mode | Don't Assume | Don't Hide Confusion | Surface Tradeoffs | Goal-Driven |
|---|---|---|---|---|
| careful | Full strength | Full strength | Full strength | Full strength |
| fast | Relaxed (assume and note) | Brief flag only | Skip unless critical | Full strength |
| teaching | Full strength | Full strength | Expand with explanation | Full strength |
| pair | Full strength | Full strength | Full strength | Full strength |
| autonomous | Assume and document | Brief flag only | Note, don't block | Full strength |
| review | Full strength | Full strength | Full strength | Full strength |
| planning | Full strength | Full strength | Full strength | Full strength |

Add this mapping to your CLAUDE.md so Claude knows how to blend the two systems contextually.

## Example Combined Session

Here is what a typical session looks like with both active:

```
You: /mode careful
Claude: Switched to careful mode.

You: /architect
Claude: Architecture agent active. What system should I design?

You: Design a notification service
Claude: Before I design the notification system, I have several questions
(Don't Assume):
1. What notification channels — email, push, SMS, in-app?
2. What volume — hundreds or millions per day?
3. What latency requirements — real-time or batch acceptable?

Also, I want to flag (Surface Tradeoffs): building all channels from scratch
vs using a service like Twilio/SendGrid involves significant cost-complexity
tradeoffs that will shape the architecture.
```

The Karpathy principles enhance every SuperClaude command by improving the reasoning quality within the structured workflow.

## Troubleshooting

**SuperClaude commands missing after adding Karpathy**: You may have overwritten SuperClaude's CLAUDE.md additions. Restore from backup and use the prepend method in Step 2. Always back up before modifying CLAUDE.md.

**Conflicting behaviors**: When Claude's behavior seems confused, it is usually a precedence issue. Put Karpathy principles at the top (highest priority), SuperClaude config below, and project-specific rules at the bottom. Claude reads CLAUDE.md top to bottom and earlier rules take priority.

**Performance feels slower**: Both systems add to the CLAUDE.md size, which consumes context tokens. If the combined file exceeds 500 lines, trim project-specific sections that are less important. The Karpathy section is only about 200 lines, so it adds minimal overhead.

**Claude asks too many questions**: In fast or autonomous mode, Claude should minimize questions. If it is still asking frequently, strengthen the priority rule from Step 3 with more explicit language about which modes relax which principles.

## Next Steps

- Compare the [workflow approaches](/superclaude-vs-karpathy-skills-workflow-2026/) in detail
- Add [custom hooks](/understanding-claude-code-hooks-system-complete-guide/) that complement both tools
- Explore the [Claude Code playbook](/playbook/) for workflow patterns
- Browse the [skills directory](/claude-skills-directory-where-to-find-skills/) for additional behavioral plugins
