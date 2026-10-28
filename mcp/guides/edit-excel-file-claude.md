---
title: "Can Claude edit my Excel file?"
slug: edit-excel-file-claude
target_query: "can Claude edit my Excel file"
updated: 2026-10-28
product_slug: spreadsheet
---

{% raw %}

Yes, if you connect an MCP spreadsheet server. Claude on its own can only read a file you paste or upload in limited ways; it cannot open, recalculate and save a real .xlsx with formulas intact. An MCP server does the open/save; Claude does the deciding.

## Procedure

1. Mint a token at https://mcp.zovo.one/mcp/connect.
2. Add the connector with the URL `https://mcp.zovo.one/mcp/spreadsheet/t/<token>` (claude.ai: Settings, Connectors, Add custom connector; Cursor: `.mcp.json` with the same shape shown on any zovo.one guide page).
3. Upload or reference the workbook. On the hosted route, send the file contents or a URL, because the server has no access to your local disk.
4. Ask for a concrete edit: "In sheet Sales, add a column Total = Quantity * Unit Price for rows 2-200, then sort by Total descending, and return the updated file."
5. Collect the download link. Hosted results expire after one hour; download at once.

## When this does not work

- **Formulas become values.** Some readers flatten formulas. Say "keep formulas" in the request and verify one cell after download; if the server cannot preserve them, it will say so rather than guess.
- **File too large.** The hosted route transfers the workbook in the request/response; a 50 MB workbook will fail or truncate. Split the workbook or run a local stdio server against the file path.
- **Claude reads but does not edit.** The connector was added but not enabled in that conversation; open the connectors menu and toggle it on.

## Note

The [spreadsheet MCP server](https://mcp.zovo.one) handles .xlsx and CSV and is hosted free at mcp.zovo.one on the anonymous tier; Pro keys are $19 single, $39 bundle. A cheaper alternative for read-only questions is pasting the CSV directly, which needs no server at all.

## Verify the connection with curl

Before blaming the assistant, confirm the server answers a real call. Discovery alone is not proof — `initialize` and `tools/list` answer 200 even with a bad token, but this is the exact request shape to start from:

```bash
curl -s https://mcp.zovo.one/mcp/spreadsheet/t/<token> \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

If this returns a tool list, the token and URL are good and any remaining problem is in the client's connector settings.

## What the server actually does

A spreadsheet server separates reading from writing: one set of tools reads sheets and cells, another writes or appends. For anything beyond a column of arithmetic, first ask for a read of the relevant range, confirm the row and column layout in chat, then issue the write. That two-step habit catches off-by-one row errors before they reach the file.
{% endraw %}
