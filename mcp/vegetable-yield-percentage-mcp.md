---
layout: default
title: "Vegetable yield percentage MCP server (free, no API key)"
description: "Free MCP server for vegetable yield and trim loss. No API key: paste the hosted URL. Vegetable and fruit yield percentage, trim waste and how much…"
permalink: /mcp/vegetable-yield-percentage-mcp/
date: 2026-11-03
---

# Vegetable yield percentage MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Vegetable yield percentage MCP server",
   "alternateName": "vegetable-yield-percentage-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Vegetable and fruit yield percentage, trim waste and how much produce to buy, from USDA refuse data.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/vegetable-yield-percentage-mcp/",
   "codeRepository": "https://github.com/theluckystrike/vegetable-yield-percentage-mcp",
   "license": "https://opensource.org/licenses/MIT",
   "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD",
    "description": "Free. Hosted endpoint with no API key, or run locally with npx."
   },
   "isPartOf": {
    "@type": "ItemList",
    "name": "Free live-data MCP servers (no key)",
    "url": "https://claudecodeguides.com/mcp/#free-live-data-mcp-servers-no-key"
   }
  },
  {
   "@type": "FAQPage",
   "mainEntity": [
    {
     "@type": "Question",
     "name": "Is there an MCP server for vegetable yield and trim loss?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Vegetable yield percentage (vegetable-yield-percentage-mcp) is a free MCP server. Vegetable and fruit yield percentage, trim waste and how much produce to buy, from USDA refuse data. It is hosted at https://vegetable-yield-percentage-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/vegetable-yield-percentage-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Vegetable yield percentage MCP server need an API key?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03."
     }
    },
    {
     "@type": "Question",
     "name": "Is it free?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all."
     }
    },
    {
     "@type": "Question",
     "name": "Where do the numbers come from?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.ars.usda.gov/ARSUserFiles/80400535/DATA/SR/sr28/dnload/sr28asc.zip. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Vegetable yield percentage",
     "item": "https://claudecodeguides.com/mcp/vegetable-yield-percentage-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server for vegetable yield and trim loss? `vegetable-yield-percentage-mcp` is free, MIT licensed and needs no API key and no account. Paste https://vegetable-yield-percentage-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Vegetable and fruit yield percentage, trim waste and how much produce to buy, from USDA refuse data.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. The USDA trim loss for each item, and what it is. Corn on the cob is 36% edible (35% husk, silk and trimmings, 29% cob). Pineapple is 51% (8% core, 16% crown, 26% parings). Cauliflower is 39%, leeks 44%, asparagus 53%, bananas 64%, onions 90%, cucumbers 97%.
2. USDA household weights for the edible part. A medium onion (2-1/2 inch) is 110 g and a cup of chopped onion is 160 g, so 2 cups chopped needs about 3 medium onions and 356 g as bought.
3. The difference between as purchased and edible portion. Recipe costing, food cost and portion planning need both. The tools return both, plus the waste.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://vegetable-yield-percentage-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http vegetable-yield-percentage https://vegetable-yield-percentage-mcp.lipmichal.workers.dev/mcp
claude mcp add vegetable-yield-percentage -- npx -y github:theluckystrike/vegetable-yield-percentage-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "vegetable-yield-percentage": { "command": "npx", "args": ["-y", "github:theluckystrike/vegetable-yield-percentage-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "vegetable-yield-percentage": { "url": "https://vegetable-yield-percentage-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `get_vegetable_yield` | USDA edible yield percent for a raw vegetable or fruit (the share left after removing peel, seeds, core, stems and trimmings), the refuse percent and what the refuse... |
| `calculate_edible_weight` | Edible weight and trim waste from a purchased (as purchased, untrimmed) weight of a raw vegetable or fruit, using the USDA edible yield percent. |
| `calculate_amount_to_buy` | How much of a raw vegetable or fruit to buy for a recipe amount. |
| `list_vegetable_yields` | List raw vegetables and fruits with their USDA edible yield percent, filtered to fruit or vegetable and sorted by name, lowest yield or highest yield. |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "How many onions do I need to buy for 3 cups chopped?" and the client sent this call.

```json
{"name": "calculate_amount_to_buy", "arguments": {"food": "onion", "amount": 3, "measure": "cup chopped"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
For 3 x cup, chopped (160 g each, USDA) of onions, raw you need 480 g edible, so buy about 533 g (1.18 lb) as purchased at the USDA edible yield of 90%, or about 4.4 x medium (2-1/2" dia) (round up to 5).
```

Data as of `2015-09 (USDA National Nutrient Database for Standard Reference, Release 28; file checked 2026-11-03)`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server for vegetable yield and trim loss?

Yes. Vegetable yield percentage (vegetable-yield-percentage-mcp) is a free MCP server. Vegetable and fruit yield percentage, trim waste and how much produce to buy, from USDA refuse data. It is hosted at https://vegetable-yield-percentage-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/vegetable-yield-percentage-mcp.

### Does the Vegetable yield percentage MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.ars.usda.gov/ARSUserFiles/80400535/DATA/SR/sr28/dnload/sr28asc.zip. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/vegetable-yield-percentage-mcp](https://github.com/theluckystrike/vegetable-yield-percentage-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/vegetable-yield-percentage-mcp/](https://www.mcpstamp.com/free-servers/vegetable-yield-percentage-mcp/) on the mcpstamp.com free server list
- [Can Claude calculate vegetable yield after peeling and trimming?](https://www.mcpstamp.com/can-claude/calculate-vegetable-yield/) on mcpstamp.com, the plain-English answer with a live call
- [ingredientcalculator.com](https://ingredientcalculator.com/vegetable-yield-percentage-calculator?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=vegetable-yield-percentage-mcp), the companion site this server's results link to

## More free live-data servers

- [A/B test sample size calculator MCP server](/mcp/ab-test-sample-size-calculator-mcp/). Exact A/B test sample size, duration, z-test, chi-square, Fisher-Freeman-Halton and peeking risk.
- [ACA premium tax credit calculator MCP server](/mcp/aca-premium-tax-credit-calculator-mcp/). 2026 ACA premium tax credit: expired enhanced subsidy, 400% FPL cliff, FPL, APTC repayment rules.
- [Address to census tract MCP server](/mcp/address-to-census-tract-mcp/). US address to census tract, block group, county FIPS and districts, from the Census Geocoder.

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
