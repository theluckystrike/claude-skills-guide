---
title: "Fill a Word document template from Claude or ChatGPT"
slug: fill-word-template-ai
target_query: "can Claude fill in a Word template for me"
updated: 2026-10-28
product_slug: docx
---

{% raw %}

Claude can write a .docx but cannot reliably open your existing template and keep its styles, headers and layout. An MCP docx server takes your template, fills named placeholders with the values you dictate, and returns the finished document as a download link.

## Procedure

1. Mint a token at https://mcp.zovo.one/mcp/connect.
2. Connect to `https://mcp.zovo.one/mcp/docx/t/<token>`:

```json
{
  "mcpServers": {
    "docx": {
      "url": "https://mcp.zovo.one/mcp/docx/t/<token>"
    }
  }
}
```

3. Supply the template (upload or URL — the hosted server cannot read your disk) and dictate the values: "Fill {{client_name}} with Northwind Ltd, {{amount}} with 4,800.00, {{date}} with 30 October 2026. Keep all other content unchanged."
4. Ask the assistant to list which placeholders it filled and which it left; unmatched placeholders should be reported, not silently dropped.
5. Download the result within one hour of generation.

## When this does not work

- **Placeholders left in the output.** The placeholder spelling in the template does not match what you gave. Ask the server to list remaining `{{...}}` tokens and re-run with corrected names.
- **Styles break.** If a generated document loses fonts or headers, the server wrote a fresh document instead of filling the template. State "fill the template, do not create a new document" and retry once.
- **Large or binary-heavy templates.** Files with embedded media may exceed hosted transfer limits. Trim the template or run a local stdio server against the file path.

## Note

The [docx MCP server](https://mcp.zovo.one) fills and generates Word documents and is hosted free at mcp.zovo.one (anonymous tier; Pro $19 single, $39 bundle). Use the pdf server when the deliverable must be a PDF rather than an editable document.

## Verify the connection with curl

Before blaming the assistant, confirm the server answers a real call. Discovery alone is not proof — `initialize` and `tools/list` answer 200 even with a bad token, but this is the exact request shape to start from:

```bash
curl -s https://mcp.zovo.one/mcp/docx/t/<token> \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

If this returns a tool list, the token and URL are good and any remaining problem is in the client's connector settings.

## What the server actually does

A docx server works on the document XML, so what it preserves is the template's own structure: styles, headers, footers and tables survive when the tool fills placeholders; they can be lost when the tool is asked to write a new document from scratch. Say which of the two you want — 'fill' and 'create' are different requests.
{% endraw %}
