---
layout: default
title: "Time Tracker MCP server: install, tools and pricing"
description: "Track billable time without leaving your AI chat. Timers, entries, reports, CSV export and invoice line items, all stored locally."
permalink: /mcp/time-tracker/
date: 2026-10-28
---

# Time Tracker MCP server

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Time Tracker MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "Track billable time without leaving your AI chat. Timers, entries, reports, CSV export and invoice line items, all stored locally.",
   "softwareVersion": "0.22.6",
   "url": "https://claudecodeguides.com/mcp/time-tracker/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/time-tracker",
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
     "name": "Is the Time Tracker MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Time Tracker locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Time Tracker need an API key?",
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
     "name": "Time Tracker",
     "item": "https://claudecodeguides.com/mcp/time-tracker/"
    }
   ]
  }
 ]
}
</script>

Track billable time without leaving your AI chat. Say "start a timer on the acme redesign", keep working, then ask for "my hours this week by project" or "invoice lines for acme in August". It keeps a running timer, lets you log time you forgot to track, applies your hourly rate per project, and turns the result into a report, a CSV file or a set of invoice line items. Everything is stored as plai

**Category:** Time and operations &middot; **Tools:** 18 &middot; **Version:** 0.22.6 &middot; **Licence:** MIT

## Install it

- **Hosted, nothing to install:** open https://mcp.zovo.one/mcp/connect - it mints a free token and prints a ready URL, `https://mcp.zovo.one/mcp/time-tracker/t/<token>`. Paste that into your client. The bare `https://mcp.zovo.one/mcp/time-tracker` hands out the tool list but answers tool calls with HTTP 401, which is why the tokenised URL is the one to use.
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.0/time-tracker.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/time-tracker`.
- **npm:** the package `@theluckystrike/mcp-time-tracker` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `timer_start` | see tool reference |
| `timer_stop` | see tool reference |
| `timer_status` | see tool reference |
| `entry_add` | see tool reference |
| `entry_log` | see tool reference |
| `summary_day` | Summarise day |
| `summary_week` | Summarise week |
| `summary_client` | Summarise client |
| `target_set` | see tool reference |
| `target_check` | see tool reference |
| `entry_list` | see tool reference |
| `entry_delete` | see tool reference |
| `entry_edit` | see tool reference |
| `project_set_rate` | see tool reference |
| `report` | see tool reference |
| `export_csv` | Export csv |
| `entry_mark_billed` | see tool reference |
| `invoice_summary` | see tool reference |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Time Tracker Pro licence — $19](https://mcp.zovo.one/buy/time-tracker?src=hub.time-tracker)

## Questions people actually ask

### Is the Time Tracker MCP server free?

Yes. Running Time Tracker locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required.

### Does Time Tracker need an API key?

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
