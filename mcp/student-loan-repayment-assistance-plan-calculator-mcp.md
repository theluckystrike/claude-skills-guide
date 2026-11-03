---
layout: default
title: "Student loan RAP calculator MCP server (free, no API key)"
description: "Free MCP server that calculates the new RAP student loan payment. No API key: paste the hosted URL. Student loan RAP payment calculator, 2026…"
permalink: /mcp/student-loan-repayment-assistance-plan-calculator-mcp/
date: 2026-11-03
---

# Student loan RAP calculator MCP server (free, no API key)

<script type="application/ld+json">
{
 "@context": "https://schema.org",
 "@graph": [
  {
   "@type": "SoftwareApplication",
   "name": "Student loan RAP calculator MCP server",
   "alternateName": "student-loan-repayment-assistance-plan-calculator-mcp",
   "applicationCategory": "DeveloperApplication",
   "operatingSystem": "macOS, Windows, Linux, any MCP client over Streamable HTTP",
   "description": "Student loan RAP payment calculator, 2026 federal loan limits, SAVE/PAYE/ICR end dates (OBBBA).",
   "softwareVersion": "1.0.1",
   "url": "https://claudecodeguides.com/mcp/student-loan-repayment-assistance-plan-calculator-mcp/",
   "codeRepository": "https://github.com/theluckystrike/student-loan-repayment-assistance-plan-calculator-mcp",
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
     "name": "Is there an MCP server that calculates the new RAP student loan payment?",
     "acceptedAnswer": {
      "@type": "Answer",
      "text": "Yes. Student loan RAP calculator (student-loan-repayment-assistance-plan-calculator-mcp) is a free MCP server. Student loan RAP payment calculator, 2026 federal loan limits, SAVE/PAYE/ICR end dates (OBBBA). It is hosted at https://student-loan-repayment-assistance-plan-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/student-loan-repayment-assistance-plan-calculator-mcp."
     }
    },
    {
     "@type": "Question",
     "name": "Does the Student loan RAP calculator MCP server need an API key?",
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
      "text": "Each result carries an as_of date and a source. In the live call on this page the source was https://www.govinfo.gov/content/pkg/PLAW-119publ21/html/PLAW-119publ21.htm. The full source list is in DATA_SOURCES.md in the repository."
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
     "name": "Student loan RAP calculator",
     "item": "https://claudecodeguides.com/mcp/student-loan-repayment-assistance-plan-calculator-mcp/"
    }
   ]
  }
 ]
}
</script>

Looking for an MCP server that calculates the new RAP student loan payment? `student-loan-repayment-assistance-plan-calculator-mcp` is free, MIT licensed and needs no API key and no account. Paste https://student-loan-repayment-assistance-plan-calculator-mcp.lipmichal.workers.dev/mcp into any MCP client that takes a remote server URL. Student loan RAP payment calculator, 2026 federal loan limits, SAVE/PAYE/ICR end dates (OBBBA).

Tools 4, version 1.0.1, licence MIT. Part of the [free live-data MCP servers](/mcp/#free-live-data-mcp-servers-no-key) on this hub.

## What it answers that a model cannot answer alone

A language model answers from training data that is months old and does arithmetic from memory. This server returns the current figure with its source. In the words of its README, it knows these things that your model does not.

1. RAP base payment is a percent of the whole AGI by band: $120 a year at $10,000 or less, then 1% (over $10,000) up to 10% (over $100,000). Divide by 12, subtract $50 per dependent, and never pay less than $10.
2. Because the percent applies to all of AGI, $50,001 pays 5% ($208.34 a month) while $50,000 pays 4% ($166.67).
3. On-time RAP payments that do not cover the month's interest: the unpaid interest is not charged. If principal drops by less than $50, the Department adds a match so it drops by the lesser of $50 or the payment.
4. The remaining balance is cancelled after 360 qualifying payments. On-time RAP payments and 10-year Standard payments count for PSLF (HEA 455(m)(1)(A) as amended by P.L. 119-21 sec. 82004). The Tiered Standard plan does not (StudentAid.gov).
5. Tiered Standard: 10 years under $25,000, 15 under $50,000, 20 under $100,000, 25 at $100,000 or more.
6. From July 1, 2026: Grad PLUS ends for new borrowers, graduate loans cap at $20,500 a year and $100,000, professional at $50,000 and $200,000, Parent PLUS at $20,000 a year and $65,000 per student, and $257,500 lifetime.
7. A court order ended SAVE in March 2026. Servicers send 90-day notices from July 1, 2026, then a final 30-day notice. PAYE and ICR end no later than July 1, 2028, when remaining borrowers go to RAP or IBR.

## Connect it with no key

Hosted URL for Claude.ai custom connectors, ChatGPT developer mode and any client that takes a remote MCP server. Paste it as is. No token, no sign-up.

```
https://student-loan-repayment-assistance-plan-calculator-mcp.lipmichal.workers.dev/mcp
```

Claude Code, hosted or local:

```
claude mcp add --transport http student-loan-repayment-assistance-plan-calculator https://student-loan-repayment-assistance-plan-calculator-mcp.lipmichal.workers.dev/mcp
claude mcp add student-loan-repayment-assistance-plan-calculator -- npx -y github:theluckystrike/student-loan-repayment-assistance-plan-calculator-mcp
```

Claude Desktop (`claude_desktop_config.json`), runs locally with Node 20 or newer:

```json
{
  "mcpServers": {
    "student-loan-repayment-assistance-plan-calculator": { "command": "npx", "args": ["-y", "github:theluckystrike/student-loan-repayment-assistance-plan-calculator-mcp"] }
  }
}
```

Cursor (`~/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "student-loan-repayment-assistance-plan-calculator": { "url": "https://student-loan-repayment-assistance-plan-calculator-mcp.lipmichal.workers.dev/mcp" }
  }
}
```

## Tools it exposes

| Tool | What it does |
| --- | --- |
| `calculate_rap_payment` | Calculates the federal student loan Repayment Assistance Plan (RAP) payment created by the One Big Beautiful Bill Act (P.L. 119-21, HEA sec. 455(q)), open since July 1... |
| `compare_rap_vs_standard` | Compares the new Repayment Assistance Plan with the Tiered Standard plan (P.L. 119-21: 10 years under $25,000, 15 under $50,000, 20 under $100,000, 25 at $100,000 or... |
| `get_federal_loan_limits` | Returns federal Direct Loan borrowing limits in force on a date. |
| `get_plan_transition_dates` | Lists the dated steps of the federal student loan repayment overhaul: SAVE ended by court order (March 2026) with 90-day servicer notices from July 1, 2026 plus a final... |

## Example output from a live call

Called on 2026-11-03 against the hosted URL above, with no token. The prompt was "I owe $38,000 at 6.5%, AGI $52,000, one dependent. What would I pay on RAP compared with the standard plan?" and the client sent this call.

```json
{"name": "compare_rap_vs_standard", "arguments": {"balance": 38000, "rate": 6.5, "agi": 52000, "dependents": 1}}
```

The server answered with this plain-English summary (the structured JSON that follows it in the result is left out here).

```text
For $38,000.00 at 6.5% and AGI $52,000.00: RAP $166.67 a month, $19,869.14 cancelled after 360 payments, total $60,001.20. Tiered Standard (15 years) $331.02 a month, total $59,583.79. 10-year Standard $431.48 a month, total $51,778.01. Lowest monthly payment: RAP. Lowest total paid: 10-year Standard. RAP and the 10-year Standard plan count toward PSLF; Tiered Standard does not.

General information, not financial or legal advice. Your servicer computes the official payment from your certified income and loan records. Use the StudentAid.gov Loan Simulator to confirm.
```

Data as of `2026-11-02`. The result also returns the source URL and a link for more detail.

## Questions people actually ask

### Is there an MCP server that calculates the new RAP student loan payment?

Yes. Student loan RAP calculator (student-loan-repayment-assistance-plan-calculator-mcp) is a free MCP server. Student loan RAP payment calculator, 2026 federal loan limits, SAVE/PAYE/ICR end dates (OBBBA). It is hosted at https://student-loan-repayment-assistance-plan-calculator-mcp.lipmichal.workers.dev/mcp with no token, and it also runs locally with npx -y github:theluckystrike/student-loan-repayment-assistance-plan-calculator-mcp.

### Does the Student loan RAP calculator MCP server need an API key?

No. The hosted endpoint answers tools/list and tools/call without a token or sign-up. The example on this page was called that way on 2026-11-03.

### Is it free?

Yes. The code is MIT licensed and the hosted endpoint is free to call. This server has no paid tier at all.

### Where do the numbers come from?

Each result carries an as_of date and a source. In the live call on this page the source was https://www.govinfo.gov/content/pkg/PLAW-119publ21/html/PLAW-119publ21.htm. The full source list is in DATA_SOURCES.md in the repository.


## Links

- [github.com/theluckystrike/student-loan-repayment-assistance-plan-calculator-mcp](https://github.com/theluckystrike/student-loan-repayment-assistance-plan-calculator-mcp), source, README and data sources (MIT)
- [www.mcpstamp.com/free-servers/student-loan-repayment-assistance-plan-calculator-mcp/](https://www.mcpstamp.com/free-servers/student-loan-repayment-assistance-plan-calculator-mcp/) on the mcpstamp.com free server list
- [Can Claude calculate a RAP student loan payment?](https://www.mcpstamp.com/can-claude/calculate-rap-student-loan-payment/) on mcpstamp.com, the plain-English answer with a live call
- [mcpstamp.com](https://www.mcpstamp.com/free-servers/?utm_source=claudecodeguides&utm_medium=mcp-hub&utm_campaign=student-loan-repayment-assistance-plan-calculator-mcp), the companion site this server's results link to

## More free live-data servers

- [Subdomain finder MCP server](/mcp/subdomain-finder-mcp/). Passive subdomain enumeration from certificate transparency (certspotter, crt.sh) with DNS checks.
- [UK income tax and salary MCP server](/mcp/uk-income-tax-salary-mcp/). UK income tax and take-home pay 2025/26 and 2026/27: Scottish bands, NI, student loans, 60% trap.
- [UK Statutory Sick Pay and Maternity Pay MCP server](/mcp/uk-statutory-sick-pay-maternity-pay-calculator-mcp/). UK Statutory Sick Pay (April 2026 rules), Maternity Pay and National Living Wage from gov.uk.

---

[All MCP servers on this hub](/mcp/) &middot; [free live-data servers with no key](/mcp/#free-live-data-mcp-servers-no-key)
