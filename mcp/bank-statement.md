---
layout: default
title: "Bank Statement MCP server: install, tools and pricing"
description: "Import a bank CSV export, categorise it, summarise it per currency, find recurring charges and reconcile it against your expense ledger. Everything…"
permalink: /mcp/bank-statement/
date: 2026-10-28
---

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Bank Statement MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "Import a bank CSV export, categorise it, summarise it per currency, find recurring charges and reconcile it against your expense ledger. Everything stays on your machine.",
   "softwareVersion": "0.22.6",
   "url": "https://claudecodeguides.com/mcp/bank-statement/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/bank-statement",
   "license": "https://opensource.org/licenses/MIT",
   "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD",
    "description": "Free tier: unlimited local use. Optional one-time Pro licence for the hosted endpoint."
   },
   "isPartOf": {
    "@type": "ItemList",
    "name": "Back-office MCP server collection",
    "url": "https://claudecodeguides.com/mcp/"
   }
  },
  {
   "@type": "FAQPage",
   "mainEntity": [
    {
     "@type": "Question",
     "name": "Is the Bank Statement MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Bank Statement locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Bank Statement need an API key?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "No. The server works offline against local files. If you use the hosted endpoint, the connection is authenticated with a scoped token instead of a per-tool API key."
     }
    },
    {
     "@type": "Question",
     "name": "Where does the data go?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Local installs keep everything on your machine. The hosted endpoint stores records in an isolated per-tenant namespace, and only for servers you actually call."
     }
    },
    {
     "@type": "Question",
     "name": "Which clients can use it?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Any MCP client: Claude Desktop (via the .mcpb bundle), Claude Code, Cursor, Windsurf, VS Code with an MCP extension, or your own agent over the Streamable HTTP transport."
     }
    }
   ]
  },
  {
   "@type": "BreadcrumbList",
   "itemListElement": [
    {
     "@type": "ListItem",
     "position": 1,
     "name": "Home",
     "item": "https://claudecodeguides.com/"
    },
    {
     "@type": "ListItem",
     "position": 2,
     "name": "MCP servers",
     "item": "https://claudecodeguides.com/mcp/"
    },
    {
     "@type": "ListItem",
     "position": 3,
     "name": "Bank Statement",
     "item": "https://claudecodeguides.com/mcp/bank-statement/"
    }
   ]
  }
 ]
}
</script>

# Bank Statement MCP server

Export the CSV from your bank, say "import this", and the month is readable. This MCP server turns a bank export into a local ledger: it finds the header row under whatever preamble the bank prints above it, works out which column is the date, which is the money and which way the money went, and reads amounts in the file's own locale, so `1 234,56` from mBank and `1,234.56` from a US bank both bec

**Category:** Money and accounting &middot; **Tools:** 10 &middot; **Version:** 0.22.6 &middot; **Licence:** MIT

## Install it

- **Hosted, nothing to install:** open https://mcp.zovo.one/mcp/connect - it mints a free token and prints a ready URL, `https://mcp.zovo.one/mcp/bank-statement/t/<token>`. Paste that into your client. The bare `https://mcp.zovo.one/mcp/bank-statement` hands out the tool list but answers tool calls with HTTP 401, which is why the tokenised URL is the one to use.
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.0/bank-statement.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/bank-statement`.
- **npm:** the package `@theluckystrike/mcp-bank-statement` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `statement_import` | see tool reference |
| `transactions_list` | see tool reference |
| `transactions_search` | see tool reference |
| `category_rules` | see tool reference |
| `transaction_categorize` | see tool reference |
| `statement_summary` | see tool reference |
| `reconcile_expenses` | see tool reference |
| `recurring_detect` | see tool reference |
| `statement_export` | see tool reference |
| `accounts_list` | see tool reference |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Bank Statement Pro licence — $19](https://mcp.zovo.one/buy/bank-statement&src=csg.mcp.bank-statement)

## Questions people actually ask

### Is the Bank Statement MCP server free?

Yes. Running Bank Statement locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required.

### Does Bank Statement need an API key?

No. The server works offline against local files. If you use the hosted endpoint, the connection is authenticated with a scoped token instead of a per-tool API key.

### Where does the data go?

Local installs keep everything on your machine. The hosted endpoint stores records in an isolated per-tenant namespace, and only for servers you actually call.

### Which clients can use it?

Any MCP client: Claude Desktop (via the .mcpb bundle), Claude Code, Cursor, Windsurf, VS Code with an MCP extension, or your own agent over the Streamable HTTP transport.


## Related servers in the same category

- [Invoice MCP server](/mcp/invoice/) — Make real, sendable PDF invoices from a sentence. Clients, numbering that never repeats, VAT lines, discounts 
- [Quotes MCP server](/mcp/quotes/) — Send a client a real quote in seconds: line items with VAT, a validity date, a plain-text version to paste int
- [Recurring MCP server](/mcp/recurring/) — Bill the same clients every month without remembering to. Define a recurring invoice once, then generate the r
- [Credit Note MCP server](/mcp/credit-note/) — Credit notes against an invoice or standalone: drafts, finalization, rendering, totals.

---

[All 58 back-office MCP servers](/mcp/) &middot; [how the collection is organised](/mcp/#how-it-fits-together)
