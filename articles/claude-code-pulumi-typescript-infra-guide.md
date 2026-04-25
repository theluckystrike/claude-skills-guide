---

layout: default
title: "Claude Code Pulumi TypeScript Infra"
description: "Use Claude Code with Pulumi and TypeScript to automate infrastructure provisioning. Practical patterns for building, testing, and managing cloud."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-pulumi-typescript-infra-guide/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Claude Code Pulumi TypeScript Infra Guide

Infrastructure as Code has evolved significantly, and combining Claude Code with Pulumi TypeScript projects creates a powerful workflow for managing cloud resources. This guide shows you practical patterns for using Claude Code to accelerate your Pulumi infrastructure development. from initial project setup through production deployments and ongoing maintenance.

## Setting Up Your Pulumi TypeScript Project

Before integrating Claude Code, ensure your Pulumi project is properly configured. Initialize a new TypeScript project if you haven't already:

```bash
mkdir my-infra && cd my-infra
pulumi new typescript --name my-stack
```

Install the required dependencies and configure your cloud provider. For AWS, you'll need the `@pulumi/aws` package. Claude Code can assist with package installation and initial project structure using the Bash tool.

```bash
npm install @pulumi/aws @pulumi/awsx
```

Once installed, open Claude Code in your project directory and ask it to scaffold the initial structure. A prompt like "Set up a Pulumi TypeScript project targeting AWS with separate modules for networking, compute, and storage" gives Claude Code the context it needs to generate a clean directory layout with typed exports.

A well-organized project from the start prevents structural debt later. Claude Code can suggest a layout like this:

```
my-infra/
 index.ts # Stack entry point
 networking.ts # VPC, subnets, route tables
 compute.ts # EC2, ECS, Lambda
 storage.ts # S3, RDS, ElastiCache
 security.ts # IAM, security groups, KMS
 Pulumi.yaml # Project metadata
```

## How Claude Code Enhances Pulumi Workflows

Claude Code brings intelligent assistance to your infrastructure projects through natural language interaction. When working with Pulumi TypeScript, you can use several capabilities:

Code Generation: Describe the infrastructure you need, and Claude Code helps generate the TypeScript code. For example, "Create an S3 bucket with versioning enabled and a lifecycle rule that transitions objects to Glacier after 90 days" produces accurate Pulumi code rather than a rough skeleton you have to fill in yourself.

Debugging Support: When your stack fails to deploy, paste the error message and Claude Code analyzes the issue, suggests fixes, and explains what went wrong. This is particularly useful for AWS IAM policy errors, which tend to produce cryptic messages. Claude can translate "AccessDenied for sts:AssumeRole" into a clear explanation of which trust policy is missing and how to add it.

Documentation Reading: Use Claude Code's web-fetching capabilities to pull Pulumi documentation, AWS provider references, or community examples directly into your workspace. Instead of switching to a browser and searching, you can ask Claude to fetch the Pulumi AWS RDS docs and summarize the required arguments.

Drift Detection Assistance: After running `pulumi refresh`, Claude Code can help you interpret the diff output and decide which changes are intentional versus unexpected drift that needs investigation.

## Writing Your First Pulumi Resource

Here's a practical example of defining infrastructure with Pulumi TypeScript that Claude Code can help you build:

```typescript
import * as aws from "@pulumi/aws";
import * as pulumi from "@pulumi/pulumi";

// Create an S3 bucket with encryption and versioning
const bucket = new aws.s3.Bucket("app-bucket", {
 versioning: {
 enabled: true,
 },
 serverSideEncryptionConfiguration: {
 rule: {
 applyServerSideEncryptionByDefault: {
 sseAlgorithm: "AES256",
 },
 },
 },
 lifecycleRules: [{
 enabled: true,
 transitions: [{
 days: 90,
 storageClass: "GLACIER",
 }],
 expiration: {
 days: 365,
 },
 }],
 tags: {
 Environment: pulumi.getStack(),
 ManagedBy: "pulumi",
 Project: pulumi.getProject(),
 },
});

// Block all public access
const bucketPublicAccessBlock = new aws.s3.BucketPublicAccessBlock("app-bucket-public-access", {
 bucket: bucket.id,
 blockPublicAcls: true,
 blockPublicPolicy: true,
 ignorePublicAcls: true,
 restrictPublicBuckets: true,
});

// Export the bucket name and ARN
export const bucketName = bucket.id;
export const bucketArn = bucket.arn;
```

Claude Code can generate variations of this code, add tags, modify the encryption settings, or extend it with additional resources like CloudFront distributions or IAM policies. When you say "add a CloudFront distribution in front of this bucket with HTTPS-only access," Claude generates the full `aws.cloudfront.Distribution` resource with the correct origin access identity configuration rather than a partial snippet.

## Managing Multi-Environment Deployments

Production infrastructure typically requires multiple environments. Use Pulumi stacks to manage dev, staging, and production:

```bash
pulumi stack init dev
pulumi stack init staging
pulumi stack init prod
```

Configure stack-specific configuration values for each environment:

```bash
pulumi config set environment dev --stack dev
pulumi config set environment staging --stack staging
pulumi config set environment prod --stack prod
```

Then read these values in your TypeScript code to control resource sizing and protection:

```typescript
const config = new pulumi.Config();
const environment = config.require("environment");

const dbInstance = new aws.rds.Instance("app-db", {
 instanceClass: environment === "prod" ? "db.t3.medium" : "db.t3.small",
 allocatedStorage: environment === "prod" ? 100 : 20,
 engine: "postgres",
 engineVersion: "14.7",
 skipFinalSnapshot: environment !== "prod",
 backupRetentionPeriod: environment === "prod" ? 7 : 1,
 multiAz: environment === "prod",
 deletionProtection: environment === "prod",
}, { protect: environment === "prod" });
```

This pattern ensures your production database receives protection against accidental deletion while development environments remain easily disposable. Claude Code can help you extend this pattern across all resource types consistently. ask it to "audit all resources in this file and apply environment-based protection to anything stateful" and it will scan through, identify RDS instances, ElastiCache clusters, and S3 buckets, then add `protect: environment === "prod"` where appropriate.

## Comparison: Pulumi TypeScript vs Other IaC Tools

Understanding where Pulumi fits helps you make better decisions about when to lean on Claude Code for generation versus configuration.

| Feature | Pulumi TypeScript | Terraform HCL | AWS CDK |
|---|---|---|---|
| Language | TypeScript/JS | Domain-specific HCL | TypeScript/Python/Java |
| Type safety | Full TypeScript types | Limited | Full types |
| Testing | Standard TS test frameworks | Terratest (Go) | Jest/pytest |
| State management | Pulumi Cloud or self-hosted | Terraform Cloud or S3 | CloudFormation (AWS only) |
| Multi-cloud | Yes | Yes | AWS only |
| Loops and conditionals | Native TypeScript | Limited HCL syntax | Native language |
| Claude Code integration | Natural, full IDE support | Works, less type inference | Natural, full IDE support |

The TypeScript type system is a major advantage when using Claude Code. Claude can use the type definitions to generate correct code without guessing at argument names or optional fields.

## Testing Infrastructure Code

Integrate testing into your Pulumi workflows using the testing skill. Pulumi has built-in mocking utilities that let you test infrastructure logic without actually provisioning resources:

```typescript
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

// Set up Pulumi mocks for unit testing
pulumi.runtime.setMocks({
 newResource: (args: pulumi.runtime.MockResourceArgs): { id: string; state: any } => {
 return {
 id: `${args.name}-id`,
 state: args.inputs,
 };
 },
 call: (args: pulumi.runtime.MockCallArgs) => {
 return args.inputs;
 },
});

// Import and test the module after mocks are configured
let infra: typeof import("./storage");
beforeAll(async () => {
 infra = await import("./storage");
});

describe("S3 bucket configuration", () => {
 it("has versioning enabled", async () => {
 const bucket = infra.appBucket;
 const versioningEnabled = await new Promise<boolean>((resolve) => {
 bucket.versioning.apply(v => resolve(v.enabled === true));
 });
 expect(versioningEnabled).toBe(true);
 });

 it("blocks public access", async () => {
 const pab = infra.bucketPublicAccessBlock;
 const blocked = await new Promise<boolean>((resolve) => {
 pab.blockPublicAcls.apply(b => resolve(b === true));
 });
 expect(blocked).toBe(true);
 });
});
```

Run tests with `npx jest` before running `pulumi preview`. Claude Code can generate test cases for every resource in a module. ask "write unit tests for all resources in storage.ts covering encryption, access controls, and tagging" and it produces a full test suite.

Policy-as-code testing is another area where Claude helps. Using `@pulumi/policy`, you can write rules that run during preview:

```typescript
import { PolicyPack, validateResourceOfType } from "@pulumi/policy";
import * as aws from "@pulumi/aws";

new PolicyPack("security-baseline", {
 policies: [{
 name: "s3-no-public-read",
 description: "S3 buckets must not allow public read access.",
 enforcementLevel: "mandatory",
 validateResource: validateResourceOfType(aws.s3.Bucket, (bucket, args, reportViolation) => {
 if (bucket.acl === "public-read" || bucket.acl === "public-read-write") {
 reportViolation("S3 bucket must not have a public ACL.");
 }
 }),
 }],
});
```

## Integrating with CI/CD Pipelines

Automate your infrastructure deployments using GitHub Actions or similar CI systems. Here's a practical workflow configuration:

```yaml
name: Infrastructure Deployment
on:
 push:
 paths:
 - 'infra/'
 branches:
 - main
 pull_request:
 paths:
 - 'infra/'

jobs:
 preview:
 runs-on: ubuntu-latest
 if: github.event_name == 'pull_request'
 steps:
 - uses: actions/checkout@v3
 - uses: actions/setup-node@v3
 with:
 node-version: '20'
 - run: npm ci
 working-directory: infra
 - uses: pulumi/actions@v4
 with:
 command: preview
 stack-name: staging
 work-dir: infra
 comment-on-pr: true
 env:
 PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
 AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
 AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

 deploy:
 runs-on: ubuntu-latest
 if: github.event_name == 'push' && github.ref == 'refs/heads/main'
 steps:
 - uses: actions/checkout@v3
 - uses: actions/setup-node@v3
 with:
 node-version: '20'
 - run: npm ci
 working-directory: infra
 - uses: pulumi/actions@v4
 with:
 command: up
 stack-name: production
 work-dir: infra
 env:
 PULUMI_ACCESS_TOKEN: ${{ secrets.PULUMI_ACCESS_TOKEN }}
 AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
 AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

Claude Code helps you craft these pipeline configurations, explains the security implications of different approaches, and suggests optimizations for faster deployments. For example, it can add a matrix strategy to preview multiple stacks simultaneously, or add a manual approval gate before production deploys using GitHub Environments.

## Organizing Large-Scale Infrastructure

As your infrastructure grows, organize code into modules with clean interfaces:

```typescript
// networking.ts - Network module
export interface NetworkOutputs {
 vpcId: pulumi.Output<string>;
 publicSubnetIds: pulumi.Output<string>[];
 privateSubnetIds: pulumi.Output<string>[];
}

export function createNetwork(vpcCidr: string, azs: string[]): NetworkOutputs {
 const vpc = new aws.ec2.Vpc("main", {
 cidrBlock: vpcCidr,
 enableDnsHostnames: true,
 enableDnsSupport: true,
 tags: { Name: `${pulumi.getStack()}-vpc` },
 });

 const publicSubnets = azs.map((az, index) =>
 new aws.ec2.Subnet(`public-subnet-${index}`, {
 vpcId: vpc.id,
 cidrBlock: `10.0.${index}.0/24`,
 availabilityZone: az,
 mapPublicIpOnLaunch: true,
 tags: { Name: `${pulumi.getStack()}-public-${az}`, Tier: "public" },
 })
 );

 const privateSubnets = azs.map((az, index) =>
 new aws.ec2.Subnet(`private-subnet-${index}`, {
 vpcId: vpc.id,
 cidrBlock: `10.0.${index + 10}.0/24`,
 availabilityZone: az,
 tags: { Name: `${pulumi.getStack()}-private-${az}`, Tier: "private" },
 })
 );

 return {
 vpcId: vpc.id,
 publicSubnetIds: publicSubnets.map(s => s.id),
 privateSubnetIds: privateSubnets.map(s => s.id),
 };
}
```

Import and compose modules in your main stack:

```typescript
import { createNetwork } from "./networking";
import { createSecurityGroups } from "./security";
import { createDatabase } from "./storage";

const network = createNetwork("10.0.0.0/16", ["us-east-1a", "us-east-1b"]);
const security = createSecurityGroups(network.vpcId);
const database = createDatabase(network.privateSubnetIds, security.dbSecurityGroupId);
```

This modular approach makes your infrastructure code maintainable and reusable across projects. Claude Code can help you refactor an existing monolithic `index.ts` into this structure. paste the file and ask "extract networking, compute, and storage into separate modules with TypeScript interfaces for their outputs."

## Handling Secrets and Sensitive Configuration

Never store secrets in plaintext. Pulumi's secret system encrypts sensitive values at rest:

```typescript
// Set a secret during stack configuration
// $ pulumi config set --secret dbPassword "my-secure-password"

const config = new pulumi.Config();
const dbPassword = config.requireSecret("dbPassword");

const db = new aws.rds.Instance("app-db", {
 password: dbPassword, // Pulumi tracks this as a secret output
 // ...other config
});

// Export without exposing the value
export const dbEndpoint = db.endpoint; // Safe to export
// Do NOT export dbPassword. it would appear in stack outputs
```

Claude Code understands this pattern and will automatically use `config.requireSecret()` instead of `config.require()` when you describe sensitive values. It can also audit your codebase to flag any places where secrets is accidentally exported or logged.

## Leveraging Claude Skills for Infrastructure

Several Claude skills enhance your infrastructure development workflow:

- pdf: Generate infrastructure documentation as PDF reports for stakeholders. architecture diagrams, resource inventories, cost estimates
- tdd: Apply test-driven development patterns to your infrastructure code, writing policy-as-code tests before implementing resources
- supermemory: Track infrastructure decisions, architecture choices, and deployment history so you can explain the reasoning behind past decisions
- frontend-design: When building internal tooling dashboards for infrastructure monitoring and deployment status
- webapp-testing: Validate infrastructure outputs through automated testing of deployed services, confirming endpoints respond correctly after deploys

Each skill complements your Pulumi workflow differently. The supermemory skill proves particularly valuable for maintaining institutional knowledge about your infrastructure architecture. recording why you chose a particular instance type or why a security group rule exists prevents future engineers from "fixing" intentional constraints.

## Best Practices Summary

1. Use descriptive resource names: `webServerSecurityGroup` instead of `sg1`. Pulumi uses these names to generate physical resource names
2. Enable stack protection: Protect production resources from accidental deletion with the `protect` resource option
3. Tag everything: Apply consistent tags for cost allocation, governance, and operational tooling. use a shared `tags` object and spread it across all resources
4. Version control your state: Use Pulumi Cloud or self-hosted backends like S3 with DynamoDB locking. never use local state for team projects
5. Test before applying: Always run `pulumi preview` before `pulumi up`, and integrate preview into pull request reviews
6. Use TypeScript strict mode: Enable `strict: true` in `tsconfig.json` to catch type errors that would otherwise surface as runtime failures during deployment
7. Pin provider versions: Lock your `@pulumi/aws` version in `package.json` to prevent surprise breaking changes from provider updates

Claude Code accelerates each of these practices through code generation, error analysis, and documentation assistance. The combination of intelligent AI assistance with Pulumi's infrastructure as code platform creates a productive workflow for teams managing cloud resources at any scale.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-pulumi-typescript-infra-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Best Way to Use Claude Code with TypeScript Projects](/best-way-to-use-claude-code-with-typescript-projects/)
- [Chrome Extension TypeScript Playground: A Developer Guide](/chrome-extension-typescript-playground/)
- [Claude Code API Client TypeScript Guide](/claude-code-api-client-typescript-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


