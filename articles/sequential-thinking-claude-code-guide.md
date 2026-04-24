---
title: "Sequential Thinking in Claude Code: Guide (2026)"
description: "How to install and use the sequential thinking MCP server in Claude Code. Step-by-step setup, when it helps, real examples, and configuration options."
permalink: /sequential-thinking-claude-code-guide/
last_tested: "2026-04-24"
render_with_liquid: false
---

# Sequential Thinking in Claude Code: Guide (2026)

Sequential thinking is an MCP server that gives Claude Code a structured `think` tool for breaking down complex problems step by step. Instead of jumping to a solution, Claude can use this tool to reason through each stage of a problem, revise its approach, and build toward a well-considered answer. This guide covers installation, how it works, when to use it, and real examples of improved output.

## What Sequential Thinking Is

The `@anthropic/sequential-thinking` MCP server provides Claude Code with a single tool: a structured thinking space where the model can work through problems methodically before producing a final answer.

Without sequential thinking, Claude Code processes your request and generates a response in a single pass. With it, Claude Code can:

1. Decompose a problem into numbered steps
2. Evaluate each step before moving to the next
3. Revise earlier steps when new information changes the approach
4. Track which assumptions have been validated and which remain uncertain
5. Produce a more thorough final answer based on the step-by-step analysis

Think of it as giving Claude a scratchpad for structured reasoning, similar to how a developer might sketch out a plan on paper before writing code.

## Installation

### One-Command Setup

```bash
claude mcp add sequential-thinking -- npx -y @anthropic/sequential-thinking
```

This adds the server to your project-level configuration (`.claude/settings.json`).

### Global Installation

To make sequential thinking available in every Claude Code session:

```bash
claude mcp add sequential-thinking --scope user -- npx -y @anthropic/sequential-thinking
```

### Verify Installation

```bash
claude mcp list
```

Expected output includes:

```
- sequential-thinking (project): npx -y @anthropic/sequential-thinking
```

### Manual Configuration

If you prefer editing the settings file directly:

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@anthropic/sequential-thinking"]
    }
  }
}
```

Add this to `~/.claude/settings.json` (user scope) or `.claude/settings.json` (project scope). See the [MCP configuration guide](/claude-code-mcp-configuration-guide/) for details on these files.

## How Sequential Thinking Works

When the sequential thinking MCP server is running, Claude Code gains access to a `think` tool. Claude can call this tool multiple times during a single response to work through a problem.

### The Think Tool

Each call to the `think` tool includes:
- **thought** — the current reasoning step
- **nextThoughtNeeded** — whether more thinking is required
- **thoughtNumber** — the current step number
- **totalThoughts** — estimated total steps (can be revised)

### Reasoning Flow

Here is what a typical sequential thinking session looks like internally:

**Step 1:** Understand the problem
```
Thought 1/5: The user wants to refactor this authentication module. Let me identify all the dependencies first.
```

**Step 2:** Analyze constraints
```
Thought 2/5: The module is used by 3 API routes and 2 middleware functions. Any refactor must maintain the same public interface.
```

**Step 3:** Evaluate approaches
```
Thought 3/6: Option A - extract token validation into its own module. Option B - use dependency injection. Option A is simpler and does not change the call sites.
```

**Step 4:** Plan implementation
```
Thought 4/6: I'll create a new token-validator.js file, move the validation logic, update the imports in auth.js, and verify all 5 consumers still work.
```

**Step 5:** Consider edge cases
```
Thought 5/6: The middleware uses a cached token check that depends on a closure variable. I need to either pass the cache as a parameter or make the validator module manage its own cache.
```

**Step 6:** Finalize approach
```
Thought 6/6: Final plan: create token-validator.js with its own cache, export validate() and invalidate() functions, update auth.js and all 5 consumers.
```

After completing the thinking steps, Claude Code produces the actual code changes with full confidence in the approach.

### Dynamic Adjustment

The total number of thinking steps is not fixed. Claude can revise it mid-process:

- If a problem is simpler than expected, it reduces the total
- If new complexity is discovered, it adds more steps
- If an earlier assumption is wrong, it can backtrack and revise

## When to Use Sequential Thinking

Sequential thinking adds overhead (each thinking step consumes tokens). Use it for complex tasks where the overhead is justified.

### Complex Multi-Step Refactoring

When refactoring touches multiple files, modules, and interfaces, sequential thinking helps Claude map out the dependency graph and plan changes that do not break intermediate states.

**Example prompt:**
```
Refactor the payment processing module to support multiple payment providers instead of just Stripe. Keep the existing Stripe integration working.
```

Without sequential thinking, Claude might start editing files immediately and realize mid-way that the abstraction layer needs a different interface. With sequential thinking, it maps the full change set first.

### Architecture Decisions

When choosing between multiple valid approaches, sequential thinking lets Claude evaluate trade-offs systematically.

**Example prompt:**
```
Should we use a message queue or direct API calls for the notification service? Consider reliability, latency, and maintenance overhead.
```

### Debugging Intricate Issues

For bugs that require understanding multiple interacting systems, sequential thinking helps trace the logic chain.

**Example prompt:**
```
Users report intermittent 503 errors on the /api/orders endpoint. The error only happens under load. Debug this.
```

Sequential thinking lets Claude work through the possible causes methodically: connection pool exhaustion, timeout cascades, race conditions in the caching layer, and so on.

### Planning Large Features

Before implementing a feature that spans many files, sequential thinking produces a comprehensive plan.

**Example prompt:**
```
Plan the implementation of a real-time collaborative editing feature for our document editor. Consider conflict resolution, WebSocket connections, and persistence.
```

### When It Is Unnecessary

Do not use sequential thinking for:

- Simple code generation ("write a function that sorts an array")
- Single-file edits with clear requirements
- Questions with straightforward answers
- Tasks where speed matters more than thoroughness

The overhead of thinking steps adds latency and token cost. For simple tasks, Claude Code's default behavior is faster and equally effective.

## Before and After Examples

### Example 1: Database Migration

**Without sequential thinking:**

Prompt: "Add a soft delete column to the users table and update all queries."

Claude immediately starts editing the migration file, then the model, then the queries. It misses two queries in a helper module and the delete cascade on the orders table.

**With sequential thinking:**

Claude's thinking process:
1. Identify all files that reference the users table
2. List every query that performs DELETE on users
3. Check for foreign key cascades that trigger on user deletion
4. Plan the migration, model changes, and query updates
5. Verify nothing was missed

Result: all 14 query locations updated, cascade on orders table handled, and a test added for the soft delete behavior.

### Example 2: API Versioning

**Without sequential thinking:**

Prompt: "Add v2 of the products API with a new response format, while keeping v1 working."

Claude starts creating v2 routes but shares too much code with v1, creating coupling that will break v1 when v2 evolves.

**With sequential thinking:**

Claude's thinking process:
1. Analyze current v1 route structure and shared middleware
2. Decide isolation strategy: separate controllers, shared services
3. Define the v2 response format and map it to existing data models
4. Plan the routing structure to support both versions
5. Identify shared validation that can be reused safely

Result: clean separation between v1 and v2, shared service layer, independent controllers, and a version-aware middleware that routes correctly.

## Configuration Options

The sequential thinking MCP server itself has minimal configuration. The main decisions are about scope and availability.

### Scope Selection

**Project scope** (default) — only available in the project where you installed it:

```bash
claude mcp add sequential-thinking -- npx -y @anthropic/sequential-thinking
```

**User scope** — available everywhere:

```bash
claude mcp add sequential-thinking --scope user -- npx -y @anthropic/sequential-thinking
```

For most developers, user scope makes sense since sequential thinking is useful across all projects.

### Pre-installing the Package

To avoid the startup delay from `npx -y` downloading the package each time:

```bash
npm install -g @anthropic/sequential-thinking
```

Then configure with the global path:

```bash
claude mcp add sequential-thinking -- sequential-thinking
```

Or find the exact path:

```bash
which sequential-thinking
# Use the full path in the configuration
```

---

*This configuration is one of 200 production-ready templates in [The Claude Code Playbook](https://zovo.one/pricing). Permission configs, model selection rules, MCP setups — all tested and ready to copy.*

## Combining with Other MCP Servers

Sequential thinking works alongside other MCP servers. Claude Code can use the `think` tool to reason about a problem, then use other tools to implement the solution.

### With Filesystem Server

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@anthropic/sequential-thinking"]
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/you/projects"]
    }
  }
}
```

Claude thinks through the approach, then uses the filesystem server to read and write files.

### With GitHub Server

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@anthropic/sequential-thinking"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_your_token"
      }
    }
  }
}
```

Claude thinks through a code review strategy, then uses the GitHub server to fetch PR details and post comments.

### With Database Server

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@anthropic/sequential-thinking"]
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-postgres", "postgresql://localhost/mydb"]
    }
  }
}
```

Claude thinks through a query optimization plan, then uses the database server to test queries and check execution plans.

## Limitations

### Token Cost

Each thinking step consumes input and output tokens. A 6-step thinking process can add 1,000-3,000 tokens of overhead. For expensive models, this adds up across many requests.

### Not Always Triggered

Claude Code decides whether to use the `think` tool based on the complexity of the request. For simple tasks, it may skip sequential thinking entirely, even when the server is installed. You cannot force Claude to use it.

### No Persistent Memory

Thinking steps are part of the current conversation only. They do not persist to future sessions or affect Claude Code's behavior in other conversations. If you need persistent project knowledge, use [CLAUDE.md files](/claude-code-claude-md-best-practices/) instead.

### Latency

Sequential thinking adds response time. Each thinking step requires a round trip to the MCP server. For time-sensitive tasks, the overhead may not be worth the improved quality.

## Frequently Asked Questions

### Does sequential thinking make Claude smarter?

It does not change the model's capabilities. It gives the model a structured space to use its existing reasoning abilities more methodically. The result is often better for complex tasks because the model is less likely to skip steps or make hasty assumptions.

### Can I see the thinking steps?

Yes. The thinking steps appear in Claude Code's output as tool calls. You can see each step's content as it happens, giving you visibility into Claude's reasoning process.

### Does it work with all Claude models?

Sequential thinking works with any model that supports MCP tool use — Opus, Sonnet, and Haiku. The quality of reasoning varies by model capability. Opus produces the most thorough thinking steps, while Haiku's may be more abbreviated.

### Can I control how many thinking steps Claude uses?

Not directly. Claude determines the number of steps based on problem complexity. You can influence this by being explicit in your prompt: "Think through this carefully in at least 5 steps" or "Keep the analysis brief."

### Is sequential thinking the same as chain-of-thought prompting?

Related but different. Chain-of-thought prompting asks the model to show its reasoning in the response text. Sequential thinking provides a separate tool for structured reasoning that is distinct from the final response. The thinking steps are tool calls, not part of the prose output.

### Can I build my own thinking MCP server?

Yes. The MCP protocol is open. You can build a custom server that provides a different structured thinking interface. The official `@anthropic/sequential-thinking` server is a reference implementation. See the [MCP integration guide](/mcp-integration-guide-for-claude-code-beginners/) for building custom servers.

## Related Guides

- [Claude Code MCP Configuration](/claude-code-mcp-configuration-guide/) — full MCP setup reference
- [Claude MCP List Command Reference](/claude-mcp-list-command-guide/) — CLI command details
- [How to Add an MCP Server](/how-to-add-mcp-server-claude-code-2026/) — step-by-step installation
- [Best MCP Servers for Claude Code](/best-mcp-servers-for-claude-code-2026/) — curated server list
- [MCP Servers Complete Setup](/mcp-servers-claude-code-complete-setup-2026/) — end-to-end walkthrough
- [Awesome MCP Servers Directory](/awesome-mcp-servers-directory-guide-2026/) — community directory
- [The Claude Code Playbook](/the-claude-code-playbook/) — comprehensive workflow reference
- [Claude Code Best Practices](/claude-code-claude-md-best-practices/) — optimize your setup
- [Configuration Hierarchy Explained](/claude-code-configuration-hierarchy-explained-2026/) — settings precedence

- [Claude Agent SDK guide](/claude-agent-sdk-complete-guide/) — Build agents that use sequential thinking
- [Claude Flow tool guide](/claude-flow-tool-guide/) — Orchestrate thinking across agents
- [Claude temperature settings guide](/claude-temperature-settings-guide/) — Temperature interacts with thinking behavior
### Does sequential thinking increase API costs?

Yes. Each thinking step consumes input and output tokens. A 6-step thinking process can add 1,000-3,000 tokens of overhead. For expensive models like Opus, this adds up across many requests.

### Can I use sequential thinking with Claude Haiku?

Yes, but Haiku's thinking steps may be more abbreviated and less thorough than Opus or Sonnet. For tasks that truly benefit from structured reasoning, Sonnet or Opus will produce better results.

### Does sequential thinking work in Claude Code API mode?

Yes. When the MCP server is configured, sequential thinking is available in both interactive mode and API mode (claude -p).

### Can I combine sequential thinking with extended thinking?

Yes. These are complementary features. Extended thinking is a model-level capability while sequential thinking is an MCP tool. They can work together for maximum reasoning depth.

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {"@type": "Question", "name": "Does sequential thinking make Claude smarter?", "acceptedAnswer": {"@type": "Answer", "text": "It does not change the model's capabilities. It gives the model a structured space to use its existing reasoning abilities more methodically. The result is often better for complex tasks."}},
    {"@type": "Question", "name": "Can I see the thinking steps?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. The thinking steps appear in Claude Code's output as tool calls. You can see each step's content as it happens, giving you visibility into Claude's reasoning process."}},
    {"@type": "Question", "name": "Does it work with all Claude models?", "acceptedAnswer": {"@type": "Answer", "text": "Sequential thinking works with any model that supports MCP tool use — Opus, Sonnet, and Haiku. The quality of reasoning varies by model capability."}},
    {"@type": "Question", "name": "Can I control how many thinking steps Claude uses?", "acceptedAnswer": {"@type": "Answer", "text": "Not directly. Claude determines the number of steps based on problem complexity. You can influence this by being explicit in your prompt."}},
    {"@type": "Question", "name": "Is sequential thinking the same as chain-of-thought prompting?", "acceptedAnswer": {"@type": "Answer", "text": "Related but different. Chain-of-thought asks the model to show reasoning in response text. Sequential thinking provides a separate tool for structured reasoning distinct from the final response."}},
    {"@type": "Question", "name": "Can I build my own thinking MCP server?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. The MCP protocol is open. You can build a custom server that provides a different structured thinking interface. The official server is a reference implementation."}},
    {"@type": "Question", "name": "Does sequential thinking increase API costs?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. Each thinking step consumes input and output tokens. A 6-step thinking process can add 1,000-3,000 tokens of overhead."}},
    {"@type": "Question", "name": "Can I use sequential thinking with Claude Haiku?", "acceptedAnswer": {"@type": "Answer", "text": "Yes, but Haiku's thinking steps may be more abbreviated. For tasks that truly benefit from structured reasoning, Sonnet or Opus will produce better results."}},
    {"@type": "Question", "name": "Does sequential thinking work in Claude Code API mode?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. When the MCP server is configured, sequential thinking is available in both interactive mode and API mode."}},
    {"@type": "Question", "name": "Can I combine sequential thinking with extended thinking?", "acceptedAnswer": {"@type": "Answer", "text": "Yes. These are complementary features. Extended thinking is a model-level capability while sequential thinking is an MCP tool. They can work together for maximum reasoning depth."}}
  ]
}
</script>
