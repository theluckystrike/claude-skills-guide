---
title: "Claude Code for mise Development Environment Setup (2026)"
permalink: /claude-code-mise-development-environment-2026/
description: "Set up polyglot dev environments with mise and Claude Code. Manage tool versions, environment variables, and project-scoped tasks in one config."
last_tested: "2026-04-22"
domain: "developer tooling"
render_with_liquid: false
---

## Why Claude Code for mise

mise (formerly rtx) replaces asdf, nvm, pyenv, rbenv, direnv, and Make with a single tool that manages language runtimes, environment variables, and project tasks. It activates the correct Node.js, Python, Go, and Rust versions when you enter a project directory and provides a task runner that replaces simple Makefiles. The challenge is configuring mise for polyglot projects that need multiple runtimes, per-environment secrets, and team-standardized tasks without conflicts.

Claude Code generates mise.toml configurations that pin exact tool versions, set up environment-specific variables, define project tasks that replace Makefiles, and configure IDE integration for seamless developer onboarding.

## The Workflow

### Step 1: Install mise

```bash
# Install mise
brew install mise  # macOS
# or: curl https://mise.run | sh

# Activate in shell
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc

# Verify
mise --version
```

### Step 2: Configure Project Environment

```toml
# mise.toml — Complete project configuration
[env]
# Project-wide environment variables
NODE_ENV = "development"
LOG_LEVEL = "debug"
DATABASE_URL = "postgresql://localhost:5432/myapp_dev"
REDIS_URL = "redis://localhost:6379"

# Template-based values
_.path = ["./node_modules/.bin", "./scripts"]
_.source = [".env.local"]  # Load additional env from file

[tools]
# Pin exact versions for reproducibility
node = "20.18.0"
python = "3.12.7"
go = "1.22.5"
rust = "1.82.0"

# Additional tools
pnpm = "9.12.0"
terraform = "1.9.8"
awscli = "2.22.0"
jq = "1.7.1"
ripgrep = "14.1.1"

# Override per-directory
[tools.python]
version = "3.12.7"
virtualenv = ".venv"  # Auto-create and activate venv

[tasks.setup]
description = "Initial project setup"
run = """
pnpm install
python -m pip install -r requirements.txt
docker compose up -d postgres redis
pnpm run db:migrate
echo "Setup complete!"
"""

[tasks.dev]
description = "Start development servers"
run = """
mise run dev:api & mise run dev:web & wait
"""

[tasks."dev:api"]
description = "Start API server"
dir = "services/api"
run = "go run ./cmd/server"
env = { PORT = "8080" }

[tasks."dev:web"]
description = "Start web frontend"
dir = "apps/web"
run = "pnpm dev"
env = { PORT = "3000" }

[tasks.test]
description = "Run all tests"
run = """
echo "=== Go tests ==="
cd services/api && go test ./... -count=1
echo "=== Python tests ==="
cd python && python -m pytest -q
echo "=== JS tests ==="
pnpm test
"""

[tasks.lint]
description = "Lint all code"
run = """
cd services/api && golangci-lint run
cd python && ruff check .
pnpm biome ci .
"""

[tasks.build]
description = "Build all services"
depends = ["lint", "test"]
run = """
cd services/api && go build -o bin/api ./cmd/server
cd apps/web && pnpm build
"""

[tasks."db:migrate"]
description = "Run database migrations"
run = "cd services/api && go run ./cmd/migrate up"

[tasks."db:reset"]
description = "Reset database (DESTRUCTIVE)"
run = """
dropdb --if-exists myapp_dev
createdb myapp_dev
mise run db:migrate
echo "Database reset complete"
"""

[tasks.clean]
description = "Clean build artifacts"
run = """
rm -rf services/api/bin
rm -rf apps/web/.next apps/web/dist
rm -rf python/.venv
find . -name '__pycache__' -exec rm -rf {} +
echo "Clean complete"
"""
```

### Step 3: Environment-Specific Overrides

```toml
# mise.staging.toml — Staging overrides
[env]
NODE_ENV = "staging"
LOG_LEVEL = "info"
DATABASE_URL = "{{env.STAGING_DATABASE_URL}}"

[tasks."deploy:staging"]
description = "Deploy to staging"
run = """
mise run build
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_REPO
docker build -t $ECR_REPO:staging-$(git rev-parse --short HEAD) .
docker push $ECR_REPO:staging-$(git rev-parse --short HEAD)
kubectl set image deployment/api api=$ECR_REPO:staging-$(git rev-parse --short HEAD) -n staging
"""
```

### Step 4: Verify

```bash
# Check installed tools
mise ls

# Run setup task
mise run setup

# Start development
mise run dev

# Run specific task
mise run test

# List all available tasks
mise tasks

# Check which tools would be installed
mise install --dry-run

# Trust the config file (first time in repo)
mise trust
```

## CLAUDE.md for mise Development Environment

```markdown
# mise Development Environment Standards

## Domain Rules
- mise.toml in project root (not .tool-versions for new projects)
- Pin exact versions for all tools (no ranges)
- Use tasks for all common workflows (replace Makefile)
- Task dependencies via depends = ["lint", "test"]
- Environment variables in [env] section, secrets in .env.local (gitignored)
- Per-directory tool overrides for polyglot projects
- All team members use mise (documented in CONTRIBUTING.md)

## File Patterns
- mise.toml (main configuration)
- mise.staging.toml, mise.production.toml (environment overrides)
- .env.local (secrets, gitignored)
- .mise.toml (alternative name for older versions)

## Common Commands
- mise install (install all tools)
- mise run TASK (run a task)
- mise tasks (list available tasks)
- mise ls (show installed tools)
- mise use node@20 (update tool version)
- mise trust (trust config after clone)
- mise env (show environment variables)
- mise doctor (diagnose issues)
```

## Common Pitfalls in mise Setup

- **Forgetting mise trust on clone:** mise requires explicit trust for each project's config to prevent malicious configs from running arbitrary code. Claude Code adds `mise trust` to the project setup documentation and CI scripts.

- **Shell activation not configured:** mise must be activated in the shell profile (.zshrc/.bashrc) to auto-switch tool versions on directory change. Claude Code verifies shell integration and adds it to onboarding documentation.

- **Python virtualenv conflicts:** mise can manage Python versions and virtual environments, but conflicts with pyenv or manually created venvs. Claude Code configures mise as the sole Python version manager and sets `virtualenv = ".venv"` in tools.python.

## Related

- [Claude Code for Ruff Python Linter Configuration](/claude-code-ruff-python-linter-configuration-2026/)
- [Claude Code for Biome Formatter Setup](/claude-code-biome-formatter-setup-2026/)
- [Claude Code for Earthly CI Pipeline](/claude-code-earthly-ci-pipeline-2026/)
