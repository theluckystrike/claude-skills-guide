---
layout: default
title: "Claude Code Skills for Writing CloudFormation Templates"
description: "Practical guide to using Claude Code skills for writing CloudFormation templates. Code snippets, workflow patterns, and real examples for AWS infrastructure."
date: 2026-03-14
categories: [use-cases]
tags: [claude-code, claude-skills, cloudformation, aws, infrastructure-as-code]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-skills-for-writing-cloudformation-templates/
---

# Claude Code Skills for Writing CloudFormation Templates

Writing AWS CloudFormation templates manually requires deep knowledge of AWS resource properties, intrinsic functions, and template anatomy. Claude Code skills transform this process by providing specialized prompts, validation rules, and generation workflows that accelerate infrastructure-as-code development. This guide covers practical approaches for using Claude Code skills to write, validate, and optimize CloudFormation templates. For broader IaC approaches, see [Claude Code Skills for Terraform IaC](/claude-skills-guide/claude-code-skills-for-infrastructure-as-code-terraform/).

## Setting Up CloudFormation Skills

Before writing templates, ensure Claude Code can access CloudFormation documentation. Create a [skill using the standard .md format](/claude-skills-guide/claude-skill-md-format-complete-specification-guide/) that loads AWS CloudFormation resource reference material:

```yaml
# cloudformation-base.skill.md
# Load CloudFormation resource types and properties
# Include: AWS::EC2::Instance, AWS::S3::Bucket, AWS::Lambda::Function
# Include: Fn::Ref, Fn::GetAtt, Fn::Sub, Fn::Join intrinsic functions
```

This foundational skill gives Claude Code context about available CloudFormation resources and their properties. The skill loads automatically when you mention CloudFormation in your prompts, enabling accurate template generation without manual reference lookups.

## Generating Basic Resource Stacks

When you need a simple resource, describe it naturally:

> "Create an S3 bucket with versioning enabled and default encryption"

Claude Code generates the YAML:

```yaml
Resources:
  DataBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${AWS::StackName}-data'
      VersioningConfiguration:
        Status: Enabled
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: AES256
```

The `!Sub '${AWS::StackName}'` pattern demonstrates CloudFormation intrinsic functions. [Claude Code understands AWS naming conventions](/claude-skills-guide/claude-code-skills-for-infrastructure-as-code-terraform/) and automatically applies best practices like using `AWS::StackName` for dynamic resource naming.

## Building Complex Multi-Resource Templates

For production stacks with multiple resources, structure your prompts to include dependencies:

> "Create a VPC with public and private subnets across two availability zones, including a NAT gateway and routing tables"

Claude Code produces a comprehensive template:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'VPC with public/private subnets and NAT Gateway'

Parameters:
  VPCCidr:
    Type: String
    Default: '10.0.0.0/16'
    Description: 'CIDR block for the VPC'

Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VPCCidr
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Sub '${AWS::StackName}-vpc'

  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: !Sub '${AWS::StackName}-igw'

  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC
      InternetGatewayId: !Ref InternetGateway

  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub '${AWS::StackName}-public-1'

  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.2.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      Tags:
        - Key: Name
          Value: !Sub '${AWS::StackName}-private-1'

  NatGatewayEIP:
    Type: AWS::EC2::EIP
    DependsOn: AttachGateway
    Properties:
      Domain: vpc

  NatGateway:
    Type: AWS::EC2::NatGateway
    Properties:
      AllocationId: !GetAtt NatGatewayEIP.AllocationId
      SubnetId: !Ref PublicSubnet1
```

This template includes proper references between resources, parameterization for flexibility, and AWS best practices like enabling DNS support.

## Validating Templates During Development

Claude Code skills can validate CloudFormation templates in real-time. Add validation prompts to catch errors before deployment:

> "Validate this CloudFormation template and check for common issues like circular dependencies, missing required properties, or invalid IAM policies"

The skill checks:
- Resource property requirements
- IAM policy syntax validity
- Circular dependency detection
- Parameter references that resolve correctly

```bash
# Command-line validation
aws cloudformation validate-template --template-body file://template.yaml
```

Integrating this validation into your workflow prevents failed stack deployments and reduces iteration cycles.

## Working with Nested Stacks

[Large CloudFormation templates benefit from nested stack patterns](/claude-skills-guide/claude-code-skills-for-ansible-automation/). Claude Code helps organize resources into logical components:

```yaml
# Parent stack
Resources:
  NetworkStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: !Sub 'https://s3.amazonaws.com/${AWS::Region}-templates/network.yaml'
      Parameters:
        VPCCidr: !Ref VPCCidr

  DatabaseStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: !Sub 'https://s3.amazonaws.com/${AWS::Region}-templates/database.yaml'
      Parameters:
        VPCId: !GetAtt NetworkStack.Outputs.VPCId
        SubnetIds: !Join [',', !GetAtt NetworkStack.Outputs.PrivateSubnetIds]
```

Claude Code understands the outputs-to-inputs pattern and generates proper references between nested stacks automatically.

## Implementing Conditionals and Mappings

Production templates often need environment-specific configurations:

```yaml
Mappings:
  RegionMap:
    us-east-1:
      AMI: ami-0c55b159cbfafe1f0
    us-west-2:
      AMI: ami-0892d3c7ee96c0bf7

Conditions:
  IsProduction: !Equals [!Ref Environment, production]
  EnableAutoscaling: !Or [!Equals [!Ref Environment, staging], !Equals [!Ref Environment, production]]

Resources:
  Instance:
    Type: AWS::EC2::Instance
    Condition: IsProduction
    Properties:
      ImageId: !FindInMap [RegionMap, !Ref 'AWS::Region', AMI]
      InstanceType: !Ref InstanceType

  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Condition: EnableAutoscaling
    Properties:
      MinSize: !If [IsProduction, 2, 1]
      MaxSize: !If [IsProduction, 10, 3]
```

Claude Code generates these CloudFormation primitives accurately, ensuring conditions evaluate correctly and mappings resolve to proper values.

## Generating IAM Roles and Policies

IAM resources require precise policy documents. This connects naturally to [Claude Code permissions model best practices](/claude-skills-guide/claude-code-permissions-model-security-guide-2026/). Prompt Claude Code with the required permissions:

> "Create an IAM role for an ECS task that can read from S3 buckets starting with 'app-data-' and write to CloudWatch Logs"

```yaml
Resources:
  ECSTaskRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Sub '${AWS::StackName}-ecs-task-role'
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: ecs-tasks.amazonaws.com
            Action: sts:AssumeRole

  S3ReadPolicy:
    Type: AWS::IAM::Policy
    Properties:
      PolicyName: !Sub '${AWS::StackName}-s3-read'
      Roles:
        - !Ref ECSTaskRole
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Action:
              - s3:GetObject
              - s3:ListBucket
            Resource:
              - !Sub 'arn:aws:s3:::app-data-*'
              - !Sub 'arn:aws:s3:::app-data-*/*'

  CloudWatchWritePolicy:
    Type: AWS::IAM::Policy
    Properties:
      PolicyName: !Sub '${AWS::StackName}-cloudwatch-write'
      Roles:
        - !Ref ECSTaskRole
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Action:
              - logs:CreateLogGroup
              - logs:CreateLogStream
              - logs:PutLogEvents
            Resource: '*'
```

The generated policies follow least-privilege principles by specifying exact actions and resource ARNs.

## Practical Workflow Integration

Integrate CloudFormation skills into your daily development workflow using the [use-cases hub](/claude-skills-guide/use-cases-hub/) for related patterns:

1. **Describe requirements**: Start with natural language describing your infrastructure needs
2. **Iterate refinement**: Ask Claude Code to add parameters, conditions, or nested stacks
3. **Validate continuously**: Run validation prompts at each iteration
4. **Review generated output**: Check that resource naming and properties match expectations
5. **Deploy safely**: Use change sets before applying modifications

This workflow reduces template writing time significantly while maintaining correctness through automated validation.

Claude Code skills for CloudFormation provide substantial value for teams managing AWS infrastructure. By loading documentation context, generating accurate resource definitions, and validating templates automatically, these skills transform CloudFormation development from a error-prone manual process into an efficient collaborative workflow.

## Related Reading

- [Claude Code Skills for Terraform IaC](/claude-skills-guide/claude-code-skills-for-infrastructure-as-code-terraform/) — extend your IaC skills beyond CloudFormation to Terraform
- [Claude Code GCP Google Cloud Setup and Deployment Guide](/claude-skills-guide/claude-code-gcp-google-cloud-setup-and-deployment-guide/) — apply similar approaches to multi-cloud infrastructure
- [Claude Code GitHub Actions Workflow Matrix Strategy Guide](/claude-skills-guide/claude-code-github-actions-workflow-matrix-strategy-guide/) — automate CloudFormation deployments via CI/CD pipelines
- [Claude Code AWS ECS Fargate Setup and Deployment Tutorial](/claude-skills-guide/claude-code-aws-ecs-fargate-setup-deployment-tutorial/) — deploy containerized apps on top of your CloudFormation stacks

Built by theluckystrike — More at [zovo.one](https://zovo.one)
