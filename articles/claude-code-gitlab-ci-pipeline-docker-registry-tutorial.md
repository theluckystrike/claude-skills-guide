---
layout: default
title: "Claude Code GitLab CI Pipeline Docker Registry Tutorial"
description: "A practical guide to building CI/CD pipelines with GitLab and Docker Registry. Includes .gitlab-ci.yml examples, Docker configuration, and automation patterns."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, claude-skills, gitlab, ci-cd, docker, devops]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-gitlab-ci-pipeline-docker-registry-tutorial/
---

# Claude Code GitLab CI Pipeline Docker Registry Tutorial

[Setting up automated deployments with GitLab CI and Docker Registry streamlines your development workflow significantly](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/) This tutorial walks you through creating a complete pipeline that builds, tests, and pushes Docker images to GitLab's integrated registry.

## Prerequisites

Before you begin, ensure you have:

- A GitLab account with a project
- Docker installed locally
- GitLab Runner configured (or use GitLab's shared runners)
- Basic familiarity with YAML syntax and command-line operations

If you are new to [CI/CD pipeline](/claude-skills-guide/claude-skills-with-github-actions-ci-cd-pipeline/)s, consider using the `/[tdd skill for testing](/claude-skills-guide/automated-testing-pipeline-with-claude-tdd-skill-2026/)` skill in Claude Code to generate test cases for your application before setting up the pipeline. The skill helps ensure your code works correctly before automation takes over.

## Project Structure

Organize your project to support Docker-based deployments:

```
my-app/
├── .gitlab-ci.yml
├── Dockerfile
├── src/
│   └── index.js
├── tests/
│   └── app.test.js
└── package.json
```

[The `.gitlab-ci.yml` file defines your pipeline, while the `Dockerfile` specifies how to build your container image](/claude-skills-guide/automated-testing-pipeline-with-claude-tdd-skill-2026/)

## Creating the Dockerfile

Start with a production-ready Dockerfile for your application:

```dockerfile
# Use Node.js 20 LTS as base image
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY src/ ./src/

# Production image
FROM node:20-alpine

WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/src ./src

USER nodejs

EXPOSE 3000
CMD ["node", "src/index.js"]
```

This multi-stage build reduces the final image size by excluding build dependencies from the production image.

## Configuring GitLab CI Pipeline

Create your `.gitlab-ci.yml` file in the project root:

```yaml
stages:
  - build
  - test
  - push
  - deploy

variables:
  DOCKER_DRIVER: overlay2
  IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

build:
  stage: build
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $IMAGE_TAG .
    - docker push $IMAGE_TAG
  only:
    - main
    - develop

test:unit:
  stage: test
  image: node:20-alpine
  script:
    - npm ci
    - npm test
  coverage: /All files[^|]*\|[^|]*\s+([\d\.]+)/
  artifacts:
    reports:
      junit: junit.xml

test:integration:
  stage: test
  image: $IMAGE_TAG
  services:
    - postgres:15-alpine
  variables:
    DATABASE_URL: postgres://postgres:postgres@postgres:5432/testdb
    NODE_ENV: test
  script:
    - npm run test:integration

push:tag:
  stage: push
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker pull $IMAGE_TAG
    - docker tag $IMAGE_TAG $CI_REGISTRY_IMAGE:latest
    - docker push $CI_REGISTRY_IMAGE:latest
  only:
    - tags
  when: manual
```

This pipeline runs four stages: building the Docker image, running unit and integration tests, and pushing to the registry. The push stage is manual for tag releases, giving you control over production deployments.

## Enabling GitLab Container Registry

Navigate to your project in GitLab and go to **Settings > General > Visibility**. Enable the Container Registry feature. GitLab automatically creates a registry at `registry.gitlab.com/username/project`.

The pipeline uses these built-in variables:

- `$CI_REGISTRY`: The registry URL
- `$CI_REGISTRY_IMAGE`: Full image path including namespace
- `$CI_REGISTRY_USER`: Username for authentication
- `$CI_REGISTRY_PASSWORD`: Secure token for pushes

GitLab generates these credentials automatically for CI pipelines, so you do not need to configure additional secrets for basic usage.

## Running Tests in Containers

The integration test stage uses the built image as the runtime environment. This ensures your containerized application works correctly in the same environment where it will deploy:

```yaml
test:integration:
  stage: test
  image: $IMAGE_TAG
  services:
    - postgres:15-alpine
  variables:
    POSTGRES_DB: testdb
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: postgres
    DATABASE_URL: postgres://postgres:postgres@postgres:5432/testdb
  script:
    - npm run migrate
    - npm run test:integration
```

The service definition starts a PostgreSQL container linked to your test container, allowing integration tests against a real database.

## Combining with Claude Skills

Use the `/tdd` skill to write comprehensive tests before setting up your pipeline. Claude generates test cases based on your function specifications, ensuring high coverage before automation begins.

After your pipeline runs, use the `/pdf` skill to generate deployment reports. This is useful for documentation and compliance requirements:

```
/pdf
Create a deployment report for our [GitLab CI pipeline](/claude-skills-guide/claude-code-github-actions-workflow-matrix-strategy-guide/) showing success rate, build times, and Docker image sizes for the past month.
```

The `/supermemory` skill stores your pipeline configurations and deployment patterns, so Claude remembers your preferred setup across sessions. This accelerates future pipeline configurations.

For frontend applications, `/frontend-design` helps scaffold components that work well with your Docker setup, including proper environment variable handling and build configurations.

## Security Best Practices

Harden your pipeline with these security measures:

```yaml
security:scan:
  stage: test
  image: aquasec/trivy:latest
  script:
    - trivy image --severity HIGH,CRITICAL $IMAGE_TAG
  allow_failure: false
  only:
    - main
```

Add vulnerability scanning to catch security issues before deployment. The Trivy scanner checks your Docker image against known vulnerability databases.

For sensitive deployments, store credentials in GitLab CI/CD variables rather than hardcoding them. Go to **Settings > CI/CD > Variables** to add secure variables that the pipeline can access.

## Optimizing Pipeline Performance

Speed up your pipeline with caching and parallel execution:

```yaml
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/
    - .npm/

test:unit:
  stage: test
  image: node:20-alpine
  cache:
    key: ${CI_COMMIT_REF_SLUG}-npm
    paths:
      - node_modules/
  script:
    - npm ci
    - npm test -- --coverage
```

Caching node_modules between runs reduces installation time significantly for Node.js projects.

## Conclusion

GitLab CI with integrated Docker Registry provides a powerful platform for automating your build, test, and deployment workflows. The pipeline in this tutorial handles building Docker images, running both unit and integration tests in containers, and pushing to your private registry with manual approval for releases.

Combining this setup with Claude Code skills like `/tdd` for test generation, `/pdf` for reporting, and `/supermemory` for pattern storage creates a productive development environment. Your CI/CD pipeline becomes reliable, repeatable, and secure with the configurations shown here.

---

## Related Reading

- [Best Claude Skills for DevOps and Deployment](/claude-skills-guide/best-claude-skills-for-devops-and-deployment/) — Automate infrastructure with Claude skills
- [Claude Code Skills for Testing](/claude-skills-guide/best-claude-skills-for-testing-2026/) — Improve test coverage with AI assistance
- [Automated Testing Pipeline with Claude TDD Skill](/claude-skills-guide/automated-testing-pipeline-with-claude-tdd-skill-2026/) — Build testing workflows with Claude


Built by theluckystrike — More at [zovo.one](https://zovo.one)
