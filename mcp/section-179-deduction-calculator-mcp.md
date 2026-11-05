---
layout: default
title: "Section 179 deduction calculator MCP server (free, no API key)"
description: "Free MCP server that calculates the Section 179 deduction for 2026. No API key: paste the hosted URL. Section 179 limits, 100% bonus depreciation…"
permalink: /mcp/section-179-deduction-calculator-mcp/
date: 2026-11-03
---

# Section 179 deduction calculator MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Section 179 deduction calculator MCP server",
   "alternateName": "section-179-deduction-calculator-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Section 179 limits, 100% bonus depreciation, heavy SUV caps and asset loan cost (2025-2026, IRS).",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/section-179-deduction-calculator-mcp/",
   "codeRepository": "https://github.com/theluckystrike/section-179-deduction-calculator-mcp",
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
     "name": "Is there an MCP server that calculates the Section 179 deduction for 2026?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Section 179 deduction calculator (section-179-deduction-calculator-mcp) is a free MCP server. Section 179 limits, 100% bonus depreciation, heavy SUV caps and asset loan cost (2025-2026, IRS). It is hosted at https://section-179-deduction-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/section-179-deduction-calculator-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Section 179 deduction calculator MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.irs.gov/pub/irs-drop/rp-25-32.pdf. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Section 179 deduction calculator",
     "item": "https://claudecodeguides.com/mcp/section-179-deduction-calculator-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that calculates the Section 179 deduction for 2026? `section-179-deduction-calculator-mcp` is free, MIT licensed and needs no API key and no account. Paste https://section-179-deduction-calculator-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Section 179 limits, 100% bonus depreciation, heavy SUV caps and asset loan cost (2025-2026, IRS).

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. The One Big Beautiful Bill Act raised the Section 179 limit to $2,500,000 for 2025. Rev. Proc. 2025-32 set $2,560,000 and a $4,090,000 phase-out start for 2026.
2. Bonus depreciation is 100% again, permanently, for property acquired after January 19, 2025. The acquisition date is the date of a written binding contract, not delivery.
3. Property acquired on or before January 19, 2025 and placed in service in 2025 gets 40%, not 100% (60% for long production property).
4. In the first tax year ending after January 19, 2025 you can elect 40% instead of 100%.
5. The 2026 heavy SUV cap is $32,000, and the 2026 first-year cap on a car of 6,000 lb or less is $20,300 with bonus (Rev. Proc. 2026-15).
6. The IRS has not published the 2027 limits yet (checked 2026-11-02). The tools say so instead of guessing.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://section-179-deduction-calculator-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http section-179-deduction-calculator https://section-179-deduction-calculator-mcp.lipmichal.workers.dev/mcp
claude mcp add section-179-deduction-calculator -- npx -y github:theluckystrike/section-179-deduction-calculator-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "section-179-deduction-calculator": { "command": "npx", "args": ["-y", "github:theluckystrike/section-179-deduction-calculator-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "section-179-deduction-calculator": { "url": "https://section-179-deduction-calculator-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `calculate_section_179` | Calculates the Section 179 expense deduction as Form 4562 Part I does, with the limits raised by the One Big Beautiful Bill Act: $2,500,000 for 2025 with a... |
| `calculate_bonus_depreciation` | Finds the special (bonus) depreciation rate under IRC 168(k) from the acquisition and placed-in-service dates and applies it after any Section 179 deduction. |
| `get_vehicle_depreciation_limits` | Returns the first-year write-off limits for a business vehicle by gross vehicle weight rating: passenger automobiles of 6,000 lb or less are held to the IRC 280F caps... |
| `calculate_asset_loan_payment` | Calculates the exact monthly payment, total interest and first-year interest for an equipment, truck, tractor, RV, land, manufactured home, ATV, pontoon or other asset... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "I bought $180,000 of equipment in 2026 and my business income is $250,000. How much can I expense under Section 179?" and the client sent this call.

```json
{"name": "calculate_section_179", "arguments": {"tax_year": 2026, "total_section_179_property_cost": 180000, "business_taxable_income": 250000}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
2026 Section 179 limit $2,560,000. Property cost $180,000 is under the $4,090,000 threshold, so the full limit applies. Elected $180,000. Deduction this year $180,000.

This is an estimate, not tax advice. Check Form 4562, its instructions and Pub. 946, or ask a tax professional before you file.
```

Data as of `2026-11-02`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that calculates the Section 179 deduction for 2026?

Yes. Section 179 deduction calculator (section-179-deduction-calculator-mcp) is a free MCP server. Section 179 limits, 100% bonus depreciation, heavy SUV caps and asset loan cost (2025-2026, IRS). It is hosted at https://section-179-deduction-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/section-179-deduction-calculator-mcp.

### Does the Section 179 deduction calculator MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.irs.gov/pub/irs-drop/rp-25-32.pdf. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/section-179-deduction-calculator-mcp](https://github.com/theluckystrike/section-179-deduction-calculator-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/section-179-deduction-calculator-mcp/](https://www.mcpstamp.com/free-servers/section-179-deduction-calculator-mcp/) on the mcpstamp.com free server list
- [Can Claude calculate a Section 179 deduction?](https://www.mcpstamp.com/can-claude/calculate-section-179-deduction/) on mcpstamp.com, the plain-English answer with a live call
- [assetloancalculator.com](https://assetloancalculator.com/section-179-deduction-calculator/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=section-179-deduction-calculator-mcp), the companion site this server's results link to

## More free live-data servers

- [Silver price per gram MCP server](/mcp/silver-price-per-gram-mcp/). Live silver price per gram by fineness and currency, junk silver coin value, gold silver ratio.
- [Social Security COLA 2027 MCP server](/mcp/social-security-cola-2027-mcp/). Social Security COLA 2027, full retirement age, earnings test and 2027 limits from SSA notices.
- [Student loan RAP calculator MCP server](/mcp/student-loan-repayment-assistance-plan-calculator-mcp/). Student loan RAP payment calculator, 2026 federal loan limits, SAVE/PAYE/ICR end dates (OBBBA).
- [Asset Register MCP server](/mcp/asset-register/) from the back-office collection
- [Tax Calc MCP server](/mcp/tax-calc/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
