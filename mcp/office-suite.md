---
layout: default
title: "Office Suite MCP server: install, tools and pricing"
description: "One install for the whole freelancer office suite: time tracking, price watching, spreadsheets and PDF invoicing, proxied behind a single MCP server."
permalink: /mcp/office-suite/
date: 2026-10-28
---

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Office Suite MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "One install for the whole freelancer office suite: time tracking, price watching, spreadsheets and PDF invoicing, proxied behind a single MCP server.",
   "softwareVersion": "0.25.0",
   "url": "https://claudecodeguides.com/mcp/office-suite/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/office-suite",
   "license": "https://opensource.org/licenses/MIT",
   "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD",
    "description": "Free: unlimited local use, MIT licensed. No hosted tier for this server yet."
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
     "name": "Is the Office Suite MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Office Suite locally is free and unlimited, and the code is MIT licensed. This server is local-only today, so there is nothing to pay for. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Office Suite need an API key?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "No. The server works offline against local files."
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
     "name": "Office Suite",
     "item": "https://claudecodeguides.com/mcp/office-suite/"
    }
   ]
  }
 ]
}
</script>

# Office Suite MCP server

Run the freelancer office from one MCP config entry. The v0.25.0 bundle initializes 50 local child servers and exposes 453 tools, measured over MCP on 2026-10-26. It includes time tracking, invoices, spreadsheets, quotes, expenses and the supplier-invoice three-way matcher duplicate invoice candidate review, and supplier statement open-item checks against AP ledger exports. The proxy forwards tool

**Category:** Invoicing and billing &middot; **Tools:** 3 &middot; **Version:** 0.25.0 &middot; **Licence:** MIT

## Install it

- **Hosted endpoint:** not open for this server yet - use the `.mcpb` bundle or build from source below. The other 46 servers in the suite are already hosted.
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.25.0/office-suite.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/office-suite`.
- **npm:** the package `@theluckystrike/mcp-office-suite` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `license_status` | see tool reference |
| `license_activate` | see tool reference |
| `tools_map` | see tool reference |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Office Suite Pro licence — $19](https://mcp.zovo.one/buy/office-suite?src=hub.office-suite)

## Questions people actually ask

### Is the Office Suite MCP server free?

Yes. Running Office Suite locally is free and unlimited, and the code is MIT licensed. This server is local-only today, so there is nothing to pay for. No subscription and no account are required.

### Does Office Suite need an API key?

No. The server works offline against local files.

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
