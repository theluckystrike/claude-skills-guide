---

layout: default
title: "Container Environment Variables in Claude Code"
description: "Set up and manage environment variables in Claude Code containers. Covers secrets, config injection, Docker Compose, and production-ready patterns."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, containers, environment-variables, devops, docker, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-container-environment-variables-management/
reviewed: true
score: 7
geo_optimized: true
---


Claude Code Container Environment Variables Management

Environment variables are the backbone of flexible, secure container configurations in Claude Code. Whether you're managing API keys, database connections, or feature flags, understanding how to properly handle environment variables in containerized Claude Code environments is essential for building solid, production-ready applications.

## Why Environment Variables Matter in Containers

Container environments present unique challenges for configuration management. Unlike traditional servers where you might directly edit configuration files, containers are designed to be immutable and portable. Environment variables solve this by externalizing configuration from your application code while maintaining security and flexibility.

In Claude Code, environment variables serve multiple critical purposes:

- Secret management: Storing API keys, tokens, and credentials securely
- Configuration: Adjusting application behavior without code changes
- Feature flags: Enabling or disabling features dynamically
- Connection strings: Database URLs, service endpoints, and network configurations

The twelve-factor app methodology, which has become the gold standard for building cloud-native applications, explicitly calls out environment variables as the correct mechanism for storing configuration that varies between deployments. When you adopt this principle in your Claude Code container workflows, you gain portability across development, staging, and production environments without any code changes.

## Setting Environment Variables in Docker Containers

There are several approaches to setting environment variables in Docker containers, each with different use cases and security implications.

## Using the ENV Instruction in Dockerfile

The most straightforward method is using the `ENV` instruction in your Dockerfile:

```dockerfile
FROM node:20-alpine

Set environment variables at build time
ENV NODE_ENV=production
ENV APP_PORT=3000

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

CMD ["node", "index.js"]
```

This approach embeds the values directly into the image, making them available to all containers running from that image. It is appropriate for non-sensitive default values that rarely change, such as a default listening port or a timezone setting. Avoid using this approach for secrets, because the values are baked into every image layer and visible in the image history.

## Using docker run -e Flag

For runtime variables, especially secrets, use the `-e` flag:

```bash
docker run -e API_KEY=your_api_key_here -e DB_PASSWORD=secret_pass my-container
```

For sensitive values, you can omit the value to pull from the host's environment:

```bash
docker run -e API_KEY -e DB_PASSWORD my-container
```

This reads from the host's environment, keeping secrets out of command history. This pattern works well for one-off container invocations or when the values are already loaded in the shell environment via a secrets manager or CI/CD injection.

## Using Docker Compose

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

The `env_file` approach is cleaner when you have many variables. The referenced file uses a simple `KEY=VALUE` format without shell quoting, and Docker Compose reads it at startup. You can layer multiple `env_file` entries for overriding defaults in different environments:

```yaml
services:
 claude-app:
 build: .
 env_file:
 - .env.base # Shared defaults
 - .env.production # Production overrides
```

## Environment Variable Interpolation in Compose Files

Docker Compose also supports variable interpolation within the compose file itself, drawing values from the shell environment or a `.env` file in the project directory:

```yaml
services:
 claude-app:
 image: myapp:${IMAGE_TAG:-latest}
 environment:
 - DATABASE_HOST=${DATABASE_HOST}
 - DATABASE_PORT=${DATABASE_PORT:-5432}
```

The `:-` syntax provides a default value when the variable is not set. This makes your compose files self-documenting. a reader can immediately see which values are configurable and what their defaults are.

## Accessing Environment Variables in Claude Code

Claude Code provides multiple ways to access and work with environment variables throughout your workflow.

## Reading Variables in Shell Scripts

Your shell scripts can access environment variables using standard syntax:

```bash
#!/bin/bash

Access environment variable with default fallback
DATABASE_URL="${DATABASE_URL:-postgres://localhost:5432/mydb}"

Use in conditional logic
if [ "$NODE_ENV" = "production" ]; then
 echo "Running in production mode"
fi

Export to child processes
export API_ENDPOINT="https://api.example.com"
```

The `${VAR:-default}` pattern is essential for defensive scripting inside containers. It ensures that a missing variable does not silently cause unexpected behavior.

## Using .env Files for Local Development

For local development, create a `.env` file (add it to `.gitignore`):

```bash
.env.local - do not commit to version control
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

In Python, the pattern looks similar:

```python
from dotenv import load_dotenv
import os

load_dotenv()

database_url = os.getenv("DATABASE_URL", "postgres://localhost:5432/devdb")
api_key = os.getenv("API_KEY")

if not api_key:
 raise RuntimeError("API_KEY environment variable is required")
```

## Accessing Variables in Different Languages

Each language ecosystem has its own conventions for environment variable access. Here is a quick reference:

| Language | Access Pattern | Default Value |
|----------|---------------|---------------|
| Node.js | `process.env.VAR_NAME` | `process.env.VAR_NAME \|\| 'default'` |
| Python | `os.getenv('VAR_NAME')` | `os.getenv('VAR_NAME', 'default')` |
| Go | `os.Getenv("VAR_NAME")` | Requires manual check for empty |
| Ruby | `ENV['VAR_NAME']` | `ENV.fetch('VAR_NAME', 'default')` |
| Bash | `$VAR_NAME` | `${VAR_NAME:-default}` |

Understanding these patterns ensures that your application code behaves consistently regardless of which container environment it runs in.

## Best Practices for Secure Variable Management

1. Never Hardcode Secrets

Always use environment variables for sensitive data:

```javascript
// Bad - hardcoded secret
const apiKey = "sk-1234567890abcdef";

// Good - from environment
const apiKey = process.env.API_KEY;
```

Beyond the obvious security risk, hardcoded secrets make rotation painful. When a credential is exposed or needs rotation, you would need to rebuild and redeploy the image. With environment variables, you update the secret at the deployment layer and restart the container.

2. Use Secret Management Services

For production environments, integrate with secret management services:

```yaml
docker-compose.production.yml
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

Popular secret management options include AWS Secrets Manager, HashiCorp Vault, and Azure Key Vault. Each offers at-rest encryption, access logging, and automatic rotation. The pattern for using them in containers is to fetch the secret at startup and inject it as an environment variable, or to mount it as a file in a `tmpfs` volume.

Here is an example using AWS Secrets Manager with the AWS CLI at container startup:

```bash
#!/bin/bash

Fetch secret from AWS Secrets Manager
DB_PASSWORD=$(aws secretsmanager get-secret-value \
 --secret-id prod/myapp/db-password \
 --query SecretString \
 --output text)

export DB_PASSWORD

Now start the application
exec node server.js
```

3. Validate Required Variables at Startup

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

Failing fast at startup is far better than a cryptic error deep inside your application logic when the missing variable is actually accessed. This pattern also surfaces configuration problems during deployment checks before traffic is routed to the new container.

In Node.js, a common pattern is to keep this validation in a dedicated `config.js` module that throws on startup if required variables are absent:

```javascript
const config = {
 databaseUrl: process.env.DATABASE_URL || throwMissing('DATABASE_URL'),
 apiKey: process.env.API_KEY || throwMissing('API_KEY'),
 port: parseInt(process.env.PORT || '3000', 10),
 nodeEnv: process.env.NODE_ENV || 'development',
};

function throwMissing(name) {
 throw new Error(`Required environment variable ${name} is not set`);
}

module.exports = config;
```

4. Separate Configuration by Environment

Keep environment-specific configuration files separate and clearly named:

```
.env.development # Local dev defaults. can be committed if no secrets
.env.test # Test environment settings
.env.staging # Staging-specific values (never committed)
.env.production # Production values (never committed)
.env.local # Personal overrides. always gitignored
```

A well-structured `.gitignore` entry for this pattern:

```gitignore
Environment variable files
.env
.env.local
.env.*.local
.env.staging
.env.production
```

## Claude Code Specific Patterns

When working with Claude Code in containerized environments, consider these specialized patterns:

## Skill Configuration Through Environment

Skills can read environment variables to adjust their behavior:

```yaml
In your skill configuration
environment:
 - ALLOWED_TOOLS=read_file,write_file,bash
 - MAX_FILE_SIZE=10485760
 - ENABLE_DEBUG=true
```

This approach lets operators change skill behavior for different deployment contexts without modifying skill code. A skill running in a restricted CI environment might have a smaller tool allowlist, while one running in a developer sandbox can have the full set.

## Container Orchestration Integration

When running Claude Code in Kubernetes or other orchestrators, use their native environment variable management:

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

Kubernetes also provides `ConfigMap` and `Secret` resources for managing environment variables at scale. A `ConfigMap` holds non-sensitive configuration; a `Secret` holds sensitive values with base64 encoding and RBAC-controlled access:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
 name: claude-code-config
data:
 NODE_ENV: "production"
 APP_PORT: "3000"
 LOG_LEVEL: "info"
---
apiVersion: v1
kind: Secret
metadata:
 name: claude-code-secrets
type: Opaque
stringData:
 API_KEY: "your_api_key_here"
 DB_PASSWORD: "your_db_password_here"
```

Reference them in your deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
 name: claude-code-deployment
spec:
 template:
 spec:
 containers:
 - name: claude-container
 image: claude-code:latest
 envFrom:
 - configMapRef:
 name: claude-code-config
 - secretRef:
 name: claude-code-secrets
```

Using `envFrom` rather than individually mapping each variable keeps the deployment manifest clean and automatically picks up any new keys added to the ConfigMap or Secret.

## Docker Build Arguments vs Environment Variables

Understand when to use `ARG` versus `ENV`:

| Aspect | ARG | ENV |
|--------|-----|-----|
| Scope | Build time only | Build time and runtime |
| Persistence | Not saved in image | Saved in image layers |
| Use case | Image version, flags | Configuration values |
| Security | Not visible at runtime | Visible via `docker inspect` |
| Override at runtime | Cannot override | Can override with `-e` |

```dockerfile
ARG - available only during build
ARG NODE_VERSION=20
FROM node:${NODE_VERSION}

ARG for build-time feature flags
ARG INSTALL_DEV_TOOLS=false
RUN if [ "$INSTALL_DEV_TOOLS" = "true" ]; then apt-get install -y vim; fi

ENV - available at build and runtime
ENV APP_ENV=production
ENV LOG_FORMAT=json
```

One important nuance: if you set an `ARG` before the `FROM` instruction and then set an `ENV` with the same name inside the build, the `ENV` value takes over for subsequent layers. This is useful for pinning a version during build but still exposing it to the running process for diagnostics.

## Environment Variable Namespacing and Organization

In complex applications with many services, namespacing your environment variables prevents collisions and makes the configuration easier to reason about:

```bash
Database variables
DB_HOST=postgres.internal
DB_PORT=5432
DB_NAME=myapp_production
DB_USER=appuser
DB_PASSWORD=secret

Redis variables
REDIS_HOST=redis.internal
REDIS_PORT=6379
REDIS_PASSWORD=secret

Application variables
APP_HOST=0.0.0.0
APP_PORT=3000
APP_LOG_LEVEL=info

Third-party API variables
STRIPE_PUBLIC_KEY=pk_live_xxx
STRIPE_SECRET_KEY=sk_live_xxx
SENDGRID_API_KEY=SG.xxx
```

A consistent prefix for each service makes it easy to grep for all variables related to a particular dependency and simplifies documentation.

## Troubleshooting Common Issues

## Variables Not Visible in Container

If your environment variables aren't available:

1. Check if they were set with `ENV` in Dockerfile
2. Verify they're passed with `-e` flag or in docker-compose
3. Confirm the spelling matches (case-sensitive)
4. For Docker Compose, ensure no typos in service names
5. Use `docker exec -it <container_id> env` to list all variables visible inside a running container

## Secret Values Appearing in Logs

To prevent environment variable leakage:

```bash
Use printf instead of echo for sensitive values
printf "API_KEY=%s\n" "$API_KEY" # Safer
echo "API_KEY=$API_KEY" # Avoid - is logged
```

Also audit your application logging configuration to ensure structured loggers do not serialize the entire environment object. A common mistake in Node.js is:

```javascript
// BAD - logs all environment variables including secrets
logger.info('Application starting', { env: process.env });

// GOOD - log only what you need
logger.info('Application starting', {
 port: process.env.PORT,
 nodeEnv: process.env.NODE_ENV
});
```

## Variables Empty in Docker Compose

Docker Compose variable substitution can fail silently. Use explicit values or `.env` files:

```bash
Create .env file in the same directory as docker-compose.yml
echo "DATABASE_URL=postgres://user:pass@localhost:5432/mydb" > .env
```

You can debug Docker Compose variable substitution with `docker compose config`, which prints the fully-resolved compose file with all substitutions applied. This makes it easy to spot missing or incorrectly named variables before starting your services.

## Avoiding Variable Precedence Confusion

Docker and Docker Compose apply environment variables in a specific precedence order. From highest to lowest priority:

1. Variables set with `-e` on `docker run`
2. The `environment` key in the compose file
3. The shell environment where `docker compose` is invoked
4. Variables in the `.env` file
5. `ENV` instructions in the Dockerfile

Understanding this order helps you predict which value wins when the same variable is defined in multiple places, which is a common source of confusing behavior in multi-stage or multi-environment setups.

## Conclusion

Mastering environment variable management in Claude Code containers is fundamental to building secure, maintainable applications. By following these patterns, using environment variables for configuration, implementing proper secret management, validating variables at startup, and organizing them with consistent namespacing, you'll create containerized applications that are both flexible and secure.

Remember: treat your environment variables as first-class configuration citizens, and your containerized applications will be easier to deploy, manage, and scale across different environments. Whether you're running a single Docker container on a personal project or orchestrating hundreds of pods across a Kubernetes cluster, the same principles apply: externalize configuration, validate early, and never hardcode secrets.


---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-code-container-environment-variables-management)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code Dockerfile Generation: Multi-Stage Build Guide](/claude-code-dockerfile-generation-multi-stage-build-guide/)
- [Claude Code Buildah Container Builds Guide](/claude-code-buildah-container-builds-guide/)
- [Claude Code Docker Compose Test Setup Guide](/claude-code-docker-compose-test-setup-guide/)
- [Claude Code Snippet Library Management](/claude-code-snippet-library-management/)
- [Claude Code Podman Rootless Container Guide](/claude-code-podman-rootless-container-guide/)
- [Claude Code Git Tags Release Management — Developer Guide](/claude-code-git-tags-release-management/)
- [Claude Code Environment Variables Reference](/claude-code-environment-variables-reference/)
- [What 1,024 Queries Reveal About Claude Code Users](/claude-code-search-query-analysis-2026/)
- [Zero-Click Crisis: 26,619 Wasted Impressions](/claude-code-zero-click-crisis-2026-study/)
- [Why Senior Developers Prefer Claude Code (2026)](/why-do-senior-developers-prefer-claude-code-2026/)
- [Claude Code Fortran Scientific — Complete Developer Guide](/claude-code-fortran-scientific-code-modernization-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


