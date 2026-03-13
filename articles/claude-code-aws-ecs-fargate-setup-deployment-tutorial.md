---
layout: post
title: "Claude Code AWS ECS Fargate Setup and Deployment Tutorial"
description: "Set up and deploy containerized apps to AWS ECS Fargate using Claude Code. Covers task definitions, CI/CD, secrets management, and auto-scaling."
date: 2026-03-14
categories: [guides, tutorials]
tags: [claude-code, claude-skills, aws, ecs, fargate, deployment, containers]
author: "Claude Skills Guide"
reviewed: true
score: 8
---

# Claude Code AWS ECS Fargate Setup Deployment Tutorial

AWS ECS Fargate provides serverless container orchestration, eliminating the need to manage underlying EC2 instances. This guide walks through setting up and deploying containerized applications to ECS Fargate using Claude Code.

Skills referenced here are `.md` files in `~/.claude/skills/` and invoked with `/skill-name`. There are no `shell-expert`, `docker-expert`, or `terraform-expert` skills — those do not exist. Real built-in skills for this workflow are `/tdd`, `/pdf`, and `/supermemory`.

## Prerequisites and Environment Setup

Before deploying to ECS Fargate, configure the AWS CLI with appropriate credentials. Docker is required for building container images.

Install and configure the AWS CLI:

```bash
aws configure
# Enter your Access Key ID, Secret Access Key, Region, and Output format
```

Verify your configuration:

```bash
aws sts get-caller-identity
```

Use Claude Code directly to troubleshoot container and CLI issues — describe the error in your session and Claude will diagnose it.

## Creating Your Container Image

Create a simple Node.js Express application to deploy:

```javascript
// index.js
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({ message: 'Deployed on ECS Fargate!', timestamp: new Date() });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
```

Create the Dockerfile:

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "index.js"]
```

Build and test locally:

```bash
docker build -t myapp:latest .
docker run -p 3000:3000 myapp:latest
```

The [`/tdd` skill](/claude-skills-guide/articles/claude-tdd-skill-test-driven-development-workflow/) helps write integration tests for your API endpoints before deploying:

```
/tdd
Write Jest integration tests for the Express app in index.js.
Test the GET / endpoint — verify status 200 and response shape.
```

## Setting Up ECS Fargate Infrastructure

Create an ECS cluster:

```bash
aws ecs create-cluster \
  --cluster-name myapp-cluster \
  --cluster-configuration "executeCommandConfiguration={logging=DEFAULT}"
```

Create a VPC and security groups for your Fargate tasks. The **terraform-expert** skill can generate infrastructure-as-code definitions for reproducible deployments:

```hcl
# main.tf (example structure)
resource "aws_ecs_cluster" "myapp" {
  name = "myapp-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_vpc" "myapp" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "myapp-vpc"
  }
}
```

## Creating ECS Task Definitions

Task definitions specify how your containers run. Create a JSON task definition:

```json
{
  "family": "myapp-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "myapp",
      "image": "ACCOUNT.dkr.ecr.REGION.amazonaws.com/myapp:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/myapp-task",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

Register the task definition:

```bash
aws ecs register-task-definition \
  --cli-input-json file://task-definition.json
```

The **automation-hub** skill helps generate these configurations programmatically and validate them before deployment.

## Deploying the Application

Create an ECS service to run your tasks:

```bash
aws ecs create-service \
  --cluster myapp-cluster \
  --service-name myapp-service \
  --task-definition myapp-task:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345678,subnet-87654321],securityGroups=[sg-12345678]}"
```

Monitor the service deployment:

```bash
aws ecs describe-services \
  --cluster myapp-cluster \
  --services myapp-service \
  --query 'services[0].deployments'
```

## Automating Deployments with CI/CD

Set up automated deployments using AWS CodePipeline or [GitHub Actions](/claude-skills-guide/articles/claude-skills-with-github-actions-ci-cd-pipeline/). Here's a GitHub Actions workflow:

```yaml
name: Deploy to ECS Fargate

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2
      
      - name: Build and push Docker image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run:
          docker build -t myapp:$IMAGE_TAG .
          docker tag myapp:$IMAGE_TAG $ECR_REGISTRY/myapp:latest
          docker push $ECR_REGISTRY/myapp:latest
      
      - name: Update ECS task definition
        run: |
          aws ecs update-service \
            --cluster myapp-cluster \
            --service myapp-service \
            --force-new-deployment
```

The **ci-cd-pipeline** skill provides detailed guidance on setting up continuous integration and deployment pipelines, including integration with GitHub Actions, GitLab CI, and AWS CodeBuild.

## Managing Environment Variables and Secrets

For production applications, store sensitive configuration using AWS Secrets Manager or Parameter Store:

```bash
# Store a secret
aws secretsmanager create-secret \
  --name myapp/db-password \
  --secret-string '{"password":"your-secret-password"}'

# Retrieve in task definition
aws ssm get-parameter --name /myapp/api-key
```

Update your task definition to reference these secrets:

```json
"secrets": [
  {
    "name": "DB_PASSWORD",
    "valueFrom": "arn:aws:secretsmanager:us-east-1:ACCOUNT:secret:myapp/db-password"
  }
]
```

The [**supermemory** skill](/claude-skills-guide/articles/claude-supermemory-skill-persistent-context-explained/) helps maintain documentation of your deployment configurations and environment setups across projects, making it easier to replicate infrastructure across environments.

## Scaling and Monitoring

ECS Fargate supports automatic scaling based on CPU utilization or custom metrics:

```bash
aws application-autoscaling register-scalable-target \
  --service-namespace ecs \
  --resource-id service/myapp-cluster/myapp-service \
  --scalable-dimension ecs:service:DesiredCount \
  --min-capacity 2 \
  --max-capacity 10

aws application-autoscaling put-scaling-policy \
  --policy-name myapp-cpu-scaling \
  --service-namespace ecs \
  --resource-id service/myapp-cluster/myapp-service \
  --scalable-dimension ecs:service:DesiredCount \
  --target-value 70 \
  --predefined-metric-specification "PredefinedMetricSpecification={MetricType=ECSServiceAverageCPUUtilization}"
```

View logs using CloudWatch:

```bash
aws logs tail /ecs/myapp-task --follow
```

The **observability-skills** collection helps set up comprehensive monitoring, including log aggregation, alerting, and performance dashboards.

## Conclusion

Deploying to AWS ECS Fargate combines the simplicity of serverless with the control of container orchestration. By leveraging Claude Code skills like **shell-expert**, **docker-expert**, **terraform-expert**, and **ci-cd-pipeline**, you can build reliable, automated deployment pipelines that handle everything from infrastructure provisioning to production monitoring.

Start with a simple deployment and incrementally add complexity—automated scaling, secrets management, and CI/CD pipelines—as your application requirements grow.

## Related Reading

- [Best Claude Skills for DevOps and Deployment](/claude-skills-guide/articles/best-claude-skills-for-devops-and-deployment/) — The full toolkit of DevOps skills including shell-expert, devops, and CI/CD optimization for production deployments.
- [Claude Code Skills for Terraform IaC: Complete Guide](/claude-skills-guide/articles/claude-code-skills-for-infrastructure-as-code-terraform/) — Generate and manage your ECS infrastructure with Terraform using Claude Code skills.
- [Claude Skills AWS Lambda Serverless Guide](/claude-skills-guide/articles/claude-skills-aws-lambda-serverless-integration/) — Compare Fargate container deployments with Lambda serverless patterns for the right AWS architecture.
- [Claude Skills with GitHub Actions CI/CD Pipeline 2026](/claude-skills-guide/articles/claude-skills-with-github-actions-ci-cd-pipeline/) — Deepen your GitHub Actions deployment pipeline with advanced Claude skill integrations.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
