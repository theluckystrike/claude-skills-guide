---
layout: default
title: "Claude Code for Pkl Configuration (2026)"
permalink: /claude-code-pkl-configuration-language-2026/
date: 2026-04-20
description: "Write type-safe configurations with Pkl and Claude Code. Define schemas, validate configs at build time, and generate YAML/JSON from Pkl modules."
last_tested: "2026-04-22"
domain: "configuration management"
---

## Why Claude Code for Pkl

Apple's Pkl (pronounced "pickle") is a programmable configuration language that eliminates the YAML/JSON configuration errors that cause production incidents. Unlike Jsonnet or CUE, Pkl has first-class IDE support, a module system with versioned dependencies, and the ability to generate validated configurations for Kubernetes, Terraform, CI/CD, and application settings. The challenge is learning Pkl's unique type system, understanding module amending vs extending, and structuring Pkl projects for multi-environment configuration management.

Claude Code generates Pkl schemas with proper type constraints, builds multi-environment configuration hierarchies, and sets up generation pipelines that output validated YAML/JSON for downstream tools.

## The Workflow

### Step 1: Install and Initialize Pkl

```bash
# Install Pkl CLI
brew install pkl  # macOS
# or: curl -fsSL https://pkl-lang.org/install.sh | sh

# Verify
pkl --version

# Create project structure
mkdir -p config/{base,dev,staging,prod}
```

### Step 2: Define Configuration Schema

```pkl
// config/AppConfig.pkl — Type-safe configuration schema
module AppConfig

/// Application server settings
server: ServerConfig

/// Database connection settings
database: DatabaseConfig

/// Feature flags
features: FeatureFlags

/// Logging configuration
logging: LoggingConfig

class ServerConfig {
  /// Port number (1024-65535)
  port: UInt16(isBetween(1024, 65535))

  /// Hostname to bind
  host: String = "0.0.0.0"

  /// Maximum concurrent connections
  maxConnections: UInt16 = 100

  /// Request timeout in seconds
  timeoutSeconds: UInt16(isBetween(1, 300)) = 30

  /// Enable TLS
  tls: Boolean = true

  /// TLS certificate path (required if tls is true)
  tlsCertPath: String?

  /// TLS key path (required if tls is true)
  tlsKeyPath: String?

  /// Validate TLS paths exist when TLS enabled
  hidden _tlsCheck = if (tls && (tlsCertPath == null || tlsKeyPath == null))
    throw("TLS is enabled but certificate/key paths are not set")
  else true
}

class DatabaseConfig {
  /// Database engine
  engine: "postgres"|"mysql"|"sqlite"

  /// Connection host
  host: String

  /// Connection port
  port: UInt16

  /// Database name
  name: String(length.isBetween(1, 63))

  /// Connection pool size
  poolSize: UInt16(isBetween(1, 100)) = 10

  /// Connection timeout in seconds
  connectTimeoutSeconds: UInt16 = 5

  /// Enable SSL connection
  ssl: Boolean = true

  /// Connection string (computed)
  hidden connectionString: String = "\(engine)://\(host):\(port)/\(name)?sslmode=\(if (ssl) "require" else "disable")"
}

class FeatureFlags {
  /// Enable new onboarding flow
  newOnboarding: Boolean = false

  /// Enable dark mode
  darkMode: Boolean = true

  /// A/B test percentage (0-100)
  abTestPercentage: UInt8(isBetween(0, 100)) = 0

  /// Maintenance mode
  maintenanceMode: Boolean = false
}

class LoggingConfig {
  /// Log level
  level: "debug"|"info"|"warn"|"error" = "info"

  /// Log format
  format: "json"|"text" = "json"

  /// Enable structured logging
  structured: Boolean = true

  /// Log destination
  destination: "stdout"|"file"|"both" = "stdout"

  /// Log file path (required if destination includes file)
  filePath: String?
}
```

### Step 3: Create Environment-Specific Configurations

```pkl
// config/base/base.pkl — Shared configuration
amends "../AppConfig.pkl"

server {
  host = "0.0.0.0"
  maxConnections = 100
  timeoutSeconds = 30
}

database {
  engine = "postgres"
  poolSize = 10
  ssl = true
}

features {
  darkMode = true
}

logging {
  format = "json"
  structured = true
}

// config/dev/config.pkl — Development overrides
amends "../base/base.pkl"

server {
  port = 3000
  tls = false  // No TLS in dev
  maxConnections = 10
}

database {
  host = "localhost"
  port = 5432
  name = "myapp_dev"
  ssl = false
  poolSize = 5
}

features {
  newOnboarding = true  // Test new features in dev
  abTestPercentage = 100
}

logging {
  level = "debug"
  destination = "stdout"
}

// config/prod/config.pkl — Production configuration
amends "../base/base.pkl"

server {
  port = 8443
  tls = true
  tlsCertPath = "/etc/ssl/app/tls.crt"
  tlsKeyPath = "/etc/ssl/app/tls.key"
  maxConnections = 500
  timeoutSeconds = 15
}

database {
  host = "db-primary.internal.prod"
  port = 5432
  name = "myapp_prod"
  poolSize = 50
}

features {
  newOnboarding = false
  abTestPercentage = 10
  maintenanceMode = false
}

logging {
  level = "warn"
  destination = "both"
  filePath = "/var/log/myapp/app.log"
}
```

### Step 4: Generate and Verify

```bash
# Evaluate dev configuration (outputs JSON)
pkl eval config/dev/config.pkl -f json > config-dev.json

# Evaluate prod configuration (outputs YAML)
pkl eval config/prod/config.pkl -f yaml > config-prod.yaml

# Validate all configurations (catches type errors at build time)
for env in dev staging prod; do
  echo "Validating $env..."
  pkl eval config/$env/config.pkl -f json > /dev/null && echo "  PASS" || echo "  FAIL"
done

# Generate Kubernetes ConfigMap from Pkl
pkl eval config/prod/config.pkl -f yaml | \
  kubectl create configmap myapp-config --from-file=config.yaml=/dev/stdin --dry-run=client -o yaml
```

## CLAUDE.md for Pkl Configuration

```markdown
# Pkl Configuration Standards

## Domain Rules
- Schema modules define types and constraints (AppConfig.pkl)
- Base modules provide shared defaults (base/base.pkl)
- Environment modules amend base with overrides (prod/config.pkl)
- All string fields with known values use union types ("debug"|"info"|"warn")
- Numeric fields have range constraints via isBetween()
- Computed fields use hidden keyword
- Cross-field validation via hidden check properties with throw()

## File Patterns
- config/Schema.pkl (type definitions)
- config/base/*.pkl (shared base configuration)
- config/{dev,staging,prod}/*.pkl (environment overrides)
- PklProject (dependency management)
- PklProject.deps.json (dependency lock file)

## Common Commands
- pkl eval config.pkl -f json
- pkl eval config.pkl -f yaml
- pkl eval config.pkl -f plist
- pkl test tests/
- pkl project resolve (update dependencies)
- pkl doc config/ (generate documentation)
```

## Common Pitfalls in Pkl Configuration

- **Amend vs extend confusion:** `amends` creates a derived configuration from a base, while `extends` creates a new type. Claude Code uses `amends` for environment hierarchies and `extends` for schema inheritance.

- **Missing cross-field validation:** Pkl validates individual field types but cross-field constraints (e.g., TLS paths required when TLS enabled) need explicit hidden check properties. Claude Code adds these validation checks for every conditional dependency.

- **Pkl evaluation in CI:** Pkl configurations must be evaluated and validated in CI, not just syntax-checked. Claude Code adds a CI step that evaluates every environment configuration and fails on type errors or constraint violations.

## Related

- [Claude Code for Buf Protobuf Schema Management](/claude-code-buf-protobuf-schema-management-2026/)
- [Claude Code for Pulumi Infrastructure as Code](/claude-code-pulumi-infrastructure-as-code-2026/)
- [Claude Code for Ruff Python Linter Configuration](/claude-code-ruff-python-linter-configuration-2026/)


## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


## Best Practices

1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency.

2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed.

3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions.

4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops).

5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like "refactor auth, add tests, and update docs" produce better results when broken into three separate prompts, each building on the previous result.




**Set it up →** Build your permission config with our [Permission Configurator](/permissions/).

## Related Guides

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude SDK Timeout Configuration Guide](/claude-sdk-timeout-configuration-customization/)
- [Claude Code API Gateway Configuration](/claude-code-api-gateway-configuration-guide/)
- [Claude Code Dotfiles Configuration](/claude-code-dotfiles-configuration-management-workflow/)
- [Claude Code Debug Configuration](/claude-code-debug-configuration-workflow/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a CLAUDE.md file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring .claude/settings.json for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your .claude/ directory and CLAUDE.md to version control so the entire team uses the same configuration. Each developer can add personal preferences in ~/.claude/settings.json (user-level) without affecting the project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation."
      }
    }
  ]
}
</script>
