---
layout: default
title: "Claude Auto-Memory vs Supermemory Skill (2026)"
description: "Compare Claude Code's native auto-memory (MEMORY.md, 200-line limit) with Supermemory-style skills for persistent knowledge."
permalink: /claude-memory-vs-supermemory-skill/
date: 2026-04-20
categories: [skills, 2026]
tags: [claude-code, claude-skills, memory, supermemory, comparison]
last_updated: 2026-04-19
---

## The Specific Situation

After 50 sessions with Claude Code, you notice it still asks about your project's deployment process, forgets your testing preferences, and re-discovers the same code patterns. You want persistent memory across sessions. Claude Code has built-in auto-memory (MEMORY.md files). Third-party skills and MCP servers like Supermemory promise richer knowledge management. Which approach gives you the persistence you need?

## Technical Foundation

**Claude Code Auto-Memory** is a built-in feature (v2.1.59+) that writes notes to MEMORY.md files based on corrections and preferences observed during sessions. Memory files are stored at `~/.claude/projects/<project>/memory/MEMORY.md` with an index that is loaded at session start (first 200 lines or 25KB). Topic files are read on demand. Memory is toggled with `/memory` or the `autoMemoryEnabled` setting. Claude writes these notes itself -- you do not manually edit them (though you can).

**Supermemory-style skills** are custom skills or MCP server integrations that store and retrieve knowledge from external databases (vector stores, SQLite, cloud storage). They provide explicit save/recall commands, semantic search across stored knowledge, and no hard size limits. Examples include MCP servers like `memory` or custom skills that read/write to a local JSON knowledge base.

## The Working SKILL.md

Custom persistent memory skill:

```yaml
---
name: project-memory
description: >
  Persistent project knowledge base. Use when saving decisions,
  architecture choices, debugging findings, or project conventions
  that should survive across all sessions. Stores as structured
  JSON with semantic tags for retrieval.
allowed-tools: Read Bash(python3 *)
---

# Project Memory Skill

## Save a Memory
When the user says "remember this" or you discover something
important about the project, save it:

1. Read current knowledge base from `data/project-memory.json`
2. Add new entry with:
   - `id`: Incrementing integer
   - `timestamp`: ISO-8601
   - `category`: architecture | convention | debugging | decision | preference
   - `tags`: Array of relevant keywords
   - `content`: The information to remember
   - `context`: What prompted this memory (file, error, conversation)
3. Write updated JSON back to `data/project-memory.json`

## Recall Memories
When you need project context, search the knowledge base:

1. Read `data/project-memory.json`
2. Filter by category and/or tags matching the current context
3. Return relevant memories sorted by timestamp (newest first)
4. Limit to 10 most relevant entries to avoid context overload

## Memory Schema
```json
{
  "memories": [
    {
      "id": 1,
      "timestamp": "2026-04-15T10:30:00Z",
      "category": "architecture",
      "tags": ["database", "migration", "postgres"],
      "content": "Database migrations must run idempotently. Use IF NOT EXISTS for all CREATE statements.",
      "context": "Discovered during failed migration on staging"
    }
  ]
}
```

## Automatic Memory Triggers
Save a memory automatically when:
- A bug is resolved (save root cause and fix)
- A deployment succeeds or fails (save what changed)
- A code review reveals a project convention
- User explicitly corrects Claude's behavior
```

## Where Auto-Memory Wins

**1. Zero setup.** Auto-memory works out of the box. Toggle it on with `/memory` and Claude starts accumulating knowledge. No skill to write, no database to configure, no schema to design. For most developers, this is all the persistence they need.

**2. Automatic capture.** Claude detects corrections ("No, we use tabs not spaces") and saves them without explicit commands. You do not need to say "remember this" -- Claude recognizes patterns that should persist. Supermemory skills require explicit save commands or trigger rules.

**3. Integrated with compaction.** Auto-memory's MEMORY.md survives compaction and session restarts because it is read from disk at session start. Custom memory skills must be explicitly invoked to load stored knowledge, which may be forgotten after compaction unless the skill is set to auto-invoke.

## Where Supermemory-Style Skills Win

**1. Structured knowledge with search.** Auto-memory produces a flat markdown file. A Supermemory skill stores structured entries with categories, tags, and timestamps, enabling filtered retrieval: "show me all debugging memories tagged with 'postgres'." Auto-memory's 200-line limit makes broad search impractical.

**2. No size limits.** Auto-memory loads the first 200 lines or 25KB of MEMORY.md. A custom memory skill backed by a JSON file, SQLite database, or vector store has no inherent limit. Projects with extensive institutional knowledge (hundreds of decisions, conventions, debugging findings) will outgrow auto-memory.

**3. Shareable across team members.** Auto-memory is personal (`~/.claude/projects/...`). A memory skill that stores knowledge in the project repository (`.claude/data/project-memory.json`) is version-controlled and shared with the team. New developers get all accumulated knowledge on their first clone.

**4. Semantic retrieval.** MCP-based memory servers can use vector embeddings for semantic search: "what do we know about authentication?" finds relevant memories even if "authentication" is not in the exact text. Auto-memory relies on Claude's contextual matching against the flat MEMORY.md text.

## Hybrid Use Case

Use auto-memory for personal preferences and corrections: "I prefer 2-space indentation," "don't suggest console.log for debugging." Use a custom memory skill for project knowledge: architecture decisions, deployment procedures, debugging findings, resolved incidents.

```
Auto-memory (personal, ~/.claude/projects/):
  - "User prefers TypeScript strict mode"
  - "Always run pnpm, not npm"
  - "Code review should check error handling first"

Custom memory skill (project, .claude/data/):
  - Architecture decision: "We use event sourcing for the orders domain"
  - Debugging finding: "Redis connection timeout is caused by missing REDIS_SENTINEL config"
  - Convention: "All API responses must include request_id header"
```

## Common Problems and Fixes

**Auto-memory becomes a dumping ground.** Claude saves low-value observations alongside high-value corrections. Periodically review `~/.claude/projects/<project>/memory/MEMORY.md` and remove irrelevant entries. Claude also provides `/memory` to view and manage what is stored.

**Custom memory skill forgets to save.** The skill is not auto-invocable, so Claude does not save memories unless you explicitly invoke it. Set `user-invocable: false` so the skill description is always in context, and add clear `when_to_use` triggers in the description.

**Memory file grows beyond context limits.** A 500-entry JSON memory file is 50KB+ and exceeds the 25KB auto-memory limit. The custom skill must implement pagination: load only entries matching the current context (by category or tags), not the entire file.

**Conflicting memories.** Auto-memory says "use 2-space indentation" but a custom memory entry says "this project uses 4-space indentation." The custom project memory should take precedence. Document this hierarchy in the skill's instructions.

## Claude-Mem: The Memory Command and Shorthand

The term "claude-mem" refers to Claude Code's `/memory` command and the MEMORY.md file system that powers it. When developers search for "claude-mem," they are looking for how to manage Claude's persistent memory from the command line.

The `/memory` command (or `claude-mem` as it is commonly abbreviated in developer shorthand) does three things:

1. **View current memories** — running `/memory` displays what Claude has stored about your project and preferences
2. **Toggle auto-memory** — enables or disables automatic memory capture during sessions
3. **Edit memories** — opens the MEMORY.md file for manual editing

The MEMORY.md file lives at `~/.claude/projects/<project-hash>/memory/MEMORY.md`. Claude reads it at the start of every session. You can also create topic-specific memory files in the same directory (e.g., `deployment.md`, `testing.md`), and Claude loads them on demand when the topic is relevant.

Common `claude-mem` workflows:

```bash
# View what Claude remembers about this project
/memory

# Manually add a memory
echo "Always use pnpm, never npm" >> ~/.claude/projects/$(pwd | md5sum | cut -c1-8)/memory/MEMORY.md

# Reset project memories
rm ~/.claude/projects/$(pwd | md5sum | cut -c1-8)/memory/MEMORY.md
```

The `claude-mem` system is distinct from CLAUDE.md project files. CLAUDE.md provides instructions that Claude follows. MEMORY.md stores observations Claude has made about your behavior and preferences. Both are loaded at session start, but they serve different purposes: CLAUDE.md is prescriptive (rules), MEMORY.md is descriptive (learned patterns).

For a guide on writing effective CLAUDE.md files, see our [CLAUDE.md best practices guide](/claude-md-best-practices-definitive-guide/).

## Production Gotchas

Auto-memory's storage path (`~/.claude/projects/<project>/memory/`) is based on the project directory hash. If you move your project to a different path, auto-memory starts fresh because the hash changes. Your accumulated knowledge is still at the old path -- you can manually copy MEMORY.md files.

Custom memory skills have a cold-start problem. On the first session with a new project, there is nothing to remember. Build an initial seeding process: the skill reads existing CLAUDE.md, README, and architecture docs to populate the first batch of memories.

## Checklist

- [ ] Auto-memory enabled for personal preferences (toggle with /memory)
- [ ] Custom memory skill stores project-level decisions and findings
- [ ] Memory file size managed (200 lines for auto, paginated for custom)
- [ ] Team-shared memories in version-controlled project files
- [ ] Periodic review of memory quality (remove low-value entries)



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Skills vs Raw Prompts with Tools](/claude-skills-vs-raw-prompts-with-tools/) -- when persistence matters
- [Claude Skills vs Claude AI Projects](/claude-skills-vs-claude-ai-projects/) -- project-level persistence comparison
- [Claude Skills vs MCP Servers](/claude-skills-vs-mcp-servers-comparison/) -- MCP memory server integration

## See Also

- [Claude Memory (claude-memory) vs Supermemory: AI Memory Tools Compared](/claude-memory-vs-supermemory-comparison/)
