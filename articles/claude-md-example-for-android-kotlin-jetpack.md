---
layout: default
title: "CLAUDE.md Example for Android + Kotlin (2026)"
description: "CLAUDE.md Example for Android + Kotlin — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-md-example-for-android-kotlin-jetpack/
date: 2026-04-20
render_with_liquid: false
categories: [claude-md, templates, 2026]
tags: [claude-code, claude-md, android, kotlin, jetpack-compose]
last_updated: 2026-04-19
---

## What This Template Does

This CLAUDE.md configures Claude Code for Android applications using Kotlin 2.1.0, Jetpack Compose with Material 3, and the full Android Architecture Components stack (ViewModel, Room, Hilt, Navigation). It prevents Claude from mixing XML layouts with Compose, enforces proper state hoisting, and ensures ViewModels use `StateFlow` instead of `LiveData` for Compose-based UIs. The template covers coroutine scoping, Room database patterns, Hilt dependency injection, and instrumented testing. This is a major expansion over previous Android templates, covering Compose Multiplatform preparation and modern Kotlin 2.x features. Tested against production apps with 40+ screens and offline-first architecture.

## The Complete Template

{% raw %}
```markdown
# CLAUDE.md — Android + Kotlin 2.1 + Jetpack Compose

## Project Stack

- Kotlin 2.1.0
- Android Gradle Plugin 8.7.3
- Jetpack Compose BOM 2024.12.01
- Material 3 (compose-material3)
- Compose Navigation 2.8.5
- ViewModel + Lifecycle 2.8.7
- Room 2.6.1 (SQLite ORM)
- Hilt 2.53.1 (dependency injection)
- Retrofit 2.11.0 + OkHttp 4.12.0 (networking)
- Kotlin Coroutines 1.9.0
- Kotlin Serialization 1.7.3 (JSON)
- Coil 3.0.4 (image loading for Compose)
- DataStore 1.1.1 (preferences and proto)
- Gradle 8.11.1 with Version Catalog

## Build & Dev Commands

- Build debug: `./gradlew assembleDebug`
- Build release: `./gradlew assembleRelease`
- Run tests: `./gradlew test`
- Run single test: `./gradlew test --tests "com.example.UserViewModelTest"`
- Instrumented tests: `./gradlew connectedAndroidTest`
- Lint: `./gradlew lint`
- Ktlint check: `./gradlew ktlintCheck`
- Ktlint format: `./gradlew ktlintFormat`
- Dependency updates: `./gradlew dependencyUpdates`
- Clean: `./gradlew clean`
- Install debug: `./gradlew installDebug`

## Project Layout

```
app/
  src/
    main/
      java/com/example/app/
        di/                          # Hilt modules
          AppModule.kt               # App-scoped bindings (Retrofit, Room)
          RepositoryModule.kt        # Repository bindings
          DispatcherModule.kt        # Coroutine dispatcher bindings
        data/
          local/
            db/
              AppDatabase.kt         # Room database definition
              dao/
                UserDao.kt           # Room DAO with @Query annotations
              entity/
                UserEntity.kt        # Room entity (database table)
              converter/
                DateConverter.kt     # Room type converters
            datastore/
              PreferencesManager.kt  # DataStore preferences
          remote/
            api/
              UserApi.kt             # Retrofit interface
            dto/
              UserDto.kt             # Network response DTOs
          repository/
            UserRepository.kt        # Repository implementation (data source coordination)
          mapper/
            UserMapper.kt            # DTO ↔ Entity ↔ Domain mappers
        domain/
          model/
            User.kt                  # Domain model (clean, no annotations)
          repository/
            UserRepository.kt        # Repository interface (abstraction)
          usecase/
            GetUsersUseCase.kt       # Single-purpose use case
        ui/
          theme/
            Theme.kt                 # Material 3 theme definition
            Color.kt                 # Color palette
            Type.kt                  # Typography
          navigation/
            AppNavHost.kt            # Compose Navigation graph
            Screen.kt                # Sealed class for navigation routes
          screens/
            users/
              UsersScreen.kt         # Compose screen (stateless)
              UsersViewModel.kt      # ViewModel with StateFlow
              UsersUiState.kt        # UI state data class
              components/
                UserCard.kt          # Screen-specific composable
          components/
            LoadingIndicator.kt      # Reusable composables
            ErrorMessage.kt
            PullToRefresh.kt
        util/
          NetworkMonitor.kt          # Connectivity observer
          Constants.kt               # App-wide constants
        App.kt                       # Application class (@HiltAndroidApp)
        MainActivity.kt              # Single Activity (@AndroidEntryPoint)
      res/
        values/
          strings.xml                # String resources (i18n)
          themes.xml                 # XML theme (for system UI, splash)
    test/                            # Unit tests (JVM)
    androidTest/                     # Instrumented tests (device/emulator)
gradle/
  libs.versions.toml                 # Version catalog
```

## Architecture Rules

- Single Activity architecture. One `MainActivity` hosts `AppNavHost` for all Compose navigation. No Fragments.
- Clean Architecture layers: Data → Domain → UI. Domain layer has no Android dependencies. Data layer implements domain interfaces.
- Unidirectional data flow: UI observes state from ViewModel. User actions trigger ViewModel methods. ViewModel updates state via StateFlow.
- Compose-only UI. No XML layouts. No Fragment-based navigation. No `findViewById`. No Data Binding.
- State hoisting: Composable screens are stateless. They receive state and callbacks from ViewModel via the screen-level composable. State lives in ViewModel.
- ViewModel per screen. ViewModel exposes `StateFlow<UiState>` for UI state and `SharedFlow<UiEvent>` for one-time events (navigation, toast).
- Repository pattern: repositories coordinate between local (Room) and remote (Retrofit) data sources. Domain layer depends on repository interfaces, not implementations.
- Use Cases: optional for simple CRUD. Required when business logic involves multiple repositories or complex transformations.
- Hilt for dependency injection: `@HiltAndroidApp` on Application, `@AndroidEntryPoint` on Activity, `@HiltViewModel` on ViewModels.
- Offline-first: Room as source of truth. Network calls update Room. UI observes Room via Flow. `NetworkBoundResource` pattern for sync.

## Coding Conventions

- Kotlin 2.1 features: data classes, sealed classes/interfaces, extension functions, scope functions (let, also, apply, run).
- Null safety: no `!!` operator in production code. Use `?.let {}`, `?: return`, or explicit null checks.
- Coroutines: `viewModelScope` in ViewModels. `withContext(Dispatchers.IO)` for database and network calls. Never use `GlobalScope`.
- StateFlow: prefer `StateFlow<UiState>` over `LiveData` for Compose. Use `MutableStateFlow` internally, expose as `StateFlow`.
- Compose state: use `remember`, `rememberSaveable`, `derivedStateOf`. Never store state in global variables.
- Composable naming: PascalCase. Stateless composables receive all data as parameters. Annotate with `@Composable`.
- Compose preview: `@Preview` annotation on composable functions. Provide sample data. Preview composables in separate `Preview` functions.
- Modifier parameter: every composable accepts `modifier: Modifier = Modifier` as the first optional parameter.
- Theme: use `MaterialTheme.colorScheme`, `.typography`, `.shapes`. Never hardcode colors or text styles.
- String resources: all user-visible text in `strings.xml`. Use `stringResource(R.string.key)` in Compose. No hardcoded strings.
- Sealed classes for navigation routes: `sealed class Screen(val route: String)`. Type-safe navigation with arguments.
- Data classes for state: `data class UsersUiState(val users: List<User> = emptyList(), val isLoading: Boolean = false, val error: String? = null)`.
- Extension functions: for domain logic on models. Keep in the model's companion or in a separate extensions file.
- Lambda trailing syntax: `Button(onClick = { viewModel.onAction() }) { Text("Click") }`.
- Collection operations: use `.map`, `.filter`, `.groupBy` instead of manual loops.
- Imports: auto-organized by IDE. No wildcard imports.

## Error Handling

- UI state includes error field: `data class UiState(val error: UiError? = null)`. Display error composable when non-null.
- ViewModel catches exceptions from use cases/repositories. Maps to user-friendly `UiError` sealed class variants.
- Network errors: `IOException` → offline message. `HttpException` → server error with status code mapping.
- Room errors: catch `SQLiteConstraintException` for unique violations. Wrap in domain-specific exceptions.
- Coroutine exception handling: `CoroutineExceptionHandler` on `viewModelScope` for uncaught exceptions. Log and update UI state.
- Retry mechanism: expose `retry()` function in ViewModel. UI shows retry button on error state.
- One-time events: `SharedFlow<UiEvent>` for navigation, snackbar, toast. `UiEvent.ShowError(message)`.
- Crash reporting: Firebase Crashlytics. Non-fatal errors reported with `Firebase.crashlytics.recordException(e)`.
- Never catch `CancellationException`. It is used by coroutines for job cancellation. Always rethrow if caught.
- Structured error logging: include screen name, user action, and error details in crash reports.

## Testing Conventions

- Unit tests (JVM): test ViewModels, Use Cases, Repositories, Mappers. No Android framework dependencies.
- ViewModel tests: use `Turbine` library to test StateFlow emissions. Use `TestDispatcher` for coroutine control.
- Repository tests: mock API and DAO. Test data coordination logic. Use `kotlinx-coroutines-test` `runTest`.
- Use Case tests: mock repository. Test business logic transformations.
- Instrumented tests: Compose testing with `createComposeRule()`. Test UI interactions and state rendering.
- Compose tests: `composeTestRule.onNodeWithText("Submit").performClick()`. Assert state changes.
- Hilt testing: `@HiltAndroidTest` on test classes. Use `@UninstallModules` to replace real modules with test modules.
- Test doubles: interfaces for all repositories and data sources. Fake implementations for testing.
- Naming: `fun \`should show users when loaded successfully\`()` using backtick syntax.
- Mocking: MockK library for Kotlin-friendly mocking. `coEvery { repo.getUsers() } returns flowOf(users)`.
- Coverage: 90% for ViewModels and Use Cases, 80% for Repositories, 50% for Compose UI.

## Database & Room Patterns

- Room database: single `@Database` class. Version-managed with `autoMigrations`.
- Entity naming: `@Entity(tableName = "users")`. Columns with `@ColumnInfo(name = "first_name")`.
- DAO pattern: `@Dao` interface with `@Query`, `@Insert(onConflict = OnConflictStrategy.REPLACE)`, `@Delete`.
- DAO returns: `Flow<List<Entity>>` for observable queries. `suspend fun` for one-shot operations.
- Type converters: `@TypeConverter` for Date, Enum, List<String> → JSON. Register with `@TypeConverters`.
- Migrations: explicit `Migration(from, to)` for schema changes. Test migrations with `MigrationTestHelper`.
- Prepopulate: `createFromAsset("database/seed.db")` for initial data.
- Indices: `@Entity(indices = [Index("email", unique = true)])` for query optimization.
- Relations: `@Embedded`, `@Relation(parentColumn, entityColumn)` for one-to-many. Return with `@Transaction` annotated DAO methods.

## Networking & API Patterns

- Retrofit: interface-based API definitions. `@GET`, `@POST`, `@PUT`, `@DELETE` annotations.
- Request/Response DTOs: separate from domain models. `@Serializable` with kotlinx-serialization.
- OkHttp interceptors: auth token interceptor, logging interceptor, network connectivity interceptor.
- Error handling: `Response<T>` wrapper. Check `isSuccessful`. Parse error body for API error messages.
- Paging: Paging 3 library with `PagingSource` for paginated API responses.
- Image loading: Coil `AsyncImage` composable for Compose. Configure caching in `ImageLoader`.

## What Claude Should Never Do

- Never create XML layout files. This project uses Jetpack Compose exclusively for UI.
- Never use `LiveData` for new code. Use `StateFlow` and `SharedFlow` for Compose state observation.
- Never use `GlobalScope` for coroutines. Use `viewModelScope` in ViewModels, `lifecycleScope` in Activity/Fragment.
- Never use `!!` (non-null assertion) in production code. Handle nullability with safe calls, Elvis operator, or explicit checks.
- Never use `findViewById`. This project uses Compose — there are no View references.
- Never store state in global variables or companion objects. State lives in ViewModel via StateFlow.
- Never access database or network on the Main thread. Use `withContext(Dispatchers.IO)` or `suspend` functions.
- Never hardcode strings, colors, or dimensions. Use resources (`strings.xml`, `MaterialTheme`).
- Never create Fragments. Single Activity + Compose Navigation handles all screen transitions.
- Never use Java code in this Kotlin project. All new code must be Kotlin.
- Never use `Thread()` or `AsyncTask`. Use Kotlin Coroutines for all async work.
- Never use `SharedPreferences` directly. Use Jetpack DataStore for key-value storage.

## Project-Specific Context

- [YOUR APP NAME] — update with your project details
- Min SDK: 26 (Android 8.0), Target SDK: 35 (Android 15)
- Backend API: [REST API URL / Firebase / Supabase]
- Analytics: [Firebase Analytics / Amplitude]
- Crash reporting: Firebase Crashlytics
- CI/CD: [GitHub Actions / Bitrise / CircleCI] → Google Play Console
- Distribution: [Google Play / Firebase App Distribution for testing]
```
{% endraw %}

## How to Adapt This For Your Project

Start with the **Project Stack** section and update versions from your `libs.versions.toml` (Gradle Version Catalog). If your app does not use Room (e.g., it is API-only), remove the database section and the offline-first architecture rules. If you use Koin instead of Hilt, replace the DI patterns — Koin uses `module {}` definitions instead of `@Module` annotations. The Compose UI patterns and state management sections are the highest value — keep those regardless of your specific architecture choices.

## Common CLAUDE.md Mistakes in Android + Kotlin Projects

1. **Not prohibiting XML layouts.** Without this rule, Claude generates XML layouts with `ConstraintLayout` and `RecyclerView` instead of Compose composables. It falls back to the older Android UI toolkit because its training data contains more XML than Compose.

2. **Allowing `LiveData` with Compose.** Claude uses `LiveData` and `observeAsState()` because many tutorials mix the two. StateFlow is the correct state holder for Compose — it is Kotlin-native and lifecycle-aware through `collectAsStateWithLifecycle()`.

3. **Missing state hoisting rules.** Claude creates stateful composables that manage their own state internally. Without hoisting, testing becomes impossible and state is lost on configuration changes.

4. **Using `GlobalScope` for coroutines.** Claude launches coroutines in `GlobalScope` for simplicity, which leaks coroutines that outlive their intended lifecycle. Specify `viewModelScope` for ViewModels.

5. **Hardcoding strings and colors.** Claude puts string literals directly in Compose functions instead of using `stringResource()`. This breaks localization and makes theme changes impossible.

## What Claude Code Does With This

With this CLAUDE.md loaded, Claude Code generates Compose-only UI with proper state hoisting and Material 3 theming. ViewModels expose `StateFlow<UiState>` instead of `LiveData`. Navigation uses Compose Navigation with type-safe sealed class routes. Dependency injection uses Hilt annotations throughout. Database access goes through Room DAOs returning `Flow` for observable queries. Network calls use Retrofit with proper coroutine scoping. All strings come from resources, all colors from the theme.

## The Full 16-Template Pack

This is one of 16 production CLAUDE.md templates available in the Lifetime pack. Includes templates for iOS + SwiftUI, Flutter + Dart, React Native + Expo, Next.js + TypeScript, and 11 more stacks. Each template is 200-400 lines of production-tested configuration. Get all 16 at [claudecodeguides.com/generator/](https://claudecodeguides.com/generator/).
