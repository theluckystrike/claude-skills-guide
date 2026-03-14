---
layout: default
title: "Claude Code Container Environment Variables Management"
description: "Master environment variable handling in Claude Code containers. Learn how to set, access, and manage environment variables for secure and efficient."
date: 2026-03-14
categories: [guides]
tags: [claude-code, containers, environment-variables, devops, docker]
author: theluckystrike
permalink: /claude-code-container-environment-variables-management/
---

{% raw %}
# Claude Code Container Environment Variables Management

Environment variables are the backbone of flexible, secure container configurations in Claude Code. Whether you're managing API keys, database connections, or feature flags, understanding how to properly handle environment variables in containerized Claude Code environments is essential for building robust, production-ready applications.

## Why Environment Variables Matter in Containers

Container environments present unique challenges for configuration management. Unlike traditional servers where you might directly edit configuration files, containers are designed to be immutable and portable. Environment variables solve this by externalizing configuration from your application code while maintaining security and flexibility.

In Claude Code, environment variables serve multiple critical purposes:

- **Secret management**: Storing API keys, tokens, and credentials securely
- **Configuration**: Adjusting application behavior without code changes
- **Feature flags**: Enabling or disabling features dynamically
- **Connection strings**: Database URLs, service endpoints, and network configurations

## Setting Environment Variables in Docker Containers

There are several approaches to setting environment variables in Docker containers, each with different use cases and security implications.

### Using the ENV Instruction in Dockerfile

The most straightforward method is using the `ENV` instruction in your Dockerfile:

```dockerfile
FROM node:20-alpine

# Set environment variables at build time
ENV NODE_ENV=production
ENV APP_PORT=3000

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

CMD ["node", "index.js"]
```

This approach embeds the values directly into the image, making them available to all containers running from that image.

### Using docker run -e Flag

For runtime variables, especially secrets, use the `-e` flag:

```bash
docker run -e API_KEY=your_api_key_here -e DB_PASSWORD=secret_pass my-container
```

For sensitive values, you can omit the value to pull from the host's environment:

```bash
docker run -e API_KEY -e DB_PASSWORD my-container
```

This reads from the host's environment, keeping secrets out of command history.

### Using Docker Compose

Docker Compose simplifies environment variable management with its `environment` and `env_file` options:

```yaml
services:
  claude-app:
    build: .
    environment:
      - NODE_ENV=production
      - APP_PORT=3000
    env_file:
      - .env.production
    ports:
      - "3000:3000"
```

## Accessing Environment Variables in Claude Code

Claude Code provides multiple ways to access and work with environment variables throughout your workflow.

### Reading Variables in Shell Scripts

Your shell scripts can access environment variables using standard syntax:

```bash
#!/bin/bash

# Access environment variable with default fallback
DATABASE_URL="${DATABASE_URL:-postgres://localhost:5432/mydb}"

# Use in conditional logic
if [ "$NODE_ENV" = "production" ]; then
    echo "Running in production mode"
fi

# Export to child processes
export API_ENDPOINT="https://api.example.com"
```

### Using .env Files for Local Development

For local development, create a `.env` file (add it to `.gitignore`):

```bash
# .env.local - do not commit to version control
DATABASE_URL=postgres://user:pass@localhost:5432/devdb
API_KEY=sk_test_your_key_here
DEBUG=true
```

Load it using a tool like `dotenv` in Node.js or `python-dotenv` in Python:

```javascript
require('dotenv').config();

const dbUrl = process.env.DATABASE_URL;
const apiKey = process.env.API_KEY;

console.log(`Connecting to: ${dbUrl}`);
```

## Best Practices for Secure Variable Management

### 1. Never Hardcode Secrets

Always use environment variables for sensitive data:

```javascript
// Bad - hardcoded secret
const apiKey = "sk-1234567890abcdef";

// Good - from environment
const apiKey = process.env.API_KEY;
```

### 2. Use Secret Management Services

For production environments, integrate with secret management services:

```yaml
# docker-compose.production.yml
services:
  app:
    environment:
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - VAULT_TOKEN=${VAULT_TOKEN}
    secrets:
      - db_password

secrets:
  db_password:
    external: true
```

### 3. Validate Required Variables at Startup

Ensure critical environment variables are present:

```bash
#!/bin/bash

required_vars=("DATABASE_URL" "API_KEY" "SECRET_KEY")

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is required but not set"
        exit 1
    fi
done

echo "All required environment variables are set"
```

## Claude Code Specific Patterns

When working with Claude Code in containerized environments, consider these specialized patterns:

### Skill Configuration Through Environment

Skills can read environment variables to adjust their behavior:

```yaml
# In your skill configuration
environment:
  - ALLOWED_TOOLS=read_file,write_file,bash
  - MAX_FILE_SIZE=10485760
  - ENABLE_DEBUG=true
```

### Container Orchestration Integration

When running Claude Code in Kubernetes or other orchestrators, leverage their native environment variable management:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: claude-code-pod
spec:
  containers:
  - name: claude-container
    image: claude-code:latest
    env:
    - name: NODE_ENV
      value: "production"
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: POD_IP
      valueFrom:
        fieldRef:
          fieldPath: status.podIP
```

### Docker Build Arguments vs Environment Variables

Understand when to use `ARG` versus `ENV`:

| Aspect | ARG | ENV |
|--------|-----|-----|
| Scope | Build time only | Build time and runtime |
| Persistence | Not saved in image | Saved in image layers |
| Use case | Image version, flags | Configuration values |

```dockerfile
# ARG - available only during build
ARG NODE_VERSION=20
FROM node:${NODE_VERSION}

# ENV - available at build and runtime
ENV APP_ENV=production
```

## Troubleshooting Common Issues

### Variables Not Visible in Container

If your environment variables aren't available:

1. Check if they were set with `ENV` in Dockerfile
2. Verify they're passed with `-e` flag or in docker-compose
3. Confirm the spelling matches (case-sensitive)
4. For Docker Compose, ensure no typos in service names

### Secret Values Appearing in Logs

To prevent environment variable leakage:

```bash
# Use printf instead of echo for sensitive values
printf "API_KEY=%s\n" "$API_KEY"  # Safer
echo "API_KEY=$API_KEY"           # Avoid - may be logged
```

### Variables Empty in Docker Compose

Docker Compose variable substitution can fail silently. Use explicit values or `.env` files:

```bash
# Create .env file in the same directory as docker-compose.yml
echo "DATABASE_URL=postgres://user:pass@localhost:5432/mydb" > .env
```

## Conclusion

Mastering environment variable management in Claude Code containers is fundamental to building secure, maintainable applications. By following these patterns—using environment variables for configuration, implementing proper secret management, and validating variables at startup—you'll create containerized applications that are both flexible and secure.

Remember: treat your environment variables as first-class configuration citizens, and your containerized applications will be easier to deploy, manage, and scale across different environments.
{% endraw %}

## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

