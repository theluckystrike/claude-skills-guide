{% raw %}
---
title: "MCP server for time tracking"
slug: mcp-server-time-tracking
target_query: "MCP server for time tracking"
updated: 2026-10-28
product_slug: time-tracker
---

For time tracking through Claude, Cursor or ChatGPT, use an MCP time tracker server: the assistant starts and stops timers, lists entries, and totals hours per client or project from chat, with no app to open.

## Procedure

1. Mint a token at https://mcp.zovo.one/mcp/connect.
2. Connect to `https://mcp.zovo.one/mcp/time-tracker/t/<token>`:

```json
{
  "mcpServers": {
    "time-tracker": {
      "url": "https://mcp.zovo.one/mcp/time-tracker/t/<token>"
    }
  }
}
```

3. Ask: "Start a timer for client Acme, task invoice review." Then: "Stop it and show this week's hours by client."
4. To bill the time, follow with: "Turn this week's Acme hours into an invoice at 120/hour" and let an invoice server do that step.

## When this does not work

- **Clock drift between entries.** If two timers were started in different clients, stop both and reconcile with "list all running timers" before trusting totals.
- **401 on tools/call.** The token is wrong or swept (30 days unused for anonymous tokens). Discovery (`initialize`, `tools/list`) returns 200 even with a bad token, so a healthy-looking connect proves nothing; only a real tool call does.
- **Hours not exported anywhere.** The tracker stores entries only; export to CSV or hand off to an invoice server as a separate step.

## Note

The [time tracker MCP server](https://mcp.zovo.one) is hosted at mcp.zovo.one with a free anonymous tier (Pro: $19 single, $39 bundle). Related estate servers: pomodoro, hourly-rate, job-card.

## Verify the connection with curl

Before blaming the assistant, confirm the server answers a real call. Discovery alone is not proof — `initialize` and `tools/list` answer 200 even with a bad token, but this is the exact request shape to start from:

```bash
curl -s https://mcp.zovo.one/mcp/time-tracker/t/<token> \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

If this returns a tool list, the token and URL are good and any remaining problem is in the client's connector settings.

## What the server actually does

A time tracker server stores dated entries with a client, a task label and a duration, and can total per client or per week. Entry labels are free text, so agree a naming pattern (client, then task) and reuse it; totals grouped by slightly different labels will split one client's hours across two rows.
## Switching clients mid-week

If you start a timer in Claude Desktop in the morning and stop it from Cursor in the afternoon, both clients hit the same hosted store, so the entry is consistent — provided both connectors point at the same token URL. Two tokens mean two stores; pick one token per person and put it in every client. When reviewing hours, ask for the raw entry list before the totals: a single mistyped duration of 8.0 instead of 0.8 is invisible in a weekly total but obvious in the list.
{% endraw %}
