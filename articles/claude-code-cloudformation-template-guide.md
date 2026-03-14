---

layout: default
title: "Claude Code CloudFormation Template Guide"
description: "Learn how to use Claude Code for CloudFormation template creation. Practical examples and workflows for AWS infrastructure automation."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-cloudformation-template-guide/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
---


{% raw %}

# Claude Code CloudFormation Template Guide

CloudFormation templates can become complex quickly. Writing YAML or JSON by hand for AWS infrastructure introduces opportunities for errors, especially when managing nested stacks, IAM policies, or cross-region deployments. Claude Code offers a practical approach to generating, validating, and maintaining CloudFormation templates through its skill system and natural language capabilities.

This guide covers workflows for creating CloudFormation templates with Claude Code, including specific skills that accelerate infrastructure-as-code development.

## Setting Up Claude Code for AWS Infrastructure

Before generating templates, configure Claude Code to understand your AWS environment and naming conventions. Create a `CLAUDE.md` file in your infrastructure project with your organizational standards:

```markdown
# Infrastructure Project Context

## AWS Standards
- All resource names use PascalCase
- Environment tags: Environment=dev|staging|prod
- Cost center tagging required on all resources
- Stack naming: {Project}-{Environment}-{Resource}

## Common Patterns
- Use VPC templates from /templates/vpc/
- RDS instances always use provisioned IOPS
- ALB always redirects HTTP to HTTPS
```

This context helps Claude Code generate templates that match your existing infrastructure patterns.

## Generating Basic CloudFormation Templates

Claude Code can generate complete CloudFormation templates from natural language descriptions. Provide specific requirements rather than vague requests:

**Effective prompt:**
```
Create a CloudFormation template for an ECS Fargate service with:
- Application load balancer in public subnets
- RDS PostgreSQL database in private subnets
- Auto scaling based on CPU utilization (70% threshold)
- Environment variables from Parameter Store
- Proper IAM roles for ECS task execution
```

Claude Code produces a YAML template with all required resources. Review the output for accuracy—AI-generated infrastructure code requires validation before deployment.

### Example: VPC Template Output

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'VPC with public and private subnets'

Parameters:
  Environment:
    Type: String
    AllowedValues:
      - dev
      - staging
      - prod
    Default: dev

Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Environment
          Value: !Ref Environment
        - Key: Project
          Value: !Ref ProjectName

  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Type
          Value: Public

  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.10.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      Tags:
        - Key: Type
          Value: Private
```

## Using the CloudFormation Skills

Claude Code works with several skills that enhance CloudFormation development:

- **aws-mcp-server**: Provides direct AWS API integration for validating stacks, checking resource limits, and querying existing infrastructure
- **tdd**: Helps create integration tests for CloudFormation templates using AWS CloudFormation Guard rules
- **frontend-design**: Useful when generating CloudFront distributions with S3 origins for static site deployments

Install skills through the Claude Code CLI:

```bash
claude skill install aws-mcp-server
claude skill install tdd
```

The aws-mcp-server skill enables queries like "list all CloudFormation stacks in us-east-1" or "get the status of the production-vpc stack" directly in your conversation.

## Template Validation Workflow

Never deploy untested CloudFormation templates. Establish a validation workflow:

1. **Syntax validation** — Check YAML/JSON syntax
2. **IAM validation** — Verify role permissions
3. **Template validation** — Use `aws cloudformation validate-template`
4. **Security scanning** — Check for exposed credentials, overly permissive policies
5. **Drift detection** — Compare against live infrastructure

Claude Code can run these checks automatically. Create a validation script:

```bash
#!/bin/bash
STACK_NAME=$1
TEMPLATE_FILE=$2

# Syntax check
python3 -c "import yaml; yaml.safe_load(open('$TEMPLATE_FILE'))"

# Validate template
aws cloudformation validate-template \
  --template-body file://$TEMPLATE_FILE

# Deploy to test (optional, for full testing)
aws cloudformation deploy \
  --stack-name $STACK_NAME-test \
  --template-file $TEMPLATE_FILE \
  --capabilities CAPABILITY_IAM \
  --no-execute-changeset
```

## Managing Complex Stacks

Large infrastructure requires organized stack architectures. Claude Code helps design nested stack patterns:

- **Root stack**: Orchestrates child stacks, manages parameters across environments
- **Network stack**: VPCs, subnets, security groups, route tables
- **Data stack**: RDS instances, ElastiCache clusters, DynamoDB tables
- **Application stack**: ECS services, Lambda functions, API Gateway

Prompt Claude Code to generate a nested stack structure:

```
Create a nested CloudFormation architecture for a three-tier application:
- Root stack that accepts environment parameter
- Network stack with VPC, subnets, NAT gateways
- Data stack with RDS PostgreSQL and ElastiCache Redis
- Application stack with ECS Fargate service
- Use Fn::ImportValue for cross-stack references
```

The output includes the parent template and all child templates with proper cross-stack outputs.

## Handling Parameters and Mappings

Effective CloudFormation templates use Parameters, Mappings, and Conditions appropriately:

```yaml
Parameters:
  Environment:
    Type: String
    AllowedValues:
      - dev
      - staging
      - prod
    Description: 'Deployment environment'

  InstanceType:
    Type: String
    Default: t3.medium
    AllowedValues:
      - t3.micro
      - t3.small
      - t3.medium
      - t3.large

Mappings:
  RegionMap:
    us-east-1:
      AMI: ami-0c55b159cbfafe1f0
    us-west-2:
      AMI: ami-0892d3c7ee96c0bf7

Conditions:
  IsProduction: !Equals [!Ref Environment, prod]
  UseLargeInstance: !Or 
    - !Equals [!Ref Environment, staging]
    - !Equals [!Ref Environment, prod]
```

Claude Code generates these structures when you specify environment-specific requirements.

## Best Practices for AI-Generated Templates

- **Always review** generated templates before deployment
- **Use specific prompts** with exact resource requirements
- **Validate syntax** with cfn-lint or cfn-guard
- **Test in dev first** before production deployments
- **Version control** all templates alongside application code
- **Use Parameter Store** for secrets rather than plain text
- **Implement rollback** using CloudFormation termination protection

## Automating Template Updates

Claude Code can help maintain existing templates when AWS releases new features or deprecated resources. Use the skill to:

- Identify deprecated resources in current templates
- Suggest modern alternatives (e.g., NAT Gateway instead of NAT instance)
- Generate migration paths for AWS service updates

Run periodic audits:

```
Review all CloudFormation templates in /infrastructure/ and identify:
- Deprecated resource types
- Missing tags for cost allocation
- Security group rules allowing unrestricted access
- Missing logging configurations
```

## Conclusion

Claude Code transforms CloudFormation template development from manual YAML editing to collaborative infrastructure design. By using skills like aws-mcp-server and tdd, developers can validate templates, manage complex nested architectures, and maintain infrastructure as code more efficiently.

Start with simple templates, establish validation workflows, and gradually adopt more complex patterns as your infrastructure needs grow.

{% endraw %}


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)