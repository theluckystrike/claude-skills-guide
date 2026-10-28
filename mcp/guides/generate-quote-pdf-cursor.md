{% raw %}
---
title: "Generate a customer quote as a PDF from Cursor or Claude"
slug: generate-quote-pdf-cursor
target_query: "generate a quote PDF with Cursor or Claude"
updated: 2026-10-28
product_slug: quotes
---

To produce a customer quote PDF, connect an MCP quotes server and ask for the quote in chat: line items, quantities, prices, validity period, and the assistant returns a formatted quote document as a download link.

## Procedure

1. Mint a token at https://mcp.zovo.one/mcp/connect.
2. Add the connector URL `https://mcp.zovo.one/mcp/quotes/t/<token>` in Cursor's `.mcp.json`:

```json
{
  "mcpServers": {
    "quotes": {
      "url": "https://mcp.zovo.one/mcp/quotes/t/<token>"
    }
  }
}
```

3. Ask: "Quote Q-1077 for Acme: 3 widgets at 450 each with a 10 percent volume discount, installation 800 flat, valid 30 days, currency GBP."
4. Have the assistant re-read the returned document's totals back to you before sending; the discount is the field most often applied twice or not at all.
5. Download within one hour. When the quote is accepted, an invoice server can turn the same line items into an invoice.

## When this does not work

- **Discount applied twice.** If the quote total does not match your arithmetic, state "discount once, on line items only" and regenerate. Do not hand-edit the PDF.
- **No file, just text.** The connector was not actually called. Check the connectors toggle for the conversation; a chat-only answer that formats a "quote" in markdown means the tool never ran.
- **Anonymous link expired.** Hosted download links expire after one hour. Re-request the document; the data is retained, the link is not.

## Note

The [quotes MCP server](https://mcp.zovo.one) is hosted free at mcp.zovo.one (anonymous tier; Pro $19 single, $39 bundle). Companion servers: invoice, credit-note, price-tracker, billing-docs.

## Verify the connection with curl

Before blaming the assistant, confirm the server answers a real call. Discovery alone is not proof — `initialize` and `tools/list` answer 200 even with a bad token, but this is the exact request shape to start from:

```bash
curl -s https://mcp.zovo.one/mcp/quotes/t/<token> \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

If this returns a tool list, the token and URL are good and any remaining problem is in the client's connector settings.

## What the server actually does

A quotes server stores quotes with an identifier, line items and a validity period. When a quote is accepted, reference the same quote id when generating the invoice so the two documents stay traceable to each other; that pairing is also what a credit-note tool expects if part of the deal is reversed.
## Revising a sent quote

When a client negotiates, issue a revised quote with a new version suffix (Q-1077-r2) rather than overwriting the original, and reference the original id in the request. Keeping both versions lets you show what changed without reconstructing it from chat history.
{% endraw %}
