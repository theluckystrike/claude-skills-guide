---

layout: default
title: "Claude Code + Infracost Cost Estimation (2026)"
description: "Estimate AWS, GCP, and Azure infrastructure costs from your terminal with Infracost and Claude Code. Get cost breakdowns before applying Terraform."
date: 2026-03-14
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
author: "Claude Skills Guide"
permalink: /claude-code-infracost-cost-estimation-guide/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Infrastructure cost estimation is one of those tasks that feels simple until you are three months into a project and realize your AWS bill is triple what you projected. Infracost solves this problem by bringing cost visibility to your infrastructure-as-code workflow, and when combined with Claude Code, it becomes a powerful assistant for making cost-conscious decisions before you deploy.

## What Infracost Brings to Your Workflow

Infracost is an open-source tool that parses your Terraform, CloudFormation, or Pulumi files and outputs cost estimates based on real cloud pricing. It integrates directly into your CI/CD pipeline, but its true power emerges when you can query costs conversationally through Claude Code.

The standard CLI workflow requires you to remember flags, file paths, and output formats. With Claude Code, you can simply ask "What's the monthly cost of this EC2 instance?" and get an immediate breakdown without leaving your terminal. This conversational interface lowers the barrier to cost-aware decision making.

Before Infracost existed, teams estimated costs by manually checking each provider's pricing page, multiplying by hours per month, and hoping they did not miss any data transfer or storage fees. Infracost automates that calculation across every resource in a Terraform module simultaneously. Combined with Claude Code's ability to explain tradeoffs and suggest alternatives, the result is a workflow that catches expensive mistakes during code review rather than on the invoice.

## Setting Up Infracost with Claude Code

Before you can estimate costs through Claude, ensure Infracost is installed and authenticated. The quickest setup involves three steps:

First, install Infracost using your preferred package manager:

```bash
brew install infracost
```

Or on Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
```

Verify the installation:

```bash
infracost --version
infracost v0.10.x
```

Next, configure your cloud credentials. Infracost supports AWS, Google Cloud, and Azure. For AWS, ensure your credentials are available in the standard environment variables or AWS credentials file:

```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-east-1
```

Infracost does not need write access to your account. it only reads your Terraform state and pricing APIs. Finally, obtain a free API key from Infracost's pricing page and store it:

```bash
infracost auth login
```

Once Infracost is operational, you can invoke it through Claude Code using standard shell commands or, more elegantly, by creating a dedicated Claude skill for infrastructure cost analysis.

## Running Your First Estimate

With installation complete, point Infracost at any Terraform directory:

```bash
infracost breakdown --path ./terraform/
```

A typical output looks like this:

```
Project: my-service

 Name Monthly Qty Unit Monthly Cost

 aws_instance.web
 Instance usage (Linux/UNIX, on-demand, t3.medium) 730 hours $30.37
 root_volume: Storage (general purpose SSD, gp2) 20 GB $2.00

 aws_db_instance.postgres
 Database instance (on-demand, db.t3.medium) 730 hours $52.56
 Storage (general purpose SSD, gp2) 20 GB $2.30
 Additional backup storage 0 GB $0.00

 aws_alb.main
 Application load balancer 730 hours $16.43

 OVERALL TOTAL $103.66
```

Paste this output into Claude Code and ask: "Which resource is the most expensive and what are two ways I could reduce that cost without changing the application tier?" Claude will identify the RDS instance, then suggest switching to Aurora Serverless for variable workloads or buying a one-year reserved instance for steady-state production traffic.

## Creating a Cost Estimation Skill

A well-designed Claude skill can wrap Infracost's functionality with context-aware prompts. Consider creating a skill called `infracost-analyzer` that handles common cost estimation scenarios. This skill would declare the necessary tools and provide templates for different query types.

The skill structure would include front matter specifying bash as the primary tool, followed by guidance on how to interpret Infracost's output. When you invoke this skill with a Terraform file path, Claude can run the appropriate Infracost command and explain the results in plain language.

A minimal skill definition stored in `.claude/skills/infracost-analyzer.md` might look like this:

```markdown
---
name: infracost-analyzer
description: Estimate and explain infrastructure costs using Infracost
tools: [bash]
---

When given a Terraform path, run:
 infracost breakdown --path <path> --format json

Parse the JSON output and present:
1. Total monthly cost
2. Top 3 cost drivers with percentages
3. One optimization suggestion per major resource type
4. Estimated annual cost

If asked to compare two configurations, run breakdown on each and
produce a diff table showing the cost change per resource.
```

With this skill active, you can invoke it with `/infracost-analyzer ./terraform/services/api` and receive a structured cost report rather than raw CLI output.

This approach works particularly well when combined with other skills in your toolkit. For instance, after receiving a cost estimate, you could ask Claude to optimize the configuration using patterns from the `tdd` skill to refactor the infrastructure code for better cost efficiency.

## Practical Examples for Developers

Let's walk through three realistic scenarios where Claude Code combined with Infracost saves time and money.

## Scenario 1: Estimating a New Service

You are building a new microservice and need to estimate its infrastructure cost before writing the PR. Your Terraform defines an ECS cluster, RDS instance, and Application Load Balancer. Simply share the Terraform file with Claude and ask for a monthly cost breakdown.

Claude executes `infracost breakdown --path ./terraform/` and presents the results in a structured format. You can then ask follow-up questions like "What happens to the cost if we switch to a t3.micro instance?" and Claude will modify the Terraform temporarily, run Infracost again, and show the difference.

Here is what a cost comparison workflow looks like in practice:

```bash
Save baseline estimate
infracost breakdown --path ./terraform/ --format json > baseline.json

Make a change. switch db.t3.medium to db.t3.small in variables.tf
Then run diff against baseline
infracost diff --path ./terraform/ --compare-to baseline.json
```

Infracost diff output:

```
~ aws_db_instance.postgres
 ~ Database instance (on-demand, db.t3.small vs db.t3.medium)
 730 hours $26.28 vs $52.56 (-$26.28)

Monthly cost change: -$26.28 (-25%)
```

Ask Claude Code: "We are downgrading the database instance to save $26/month. What are the performance implications for a PostgreSQL database handling 500 concurrent connections?" This gives you the cost context alongside the engineering tradeoff in a single conversation.

## Scenario 2: Comparing AWS vs GCP for the Same Workload

You need to make a platform decision and want quick cost comparisons. Share your requirements with Claude and ask for parallel estimates across providers. The skill can generate provider-specific Terraform configurations, run Infracost against each, and produce a comparison table.

Here is an example comparison for a standard web application stack:

| Resource | AWS (us-east-1) | GCP (us-central1) | Azure (eastus) |
|---|---|---|---|
| 2x app servers (4 vCPU, 8 GB) | $140/mo | $132/mo | $138/mo |
| Managed database (4 vCPU, 16 GB) | $245/mo | $210/mo | $228/mo |
| Load balancer | $16/mo | $18/mo | $19/mo |
| 1 TB egress | $90/mo | $85/mo | $87/mo |
| Total | $491/mo | $445/mo | $472/mo |

Claude Code can generate this table automatically when you supply requirements rather than a completed Terraform file. Ask: "Generate minimal Terraform configurations for AWS, GCP, and Azure that represent a two-tier web application with the specs above, then run Infracost on each and give me a cost comparison table."

This workflow shines when combined with the `supermemory` skill, which can store these comparisons for later reference during architecture reviews.

## Scenario 3: Ongoing Cost Monitoring

For projects already deployed, set up a recurring check where Claude runs Infracost against your current infrastructure state and alerts you to cost anomalies. This proactive approach catches unexpected cost spikes before they impact your monthly budget.

A simple shell script scheduled via cron handles this:

```bash
#!/bin/bash
cost-monitor.sh. run daily via cron

TERRAFORM_PATH="/home/deploy/infra/production"
BASELINE_PATH="/home/deploy/infra/cost-baseline.json"
ALERT_THRESHOLD=10 # alert if monthly cost increases by more than 10%

current=$(infracost breakdown --path "$TERRAFORM_PATH" --format json)
echo "$current" > /tmp/current-cost.json

if [ -f "$BASELINE_PATH" ]; then
 diff_output=$(infracost diff \
 --path "$TERRAFORM_PATH" \
 --compare-to "$BASELINE_PATH" \
 --format json)

 pct_change=$(echo "$diff_output" | \
 python3 -c "import json,sys; d=json.load(sys.stdin); \
 print(d['diffTotalMonthlyCost']['percentage'])")

 if (( $(echo "$pct_change > $ALERT_THRESHOLD" | bc -l) )); then
 echo "ALERT: Infrastructure cost increased by ${pct_change}%" | \
 mail -s "Cost spike detected" ops@example.com
 fi
fi

cp /tmp/current-cost.json "$BASELINE_PATH"
```

Claude Code can review this script, suggest error handling, and extend it to post alerts to a Slack channel using a webhook instead of email.

## Interpreting Infracost Output

Infracost provides granular cost breakdowns that can overwhelm newcomers. Here is what the output typically shows:

The monthly cost represents the projected 30-day expense based on current resource configurations. This figure assumes continuous operation, so factor in development environments that run intermittently.

The cost breakdown by resource shows which components contribute most to your bill. In most architectures, compute instances and databases dominate the cost. Use this breakdown to identify optimization targets.

The difference view compares two states, useful for tracking cost changes between deployments. When combined with Claude's ability to explain differences conversationally, you gain immediate insight into what each code change costs.

The hourly vs monthly toggle matters for development environments. If you only run resources during business hours, multiply the hourly rate by your actual usage rather than accepting the monthly projection. For a resource running eight hours per weekday, the effective monthly cost is roughly 23% of the full-month figure.

## What Infracost Does Not Capture

Understanding Infracost's blind spots prevents nasty surprises on your cloud bill:

| Cost category | Captured by Infracost | Notes |
|---|---|---|
| Compute instance hours | Yes | Based on declared instance type |
| Storage (EBS, S3) | Yes | Based on declared size |
| Data transfer egress | Partial | Uses zero usage as default |
| API Gateway calls | Partial | Requires usage file |
| Lambda invocations | No | Usage-based, needs estimates |
| Support plan | No | Must add manually |
| Reserved instance discounts | No | Shows on-demand pricing |
| Spot instance pricing | No | On-demand only |

To account for usage-based costs, Infracost supports a usage file that lets you specify expected values:

```yaml
infracost-usage.yml
version: 0.1
resource_usage:
 aws_lambda_function.processor:
 monthly_requests: 10000000
 request_duration_ms: 250
 aws_s3_bucket.assets:
 storage_gb: 500
 monthly_get_requests: 1000000
 monthly_put_requests: 50000
```

Run the estimate with:

```bash
infracost breakdown --path ./terraform/ --usage-file infracost-usage.yml
```

Ask Claude Code to generate a usage file based on your application's traffic expectations. Describe your workload. "We expect 5 million API calls per month with an average payload of 2 KB". and Claude will produce realistic values for each usage-based resource in your Terraform configuration.

## Integrating Infracost into CI/CD

The most impactful place to surface cost data is in the pull request review, before any code merges. Infracost supports GitHub Actions, GitLab CI, and CircleCI natively.

## GitHub Actions Integration

Add this workflow file to your repository:

```yaml
name: Infracost

on:
 pull_request:

jobs:
 infracost:
 runs-on: ubuntu-latest
 permissions:
 contents: read
 pull-requests: write

 steps:
 - uses: actions/checkout@v4

 - name: Setup Infracost
 uses: infracost/actions/setup@v3
 with:
 api-key: ${{ secrets.INFRACOST_API_KEY }}

 - name: Checkout base branch
 uses: actions/checkout@v4
 with:
 ref: ${{ github.event.pull_request.base.ref }}
 path: base

 - name: Generate base cost estimate
 run: |
 infracost breakdown --path=base/terraform \
 --format=json \
 --out-file=/tmp/infracost-base.json

 - name: Generate PR cost estimate
 run: |
 infracost breakdown --path=terraform \
 --format=json \
 --out-file=/tmp/infracost-pr.json

 - name: Post cost diff as PR comment
 run: |
 infracost diff \
 --path=/tmp/infracost-pr.json \
 --compare-to=/tmp/infracost-base.json \
 --format=github-comment \
 --out-file=/tmp/comment.md

 gh pr comment ${{ github.event.pull_request.number }} \
 --body-file /tmp/comment.md
 env:
 GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

With this workflow, every pull request that touches Terraform receives an automatic comment showing exactly how much the proposed changes will add to or subtract from the monthly bill. Reviewers can make informed decisions without context-switching to a spreadsheet.

Claude Code can customize this workflow for your repository structure, add thresholds that require manager approval for changes above a dollar amount, and extend it to post summaries to a Slack channel alongside the PR link.

## Extending the Workflow

Beyond basic cost estimation, consider integrating this workflow with documentation skills. After finalizing your infrastructure, use the `pdf` skill to generate a cost report suitable for stakeholder review. Alternatively, employ the `frontend-design` skill if you need to create a visual dashboard of cost trends over time.

The `internal-comms` skill proves valuable when you need to communicate cost implications to your team. Claude can draft clear messages explaining why certain architectural choices were made based on budget constraints. A prompt like "Draft a Slack message explaining that we are switching from RDS Multi-AZ to a single availability zone for the staging environment to save $180 per month" produces a professional, non-technical explanation ready to send.

For teams managing multiple environments, Claude Code can aggregate cost estimates across all environments and generate a consolidated budget report. Ask: "Run Infracost on all directories under ./terraform/environments/ and summarize total monthly spend by environment in a table."

## Best Practices for Cost-Aware Development

Adopting Infracost early in your development cycle yields the greatest benefit. Waiting until after infrastructure is deployed limits your optimization options. Make cost estimation a standard part of your code review process.

Store Infracost output in version control to maintain a historical record of cost changes. This creates accountability and helps teams understand the cost impact of their architectural decisions over time. A simple approach is to commit `infracost-baseline.json` alongside your Terraform code and update it with each planned infrastructure change.

Tag your resources consistently so that cloud provider cost explorer tools can break down costs by team, project, and environment. Infracost respects these tags in its output and can filter estimates to show only resources with a specific tag value.

Set budget alerts in your cloud provider's billing console as a backstop. Even with Infracost in your CI pipeline, unexpected usage spikes from traffic surges or runaway background jobs will bypass static estimates. AWS Budgets, GCP Budget Alerts, and Azure Cost Alerts can all be configured through Terraform. ask Claude Code to add budget alert resources to your existing infrastructure modules.

Finally, remember that Infracost provides estimates, not guarantees. Actual costs vary based on usage patterns, reserved instance availability, and region-specific pricing. Use the tool as a directional guide rather than a precise predictor, and plan for a 10 to 20 percent variance in your budget projections to account for factors Infracost cannot anticipate.

---


**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).
---

<div class="mastery-cta">

Claude Code is expensive because it's reading your entire codebase every time. A CLAUDE.md tells it what matters upfront — architecture, conventions, boundaries. Less scanning. Fewer wrong turns. Lower bills.

I spend $200+/month on Claude subs. These configs are how I keep the output worth the cost.

**[Get the configs →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-perf&utm_campaign=claude-code-infracost-cost-estimation-guide)**

$99 once. Pays for itself in saved tokens within a week.

</div>

Related Reading

- [Claude Code Cost Per Project Estimation Calculator Guide](/claude-code-cost-per-project-estimation-calculator-guide/)
- [Claude API Cost Optimization Strategies for SaaS.](/claude-api-cost-optimization-strategies-for-saas-application/)
- [Claude Code Cost for Agencies and Consultancies: A.](/claude-code-cost-for-agencies-and-consultancies/)
- [Claude Cost Anomaly Detection Setup Guide](/claude-cost-anomaly-detection-setup-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

