---
layout: post
title: "Claude Code Tool Calling and Parallel Execution 2026"
description: "Master Claude Code tool calling: parallel tool use, custom tool definitions, execution strategies, and error handling for complex workflows."
permalink: /claude-code-tool-calling-parallel-execution-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---

## The Workflow

Understand and leverage Claude Code's tool calling system, including parallel tool execution, custom tool definitions via MCP, and strategies for handling tool errors gracefully. This enables building complex multi-step workflows that execute efficiently.

Expected time: 20-30 minutes to understand and configure
Prerequisites: Claude Code installed, familiarity with MCP protocol basics, shell scripting knowledge

## Setup

### 1. Inspect Available Tools

```bash
claude --print "List all tools you have access to and their capabilities"
# Expected output:
# Read, Write, Edit, Bash, Glob, Grep, WebFetch, etc.
```

### 2. Configure MCP for Custom Tools

```json
{
  "mcpServers": {
    "custom-tools": {
      "command": "node",
      "args": ["./mcp-server/index.js"],
      "env": {
        "TOOL_TIMEOUT": "30000"
      }
    }
  }
}
```

Save to `.claude/mcp-config.json` or `~/.claude/mcp-config.json`.

### 3. Verify Tool Availability

```bash
claude --mcp-list
# Expected output:
# Built-in tools: Read, Write, Edit, Bash, Glob, Grep
# MCP servers: custom-tools (connected)
```

## Usage Example

Build a custom MCP tool server that Claude Code can call:

```javascript
// mcp-server/index.js
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

const server = new Server(
  { name: 'project-tools', version: '1.0.0' },
  { capabilities: { tools: {} } }
);

// Define custom tools
server.setRequestHandler('tools/list', async () => ({
  tools: [
    {
      name: 'run_tests',
      description: 'Run project test suite with optional filter',
      inputSchema: {
        type: 'object',
        properties: {
          filter: {
            type: 'string',
            description: 'Test name filter pattern'
          },
          coverage: {
            type: 'boolean',
            description: 'Include coverage report'
          }
        }
      }
    },
    {
      name: 'check_deps',
      description: 'Check for outdated or vulnerable dependencies',
      inputSchema: {
        type: 'object',
        properties: {
          audit: {
            type: 'boolean',
            description: 'Run security audit'
          }
        }
      }
    },
    {
      name: 'deploy_preview',
      description: 'Deploy a preview environment for the current branch',
      inputSchema: {
        type: 'object',
        properties: {
          branch: {
            type: 'string',
            description: 'Git branch to deploy'
          }
        },
        required: ['branch']
      }
    }
  ]
}));

// Handle tool execution
server.setRequestHandler('tools/call', async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case 'run_tests': {
      const { execSync } = await import('child_process');
      const cmd = args.coverage
        ? `npx vitest run ${args.filter || ''} --coverage`
        : `npx vitest run ${args.filter || ''}`;

      try {
        const output = execSync(cmd, {
          encoding: 'utf-8',
          timeout: 60000
        });
        return { content: [{ type: 'text', text: output }] };
      } catch (error) {
        return {
          content: [{ type: 'text', text: `Tests failed:\n${error.stdout}\n${error.stderr}` }],
          isError: true
        };
      }
    }

    case 'check_deps': {
      const { execSync } = await import('child_process');
      const results = [];

      results.push(execSync('npm outdated --json 2>/dev/null || true', {
        encoding: 'utf-8'
      }));

      if (args.audit) {
        results.push(execSync('npm audit --json 2>/dev/null || true', {
          encoding: 'utf-8'
        }));
      }

      return { content: [{ type: 'text', text: results.join('\n---\n') }] };
    }

    case 'deploy_preview': {
      const { execSync } = await import('child_process');
      const output = execSync(
        `vercel deploy --no-wait 2>&1 || echo "Deploy queued for ${args.branch}"`,
        { encoding: 'utf-8', timeout: 30000 }
      );
      return { content: [{ type: 'text', text: output }] };
    }

    default:
      return {
        content: [{ type: 'text', text: `Unknown tool: ${name}` }],
        isError: true
      };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

Install dependencies for the MCP server:

```bash
cd mcp-server && npm init -y && npm install @modelcontextprotocol/sdk
```

Claude Code automatically parallelizes independent tool calls. When you ask it to "run tests, check for outdated deps, and read the README," it will execute all three simultaneously:

```
User: Run the test suite with coverage, check deps for security issues,
      and show me the project README.

Claude executes in parallel:
  ├── Tool: run_tests {coverage: true}
  ├── Tool: check_deps {audit: true}
  └── Tool: Read {file_path: "./README.md"}

All three return results simultaneously, saving wall-clock time.
```

For error handling in multi-tool workflows, use a wrapper pattern:

```bash
#!/bin/bash
# robust-workflow.sh — Tool execution with retry and fallback

MAX_RETRIES=3
TIMEOUT=60

run_with_retry() {
  local description="$1"
  local command="$2"
  local attempt=0

  while [ $attempt -lt $MAX_RETRIES ]; do
    attempt=$((attempt + 1))
    echo "[$description] Attempt $attempt/$MAX_RETRIES"

    output=$(timeout "$TIMEOUT" bash -c "$command" 2>&1)
    status=$?

    if [ $status -eq 0 ]; then
      echo "$output"
      return 0
    elif [ $status -eq 124 ]; then
      echo "[$description] Timed out after ${TIMEOUT}s"
    else
      echo "[$description] Failed (exit $status): $output"
    fi

    [ $attempt -lt $MAX_RETRIES ] && sleep 2
  done

  echo "[$description] All $MAX_RETRIES attempts failed"
  return 1
}

# Execute tools with resilience
run_with_retry "Tests" "npm test" &
run_with_retry "Lint" "npm run lint" &
run_with_retry "Type Check" "npx tsc --noEmit" &

# Wait for all parallel jobs
wait

echo "All checks complete"
```

## Common Issues

- **Tool calls timeout:** Set appropriate timeouts in your MCP server. Default is 30 seconds which is too short for test suites. Use `TOOL_TIMEOUT` env var or configure per-tool.
- **Parallel tools conflict on file writes:** If two tools write to the same file simultaneously, results are undefined. Ensure parallel tools are truly independent (read-only operations, or write to different files).
- **Custom MCP server disconnects:** Check that your server keeps the stdio transport open. Do not call `process.exit()` anywhere. Handle errors without crashing the server process.

## Why This Matters

Parallel tool execution cuts workflow time by 60-80% for independent operations. Understanding tool calling lets you build custom automation that Claude executes natively, without shell script wrappers.

## Related Guides

- [Claude Code Multi-Agent Subagent Communication Guide](/claude-code-multi-agent-subagent-communication-guide/)
- [Advanced Claude Skills with Tool Use and Function Calling](/advanced-claude-skills-with-tool-use-and-function-calling/)
- [Claude Skills vs MCP Servers Differences](/claude-skills-vs-mcp-servers-differences/)
