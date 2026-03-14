---
layout: default
title: "Claude MD Example for Flutter Mobile Application"
description: "Practical guide to creating Claude skill files for Flutter mobile apps. Includes real examples, code patterns, and integration tips for cross-platform development."
date: 2026-03-14
author: theluckystrike
permalink: /claude-md-example-for-flutter-mobile-application/
categories: [guides]
tags: [claude-code, flutter, mobile-development]
---

{% raw %}

# Claude MD Example for Flutter Mobile Application

Creating effective Claude skill files for Flutter mobile applications requires understanding both the skill format and how Claude Code processes cross-platform development workflows. This guide provides practical examples you can adapt immediately for building Flutter apps with Dart.

## The Claude Skill Format

Claude skills are Markdown files with a specific structure that Claude reads when you invoke them. For Flutter projects, these skills help Claude understand your tooling, state management approach, and preferred development practices.

A basic skill file follows this structure:

```markdown
# Skill Name

## Description
Brief description of what this skill does.

## When to Use
Situations where this skill applies.

## Guidelines
- Specific instruction 1
- Specific instruction 2
```

The skill loads when you type `/skillname` in Claude Code, making these instructions part of the AI's context for your session.

## Example: Flutter App Architecture Skill

For a Flutter project using BLoC pattern and Clean Architecture, create a skill that guides Claude through your preferred patterns. Save this as `~/.claude/skills/flutter-app.md`:

```markdown
# flutter-app

## Description
Guides Claude through Flutter development following BLoC pattern and Clean Architecture principles.

## When to Use
- Creating new screens or features
- Implementing BLoC for state management
- Setting up dependency injection with GetIt
- Working with Riverpod providers
- Implementing widget tests

## Guidelines

### Project Structure
- Follow Clean Architecture: presentation → domain → data layers
- Place BLoCs in presentation layer with events and states
- Use repository pattern for data access
- Keep domain layer free of Flutter dependencies

### Dart Conventions
- Use data classes for models and DTOs
- Implement sealed classes for BLoC states and events
- Prefer immutability with freezed
- Use async/await for asynchronous operations

### Flutter Widgets
- Use const constructors where possible
- Implement proper widget keys for testing
- Create reusable widget components
- Follow Material Design 3 guidelines
```

This skill file teaches Claude about your Flutter architecture preferences automatically.

## Example: Flutter Testing Skill

Create a separate skill for testing workflows:

```markdown
# flutter-testing

## Description
Guides Claude through Flutter testing patterns including unit tests, widget tests, and integration tests.

## When to Use
- Writing tests for BLoCs and business logic
- Creating widget tests for custom components
- Setting up integration tests
- Debugging test failures

## Guidelines

### Unit Tests
- Test one thing per test method
- Use arrange-act-assert pattern
- Mock external dependencies with mocktail
- Test edge cases and error states

### Widget Tests
- Use WidgetTester for pump and settle
- Find widgets by key, not by text
- Test user interactions with tap, swipe, enter text
- Verify state changes after interactions

### Integration Tests
- Use flutter_test for widget tests
- Use integration_test for end-to-end flows
- Set up mock servers for API testing
- Clear app state between tests
```

## Example: Flutter State Management Skill

Different projects use different state management solutions. Create a skill that matches your stack:

```markdown
# flutter-riverpod

## Description
Guides Claude through Flutter development with Riverpod for state management.

## When to Use
- Creating providers for data fetching
- Implementing StateNotifier for complex state
- Setting up AsyncValue for loading/error states
- Organizing providers in a hierarchy

## Guidelines

### Provider Types
- Use Provider for dependency injection
- Use FutureProvider for async data
- Use StreamProvider for real-time data
- Use StateNotifierProvider for complex state
- Use ref.watch for reactive updates

### Code Patterns
- Keep providers in dedicated files
- Use Family providers for parameterized providers
- Implement proper error handling
- Use select() to minimize rebuilds
```

## Combining Skills for Flutter Projects

You can load multiple skills for comprehensive Flutter development guidance. For a production Flutter app, you might use:

```bash
/claude-code
/load-skill flutter-app
/load-skill flutter-testing
/load-skill flutter-riverpod
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
# flutter-mobile

## Description
Guides Claude through Flutter mobile development with platform channels and native integrations.

## When to Use
- Implementing platform channels
- Working with native iOS/Android code
- Handling device permissions
- Integrating mobile-specific APIs

## Guidelines

### Platform Channels
- Define clear method channel contracts
- Use EventChannel for streaming data
- Handle platform exceptions gracefully
- Test both iOS and Android implementations

### Permissions
- Use permission_handler package
- Request permissions before feature access
- Handle permanent denial gracefully
- Provide rationale to users
```

## Advanced: Conditional Skill Loading

You can create skill files that adapt based on context:

```markdown
# flutter-feature

## Description
Adaptive skill for Flutter feature development based on project type.

## When to Use
- Starting a new feature module
- Adding screens to existing features
- Implementing API integrations

## Guidelines

### If Using GetX
- Follow GetX controller pattern
- Use Get.lazyPut for dependency injection
- Implement GetxController with onInit/onClose

### If Using BLoC
- Define clear events and states
- Use Equatable for state comparison
- Implement proper error handling

### If Using Riverpod
- Create providers with @riverpod annotation
- Use AsyncValue for async states
- Follow provider organization best practices
```

## Conclusion

Claude skill files transform how you work with Flutter by encoding your project conventions, architecture patterns, and team preferences. Start with basic skills for architecture and testing, then expand to cover specific frameworks and workflows.

For Flutter development, consider installing complementary skills like the `frontend-design` skill for UI/UX consistency, the `tdd` skill for test-driven development workflows, and the `supermemory` skill to maintain context across Flutter development sessions.

Built by theluckystrike — More at [zovo.one](https://zovo.one)

{% endraw %}
