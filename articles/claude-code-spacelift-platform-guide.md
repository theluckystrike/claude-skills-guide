---

layout: default
title: "Claude Code Spacelift Platform Guide"
description: "Learn how to integrate Claude Code with Spacelift for automated infrastructure management, policy enforcement, and intelligent deployment workflows."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-spacelift-platform-guide/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
geo_optimized: true
---

Infrastructure as Code (IaC) has evolved significantly, and combining Claude Code with Spacelift creates a powerful workflow for managing cloud resources intelligently. This guide shows developers how to use Claude Code's natural language capabilities with Spacelift's policy engine to build smarter, more compliant infrastructure automation.

## Understanding the Spacelift Integration

Spacelift is a sophisticated IaC management platform that brings policy-as-code, workflow automation, and collaborative infrastructure management to Terraform, Pulumi, and CloudFormation stacks. When you add Claude Code to this mix, you gain an intelligent partner that can interpret requirements, generate configuration, explain errors, and suggest optimizations.

The integration works through Spacelift's exposed APIs and webhook system. Claude Code can interact with these endpoints to:

- Create and update infrastructure stacks programmatically
- Review pull requests for infrastructure changes
- Enforce compliance policies before deployments
- Troubleshoot failed runs with contextual awareness
- Generate OPA Rego policies from plain-language compliance requirements

Where Spacelift provides the enforcement layer, Claude Code provides the intelligence layer, translating business requirements into infrastructure code, and infrastructure errors into actionable fixes.

## Setting Up the Connection

Before connecting Claude Code to Spacelift, ensure you have appropriate API credentials. Spacelift provides service accounts with scoped permissions for exactly this purpose.

```bash
Store your Spacelift API token securely
export SPACELIFT_API_TOKEN="spacelift_v1_..."
export SPACELIFT_ACCOUNT="your-account-id"
```

You'll want to create a dedicated service account in Spacelift with read-write access to the stacks you want Claude Code to manage. Avoid using admin credentials for daily operations, principle of least privilege applies here.

The Spacelift GraphQL API is the primary integration surface. You can verify connectivity with a basic query:

```bash
curl -X POST \
 -H "Authorization: Bearer $SPACELIFT_API_TOKEN" \
 -H "Content-Type: application/json" \
 -d '{"query": "{ viewer { id login } }"}' \
 "https://$SPACELIFT_ACCOUNT.app.spacelift.io/graphql"
```

Once connectivity is confirmed, Claude Code can use this API surface to query stack states, trigger runs, and retrieve run logs for analysis.

## Practical Examples

## Generating Infrastructure Configurations

Suppose you need to set up a new AWS ECS cluster with specific requirements. Instead of writing Terraform from scratch, describe your needs to Claude Code:

```
Create an ECS cluster on AWS with auto-scaling,
Fargate launch type, and CloudWatch logging enabled
```

Claude Code can generate the appropriate Terraform configuration:

```hcl
Generated ECS Cluster Configuration
module "ecs_cluster" {
 source = "terraform-aws-modules/ecs/aws"
 version = "~> 5.0"

 cluster_name = "production-cluster"

 cluster_configuration = {
 execute_command_configuration = {
 logging = "OVERRIDE"
 configuration = {
 cloud_watch_log_group_name = "/aws/ecs/${var.cluster_name}/execute-command"
 }
 }
 }

 fargate_capacity_providers = {
 default = {
 weight = 100
 }
 }

 autoscaling_capacity_providers = {
 FARGATE = {
 auto_scaling_group_arn = module.asg.autoscaling_group_arn
 managed_scaling = {
 maximum_scaling_step_size = 5
 minimum_scaling_step_size = 1
 status = "ENABLED"
 target_capacity = 70
 }
 }
 }
}
```

After generation, ask Claude Code to explain the configuration choices and flag anything that needs to be customized for your environment. This is more educational than copy-pasting from examples, because you end up understanding what you've deployed.

## Policy Review Workflows

Spacelift's policy engine uses Open Policy Agent (OPA) Rego language. Writing these policies can be challenging. Claude Code's understanding of Rego lets you generate policies from natural language compliance requirements rather than writing raw Rego from scratch.

For example, to enforce tagging requirements:

```rego
package spacelift

mandatory_tags := {"Environment", "Owner", "CostCenter", "Project"}

deny[msg] {
 input.change.kind == "terraform"
 some resource_type
 resources := input.change.resource_changes[resource_type]
 some resource
 resource := resources[_]
 missing_tags := mandatory_tags - keys(resource.change.after.tags)
 count(missing_tags) > 0
 msg := sprintf("Missing mandatory tags on %s: %v", [resource.address, missing_tags])
}

keys(s) := {k | s[k]}
```

You can prompt Claude Code to generate more complex policies as well. For instance, a policy that enforces region constraints:

```rego
package spacelift

allowed_regions := {"us-east-1", "us-west-2", "eu-west-1"}

deny[msg] {
 input.change.kind == "terraform"
 resource := input.change.resource_changes[_]
 region := resource.change.after.region
 not allowed_regions[region]
 msg := sprintf("Resource %s is targeting disallowed region: %s", [resource.address, region])
}
```

A useful workflow is to write your compliance requirement in plain English, paste it to Claude Code, and ask it to produce the Rego policy. Then ask Claude Code to write test cases for the policy using OPA's built-in testing framework, this catches edge cases before the policy reaches production.

## Troubleshooting Failed Deployments

When Spacelift runs fail, the error messages aren't always intuitive. Claude Code can analyze the run logs and suggest fixes:

```bash
Capture a failed Terraform plan output
terraform plan -out=tfplan 2>&1 | grep -A 20 "Error:"
```

Paste the error output to Claude Code with context about what you were trying to do. A prompt like this gets better results than just pasting the error:

```
This Terraform plan failed in our Spacelift stack for the payments service.
We were adding a new RDS instance. Here is the error output:

[paste error]

We're on AWS, us-east-1. The VPC was created last month and has two private subnets.
What's wrong and what's the fix?
```

Claude Code interprets these errors in context, considering your existing infrastructure, recent changes, and known constraints, to provide actionable solutions rather than generic error messages. Common Spacelift failure patterns it handles well include state lock conflicts, provider version mismatches, and IAM permission errors that produce misleading error text.

## Writing Spacelift Stack Configurations

Beyond Terraform, Claude Code can help write Spacelift's own configuration files. The `.spacelift/config.yml` file controls stack behavior:

```yaml
version: "1"

stacks:
 payments-service:
 terraform_version: "1.7.0"
 autodeploy: false
 before_init:
 - aws sts get-caller-identity
 environment:
 - name: TF_VAR_environment
 value: production
 - name: TF_VAR_region
 value: us-east-1
 policies:
 - mandatory-tagging
 - region-constraint
 - cost-center-required
```

Ask Claude Code to generate this configuration from a description of your stack's requirements, then refine it through dialogue to add the specific hooks and policies your organization requires.

## Advanced Workflow Patterns

## Automated Pull Request Reviews

Set up a workflow where Claude Code reviews every infrastructure change before it reaches Spacelift:

1. Configure Spacelift to trigger preview runs on pull request events
2. Export the plan output to a location Claude Code can access (an S3 bucket or a CI artifact)
3. Have Claude Code analyze the proposed changes for security issues, cost implications, and policy compliance
4. Post the analysis as a pull request comment using the GitHub or GitLab API

This creates an intelligent gate that catches configuration issues before they reach production. The review Claude Code produces is more useful than raw `terraform plan` output because it explains the *impact* of changes in plain language, "this change adds a public-facing security group rule allowing all inbound traffic on port 22" is more actionable than the raw plan diff.

## Drift Detection and Remediation

Spacelift can detect configuration drift, when live infrastructure diverges from the Terraform state. Claude Code adds intelligence to this process:

```bash
Retrieve drift detection results from Spacelift API
curl -X POST \
 -H "Authorization: Bearer $SPACELIFT_API_TOKEN" \
 -H "Content-Type: application/json" \
 -d '{"query": "{ stack(id: \"payments-service\") { driftDetection { state } } }"}' \
 "https://$SPACELIFT_ACCOUNT.app.spacelift.io/graphql"
```

When drift is detected, paste the results to Claude Code and ask it to analyze whether the drift is expected (a manual hotfix that needs to be codified) or unexpected (a change that needs to be reverted). This distinction matters enormously, blindly running `terraform apply` to remediate drift can overwrite legitimate emergency changes.

## Multi-Cloud Orchestration

For organizations using multiple cloud providers, Claude Code can manage complex dependencies across AWS, GCP, and Azure. When resources in one cloud depend on resources in another, the dependency graph becomes difficult to reason about manually.

Claude Code helps by maintaining context across these orchestration sessions. You can describe a multi-cloud architecture in plain language and ask Claude Code to generate the Terraform configurations for each provider, along with the remote state data sources that connect them:

```hcl
AWS side: share VPC CIDR via remote state
output "vpc_cidr" {
 value = aws_vpc.main.cidr_block
}

GCP side: consume AWS remote state
data "terraform_remote_state" "aws" {
 backend = "s3"
 config = {
 bucket = "my-terraform-state"
 key = "aws/networking/terraform.tfstate"
 region = "us-east-1"
 }
}

resource "google_compute_firewall" "allow_aws" {
 name = "allow-aws-vpc"
 network = google_compute_network.main.name

 allow {
 protocol = "tcp"
 ports = ["443", "8080"]
 }

 source_ranges = [data.terraform_remote_state.aws.outputs.vpc_cidr]
}
```

## Security Considerations

When integrating Claude Code with Spacelift, follow these security practices:

- Credential Rotation: Regularly rotate API tokens, and use short-lived tokens where Spacelift's OIDC integration supports it
- Audit Logging: Enable detailed logging for all Claude Code actions that trigger Spacelift runs
- Policy Boundaries: Define clear OPA policies that enforce what Claude Code can and cannot change, treat AI-generated infrastructure with the same skepticism you'd apply to any external contribution
- Approval Gates: Require human approval for production changes; use Spacelift's approval policies to enforce this even when changes originate from automated workflows
- Scope Limitation: Create separate service accounts for different stack groups; Claude Code managing the staging environment should not have credentials that reach production

A useful pattern is to have Claude Code generate the change, have Spacelift run a plan, and require a human to approve before apply. The AI accelerates the generation and analysis steps; the human remains responsible for final authorization.

## Spacelift Feature Support Comparison

| Feature | Manual Workflow | With Claude Code |
|---------|----------------|-----------------|
| Config generation | Write from scratch | Generate from requirements |
| OPA policy authoring | Learn Rego manually | Natural language to Rego |
| Error diagnosis | Read docs, search Stack Overflow | Contextual analysis |
| Drift remediation | Manual judgment call | Analyzed recommendation |
| PR review | Read raw plan diff | Plain-language impact summary |
| Multi-cloud deps | Manual dependency mapping | Generated with explanations |

## Best Practices

Start small with non-critical stacks to build confidence in the workflow. Document your infrastructure patterns so Claude Code can generate consistent configurations, a short description of your naming conventions, tagging standards, and module preferences gives Claude Code the context to produce configurations that fit your codebase rather than generic examples.

Write tests alongside your infrastructure code. Terraform's `terratest` framework and OPA's built-in test runner both work well here. Ask Claude Code to generate test cases after generating configurations, this catches issues early and gives Claude Code better context when generating future changes.

The combination of Claude Code's contextual understanding and Spacelift's policy enforcement creates infrastructure automation that's both intelligent and compliant. As your infrastructure grows, this integration scales to manage hundreds of stacks while maintaining consistent governance.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-spacelift-platform-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Dart Flutter Cross Platform Development Guide](/claude-code-dart-flutter-cross-platform-development-guide/)
- [Claude Code for Multi-Platform Release Workflow Guide](/claude-code-for-multi-platform-release-workflow-guide/)
- [Claude Code for Platform Engineer: Infrastructure.](/claude-code-for-platform-engineer-infrastructure-automation-/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


