---
layout: default
title: "UK Statutory Sick Pay and Maternity Pay MCP server (free, no API key)"
description: "Free MCP server that calculates UK Statutory Sick Pay under the April 2026 rules. No API key: paste the hosted URL. UK Statutory Sick Pay (April…"
permalink: /mcp/uk-statutory-sick-pay-maternity-pay-calculator-mcp/
date: 2026-11-03
---

# UK Statutory Sick Pay and Maternity Pay MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "UK Statutory Sick Pay and Maternity Pay MCP server",
   "alternateName": "uk-statutory-sick-pay-maternity-pay-calculator-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "UK Statutory Sick Pay (April 2026 rules), Maternity Pay and National Living Wage from gov.uk.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/uk-statutory-sick-pay-maternity-pay-calculator-mcp/",
   "codeRepository": "https://github.com/theluckystrike/uk-statutory-sick-pay-maternity-pay-calculator-mcp",
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
     "name": "Is there an MCP server that calculates UK Statutory Sick Pay under the April 2026 rules?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. UK Statutory Sick Pay and Maternity Pay (uk-statutory-sick-pay-maternity-pay-calculator-mcp) is a free MCP server. UK Statutory Sick Pay (April 2026 rules), Maternity Pay and National Living Wage from gov.uk. It is hosted at https://uk-statutory-sick-pay-maternity-pay-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/uk-statutory-sick-pay-maternity-pay-calculator-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the UK Statutory Sick Pay and Maternity Pay MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.gov.uk/guidance/rates-and-thresholds-for-employers-2026-to-2027 ; https://www.gov.uk/guidance/statutory-sick-pay-manually-calculate-your-employees-payments ; https://www.legislation.gov.uk/ukpga/2025/36/section/10 ; https://www.legislation.gov.uk/uksi/2026/373/made. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "UK Statutory Sick Pay and Maternity Pay",
     "item": "https://claudecodeguides.com/mcp/uk-statutory-sick-pay-maternity-pay-calculator-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that calculates UK Statutory Sick Pay under the April 2026 rules? `uk-statutory-sick-pay-maternity-pay-calculator-mcp` is free, MIT licensed and needs no API key and no account. Paste https://uk-statutory-sick-pay-maternity-pay-calculator-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. UK Statutory Sick Pay (April 2026 rules), Maternity Pay and National Living Wage from gov.uk.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. From 6 April 2026 the Employment Rights Act 2025 (ss.10 and 11, commenced by SI 2026/373) removed the 3 SSP waiting days and the lower earnings limit. SSP is now the lower of £123.25 a week or 80% of average weekly earnings, paid from the first qualifying day.
2. Before 6 April 2026 SSP was £118.75 flat, needed earnings of at least £125 a week and 4 days of sickness in a row, and the first 3 qualifying days were unpaid.
3. HMRC's 2026/27 SSP day tables round the unrounded daily rate times days up to the next penny, so 4 days on a 6-day week is £82.17.
4. The 2026/27 family pay flat rate is £194.32 (2025/26: £187.18). The SMP rate changed on Sunday 5 April 2026, so a maternity pay period that crosses April uses both.
5. The lower earnings limit for maternity, paternity, adoption and shared parental pay is £129 a week in 2026/27 (£125 in 2025/26).
6. The National Living Wage is £12.71 an hour from 1 April 2026, with £10.85 for 18 to 20 and £8 for under 18s and apprentices. The April 2027 rates are already published: £13.21, £11.27 and £8.31.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://uk-statutory-sick-pay-maternity-pay-calculator-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http uk-statutory-sick-pay-maternity-pay-calculator https://uk-statutory-sick-pay-maternity-pay-calculator-mcp.lipmichal.workers.dev/mcp
claude mcp add uk-statutory-sick-pay-maternity-pay-calculator -- npx -y github:theluckystrike/uk-statutory-sick-pay-maternity-pay-calculator-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "uk-statutory-sick-pay-maternity-pay-calculator": { "command": "npx", "args": ["-y", "github:theluckystrike/uk-statutory-sick-pay-maternity-pay-calculator-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "uk-statutory-sick-pay-maternity-pay-calculator": { "url": "https://uk-statutory-sick-pay-maternity-pay-calculator-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `calculate_statutory_sick_pay` | Works out UK Statutory Sick Pay (SSP) for a period of sickness. |
| `calculate_statutory_maternity_pay` | Works out UK Statutory Maternity Pay (SMP) week by week for 39 weeks: 90% of average weekly earnings for 6 weeks, then the lower of the flat rate or 90% for 33 weeks. |
| `get_minimum_wage_rates` | Returns the UK National Living Wage and National Minimum Wage hourly rates in force on a date, by age band and apprentice rate, and the rate that applies to a given age. |
| `check_eligibility` | Checks the qualifying conditions for UK Statutory Sick Pay, Maternity, Paternity, Adoption or Shared Parental Pay and returns each condition as met, not met or not... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "An employee on 400 pounds a week is off sick for 10 working days from 4 May 2026. How much Statutory Sick Pay is due?" and the client sent this call.

```json
{"name": "calculate_statutory_sick_pay", "arguments": {"average_weekly_earnings": 400, "qualifying_days": 5, "days_off": 10, "start_date": "2026-05-04"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
Under the 2026/27 rules SSP is £123.25 a week (flat weekly rate). For 10 qualifying days off on a 5-day week, 10 days are payable from day one: total £246.50.

Estimate from gov.uk rates, not legal or payroll advice. Check special cases with HMRC or the gov.uk calculators.
```

Data as of `2026-11-02`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that calculates UK Statutory Sick Pay under the April 2026 rules?

Yes. UK Statutory Sick Pay and Maternity Pay (uk-statutory-sick-pay-maternity-pay-calculator-mcp) is a free MCP server. UK Statutory Sick Pay (April 2026 rules), Maternity Pay and National Living Wage from gov.uk. It is hosted at https://uk-statutory-sick-pay-maternity-pay-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/uk-statutory-sick-pay-maternity-pay-calculator-mcp.

### Does the UK Statutory Sick Pay and Maternity Pay MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.gov.uk/guidance/rates-and-thresholds-for-employers-2026-to-2027 ; https://www.gov.uk/guidance/statutory-sick-pay-manually-calculate-your-employees-payments ; https://www.legislation.gov.uk/ukpga/2025/36/section/10 ; https://www.legislation.gov.uk/uksi/2026/373/made. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/uk-statutory-sick-pay-maternity-pay-calculator-mcp](https://github.com/theluckystrike/uk-statutory-sick-pay-maternity-pay-calculator-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/uk-statutory-sick-pay-maternity-pay-calculator-mcp/](https://www.mcpstamp.com/free-servers/uk-statutory-sick-pay-maternity-pay-calculator-mcp/) on the mcpstamp.com free server list
- [ukmoneycalc.com](https://ukmoneycalc.com/calculators/take-home-pay/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=uk-statutory-sick-pay-maternity-pay-calculator-mcp), the companion site this server's results link to

## More free live-data servers

- [US federal holidays and business days MCP server](/mcp/us-federal-holidays-business-days-mcp/). Exact U.S. federal holidays and business days 1971-2100, OPM and Federal Reserve observance.
- [UV index today MCP server](/mcp/uv-index-today-mcp/). Today's UV Index forecast by US ZIP code or city, with hourly peak and UV Alert, from EPA and NWS.
- [Vegetable yield percentage MCP server](/mcp/vegetable-yield-percentage-mcp/). Vegetable and fruit yield percentage, trim waste and how much produce to buy, from USDA refuse data.
- [Leave MCP server](/mcp/leave/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
