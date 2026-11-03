---
layout: default
title: "No tax on overtime calculator MCP server (free, no API key)"
description: "Free MCP server that calculates the no tax on overtime deduction. No API key: paste the hosted URL. No tax on overtime, tips and senior deductions…"
permalink: /mcp/no-tax-on-overtime-mcp/
date: 2026-11-03
---

# No tax on overtime calculator MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "No tax on overtime calculator MCP server",
   "alternateName": "no-tax-on-overtime-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "No tax on overtime, tips and senior deductions for 2025-2028 (OBBBA), with IRS caps and phase-outs.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/no-tax-on-overtime-mcp/",
   "codeRepository": "https://github.com/theluckystrike/no-tax-on-overtime-mcp",
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
     "name": "Is there an MCP server that calculates the no tax on overtime deduction?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. No tax on overtime calculator (no-tax-on-overtime-mcp) is a free MCP server. No tax on overtime, tips and senior deductions for 2025-2028 (OBBBA), with IRS caps and phase-outs. It is hosted at https://no-tax-on-overtime-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/no-tax-on-overtime-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the No tax on overtime calculator MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.irs.gov/pub/irs-pdf/f1040s1a.pdf ; https://www.irs.gov/pub/taxpros/fs-2026-13.pdf. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "No tax on overtime calculator",
     "item": "https://claudecodeguides.com/mcp/no-tax-on-overtime-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that calculates the no tax on overtime deduction? `no-tax-on-overtime-mcp` is free, MIT licensed and needs no API key and no account. Paste https://no-tax-on-overtime-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. No tax on overtime, tips and senior deductions for 2025-2028 (OBBBA), with IRS caps and phase-outs.

Tools 5, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. These deductions started in tax year 2025, after most models were trained. The law was signed on July 4, 2025.
2. The phase-out is $100 for each full $1,000 of MAGI over the threshold, rounded down, as Schedule 1-A lines 16-21 do it. It is not a smooth percentage.
3. Only the FLSA premium qualifies. Ten double-time hours at $20 give $100 of qualified overtime, not $200 (IRS FS-2026-13 A16).
4. From 2026 you may not use more than the amount in Form W-2 box 12 code TT. If your employer leaves it out, you need a Form W-2c (FS-2026-13, August 2026).
5. The tips cap is $25,000 per return even on a joint return. The overtime cap doubles for joint returns. The senior reduction applies to each spouse separately.
6. Married filing separately gets nothing from any of the three.
7. 2025 and 2026 brackets from Rev. Proc. 2024-40 and Rev. Proc. 2025-32, including the OBBBA standard deduction amounts.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://no-tax-on-overtime-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http no-tax-on-overtime https://no-tax-on-overtime-mcp.lipmichal.workers.dev/mcp
claude mcp add no-tax-on-overtime -- npx -y github:theluckystrike/no-tax-on-overtime-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "no-tax-on-overtime": { "command": "npx", "args": ["-y", "github:theluckystrike/no-tax-on-overtime-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "no-tax-on-overtime": { "url": "https://no-tax-on-overtime-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `calculate_overtime_deduction` | Calculates the 2025-2028 federal deduction for qualified overtime pay under the One Big Beautiful Bill Act (P.L. 119-21, IRC 225) as IRS Schedule 1-A Part III does: the... |
| `calculate_tips_deduction` | Calculates the 2025-2028 federal deduction for qualified tips under the One Big Beautiful Bill Act (P.L. 119-21, IRC 224) as IRS Schedule 1-A Part II does: a $25,000... |
| `calculate_senior_deduction` | Calculates the 2025-2028 enhanced deduction for seniors under the One Big Beautiful Bill Act (P.L. 119-21) as IRS Schedule 1-A Part V does: $6,000 per person age 65 or... |
| `estimate_tax_savings` | Estimates the federal income tax saved in 2025-2028 by the One Big Beautiful Bill Act overtime, tips and senior deductions combined. |
| `explain_eligibility` | Explains who can claim the 2025-2028 One Big Beautiful Bill Act deductions for overtime, tips and seniors: years covered, excluded filing status (married filing... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "I earn $24 an hour and worked 300 overtime hours at time and a half in 2025. Single, MAGI $68,000. What is my no tax on overtime deduction?" and the client sent this call.

```json
{"name": "calculate_overtime_deduction", "arguments": {"filing_status": "single", "magi": 68000, "tax_year": 2025, "hourly_rate": 24, "overtime_hours": 300, "multiplier": 1.5}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
Qualified overtime premium $3,600. After the $12,500 cap: $3,600. MAGI $68,000 is not above the $150,000 threshold, so there is no phase-out. Deduction for 2025: $3,600. Only the FLSA premium (the "half" in time-and-a-half) qualifies, not the straight-time part or any extra premium.

This is an estimate, not tax advice. Check the IRS instructions for Schedule 1-A or ask a tax professional before you file.
```

Data as of `2026-10-30`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that calculates the no tax on overtime deduction?

Yes. No tax on overtime calculator (no-tax-on-overtime-mcp) is a free MCP server. No tax on overtime, tips and senior deductions for 2025-2028 (OBBBA), with IRS caps and phase-outs. It is hosted at https://no-tax-on-overtime-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/no-tax-on-overtime-mcp.

### Does the No tax on overtime calculator MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.irs.gov/pub/irs-pdf/f1040s1a.pdf ; https://www.irs.gov/pub/taxpros/fs-2026-13.pdf. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/no-tax-on-overtime-mcp](https://github.com/theluckystrike/no-tax-on-overtime-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/no-tax-on-overtime-mcp/](https://www.mcpstamp.com/free-servers/no-tax-on-overtime-mcp/) on the mcpstamp.com free server list
- [Can Claude calculate the no tax on overtime deduction?](https://www.mcpstamp.com/can-claude/calculate-no-tax-on-overtime/) on mcpstamp.com, the plain-English answer with a live call
- [noovertimetax.com](https://noovertimetax.com/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=no-tax-on-overtime-mcp), the companion site this server's results link to

## More free live-data servers

- [Paycheck calculator MCP server](/mcp/paycheck-calculator-mcp/). Take-home pay for 2025-2026: IRS brackets, FICA wage base and state income tax for 50 states + DC.
- [Raw to cooked weight MCP server](/mcp/raw-to-cooked-weight-mcp/). Raw to cooked weight of meat and poultry by cut and cooking method from USDA cooking yields.
- [Recipe nutrition calculator MCP server](/mcp/recipe-nutrition-calculator-mcp/). Recipe nutrition from ingredient lines: USDA FoodData Central values, per serving, FDA rounding.
- [Payroll MCP server](/mcp/payroll/) from the back-office collection
- [Tax Calc MCP server](/mcp/tax-calc/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
