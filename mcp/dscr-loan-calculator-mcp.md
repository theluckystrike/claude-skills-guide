---
layout: default
title: "DSCR loan calculator MCP server (free, no API key)"
description: "Free MCP server that calculates DSCR for a rental property loan. No API key: paste the hosted URL. DSCR loan calculator for rental property: DSCR…"
permalink: /mcp/dscr-loan-calculator-mcp/
date: 2026-11-03
---

# DSCR loan calculator MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "DSCR loan calculator MCP server",
   "alternateName": "dscr-loan-calculator-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "DSCR loan calculator for rental property: DSCR, lender tiers, max loan, rent needed, amortization.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/dscr-loan-calculator-mcp/",
   "codeRepository": "https://github.com/theluckystrike/dscr-loan-calculator-mcp",
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
     "name": "Is there an MCP server that calculates DSCR for a rental property loan?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. DSCR loan calculator (dscr-loan-calculator-mcp) is a free MCP server. DSCR loan calculator for rental property: DSCR, lender tiers, max loan, rent needed, amortization. It is hosted at https://dscr-loan-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/dscr-loan-calculator-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the DSCR loan calculator MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://selling-guide.fanniemae.com/sel/b3-6-03/monthly-housing-expense-subject-property. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "DSCR loan calculator",
     "item": "https://claudecodeguides.com/mcp/dscr-loan-calculator-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that calculates DSCR for a rental property loan? `dscr-loan-calculator-mcp` is free, MIT licensed and needs no API key and no account. Paste https://dscr-loan-calculator-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. DSCR loan calculator for rental property: DSCR, lender tiers, max loan, rent needed, amortization.

Tools 5, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. Cent-exact payments. Language models often get the annuity formula wrong by a few dollars, or round in the wrong place. This server uses the standard annuity formula with monthly compounding and rounds each part half up to the cent, the way a lender schedule does.
2. The real definition of PITIA (Fannie Mae Selling Guide B3-6-03): principal, interest, taxes, insurance, association dues, ground rent, special assessments.
3. Exact tier edges. A DSCR of 1.2499 is not 1.25. Tiers are decided on the exact ratio with integer math, and the 2-decimal DSCR is truncated, not rounded up.
4. Solvers. Max loan and rent needed are solved exactly against the rounded payment, not estimated.
5. How lenders actually differ. Some lenders look for 1.25, some accept 1.00, some go down to 0.75, and some offer no-ratio programs. Sources are in each result.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://dscr-loan-calculator-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http dscr-loan-calculator https://dscr-loan-calculator-mcp.lipmichal.workers.dev/mcp
claude mcp add dscr-loan-calculator -- npx -y github:theluckystrike/dscr-loan-calculator-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "dscr-loan-calculator": { "command": "npx", "args": ["-y", "github:theluckystrike/dscr-loan-calculator-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "dscr-loan-calculator": { "url": "https://dscr-loan-calculator-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `calculate_dscr` | Debt service coverage ratio for a DSCR (investor) mortgage: qualifying rent / PITIA. Computes exact principal and interest with the annuity formula (monthly... |
| `max_loan_for_target_dscr` | Solves for the largest whole-dollar loan whose PITIA keeps the DSCR at or above a target (default 1.25), given rent, rate, term, interest-only choice, tax, insurance... |
| `rent_needed_for_target_dscr` | Solves for the smallest monthly rent (to the cent, and rounded up to whole dollars) that reaches a target DSCR (default 1.25) for a given loan, rate, term, tax... |
| `compare_scenarios` | Compares 1 to 5 financing scenarios (rate, down payment, term, interest-only) on one property: loan amount, P&I, PITIA, DSCR, lender band, rent minus PITIA and total... |
| `amortization_summary` | Exact month-by-month amortization: monthly payment, number of payments, final payment, total interest, total paid and the remaining balance after chosen years. |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "Rent is $2,400 on a $300,000 rental with 25% down at 7.25%. What is the DSCR?" and the client sent this call.

```json
{"name": "calculate_dscr", "arguments": {"monthly_rent": 2400, "purchase_price": 300000, "down_payment_pct": 25, "annual_rate_pct": 7.25, "term_years": 30, "annual_property_tax": 3600, "annual_insurance": 1500, "vacancy_pct": 5}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
A $225,000.00 loan at 7.25% over 30 years has a monthly payment of $1,534.90 and PITIA of $1,959.90. Qualifying rent of $2,280.00 gives a DSCR of 1.16 (exact 1.163325), in the 1.00 to 1.24 band. Rent covers PITIA. Many DSCR programs accept 1.00 or more; lenders that want 1.25 will not. DSCR minimums and pricing bands vary by lender and change over time. These tiers are common market labels, not an approval decision.
```

Data as of `2026-10-30`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that calculates DSCR for a rental property loan?

Yes. DSCR loan calculator (dscr-loan-calculator-mcp) is a free MCP server. DSCR loan calculator for rental property: DSCR, lender tiers, max loan, rent needed, amortization. It is hosted at https://dscr-loan-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/dscr-loan-calculator-mcp.

### Does the DSCR loan calculator MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://selling-guide.fanniemae.com/sel/b3-6-03/monthly-housing-expense-subject-property. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/dscr-loan-calculator-mcp](https://github.com/theluckystrike/dscr-loan-calculator-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/dscr-loan-calculator-mcp/](https://www.mcpstamp.com/free-servers/dscr-loan-calculator-mcp/) on the mcpstamp.com free server list
- [Can Claude calculate DSCR for a rental loan?](https://www.mcpstamp.com/can-claude/calculate-dscr/) on mcpstamp.com, the plain-English answer with a live call
- [dscrradar.com](https://dscrradar.com/dscr-loan-calculator/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=dscr-loan-calculator-mcp), the companion site this server's results link to

## More free live-data servers

- [Estate and gift tax exemption calculator MCP server](/mcp/estate-gift-tax-exemption-calculator-mcp/). 2026 US estate and gift tax: $15M exemption (P.L. 119-21), 40% rates, annual exclusion, DSUE.
- [Gold price per gram MCP server](/mcp/gold-price-per-gram-mcp/). Live gold price per gram by karat and currency, metal prices, jewelry melt value, unit conversion.
- [IRS mileage rate and per diem MCP server](/mcp/irs-mileage-rate-per-diem-mcp/). IRS mileage rates 2011-2026 (76 cents from July 2026), GSA per diem by ZIP FY2026-27, high-low.
- [Amortization MCP server](/mcp/amortization/) from the back-office collection
- [Loan Calculator MCP server](/mcp/loan-calculator/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
