---
layout: default
title: "Ingredient Convert MCP server: install, tools and pricing"
description: "Cooking ingredient unit conversion with a real per-ingredient density table. Cups/tbsp/tsp/ml/fl oz/grams/ounces for 30+ ingredients, recipe scaling…"
permalink: /mcp/ingredient-convert/
date: 2026-10-28
---

# Ingredient Convert MCP server

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Ingredient Convert MCP server",
   "applicationCategory": "BusinessApplication",
   "operatingSystem": "macOS, Windows, Linux",
   "description": "Cooking ingredient unit conversion with a real per-ingredient density table. Cups/tbsp/tsp/ml/fl oz/grams/ounces for 30+ ingredients, recipe scaling with friendly fractions, bulk conversion. All local, deterministic, no network.",
   "softwareVersion": "0.1.0",
   "url": "https://claudecodeguides.com/mcp/ingredient-convert/",
   "codeRepository": "https://github.com/theluckystrike/mcp-servers/tree/main/servers/ingredient-convert",
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
     "name": "Is the Ingredient Convert MCP server free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Running Ingredient Convert locally is free and unlimited, and the code is MIT licensed. This server is local-only today, so there is nothing to pay for. No subscription and no account are required."
     }
    },
    {
     "@type": "Question",
     "name": "Does Ingredient Convert need an API key?",
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
     "name": "Ingredient Convert",
     "item": "https://claudecodeguides.com/mcp/ingredient-convert/"
    }
   ]
  }
 ]
}
</script>

Ask your assistant how much a cup of flour weighs, how many grams are in three tablespoons of honey, or what half a recipe of something looks like in cups, and get a number that comes from a density table instead of a guess. Cups, tablespoons, teaspoons, millilitres, fluid ounces, grams and ounces convert for 30+ ingredients using per-ingredient grams-per-cup values, so a cup of sugar and a cup of

**Category:** Cooking and recipes &middot; **Tools:** 7 &middot; **Version:** 0.1.0 &middot; **Licence:** MIT

## Install it

- **Hosted endpoint:** not open for this server yet - use the `.mcpb` bundle or build from source below. The other 57 servers in the suite are already hosted.
- **Claude Desktop:** build from the repository and add it to `claude_desktop_config.json`.
- **From source:** `git clone https://github.com/theluckystrike/mcp-servers` then build `servers/ingredient-convert`.
- **npm:** the package `@theluckystrike/mcp-ingredient-convert` is staged and publishes shortly; the `.mcpb` bundle is the supported install until then.

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `convert_ingredient` | Convert ingredient |
| `list_ingredients` | List ingredients |
| `scale_recipe` | see tool reference |
| `convert_bulk` | Convert bulk |
| `decimal_to_fraction` | see tool reference |
| `fraction_to_decimal` | see tool reference |
| `common_conversions` | see tool reference |

## Pricing

Free to run locally, forever. The **Pro licence is $19, one time, lifetime** — it changes only the
hosted endpoint's saved-report cap, never the tools. All 59 servers together are
[$39 as a bundle](/mcp/#pricing) instead of $1102 bought one at a time.

[Buy the Ingredient Convert Pro licence — $19](https://mcp.zovo.one/buy/ingredient-convert?src=hub.ingredient-convert)

## Questions people actually ask

### Is the Ingredient Convert MCP server free?

Yes. Running Ingredient Convert locally is free and unlimited, and the code is MIT licensed. This server is local-only today, so there is nothing to pay for. No subscription and no account are required.

### Does Ingredient Convert need an API key?

No. The server works offline against local files.

### Where does the data go?

Local installs keep everything on your machine. The hosted endpoint stores records in an isolated per-tenant namespace, and only for servers you actually call.

### Which clients can use it?

Any MCP client: Claude Desktop (via the .mcpb bundle), Claude Code, Cursor, Windsurf, VS Code with an MCP extension, or your own agent over the Streamable HTTP transport.


## Related servers in the same category

- [McpStamp Invoices MCP server](/mcp/invoice/) — Make real, sendable PDF invoices from a sentence. Clients, numbering that never repeats, VAT lines, discounts 
- [McpStamp Quotes MCP server](/mcp/quotes/) — Send a client a real quote in seconds: line items with VAT, a validity date, a plain-text version to paste int
- [McpStamp Recurring Invoices MCP server](/mcp/recurring/) — Bill the same clients every month without remembering to. Define a recurring invoice once, then generate the r
- [Credit Note MCP server](/mcp/credit-note/) — Credit notes against an invoice or standalone: drafts, finalization, rendering, totals.

---

[All 59 back-office MCP servers](/mcp/) &middot; [how the collection is organised](/mcp/#how-it-fits-together)
