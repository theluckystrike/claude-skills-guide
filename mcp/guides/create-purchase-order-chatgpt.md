{% raw %}
---
title: "Create a purchase order from ChatGPT or Claude"
slug: create-purchase-order-chatgpt
target_query: "how to create a purchase order with ChatGPT"
updated: 2026-10-28
product_slug: purchase-requisition
---

ChatGPT can draft purchase order text but cannot emit a fillable PO document. Connect an MCP purchase-order server and the assistant generates a real PO document from your line items, with a PO number and supplier details, returned as a download link.

## Procedure

1. Mint a token at https://mcp.zovo.one/mcp/connect.
2. Add the connector URL `https://mcp.zovo.one/mcp/purchase-requisition/t/<token>` (ChatGPT via an MCP-capable connector setting; Claude and Cursor via `.mcp.json`):

```json
{
  "mcpServers": {
    "purchase-requisition": {
      "url": "https://mcp.zovo.one/mcp/purchase-requisition/t/<token>"
    }
  }
}
```

3. Ask: "Create PO 2026-PO-018 for Northwind Supply: 40 units of widget A at 6.50, 5 units of bracket B at 22.00, delivery to our warehouse by 15 November, terms net 30."
4. Review the returned document against the chat text; the document is the deliverable, the chat text is only the draft.
5. Download within the hour. For approval flow, follow with the purchase-requisition or goods-receipt servers.

## When this does not work

- **The connector calls no tools.** On claude.ai the connector must be enabled per conversation; on Teams plans an Owner must add it at organization level first.
- **Numbering drift.** If you let the server assign PO numbers across sessions it may reuse or skip; pass the PO number explicitly, as in the example above, and keep your own register.
- **VAT or currency wrong.** State tax rate and currency in the request. If the output still disagrees, edit the request, not the PDF by hand.

## Note

The [purchase order MCP server](https://mcp.zovo.one) is hosted free at mcp.zovo.one (Pro $19 single, $39 bundle). The estate also ships quotes, change-order, delivery-schedule and three-way-match servers that use the same connector URL pattern.

## Verify the connection with curl

Before blaming the assistant, confirm the server answers a real call. Discovery alone is not proof — `initialize` and `tools/list` answer 200 even with a bad token, but this is the exact request shape to start from:

```bash
curl -s https://mcp.zovo.one/mcp/purchase-requisition/t/<token> \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

If this returns a tool list, the token and URL are good and any remaining problem is in the client's connector settings.

## What the server actually does

A purchase order server generates the document; it does not approve anything. If your process needs approval before sending, export the PO, route it through your normal approver, and only then forward the PDF. Keep PO numbers sequential in your own register regardless of what the tool assigns.
{% endraw %}
