---
layout: default
title: "Estate and gift tax exemption calculator MCP server (free, no API key)"
description: "Free MCP server that knows the 2026 estate and gift tax exemption. No API key: paste the hosted URL. 2026 US estate and gift tax: $15M exemption…"
permalink: /mcp/estate-gift-tax-exemption-calculator-mcp/
date: 2026-11-03
---

# Estate and gift tax exemption calculator MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Estate and gift tax exemption calculator MCP server",
   "alternateName": "estate-gift-tax-exemption-calculator-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "2026 US estate and gift tax: $15M exemption (P.L. 119-21), 40% rates, annual exclusion, DSUE.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/estate-gift-tax-exemption-calculator-mcp/",
   "codeRepository": "https://github.com/theluckystrike/estate-gift-tax-exemption-calculator-mcp",
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
     "name": "Is there an MCP server that knows the 2026 estate and gift tax exemption?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Estate and gift tax exemption calculator (estate-gift-tax-exemption-calculator-mcp) is a free MCP server. 2026 US estate and gift tax: $15M exemption (P.L. 119-21), 40% rates, annual exclusion, DSUE. It is hosted at https://estate-gift-tax-exemption-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/estate-gift-tax-exemption-calculator-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Estate and gift tax exemption calculator MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.law.cornell.edu/uscode/text/26/2001. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Estate and gift tax exemption calculator",
     "item": "https://claudecodeguides.com/mcp/estate-gift-tax-exemption-calculator-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that knows the 2026 estate and gift tax exemption? `estate-gift-tax-exemption-calculator-mcp` is free, MIT licensed and needs no API key and no account. Paste https://estate-gift-tax-exemption-calculator-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. 2026 US estate and gift tax: $15M exemption (P.L. 119-21), 40% rates, annual exclusion, DSUE.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. The 2026 basic exclusion amount is $15,000,000 per person ($30,000,000 for a married couple using portability). P.L. 119-21 sec. 70106 replaced the $5,000,000 base in sec. 2010(c)(3) with $15,000,000 and struck the TCJA sunset. Amounts after 2026 are indexed and rounded to the nearest $10,000.
2. The 2025 amount was $13,990,000 (Rev. Proc. 2024-40). The applicable credit is $5,945,800 for 2026 and $5,541,800 for 2025.
3. The 2026 annual gift exclusion is $19,000 per recipient, the same as 2025, or $38,000 with gift splitting.
4. Gifts to a spouse who is not a US citizen get no unlimited marital deduction. The annual exclusion for them is $194,000 for 2026 (Rev. Proc. 2025-32) and was $190,000 for 2025 (Rev. Proc. 2024-40).
5. The 2026 GST exemption is $15,000,000 (Rev. Proc. 2025-32).
6. The top rate is still 40% above $1,000,000 on the unified schedule in 26 USC 2001(c).
7. A surviving spouse can add the deceased spouse's unused exclusion (DSUE) only if the executor files a timely Form 706 and elects portability.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://estate-gift-tax-exemption-calculator-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http estate-gift-tax-exemption-calculator https://estate-gift-tax-exemption-calculator-mcp.lipmichal.workers.dev/mcp
claude mcp add estate-gift-tax-exemption-calculator -- npx -y github:theluckystrike/estate-gift-tax-exemption-calculator-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "estate-gift-tax-exemption-calculator": { "command": "npx", "args": ["-y", "github:theluckystrike/estate-gift-tax-exemption-calculator-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "estate-gift-tax-exemption-calculator": { "url": "https://estate-gift-tax-exemption-calculator-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `get_exemption_amounts` | Returns the federal basic exclusion amount (estate and lifetime gift tax exemption), the applicable credit, the filing threshold, the annual gift exclusion per... |
| `calculate_estate_tax` | Calculates US federal estate tax the Form 706 way: taxable estate (gross estate minus deductions such as debts, expenses, marital and charitable bequests), plus... |
| `check_gift` | Checks a gift against the federal gift tax rules for a year (2013-2026): annual exclusion per recipient ($19,000 in 2025 and 2026), gift splitting with a spouse (sec.... |
| `compare_years` | Compares two years (2013-2026) side by side: basic exclusion amount, applicable credit, annual gift exclusion and non-citizen spouse exclusion, and, with a taxable... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "How much federal estate tax is due on a $20 million estate for a death in 2026?" and the client sent this call.

```json
{"name": "calculate_estate_tax", "arguments": {"gross_estate": 20000000}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
2026 federal estate tax: $2,000,000. Taxable estate $20,000,000 plus $0 of lifetime taxable gifts is $20,000,000, which is $5,000,000 over the $15,000,000 exclusion, taxed at 40%. A surviving spouse keeps any unused exclusion only if the executor files Form 706 and elects portability.

Federal estate and gift tax only. State estate and inheritance taxes are not included. General information, not legal or tax advice; Forms 706 and 709 and their instructions decide the official amounts.
```

Data as of `2026-11-02`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that knows the 2026 estate and gift tax exemption?

Yes. Estate and gift tax exemption calculator (estate-gift-tax-exemption-calculator-mcp) is a free MCP server. 2026 US estate and gift tax: $15M exemption (P.L. 119-21), 40% rates, annual exclusion, DSUE. It is hosted at https://estate-gift-tax-exemption-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/estate-gift-tax-exemption-calculator-mcp.

### Does the Estate and gift tax exemption calculator MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.law.cornell.edu/uscode/text/26/2001. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/estate-gift-tax-exemption-calculator-mcp](https://github.com/theluckystrike/estate-gift-tax-exemption-calculator-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/estate-gift-tax-exemption-calculator-mcp/](https://www.mcpstamp.com/free-servers/estate-gift-tax-exemption-calculator-mcp/) on the mcpstamp.com free server list
- [taxbreakcalc.com](https://taxbreakcalc.com/charitable-deduction-calculator/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=estate-gift-tax-exemption-calculator-mcp), the companion site this server's results link to

## More free live-data servers

- [Gold price per gram MCP server](/mcp/gold-price-per-gram-mcp/). Live gold price per gram by karat and currency, metal prices, jewelry melt value, unit conversion.
- [IRS mileage rate and per diem MCP server](/mcp/irs-mileage-rate-per-diem-mcp/). IRS mileage rates 2011-2026 (76 cents from July 2026), GSA per diem by ZIP FY2026-27, high-low.
- [Lake level MCP server](/mcp/lake-level-mcp/). Live US lake and reservoir water levels from USGS, USACE, CDEC, USBR and TWDB gauges.
- [Tax Calc MCP server](/mcp/tax-calc/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
