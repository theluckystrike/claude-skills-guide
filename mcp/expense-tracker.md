---
layout: default
title: "Expense Tracker MCP server: install, tools and pricing"
description: "Local expenses, receipts and mileage ledger for freelancers: categorise, split VAT, summarise, export to CSV or xlsx and rebill straight into an…"
permalink: /mcp/expense-tracker/
date: 2026-10-28
---

# Expense Tracker MCP server

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Expense Tracker MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "Local expenses, receipts and mileage ledger for freelancers: categorise, split VAT, summarise, export to CSV or xlsx and rebill straight into an invoice.",
   "softwareVersion": "0.22.9",
   "url": "https://claudecodeguides.com/mcp/expense-tracker/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/expense-tracker",
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
     "name": "Is the Expense Tracker MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Expense Tracker locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Expense Tracker need an API key?",
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
     "name": "Expense Tracker",
     "item": "https://claudecodeguides.com/mcp/expense-tracker/"
    }
   ]
  }
 ]
}
</script>

Say "12.30 euros at Adobe, software, billable to Acme" and it is logged, categorised, VAT-split and ready to rebill. This MCP server keeps a local ledger of your business expenses: every amount is held in integer minor units in its own currency, `vat_rate` splits the gross on the receipt into net and VAT (set it once with `expense_settings` and every later expense is split without repeating it), m

**Category:** Money and accounting &middot; **Tools:** 12 &middot; **Version:** 0.22.9 &middot; **Licence:** MIT

## Install it

- **Hosted, nothing to install:** open https://mcp.zovo.one/mcp/connect - it mints a free token and prints a ready URL, `https://mcp.zovo.one/mcp/expense-tracker/t/<token>`. Paste that into your client. The bare `https://mcp.zovo.one/mcp/expense-tracker` hands out the tool list but answers tool calls with HTTP 401, which is why the tokenised URL is the one to use.
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.9/expense-tracker.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/expense-tracker`.
- **npm:** the package `@theluckystrike/mcp-expense-tracker` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `expense_add` | see tool reference |
| `expense_list` | see tool reference |
| `expense_update` | see tool reference |
| `expense_delete` | see tool reference |
| `receipt_attach` | see tool reference |
| `category_rules` | see tool reference |
| `expense_settings` | see tool reference |
| `expense_summary` | see tool reference |
| `mileage_add` | see tool reference |
| `expense_export` | see tool reference |
| `expense_to_invoice` | see tool reference |
| `expense_mark_rebilled` | see tool reference |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Expense Tracker Pro licence — $19](https://mcp.zovo.one/buy/expense-tracker?src=hub.expense-tracker)

## Questions people actually ask

### Is the Expense Tracker MCP server free?

Yes. Running Expense Tracker locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required.

### Does Expense Tracker need an API key?

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
