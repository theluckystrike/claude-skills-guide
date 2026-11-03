---
layout: default
title: "Silver price per gram MCP server (free, no API key)"
description: "Free MCP server for the current silver price per gram. No API key: paste the hosted URL. Live silver price per gram by fineness and currency, junk…"
permalink: /mcp/silver-price-per-gram-mcp/
date: 2026-11-03
---

# Silver price per gram MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Silver price per gram MCP server",
   "alternateName": "silver-price-per-gram-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Live silver price per gram by fineness and currency, junk silver coin value, gold silver ratio.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/silver-price-per-gram-mcp/",
   "codeRepository": "https://github.com/theluckystrike/silver-price-per-gram-mcp",
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
     "name": "Is there an MCP server for the current silver price per gram?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Silver price per gram (silver-price-per-gram-mcp) is a free MCP server. Live silver price per gram by fineness and currency, junk silver coin value, gold silver ratio. It is hosted at https://silver-price-per-gram-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/silver-price-per-gram-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Silver price per gram MCP server need an API key?",
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
     "name": "Silver price per gram",
     "item": "https://claudecodeguides.com/mcp/silver-price-per-gram-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server for the current silver price per gram? `silver-price-per-gram-mcp` is free, MIT licensed and needs no API key and no account. Paste https://silver-price-per-gram-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Live silver price per gram by fineness and currency, junk silver coin value, gold silver ratio.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. Today's silver price. Spot moves every minute and a model's training data is months old.
2. Today's exchange rate for EUR, GBP, INR, CAD, MXN and about 150 more currencies.
3. Exact coin silver content from statute. A 1965 to 1970 Kennedy half holds 4.6 g of silver (Coinage Act of 1965), not the 90% of earlier halves. One dollar face of pre-1965 dimes, quarters or halves holds 22.5 g, which is 0.723392 troy ounces.
4. What the words mean. "Sterling" needs at least 925 parts per thousand of silver and "coin silver" at least 900 (16 CFR 23.5). Britannia silver is 958.4 (UK Hallmarking Act 1973).
5. Exact units. A troy ounce is 31.1034768 g (NIST Handbook 44). A kitchen-scale ounce is 28.349523125 g. Mixing them up is a 9.7% error.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://silver-price-per-gram-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http silver-price-per-gram https://silver-price-per-gram-mcp.lipmichal.workers.dev/mcp
claude mcp add silver-price-per-gram -- npx -y github:theluckystrike/silver-price-per-gram-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "silver-price-per-gram": { "command": "npx", "args": ["-y", "github:theluckystrike/silver-price-per-gram-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "silver-price-per-gram": { "url": "https://silver-price-per-gram-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `get_silver_price_per_gram` | Today's silver price per gram, per troy ounce, per kilogram and per tola, read live from the silver spot market, for fine .999, Britannia .9584, sterling .925, coin... |
| `calculate_silver_value` | Melt value of a silver item (sterling flatware, tea set, jewellery, bar, round, scrap) from its weight, unit and fineness at the live silver spot price, in any currency. |
| `calculate_junk_silver_value` | Melt value of US silver coins at the live silver spot: pre-1965 90% dimes, quarters and halves, 1965-1970 40% Kennedy halves (4.6 g silver, Coinage Act of 1965)... |
| `get_gold_silver_ratio` | Live gold to silver ratio (ounces of silver one ounce of gold buys), with both spot prices per troy ounce and per gram in any currency. |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "What is the silver price per gram right now?" and the client sent this call.

```json
{"name": "get_silver_price_per_gram", "arguments": {}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
Fine silver .999 (bullion bars and rounds) is 1.5667 USD per gram (48.73 USD per troy ounce, 1,566.68 USD per kilogram) at a silver spot of 48.78 USD per troy ounce of pure silver, as of 2026-11-03T09:02:25Z. Per gram by grade: 958.4 1.5030 USD, 925 1.4506 USD, 900 1.4114 USD, 800 1.2546 USD. Melt (spot) value only. Dealers sell bullion and coins above spot (premium) and buy below it; numismatic coins can be worth far more than melt.
```

Data as of `2026-11-03T09:02:25Z`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server for the current silver price per gram?

Yes. Silver price per gram (silver-price-per-gram-mcp) is a free MCP server. Live silver price per gram by fineness and currency, junk silver coin value, gold silver ratio. It is hosted at https://silver-price-per-gram-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/silver-price-per-gram-mcp.

### Does the Silver price per gram MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://gold-api.com/. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/silver-price-per-gram-mcp](https://github.com/theluckystrike/silver-price-per-gram-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/silver-price-per-gram-mcp/](https://www.mcpstamp.com/free-servers/silver-price-per-gram-mcp/) on the mcpstamp.com free server list
- [Can Claude check the current silver price?](https://www.mcpstamp.com/can-claude/check-silver-price/) on mcpstamp.com, the plain-English answer with a live call
- [goldgramprice.com](https://goldgramprice.com/silver-price-per-gram/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=silver-price-per-gram-mcp), the companion site this server's results link to

## More free live-data servers

- [Student loan RAP calculator MCP server](/mcp/student-loan-repayment-assistance-plan-calculator-mcp/). Student loan RAP payment calculator, 2026 federal loan limits, SAVE/PAYE/ICR end dates (OBBBA).
- [Subdomain finder MCP server](/mcp/subdomain-finder-mcp/). Passive subdomain enumeration from certificate transparency (certspotter, crt.sh) with DNS checks.
- [UK income tax and salary MCP server](/mcp/uk-income-tax-salary-mcp/). UK income tax and take-home pay 2025/26 and 2026/27: Scottish bands, NI, student loans, 60% trap.
- [Currency MCP server](/mcp/currency/) from the back-office collection
- [Price Tracker MCP server](/mcp/price-tracker/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
