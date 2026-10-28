---
layout: default
title: "Duplicate Invoice Check MCP server: install, tools and pricing"
description: "Review explainable duplicate supplier invoice candidates in a supplied local batch."
permalink: /mcp/duplicate-invoice-check/
date: 2026-10-28
---

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Duplicate Invoice Check MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "Review explainable duplicate supplier invoice candidates in a supplied local batch.",
   "softwareVersion": "0.22.8",
   "url": "https://claudecodeguides.com/mcp/duplicate-invoice-check/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/duplicate-invoice-check",
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
     "name": "Is the Duplicate Invoice Check MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Duplicate Invoice Check locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Duplicate Invoice Check need an API key?",
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
     "name": "Duplicate Invoice Check",
     "item": "https://claudecodeguides.com/mcp/duplicate-invoice-check/"
    }
   ]
  }
 ]
}
</script>

# Duplicate Invoice Check MCP server

Review a supplied batch of supplier invoices for repeated invoice numbers, conservative formatting variations, or identical amounts and invoice dates. This local MCP server returns complete grouped evidence and the exact reason each record needs review. Distinct legitimate invoices can share an amount and date. Candidates are not confirmed duplicates, fraud scores, recoverable money or payment dec

**Category:** Invoicing and billing &middot; **Tools:** 6 &middot; **Version:** 0.22.8 &middot; **Licence:** MIT

## Install it

- **Hosted, nothing to install:** `https://mcp.zovo.one/mcp/duplicate-invoice-check` — point any MCP client at that URL.
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.8/duplicate-invoice-check.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/duplicate-invoice-check`.
- **npm:** the package `@theluckystrike/mcp-duplicate-invoice-check` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `duplicate_invoice_check` | see tool reference |
| `report_list` | Report list |
| `report_get` | Report get |
| `report_page` | Report page |
| `report_delete` | Report delete |
| `report_export_csv` | Report export csv |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Duplicate Invoice Check Pro licence — $19](https://mcp.zovo.one/buy/duplicate-invoice-check&src=csg.mcp.duplicate-invoice-check)

## Questions people actually ask

### Is the Duplicate Invoice Check MCP server free?

Yes. Running Duplicate Invoice Check locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required.

### Does Duplicate Invoice Check need an API key?

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
