---
layout: default
title: "Barcode MCP server: install, tools and pricing"
description: "QR codes and barcodes from chat: URLs, WiFi joins, vCards, SEPA payment QR that a banking app can scan, Code 128 and EAN-13, as SVG or PNG. No…"
permalink: /mcp/barcode/
date: 2026-10-28
---

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Barcode MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "QR codes and barcodes from chat: URLs, WiFi joins, vCards, SEPA payment QR that a banking app can scan, Code 128 and EAN-13, as SVG or PNG. No network, no account.",
   "softwareVersion": "0.22.6",
   "url": "https://claudecodeguides.com/mcp/barcode/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/barcode",
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
     "name": "Is the Barcode MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Barcode locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Barcode need an API key?",
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
     "name": "Barcode",
     "item": "https://claudecodeguides.com/mcp/barcode/"
    }
   ]
  }
 ]
}
</script>

# Barcode MCP server

Make a QR code or a barcode in the conversation you are already in. Paste a URL and get a QR code you can put on a flyer. Give a client's invoice an EPC payment code their banking app scans and fills in for them. Print an EAN-13 for a product, a Code 128 for a shelf label, a WiFi code for the office wall, a vCard for a conference badge. Everything is drawn on your machine: no upload, no account, n

**Category:** Documents and files &middot; **Tools:** 8 &middot; **Version:** 0.22.6 &middot; **Licence:** MIT

## Install it

- **Hosted, nothing to install:** open https://mcp.zovo.one/mcp/connect - it mints a free token and prints a ready URL, `https://mcp.zovo.one/mcp/barcode/t/<token>`. Paste that into your client. The bare `https://mcp.zovo.one/mcp/barcode` hands out the tool list but answers tool calls with HTTP 401, which is why the tokenised URL is the one to use.
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.0/barcode.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/barcode`.
- **npm:** the package `@theluckystrike/mcp-barcode` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `qr_create` | see tool reference |
| `qr_wifi` | see tool reference |
| `qr_vcard` | see tool reference |
| `qr_payment_sepa` | see tool reference |
| `invoice_payment_qr` | see tool reference |
| `barcode_create` | see tool reference |
| `barcode_batch` | see tool reference |
| `code_list` | see tool reference |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Barcode Pro licence — $19](https://mcp.zovo.one/buy/barcode&src=csg.mcp.barcode)

## Questions people actually ask

### Is the Barcode MCP server free?

Yes. Running Barcode locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required.

### Does Barcode need an API key?

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
