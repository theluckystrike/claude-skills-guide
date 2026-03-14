---
layout: default
title: "Claude Code Rust Crate Development Guide"
description: "A practical guide to developing Rust crates efficiently with Claude Code. Learn skill patterns, TDD workflows, and crate organization for productive Rust development."
date: 2026-03-14
categories: [guides]
tags: [claude-code, rust, crate-development, programming]
author: theluckystrike
permalink: /claude-code-rust-crate-development-guide/
---

# Claude Code Rust Crate Development Guide

Rust crate development benefits enormously from Claude Code when you structure your skills and workflows correctly. This guide shows you how to leverage Claude Code's capabilities specifically for Rust development, from initial crate setup through testing and publishing.

## Setting Up Rust Development Skills

Before starting any Rust project, ensure your Claude Code environment includes the right skills. The `tdd` skill is essential for test-driven development, while `pdf` becomes valuable when generating documentation. Create a `.claude/settings.local.md` that loads these skills for Rust projects:

```
Load the tdd skill for all Rust implementation tasks.
Load the doc skill when generating crate documentation.
```

The `tools` field in your skill configuration should include Bash (for cargo commands), Read, and Write. For Rust development specifically, add:

```yaml
---
name: rust-dev
description: Rust crate development workflow
tools:
  - Read
  - Write
  - Bash
---
```

This gives Claude access to cargo, rustc, and other essential Rust tooling.

## Crate Structure and Project Initialization

When initializing a new Rust crate, Claude Code can scaffold the entire project structure. Provide clear instructions about your intended crate type:

```
Create a new library crate called "async-cache" with:
- src/lib.rs as the main entry point
- src/error.rs for custom error types using thiserror
- src/cache.rs for the core caching implementation
- tests/ directory for integration tests
- examples/ directory with a basic usage example
- Cargo.toml with: MIT license, rust-version 1.70+, 
  dependencies: tokio, thiserror, serde
```

The `frontend-design` skill pattern translates well here—specifying exact file paths and naming conventions produces consistent results. After the initial scaffold, ask Claude to read Cargo.toml and verify the dependencies before proceeding.

## Test-Driven Development with the tdd Skill

The `tdd` skill excels at Rust development. Configure it specifically for cargo test workflows:

```
For Rust TDD workflow:
1. Write failing tests in tests/ or src/ with #[test] and #[cfg(test)]
2. Run: cargo test --lib (verify tests fail)
3. Implement the functionality in src/
4. Run: cargo test --lib (verify tests pass)
5. Run: cargo clippy (check for common Rust mistakes)
6. Run: cargo fmt (format code before completing)

Never skip clippy warnings. Fix them before moving on.
```

This pattern ensures your Rust code follows idiomatic patterns and avoids common pitfalls. The `tdd` skill's emphasis on failing tests first aligns perfectly with Rust's borrow checker—catching ownership errors early saves significant debugging time.

## Working with Dependencies

Rust's dependency management requires specific guidance for Claude Code. When adding dependencies:

```
When adding a dependency:
1. Search crates.io for the latest stable version
2. Add to Cargo.toml with: cargo add {package_name}
3. Run: cargo check (verify it compiles)
4. Read the crate documentation
5. Write a minimal usage example to verify understanding

For async crates, always use the Tokio runtime unless specified otherwise.
```

The `supermemory` skill can help you remember which crates you've used successfully in past projects, avoiding repeated research. Store crate recommendations and configuration patterns there for quick reference.

## Error Handling and Thiserror Patterns

Rust's error handling philosophy differs significantly from other languages. Guide Claude Code to use thiserror effectively:

```
For error types:
1. Use thiserror for library errors (enum with #[derive(thiserror::Error)])
2. Implement std::error::Error trait
3. Use #[source] for chained errors
4. Provide context with .context() from anyhow for application code

Example structure:
#[derive(Debug, thiserror::Error)]
pub enum CacheError {
    #[error("key not found: {0}")]
    KeyNotFound(String),
    #[error("serialization failed: {0}")]
    Serialization(#[from] serde_json::Error),
}
```

This produces errors that work well with Rust's ? operator and integrate cleanly with logging systems.

## Documentation Generation

The `pdf` skill becomes valuable when you need to export crate documentation. For generating documentation:

```
For crate documentation:
1. Run: cargo doc --no-deps --open (generate and preview)
2. Ensure all public APIs have doc comments (///)
3. Include usage examples in doc comments (/// # Examples)
4. Add README.md with: installation, basic usage, features list
5. For PDF export: convert the README to PDF using the pdf skill
```

Good documentation directly in the source code with `cargo doc` produces HTML documentation that you can then convert to PDF using the `pdf` skill for distribution.

## Performance and Benchmarking

Rust users care about performance. Guide Claude Code to include benchmarking:

```
For performance-critical code:
1. Write benchmarks in benches/ using criterion crate
2. Run: cargo bench (capture baseline numbers)
3. Implement the optimization
4. Run: cargo bench (verify improvement)
5. Document the performance characteristics in README

Always include worst-case time complexity in documentation.
```

The `tdd` skill's verification focus applies here—baseline benchmarks before optimization, then verification after.

## Publishing Crates

When ready to publish to crates.io:

```
Before publishing:
1. Run: cargo publish --dry-run
2. Verify: cargo test --all-features
3. Verify: cargo clippy --all-targets
4. Verify: cargo fmt --check
5. Update version in Cargo.toml following semver
6. Run: cargo publish

Ensure Cargo.toml includes:
- description (max 200 chars)
- license (valid SPDX identifier)
- repository URL
- documentation URL
```

## Common Rust Development Patterns

A few patterns specifically for Rust development with Claude Code:

**Module organization**: Use `mod.rs` files or the 2018+ module convention (`src/foo.rs` with `mod foo;` in parent). Specify your preference explicitly.

**Workspace management**: For multi-crate projects, provide the workspace structure:

```
This is a Cargo workspace with members:
- core/ (the core library)
- cli/ (command-line interface)
- macros/ (proc-macros)

Run commands from workspace root: cargo test -p core
```

**Feature flags**: Define features in Cargo.toml and test each combination:

```
Test these feature combinations:
- cargo test (default features only)
- cargo test --all-features (all features)
- cargo test --no-default-features (minimal build)
```

## Integrating with Other Skills

The Rust development workflow benefits from combining multiple skills. The `algorithmic-art` skill can visualize data structures when needed. The `docx` skill helps create formatted design documents. The `skill-creator` skill lets you build custom Rust-specific skills once and reuse them across projects.

For CI/CD integration, create a skill that runs the full check suite:

```
Rust CI check list (in order):
1. cargo fmt --check
2. cargo clippy --all-targets -- -D warnings
3. cargo test --all-features
4. cargo bench
5. cargo audit (check for vulnerabilities)

Fail the build on any step failure.
```

---

This workflow transforms Claude Code into an effective Rust development partner. The key is providing Rust-specific guidance that accounts for the language's unique features: the borrow checker, trait system, and cargo ecosystem. With the right skill configuration, you can achieve rapid development while maintaining Rust's high standards for correctness and performance.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
