---
layout: default
title: "Clauses MCP server: install, tools and pricing"
description: "A personal library of reusable contract and proposal clauses: 25 generic freelance starters with {variables}, ranked search, and one-call assembly…"
permalink: /mcp/clauses/
date: 2026-10-28
---

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Clauses MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "A personal library of reusable contract and proposal clauses: 25 generic freelance starters with {variables}, ranked search, and one-call assembly into a real Word .docx with every missing fact left as a bracketed prompt. Everything stays on your machine.",
   "softwareVersion": "0.22.6",
   "url": "https://claudecodeguides.com/mcp/clauses/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/clauses",
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
     "name": "Is the Clauses MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Clauses locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Clauses need an API key?",
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
     "name": "Clauses",
     "item": "https://claudecodeguides.com/mcp/clauses/"
    }
   ]
  }
 ]
}
</script>

# Clauses MCP server

Say "draft a service agreement for Beta Corp, 4,500 EUR, 14-day terms" and get a real `.docx` built from your own clause library. This MCP server keeps the contract and proposal paragraphs you reuse, scope, payment terms, late fees, IP assignment, confidentiality, termination, liability cap and twenty more, as searchable clauses with `{variables}` in them. It ships with 25 generic freelance star

**Category:** Documents and files &middot; **Tools:** 10 &middot; **Version:** 0.22.6 &middot; **Licence:** MIT

## Install it

- **Hosted, nothing to install:** open https://mcp.zovo.one/mcp/connect - it mints a free token and prints a ready URL, `https://mcp.zovo.one/mcp/clauses/t/<token>`. Paste that into your client. The bare `https://mcp.zovo.one/mcp/clauses` hands out the tool list but answers tool calls with HTTP 401, which is why the tokenised URL is the one to use.
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.0/clauses.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/clauses`.
- **npm:** the package `@theluckystrike/mcp-clauses` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `clause_add` | see tool reference |
| `clause_get` | see tool reference |
| `clause_update` | see tool reference |
| `clause_delete` | see tool reference |
| `clause_list` | see tool reference |
| `clause_search` | see tool reference |
| `clause_import` | see tool reference |
| `clause_export` | see tool reference |
| `contract_assemble` | see tool reference |
| `variables_list` | see tool reference |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Clauses Pro licence — $19](https://mcp.zovo.one/buy/clauses?src=hub.clauses)

## Questions people actually ask

### Is the Clauses MCP server free?

Yes. Running Clauses locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required.

### Does Clauses need an API key?

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
