---
layout: default
title: "ACA premium tax credit calculator MCP server (free, no API key)"
description: "Free MCP server for the 2026 ACA premium tax credit. No API key: paste the hosted URL. 2026 ACA premium tax credit: expired enhanced subsidy, 400%…"
permalink: /mcp/aca-premium-tax-credit-calculator-mcp/
date: 2026-11-03
---

# ACA premium tax credit calculator MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "ACA premium tax credit calculator MCP server",
   "alternateName": "aca-premium-tax-credit-calculator-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "2026 ACA premium tax credit: expired enhanced subsidy, 400% FPL cliff, FPL, APTC repayment rules.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/aca-premium-tax-credit-calculator-mcp/",
   "codeRepository": "https://github.com/theluckystrike/aca-premium-tax-credit-calculator-mcp",
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
     "name": "Is there an MCP server for the 2026 ACA premium tax credit?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. ACA premium tax credit calculator (aca-premium-tax-credit-calculator-mcp) is a free MCP server. 2026 ACA premium tax credit: expired enhanced subsidy, 400% FPL cliff, FPL, APTC repayment rules. It is hosted at https://aca-premium-tax-credit-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/aca-premium-tax-credit-calculator-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the ACA premium tax credit calculator MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.irs.gov/pub/irs-drop/rp-25-25.pdf. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "ACA premium tax credit calculator",
     "item": "https://claudecodeguides.com/mcp/aca-premium-tax-credit-calculator-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server for the 2026 ACA premium tax credit? `aca-premium-tax-credit-calculator-mcp` is free, MIT licensed and needs no API key and no account. Paste https://aca-premium-tax-credit-calculator-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. 2026 ACA premium tax credit: expired enhanced subsidy, 400% FPL cliff, FPL, APTC repayment rules.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. The enhanced credits ended after tax year 2025. No public law through P.L. 119-136 (October 22, 2026) amends IRC sec. 36B to extend them. Checked 2026-11-02.
2. For 2026 coverage there is no premium tax credit above 400% of the federal poverty line. One dollar over the line can cost a family thousands.
3. The 2026 applicable percentage table (Rev. Proc. 2025-25) runs from 2.10% of income below 133% FPL to 9.96% at 300% to 400% FPL. The 2025 table ran from 0% to 8.5%.
4. The 2026 required contribution percentage (employer coverage affordability) is 9.96%. It was 9.02% for 2025.
5. 2026 coverage uses the 2025 HHS poverty guidelines: $15,650 for one person in the 48 states and DC, $19,550 in Alaska, $17,990 in Hawaii, plus $5,500, $6,880 or $6,330 for each extra person.
6. From tax year 2026 there is no cap on repaying excess advance credit. The One Big Beautiful Bill Act (P.L. 119-21 sec. 71305) repealed it. For 2025 the caps were $375 to $1,625 (single) and $750 to $3,250 (other filers) below 400% FPL.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://aca-premium-tax-credit-calculator-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http aca-premium-tax-credit-calculator https://aca-premium-tax-credit-calculator-mcp.lipmichal.workers.dev/mcp
claude mcp add aca-premium-tax-credit-calculator -- npx -y github:theluckystrike/aca-premium-tax-credit-calculator-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "aca-premium-tax-credit-calculator": { "command": "npx", "args": ["-y", "github:theluckystrike/aca-premium-tax-credit-calculator-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "aca-premium-tax-credit-calculator": { "url": "https://aca-premium-tax-credit-calculator-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `get_federal_poverty_level` | Returns the federal poverty line (FPL) used for the ACA premium tax credit for a coverage year, household size and state, plus the 100%, 133%, 138%, 150%, 200%, 250%... |
| `calculate_premium_tax_credit` | Calculates the ACA Marketplace premium tax credit (IRC sec. 36B) the way Form 8962 does. |
| `check_subsidy_cliff` | Shows the dollar effect of the 400% federal poverty line subsidy cliff that returned for 2026 coverage after the enhanced premium tax credits expired: the cliff income... |
| `get_aptc_repayment_cap` | Returns the cap on repaying excess advance premium tax credit (APTC) at tax time. |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "A couple in Texas earns $68,000 and the benchmark plan is $1,150 a month. What is their 2026 premium tax credit?" and the client sent this call.

```json
{"name": "calculate_premium_tax_credit", "arguments": {"household_income": 68000, "household_size": 2, "state": "TX", "benchmark_premium": 1150, "year": 2026, "premium_period": "monthly"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
2026 premium tax credit: income $68,000.00 is 321.51% of the $21,150.00 poverty line, applicable figure 9.96%, so the household is expected to pay $6,772.80 a year ($564.40 a month) toward the $13,800.00 benchmark plan. Credit: $7,027.20 a year ($585.60 a month). 2026 rules: enhanced credits expired, 400% FPL limit applies.

General information, not tax advice. The Marketplace and Form 8962 decide the official amounts. Benchmark (second lowest cost silver) premiums vary by ZIP code, age and household; get yours from HealthCare.gov or your state Marketplace.
```

Data as of `2026-11-02`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server for the 2026 ACA premium tax credit?

Yes. ACA premium tax credit calculator (aca-premium-tax-credit-calculator-mcp) is a free MCP server. 2026 ACA premium tax credit: expired enhanced subsidy, 400% FPL cliff, FPL, APTC repayment rules. It is hosted at https://aca-premium-tax-credit-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/aca-premium-tax-credit-calculator-mcp.

### Does the ACA premium tax credit calculator MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.irs.gov/pub/irs-drop/rp-25-25.pdf. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/aca-premium-tax-credit-calculator-mcp](https://github.com/theluckystrike/aca-premium-tax-credit-calculator-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/aca-premium-tax-credit-calculator-mcp/](https://www.mcpstamp.com/free-servers/aca-premium-tax-credit-calculator-mcp/) on the mcpstamp.com free server list
- [Can Claude calculate my 2026 ACA premium tax credit?](https://www.mcpstamp.com/can-claude/calculate-aca-premium-tax-credit/) on mcpstamp.com, the plain-English answer with a live call
- [taxbreakcalc.com](https://taxbreakcalc.com/hsa-calculator/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=aca-premium-tax-credit-calculator-mcp), the companion site this server's results link to

## More free live-data servers

- [Address to census tract MCP server](/mcp/address-to-census-tract-mcp/). US address to census tract, block group, county FIPS and districts, from the Census Geocoder.
- [AP score distributions MCP server](/mcp/ap-score-distributions-mcp/). Official College Board AP score distributions 2026, 2025, 2024: percentiles, pass rates.
- [Car loan interest deduction calculator MCP server](/mcp/car-loan-interest-deduction-calculator-mcp/). 2025-2028 car loan interest deduction, SALT cap, child tax credit and 2026 tax brackets (IRS).
- [Tax Calc MCP server](/mcp/tax-calc/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
