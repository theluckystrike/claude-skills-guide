---
layout: default
title: "Credit Note MCP server: install, tools and pricing"
description: "Credit notes against an invoice or standalone: drafts, finalization, rendering, totals."
permalink: /mcp/credit-note/
date: 2026-10-28
---

# Credit Note MCP server

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Credit Note MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "Credit notes against an invoice or standalone: drafts, finalization, rendering, totals.",
   "softwareVersion": "0.22.8",
   "url": "https://claudecodeguides.com/mcp/credit-note/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/credit-note",
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
     "name": "Is the Credit Note MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Credit Note locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Credit Note need an API key?",
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
     "name": "Credit Note",
     "item": "https://claudecodeguides.com/mcp/credit-note/"
    }
   ]
  }
 ]
}
</script>

Credit notes against an invoice or standalone: drafts, finalization, rendering, totals.

**Category:** Invoicing and billing &middot; **Tools:** 8 &middot; **Version:** 0.22.8 &middot; **Licence:** MIT

## Install it

- **Hosted, nothing to install:** open https://mcp.zovo.one/mcp/connect - it mints a free token and prints a ready URL, `https://mcp.zovo.one/mcp/credit-note/t/<token>`. Paste that into your client. The bare `https://mcp.zovo.one/mcp/credit-note` hands out the tool list but answers tool calls with HTTP 401, which is why the tokenised URL is the one to use.
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.0/credit-note.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/credit-note`.
- **npm:** the package `@theluckystrike/mcp-credit-note` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `credit_note_create` | see tool reference |
| `credit_note_update` | see tool reference |
| `credit_note_finalize` | see tool reference |
| `credit_note_list` | see tool reference |
| `credit_note_get` | see tool reference |
| `credit_note_delete` | see tool reference |
| `credit_note_render` | see tool reference |
| `credit_note_summary` | see tool reference |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Credit Note Pro licence — $19](https://mcp.zovo.one/buy/credit-note?src=hub.credit-note)

## Questions people actually ask

### Is the Credit Note MCP server free?

Yes. Running Credit Note locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required.

### Does Credit Note need an API key?

No. The server works offline against local files. If you use the hosted endpoint, the connection is authenticated with a scoped token instead of a per-tool API key.

### Where does the data go?

Local installs keep everything on your machine. The hosted endpoint stores records in an isolated per-tenant namespace, and only for servers you actually call.

### Which clients can use it?

Any MCP client: Claude Desktop (via the .mcpb bundle), Claude Code, Cursor, Windsurf, VS Code with an MCP extension, or your own agent over the Streamable HTTP transport.


## Related servers in the same category

- [Invoice MCP server](/mcp/invoice/) — Make real, sendable PDF invoices from a sentence. Clients, numbering that never repeats, VAT lines, discounts 
- [Quotes MCP server](/mcp/quotes/) — Send a client a real quote in seconds: line items with VAT, a validity date, a plain-text version to paste int
- [Recurring MCP server](/mcp/recurring/) — Bill the same clients every month without remembering to. Define a recurring invoice once, then generate the r
- [Dunning Letters MCP server](/mcp/dunning-letters/) — Chase overdue invoices: reminder 1, reminder 2, final notice, escalation dates, aging.

---

[All 58 back-office MCP servers](/mcp/) &middot; [how the collection is organised](/mcp/#how-it-fits-together)
