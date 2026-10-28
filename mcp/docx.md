---
layout: default
title: "Docx MCP server: install, tools and pricing"
description: "Turn a chat into a real Word document: proposals, quotes, contracts, statements of work and letters as .docx files, plus reading and filling…"
permalink: /mcp/docx/
date: 2026-10-28
---

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Docx MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "Turn a chat into a real Word document: proposals, quotes, contracts, statements of work and letters as .docx files, plus reading and filling existing .docx templates. Everything stays on your machine.",
   "softwareVersion": "0.22.6",
   "url": "https://claudecodeguides.com/mcp/docx/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/docx",
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
     "name": "Is the Docx MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Docx locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Docx need an API key?",
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
     "name": "Docx",
     "item": "https://claudecodeguides.com/mcp/docx/"
    }
   ]
  }
 ]
}
</script>

# Docx MCP server

Say "write a proposal for Beta Corp, checkout rebuild, 4,500 EUR, three phases" and get a real `.docx` you can send. This MCP server writes Word documents from chat, proposals, quotes, service agreements, statements of work and letters, with your letterhead, headings, bullet and numbered lists and tables. It also turns markdown into `.docx`, reads an existing `.docx` back as text and outline, and 

**Category:** Documents and files &middot; **Tools:** 9 &middot; **Version:** 0.22.6 &middot; **Licence:** MIT

## Install it

- **Hosted, nothing to install:** `https://mcp.zovo.one/mcp/docx` — point any MCP client at that URL.
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.0/docx.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/docx`.
- **npm:** the package `@theluckystrike/mcp-docx` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `business_set` | see tool reference |
| `doc_create` | see tool reference |
| `doc_from_markdown` | see tool reference |
| `doc_read` | see tool reference |
| `doc_to_html` | see tool reference |
| `doc_fill_template` | see tool reference |
| `proposal_create` | see tool reference |
| `proposal_update` | see tool reference |
| `contract_create` | see tool reference |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Docx Pro licence — $19](https://mcp.zovo.one/buy/docx&src=csg.mcp.docx)

## Questions people actually ask

### Is the Docx MCP server free?

Yes. Running Docx locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required.

### Does Docx need an API key?

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
