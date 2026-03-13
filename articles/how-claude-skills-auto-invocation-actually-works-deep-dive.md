---
layout: default
title: "How Claude Skills Auto-Invocation Actually Works: Deep Dive"
description: "A technical deep dive into the trigger matching pipeline behind Claude skills auto-invocation — from user input to skill selection to execution."
date: 2026-03-13
author: theluckystrike
---

# How Claude Skills Auto-Invocation Actually Works: Deep Dive

When you type "can you generate some tests for this function?" and Claude Code silently invokes your `tdd` skill without you asking — that's auto-invocation. Understanding how it works helps you write skills that trigger reliably and avoid false positives that interrupt unrelated tasks.

## The High-Level Pipeline

Auto-invocation goes through five stages every time you send a message in Claude Code:

1. **Input capture** — Your message text is collected
2. **Skill candidate selection** — All loaded skills with trigger phrases are gathered
3. **Similarity scoring** — Each trigger phrase is scored against your input
4. **Threshold filtering** — Scores below the threshold are dropped
5. **Skill dispatch** — The highest-scoring skill is invoked (or none if all filtered out)

This all happens before Claude processes your message normally. If a skill fires, Claude Code switches to the skill's system prompt for that turn.

## Stage 1: Input Capture

The input is your raw message text, lowercased and stripped of leading/trailing whitespace. No tokenization happens yet. Code blocks (text wrapped in backticks) are optionally excluded from matching — this prevents "write tests for `generateInvoice()`" from triggering on the code snippet itself.

```
User input: "can you write tests for the generateInvoice function?"
Processed:  "can you write tests for the generateinvoice function?"
```

## Stage 2: Skill Candidate Selection

Claude Code maintains an in-memory registry of every loaded skill. At this stage, it filters to only skills that have at least one `triggers` entry. Skills without triggers are excluded from auto-invocation entirely — they can only be called with `/skill-name`.

Skills are ordered by their loading priority (project skills before global skills before built-ins). This order matters when two skills have similar trigger scores.

## Stage 3: Similarity Scoring

This is the core of the system and the part most developers get wrong.

Auto-invocation does **not** use simple substring matching. It uses semantic similarity via embeddings. Each trigger phrase and the user's input are independently embedded into a high-dimensional vector space, and the cosine similarity between the user input vector and each trigger phrase vector is computed.

```
trigger phrase: "write tests for"
user input:     "can you write tests for the generateInvoice function?"

cosine_similarity(embed(trigger), embed(input)) → 0.84
```

The embedding model used is a lightweight sentence transformer (not the full Claude model), so this computation is fast — typically under 10ms even for 50+ loaded skills.

### Why This Matters for Skill Design

Because matching is semantic, you don't need to enumerate every possible phrasing:

```yaml
# You don't need all these:
triggers:
  - phrase: write tests
  - phrase: create unit tests
  - phrase: generate test cases
  - phrase: make tests for

# One or two is usually enough:
triggers:
  - phrase: write tests for
  - phrase: create unit tests
```

Conversely, a trigger phrase that's too generic will match everything:

```yaml
# This will trigger on almost any development request:
triggers:
  - phrase: help me with the code
```

## Stage 4: Threshold Filtering

All similarity scores are compared against the threshold. The default threshold is **0.75**.

You can adjust this per-skill in the front matter:

```yaml
triggers:
  - phrase: generate a PDF report
    threshold: 0.85
```

A higher threshold means the trigger phrase must more precisely match the input. Use higher thresholds for skills that should only fire in very specific situations. Use lower thresholds (0.65-0.70) for skills you want to fire broadly, like a general `frontend-design` skill.

If multiple trigger phrases from the same skill exceed the threshold, the highest score is used to represent that skill.

## Stage 5: Skill Dispatch

After filtering, Claude Code has a set of (skill, score) pairs. It selects the skill with the highest score and dispatches it.

**What dispatching means:**
- The skill's front matter is merged into session settings (model override, tool restrictions, max_turns)
- The skill body becomes the system prompt for this turn
- Any `context_files` listed in the skill are loaded into the context window
- Claude processes your original message under this new configuration

If the top two skills have scores within 0.05 of each other, Claude Code may surface a disambiguation prompt: "Did you mean [skill A] or [skill B]?" This is rare in practice.

## Confidence Signals and Learning

Claude Code tracks invocation outcomes over time per project. If you consistently dismiss or override a skill invocation (by saying "no, I didn't mean that" or manually switching context), the effective threshold for that skill is raised slightly. This prevents a skill from repeatedly firing when it's not wanted.

This per-project calibration is stored in `.claude/skill-confidence.json` (not checked into git by default — add it to `.gitignore`).

## The supermemory Skill and Context Injection

The `supermemory` skill works differently from standard auto-invoked skills. Rather than replacing the system prompt, it runs as a pre-hook: it queries the memory store for relevant past context before any other skill fires.

This means `supermemory` context can actually influence which skill gets invoked next, because past conversations about your project are injected before the similarity scoring happens for the user's current message.

## Debugging Auto-Invocation

### See What Fired

Run this in your Claude Code session to see the last auto-invocation event:

```
/skills debug last
```

Output:
```
Last auto-invocation:
  Input: "can you write tests for the generateInvoice function?"
  Scores:
    tdd: 0.84 (threshold: 0.75) INVOKED
    frontend-design: 0.31
    pdf: 0.12
```

### List Active Triggers

```
/skills triggers
```

Shows all trigger phrases across all loaded skills, sorted by skill name.

### Simulate Matching

```
/skills match "your test message here"
```

Runs the matching pipeline and shows scores without actually invoking any skill. Useful for tuning trigger phrases.

## Common Auto-Invocation Problems

**Skill fires too often**: Your trigger phrase is too generic. Add a second distinguishing word or raise the threshold.

**Skill never fires**: Your trigger phrase is too specific or uses unusual vocabulary. Test with `/skills match` to see the actual scores.

**Wrong skill fires**: Two skills have overlapping trigger phrases. Review both skills' triggers, or raise the threshold on the less-relevant one.

**Skill fires on code content**: Make sure code blocks in your messages are fenced with triple backticks — Claude Code excludes fenced blocks from matching by default.

## Manual Override

You can always bypass auto-invocation by prefixing your message with `/no-skill` — this sends your message with no skill active, using the default session configuration. Alternatively, explicitly invoke a different skill with `/skill-name your message`.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
