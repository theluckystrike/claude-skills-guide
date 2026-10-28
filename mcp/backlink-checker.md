---
layout: default
title: "Backlink Checker MCP server: install, tools and pricing"
description: "Check backlinks from Claude or Cursor: does a page link to your domain, dofollow or nofollow, with anchor text, HTTP status and robots guards. All…"
permalink: /mcp/backlink-checker/
date: 2026-10-28
---

# Backlink Checker MCP server

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Backlink Checker MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "Check backlinks from Claude or Cursor: does a page link to your domain, dofollow or nofollow, with anchor text, HTTP status and robots guards. All checks run on demand, nothing stored.",
   "softwareVersion": "0.22.6",
   "url": "https://claudecodeguides.com/mcp/backlink-checker/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/backlink-checker",
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
     "name": "Is the Backlink Checker MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Backlink Checker locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Backlink Checker need an API key?",
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
     "name": "Backlink Checker",
     "item": "https://claudecodeguides.com/mcp/backlink-checker/"
    }
   ]
  }
 ]
}
</script>

Nothing is stored. Every call fetches the page live, parses the anchor, applies the robots guards, and reports - so a verdict is always about the page as it is now, never as it was.

**Category:** Web and SEO &middot; **Tools:** 6 &middot; **Version:** 0.22.6 &middot; **Licence:** MIT

## Install it

- **Hosted, nothing to install:** open https://mcp.zovo.one/mcp/connect - it mints a free token and prints a ready URL, `https://mcp.zovo.one/mcp/backlink-checker/t/<token>`. Paste that into your client. The bare `https://mcp.zovo.one/mcp/backlink-checker` hands out the tool list but answers tool calls with HTTP 401, which is why the tokenised URL is the one to use.
- **Claude Desktop, one click:** [download the `.mcpb` bundle](https://github.com/theluckystrike/mcp-servers/releases/download/v0.22.0/backlink-checker.mcpb)
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/backlink-checker`.
- **npm:** the package `@theluckystrike/mcp-backlink-checker` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `link_check` | see tool reference |
| `link_audit` | see tool reference |
| `anchor_profile` | see tool reference |
| `referring_domain_summary` | see tool reference |
| `outreach_queue` | see tool reference |
| `robots_guard_check` | see tool reference |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 58 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Backlink Checker Pro licence — $19](https://mcp.zovo.one/buy/backlink-checker?src=hub.backlink-checker)

## Questions people actually ask

### Is the Backlink Checker MCP server free?

Yes. Running Backlink Checker locally is free and unlimited, and the code is MIT licensed. There is a one-time $19 Pro licence for the hosted endpoint, which removes the saved-report cap. No subscription and no account are required.

### Does Backlink Checker need an API key?

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
