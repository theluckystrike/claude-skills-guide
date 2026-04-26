---
layout: default
title: "Claude SuperMemory Skill (2026)"
description: "Claude SuperMemory Skill — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-03-13
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills, supermemory, persistent-context, memory]
author: "Claude Skills Guide"
reviewed: true
score: 9
permalink: /claude-supermemory-skill-persistent-context-explained/
geo_optimized: true
---

# Claude SuperMemory Skill: Persistent Context Explained

The SuperMemory skill provides persistent context across Claude Code sessions. Where a standard session starts fresh each time, SuperMemory maintains a knowledge base. project preferences, architecture decisions, coding conventions. that Claude loads automatically at the start of subsequent sessions.

## The Context Persistence Problem

When you start a new Claude session, Claude has no memory of previous conversations. For isolated tasks this is fine, but for multi-day projects it creates friction: you re-explain your stack, remind Claude of your conventions, and rebuild shared understanding every time.

Consider a realistic development scenario: you're three weeks into a project, and over that time you've made a dozen significant architectural decisions. You chose Postgres over MySQL for JSONB support. You standardized on a particular error-handling pattern after a painful debugging session. You discovered that your CI pipeline requires environment variables set in a specific order. None of this is in your codebase. it's knowledge that exists in your head and in Slack threads. Every time you start a new Claude session, you're either re-explaining all of it or working without it, and Claude's suggestions drift accordingly.

Claude Code ships with a built-in partial solution: the `CLAUDE.md` file at the root of your project. That file loads automatically on every session and is the right place for stable, long-lived project context. SuperMemory fills a different niche. it's suited for context that changes over time: solutions you discover mid-session, decisions you make during a sprint, or notes you want preserved without editing `CLAUDE.md` manually.

The distinction matters. `CLAUDE.md` is a document you maintain intentionally, with a text editor, in version control. SuperMemory is a live scratchpad you update during sessions, from inside Claude, without leaving your workflow.

## How Skills Work in Claude Code

Before diving into SuperMemory specifically, it helps to understand the skill system. Skills in Claude Code are Markdown files stored in `~/.claude/skills/`. Each skill file contains a description of its purpose, instructions for Claude on how to behave, and sometimes configuration metadata in its front matter.

When you invoke a skill with a slash command, Claude loads the skill file as additional context and begins operating according to its instructions. The skill can direct Claude to read from or write to files on your system, use its built-in tools (Read, Write, Edit, Bash), and maintain state through those file operations.

SuperMemory takes advantage of this to create a simple but effective persistence layer: it writes notes to a file between sessions and reads that file at the start of each new session.

## Invoking SuperMemory

You invoke SuperMemory with its slash command:

```
/supermemory
```

Once the skill is active, you interact with it through natural-language instructions within your Claude session. There is no separate CLI binary and no `claude code run supermemory` subcommand. the skill runs inside your Claude Code conversation.

After invoking, you can immediately start issuing memory commands. Claude will confirm what it has stored and can show you a summary of existing entries on request.

## Storing Context

After invoking the skill, tell Claude what to remember:

```
/supermemory

Remember for this project:
- Stack: React 18, TypeScript, Vite, Tailwind CSS
- Conventions: functional components only, props interfaces prefixed with component name
- Custom hooks live in /hooks, shared types in /types/index.ts
- ESLint config: airbnb-typescript preset
```

The skill stores this in a local file (typically within `~/.claude/memory/` or a project-scoped location defined in the skill's own front matter). The exact storage path depends on how the skill author configured it. check the skill's own `README` or front matter if you need the precise location.

## What to Store

Not everything deserves a SuperMemory entry. Good candidates are facts that:

- Take more than a sentence to explain
- Are not obvious from reading the codebase
- You expect to need again within days or weeks
- Changed or were decided mid-session

Poor candidates are facts that:

- Are already in your `CLAUDE.md`
- Can be inferred by reading the code
- Are in official documentation Claude already knows
- Change so frequently that stored entries become stale quickly

A practical test: if you'd write it in a sticky note on your monitor, it belongs in SuperMemory.

## Memory Entry Formats

Entries work best when they are specific and dated. Vague entries lose value fast:

```
Vague. avoid this
/supermemory

Remember we had problems with authentication.
```

```
Specific. prefer this
/supermemory

Auth issue (2026-03-15): JWT refresh tokens were expiring prematurely because
the server clock was 90 seconds ahead of the client. Fixed by adding a 120-second
clock skew tolerance in jwt.verify(). See auth/middleware.ts line 47.
```

The specific entry tells future-you (and future Claude) exactly what happened, where the fix lives, and why it was necessary.

## Practical Examples

## Multi-Session Project Development

On day one of a project, you document an architecture decision:

```
/supermemory

Architecture decision (2026-03-10): chose microservices over monolith.
Three services: auth (JWT, 1h expiry), billing (Stripe), notifications (SendGrid).
Auth service owns the user table; billing and notifications call auth's /verify endpoint.
```

When you return three days later, Claude loads this context before you type your first message. You can ask "continue the billing service" without re-explaining the architecture.

This is the core value proposition: reducing the cold-start cost of resuming a session. The more complex your project, the more valuable this becomes.

## Preserving Debugging Solutions

When you solve a non-obvious bug, store the solution:

```
/supermemory

Fix: webpack `resolve.fallback` must be set to `false` for the `fs` module in
production builds. Without this, the build throws "Module not found: Error: Can't
resolve 'fs'" for any package that optionally imports Node built-ins.
```

This prevents the same debugging session from happening twice. It also means that if you onboard a teammate who hits the same issue, you can pull this note into a `CLAUDE.md` or documentation file with minimal rewriting.

## Capturing Third-Party API Quirks

External APIs often have behavior that is not in their documentation or is buried in a GitHub issue from 2019:

```
/supermemory

Stripe webhooks (2026-03-12): the `payment_intent.succeeded` event fires before
the `charge.succeeded` event. Our fulfillment logic must listen to payment_intent,
not charge, or it races. Also: test mode webhook signatures use a different signing
secret than live mode. do not share them.
```

When you're back in this code six weeks later, Claude will already know this.

## Team Convention Notes

```
/supermemory

Branch naming: feature/TICKET-ID-short-description
PR rules: 2 approvals required, squash merge to main
CI gates: unit tests + lint + build (all must pass)
Deployment: staging auto-deploys on merge to develop; prod requires manual approval in GitHub Actions
```

## Tracking Dependencies and Their Quirks

```
/supermemory

Dependencies with known issues (as of 2026-03-14):
- date-fns v3 is incompatible with our current Webpack config; pinned to 2.30.0
- @types/node must stay at ^18.0.0 for compatibility with our Node 18 target
- react-query v5 breaks our existing devtools setup; migration deferred to Q2
```

This kind of note saves hours when a `npm update` breaks things and Claude needs to figure out why.

## SuperMemory vs CLAUDE.md

| | `CLAUDE.md` | SuperMemory skill |
|---|---|---|
| Best for | Stable project facts | Evolving notes and discoveries |
| Edited by | You (text editor) | Claude (during session) |
| Loaded | Automatically, always | When skill is active |
| Scope | Per-repo (place in project root) | Configurable; often per-user |
| Versioned | Yes (it's a tracked file) | Depends on storage path |
| Team visibility | Shared via git | Local to your machine |
| Format | Freeform Markdown | Freeform Markdown |
| Review required | No | No |

For anything you'd want in your repo's git history. tech stack, architecture overview, team conventions. `CLAUDE.md` is the better tool. SuperMemory shines for ephemeral-to-medium-term notes that don't belong in version control.

A healthy workflow treats them as a pipeline: things start in SuperMemory (discovered mid-session, unpolished) and graduate to `CLAUDE.md` once they've stabilized (confirmed, agreed on by the team, worth committing).

## When Context Should Stay in SuperMemory

Some context genuinely does not belong in `CLAUDE.md` or your codebase. Personal workflow preferences ("I prefer explanations before code, not after"), machine-specific paths, or notes about external tools that your team does not all use. these are SuperMemory material that would clutter `CLAUDE.md`.

## Combining SuperMemory with Other Skills

SuperMemory composes well with other skills. The [`tdd` skill](/best-claude-skills-for-developers-2026/) benefits from remembering where your test files live and which framework you use. The `frontend-design` skill produces better output when it already knows your component library and design tokens. The [`pdf` skill](/best-claude-skills-for-data-analysis/) can store extraction schemas so you don't re-specify column mappings for recurring document types.

Invoke both in the same session:

```
/supermemory
/tdd

Review my test coverage for src/auth.ts and remember any patterns we agree on.
```

After a productive TDD session, you might store what you learned:

```
/supermemory

Testing conventions agreed on 2026-03-15:
- Unit tests use vitest, not jest
- Integration tests live in __tests__/integration/ and require DATABASE_URL set
- Mock factories in /test/factories/. use createUser(), createProduct(), etc.
- Coverage threshold: 80% lines; CI fails below this
```

Now your next session starts with these conventions already loaded, and the `tdd` skill will apply them correctly without being told.

## Managing Stored Context Over Time

SuperMemory entries accumulate. Without occasional maintenance, your memory file grows stale and noisy. old decisions that were reversed, bug fixes that are no longer relevant, notes about dependencies you no longer use.

## Pruning Stale Entries

Periodically ask Claude to review what is stored:

```
/supermemory

Show me everything stored for this project.
```

Then remove outdated entries:

```
/supermemory

Remove the entry about webpack resolve.fallback. we migrated off webpack
to Vite in February and that no longer applies.
```

## Promoting Entries to CLAUDE.md

When a SuperMemory entry has proven durable. it's been accurate for several weeks and the whole team should know it. move it:

```
/supermemory

Move the CI gates entry to CLAUDE.md and remove it from SuperMemory.
```

Claude will read the current `CLAUDE.md`, append the entry in an appropriate section, and clean up the SuperMemory file.

## Limitations

Storage is local. Context stored on one machine does not sync to another unless you manually copy the storage file or use a shared path.

Manual, not automatic. SuperMemory only stores what you explicitly ask it to. Claude will not silently record everything you discuss. This is a feature, not a bug. implicit recording would quickly fill your memory with noise. but it means you have to remember to invoke the skill when something worth preserving comes up.

Token budget still applies. If your stored context grows very large, the skill may summarize or truncate older entries to stay within Claude's context window. Prune stale entries periodically. A good target is keeping your SuperMemory file under 1,000 words; beyond that, the signal-to-noise ratio usually drops anyway.

No official sub-commands. Unlike the hallucinated `@supermemory list` or `@supermemory export` syntax you may see in other guides, the skill operates through natural language inside Claude Code. Ask Claude to "show what's stored" or "clear the project context" and it will handle it through its normal tool use.

No encryption. Memory files are stored as plain text. Do not store secrets, credentials, API keys, or sensitive user data in SuperMemory. Use a secrets manager or environment variables for those.

## When to Use SuperMemory

SuperMemory is worth reaching for when:

- You're working on the same project across multiple sessions over days or weeks
- You want Claude to remember something you discovered mid-session without editing a file manually
- You need a scratchpad for decisions that haven't hardened into `CLAUDE.md` material yet
- You want to capture external API quirks, dependency issues, or environment-specific notes that are too machine-specific for a shared config file

For quick one-off tasks, the built-in session context is enough. Save SuperMemory for work where continuity matters.

## A Daily Workflow

A practical pattern that works well for multi-week projects:

1. Start each session with `/supermemory` to load stored context
2. Work normally
3. When you discover something worth remembering, pause and record it immediately
4. At the end of a productive session, spend two minutes reviewing what is stored and pruning anything that is no longer accurate
5. Every few weeks, promote the most stable entries to `CLAUDE.md`

This adds less than five minutes to most sessions and pays off significantly on any project that runs longer than a week.

---


**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-supermemory-skill-persistent-context-explained)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Skills Token Optimization: Reduce API Costs](/claude-skills-token-optimization-reduce-api-costs/). Complete token optimization guide
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/). Skills worth the token cost
- [Claude Skills Auto Invocation: How It Works](/claude-skills-auto-invocation-how-it-works/). How skills activate automatically
- [Claude Code Keeps Switching to Wrong File Context](/claude-code-keeps-switching-to-wrong-file-context/)
- [Fix Claude Code MCP Tools Excessive Context — Quick Guide](/claude-code-mcp-tools-excessive-context-fix/)
- [Claude Memory Feature vs SuperMemory Skill](/claude-memory-feature-vs-supermemory-skill-comparison/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

**Configure MCP →** Build your server config with our [MCP Config Generator](/mcp-config/).
