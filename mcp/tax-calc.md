---
layout: default
title: "Tax Calc MCP server: install, tools and pricing"
description: "MCP server: tax-calc"
permalink: /mcp/tax-calc/
date: 2026-10-28
---

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Tax Calc MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "MCP server: tax-calc",
   "softwareVersion": "0.22.6",
   "url": "https://claudecodeguides.com/mcp/tax-calc/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/tax-calc",
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
     "name": "Is the Tax Calc MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Tax Calc locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Tax Calc need an API key?",
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
     "name": "Tax Calc",
     "item": "https://claudecodeguides.com/mcp/tax-calc/"
    }
   ]
  }
 ]
}
</script>

# Tax Calc MCP server

Give Claude (or any MCP client) a tax estimator: `us_federal_tax` applies the 2026 US federal brackets for a single filer — including the $15,750 standard deduction — and returns total tax, effective rate, and marginal bracket. Planning numbers, computed on your machine, in one sentence.

**Category:** Money and accounting &middot; **Tools:** 0 &middot; **Version:** 0.22.6 &middot; **Licence:** MIT

## Install it

- **Hosted, nothing to install:** `https://mcp.zovo.one/mcp/tax-calc` — point any MCP client at that URL.
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.0/tax-calc.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/tax-calc`.
- **npm:** the package `mcp-tax-calc` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

_The tool list is published in the server manifest (`server.json`) and the repository README._

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Tax Calc Pro licence — $19](https://mcp.zovo.one/buy/tax-calc&src=csg.mcp.tax-calc)

## Questions people actually ask

### Is the Tax Calc MCP server free?

Yes. Running Tax Calc locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required.

### Does Tax Calc need an API key?

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
