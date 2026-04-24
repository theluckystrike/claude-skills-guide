---
title: "CLAUDE.md Example for Flutter + Dart +"
description: "Complete 310-line CLAUDE.md for Flutter 3.27 with Riverpod 2.6."
permalink: /claude-md-example-for-flutter-dart-riverpod/
render_with_liquid: false
categories: [claude-md, templates, 2026]
tags: [claude-code, claude-md, flutter, dart, riverpod]
last_updated: 2026-04-19
---

## What This Template Does

This CLAUDE.md configures Claude Code for Flutter 3.27 applications with Dart 3.6, Riverpod 2.6 for state management, freezed for immutable models, and go_router for navigation. It prevents Claude from using `setState` for anything beyond local widget state, enforces proper Riverpod provider patterns, and ensures code generation with build_runner is used correctly. The template covers feature-first architecture, Drift database patterns, and widget testing conventions. Tested against production apps with 50+ screens across iOS, Android, and web platforms.

## The Complete Template

{% raw %}
```markdown
# CLAUDE.md — Flutter 3.27 + Dart 3.6 + Riverpod

## Project Stack

- Flutter 3.27.2
- Dart 3.6.1
- Riverpod 2.6.1 (flutter_riverpod + riverpod_annotation + riverpod_generator)
- freezed 2.5.7 (immutable data classes)
- go_router 14.6.2 (declarative routing)
- Drift 2.22.1 (SQLite ORM with type-safe queries)
- Dio 5.7.0 (HTTP client)
- json_serializable 6.8.0 (JSON serialization)
- build_runner 2.4.13 (code generation)
- Flutter Hooks 0.20.5 (widget lifecycle hooks)
- Mocktail 1.0.4 (testing mocks)
- Very Good Analysis 6.0.0 (lint rules)

## Build & Dev Commands

- Run: `flutter run`
- Run web: `flutter run -d chrome`
- Build APK: `flutter build apk --release`
- Build iOS: `flutter build ios --release`
- Build web: `flutter build web --release`
- Test: `flutter test`
- Test single: `flutter test test/features/auth/auth_controller_test.dart`
- Test coverage: `flutter test --coverage && genhtml coverage/lcov.info -o coverage/html`
- Code gen: `dart run build_runner build --delete-conflicting-outputs`
- Code gen watch: `dart run build_runner watch --delete-conflicting-outputs`
- Analyze: `dart analyze`
- Format: `dart format .`
- Fix: `dart fix --apply`
- Clean: `flutter clean && flutter pub get`
- Pub get: `flutter pub get`
- Upgrade deps: `flutter pub upgrade --major-versions`

## Project Layout

```
lib/
  main.dart                      # Entry: ProviderScope → App
  app.dart                       # MaterialApp.router with go_router
  features/
    auth/
      data/
        auth_repository.dart     # Repository implementation
        auth_api.dart            # Dio API calls
        models/
          user_model.dart        # @freezed user model
          user_model.g.dart      # Generated JSON serialization
          user_model.freezed.dart # Generated freezed code
      domain/
        auth_repository.dart     # Repository abstract class
        entities/
          user.dart              # Domain entity (plain class)
      presentation/
        login_screen.dart        # Screen widget
        signup_screen.dart
        widgets/
          login_form.dart        # Feature-specific widget
        controllers/
          auth_controller.dart   # @riverpod controller
          auth_controller.g.dart # Generated Riverpod code
    home/
      presentation/
        home_screen.dart
      data/
      domain/
  core/
    router/
      app_router.dart            # go_router configuration
      routes.dart                # Route path constants
    theme/
      app_theme.dart             # ThemeData configuration
      colors.dart                # Color constants
      text_styles.dart           # TextStyle definitions
    network/
      dio_client.dart            # Dio instance with interceptors
      api_interceptor.dart       # Auth token interceptor
      error_interceptor.dart     # Error mapping interceptor
    database/
      app_database.dart          # Drift database definition
      app_database.g.dart        # Generated Drift code
    providers/
      shared_providers.dart      # App-wide providers (Dio, DB, etc.)
    widgets/
      loading_widget.dart        # Shared loading indicator
      error_widget.dart          # Shared error display
      app_button.dart            # Design system button
    extensions/
      context_extensions.dart    # BuildContext extensions
      string_extensions.dart     # String extensions
    utils/
      validators.dart            # Form validators
      constants.dart             # App constants
    l10n/
      app_en.arb                 # English strings
      app_localizations.dart     # Generated localization
test/
  features/
    auth/
      auth_controller_test.dart  # Controller/provider tests
      auth_repository_test.dart  # Repository tests
    home/
  core/
    router/
      app_router_test.dart
  helpers/
    test_helpers.dart            # Shared test utilities
    pump_app.dart                # Widget test helper (wraps with providers)
```

## Architecture Rules

- Feature-first folder structure. Each feature in `lib/features/` with `data/`, `domain/`, `presentation/` layers.
- Clean Architecture layers: Presentation (widgets, controllers) → Domain (entities, repository interfaces) → Data (API, database, repository implementations).
- Riverpod for all state management. No `setState` except for local ephemeral widget state (text field focus, animation controllers).
- `@riverpod` annotation on controller classes. Code-generated providers via `riverpod_generator`. Never manually create `StateNotifierProvider` or `ChangeNotifierProvider`.
- Providers are the dependency injection mechanism. No service locator (get_it). No manual dependency passing through constructors across the widget tree.
- `go_router` for navigation. Declarative route configuration. `context.go()` for navigation, `context.push()` for stack navigation. No `Navigator.push`.
- `freezed` for all data models. Immutable, with `copyWith`, `toJson`/`fromJson`, union types for sealed classes.
- `build_runner` for code generation. Run after model or provider changes. Generated files: `*.g.dart`, `*.freezed.dart`.
- Feature modules must not import from other features directly. Shared code in `lib/core/`.
- Domain layer has no Flutter dependencies. Pure Dart classes and abstract interfaces.

## Coding Conventions

- Dart 3.6: records, patterns, sealed classes, class modifiers (`final class`, `interface class`).
- Very Good Analysis lint rules. Zero lint warnings. Fix all analyzer issues before commit.
- Naming: `UpperCamelCase` for types and extensions, `lowerCamelCase` for variables/functions/parameters, `SCREAMING_CAPS` for constants.
- File naming: `snake_case.dart`. One primary class per file. Widget files match widget name.
- Widget types: `StatelessWidget` for pure UI. `HookWidget` (flutter_hooks) for lifecycle management. `ConsumerWidget` for Riverpod-connected widgets.
- Private members: prefix with `_`. Private classes, methods, variables all use underscore prefix.
- Immutable by default: use `final` on all variable declarations unless mutation is required. Use `const` constructors where possible.
- `const` widgets: mark widget constructors as `const` when all fields are `final` and the widget takes no mutable state. Flutter optimizes const widget rebuilds.
- Trailing commas on all function calls and widget constructors with multiple arguments. Enables better dart format output.
- Widget tree: max 5 levels of nesting in a single `build()` method. Extract sub-widgets at 5+ levels.
- Extension methods for reusable utility on built-in types. Place in `lib/core/extensions/`.
- Prefer named parameters for functions with 2+ parameters. Use `required` for non-optional named params.
- Null safety: fully sound. No `!` operator in production code. Use `?.`, `??`, `if-case let`, or pattern matching.
- Imports: `dart:` first, `package:` second, relative imports third. Prefer `package:` imports over relative.
- No print statements. Use `debugPrint()` for development, or logging package for structured logs.
- Comments: `///` doc comments on public APIs. `//` for implementation notes. `// TODO(name):` for todos.

## Error Handling

- `AsyncValue<T>` from Riverpod for async state. Three states: `.data(value)`, `.loading()`, `.error(error, stack)`.
- UI: `ref.watch(provider).when(data: ..., loading: ..., error: ...)` pattern for rendering async states.
- Network errors: Dio interceptor catches `DioException`. Maps to `AppException` sealed class: `.network()`, `.server(statusCode, message)`, `.unauthorized()`, `.timeout()`.
- Repository layer: catches data-layer exceptions, maps to domain-specific errors.
- Controller layer: errors propagated through `AsyncValue.error`. UI displays error widget with retry callback.
- Form validation: `TextFormField` with `validator` callback. Return null for valid, error string for invalid.
- Snackbar for transient errors: `ScaffoldMessenger.of(context).showSnackBar(...)`. Controller exposes one-shot error events.
- Never catch generic `Exception`. Catch specific types: `DioException`, `DatabaseException`, `FormatException`.
- Crash reporting: Firebase Crashlytics in `FlutterError.onError` and `PlatformDispatcher.instance.onError`.
- Stack traces: always capture with `StackTrace.current` or from catch block. Pass to error reporting.

## Testing Conventions

- Widget tests: `testWidgets("description", (tester) async { ... })`. Pump widget with `pumpApp()` helper that wraps in `ProviderScope`.
- Controller/provider tests: use `ProviderContainer()` with overrides. Test state transitions.
- Repository tests: mock API with Mocktail. Assert repository transforms API responses to domain models.
- Mock pattern: `class MockUserRepository extends Mock implements UserRepository {}`. Configure with `when(() => mock.method()).thenReturn(value)`.
- Golden tests: `matchesGoldenFile('goldens/login_screen.png')` for visual regression. Update with `--update-goldens`.
- Integration tests: `flutter test integration_test/app_test.dart`. Test critical user flows end-to-end.
- Test naming: `test("should return user when login succeeds", () { ... })`.
- Provider testing: `container.read(authControllerProvider.notifier).login(email, password)`. Assert state changes.
- No `setUp` with side effects. Each test creates its own container and mocks.
- Coverage: 90% for controllers, 85% for repositories, 70% for widgets. Exclude generated files from coverage.

## Database & API Patterns

- Drift for SQLite: type-safe queries generated from Dart table definitions. Run `build_runner` after schema changes.
- Drift tables: Dart classes extending `Table`. Columns defined as getters: `TextColumn get name => text()()`.
- Drift queries: generated methods on database class. Custom queries with `@DriftAccessor`.
- API client: Dio with `BaseOptions(baseUrl, connectTimeout, receiveTimeout)`. Interceptors for auth token and error handling.
- API response: `ApiResponse<T>` wrapper with `data`, `message`, `meta` fields. JSON deserialized with `json_serializable`.
- Offline-first: Drift as source of truth. API syncs update local database. UI reads from Drift streams.
- Pagination: `FutureProvider.family((ref, page) => ...)` for paginated API calls. Infinite scroll with `ScrollController.addListener`.
- Image caching: `cached_network_image` for network images. Placeholder and error widgets.

## What Claude Should Never Do

- Never use `setState` for state that outlives a single widget or is shared between widgets. Use Riverpod providers.
- Never manually write `StateNotifierProvider` or `ChangeNotifierProvider`. Use `@riverpod` annotation with code generation.
- Never use `Navigator.push()` or `MaterialPageRoute`. Use `go_router` with `context.go()` or `context.push()`.
- Never use `get_it` or any service locator. Riverpod is the dependency injection mechanism.
- Never use `!` (null assertion) in production code. Handle nullability with `?.`, `??`, pattern matching, or `if-case`.
- Never create mutable data models. Use `@freezed` for immutable models with `copyWith`.
- Never edit generated files (`*.g.dart`, `*.freezed.dart`). Modify the source and re-run `build_runner`.
- Never use `BuildContext` after async gaps without checking `mounted`. Context may be invalid after await.
- Never import from one feature into another feature. Shared code belongs in `lib/core/`.
- Never use `print()`. Use `debugPrint()` for development output.
- Never skip trailing commas on multi-argument constructors and function calls.
- Never use `dynamic` type. Use `Object?` or define proper types.

## Project-Specific Context

- [YOUR APP NAME] — update with your project details
- Target platforms: iOS, Android, [Web / macOS / Windows / Linux]
- Backend: [REST API / Firebase / Supabase / Appwrite]
- Analytics: [Firebase Analytics / Amplitude / Mixpanel]
- Crash reporting: Firebase Crashlytics
- Push notifications: Firebase Cloud Messaging
- Distribution: [Google Play / App Store / TestFlight / Firebase App Distribution]
- CI/CD: [GitHub Actions / Codemagic / Bitrise] → Store upload
```
{% endraw %}

## How to Adapt This For Your Project

Start with the **Project Stack** section and match versions from your `pubspec.yaml`. If you use Bloc instead of Riverpod, replace the state management patterns — Bloc uses `Cubit`/`Bloc` classes with `BlocProvider` instead of Riverpod's `@riverpod` annotation. If you do not use code generation (no freezed, no riverpod_generator), remove the `build_runner` references and write providers manually. The feature-first folder structure and Clean Architecture layers are the highest-value sections — they prevent Claude from creating a flat folder structure that becomes unmanageable past 20 screens.

## Common CLAUDE.md Mistakes in Flutter Projects

1. **Not specifying the state management library.** Flutter has 10+ state management options. Without declaring Riverpod, Claude may generate `setState`, `Provider`, `Bloc`, or `GetX` patterns randomly depending on its training data.

2. **Allowing `setState` for shared state.** Claude uses `setState` because it is the simplest approach. Without explicit rules, it creates stateful widgets that manage API data, authentication state, and form state locally instead of in providers.

3. **Missing build_runner workflow.** Claude edits generated files (`*.g.dart`, `*.freezed.dart`) directly instead of modifying the source files and re-running code generation. Specify that generated files must never be edited manually.

4. **Using `Navigator.push` instead of go_router.** Claude defaults to imperative navigation because it has more training examples. Without explicit `go_router` rules, you get a mix of navigation approaches that are impossible to deep-link.

5. **Not requiring immutable models.** Claude creates mutable Dart classes for data models, which leads to state mutation bugs. Freezed models with `copyWith` prevent accidental mutation.

## What Claude Code Does With This

With this CLAUDE.md loaded, Claude Code generates feature-first folder structures with Clean Architecture layers. State management uses `@riverpod` annotated controllers with code generation. Data models use `@freezed` for immutability. Navigation uses `go_router` with `context.go()`. API calls go through Dio with proper error handling interceptors. Async state renders with `AsyncValue.when()` for loading/data/error states. Widget tests use `ProviderScope` with mock overrides. Generated files are never touched directly.

## The Full 16-Template Pack

This is one of 16 production CLAUDE.md templates available in the Lifetime pack. Includes templates for Android + Kotlin, iOS + SwiftUI, React Native + Expo, Next.js + TypeScript, and 11 more stacks. Each template is 200-400 lines of production-tested configuration. Get all 16 at [claudecodeguides.com/generator/](https://claudecodeguides.com/generator/).
