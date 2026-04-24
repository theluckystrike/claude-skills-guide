---
title: "Claude Code for Pulumi Infrastructure"
permalink: /claude-code-pulumi-infrastructure-as-code-2026/
description: "Build cloud infrastructure with Pulumi and Claude Code. Write type-safe IaC in TypeScript/Python, implement policy-as-code, and manage stack references."
last_tested: "2026-04-22"
domain: "infrastructure"
render_with_liquid: false
---

## Why Claude Code for Pulumi

Pulumi lets you define cloud infrastructure using general-purpose programming languages instead of HCL or YAML. This means you get type checking, IDE autocomplete, testing, and abstractions that Terraform cannot provide. But the flexibility creates its own challenges: structuring Pulumi projects for multi-environment deployments, implementing CrossGuard policy-as-code, managing stack references between dependent infrastructure, and writing unit tests for infrastructure code. Most teams write Pulumi like scripting when they should write it like production application code.

Claude Code generates well-structured Pulumi programs with proper component resources, stack references, policy packs, and unit tests that treat infrastructure code with the same rigor as application code.

## The Workflow

### Step 1: Initialize a Pulumi Project

```bash
# Install Pulumi
brew install pulumi  # macOS
# or: curl -fsSL https://get.pulumi.com | sh

# Create new project with TypeScript
mkdir infra && cd infra
pulumi new aws-typescript --name my-platform --yes

# Or Python
pulumi new aws-python --name my-platform --yes

# Set up multiple stacks
pulumi stack init dev
pulumi stack init staging
pulumi stack init prod
```

### Step 2: Build Component Resources with Type Safety

```typescript
// infra/components/vpc.ts
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

export interface VpcArgs {
    cidrBlock: string;
    availabilityZones: string[];
    enableNatGateway: boolean;
    tags?: Record<string, string>;
}

export class Vpc extends pulumi.ComponentResource {
    public readonly vpcId: pulumi.Output<string>;
    public readonly publicSubnetIds: pulumi.Output<string>[];
    public readonly privateSubnetIds: pulumi.Output<string>[];

    constructor(name: string, args: VpcArgs, opts?: pulumi.ComponentResourceOptions) {
        super("custom:network:Vpc", name, {}, opts);

        const vpc = new aws.ec2.Vpc(`${name}-vpc`, {
            cidrBlock: args.cidrBlock,
            enableDnsHostnames: true,
            enableDnsSupport: true,
            tags: { ...args.tags, Name: `${name}-vpc` },
        }, { parent: this });

        this.vpcId = vpc.id;

        const igw = new aws.ec2.InternetGateway(`${name}-igw`, {
            vpcId: vpc.id,
            tags: { Name: `${name}-igw` },
        }, { parent: this });

        // Create public and private subnets across AZs
        this.publicSubnetIds = [];
        this.privateSubnetIds = [];

        args.availabilityZones.forEach((az, index) => {
            const publicSubnet = new aws.ec2.Subnet(`${name}-public-${index}`, {
                vpcId: vpc.id,
                cidrBlock: `10.0.${index * 2}.0/24`,
                availabilityZone: az,
                mapPublicIpOnLaunch: true,
                tags: { Name: `${name}-public-${az}`, Tier: "public" },
            }, { parent: this });
            this.publicSubnetIds.push(publicSubnet.id);

            const privateSubnet = new aws.ec2.Subnet(`${name}-private-${index}`, {
                vpcId: vpc.id,
                cidrBlock: `10.0.${index * 2 + 1}.0/24`,
                availabilityZone: az,
                tags: { Name: `${name}-private-${az}`, Tier: "private" },
            }, { parent: this });
            this.privateSubnetIds.push(privateSubnet.id);
        });

        this.registerOutputs({
            vpcId: this.vpcId,
            publicSubnetIds: this.publicSubnetIds,
            privateSubnetIds: this.privateSubnetIds,
        });
    }
}

// infra/index.ts
import { Vpc } from "./components/vpc";
import { Database } from "./components/database";
import { EcsService } from "./components/ecs-service";

const config = new pulumi.Config();
const environment = pulumi.getStack();

const network = new Vpc("platform", {
    cidrBlock: "10.0.0.0/16",
    availabilityZones: ["us-east-1a", "us-east-1b", "us-east-1c"],
    enableNatGateway: environment !== "dev",
    tags: { Environment: environment, ManagedBy: "pulumi" },
});

const database = new Database("platform", {
    vpcId: network.vpcId,
    subnetIds: network.privateSubnetIds,
    instanceClass: config.get("dbInstanceClass") || "db.t3.medium",
    engine: "postgres",
    engineVersion: "16.2",
    allocatedStorage: 50,
    multiAz: environment === "prod",
});

const api = new EcsService("api", {
    vpcId: network.vpcId,
    subnetIds: network.privateSubnetIds,
    image: `myregistry/api:${config.require("apiVersion")}`,
    cpu: 512,
    memory: 1024,
    desiredCount: environment === "prod" ? 3 : 1,
    environment: {
        DATABASE_URL: database.connectionString,
        NODE_ENV: environment,
    },
});

export const apiEndpoint = api.endpoint;
export const databaseEndpoint = database.endpoint;
```

### Step 3: Write Policy-as-Code with CrossGuard

```typescript
// policy/index.ts
import * as policy from "@pulumi/policy";

new policy.PolicyPack("platform-policies", {
    policies: [
        {
            name: "no-public-s3",
            description: "S3 buckets must not have public access",
            enforcementLevel: "mandatory",
            validateResource: policy.validateResourceOfType(
                aws.s3.Bucket, (bucket, args, reportViolation) => {
                    if (bucket.acl === "public-read" || bucket.acl === "public-read-write") {
                        reportViolation("S3 buckets must not be publicly accessible");
                    }
                }
            ),
        },
        {
            name: "require-encryption",
            description: "RDS instances must have encryption enabled",
            enforcementLevel: "mandatory",
            validateResource: policy.validateResourceOfType(
                aws.rds.Instance, (instance, args, reportViolation) => {
                    if (!instance.storageEncrypted) {
                        reportViolation("RDS instances must have storage encryption enabled");
                    }
                }
            ),
        },
        {
            name: "require-tags",
            description: "All resources must have Environment and ManagedBy tags",
            enforcementLevel: "advisory",
            validateResource: (args, reportViolation) => {
                const tags = (args.props as any).tags;
                if (tags && (!tags.Environment || !tags.ManagedBy)) {
                    reportViolation("Resources must have Environment and ManagedBy tags");
                }
            },
        },
    ],
});
```

### Step 4: Verify

```bash
# Preview changes
pulumi preview --stack dev

# Deploy with policy enforcement
pulumi up --stack dev --policy-pack ./policy

# Run unit tests
cd infra && npm test

# View stack outputs
pulumi stack output --stack dev --json

# Compare stacks
pulumi stack export --stack dev > dev.json
pulumi stack export --stack staging > staging.json
diff <(jq '.deployment.resources | length' dev.json) \
     <(jq '.deployment.resources | length' staging.json)
```

## CLAUDE.md for Pulumi Infrastructure

```markdown
# Pulumi Infrastructure Standards

## Domain Rules
- Use ComponentResource for all reusable infrastructure patterns
- One stack per environment (dev, staging, prod)
- Stack configuration for environment-specific values (not hardcoded)
- All resources must have Environment and ManagedBy tags
- Use stack references for cross-stack dependencies (not hardcoded ARNs)
- Policy packs enforce security and compliance in CI
- Secrets must use pulumi config set --secret, never plaintext

## File Patterns
- components/*.ts (reusable ComponentResource classes)
- index.ts (stack entry point, minimal orchestration)
- policy/index.ts (CrossGuard policy pack)
- __tests__/*.test.ts (unit tests with mocked resources)
- Pulumi.yaml, Pulumi.dev.yaml, Pulumi.prod.yaml

## Common Commands
- pulumi new aws-typescript
- pulumi stack init dev
- pulumi preview --stack dev
- pulumi up --stack dev --policy-pack ./policy
- pulumi stack output --json
- pulumi config set key value
- pulumi config set --secret dbPassword s3cret
- pulumi destroy --stack dev
- pulumi stack export --stack dev > state.json
```

## Common Pitfalls in Pulumi Development

- **Resource naming collisions:** Pulumi auto-generates physical names with random suffixes, but custom names can collide across stacks. Claude Code uses the stack name as a name prefix to ensure uniqueness across environments.

- **Stack reference circular dependencies:** When stack A references stack B and vice versa, Pulumi cannot resolve the dependency. Claude Code structures multi-stack architectures with a clear dependency tree (network -> data -> compute -> application).

- **Forgetting to register outputs:** ComponentResource classes must call `registerOutputs()` or child resources will not appear in the state. Claude Code always includes this call in the constructor.

## Related

- [Claude Code for Earthly CI Pipeline](/claude-code-earthly-ci-pipeline-2026/)
- [Claude Code for Bazel Build System](/claude-code-bazel-build-system-2026/)
- [Claude Code for Nx Workspace Orchestration](/claude-code-nx-workspace-orchestration-2026/)
