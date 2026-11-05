---
layout: default
title: "UK income tax and salary MCP server (free, no API key)"
description: "Free MCP server that calculates UK take-home pay for 2026/27. No API key: paste the hosted URL. UK income tax and take-home pay 2025/26 and 2026/27…"
permalink: /mcp/uk-income-tax-salary-mcp/
date: 2026-11-03
---

# UK income tax and salary MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "UK income tax and salary MCP server",
   "alternateName": "uk-income-tax-salary-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "UK income tax and take-home pay 2025/26 and 2026/27: Scottish bands, NI, student loans, 60% trap.",
   "softwareVersion": "1.0.0",
   "url": "https://claudecodeguides.com/mcp/uk-income-tax-salary-mcp/",
   "codeRepository": "https://github.com/theluckystrike/uk-income-tax-salary-mcp",
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
     "name": "Is there an MCP server that calculates UK take-home pay for 2026/27?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. UK income tax and salary (uk-income-tax-salary-mcp) is a free MCP server. UK income tax and take-home pay 2025/26 and 2026/27: Scottish bands, NI, student loans, 60% trap. It is hosted at https://uk-income-tax-salary-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/uk-income-tax-salary-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the UK income tax and salary MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.gov.uk/guidance/rates-and-thresholds-for-employers-2026-to-2027 ; https://www.gov.uk/income-tax-rates ; https://www.gov.uk/national-insurance-rates-letters. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "UK income tax and salary",
     "item": "https://claudecodeguides.com/mcp/uk-income-tax-salary-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that calculates UK take-home pay for 2026/27? `uk-income-tax-salary-mcp` is free, MIT licensed and needs no API key and no account. Paste https://uk-income-tax-salary-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. UK income tax and take-home pay 2025/26 and 2026/27: Scottish bands, NI, student loans, 60% trap.

Tools 4, version 1.0.0, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. The 2026/27 Scottish bands. The starter band now runs to £16,537 and the basic band to £29,526 (2025/26: £15,397 and £27,491).
2. The 2026/27 student loan thresholds: Plan 1 £26,900, Plan 2 £29,385, Plan 4 £33,795, Postgraduate £21,000, and the first Plan 5 threshold of £25,000. Plan 5 has no threshold in 2025/26.
3. The 2026/27 NI lower earnings limit of £6,708 and the 8% / 2% employee rates by category letter.
4. The taper takes £1 of allowance for every complete £2 over £100,000. That makes the marginal rate 62% in England with NI, and 69.5% in Scotland's 45% advanced band.
5. With relief at source you pay 80% and claim the rest above 20% yourself, and the grossed-up contribution lowers adjusted net income for the taper. Salary sacrifice also cuts NI and student loan.
6. Several student loan plans repay 9% over the lowest threshold, plus 6% over the Postgraduate threshold, as gov.uk describes.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://uk-income-tax-salary-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http uk-income-tax-salary https://uk-income-tax-salary-mcp.lipmichal.workers.dev/mcp
claude mcp add uk-income-tax-salary -- npx -y github:theluckystrike/uk-income-tax-salary-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "uk-income-tax-salary": { "command": "npx", "args": ["-y", "github:theluckystrike/uk-income-tax-salary-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "uk-income-tax-salary": { "url": "https://uk-income-tax-salary-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `calculate_uk_take_home` | Calculates UK take-home pay for an employee in tax year 2025/26 or 2026/27 from HMRC's published rates: income tax by band (England, Wales and NI, or the six Scottish... |
| `get_uk_tax_bands` | Returns the official UK income tax bands for 2025/26 or 2026/27, for England, Wales and Northern Ireland or for Scotland (starter 19%, basic 20%, intermediate 21%... |
| `compare_salaries` | Compares 1 to 5 UK gross salaries after income tax, National Insurance, student loan and pension for 2025/26 or 2026/27, with the same region, tax code and options for... |
| `marginal_rate_at_income` | Returns the true UK marginal rate on the next pounds of salary in 2025/26 or 2026/27: income tax band rate, employee NI and student loan together, plus the Personal... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "What is my take-home pay on a 45,000 pound salary in England for 2026/27?" and the client sent this call.

```json
{"name": "calculate_uk_take_home", "arguments": {"gross_salary": 45000, "tax_year": "2026/27"}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
On £45,000 in 2026/27 (England, Wales or NI, code 1257L) take-home pay is £35,919.60 a year, £2,993.30 a month or £690.76 a week. Income tax £6,486, National Insurance £2,594.40.

Estimate for one employment, worked out on annual figures. Payroll works per pay period, so a payslip can differ by a few pounds. Not tax advice.
```

Data as of `2026-10-30`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that calculates UK take-home pay for 2026/27?

Yes. UK income tax and salary (uk-income-tax-salary-mcp) is a free MCP server. UK income tax and take-home pay 2025/26 and 2026/27: Scottish bands, NI, student loans, 60% trap. It is hosted at https://uk-income-tax-salary-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/uk-income-tax-salary-mcp.

### Does the UK income tax and salary MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.gov.uk/guidance/rates-and-thresholds-for-employers-2026-to-2027 ; https://www.gov.uk/income-tax-rates ; https://www.gov.uk/national-insurance-rates-letters. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/uk-income-tax-salary-mcp](https://github.com/theluckystrike/uk-income-tax-salary-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/uk-income-tax-salary-mcp/](https://www.mcpstamp.com/free-servers/uk-income-tax-salary-mcp/) on the mcpstamp.com free server list
- [Can Claude work out UK take-home pay for 2026/27?](https://www.mcpstamp.com/can-claude/calculate-uk-take-home-pay/) on mcpstamp.com, the plain-English answer with a live call
- [ukmoneycalc.com](https://ukmoneycalc.com/calculators/take-home-pay/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=uk-income-tax-salary-mcp), the companion site this server's results link to

## More free live-data servers

- [UK Statutory Sick Pay and Maternity Pay MCP server](/mcp/uk-statutory-sick-pay-maternity-pay-calculator-mcp/). UK Statutory Sick Pay (April 2026 rules), Maternity Pay and National Living Wage from gov.uk.
- [US federal holidays and business days MCP server](/mcp/us-federal-holidays-business-days-mcp/). Exact U.S. federal holidays and business days 1971-2100, OPM and Federal Reserve observance.
- [UV index today MCP server](/mcp/uv-index-today-mcp/). Today's UV Index forecast by US ZIP code or city, with hourly peak and UV Alert, from EPA and NWS.
- [Payroll MCP server](/mcp/payroll/) from the back-office collection

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
