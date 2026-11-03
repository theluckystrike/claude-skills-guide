---
layout: default
title: "Raw to cooked weight MCP server (free, no API key)"
description: "Free MCP server that converts raw meat weight to cooked weight. No API key: paste the hosted URL. Raw to cooked weight of meat and poultry by cut…"
permalink: /mcp/raw-to-cooked-weight-mcp/
date: 2026-11-03
---

# Raw to cooked weight MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Raw to cooked weight MCP server",
   "alternateName": "raw-to-cooked-weight-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Raw to cooked weight of meat and poultry by cut and cooking method from USDA cooking yields.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/raw-to-cooked-weight-mcp/",
   "codeRepository": "https://github.com/theluckystrike/raw-to-cooked-weight-mcp",
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
     "name": "Is there an MCP server that converts raw meat weight to cooked weight?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Raw to cooked weight (raw-to-cooked-weight-mcp) is a free MCP server. Raw to cooked weight of meat and poultry by cut and cooking method from USDA cooking yields. It is hosted at https://raw-to-cooked-weight-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/raw-to-cooked-weight-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Raw to cooked weight MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.ars.usda.gov/ARSUserFiles/80400535/Data/retn/USDA_CookingYields_MeatPoultry02.pdf. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Raw to cooked weight",
     "item": "https://claudecodeguides.com/mcp/raw-to-cooked-weight-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that converts raw meat weight to cooked weight? `raw-to-cooked-weight-mcp` is free, MIT licensed and needs no API key and no account. Paste https://raw-to-cooked-weight-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Raw to cooked weight of meat and poultry by cut and cooking method from USDA cooking yields.

Tools 5, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. Yields differ by cut, fat level and method. A flat "meat loses 25%" rule is wrong for most cuts. USDA measured bacon at 29 to 32% of its raw weight, 80/20 ground beef crumbles at 67%, a grilled bone-in rib eye steak at 85.7% and a boneless cured ham at 94 to 96%.
2. The exact USDA number, its sample count and its range. Roast chicken thigh is 69%, but USDA samples ran from 58% to 79%. The tools return both.
3. Ground meat lean ratios. "80/20", "93% lean" and "73/27" map to the USDA low, medium and high fat classes for beef (under 12%, 12 to 22%, over 22% fat) and pork (under 10%, 10 to 27%, over 27%).
4. What is not covered. Fish, seafood, rice, pasta and vegetables are not in the USDA table. The tools say so instead of guessing.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://raw-to-cooked-weight-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http raw-to-cooked-weight https://raw-to-cooked-weight-mcp.lipmichal.workers.dev/mcp
claude mcp add raw-to-cooked-weight -- npx -y github:theluckystrike/raw-to-cooked-weight-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "raw-to-cooked-weight": { "command": "npx", "args": ["-y", "github:theluckystrike/raw-to-cooked-weight-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "raw-to-cooked-weight": { "url": "https://raw-to-cooked-weight-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `convert_raw_to_cooked` | Cooked weight of raw meat or poultry using the USDA measured cooking yield for that cut and cooking method (USDA Table of Cooking Yields for Meat and Poultry). |
| `convert_cooked_to_raw` | Raw weight that a cooked portion of meat or poultry came from, using the USDA measured cooking yield. |
| `calculate_raw_weight_to_buy` | How much raw meat or poultry to buy for a number of cooked servings, from the USDA cooking yield for that cut and method. |
| `find_cooking_yield` | Look up the USDA cooking yield percent for a cut of meat or poultry and a cooking method, with the yield range, sample count, moisture change and fat change measured by... |
| `list_cooking_yields` | List rows of the USDA Table of Cooking Yields for Meat and Poultry, filtered by category (beef, pork, poultry, chicken, turkey, lamb, veal, game, sausage) and cooking... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "How much does 1 lb of raw chicken breast weigh after roasting?" and the client sent this call.

```json
{"name": "convert_raw_to_cooked", "arguments": {"food": "chicken breast", "method": "roast", "raw_weight": 1, "unit": "lb"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
1 pound raw chicken, broiler-fryer, breast, meat and skin (baked or roasted, unspecified) cooks down to about 0.72 pounds (327 g) at the USDA cooking yield of 72%; USDA samples ranged 0.61-0.82 pounds. USDA yield is hot cooked weight divided by raw weight of the same piece, measured in USDA research kitchens; your result moves with doneness, trim, bone and pan juices.
```

Data as of `2014-09 (USDA Table of Cooking Yields for Meat and Poultry, Release 2; file checked 2026-11-03)`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that converts raw meat weight to cooked weight?

Yes. Raw to cooked weight (raw-to-cooked-weight-mcp) is a free MCP server. Raw to cooked weight of meat and poultry by cut and cooking method from USDA cooking yields. It is hosted at https://raw-to-cooked-weight-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/raw-to-cooked-weight-mcp.

### Does the Raw to cooked weight MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.ars.usda.gov/ARSUserFiles/80400535/Data/retn/USDA_CookingYields_MeatPoultry02.pdf. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/raw-to-cooked-weight-mcp](https://github.com/theluckystrike/raw-to-cooked-weight-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/raw-to-cooked-weight-mcp/](https://www.mcpstamp.com/free-servers/raw-to-cooked-weight-mcp/) on the mcpstamp.com free server list
- [Can Claude convert raw to cooked weight?](https://www.mcpstamp.com/can-claude/convert-raw-to-cooked-weight/) on mcpstamp.com, the plain-English answer with a live call
- [recipetool.net](https://recipetool.net/tools/raw-to-cooked-weight-calculator?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=raw-to-cooked-weight-mcp), the companion site this server's results link to

## More free live-data servers

- [Recipe nutrition calculator MCP server](/mcp/recipe-nutrition-calculator-mcp/). Recipe nutrition from ingredient lines: USDA FoodData Central values, per serving, FDA rounding.
- [Retirement contribution limits MCP server](/mcp/retirement-contribution-limits-2027-mcp/). 401(k), IRA, HSA limits, age 60-63 catch-up, Roth catch-up rule, Social Security COLA, 2025-2027.
- [River level MCP server](/mcp/river-level-mcp/). Live US river levels, streamflow and NWS flood forecasts from USGS stream gauges.

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
