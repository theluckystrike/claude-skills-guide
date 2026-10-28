---
layout: default
title: "Pdf MCP server: install, tools and pricing"
description: "Merge, split, extract, rotate, reorder and stamp PDF files from chat: mark an invoice PAID, pull pages out of a scan, join a set of documents into one"
permalink: /mcp/pdf/
date: 2026-10-28
---

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Pdf MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "Merge, split, extract, rotate, reorder and stamp PDF files from chat: mark an invoice PAID, pull pages out of a scan, join a set of documents into one. Everything stays on your machine.",
   "softwareVersion": "0.22.6",
   "url": "https://claudecodeguides.com/mcp/pdf/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/pdf",
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
     "name": "Is the Pdf MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Pdf locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Pdf need an API key?",
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
     "name": "Pdf",
     "item": "https://claudecodeguides.com/mcp/pdf/"
    }
   ]
  }
 ]
}
</script>

# Pdf MCP server

Say "stamp PAID on that invoice and save a copy" or "pull pages 2 to 6 out of this scan and merge them with the contract" and it happens, on your machine, in a second. This MCP server does the small PDF jobs that otherwise send you to a web uploader: merge, split by page range, extract or reorder pages, rotate a sideways scan, stamp `PAID` or `DRAFT` or any text you like, put your business name an

**Category:** Documents and files &middot; **Tools:** 10 &middot; **Version:** 0.22.6 &middot; **Licence:** MIT

## Install it

- **Hosted, nothing to install:** `https://mcp.zovo.one/mcp/pdf` — point any MCP client at that URL.
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.0/pdf.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/pdf`.
- **npm:** the package `@theluckystrike/mcp-pdf` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `pdf_info` | see tool reference |
| `pdf_count` | see tool reference |
| `pdf_merge` | see tool reference |
| `pdf_split` | see tool reference |
| `pdf_pages` | see tool reference |
| `pdf_rotate` | see tool reference |
| `pdf_stamp` | see tool reference |
| `pdf_watermark_business` | see tool reference |
| `pdf_reorder` | see tool reference |
| `pdf_text` | see tool reference |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Pdf Pro licence — $19](https://mcp.zovo.one/buy/pdf&src=csg.mcp.pdf)

## Questions people actually ask

### Is the Pdf MCP server free?

Yes. Running Pdf locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required.

### Does Pdf need an API key?

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
