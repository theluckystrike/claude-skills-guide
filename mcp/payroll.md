---
layout: default
title: "Payroll MCP server: install, tools and pricing"
description: "MCP server: payroll"
permalink: /mcp/payroll/
date: 2026-10-28
---

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Payroll MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "MCP server: payroll",
   "softwareVersion": "0.22.6",
   "url": "https://claudecodeguides.com/mcp/payroll/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/payroll",
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
     "name": "Is the Payroll MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Payroll locally is free and unlimited, and the code is MIT licensed. This server is local-only today, so there is nothing to pay for. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Payroll need an API key?",
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
     "name": "Payroll",
     "item": "https://claudecodeguides.com/mcp/payroll/"
    }
   ]
  }
 ]
}
</script>

# Payroll MCP server

Give Claude (or any MCP client) a payroll estimator: `payroll_run` turns hours worked × hourly rate − tax rate into gross pay, tax withheld and net pay; `payroll_invoice_total` sums a batch of runs into one payroll total. For solo operators, small teams and anyone who pays hourly people and wants the arithmetic done right the first time.

**Category:** Money and accounting &middot; **Tools:** 0 &middot; **Version:** 0.22.6 &middot; **Licence:** MIT

## Install it

- **Hosted endpoint:** not open for this server yet - use the `.mcpb` bundle or build from source below. The other 46 servers in the suite are already hosted.
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.0/payroll.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/payroll`.
- **npm:** the package `mcp-payroll` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

_The tool list is published in the server manifest (`server.json`) and the repository README._

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Payroll Pro licence — $19](https://mcp.zovo.one/buy/payroll?src=hub.payroll)

## Questions people actually ask

### Is the Payroll MCP server free?

Yes. Running Payroll locally is free and unlimited, and the code is MIT licensed. This server is local-only today, so there is nothing to pay for. No subscription and no account are required.

### Does Payroll need an API key?

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
