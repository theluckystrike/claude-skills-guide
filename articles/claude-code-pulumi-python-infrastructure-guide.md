---

layout: default
title: "Claude Code with Pulumi Python for IaC (2026)"
description: "Provision cloud infrastructure with Pulumi and Python using Claude Code. Covers AWS, GCP, and Azure resource definitions with type-safe automation."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-pulumi-python-infrastructure-guide/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
render_with_liquid: false
geo_optimized: true
last_tested: "2026-04-21"
---

{% raw %}
Claude Code Pulumi Python Infrastructure Guide

Infrastructure as Code has become essential for modern cloud deployments, and combining Claude Code with Pulumi Python creates a powerful automation workflow. This guide shows developers and power users how to use Claude Code's capabilities alongside Pulumi's infrastructure management to build, test, and deploy cloud resources efficiently. Whether you're provisioning a single S3 bucket or orchestrating dozens of interdependent services across multiple AWS accounts, the Claude Code and Pulumi combination accelerates every stage of the development cycle.

## Why Pulumi Python Over Other IaC Tools

Before diving into Claude Code integration, it helps to understand why Pulumi Python stands out among infrastructure-as-code options.

| Tool | Language | State Management | Testing Support | IDE Support |
|------|----------|-----------------|-----------------|-------------|
| Pulumi | Python, Go, TS, etc. | Managed or self-hosted | Native unit tests | Full (LSP, autocomplete) |
| Terraform | HCL | Managed or self-hosted | Limited (terratest) | Moderate |
| CDK | TypeScript, Python | CloudFormation | Jest/pytest | Full |
| CloudFormation | YAML/JSON | AWS-managed | Limited | Minimal |

Pulumi's key advantage is using real programming languages. This means you get loops, conditionals, classes, imports, and proper unit testing. all things that HCL and YAML cannot offer. When Claude Code assists with your infrastructure, it works in the same Python context it already understands deeply, producing more accurate and idiomatic code.

## Setting Up Your Pulumi Python Project

Before integrating Claude Code, initialize a Pulumi Python project:

```bash
mkdir my-infra && cd my-infra
pulumi new python --name my-stack
```

Install your cloud provider packages. For AWS, add `pulumi-aws`:

```bash
pip install pulumi-aws
```

For multi-cloud projects, you can add multiple providers in one step:

```bash
pip install pulumi-aws pulumi-gcp pulumi-azure-native
```

Configure your cloud credentials using environment variables or the Pulumi CLI. Claude Code can handle the setup using its Bash tool to run commands and read configuration files.

A well-structured Pulumi Python project looks like this:

```
my-infra/
 __main__.py # Entry point, resource definitions
 components/
 __init__.py
 networking.py # VPC, subnets, routing
 compute.py # EC2, ECS, Lambda
 storage.py # S3, RDS, DynamoDB
 Pulumi.yaml # Project config
 Pulumi.dev.yaml # Dev stack config
 Pulumi.prod.yaml # Prod stack config
 requirements.txt
```

Splitting resources into component modules keeps your `__main__.py` clean and makes it easier for Claude Code to work on individual sections without context overflow.

## How Claude Code Enhances Pulumi Workflows

Claude Code brings intelligent assistance to infrastructure projects through natural language interaction. When working with Pulumi Python, you can use several capabilities that accelerate development.

Code Generation: Describe the infrastructure you need, and Claude Code helps generate the Python code. For example, "Create an S3 bucket with versioning enabled" produces the appropriate Pulumi code:

```python
import pulumi
import pulumi_aws as aws

Create an S3 bucket with versioning enabled
bucket = aws.s3.BucketV2(
 "my-bucket",
 bucket="my-unique-bucket-name",
)

bucket_versioning = aws.s3.BucketVersioningV1(
 "my-bucket-versioning",
 bucket=bucket.id,
 versioning_configuration=aws.s3.BucketVersioningV1VersioningConfigurationArgs(
 status="Enabled",
 ),
)
```

Error Resolution: When Pulumi stacks fail during preview or update, Claude Code can analyze error messages and suggest fixes. This is particularly useful for permission errors, missing dependencies, or incorrect resource configurations. Paste the full error output into Claude Code, and it identifies whether the issue is an IAM policy gap, a missing provider version, or a circular dependency in your resource graph.

Documentation Generation: Use the doc skill to automatically generate documentation for your infrastructure code. This helps teams understand the purpose and configuration of each resource, and makes onboarding new engineers significantly faster.

Refactoring Legacy Stacks: If you have an existing Pulumi project that grew organically, Claude Code can help you refactor it into proper component resources without changing the underlying infrastructure. Describe what you want the final structure to look like, and Claude Code produces the refactored code while preserving resource logical names to avoid accidental replacements.

## Creating Reusable Infrastructure Components

One of Pulumi's strengths is creating reusable components. Claude Code can help you design and implement component resources that encapsulate common infrastructure patterns.

## Web Server Component

Here's a reusable component that provisions a web server with security groups:

```python
import pulumi
import pulumi_aws as aws
from pulumi import ComponentResource, ComponentResourceOptions

class WebServerArgs:
 def __init__(
 self,
 vpc_id: str,
 instance_type: str = "t3.micro",
 ami_id: str = "ami-0c55b159cbfafe1f0",
 ):
 self.vpc_id = vpc_id
 self.instance_type = instance_type
 self.ami_id = ami_id

class WebServer(ComponentResource):
 def __init__(self, name: str, args: WebServerArgs, opts: ComponentResourceOptions = None):
 super().__init__("custom:WebServer", name, {}, opts)

 # Security group for the web server
 self.security_group = aws.ec2.SecurityGroup(
 f"{name}-sg",
 vpc_id=args.vpc_id,
 description="Security group for web server",
 ingress=[
 {"protocol": "tcp", "from_port": 80, "to_port": 80, "cidr_blocks": ["0.0.0.0/0"]},
 {"protocol": "tcp", "from_port": 443, "to_port": 443, "cidr_blocks": ["0.0.0.0/0"]},
 {"protocol": "tcp", "from_port": 22, "to_port": 22, "cidr_blocks": ["0.0.0.0/0"]},
 ],
 opts=opts,
 )

 # EC2 instance
 self.instance = aws.ec2.Instance(
 f"{name}-instance",
 instance_type=args.instance_type,
 ami=args.ami_id,
 vpc_security_group_ids=[self.security_group.id],
 opts=opts,
 )

 self.register_outputs({"public_ip": self.instance.public_ip})
```

This component can then be instantiated multiple times across your infrastructure:

```python
web_server = WebServer(
 "production-web",
 WebServerArgs(
 vpc_id=vpc.id,
 instance_type="t3.medium",
 ),
)
```

## Extending Components with Outputs

A common pattern is exposing resource outputs so other stacks or resources can depend on them:

```python
Export from the component's stack
pulumi.export("web_server_ip", web_server.instance.public_ip)
pulumi.export("security_group_id", web_server.security_group.id)
```

Claude Code is particularly helpful here because it understands Pulumi's `Output[T]` type system and correctly applies `.apply()` when you need to transform values before passing them to other resources.

## Testing Infrastructure with the TDD Skill

The tdd skill works well with infrastructure code to implement test-driven development patterns. Before deploying resources, write tests that verify expected behavior:

```python
import pytest
from pulumi import Output
from pulumi.testing import Mocks

class MockPulumi(Mocks):
 def call(self, args):
 return {}

 def new_resource(self, args):
 return [args.id + "-mocked", {}]

Use with pytest
def test_web_server_creates_security_group():
 # Test that security group is created with correct rules
 pass
```

Beyond the basic mock setup, meaningful infrastructure tests verify resource properties. Here is a fuller example that checks your S3 bucket has server-side encryption enabled:

```python
import pulumi
import pulumi_aws as aws
from unittest.mock import MagicMock

@pulumi.runtime.test
def test_bucket_has_encryption():
 def check_encryption(args):
 sse_config = args[0]
 assert sse_config is not None, "Bucket must have SSE configuration"
 rules = sse_config.get("rules", [])
 assert len(rules) > 0, "At least one SSE rule required"

 bucket = aws.s3.BucketV2("test-bucket")
 return pulumi.Output.all(bucket.server_side_encryption_configuration).apply(check_encryption)
```

This approach catches configuration errors before they reach production. When you ask Claude Code to add a new resource to your stack, ask it to write the test first. this surfaces edge cases in the resource configuration before any real infrastructure changes occur.

## Managing Multi-Environment Deployments

For teams managing multiple environments, Claude Code helps create consistent deployment patterns across staging, production, and development environments.

Create a stack configuration that uses Pulumi's stack references:

```python
import pulumi

Reference shared infrastructure from another stack
shared_stack = pulumi.StackReference("organization/shared-infra/prod")
vpc_id = shared_stack.require_output("vpc_id")

Use the referenced VPC
web_server = WebServer(
 "prod-web",
 WebServerArgs(vpc_id=vpc_id),
)
```

## Environment-Specific Configuration

Pulumi stack config files let you vary resource sizes and settings per environment without changing code:

```yaml
Pulumi.prod.yaml
config:
 my-infra:instance_type: t3.xlarge
 my-infra:min_capacity: 3
 my-infra:max_capacity: 20
 my-infra:enable_deletion_protection: true
```

```yaml
Pulumi.dev.yaml
config:
 my-infra:instance_type: t3.micro
 my-infra:min_capacity: 1
 my-infra:max_capacity: 3
 my-infra:enable_deletion_protection: false
```

In your Python code, access these values with proper defaults:

```python
config = pulumi.Config()
instance_type = config.get("instance_type") or "t3.micro"
enable_deletion_protection = config.get_bool("enable_deletion_protection") or False
```

Claude Code can help you audit your stacks to ensure production-only guard rails (deletion protection, backup retention, encryption) are enforced through config rather than hardcoded. The supermemory skill can help track environment-specific configurations and maintain context across deployments.

## CI/CD Integration Patterns

Integrating Pulumi Python with CI/CD pipelines requires careful handling of secrets and state. Claude Code can assist with setting up GitHub Actions workflows:

```yaml
name: Infrastructure Update
on:
 push:
 paths:
 - 'infra/'
jobs:
 update:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4
 - uses: actions/setup-python@v4
 with:
 python-version: '3.11'
 - run: pip install pulumi
 - run: pulumi login
 - run: pulumi preview
 env:
 PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
```

For production deployments, add a manual approval gate between preview and apply:

```yaml
 apply:
 needs: preview
 runs-on: ubuntu-latest
 environment: production # requires manual approval in GitHub settings
 steps:
 - uses: actions/checkout@v4
 - run: pulumi up --yes
 env:
 PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
 AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
 AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

When the preview output shows unexpected resource replacements, Claude Code can analyze the diff and explain why. often it is a change to a resource property that forces replacement (like an RDS `identifier`) versus an in-place update, and Claude Code will suggest alternatives that avoid downtime.

## Best Practices for Claude Code + Pulumi

Follow these practices for effective infrastructure development:

Use descriptive resource names: Name resources clearly so their purpose is obvious in the Pulumi console and cloud provider interfaces. Avoid generic names like `bucket1`. prefer `user-uploads-prod-us-east-1`.

Implement proper tagging: Add tags to all resources for cost tracking and organization:

```python
tags = {
 "Environment": pulumi.get_stack(),
 "ManagedBy": "Pulumi",
 "Project": "my-infrastructure",
}

bucket = aws.s3.BucketV2(
 "my-bucket",
 tags=tags,
)
```

Store state securely: Use Pulumi's managed service or set up a backend with proper encryption. Never commit state files to version control.

Review previews carefully: Always run `pulumi preview` before `pulumi up` to catch unintended changes. Look especially for any `replace` operations that could cause downtime. these appear as a minus-then-plus pair in the diff output.

Pin provider versions: Lock your provider versions in `requirements.txt` to avoid surprise breakage when upstream providers release breaking changes:

```
pulumi>=3.0.0,<4.0.0
pulumi-aws>=6.0.0,<7.0.0
```

Separate concerns by component: Keep networking, compute, and data resources in separate component files. This makes it easier to ask Claude Code to work on one layer at a time without accidentally introducing cross-cutting changes.

## Conclusion

Combining Claude Code with Pulumi Python creates a powerful workflow for infrastructure automation. Claude Code handles code generation, error resolution, and documentation while Pulumi manages the actual resource provisioning. This combination reduces manual work and helps teams maintain consistent, testable infrastructure code.

The real productivity gains come from Claude Code's ability to hold complex infrastructure context. resource dependencies, output types, provider quirks. and translate natural language requirements into correct Pulumi Python. Instead of hunting through provider documentation for the exact argument shape, you describe what you want and iterate on the generated code.

For teams working with complex deployments, integrate the tdd skill for testing infrastructure before it reaches production, and use supermemory for maintaining deployment context across sessions. As your Pulumi codebase grows, Claude Code's ability to analyze and refactor existing stacks becomes increasingly valuable, keeping your infrastructure code clean and maintainable.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-pulumi-python-infrastructure-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Building Apps with Claude API: Anthropic SDK Python Guide](/building-apps-with-claude-api-anthropic-sdk-python-guide/)
- [Claude Code FastAPI Async Python Guide](/claude-code-fastapi-async-python-guide/)
- [Claude Code for Brownie Python Workflow Guide](/claude-code-for-brownie-python-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


