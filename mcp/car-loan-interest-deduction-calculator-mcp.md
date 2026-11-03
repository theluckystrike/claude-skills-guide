---
layout: default
title: "Car loan interest deduction calculator MCP server (free, no API key)"
description: "Free MCP server that calculates the new car loan interest deduction. No API key: paste the hosted URL. 2025-2028 car loan interest deduction, SALT…"
permalink: /mcp/car-loan-interest-deduction-calculator-mcp/
date: 2026-11-03
---

# Car loan interest deduction calculator MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Car loan interest deduction calculator MCP server",
   "alternateName": "car-loan-interest-deduction-calculator-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "2025-2028 car loan interest deduction, SALT cap, child tax credit and 2026 tax brackets (IRS).",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/car-loan-interest-deduction-calculator-mcp/",
   "codeRepository": "https://github.com/theluckystrike/car-loan-interest-deduction-calculator-mcp",
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
     "name": "Is there an MCP server that calculates the new car loan interest deduction?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Car loan interest deduction calculator (car-loan-interest-deduction-calculator-mcp) is a free MCP server. 2025-2028 car loan interest deduction, SALT cap, child tax credit and 2026 tax brackets (IRS). It is hosted at https://car-loan-interest-deduction-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/car-loan-interest-deduction-calculator-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Car loan interest deduction calculator MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.irs.gov/pub/irs-pdf/f1040s1a.pdf ; https://www.irs.gov/pub/irs-pdf/i1040gi.pdf ; https://www.irs.gov/pub/irs-drop/n-25-57.pdf. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Car loan interest deduction calculator",
     "item": "https://claudecodeguides.com/mcp/car-loan-interest-deduction-calculator-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that calculates the new car loan interest deduction? `car-loan-interest-deduction-calculator-mcp` is free, MIT licensed and needs no API key and no account. Paste https://car-loan-interest-deduction-calculator-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. 2025-2028 car loan interest deduction, SALT cap, child tax credit and 2026 tax brackets (IRS).

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. The car loan interest deduction started in tax year 2025, after most models were trained. You can take it without itemizing.
2. Its phase-out is $200 for each $1,000 or part of $1,000 over the threshold. One dollar over $149,000 (single) wipes out the last $200. Schedule 1-A line 28 rounds up.
3. Only new vehicles with final assembly in the US qualify, the loan must be originated after December 31, 2024, and leases never count.
4. Married filing separately can claim it, with the same $100,000 threshold as single filers.
5. The SALT cap is $40,000 for 2025 and $40,400 for 2026, not $10,000. Above $500,000 of MAGI it shrinks by 30 cents per dollar, but never below $10,000.
6. The 2026 standard deduction is $16,100 single and $32,200 joint (Rev. Proc. 2025-32). The child tax credit is $2,200, with up to $1,700 refundable.
7. The IRS has not published 2027 amounts yet (checked 2026-11-02). The tools say so instead of guessing.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://car-loan-interest-deduction-calculator-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http car-loan-interest-deduction-calculator https://car-loan-interest-deduction-calculator-mcp.lipmichal.workers.dev/mcp
claude mcp add car-loan-interest-deduction-calculator -- npx -y github:theluckystrike/car-loan-interest-deduction-calculator-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "car-loan-interest-deduction-calculator": { "command": "npx", "args": ["-y", "github:theluckystrike/car-loan-interest-deduction-calculator-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "car-loan-interest-deduction-calculator": { "url": "https://car-loan-interest-deduction-calculator-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `calculate_car_loan_interest_deduction` | Calculates the 2025-2028 federal deduction for car loan interest created by the One Big Beautiful Bill Act (P.L. 119-21, IRC 163(h)(4)) the way IRS Schedule 1-A Part IV... |
| `calculate_salt_deduction` | Calculates the deductible state and local tax (SALT) on Schedule A under the One Big Beautiful Bill Act cap (IRC 164(b)(6)-(7)): $40,000 for 2025 and $40,400 for 2026... |
| `get_tax_brackets_and_standard_deduction` | Returns the official 2025 and 2026 federal income tax brackets and standard deductions after the One Big Beautiful Bill Act: 2026 standard deduction $16,100 single... |
| `calculate_child_tax_credit` | Calculates the child tax credit as Schedule 8812 does after the One Big Beautiful Bill Act: $2,200 per qualifying child under 17 for 2025 and 2026, $500 per other... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "I paid $2,400 of interest in 2025 on a loan for a new US-assembled car bought in March 2025. Single, MAGI $85,000. How much can I deduct?" and the client sent this call.

```json
{"name": "calculate_car_loan_interest_deduction", "arguments": {"filing_status": "single", "magi": 85000, "tax_year": 2025, "interest_paid": 2400, "loan_origination_date": "2025-03-15", "new_vehicle": true, "us_final_assembly": true, "personal_use": true}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
Interest counted $2,400, $2,400 after the $10,000 cap. MAGI $85,000 is not over the $100,000 threshold, so nothing is phased out. Car loan interest deduction for 2025: $2,400. Assumed: the gross vehicle weight rating is under 14,000 pounds; the loan is secured by a first lien on the vehicle; the vehicle is a car, minivan, van, SUV, pickup truck or motorcycle.

This is an estimate, not tax advice. Check the IRS instructions or ask a tax professional before you file.
```

Data as of `2026-11-02`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that calculates the new car loan interest deduction?

Yes. Car loan interest deduction calculator (car-loan-interest-deduction-calculator-mcp) is a free MCP server. 2025-2028 car loan interest deduction, SALT cap, child tax credit and 2026 tax brackets (IRS). It is hosted at https://car-loan-interest-deduction-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/car-loan-interest-deduction-calculator-mcp.

### Does the Car loan interest deduction calculator MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.irs.gov/pub/irs-pdf/f1040s1a.pdf ; https://www.irs.gov/pub/irs-pdf/i1040gi.pdf ; https://www.irs.gov/pub/irs-drop/n-25-57.pdf. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/car-loan-interest-deduction-calculator-mcp](https://github.com/theluckystrike/car-loan-interest-deduction-calculator-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/car-loan-interest-deduction-calculator-mcp/](https://www.mcpstamp.com/free-servers/car-loan-interest-deduction-calculator-mcp/) on the mcpstamp.com free server list
- [Can Claude calculate the car loan interest deduction?](https://www.mcpstamp.com/can-claude/calculate-car-loan-interest-deduction/) on mcpstamp.com, the plain-English answer with a live call
- [taxbreakcalc.com](https://taxbreakcalc.com/car-loan-interest-calculator/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=car-loan-interest-deduction-calculator-mcp), the companion site this server's results link to

## More free live-data servers

- [CPI inflation calculator MCP server](/mcp/cpi-inflation-calculator-mcp/). Inflation calculator with official BLS CPI 1913 to the latest month, raise vs inflation, SS COLA.
- [Cups to grams converter MCP server](/mcp/cups-to-grams-mcp/). Cups to grams for 271 ingredients with USDA and King Arthur densities, recipe scaling, oven temps.
- [DSCR loan calculator MCP server](/mcp/dscr-loan-calculator-mcp/). DSCR loan calculator for rental property: DSCR, lender tiers, max loan, rent needed, amortization.
- [Tax Calc MCP server](/mcp/tax-calc/) from the back-office collection
- [Loan Calculator MCP server](/mcp/loan-calculator/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
