---
title: "Claude Code for Bazel Build System (2026)"
permalink: /claude-code-bazel-build-system-2026/
description: "Configure Bazel builds with Claude Code. Write BUILD files, manage external dependencies with bzlmod, and optimize remote execution caching."
last_tested: "2026-04-22"
domain: "build systems"
---

## Why Claude Code for Bazel

Bazel is Google's open-source build system for multi-language monorepos at massive scale. It guarantees hermetic, reproducible builds with fine-grained caching and remote execution. But Bazel has the steepest learning curve of any build tool: writing BUILD files with correct visibility and deps, managing external dependencies through bzlmod, configuring toolchains for cross-compilation, and setting up remote build execution (RBE). Most teams spend weeks getting their first Bazel build working correctly.

Claude Code generates BUILD files with correct dependency declarations, configures bzlmod for external dependencies, writes custom Starlark rules when needed, and sets up remote caching that slashes CI times from hours to minutes.

## The Workflow

### Step 1: Initialize Bazel Project

```bash
# Install Bazel via Bazelisk (version manager)
brew install bazelisk  # macOS
# or: npm install -g @bazel/bazelisk

# Create MODULE.bazel (replaces WORKSPACE for bzlmod)
touch MODULE.bazel BUILD.bazel .bazelrc .bazelversion
echo "7.4.0" > .bazelversion
```

### Step 2: Configure Multi-Language Build

```python
# MODULE.bazel — External dependency management via bzlmod
module(
    name = "my_project",
    version = "0.1.0",
)

# Rules for each language
bazel_dep(name = "rules_go", version = "0.50.1")
bazel_dep(name = "rules_python", version = "0.36.0")
bazel_dep(name = "rules_proto", version = "6.0.2")
bazel_dep(name = "rules_pkg", version = "1.0.1")
bazel_dep(name = "rules_oci", version = "2.0.0")  # Container images

# Go SDK
go_sdk = use_extension("@rules_go//go:extensions.bzl", "go_sdk")
go_sdk.download(version = "1.22.5")

# Go dependencies from go.mod
go_deps = use_extension("@gazelle//:extensions.bzl", "go_deps")
go_deps.from_file(go_mod = "//:go.mod")
use_repo(go_deps, "com_github_gin_gonic_gin", "org_golang_google_grpc")

# Python toolchain
python = use_extension("@rules_python//python/extensions:python.bzl", "python")
python.toolchain(python_version = "3.12")

# Python pip dependencies
pip = use_extension("@rules_python//python/extensions:pip.bzl", "pip")
pip.parse(
    hub_name = "pip",
    python_version = "3.12",
    requirements_lock = "//python:requirements_lock.txt",
)
use_repo(pip, "pip")
```

```python
# services/api/BUILD.bazel — Go API service
load("@rules_go//go:def.bzl", "go_binary", "go_library", "go_test")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_push")
load("@rules_pkg//pkg:tar.bzl", "pkg_tar")

go_library(
    name = "api_lib",
    srcs = glob(["*.go"], exclude = ["*_test.go"]),
    importpath = "github.com/myorg/myproject/services/api",
    visibility = ["//visibility:private"],
    deps = [
        "//internal/auth",
        "//internal/database",
        "//proto/api/v1:api_go_proto",
        "@com_github_gin_gonic_gin//:gin",
        "@org_golang_google_grpc//:grpc",
    ],
)

go_binary(
    name = "api",
    embed = [":api_lib"],
    visibility = ["//visibility:public"],
)

go_test(
    name = "api_test",
    srcs = glob(["*_test.go"]),
    embed = [":api_lib"],
    deps = [
        "@com_github_stretchr_testify//assert",
        "@com_github_stretchr_testify//require",
    ],
)

# Container image
pkg_tar(
    name = "api_layer",
    srcs = [":api"],
)

oci_image(
    name = "api_image",
    base = "@distroless_base",
    tars = [":api_layer"],
    entrypoint = ["/api"],
    exposed_ports = ["8080/tcp"],
)

oci_push(
    name = "push_api",
    image = ":api_image",
    repository = "myregistry/api",
)
```

```python
# python/ml/BUILD.bazel — Python ML pipeline
load("@rules_python//python:defs.bzl", "py_binary", "py_library", "py_test")
load("@pip//:requirements.bzl", "requirement")

py_library(
    name = "ml_lib",
    srcs = glob(["*.py"], exclude = ["*_test.py", "main.py"]),
    visibility = ["//python:__subpackages__"],
    deps = [
        requirement("numpy"),
        requirement("pandas"),
        requirement("scikit-learn"),
        "//python/common:utils",
    ],
)

py_binary(
    name = "train",
    srcs = ["main.py"],
    main = "main.py",
    deps = [":ml_lib"],
)

py_test(
    name = "ml_test",
    srcs = glob(["*_test.py"]),
    deps = [
        ":ml_lib",
        requirement("pytest"),
    ],
)
```

### Step 3: Configure Remote Caching

```bash
# .bazelrc — Build configuration
# Remote cache (BuildBuddy, Google RBE, or custom)
build:ci --remote_cache=grpcs://remote.buildbuddy.io
build:ci --remote_header=x-buildbuddy-api-key=YOUR_KEY
build:ci --remote_upload_local_results=true

# Common settings
build --incompatible_strict_action_env
build --enable_bzlmod
test --test_output=errors
test --test_summary=terse

# Performance
build --jobs=auto
build --experimental_remote_merkle_tree_cache
fetch --experimental_remote_downloader=grpcs://remote.buildbuddy.io

# Stamping for release builds
build:release --stamp
build:release --workspace_status_command=./tools/workspace_status.sh
```

### Step 4: Verify

```bash
# Build everything
bazel build //...

# Test everything
bazel test //...

# Build specific target
bazel build //services/api:api

# Query dependency graph
bazel query 'deps(//services/api:api)' --output=graph | dot -Tpng > deps.png

# Check what changed (affected targets)
bazel query 'rdeps(//..., set($(git diff --name-only HEAD~1)))' 2>/dev/null

# Run with remote cache
bazel build //... --config=ci
```

## CLAUDE.md for Bazel Build System

```markdown
# Bazel Build System Standards

## Domain Rules
- Use bzlmod (MODULE.bazel) not WORKSPACE for dependencies
- Every directory with source files needs a BUILD.bazel file
- Visibility: private by default, explicit public for shared libraries
- Use Gazelle for Go BUILD file generation
- Remote cache for all CI builds
- Hermetic toolchains: never depend on host-installed tools
- Pin all external dependency versions

## File Patterns
- MODULE.bazel (external dependencies)
- BUILD.bazel (per-directory build rules)
- .bazelrc (build configuration flags)
- .bazelversion (Bazel version pin)
- tools/ (custom Starlark rules and macros)

## Common Commands
- bazel build //...
- bazel test //...
- bazel run //services/api:api
- bazel query 'deps(//target)'
- bazel query 'rdeps(//..., //changed:target)'
- bazel clean --expunge
- bazel fetch //...
- bazelisk (auto-downloads correct Bazel version)
```

## Common Pitfalls in Bazel Configuration

- **Missing deps cause non-hermetic builds:** Bazel builds in a sandbox, so every dependency must be explicitly declared. Claude Code uses `bazel query` to detect undeclared dependencies that work locally but fail in CI.

- **Gazelle drift for Go projects:** Gazelle generates BUILD files from Go imports, but manual edits get overwritten. Claude Code adds `# keep` comments on manually managed rules and configures Gazelle directives properly.

- **Remote cache key pollution:** Different Bazel versions, host OS, or env variables produce different cache keys. Claude Code configures `--incompatible_strict_action_env` and pins toolchain versions to maximize cache hit rates.

## Related

- [Claude Code for Earthly CI Pipeline](/claude-code-earthly-ci-pipeline-2026/)
- [Claude Code for Nx Workspace Orchestration](/claude-code-nx-workspace-orchestration-2026/)
- [Claude Code for Turborepo Monorepo Management](/claude-code-turborepo-monorepo-management-2026/)
- [Claude Code for Order Management Systems (2026)](/claude-code-order-management-system-2026/)
- [Circular Dependency Detected in Build — Fix (2026)](/claude-code-circular-dependency-detected-build-fix-2026/)
- [Claude Code for Ada Legacy System Updates (2026)](/claude-code-ada-legacy-system-updates-2026/)
- [Claude Code for Trading System Backtesting (2026)](/claude-code-trading-system-backtesting-2026/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


## Related Guides

- [Terminal Emulator Rendering Artifacts — Fix (2026)](/claude-code-terminal-rendering-artifacts-fix-2026/)
- [How to Use Thirdweb SDK Workflow (2026)](/claude-code-for-thirdweb-sdk-workflow-tutorial/)
- [Python Virtualenv Not Activated Fix — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Claude Code Offline Mode Setup (2026)](/best-way-to-use-claude-code-offline-without-internet-access/)

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json. When working with Claude Code on this topic, keep these implementation details in mind: **Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations. **Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code. **Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%. **Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results."
      }
    }
  ]
}
</script>
