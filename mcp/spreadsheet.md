---
layout: default
title: "Spreadsheet MCP server: install, tools and pricing"
description: "Open, inspect, query, edit and convert xlsx and csv files locally from your AI assistant"
permalink: /mcp/spreadsheet/
date: 2026-10-28
---

# Spreadsheet MCP server

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Spreadsheet MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "Open, inspect, query, edit and convert xlsx and csv files locally from your AI assistant",
   "softwareVersion": "0.22.9",
   "url": "https://claudecodeguides.com/mcp/spreadsheet/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/spreadsheet",
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
     "name": "Is the Spreadsheet MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Spreadsheet locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Spreadsheet need an API key?",
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
     "name": "Spreadsheet",
     "item": "https://claudecodeguides.com/mcp/spreadsheet/"
    }
   ]
  }
 ]
}
</script>

Hand your AI assistant a spreadsheet and talk to it. Point it at any `.xlsx`, `.xlsm`, `.xlsb`, `.xls`, `.ods`, `.csv` or `.tsv` file on your machine and ask what is in it, filter it, compute a new column, or save it in another format. It handles the messy parts of real files for you: it guesses which row holds the headers, sniffs whether a CSV is separated by commas, semicolons or tabs, keeps quo

**Category:** Documents and files &middot; **Tools:** 8 &middot; **Version:** 0.22.9 &middot; **Licence:** MIT

## Install it

- **Hosted, nothing to install:** open https://mcp.zovo.one/mcp/connect - it mints a free token and prints a ready URL, `https://mcp.zovo.one/mcp/spreadsheet/t/<token>`. Paste that into your client. The bare `https://mcp.zovo.one/mcp/spreadsheet` hands out the tool list but answers tool calls with HTTP 401, which is why the tokenised URL is the one to use.
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.9/spreadsheet.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/spreadsheet`.
- **npm:** the package `@theluckystrike/mcp-spreadsheet` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `sheet_info` | see tool reference |
| `sheet_read` | see tool reference |
| `sheet_query` | see tool reference |
| `sheet_stats` | see tool reference |
| `sheet_find` | see tool reference |
| `sheet_write` | see tool reference |
| `sheet_add_column` | see tool reference |
| `sheet_convert` | see tool reference |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Spreadsheet Pro licence — $19](https://mcp.zovo.one/buy/spreadsheet?src=hub.spreadsheet)

## Questions people actually ask

### Is the Spreadsheet MCP server free?

Yes. Running Spreadsheet locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required.

### Does Spreadsheet need an API key?

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
