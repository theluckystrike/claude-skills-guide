---
layout: default
title: "Claude MD Example for Android Kotlin Project"
description: "Practical guide to creating Claude skill files for Android Kotlin projects. Includes real examples, patterns, and integration tips for mobile development."
date: 2026-03-14
author: theluckystrike
permalink: /claude-md-example-for-android-kotlin-project/
categories: [guides]
---

{% raw %}

# Claude MD Example for Android Kotlin Project

Creating effective Claude skill files for Android Kotlin projects requires understanding both the skill format and how Claude Code processes mobile development workflows. This guide provides practical examples you can adapt immediately for building Android apps with Kotlin.

## The Claude Skill Format

Claude skills are Markdown files with a specific structure that Claude reads when you invoke them. For Android Kotlin projects, these skills help Claude understand your tooling, architecture patterns, and preferred development practices.

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

## Example: Android Kotlin App Architecture Skill

For an Android Kotlin project using MVVM and Clean Architecture, create a skill that guides Claude through your preferred patterns. Save this as `~/.claude/skills/android-kotlin.md`:

```markdown
# android-kotlin

## Description
Guides Claude through Android Kotlin development following Clean Architecture and MVVM patterns.

## When to Use
- Creating new screens or features
- Implementing ViewModels and UI state management
- Setting up dependency injection with Hilt
- Working with Room database
- Implementing Compose UI components

## Guidelines

### Project Structure
- Follow Clean Architecture: ui → domain → data layers
- Place ViewModels in ui layer with state hoisting
- Use repository pattern for data access
- Keep domain layer free of Android dependencies

### Kotlin Conventions
- Use data classes for DTOs and models
- Implement sealed classes for UI state and events
- Prefer immutable state with Kotlin Flow
- Use coroutines for async operations with proper scope management

### Jetpack Compose
- Use remember and mutableStateOf for local UI state
- Implement unidirectional data flow
- Create reusable composable functions
- Follow Material Design 3 guidelines

### Dependency Injection
- Use Hilt for dependency injection
- Inject repositories into ViewModels
- Provide use cases through Hilt modules
- Avoid manual dependency creation

### Testing
- Use the tdd skill for test-first development
- Write unit tests for ViewModels using Turbine
- Test use cases with mock repositories
- Use composeUITest for UI testing
```

To use this skill, type `/android-kotlin` in your Claude session, then describe what you need. Claude will apply your conventions throughout the task.

## Example: Jetpack Compose UI Skill

For projects heavily using Jetpack Compose, create a specialized skill. Save this as `~/.claude/skills/compose-ui.md`:

```markdown
# compose-ui

## Description
Guides Jetpack Compose UI development with Material Design 3 and state management best practices.

## When to Use
- Building new Compose screens
- Creating reusable UI components
- Implementing navigation with Compose Navigation
- Handling user input and form validation

## Guidelines

### UI Components
- Create small, focused composable functions
- Use modifiers consistently for styling and layout
- Follow single responsibility principle for components
- Extract repeated patterns into shared components

### State Management
- Use remember and mutableStateOf for local state
- Hoist state to the lowest common ancestor
- Use collectAsState with Flow in ViewModels
- Implement rememberSaveable for UI state survival

### Material Design 3
- Use M3 color schemes and typography
- Implement proper accessibility with contentDescription
- Use appropriate touch targets (48dp minimum)
- Follow spacing and padding guidelines

### Navigation
- Use Compose Navigation for screen transitions
- Define type-safe arguments
- Handle deep links properly
- Pass data through navigation arguments or ViewModel
```

## Example: Room Database Skill

For Android apps using Room for local persistence, create a skill. Save this as `~/.claude/skills/android-room.md`:

```markdown
# android-room

## Description
Guides Room database operations with migrations and query optimization.

## When to Use
- Creating new entities and DAOs
- Writing complex queries
- Handling database migrations
- Implementing repository pattern with Room

## Guidelines

### Entities
- Use @Entity annotations with proper column names
- Define primary keys appropriately
- Use TypeConverters for complex types
- Implement relation annotations for relationships

### DAOs
- Write type-safe queries with @Query annotation
- Use suspend functions for async operations
- Return Flow for reactive data updates
- Implement proper transaction handling

### Migrations
- Always create migration scripts for schema changes
- Test migrations on copy of production data
- Use destructive migrations only in development
- Keep migration files versioned

### Repository Pattern
- Abstract data sources through repositories
- Handle offline-first scenarios
- Implement proper error handling
- Use WorkManager for background sync
```

## Combining Skills for Android Development

You can load multiple skills to cover different aspects of Android development. For a complete workflow:

```bash
/android-kotlin /compose-ui /android-room
```

This combination gives Claude context on architecture, UI, and data layers. If you're also working on documentation, consider adding the pdf skill for generating reports, or the frontend-design skill for theming.

## Practical Example: Creating a New Feature

With the skills above loaded, here's how a typical workflow looks:

1. **Describe your feature**: "Create a user profile screen with Jetpack Compose"
2. **Claude applies your conventions**: Creates ViewModel with state hoisting, Compose UI following M3, Room entity for local caching
3. **Review and refine**: Claude follows your DI patterns and testing preferences

The skills ensure consistent code quality across your entire Android project.

## Tips for Android Kotlin Skills

- **Keep skills focused**: Separate skills for architecture, UI, and data concerns work better than one large skill
- **Specify tooling versions**: Include Kotlin, Compose, and dependency versions in guidelines
- **Include testing preferences**: Android testing has many frameworks; specify your choices
- **Reference official docs**: Link to Android developer documentation for complex APIs

## Common Pitfalls to Avoid

- **Overly generic guidelines**: "Write good code" is not helpful; specify what "good" means
- **Missing version constraints**: Kotlin and Android evolve quickly; pin to your used versions
- **Ignoring build configuration**: Include Gradle conventions and plugin usage patterns
- **Forgetting gradle**: Many teams forget to specify how Claude should handle Gradle tasks and build variants

## Conclusion

Claude skill files transform how you work with Claude Code on Android Kotlin projects. By defining your architecture, coding standards, and tooling preferences in skills, you get consistent, high-quality code that matches your team's conventions.

Start with one skill covering your core architecture, then expand as you identify more specific needs. The investment in creating well-structured skills pays dividends in faster development and fewer code review iterations.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)

{% endraw %}
