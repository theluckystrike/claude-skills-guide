---
layout: default
title: "Cups to grams converter MCP server (free, no API key)"
description: "Free MCP server that converts cups to grams by ingredient. No API key: paste the hosted URL. Cups to grams for 271 ingredients with USDA and King…"
permalink: /mcp/cups-to-grams-mcp/
date: 2026-11-03
---

# Cups to grams converter MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Cups to grams converter MCP server",
   "alternateName": "cups-to-grams-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Cups to grams for 271 ingredients with USDA and King Arthur densities, recipe scaling, oven temps.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/cups-to-grams-mcp/",
   "codeRepository": "https://github.com/theluckystrike/cups-to-grams-mcp",
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
     "name": "Is there an MCP server that converts cups to grams by ingredient?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Cups to grams converter (cups-to-grams-mcp) is a free MCP server. Cups to grams for 271 ingredients with USDA and King Arthur densities, recipe scaling, oven temps. It is hosted at https://cups-to-grams-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/cups-to-grams-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Cups to grams converter MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.kingarthurbaking.com/learn/ingredient-weight-chart. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Cups to grams converter",
     "item": "https://claudecodeguides.com/mcp/cups-to-grams-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that converts cups to grams by ingredient? `cups-to-grams-mcp` is free, MIT licensed and needs no API key and no account. Paste https://cups-to-grams-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Cups to grams for 271 ingredients with USDA and King Arthur densities, recipe scaling, oven temps.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. Measured weights. A cup of all-purpose flour is 120 g, granulated sugar 200 g, butter 227 g, honey 339 g, water 237 g. Models often apply one density to everything or mix up fluid ounces and weight ounces. Each of the 271 rows carries its source, and USDA rows carry the FDC id.
2. Which cup. A US cup is 236.5882365 mL, a metric cup 250 mL, an imperial cup 284.13 mL, the US nutrition-label cup 240 mL and a Japanese cup 200 mL. A 1 cup of flour in an Australian recipe is about 127 g, not 120 g. The server states the cup it used.
3. Exact unit constants. US units come from the US gallon of 231 cubic inches (NIST SP 811). Imperial units come from the UK Weights and Measures Act 1985 (gallon = 4.54609 L). The pound is exactly 453.59237 g.
4. Where published tables disagree. For 23 ingredients USDA and King Arthur differ by more than 5% (cornstarch, bread flour, oats, baking soda and others). The result names the value used and lists the other published value, so the user can see the spread.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://cups-to-grams-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http cups-to-grams https://cups-to-grams-mcp.lipmichal.workers.dev/mcp
claude mcp add cups-to-grams -- npx -y github:theluckystrike/cups-to-grams-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "cups-to-grams": { "command": "npx", "args": ["-y", "github:theluckystrike/cups-to-grams-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "cups-to-grams": { "url": "https://cups-to-grams-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `convert_ingredient` | Converts a kitchen amount between volume and weight for a specific ingredient, using measured grams-per-cup values (USDA FoodData Central portion weights with FDC ids... |
| `search_ingredients` | Fuzzy search over the ingredient table (flours, sugars, fats, dairy, liquids, nuts, grains, fruit, produce). |
| `scale_recipe` | Scales a list of recipe ingredient lines ("1 1/2 cups all-purpose flour", "2 tbsp honey", "3 eggs") by a factor or from original to target servings. |
| `convert_oven_temperature` | Converts an oven setting between Fahrenheit, Celsius and UK gas mark (1/4 to 10, from the standard recipe table) and optionally adjusts for a fan (convection) oven by... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "How many grams is 1 cup of all-purpose flour?" and the client sent this call.

```json
{"name": "convert_ingredient", "arguments": {"amount": 1, "from_unit": "cup", "to_unit": "g", "ingredient": "all-purpose flour"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
1 us_cup of All-purpose flour = 120 g. Density 120 g per US cup from King Arthur Baking ingredient weight chart (1 cup = 120 g). Cup definition used: US cup (236.5882365 mL). Dry values assume spoon-and-level filling; scooping packs more in.
```

Data as of `2026-10-30`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that converts cups to grams by ingredient?

Yes. Cups to grams converter (cups-to-grams-mcp) is a free MCP server. Cups to grams for 271 ingredients with USDA and King Arthur densities, recipe scaling, oven temps. It is hosted at https://cups-to-grams-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/cups-to-grams-mcp.

### Does the Cups to grams converter MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.kingarthurbaking.com/learn/ingredient-weight-chart. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/cups-to-grams-mcp](https://github.com/theluckystrike/cups-to-grams-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/cups-to-grams-mcp/](https://www.mcpstamp.com/free-servers/cups-to-grams-mcp/) on the mcpstamp.com free server list
- [Can Claude convert cups to grams?](https://www.mcpstamp.com/can-claude/convert-cups-to-grams/) on mcpstamp.com, the plain-English answer with a live call
- [ingredientcalculator.com](https://ingredientcalculator.com/cups-to-grams?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=cups-to-grams-mcp), the companion site this server's results link to

## More free live-data servers

- [DSCR loan calculator MCP server](/mcp/dscr-loan-calculator-mcp/). DSCR loan calculator for rental property: DSCR, lender tiers, max loan, rent needed, amortization.
- [Estate and gift tax exemption calculator MCP server](/mcp/estate-gift-tax-exemption-calculator-mcp/). 2026 US estate and gift tax: $15M exemption (P.L. 119-21), 40% rates, annual exclusion, DSUE.
- [Gold price per gram MCP server](/mcp/gold-price-per-gram-mcp/). Live gold price per gram by karat and currency, metal prices, jewelry melt value, unit conversion.

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
