---
title: "CLAUDE.md Example for iOS + Swift + SwiftUI — Production Template (2026)"
description: "Complete 310-line CLAUDE.md for iOS 18 with Swift 6 and SwiftUI. Covers @Observable, SwiftData, async/await, and structured concurrency. Tested on Xcode 16.2."
permalink: /claude-md-example-for-ios-swift-swiftui/
render_with_liquid: false
categories: [claude-md, templates, 2026]
tags: [claude-code, claude-md, ios, swift, swiftui]
last_updated: 2026-04-19
---

## What This Template Does

This CLAUDE.md configures Claude Code for iOS applications using Swift 6.0, SwiftUI with the Observation framework, and SwiftData for persistence. It prevents Claude from using UIKit patterns, enforces `@Observable` over the deprecated `ObservableObject` protocol, and ensures structured concurrency with `async/await` instead of completion handlers. The template covers SwiftData model design, NavigationStack patterns, and Swift Testing framework conventions. Tested against production apps targeting iOS 17+ with 30+ screens and complex data models.

## The Complete Template

{% raw %}
```markdown
# CLAUDE.md — iOS 18 + Swift 6 + SwiftUI

## Project Stack

- Swift 6.0.2
- Xcode 16.2
- iOS 18.0 deployment target (minimum iOS 17.0)
- SwiftUI (Observation framework — @Observable)
- SwiftData 1.0 (persistence)
- Swift Concurrency (async/await, actors, structured concurrency)
- Swift Testing framework (replacing XCTest for new tests)
- NavigationStack (not NavigationView)
- Swift Package Manager (SPM)
- Kingfisher 8.1.0 (async image loading)
- Alamofire 5.10.2 (networking — optional, URLSession preferred)

## Build & Dev Commands

- Build: Cmd+B in Xcode (or `xcodebuild -scheme AppName build`)
- Run: Cmd+R in Xcode
- Test: Cmd+U in Xcode (or `xcodebuild test -scheme AppName -destination 'platform=iOS Simulator,name=iPhone 16'`)
- Clean: Cmd+Shift+K (or `xcodebuild clean`)
- Format: `swift format --in-place --recursive Sources/`)
- Lint: `swiftlint` (if configured)
- Resolve packages: File → Packages → Resolve Package Versions
- Archive: Product → Archive (for App Store submission)

## Project Layout

```
AppName/
  App/
    AppNameApp.swift           # @main entry point, WindowGroup, modelContainer
    ContentView.swift          # Root view with NavigationStack/TabView
  Models/
    User.swift                 # @Model SwiftData model
    Post.swift                 # @Model SwiftData model
    Enums/
      UserRole.swift           # Enums used by models
  Views/
    Users/
      UsersListView.swift      # List screen
      UserDetailView.swift     # Detail screen
      Components/
        UserRow.swift          # Reusable row component
    Common/
      LoadingView.swift        # Shared loading indicator
      ErrorView.swift          # Shared error display with retry
      EmptyStateView.swift     # Empty state placeholder
  ViewModels/
    UsersViewModel.swift       # @Observable view model
    AuthViewModel.swift        # @Observable auth state
  Services/
    NetworkService.swift       # URLSession-based API client
    AuthService.swift          # Authentication logic
    Endpoints/
      UserEndpoint.swift       # API endpoint definitions
  Repositories/
    UserRepository.swift       # SwiftData + network coordination
  Utilities/
    Extensions/
      Date+Formatting.swift    # Date extensions
      View+Modifiers.swift     # Custom view modifiers
    Constants.swift            # App-wide constants
    Logger.swift               # os.Logger wrapper
  Resources/
    Assets.xcassets            # Images and colors
    Localizable.xcstrings      # Localized strings (String Catalogs)
    Info.plist                 # App configuration
  Preview Content/
    PreviewData.swift          # Sample data for SwiftUI previews
Tests/
  AppNameTests/
    ViewModels/
      UsersViewModelTests.swift
    Services/
      NetworkServiceTests.swift
    Repositories/
      UserRepositoryTests.swift
  AppNameUITests/
    UsersFlowTests.swift       # UI test for user workflows
```

## Architecture Rules

- MVVM architecture: View → ViewModel → Repository → Service/SwiftData. Views observe ViewModels. ViewModels coordinate data access.
- SwiftUI-only UI. No UIKit views. No UIHostingController wrapping. No storyboards. No XIBs.
- Observation framework: `@Observable` macro on ViewModels (not `ObservableObject` protocol). Views access properties directly — no `@Published` wrappers needed.
- SwiftData for persistence: `@Model` macro on data classes. `ModelContainer` configured in `@main` app struct. `@Query` in views for fetched results.
- NavigationStack (not `NavigationView`): value-based navigation with `NavigationPath`. Type-safe `.navigationDestination(for:)`.
- Structured concurrency: `async/await` for all async operations. No completion handlers. No Combine for new code. `Task {}` in view lifecycle, `TaskGroup` for parallel work.
- Actor isolation: `@MainActor` on ViewModels and Views. Isolate data access with custom actors when needed.
- Dependency injection: use `@Environment` for framework-provided dependencies. Protocol-based DI for services. Pass via initializer or environment.
- Single source of truth: state owned by one entity. Views derive display from ViewModel state. No duplicate state.
- Feature-based folder structure: each feature has its own Views, ViewModel, and components subdirectory.

## Coding Conventions

- Swift 6 strict concurrency. No data races. All shared mutable state isolated to actors or marked `@Sendable`.
- Naming: types PascalCase, properties/methods camelCase, constants camelCase (Swift convention, not SCREAMING_SNAKE).
- View naming: `NounView` (`UsersListView`, `UserDetailView`). Modifier views: `NounModifier`.
- ViewModel naming: `NounViewModel` (`UsersViewModel`). One ViewModel per screen.
- Protocol naming: adjective or noun (`Fetchable`, `UserRepository`). No `Protocol` suffix.
- File naming: one primary type per file. File name matches type name.
- Access control: explicit `private`, `internal`, `public`. Default to most restrictive. `private(set)` for read-only from outside.
- Properties order in structs/classes: stored properties, computed properties, initializer, methods.
- Prefer value types (struct, enum) over reference types (class). Use class only when identity semantics or inheritance is required.
- Guard statements for early exits. `guard let value = optional else { return }`.
- SwiftUI view body: max 30 lines. Extract subviews into separate computed properties or child views.
- View modifiers: extract reusable modifier chains into custom `ViewModifier` structs.
- Trailing closure syntax for single-closure APIs. Labeled closures when multiple closures.
- String interpolation with `\()`. No `String(format:)` for simple interpolation.
- Collections: use `.map`, `.filter`, `.compactMap`, `.flatMap`. Avoid manual index-based loops.
- Comments: `///` documentation comments on public APIs. `//` for implementation notes. `// MARK:` for section organization.

## Error Handling

- ViewModel error state: `var error: AppError? = nil`. Views show error overlay when non-null.
- `AppError` enum conforming to `LocalizedError`. Variants: `.network(NetworkError)`, `.storage(StorageError)`, `.auth(AuthError)`, `.unknown(Error)`.
- Async function errors: throw `AppError` from service/repository methods. ViewModel catches and maps to UI state.
- Network errors: map `URLError` codes to user-friendly messages. `.notConnectedToInternet` → "No internet connection".
- SwiftData errors: catch `SwiftDataError` in repository. Map to domain-specific errors.
- Alert presentation: `.alert("Error", isPresented: $showError)`. One-time error display with automatic dismissal.
- Retry: expose `retry()` method on ViewModel. `ErrorView` composable includes retry button.
- Logging: `os.Logger` with subsystem and category. Log errors at `.error` level with context.
- Crash reporting: [Firebase Crashlytics / Sentry]. Non-fatal errors reported separately.
- Never force-unwrap optionals with `!` in production code. Use `guard let`, `if let`, or nil coalescing `??`.

## Testing Conventions

- Swift Testing framework for new tests (`@Test`, `#expect`, `@Suite`). XCTest for legacy tests and UI tests.
- ViewModel tests: test state transitions. Create ViewModel with mock dependencies, trigger action, assert state.
- Service tests: mock `URLProtocol` for network tests. Assert request format and response parsing.
- Repository tests: use in-memory `ModelContainer` for SwiftData tests. Assert CRUD operations.
- UI tests: XCUITest for critical user flows. Test navigation, form submission, error states.
- Preview tests: ensure all views have `#Preview` macros that compile and render correctly.
- Test naming: `@Test func fetchUsers_withValidResponse_updatesState()` or descriptive string: `@Test("Users load successfully from API")`.
- Mock pattern: protocol-based. `MockNetworkService: NetworkService` with configurable responses.
- Async test: `@Test func fetchUsers() async throws { ... }`. Swift Testing supports async natively.
- Test data: `PreviewData` struct with static sample instances for both previews and tests.
- Coverage: 90% for ViewModels, 80% for Services/Repositories, 50% for Views (tested via UI tests).

## Data & Persistence Patterns

- SwiftData `@Model` on model classes. Properties are automatically persisted. Use `@Attribute(.unique)` for unique constraints.
- ModelContainer: configured in `@main` app struct with `modelContainer(for: [User.self, Post.self])`.
- `@Query` in views: `@Query(sort: \User.name) var users: [User]` for automatic fetching and UI updates.
- ModelContext: accessed via `@Environment(\.modelContext) var context`. Use for insert, delete operations.
- Relationships: use plain Swift references. `var posts: [Post] = []` on User. SwiftData infers the relationship.
- Migration: SwiftData handles lightweight migrations automatically. For complex migrations, use `SchemaMigrationPlan`.
- Predicate: `#Predicate<User> { $0.name.contains(searchText) }` for type-safe filtering.
- Background operations: create separate `ModelContext` for background work. Merge changes to main context.
- CloudKit sync: enable iCloud container in capabilities. SwiftData syncs automatically with `cloudKitDatabase: .automatic`.

## Networking

- URLSession for API calls. Async/await: `let (data, response) = try await URLSession.shared.data(for: request)`.
- Request building: `URLRequest` with proper headers, HTTP method, and body. JSONEncoder for encoding.
- Response decoding: `JSONDecoder` with configured date strategy. Decode into response DTOs, map to domain models.
- Authentication: Bearer token in `Authorization` header. Refresh token flow in `AuthService`.
- Error responses: decode server error body. Map HTTP status codes to `NetworkError` enum.
- No third-party networking libraries unless specific features needed (multipart upload, certificate pinning).
- Request timeout: configure `URLSessionConfiguration` with `timeoutIntervalForRequest = 30`.
- Caching: use `URLCache` for GET requests. Configure cache policy per request.
- Pagination: generic `PaginatedResponse<T>` struct. Fetch next page with cursor or offset.

## Security

- Keychain: store auth tokens in Keychain via Keychain Services or a wrapper. Never use `UserDefaults` for secrets.
- App Transport Security: enforce HTTPS. No `NSAllowsArbitraryLoads` exceptions without justification.
- Biometric auth: `LAContext` for Face ID / Touch ID. Gate sensitive operations behind biometric check.
- Certificate pinning: use `URLSessionDelegate` `didReceive challenge:` for SSL pinning on critical API endpoints.
- Data protection: enable `FileProtectionType.complete` for sensitive local files.
- Input validation: validate all user input before sending to API. Sanitize strings to prevent injection.

## Deployment

- Xcode Cloud or Fastlane for CI/CD. Run tests and SwiftLint before archive.
- TestFlight for internal and external beta distribution.
- App Store Connect: manage app metadata, screenshots, and pricing.
- Versioning: semantic versioning in Xcode target. Increment build number automatically in CI.
- App Clips: use for lightweight entry points. Share code with main app target.
- Widgets: WidgetKit with SwiftUI. Share data via App Group container.

## What Claude Should Never Do

- Never create UIKit code (UIViewController, UITableView, UICollectionView). This project uses SwiftUI exclusively.
- Never use `ObservableObject` and `@Published`. Use `@Observable` macro from the Observation framework.
- Never use `NavigationView`. Use `NavigationStack` with `NavigationPath` for type-safe navigation.
- Never use completion handlers for async operations. Use `async/await` and structured concurrency.
- Never use Combine for new code. Use `AsyncSequence`, `AsyncStream`, or Observation framework.
- Never force-unwrap optionals with `!`. Use `guard let`, `if let`, optional chaining, or nil coalescing.
- Never use `AnyView` to erase view types. Use `@ViewBuilder`, conditional views, or `some View` return types.
- Never use storyboards, XIBs, or Interface Builder. All UI is code-based SwiftUI.
- Never use CoreData for new persistence. Use SwiftData (`@Model`).
- Never use `DispatchQueue.main.async`. Use `@MainActor` and structured concurrency.
- Never hardcode strings. Use String Catalogs (`Localizable.xcstrings`) and `String(localized:)`.
- Never use `UserDefaults` directly. Use `@AppStorage` in views or `UserDefaults` wrapped in a DataStore service.

## Project-Specific Context

- [YOUR APP NAME] — update with your project details
- iOS deployment target: 17.0 (supports @Observable, SwiftData, NavigationStack)
- Backend: [REST API URL / Firebase / Supabase / CloudKit]
- Analytics: [Firebase Analytics / Mixpanel / TelemetryDeck]
- Crash reporting: [Firebase Crashlytics / Sentry]
- Push notifications: APNs via [Firebase Cloud Messaging / direct APNs]
- Distribution: TestFlight → App Store Connect
```
{% endraw %}

## How to Adapt This For Your Project

Start with the **Project Stack** section and match Xcode and Swift versions. If your minimum deployment target is iOS 16, you cannot use `@Observable` or SwiftData — downgrade to `ObservableObject` and CoreData, and update the conventions accordingly. If you use The Composable Architecture (TCA), replace the MVVM patterns with Reducer/Store/Action patterns. The SwiftUI view conventions and Swift coding style sections apply regardless of architecture. If your app uses UIKit for specific screens (e.g., camera, maps), add explicit boundary rules about when UIKit is acceptable.

## Common CLAUDE.md Mistakes in iOS + SwiftUI Projects

1. **Not specifying `@Observable` vs `ObservableObject`.** Claude defaults to the older `ObservableObject` protocol with `@Published` properties because its training data has more examples. Without explicit guidance, you get a mix of old and new patterns.

2. **Allowing `NavigationView`.** Claude generates `NavigationView` (deprecated in iOS 16) instead of `NavigationStack`. The APIs are different — `NavigationStack` uses value-based navigation with `NavigationPath`.

3. **Using completion handlers instead of async/await.** Claude generates callback-based networking code when async/await is the Swift 6 standard. Specify that all async operations use structured concurrency.

4. **Force-unwrapping optionals.** Claude uses `!` to simplify code, especially when accessing dictionary values or parsing JSON. Each force-unwrap is a potential crash in production.

5. **Mixing CoreData with SwiftData.** Claude generates CoreData `NSManagedObject` subclasses when the project uses SwiftData. Specify which persistence framework your project uses.

## What Claude Code Does With This

With this CLAUDE.md loaded, Claude Code generates SwiftUI views with proper `@Observable` ViewModels, NavigationStack-based navigation, and SwiftData persistence. Async operations use structured concurrency with `async/await`. Views follow the state hoisting pattern with clear separation between stateless UI and ViewModel-owned state. Error handling uses typed `AppError` enums with user-friendly messages. Tests use the Swift Testing framework with protocol-based mock injection.

## The Full 16-Template Pack

This is one of 16 production CLAUDE.md templates available in the Lifetime pack. Includes templates for Android + Kotlin, Flutter + Dart, React Native + Expo, Next.js + TypeScript, and 11 more stacks. Each template is 200-400 lines of production-tested configuration. Get all 16 at [claudecodeguides.com/generator/](https://claudecodeguides.com/generator/).
