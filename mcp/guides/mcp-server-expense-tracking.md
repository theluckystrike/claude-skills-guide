{% raw %}
---
title: "MCP server for expense tracking"
slug: mcp-server-expense-tracking
target_query: "MCP server for expense tracking"
updated: 2026-10-28
product_slug: expense-tracker
---

An MCP expense-tracker server lets Claude, Cursor or ChatGPT log expenses from receipts or plain sentences, categorize them, and produce a monthly summary or export — replacing a manual spreadsheet routine without installing a desktop app.

## Procedure

1. Mint a token at https://mcp.zovo.one/mcp/connect.
2. Connect to `https://mcp.zovo.one/mcp/expense-tracker/t/<token>`:

```json
{
  "mcpServers": {
    "expense-tracker": {
      "url": "https://mcp.zovo.one/mcp/expense-tracker/t/<token>"
    }
  }
}
```

3. Log an expense: "Add expense 2026-10-28, taxi to client site, 34.50 EUR, category travel."
4. Ask for review: "List October expenses by category and flag anything over 500."
5. For receipt-based entry, pass the receipt to the receipts server first, then log the parsed amount with the expense tracker. Export at month end: "Export October to CSV."

## When this does not work

- **Duplicate entries.** Logging the same receipt from both the receipts server and by hand creates two rows. Ask "list expenses for 2026-10-28" before adding, and delete the duplicate by id.
- **Currency mixing.** If you log some amounts in EUR and some in GBP without saying so, category totals are wrong. State the currency on every entry or convert first with the currency server.
- **401 on tool calls.** A swept or mistyped token. `initialize` still answers 200 with a bad token, so test with a real add/list call, not the connect step.

## Note

The [expense tracker MCP server](https://mcp.zovo.one) is hosted free at mcp.zovo.one (anonymous tier; Pro $19 single, $39 bundle). Nearby estate servers: receipts, petty-cash, per-diem, mileage-log, tax-calc.

## Verify the connection with curl

Before blaming the assistant, confirm the server answers a real call. Discovery alone is not proof — `initialize` and `tools/list` answer 200 even with a bad token, but this is the exact request shape to start from:

```bash
curl -s https://mcp.zovo.one/mcp/expense-tracker/t/<token> \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

If this returns a tool list, the token and URL are good and any remaining problem is in the client's connector settings.

## What the server actually does

An expense tracker server stores dated entries with amount, currency and category, and can filter by month or category. Categories are free text, so a monthly 'review categories' pass to merge near-duplicates (travel, Travel, taxi) keeps summaries honest.
## Month-end routine

A workable month-end routine in three asks: "list October expenses by category", "compare this total against last month and flag categories that doubled", then "export October to CSV". The comparison step is where duplicates and double-currency entries actually surface; the export is mechanical. Keep the receipts themselves outside the tracker — the tracker records amounts and categories, the receipts folder is the evidence behind them.
{% endraw %}
