---
layout: default
title: "Packing List MCP server: install, tools and pricing"
description: "Packing slips: cartons, contents, weights, chargeable weight and what is still to pack."
permalink: /mcp/packing-list/
date: 2026-10-28
---

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Packing List MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "Packing slips: cartons, contents, weights, chargeable weight and what is still to pack.",
   "softwareVersion": "0.22.8",
   "url": "https://claudecodeguides.com/mcp/packing-list/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/packing-list",
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
     "name": "Is the Packing List MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Packing List locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Packing List need an API key?",
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
     "name": "Packing List",
     "item": "https://claudecodeguides.com/mcp/packing-list/"
    }
   ]
  }
 ]
}
</script>

# Packing List MCP server

That is not a simplification, it is what the document is for: it travels inside the box, and the consignee's warehouse is not the party that sees what the goods cost. The invoice against the same order is a different document and lives in `@theluckystrike/mcp-invoice`. There is no money arithmetic in this server at all, and a test asserts there is not.

**Category:** Documents and files &middot; **Tools:** 12 &middot; **Version:** 0.22.8 &middot; **Licence:** MIT

## Install it

- **Hosted, nothing to install:** open https://mcp.zovo.one/mcp/connect - it mints a free token and prints a ready URL, `https://mcp.zovo.one/mcp/packing-list/t/<token>`. Paste that into your client. The bare `https://mcp.zovo.one/mcp/packing-list` hands out the tool list but answers tool calls with HTTP 401, which is why the tokenised URL is the one to use.
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.0/packing-list.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/packing-list`.
- **npm:** the package `@theluckystrike/mcp-packing-list` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `packing_list_create` | see tool reference |
| `packing_expect` | see tool reference |
| `carton_add` | see tool reference |
| `pack_item` | see tool reference |
| `unpack_item` | see tool reference |
| `packing_list_show` | see tool reference |
| `packing_list_list` | see tool reference |
| `carton_report` | see tool reference |
| `packing_shortfall` | see tool reference |
| `packing_list_status` | see tool reference |
| `packing_slip` | see tool reference |
| `packing_list_delete` | see tool reference |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Packing List Pro licence — $19](https://mcp.zovo.one/buy/packing-list&src=csg.mcp.packing-list)

## Questions people actually ask

### Is the Packing List MCP server free?

Yes. Running Packing List locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required.

### Does Packing List need an API key?

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
