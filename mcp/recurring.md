---
layout: default
title: "Recurring MCP server: install, tools and pricing"
description: "Bill the same clients every month without remembering to. Define a recurring invoice once, then generate the real PDFs that are due into your…"
permalink: /mcp/recurring/
date: 2026-10-28
---

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Recurring MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "Bill the same clients every month without remembering to. Define a recurring invoice once, then generate the real PDFs that are due into your invoice server, with month-end safe dates, an audit log and a revenue forecast. Everything stays on your machine.",
   "softwareVersion": "0.22.6",
   "url": "https://claudecodeguides.com/mcp/recurring/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/recurring",
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
     "name": "Is the Recurring MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Recurring locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Recurring need an API key?",
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
     "name": "Recurring",
     "item": "https://claudecodeguides.com/mcp/recurring/"
    }
   ]
  }
 ]
}
</script>

# Recurring MCP server

Say "bill Acme 12 hours at 90 EUR on the 1st of every month" once, and stop remembering it. This MCP server stores recurring invoice schedules, client, line items, cadence, start and end dates, and then, when you ask, creates the invoices that have actually fallen due as real records in the invoice server, with its number series, its clients and its A4 PDF. Generation is idempotent: one invoice pe

**Category:** Invoicing and billing &middot; **Tools:** 12 &middot; **Version:** 0.22.6 &middot; **Licence:** MIT

## Install it

- **Hosted, nothing to install:** `https://mcp.zovo.one/mcp/recurring` - point any MCP client at that URL (Streamable HTTP, verified with a live MCP handshake).
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.0/recurring.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/recurring`.
- **npm:** the package `@theluckystrike/mcp-recurring` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `schedule_create` | see tool reference |
| `schedule_list` | see tool reference |
| `schedule_get` | see tool reference |
| `schedule_update` | see tool reference |
| `schedule_pause` | see tool reference |
| `schedule_resume` | see tool reference |
| `schedule_delete` | see tool reference |
| `schedule_skip` | see tool reference |
| `schedule_upcoming` | see tool reference |
| `invoice_generate_due` | see tool reference |
| `schedule_history` | see tool reference |
| `forecast` | see tool reference |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Recurring Pro licence — $19](https://mcp.zovo.one/buy/recurring&src=csg.mcp.recurring)

## Questions people actually ask

### Is the Recurring MCP server free?

Yes. Running Recurring locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required.

### Does Recurring need an API key?

No. The server works offline against local files. If you use the hosted endpoint, the connection is authenticated with a scoped token instead of a per-tool API key.

### Where does the data go?

Local installs keep everything on your machine. The hosted endpoint stores records in an isolated per-tenant namespace, and only for servers you actually call.

### Which clients can use it?

Any MCP client: Claude Desktop (via the .mcpb bundle), Claude Code, Cursor, Windsurf, VS Code with an MCP extension, or your own agent over the Streamable HTTP transport.


## Related servers in the same category

- [Invoice MCP server](/mcp/invoice/) — Make real, sendable PDF invoices from a sentence. Clients, numbering that never repeats, VAT lines, discounts 
- [Quotes MCP server](/mcp/quotes/) — Send a client a real quote in seconds: line items with VAT, a validity date, a plain-text version to paste int
- [Credit Note MCP server](/mcp/credit-note/) — Credit notes against an invoice or standalone: drafts, finalization, rendering, totals.
- [Dunning Letters MCP server](/mcp/dunning-letters/) — Chase overdue invoices: reminder 1, reminder 2, final notice, escalation dates, aging.

---

[All 58 back-office MCP servers](/mcp/) &middot; [how the collection is organised](/mcp/#how-it-fits-together)
