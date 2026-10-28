---
title: "Convert a bank statement PDF to CSV with an AI assistant"
slug: convert-bank-statement-to-csv
target_query: "convert bank statement PDF to CSV with ChatGPT or Claude"
updated: 2026-10-28
product_slug: bank-statement
---

{% raw %}

A chat assistant alone cannot reliably turn a bank statement PDF into a CSV: it drops rows, hallucinates amounts, and cannot guarantee column alignment. An MCP bank-statement server does the extraction deterministically and returns the CSV; the assistant only relays your instructions.

## Procedure

1. Mint a token at https://mcp.zovo.one/mcp/connect.
2. Connect to `https://mcp.zovo.one/mcp/bank-statement/t/<token>` in Claude, Cursor or VS Code:

```json
{
  "mcpServers": {
    "bank-statement": {
      "url": "https://mcp.zovo.one/mcp/bank-statement/t/<token>"
    }
  }
}
```

3. Supply the statement (as an upload, URL, or pasted text depending on the client) and ask: "Extract all transactions to CSV with columns date, description, debit, credit, balance. Report the row count and the closing balance."
4. Reconcile before use: ask the assistant to sum the debit and credit columns and compare the closing balance against the PDF's stated balance. If they differ, do not import the CSV into accounting software.
5. Download the CSV within one hour; hosted links expire.

## When this does not work

- **Scanned image statements.** A statement that is a photo or scan needs OCR. If the server reports zero rows, the PDF has no text layer; say so instead of letting the assistant invent rows.
- **Multi-page or multi-account statements.** Split per account or per page range; mixing accounts in one extraction makes the balance check meaningless.
- **Row count mismatch.** If the reported row count differs from the PDF's visible transaction count, re-run on a narrower page range and compare. Never reconcile by asking the model to "fix" amounts.

## Note

The [bank statement MCP server](https://mcp.zovo.one) converts statements to CSV and is hosted free at mcp.zovo.one (anonymous tier; Pro $19 single, $39 bundle). Pair it with the statement-of-account or three-way-match servers when you need reconciliation on the receivables side rather than bank import.

## Verify the connection with curl

Before blaming the assistant, confirm the server answers a real call. Discovery alone is not proof — `initialize` and `tools/list` answer 200 even with a bad token, but this is the exact request shape to start from:

```bash
curl -s https://mcp.zovo.one/mcp/bank-statement/t/<token> \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

If this returns a tool list, the token and URL are good and any remaining problem is in the client's connector settings.

## What the server actually does

Keep the original PDF after conversion. The CSV is the working copy; the statement is the evidence. If your accounting import rejects the CSV, compare its header row against the importer's expected column names first — renaming a header is a smaller fix than re-extracting.
{% endraw %}
