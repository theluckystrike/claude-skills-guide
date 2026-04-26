---
layout: default
title: "Claude Md Example For Flutter Mobile (2026)"
description: "Practical guide to creating Claude skill files for Flutter mobile apps. Includes real examples, code patterns, and integration tips for cross-platform."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-md-example-for-flutter-mobile-application/
categories: [guides]
tags: [claude-code, flutter, mobile-development, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---
Creating effective Claude skill files for Flutter mobile applications requires understanding both the skill format and how Claude Code processes cross-platform development workflows. This guide provides practical examples you can adapt immediately for building Flutter apps with Dart.

## The Claude Skill Format

Claude skills are Markdown files with a specific structure that Claude reads when you invoke them. For Flutter projects, these skills help Claude understand your tooling, state management approach, and preferred development practices.

A basic skill file follows this structure:

```markdown
Skill Name

Description
Brief description of what this skill does.

When to Use
Situations where this skill applies.

Guidelines
- Specific instruction 1
- Specific instruction 2
```

The skill loads when you type `/skillname` in Claude Code, making these instructions part of the AI's context for your session.

## Flutter App Architecture Skill

For a Flutter project using BLoC pattern and Clean Architecture, create a skill that guides Claude through your preferred patterns. Save this as `~/.claude/skills/flutter-app.md`:

```markdown
flutter-app

Description
Guides Claude through Flutter development following BLoC pattern and Clean Architecture principles.

When to Use
- Creating new screens or features
- Implementing BLoC for state management
- Setting up dependency injection with GetIt
- Working with Riverpod providers
- Implementing widget tests

Guidelines

Project Structure
- Follow Clean Architecture: presentation → domain → data layers
- Place BLoCs in presentation layer with events and states
- Use repository pattern for data access
- Keep domain layer free of Flutter dependencies

Dart Conventions
- Use data classes for models and DTOs
- Implement sealed classes for BLoC states and events
- Prefer immutability with freezed
- Use async/await for asynchronous operations

Flutter Widgets
- Use const constructors where possible
- Implement proper widget keys for testing
- Create reusable widget components
- Follow Material Design 3 guidelines
```

This skill file teaches Claude about your Flutter architecture preferences automatically.

## Flutter Testing Skill

Create a separate skill for testing workflows:

```markdown
flutter-testing

Description
Guides Claude through Flutter testing patterns including unit tests, widget tests, and integration tests.

When to Use
- Writing tests for BLoCs and business logic
- Creating widget tests for custom components
- Setting up integration tests
- Debugging test failures

Guidelines

Unit Tests
- Test one thing per test method
- Use arrange-act-assert pattern
- Mock external dependencies with mocktail
- Test edge cases and error states

Widget Tests
- Use WidgetTester for pump and settle
- Find widgets by key, not by text
- Test user interactions with tap, swipe, enter text
- Verify state changes after interactions

Integration Tests
- Use flutter_test for widget tests
- Use integration_test for end-to-end flows
- Set up mock servers for API testing
- Clear app state between tests
```

## Flutter State Management Skill

Different projects use different state management solutions. Create a skill that matches your stack:

```markdown
flutter-riverpod

Description
Guides Claude through Flutter development with Riverpod for state management.

When to Use
- Creating providers for data fetching
- Implementing StateNotifier for complex state
- Setting up AsyncValue for loading/error states
- Organizing providers in a hierarchy

Guidelines

Provider Types
- Use Provider for dependency injection
- Use FutureProvider for async data
- Use StreamProvider for real-time data
- Use StateNotifierProvider for complex state
- Use ref.watch for reactive updates

Code Patterns
- Keep providers in dedicated files
- Use Family providers for parameterized providers
- Implement proper error handling
- Use select() to minimize rebuilds
```

## Combining Skills for Flutter Projects

You can load multiple skills for comprehensive Flutter development guidance. For a production Flutter app, invoke each skill in your Claude Code session:

```
/flutter-app
/flutter-testing
/flutter-riverpod
```

This combines architecture guidelines, testing patterns, and state management preferences in one session.

## Practical Example: Building a Feature

When you create a new feature in your Flutter app, your skill file ensures Claude generates consistent code. For instance, a request for a user profile screen might produce:

```dart
// lib/presentation/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_event.dart';
part 'profile_state.dart';
part 'profile_bloc.dart';

class ProfileScreen extends StatelessWidget {
 const ProfileScreen({super.key});

 @override
 Widget build(BuildContext context) {
 return BlocBuilder<ProfileBloc, ProfileState>(
 builder: (context, state) {
 return state.when(
 initial: () => const Center(child: CircularProgressIndicator()),
 loading: () => const Center(child: CircularProgressIndicator()),
 loaded: (user) => _ProfileContent(user: user),
 error: (message) => Center(child: Text(message)),
 );
 },
 );
 }
}
```

The skill file ensures Claude understands your preferred patterns for state classes, event handling, and widget structure.

## Using Claude Skills with Mobile Frameworks

Mobile development often involves platform-specific code. Create skills that address these nuances:

```markdown
flutter-mobile

Description
Guides Claude through Flutter mobile development with platform channels and native integrations.

When to Use
- Implementing platform channels
- Working with native iOS/Android code
- Handling device permissions
- Integrating mobile-specific APIs

Guidelines

Platform Channels
- Define clear method channel contracts
- Use EventChannel for streaming data
- Handle platform exceptions gracefully
- Test both iOS and Android implementations

Permissions
- Use permission_handler package
- Request permissions before feature access
- Handle permanent denial gracefully
- Provide rationale to users
```

## Advanced: Conditional Skill Loading

You can create skill files that adapt based on context:

```markdown
flutter-feature

Description
Adaptive skill for Flutter feature development based on project type.

When to Use
- Starting a new feature module
- Adding screens to existing features
- Implementing API integrations

Guidelines

If Using GetX
- Follow GetX controller pattern
- Use Get.lazyPut for dependency injection
- Implement GetxController with onInit/onClose

If Using BLoC
- Define clear events and states
- Use Equatable for state comparison
- Implement proper error handling

If Using Riverpod
- Create providers with @riverpod annotation
- Use AsyncValue for async states
- Follow provider organization best practices
```

## Conclusion

Claude skill files transform how you work with Flutter by encoding your project conventions, architecture patterns, and team preferences. Start with basic skills for architecture and testing, then expand to cover specific frameworks and workflows.

For Flutter development, consider installing complementary skills like the `frontend-design` skill for UI/UX consistency, the `tdd` skill for test-driven development workflows, and the `supermemory` skill to maintain context across Flutter development sessions.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-md-example-for-flutter-mobile-application)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Code Expo EAS Build Submission Workflow Guide](/claude-code-expo-eas-build-submission-workflow-guide/)
- [Claude Code for React Native Fabric Renderer Workflow](/claude-code-for-react-native-fabric-renderer-workflow/)
- [Kotlin Android Development with Claude Code Guide](/claude-code-kotlin-android-development-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)

## Writing a Project CLAUDE.md for Flutter

A `CLAUDE.md` at your Flutter project root gives Claude Code persistent context about your state management choice, folder structure, and conventions without requiring skill invocations each session:

```markdown
CLAUDE.md. MyApp Flutter

Project
Flutter 3.19 cross-platform app (iOS, Android). State management: Riverpod 2.x with
code generation. Architecture: Feature-first with Clean Architecture layers.

Commands
flutter run # run on connected device
flutter test # unit and widget tests
flutter test integration_test/ # integration tests (device required)
flutter pub run build_runner watch # code generation for Riverpod + freezed

Folder Structure
lib/
 features/
 auth/
 data/ # repositories, data sources, models
 domain/ # entities, use cases, repository interfaces
 presentation/ # screens, widgets, providers
 core/
 router/ # GoRouter configuration
 theme/ # ThemeData and design tokens
 utils/ # shared utilities

Conventions
- All providers use @riverpod annotation (code generation required after changes)
- State classes use freezed for immutability (run build_runner after changes)
- Network calls go through Dio with interceptors in core/network/
- Use GoRouter for navigation. never Navigator.push directly
- Asset strings go in AppAssets class; localization strings in AppStrings

Testing
- Unit tests: test/ folder, mirrors lib/ structure
- Widget tests: use WidgetTester, find widgets by Key not text where possible
- Mock providers using ProviderContainer with overrides in tests
- Run `flutter test --coverage` to generate coverage report
```

## Practical Workflow: Generating Features with Claude Code

## Creating a New Screen

Describe your feature requirements and let Claude Code scaffold the complete slice:

```
Using our Riverpod + Clean Architecture conventions (see CLAUDE.md),
create a product detail screen with these requirements:
- Fetch product by ID from /api/products/{id}
- Show loading skeleton while fetching
- Handle error state with retry button
- Add to cart button that calls the cart provider
- Use our standard AppTheme text styles and spacing
```

Claude Code generates the data model with freezed annotations, the repository interface and implementation, the Riverpod provider with AsyncValue, and the screen widget. all in the right folders with correct imports.

## Updating Code Generation After Changes

When you modify a freezed class or add a Riverpod provider, remind Claude Code to trigger code generation:

```
I added an isWishlisted field to the Product model.
Update the freezed class, regenerate build artifacts, and update any widgets
that display Product to show the wishlisted state with a heart icon.
```

Claude Code runs `flutter pub run build_runner build --delete-conflicting-outputs` after modifying generated files, ensuring the project compiles without manual intervention.

## Handling Platform-Specific Code with Claude Code

Flutter's platform channel API requires matching implementations on both iOS (Swift/ObjC) and Android (Kotlin/Java). Claude Code handles both sides when given clear context:

```
Create a platform channel for retrieving the device's battery level.
- Dart side: BatteryService class with getBatteryLevel() returning Future<int>
- Android side: BatteryMethodCallHandler.kt in the main activity
- iOS side: Swift implementation in AppDelegate.swift
- Include error handling for when the API is unavailable

Use our existing channel naming convention: com.myapp/device_info
```

This saves significant context-switching time compared to manually writing and testing each platform implementation.

## Common Flutter + Claude Code Pitfalls

Missing build_runner step: After Claude Code creates new freezed models or Riverpod providers, always run `flutter pub run build_runner build`. If the generated `.g.dart` and `.freezed.dart` files are not updated, the project will have type errors that Claude Code cannot resolve without running code generation first.

Provider scope mismatches: When Claude Code creates providers, confirm that the correct scope is used. Providers that should reset on user logout must be under an appropriate `ProviderScope` override, not at the root level where they persist across sessions.

Widget test pump timing: If Claude Code generates widget tests and they fail with "widget not found" errors, the issue is usually that an async operation has not settled. Add `await tester.pumpAndSettle()` after user interactions that trigger async state updates.


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

