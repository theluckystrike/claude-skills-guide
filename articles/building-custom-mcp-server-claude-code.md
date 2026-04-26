---
layout: default
title: "Building a Custom MCP Server for Claude Code (2026)"
description: "Build your own MCP server for Claude Code using the TypeScript SDK. Working code example, architecture overview, testing steps, and deployment guide included."
date: 2026-04-26
author: "Claude Skills Guide"
permalink: /building-custom-mcp-server-claude-code/
reviewed: true
categories: [tutorials]
tags: [claude, claude-code, mcp, custom-server, typescript, sdk, development]
---

# Building a Custom MCP Server for Claude Code (2026)

When the existing MCP servers do not cover your use case — an internal API, a proprietary database, or a custom tool — you can build your own. The MCP TypeScript SDK handles all the protocol details, leaving you to implement just the tools and resources your server exposes. This guide covers the full process: understanding the architecture, scaffolding a project, implementing tools, testing locally, and connecting to Claude Code. Use the [MCP Config Generator](/mcp-config/) to generate the final configuration.

## MCP Server Architecture

Every MCP server follows the same pattern:

```
Claude Code  ←→  MCP Protocol (JSON-RPC over stdio)  ←→  Your Server  ←→  Your Data/API
```

Your server declares:
- **Tools** — Actions Claude can invoke (e.g., "create_ticket", "run_query")
- **Resources** — Data Claude can read (e.g., "project_config", "user_list")

The MCP SDK handles serialization, transport, and protocol negotiation. You write the handler functions.

## Project Setup

Initialize a new TypeScript project for your MCP server:

```bash
mkdir my-mcp-server && cd my-mcp-server

npm init -y
npm install @modelcontextprotocol/sdk zod
npm install -D typescript @types/node tsx

# Create tsconfig
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true
  },
  "include": ["src/**/*"]
}
EOF

mkdir src
```

## Implementing a Working Server

Here is a complete MCP server that exposes a weather lookup tool. This demonstrates the core patterns you will reuse for any custom server:

```typescript
// src/index.ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "weather-server",
  version: "1.0.0",
});

// Define a tool that Claude can call
server.tool(
  "get_weather",
  "Get current weather for a city",
  {
    city: z.string().describe("City name"),
    units: z.enum(["celsius", "fahrenheit"]).default("celsius"),
  },
  async ({ city, units }) => {
    // Replace with your actual API call
    const response = await fetch(
      `https://api.weatherapi.com/v1/current.json?key=${process.env.WEATHER_API_KEY}&q=${city}`
    );
    const data = await response.json();

    const temp = units === "celsius"
      ? data.current.temp_c
      : data.current.temp_f;

    return {
      content: [
        {
          type: "text" as const,
          text: `Weather in ${city}: ${temp}° ${units}, ${data.current.condition.text}`,
        },
      ],
    };
  }
);

// Define a resource that Claude can read
server.resource(
  "supported-cities",
  "weather://cities",
  async (uri) => ({
    contents: [
      {
        uri: uri.href,
        mimeType: "application/json",
        text: JSON.stringify([
          "New York", "London", "Tokyo", "Sydney", "Berlin"
        ]),
      },
    ],
  })
);

// Start the server
async function main(): Promise<void> {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(console.error);
```

This server exposes one tool (`get_weather`) and one resource (`supported-cities`). Claude Code will discover both automatically when connected.

## Adding Multiple Tools

Extend your server with additional tools by calling `server.tool()` for each one:

```typescript
server.tool(
  "get_forecast",
  "Get 5-day weather forecast",
  {
    city: z.string(),
    days: z.number().min(1).max(5).default(3),
  },
  async ({ city, days }) => {
    const response = await fetch(
      `https://api.weatherapi.com/v1/forecast.json?key=${process.env.WEATHER_API_KEY}&q=${city}&days=${days}`
    );
    const data = await response.json();

    const forecast = data.forecast.forecastday.map(
      (day: { date: string; day: { avgtemp_c: number; condition: { text: string } } }) =>
        `${day.date}: ${day.day.avgtemp_c}°C, ${day.day.condition.text}`
    );

    return {
      content: [{ type: "text" as const, text: forecast.join("\n") }],
    };
  }
);
```

## Testing Locally

Test your server before connecting it to Claude Code:

```bash
# Run the server directly (it communicates over stdio)
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}' | npx tsx src/index.ts

# Or use the MCP inspector tool
npx @modelcontextprotocol/inspector npx tsx src/index.ts
```

The MCP inspector provides a web UI where you can call tools, read resources, and see the raw JSON-RPC messages.

## Connecting to Claude Code

Add your custom server to the MCP configuration:

```json
{
  "mcpServers": {
    "weather": {
      "command": "npx",
      "args": ["tsx", "/absolute/path/to/my-mcp-server/src/index.ts"],
      "env": {
        "WEATHER_API_KEY": "your_api_key_here"
      }
    }
  }
}
```

Or build and run the compiled JavaScript:

```bash
npx tsc
```

```json
{
  "mcpServers": {
    "weather": {
      "command": "node",
      "args": ["/absolute/path/to/my-mcp-server/dist/index.js"],
      "env": {
        "WEATHER_API_KEY": "your_api_key_here"
      }
    }
  }
}
```

Restart Claude Code and verify with `/mcp`. Your `weather` server should appear as `connected`.

## Error Handling Best Practices

Return errors through the MCP protocol rather than throwing exceptions:

```typescript
server.tool(
  "get_weather",
  "Get current weather",
  { city: z.string() },
  async ({ city }) => {
    try {
      const response = await fetch(`https://api.weatherapi.com/v1/current.json?key=${process.env.WEATHER_API_KEY}&q=${city}`);
      if (!response.ok) {
        return {
          content: [{ type: "text" as const, text: `Error: Could not fetch weather for "${city}" (HTTP ${response.status})` }],
          isError: true,
        };
      }
      const data = await response.json();
      return {
        content: [{ type: "text" as const, text: `${city}: ${data.current.temp_c}°C` }],
      };
    } catch (err) {
      return {
        content: [{ type: "text" as const, text: `Network error: ${(err as Error).message}` }],
        isError: true,
      };
    }
  }
);
```

## Publishing Your Server

Package your server for others to use:

```json
{
  "name": "@yourorg/mcp-server-weather",
  "version": "1.0.0",
  "bin": { "mcp-server-weather": "./dist/index.js" },
  "files": ["dist"],
  "scripts": {
    "build": "tsc",
    "prepublishOnly": "npm run build"
  }
}
```

Add a shebang to `src/index.ts`:

```typescript
#!/usr/bin/env node
```

After publishing to npm, users can configure it with:

```json
{
  "mcpServers": {
    "weather": {
      "command": "npx",
      "args": ["-y", "@yourorg/mcp-server-weather"],
      "env": { "WEATHER_API_KEY": "xxx" }
    }
  }
}
```

## Try It Yourself

Use the [MCP Config Generator](/mcp-config/) to create configuration entries for your custom server. It handles the JSON structure so you can focus on building tools.

<details>
<summary>What language can I write MCP servers in?</summary>
MCP servers can be written in any language. Official SDKs exist for TypeScript and Python. Community SDKs are available for Go, Rust, and Java. The server communicates over stdio using JSON-RPC, so any language that can read stdin and write stdout works.
</details>

<details>
<summary>How do I handle authentication in my MCP server?</summary>
Pass credentials through environment variables in the MCP configuration. Your server reads them from process.env. Never hardcode secrets in your server code. For OAuth flows, implement token refresh logic inside your server.
</details>

<details>
<summary>Can my MCP server maintain state between calls?</summary>
Yes. Your server runs as a long-lived process during the Claude Code session. You can maintain in-memory state, database connections, or caches between tool calls. The state is lost when the session ends.
</details>

<details>
<summary>What happens if my MCP server crashes?</summary>
Claude Code detects the crash and marks the server as disconnected. You can restart Claude Code or use the /mcp command to reconnect. Design your server with proper error handling to prevent crashes from propagating.
</details>

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What language can I write MCP servers in?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "MCP servers can be written in any language. Official SDKs exist for TypeScript and Python. Community SDKs are available for Go, Rust, and Java. The server communicates over stdio using JSON-RPC, so any language that can read stdin and write stdout works."
      }
    },
    {
      "@type": "Question",
      "name": "How do I handle authentication in my MCP server?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Pass credentials through environment variables in the MCP configuration. Your server reads them from process.env. Never hardcode secrets in your server code. For OAuth flows, implement token refresh logic inside your server."
      }
    },
    {
      "@type": "Question",
      "name": "Can my MCP server maintain state between calls?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Your server runs as a long-lived process during the Claude Code session. You can maintain in-memory state, database connections, or caches between tool calls. The state is lost when the session ends."
      }
    },
    {
      "@type": "Question",
      "name": "What happens if my MCP server crashes?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code detects the crash and marks the server as disconnected. You can restart Claude Code or use the /mcp command to reconnect. Design your server with proper error handling to prevent crashes from propagating."
      }
    }
  ]
}
</script>



**Get started →** Generate your project setup with our [Project Starter](/starter/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [MCP Config Generator](/mcp-config/) — Generate configuration for any MCP server
- [Advanced Usage Patterns](/advanced-usage/) — Power-user workflows and automation
- [Command Reference](/commands/) — All Claude Code commands and flags
- [Claude Code Configuration Guide](/configuration/) — Settings and project configuration
- [Best Practices for Claude Code](/best-practices/) — Development workflow optimization
