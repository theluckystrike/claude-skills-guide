---
layout: default
title: "Claude Code for Kotlin Multiplatform"
description: "Share code across platforms with KMP and Claude Code. Tested setup with copy-paste CLAUDE.md config."
date: 2026-04-18
permalink: /claude-code-for-kotlin-multiplatform-workflow-guide/
render_with_liquid: false
categories: [workflow, niche-tools]
tags: [claude-code, kotlin-multiplatform, workflow]
---

## The Setup

You are building cross-platform applications with Kotlin Multiplatform (KMP), which lets you share business logic between Android, iOS, web, and desktop from a single Kotlin codebase. KMP uses expect/actual declarations for platform-specific code and shares common code through multiplatform modules. Claude Code can write Kotlin, but it generates Android-only code instead of multiplatform-compatible shared code.

## What Claude Code Gets Wrong By Default

1. **Uses Android-specific APIs in shared code.** Claude imports `android.content.Context` and `android.util.Log` in shared modules. Shared code must use only Kotlin standard library and multiplatform libraries — Android APIs go in the `androidMain` source set only.

2. **Ignores the expect/actual pattern.** Claude writes platform-specific implementations directly. KMP uses `expect` declarations in `commonMain` and `actual` implementations in each platform source set (`androidMain`, `iosMain`, etc.).

3. **Creates separate projects per platform.** Claude generates independent Android and iOS projects with duplicated logic. KMP uses a single project with shared modules — the `shared` module contains common code used by both platforms.

4. **Uses JVM-only libraries in shared code.** Claude adds Retrofit, Room, or Gson to shared modules. These are JVM-only libraries. KMP uses multiplatform alternatives: Ktor for networking, SQLDelight for database, and kotlinx.serialization for JSON.

## The CLAUDE.md Configuration

```
# Kotlin Multiplatform Project

## Architecture
- Framework: Kotlin Multiplatform (KMP)
- Shared: commonMain for cross-platform code
- Platform: androidMain, iosMain, jvmMain, jsMain
- Pattern: expect/actual for platform-specific code

## KMP Rules
- Shared code: only Kotlin stdlib + multiplatform libraries
- Networking: Ktor (not Retrofit)
- Database: SQLDelight (not Room)
- Serialization: kotlinx.serialization (not Gson)
- DI: Koin multiplatform (not Dagger/Hilt)
- Async: kotlinx.coroutines (shared across platforms)
- expect/actual for platform-specific implementations

## Conventions
- shared/src/commonMain/ for shared business logic
- shared/src/androidMain/ for Android-specific code
- shared/src/iosMain/ for iOS-specific code
- Use interfaces in commonMain, implementations per platform
- Gradle: kotlin("multiplatform") plugin
- iOS: shared module exported as framework
- Test: commonTest for shared tests
```

## Workflow Example

You want to create a shared networking layer for Android and iOS. Prompt Claude Code:

"Create a KMP shared networking module using Ktor that fetches user profiles from a REST API. Use kotlinx.serialization for JSON parsing. Add expect/actual for platform-specific HTTP engines (OkHttp for Android, Darwin for iOS)."

Claude Code should create the data class in `commonMain` with `@Serializable`, the API client using `HttpClient` with expect/actual for the engine, `OkHttp` engine in `androidMain`, and `Darwin` engine in `iosMain`, with all network calls using coroutines.

## Common Pitfalls

1. **iOS framework not exporting properly.** Claude creates shared code but iOS cannot access it. The shared module must be configured with `framework { baseName = "shared" }` in the iOS target, and the Xcode project must reference the generated framework.

2. **Coroutine scope issues on iOS.** Claude uses `GlobalScope.launch` in shared code. On iOS, coroutines need proper scope management. Use `MainScope()` for iOS or inject a coroutine scope from the platform to avoid memory leaks.

3. **Gradle configuration complexity.** Claude creates a simple `build.gradle.kts` without the required multiplatform source set hierarchy. KMP Gradle configuration needs explicit target declarations, source set dependencies, and framework configuration for each platform.

## Related Guides

- [Best AI Tools for Backend Development 2026](/best-ai-tools-for-backend-development-2026/)
- [Claude Code API Authentication Patterns Guide](/claude-code-api-authentication-patterns-guide/)
- [Best Way to Set Up Claude Code for New Project](/best-way-to-set-up-claude-code-for-new-project/)
