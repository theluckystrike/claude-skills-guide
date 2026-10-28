{% raw %}
---
title: "Generate an invoice as a PDF from Claude"
slug: generate-invoice-pdf-claude
target_query: "how do I generate an invoice as a PDF from Claude"
updated: 2026-10-28
product_slug: invoice
---

Claude cannot produce a PDF invoice on its own; it writes text in chat. To get an actual invoice.pdf, give Claude an MCP server that has an invoice generator, then ask for the invoice in plain language and download the PDF it returns.

## Procedure

1. Get a hosted URL. Open https://mcp.zovo.one/mcp/connect in a browser and mint a token (10 mints per IP per hour, so do not retry rapidly).
2. Add the connector in Claude Desktop or claude.ai: Settings, Connectors, Add custom connector, and paste `https://mcp.zovo.one/mcp/invoice/t/<token>`.
3. In Claude Code, add it to `.mcp.json` instead:

```json
{
  "mcpServers": {
    "invoice": {
      "url": "https://mcp.zovo.one/mcp/invoice/t/<token>"
    }
  }
}
```

4. Ask: "Create an invoice from Acme Ltd to Northwind, line items 10 hours consulting at 120 and 2 licences at 90, VAT 20%, invoice number INV-0042, due in 14 days, and give me the PDF."
5. The server returns a download link (the hosted route has no filesystem, so files come back as links that expire after one hour, not paths on disk). Download it immediately.

## When this does not work

- **401 on every tool call.** The token segment is missing or was swept. Anonymous tokens are removed after 30 days without a call; mint a fresh one at `/mcp/connect`.
- **The assistant calls no tools.** The connector was not enabled for the conversation, or on Team/Enterprise plans only an Owner can add it at organization level first.
- **You get a link, not a file, and expect a file.** That is the designed behaviour of the hosted route. A local (stdio) install of the same server writes to disk instead.

## Note

The [invoice MCP server](https://mcp.zovo.one) is hosted at mcp.zovo.one with a free anonymous tier; a Pro key ($19 single, $39 bundle) replaces the token in the same URL for higher limits. The same connector URL pattern works in Cursor and VS Code.

## Verify the connection with curl

Before blaming the assistant, confirm the server answers a real call. Discovery alone is not proof — `initialize` and `tools/list` answer 200 even with a bad token, but this is the exact request shape to start from:

```bash
curl -s https://mcp.zovo.one/mcp/invoice/t/<token> \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

If this returns a tool list, the token and URL are good and any remaining problem is in the client's connector settings.

## What the server actually does

A hosted invoice server typically carries tools for creating an invoice from line items, listing previously issued invoices, and numbering. Create one tool call per document; do not ask for several invoices in a single request, because one failure then blocks all of them. Keep line item descriptions short and pass tax as a rate plus a label, not a precomputed amount.
{% endraw %}
