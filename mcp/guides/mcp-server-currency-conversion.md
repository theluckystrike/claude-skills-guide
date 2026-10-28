---
title: "Convert currencies inside Claude, Cursor or ChatGPT"
slug: mcp-server-currency-conversion
target_query: "how to convert currencies in ChatGPT with live rates"
updated: 2026-10-28
product_slug: currency
---

{% raw %}

Chat assistants know exchange rates only from training data, so quoted rates can be weeks or months old. An MCP currency server fetches a current rate at call time, and the assistant uses it for the arithmetic and the explanation.

## Procedure

1. Mint a token at https://mcp.zovo.one/mcp/connect.
2. Connect to `https://mcp.zovo.one/mcp/currency/t/<token>`:

```json
{
  "mcpServers": {
    "currency": {
      "url": "https://mcp.zovo.one/mcp/currency/t/<token>"
    }
  }
}
```

3. Ask: "Convert 12,500 USD to EUR at the current rate and show the rate you used."
4. For invoicing, name the currency explicitly per line item and ask for a per-currency subtotal before any conversion, so the conversion rate is applied once, visibly.
5. If you need the rate recorded, ask the assistant to print the rate and timestamp into the invoice or CSV it produces; the chat transcript is not an audit trail.

## When this does not work

- **Stale-rate suspicion.** Ask the assistant to echo the rate returned by the tool. If it quotes a rate without calling the tool, the connector is not enabled; fix that before trusting any number.
- **Exotic currency pair.** Some pairs are not carried. Convert through a major pair (for example XGG to USD to EUR) and say so in the output.
- **401 on tools/call.** Wrong or swept token; `initialize` answers 200 regardless, so verify with an actual conversion call.

## Note

The [currency MCP server](https://mcp.zovo.one) is hosted free at mcp.zovo.one (anonymous tier; Pro $19 single, $39 bundle). Pair it with invoice, expense-tracker or amortization servers whenever documents mix currencies.

## Verify the connection with curl

Before blaming the assistant, confirm the server answers a real call. Discovery alone is not proof — `initialize` and `tools/list` answer 200 even with a bad token, but this is the exact request shape to start from:

```bash
curl -s https://mcp.zovo.one/mcp/currency/t/<token> \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

If this returns a tool list, the token and URL are good and any remaining problem is in the client's connector settings.

## What the server actually does

A currency server returns a rate for a pair at call time. Rates move, so a document generated today and one generated tomorrow can differ without either being wrong. For any figure that appears in a legal or tax document, print the rate used into the document itself.
## Rounding

Decide rounding once and state it in the request: convert first, then round the document total to two decimals, and never round intermediate line items. If the assistant rounds each line before summing, totals drift by cents, which bank reconciliation then flags; the fix is one sentence in the request.
{% endraw %}
