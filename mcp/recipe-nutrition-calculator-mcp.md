---
layout: default
title: "Recipe nutrition calculator MCP server (free, no API key)"
description: "Free MCP server that calculates recipe nutrition per serving. No API key: paste the hosted URL. Recipe nutrition from ingredient lines: USDA…"
permalink: /mcp/recipe-nutrition-calculator-mcp/
date: 2026-11-03
---

# Recipe nutrition calculator MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Recipe nutrition calculator MCP server",
   "alternateName": "recipe-nutrition-calculator-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Recipe nutrition from ingredient lines: USDA FoodData Central values, per serving, FDA rounding.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/recipe-nutrition-calculator-mcp/",
   "codeRepository": "https://github.com/theluckystrike/recipe-nutrition-calculator-mcp",
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
     "name": "Is there an MCP server that calculates recipe nutrition per serving?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Recipe nutrition calculator (recipe-nutrition-calculator-mcp) is a free MCP server. Recipe nutrition from ingredient lines: USDA FoodData Central values, per serving, FDA rounding. It is hosted at https://recipe-nutrition-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/recipe-nutrition-calculator-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Recipe nutrition calculator MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_sr_legacy_food_csv_2018-04.zip. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Recipe nutrition calculator",
     "item": "https://claudecodeguides.com/mcp/recipe-nutrition-calculator-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that calculates recipe nutrition per serving? `recipe-nutrition-calculator-mcp` is free, MIT licensed and needs no API key and no account. Paste https://recipe-nutrition-calculator-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Recipe nutrition from ingredient lines: USDA FoodData Central values, per serving, FDA rounding.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. Exact USDA values. Each of the 406 ingredients carries the FoodData Central nutrient values and FDC id: 398 from SR Legacy and 8 from the April 2026 Foundation Foods release where that release has all eight nutrients. A model recalls nutrition roughly and changes its answer between runs.
2. Food-specific cup weights. A cup of flour is 125 g, packed brown sugar 220 g, shredded cheddar 113 g, chopped onion 160 g, whole milk 244 g. These are the USDA household measures for that food, not one density for everything.
3. The label rounding rules. Calories round to 5 up to 50 and to 10 above, fat to 0.5 g under 5 g, sodium to 5 mg up to 140 mg and to 10 mg above, with the "less than 1g" cases for carbohydrate, fiber, sugars and protein. Copied from the eCFR text of 21 CFR 101.9.
4. The current Daily Values. Fat 78 g, saturated fat 20 g, sodium 2,300 mg, carbohydrate 275 g, fiber 28 g, added sugars 50 g.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://recipe-nutrition-calculator-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http recipe-nutrition-calculator https://recipe-nutrition-calculator-mcp.lipmichal.workers.dev/mcp
claude mcp add recipe-nutrition-calculator -- npx -y github:theluckystrike/recipe-nutrition-calculator-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "recipe-nutrition-calculator": { "command": "npx", "args": ["-y", "github:theluckystrike/recipe-nutrition-calculator-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "recipe-nutrition-calculator": { "url": "https://recipe-nutrition-calculator-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `lookup_ingredient_nutrition` | Returns USDA FoodData Central nutrient values per 100 g (calories, protein, total fat, saturated fat, carbohydrate, fiber, total sugars, sodium) for a common recipe... |
| `calculate_recipe_nutrition` | Parses ingredient lines ("2 cups flour", "1 stick butter" as 8 tbsp, "3 large eggs", "1 lb ground beef"), converts cups, spoons and counted items to grams with USDA... |
| `round_nutrition_label` | Applies the FDA Nutrition Facts rounding rules from 21 CFR 101.9(c) to unrounded per-serving values: calories (under 5 = 0, nearest 5 up to 50, nearest 10 above), fat... |
| `scale_recipe_nutrition` | Scales ingredient lines by a factor or from original to target servings (parses mixed numbers and fraction characters), then recomputes total and per-serving nutrition... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "What are the calories per serving of this 12-serving cake recipe?" and the client sent this call.

```json
{"name": "calculate_recipe_nutrition", "arguments": {"lines": ["2 cups all-purpose flour", "1/2 cup butter", "1 cup sugar", "2 large eggs", "1 cup milk", "2 tsp baking powder"], "servings": 12}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
Recipe of 6 lines (916.7 g matched): 2799.5 kcal total, 233.3 kcal per serving over 12 servings. Per serving: 3.9 g protein, 9.4 g fat, 33.8 g carbohydrate, 0.6 g fiber, 162.2 mg sodium. FDA label rounding gives 230 calories per serving. Every line was matched to a USDA FoodData Central food. Values are for the raw ingredients as listed; cooking losses and water evaporation are not modeled.
```

Data as of `2026-11-02`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that calculates recipe nutrition per serving?

Yes. Recipe nutrition calculator (recipe-nutrition-calculator-mcp) is a free MCP server. Recipe nutrition from ingredient lines: USDA FoodData Central values, per serving, FDA rounding. It is hosted at https://recipe-nutrition-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/recipe-nutrition-calculator-mcp.

### Does the Recipe nutrition calculator MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_sr_legacy_food_csv_2018-04.zip. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/recipe-nutrition-calculator-mcp](https://github.com/theluckystrike/recipe-nutrition-calculator-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/recipe-nutrition-calculator-mcp/](https://www.mcpstamp.com/free-servers/recipe-nutrition-calculator-mcp/) on the mcpstamp.com free server list
- [Can Claude calculate calories and nutrition for a recipe?](https://www.mcpstamp.com/can-claude/calculate-recipe-nutrition/) on mcpstamp.com, the plain-English answer with a live call
- [recipetool.net](https://recipetool.net/nutrition-calculator?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=recipe-nutrition-calculator-mcp), the companion site this server's results link to

## More free live-data servers

- [Retirement contribution limits MCP server](/mcp/retirement-contribution-limits-2027-mcp/). 401(k), IRA, HSA limits, age 60-63 catch-up, Roth catch-up rule, Social Security COLA, 2025-2027.
- [River level MCP server](/mcp/river-level-mcp/). Live US river levels, streamflow and NWS flood forecasts from USGS stream gauges.
- [SAT score percentiles MCP server](/mcp/sat-score-percentiles-mcp/). SAT score percentiles and class of 2026 SAT averages and participation by state (College Board).

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
