---
layout: default
title: "Paycheck calculator MCP server (free, no API key)"
description: "Free MCP server that calculates take-home pay after federal and state tax. No API key: paste the hosted URL. Take-home pay for 2025-2026: IRS…"
permalink: /mcp/paycheck-calculator-mcp/
date: 2026-11-03
---

# Paycheck calculator MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Paycheck calculator MCP server",
   "alternateName": "paycheck-calculator-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Take-home pay for 2025-2026: IRS brackets, FICA wage base and state income tax for 50 states + DC.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/paycheck-calculator-mcp/",
   "codeRepository": "https://github.com/theluckystrike/paycheck-calculator-mcp",
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
     "name": "Is there an MCP server that calculates take-home pay after federal and state tax?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Paycheck calculator (paycheck-calculator-mcp) is a free MCP server. Take-home pay for 2025-2026: IRS brackets, FICA wage base and state income tax for 50 states + DC. It is hosted at https://paycheck-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/paycheck-calculator-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Paycheck calculator MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.irs.gov/pub/irs-drop/rp-25-32.pdf ; https://www.irs.gov/pub/irs-pdf/p15.pdf ; https://www.irs.gov/pub/irs-pdf/i8959.pdf ; https://www.ncdor.gov/taxes-forms/individual-income-tax/tax-rate-schedules. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Paycheck calculator",
     "item": "https://claudecodeguides.com/mcp/paycheck-calculator-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that calculates take-home pay after federal and state tax? `paycheck-calculator-mcp` is free, MIT licensed and needs no API key and no account. Paste https://paycheck-calculator-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Take-home pay for 2025-2026: IRS brackets, FICA wage base and state income tax for 50 states + DC.

Tools 5, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. The 2025 standard deduction changed mid-year. P.L. 119-21 (signed July 4, 2025) raised it to $15,750 single, $31,500 joint and $23,625 head of household, replacing the $15,000 / $30,000 / $22,500 in Rev. Proc. 2024-40.
2. The 2026 brackets and standard deduction ($16,100 / $32,200 / $24,150) from Rev. Proc. 2025-32.
3. The Social Security wage base: $176,100 for 2025 and $184,500 for 2026.
4. Additional Medicare tax is owed over $200,000 single, $250,000 joint and $125,000 separate, but employers withhold it over $200,000 for everyone. The tool returns both.
5. A 401(k) deferral lowers income tax but not Social Security or Medicare. A payroll HSA contribution lowers all three.
6. Exact 2026 state schedules for California, New York, New Jersey, Illinois, Pennsylvania, Georgia and North Carolina, including each state's deductions or exemptions and its treatment of 401(k) and HSA money (Pennsylvania taxes 401(k) deferrals; California and New Jersey tax HSA contributions). New York's 2026 rate cuts and its tax-benefit recapture over $107,650 are included.
7. Michigan, Virginia and Ohio run through their own schedules and exemptions, but are labeled `method: "estimate"` until their 2026 sources are re-checked (see Limitations).
8. Every other state's figure is a single-rate estimate and is labeled `method: "estimate"`. States with no wage income tax are labeled `no_wage_income_tax`.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://paycheck-calculator-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http paycheck-calculator https://paycheck-calculator-mcp.lipmichal.workers.dev/mcp
claude mcp add paycheck-calculator -- npx -y github:theluckystrike/paycheck-calculator-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "paycheck-calculator": { "command": "npx", "args": ["-y", "github:theluckystrike/paycheck-calculator-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "paycheck-calculator": { "url": "https://paycheck-calculator-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `calculate_take_home_pay` | Calculates take-home (net) pay for a US employee in any of the 50 states or DC for tax year 2025 or 2026: federal income tax from the IRS Rev. |
| `compare_states_take_home` | Runs the same gross pay through 2 to 10 states (or DC) and ranks them by annual take-home pay for tax year 2025 or 2026, showing state income tax, the method for each... |
| `salary_to_hourly` | Converts an annual salary to an hourly rate and to weekly, biweekly (26), semimonthly (24) and monthly gross pay. |
| `hourly_to_salary` | Converts an hourly wage to weekly, monthly and annual gross pay, with optional weekly overtime hours at a multiplier (1.5 by default). |
| `get_federal_tax_brackets` | Returns the exact federal income tax brackets (rate, lower and upper bound, tax on lower brackets) and standard deduction for tax year 2025 or 2026 and a filing status... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "What is my 2026 take-home pay on $92,000 in North Carolina, paid every two weeks, with 6% to a 401(k)?" and the client sent this call.

```json
{"name": "calculate_take_home_pay", "arguments": {"state": "NC", "filing_status": "single", "tax_year": 2026, "gross_annual": 92000, "pay_frequency": "biweekly", "pretax_401k_percent": 6}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
North Carolina, single, 2026: gross $92,000.00 a year ($3,538.46 biweekly). Federal income tax $10,195.60 on taxable income $70,380.00 after the $16,100.00 standard deduction (marginal 22%). Social Security $5,704.00 (6.2% up to the $184,500.00 wage base), Medicare $1,334.00. State income tax $2,941.83 (exact 2026 schedule). Take-home $66,304.57 a year, $2,550.18 per biweekly paycheck; effective tax rate 21.93%.

Estimate of annual tax on wages, not tax advice and not your employer's W-4 withholding. Uses the standard deduction and no credits. Local taxes (NYC, Yonkers, Ohio cities, Pennsylvania EIT, Maryland and Indiana counties) and state payroll taxes such as CA SDI are not included.
```

Data as of `2026-10-30`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that calculates take-home pay after federal and state tax?

Yes. Paycheck calculator (paycheck-calculator-mcp) is a free MCP server. Take-home pay for 2025-2026: IRS brackets, FICA wage base and state income tax for 50 states + DC. It is hosted at https://paycheck-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/paycheck-calculator-mcp.

### Does the Paycheck calculator MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.irs.gov/pub/irs-drop/rp-25-32.pdf ; https://www.irs.gov/pub/irs-pdf/p15.pdf ; https://www.irs.gov/pub/irs-pdf/i8959.pdf ; https://www.ncdor.gov/taxes-forms/individual-income-tax/tax-rate-schedules. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/paycheck-calculator-mcp](https://github.com/theluckystrike/paycheck-calculator-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/paycheck-calculator-mcp/](https://www.mcpstamp.com/free-servers/paycheck-calculator-mcp/) on the mcpstamp.com free server list
- [Can Claude calculate my take-home pay?](https://www.mcpstamp.com/can-claude/calculate-take-home-pay/) on mcpstamp.com, the plain-English answer with a live call
- [statewage.com](https://statewage.com/states/north-carolina/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=paycheck-calculator-mcp), the companion site this server's results link to

## More free live-data servers

- [Raw to cooked weight MCP server](/mcp/raw-to-cooked-weight-mcp/). Raw to cooked weight of meat and poultry by cut and cooking method from USDA cooking yields.
- [Recipe nutrition calculator MCP server](/mcp/recipe-nutrition-calculator-mcp/). Recipe nutrition from ingredient lines: USDA FoodData Central values, per serving, FDA rounding.
- [Retirement contribution limits MCP server](/mcp/retirement-contribution-limits-2027-mcp/). 401(k), IRA, HSA limits, age 60-63 catch-up, Roth catch-up rule, Social Security COLA, 2025-2027.
- [Payroll MCP server](/mcp/payroll/) from the back-office collection
- [Hourly Rate MCP server](/mcp/hourly-rate/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
