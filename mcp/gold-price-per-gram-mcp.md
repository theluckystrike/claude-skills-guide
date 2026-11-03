---
layout: default
title: "Gold price per gram MCP server (free, no API key)"
description: "Free MCP server for the current gold price per gram. No API key: paste the hosted URL. Live gold price per gram by karat and currency, metal prices…"
permalink: /mcp/gold-price-per-gram-mcp/
date: 2026-11-03
---

# Gold price per gram MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Gold price per gram MCP server",
   "alternateName": "gold-price-per-gram-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Live gold price per gram by karat and currency, metal prices, jewelry melt value, unit conversion.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/gold-price-per-gram-mcp/",
   "codeRepository": "https://github.com/theluckystrike/gold-price-per-gram-mcp",
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
     "name": "Is there an MCP server for the current gold price per gram?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Gold price per gram (gold-price-per-gram-mcp) is a free MCP server. Live gold price per gram by karat and currency, metal prices, jewelry melt value, unit conversion. It is hosted at https://gold-price-per-gram-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/gold-price-per-gram-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Gold price per gram MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://gold-api.com/. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Gold price per gram",
     "item": "https://claudecodeguides.com/mcp/gold-price-per-gram-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server for the current gold price per gram? `gold-price-per-gram-mcp` is free, MIT licensed and needs no API key and no account. Paste https://gold-price-per-gram-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Live gold price per gram by karat and currency, metal prices, jewelry melt value, unit conversion.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. Today's gold price. Spot moves every minute and a model's training data is months old.
2. Today's exchange rate for INR, AED, SAR, PKR, EUR, GBP and about 150 more currencies.
3. Exact unit constants. A troy ounce is 31.1034768 g and a grain is 64.79891 mg by definition (NIST Handbook 44). A tola is 180 grains. A Thai bullion baht is 15.244 g, not 15 g. A kitchen-scale ounce is 28.349523125 g, not a troy ounce.
4. Karat purity as an exact fraction (karat / 24), so 22K is 91.6667% and 14K is 58.3333%.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://gold-price-per-gram-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http gold-price-per-gram https://gold-price-per-gram-mcp.lipmichal.workers.dev/mcp
claude mcp add gold-price-per-gram -- npx -y github:theluckystrike/gold-price-per-gram-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "gold-price-per-gram": { "command": "npx", "args": ["-y", "github:theluckystrike/gold-price-per-gram-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "gold-price-per-gram": { "url": "https://gold-price-per-gram-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `get_gold_price_per_gram` | Today's gold price per gram, per troy ounce, per tola and per kilogram, read live from the gold spot market, for 24K, 22K, 21K, 18K, 14K, 10K and 9K gold, in any of... |
| `get_metal_prices` | Live spot prices of gold (XAU), silver (XAG), platinum (XPT) and palladium (XPD) per troy ounce, per gram and per kilogram, in any major currency. |
| `calculate_jewelry_value` | Melt value of a gold item (ring, chain, bracelet, scrap) from its weight, unit and karat at the live spot price, in any currency. |
| `convert_gold_units` | Convert a gold weight between gram, kilogram, troy ounce, pennyweight, grain, avoirdupois ounce, tola, Thai baht (bullion and jewellery), Vietnamese chi and luong, Hong... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "What is the gold price per gram right now, by karat?" and the client sent this call.

```json
{"name": "get_gold_price_per_gram", "arguments": {"currency": "USD"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
24K gold is 125.33 USD per gram (3,898.10 USD per troy ounce, 1,461.79 USD per tola) at a spot of 3,898.10 USD per troy ounce of fine gold, as of 2026-11-03T09:00:56Z. Per gram by karat: 22K 114.88 USD, 21K 109.66 USD, 18K 94.00 USD, 14K 73.11 USD, 10K 52.22 USD, 9K 47.00 USD. These are melt (spot) values. Shops sell jewellery above this and buy it back below it.
```

Data as of `2026-11-03T09:00:56Z`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server for the current gold price per gram?

Yes. Gold price per gram (gold-price-per-gram-mcp) is a free MCP server. Live gold price per gram by karat and currency, metal prices, jewelry melt value, unit conversion. It is hosted at https://gold-price-per-gram-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/gold-price-per-gram-mcp.

### Does the Gold price per gram MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://gold-api.com/. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/gold-price-per-gram-mcp](https://github.com/theluckystrike/gold-price-per-gram-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/gold-price-per-gram-mcp/](https://www.mcpstamp.com/free-servers/gold-price-per-gram-mcp/) on the mcpstamp.com free server list
- [Can Claude check the current gold price?](https://www.mcpstamp.com/can-claude/check-gold-price/) on mcpstamp.com, the plain-English answer with a live call
- [goldgramprice.com](https://goldgramprice.com/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=gold-price-per-gram-mcp), the companion site this server's results link to

## More free live-data servers

- [IRS mileage rate and per diem MCP server](/mcp/irs-mileage-rate-per-diem-mcp/). IRS mileage rates 2011-2026 (76 cents from July 2026), GSA per diem by ZIP FY2026-27, high-low.
- [Lake level MCP server](/mcp/lake-level-mcp/). Live US lake and reservoir water levels from USGS, USACE, CDEC, USBR and TWDB gauges.
- [Minimum wage MCP server](/mcp/minimum-wage-mcp/). US state minimum wage 2026-2027: rates, tipped wages and scheduled increases for 50 states and DC.
- [Currency MCP server](/mcp/currency/) from the back-office collection
- [Price Tracker MCP server](/mcp/price-tracker/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
