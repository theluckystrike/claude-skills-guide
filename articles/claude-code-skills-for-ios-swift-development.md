---
layout: default
title: "Claude Code Skills for iOS Swift (2026)"
description: "Practical guide to using Claude Code skills for iOS and Swift development. Build workflows with built-in skills for TDD, documentation, and workflow."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
categories: [guides]
tags: [claude-code, claude-skills, ios, swift, xcode, mobile-development]
reviewed: true
score: 8
permalink: /claude-code-skills-for-ios-swift-development/
geo_optimized: true
---

# Claude Code Skills for iOS Swift Development

iOS development with Swift requires handling complex architectures, extensive testing, and detailed documentation. Claude Code and its [skill system](/claude-skill-md-format-complete-specification-guide/) provide valuable assistance for developers working with Xcode, SwiftUI, and UIKit. This guide covers practical applications of Claude Code's built-in skills for iOS development workflows.

## Setting Up Claude Code for iOS Development

Before integrating Claude into your iOS workflow, ensure your development environment is properly configured. You'll need Xcode installed along with the command-line tools. Claude Code works best when it can access your project structure, so keep your `.xcodeproj` and `.xcworkspace` files accessible.

Initialize your iOS project using Xcode or `xcode-select --install` for command-line tools. When working with Swift packages, make sure your `Package.swift` files are visible to Claude for accurate dependency resolution.

Place your Swift source files in a clear directory hierarchy so Claude can understand your project layout:

```
MyApp/
 Sources/
 App/
 MyAppApp.swift
 Features/
 Onboarding/
 Dashboard/
 Core/
 Models/
 Services/
 Utilities/
 Resources/
 Tests/
```

Add a `CLAUDE.md` file in your project root to tell Claude Code about your iOS project structure and conventions:

```markdown
Project Structure
- Source files: Sources//*.swift
- Test files: Tests//*.swift

Conventions
Prefer SwiftUI over UIKit for new views
Use @Observable macro over @StateObject for iOS 17+
Follow Apple's Swift API Design Guidelines
Include accessibility labels for all interactive elements
```

When starting a Claude session, also provide architectural context explicitly:

```
I'm working on an iOS app with SwiftUI and MVVM architecture. The project uses Combine for reactive programming and Swift Package Manager for dependencies.
```

## Available Skills for iOS Development

Claude Code ships with several built-in skills that enhance iOS development:

- `/tdd`. test-driven development guidance
- `/pdf`. document generation from code
- `/docx`. documentation creation
- `/xlsx`. spreadsheet operations for metrics
- `/pptx`. presentation generation
- `/frontend-design`. UI component guidance (applies to SwiftUI)
- `/webapp-testing`. testing workflow guidance

While there are no iOS-specific built-in skills like `/swift`, `/xcode`, or `/swiftui`, Claude handles Swift code generation effectively when you describe your requirements clearly.

## Feature Development Workflow with Claude Code

When starting a new feature, structure your requests to Claude in phases.

## Phase 1: Feature Planning and Architecture

Describe your requirements with clear, structured prompts that include:

- User story: What the feature should accomplish
- Technical requirements: APIs, frameworks, or libraries needed
- Design constraints: UI/UX guidelines and performance requirements
- Integration points: How the feature connects with existing code

For example: "Design a feature for user authentication with biometric support using LocalAuthentication framework. Include login, registration, and password reset screens following MVVM architecture."

Claude Code will generate suggested architecture diagrams, file structure recommendations, protocol definitions, and initial view model and view controller templates.

## Phase 2: Code Generation and Implementation

Claude Code excels at generating Swift code that follows Apple's best practices. For example, a shopping cart view model:

```swift
import SwiftUI
import Combine

@MainActor
final class ShoppingCartViewModel: ObservableObject {
 @Published var items: [CartItem] = []
 @Published var isLoading = false
 @Published var error: CartError?

 var totalPrice: Double {
 items.reduce(0) { $0 + $1.price * Double($1.quantity) }
 }

 var itemCount: Int {
 items.reduce(0) { $0 + $1.quantity }
 }

 func addItem(_ product: Product) {
 if let index = items.firstIndex(where: { $0.product.id == product.id }) {
 items[index].quantity += 1
 } else {
 items.append(CartItem(product: product, quantity: 1))
 }
 }

 func removeItem(_ item: CartItem) {
 items.removeAll { $0.product.id == item.product.id }
 }

 func checkout() async throws {
 isLoading = true
 defer { isLoading = false }

 // Implementation
 }
}
```

This demonstrates several Swift best practices: `@MainActor` for thread-safe UI updates, `@Published` properties for reactive updates, clear separation of concerns, and custom error types.

## Phase 3: Testing and Debugging

Claude Code can generate unit tests, integration tests, and UI tests. For the shopping cart above:

```swift
import XCTest
@testable import YourApp

@MainActor
final class ShoppingCartViewModelTests: XCTestCase {
 var viewModel: ShoppingCartViewModel!

 override func setUp() {
 super.setUp()
 viewModel = ShoppingCartViewModel()
 }

 func testAddItemIncreasesCount() {
 let product = Product(id: "1", name: "Test", price: 9.99)

 viewModel.addItem(product)

 XCTAssertEqual(viewModel.itemCount, 1)
 }

 func testTotalPriceCalculation() {
 let product1 = Product(id: "1", name: "Item1", price: 10.00)
 let product2 = Product(id: "2", name: "Item2", price: 15.00)

 viewModel.addItem(product1)
 viewModel.addItem(product2)

 XCTAssertEqual(viewModel.totalPrice, 25.00, accuracy: 0.01)
 }
}
```

## Test-Driven Development with the TDD Skill

The [TDD skill](/claude-tdd-skill-test-driven-development-workflow/) transforms your iOS development approach. Activate it in your Claude session:

```
/tdd
```

When building iOS features, describe your intended implementation and the skill prompts Claude to generate test cases first, then build your Swift code against those tests. This approach integrates well with both XCTest and the newer Swift Testing framework.

For example, when implementing a network layer using Swift Testing annotations:

```swift
import Testing

@Test
func testSuccessfulLogin() async throws {
 let userService = UserService(authService: MockAuthService())

 let user = try await userService.login(
 email: "test@example.com",
 password: "password123"
 )

 #expect(user.email == "test@example.com")
 #expect(user.id != nil)
}

@Test
func testLoginWithInvalidCredentials() async throws {
 let userService = UserService(authService: FailingMockAuthService())

 await #expect(throws: AuthError.invalidCredentials) {
 try await userService.login(
 email: "invalid@example.com",
 password: "wrongpassword"
 )
 }
}
```

Using XCTest with Swift Testing's `@Suite` and `@Test` for a service layer:

```swift
// Test case first - Swift Testing
@testable import NetworkModule

@Suite
struct UserServiceTests {
 @Test
 func testFetchUserDecodesSuccessfully() async throws {
 // Arrange
 let mockLoader = MockDataLoader()
 let service = UserService(loader: mockLoader)

 // Act
 let user = try await service.fetchUser(id: "123")

 // Assert
 #expect(user.id == "123")
 #expect(user.name == "John Doe")
 }
}
```

After writing tests, Claude generates the corresponding implementation:

```swift
actor UserService {
 private let loader: DataLoading

 init(loader: DataLoading) {
 self.loader = loader
 }

 func fetchUser(id: String) async throws -> User {
 let data = try await loader.load(from: "/users/\(id)")
 return try JSONDecoder().decode(User.self, from: data)
 }
}
```

## SwiftUI Development with Claude

When building SwiftUI interfaces, Claude assists with component creation and state management. Describe your UI requirements clearly:

```
I need to build a settings screen with SwiftUI.
The screen should display user preferences including
notifications toggle, theme selector, and account info.
Handle loading and error states properly.
```

Claude generates the complete SwiftUI implementation:

```swift
struct SettingsView: View {
 @StateObject private var viewModel = SettingsViewModel()
 @State private var showError = false

 var body: some View {
 NavigationStack {
 List {
 Section("Notifications") {
 Toggle("Push Notifications",
 isOn: $viewModel.notificationsEnabled)
 }

 Section("Appearance") {
 Picker("Theme",
 selection: $viewModel.selectedTheme) {
 Text("System").tag(Theme.system)
 Text("Light").tag(Theme.light)
 Text("Dark").tag(Theme.dark)
 }
 }

 Section("Account") {
 if viewModel.isLoading {
 ProgressView()
 } else if let user = viewModel.currentUser {
 Text(user.email)
 Text(user.name)
 }
 }
 }
 .navigationTitle("Settings")
 .alert("Error", isPresented: $showError) {
 Button("OK", role: .cancel) {}
 } message: {
 Text(viewModel.errorMessage)
 }
 .task {
 await viewModel.loadUserData()
 }
 }
 }
}
```

For screens using the modern `@Observable` macro (iOS 17+), Claude generates the appropriate patterns:

```swift
import SwiftUI

struct ProfileView: View {
 @State private var viewModel = ProfileViewModel()

 var body: some View {
 NavigationStack {
 ScrollView {
 VStack(spacing: 24) {
 profileHeader
 userInfoSection
 settingsSection
 }
 .padding()
 }
 .navigationTitle("Profile")
 .task {
 await viewModel.loadUserData()
 }
 }
 }

 private var profileHeader: some View {
 VStack(spacing: 12) {
 AsyncImage(url: URL(string: "https://picsum.photos/200")) { phase in
 switch phase {
 case .empty:
 ProgressView()
 case .success(let image):
 image.resizable().scaledToFill()
 case .failure:
 Image(systemName: "person.circle.fill")
 .resizable()
 @unknown default:
 EmptyView()
 }
 }
 .frame(width: 120, height: 120)
 .clipShape(Circle())

 if viewModel.isLoading {
 ProgressView()
 }
 }
 }

 private var userInfoSection: some View {
 GroupBox("Account Information") {
 VStack(spacing: 16) {
 TextField("Name", text: $viewModel.userName)
 .textContentType(.name)

 TextField("Email", text: $viewModel.userEmail)
 .textContentType(.emailAddress)
 .keyboardType(.emailAddress)
 }
 .textFieldStyle(.roundedBorder)
 }
 }

 private var settingsSection: some View {
 GroupBox("Settings") {
 VStack(spacing: 0) {
 NavigationLink("Notifications") {
 NotificationsSettingsView()
 }
 NavigationLink("Privacy") {
 PrivacySettingsView()
 }
 NavigationLink("About") {
 AboutView()
 }
 }
 }
 }
}

#Preview {
 ProfileView()
}
```

The corresponding `@Observable` ViewModel:

```swift
import SwiftUI

@Observable
final class ProfileViewModel {
 var userName: String = ""
 var userEmail: String = ""
 var isLoading: Bool = false
 var errorMessage: String?

 func loadUserData() async {
 isLoading = true
 defer { isLoading = false }

 // Simulate network call
 try? await Task.sleep(for: .seconds(1))
 userName = "John Developer"
 userEmail = "john@example.com"
 }
}
```

## Custom SwiftUI Components

Claude Code also generates reusable component styles. Request components with specific requirements:

```
Create a reusable ButtonStyle for primary actions that includes:
- Rounded corners (12pt radius)
- Background color: #007AFF
- Pressed state with 0.8 opacity
- Disabled state with 0.5 opacity
- Smooth animation (200ms ease-in-out)
```

Claude generates the complete style:

```swift
struct PrimaryButtonStyle: ButtonStyle {
 @Environment(\.isEnabled) private var isEnabled

 func makeBody(configuration: Configuration) -> some View {
 configuration.label
 .font(.headline)
 .foregroundColor(.white)
 .padding(.horizontal, 24)
 .padding(.vertical, 14)
 .background(
 RoundedRectangle(cornerRadius: 12)
 .fill(backgroundColor)
 )
 .opacity(configuration.isPressed ? 0.8 : (isEnabled ? 1.0 : 0.5))
 .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
 }

 private var backgroundColor: Color {
 Color(red: 0/255, green: 122/255, blue: 255/255) // #007AFF
 }
}
```

## Building Network Layers with Claude

iOS apps require solid networking. Claude excels at generating type-safe API clients using modern Swift concurrency. A full NetworkService with structured error handling:

```swift
enum NetworkError: Error, LocalizedError {
 case invalidURL
 case requestFailed(Error)
 case invalidResponse
 case decodingFailed(Error)

 var errorDescription: String? {
 switch self {
 case .invalidURL:
 return "Invalid URL"
 case .requestFailed(let error):
 return "Request failed: \(error.localizedDescription)"
 case .invalidResponse:
 return "Invalid server response"
 case .decodingFailed(let error):
 return "Failed to decode response: \(error.localizedDescription)"
 }
 }
}

actor NetworkService {
 private let session: URLSession
 private let decoder: JSONDecoder

 init(session: URLSession = .shared) {
 self.session = session
 self.decoder = JSONDecoder()
 self.decoder.dateDecodingStrategy = .iso8601
 }

 func fetch<T: Decodable>(from urlString: String) async throws -> T {
 guard let url = URL(string: urlString) else {
 throw NetworkError.invalidURL
 }

 do {
 let (data, response) = try await session.data(from: url)

 guard let httpResponse = response as? HTTPURLResponse,
 (200...299).contains(httpResponse.statusCode) else {
 throw NetworkError.invalidResponse
 }

 do {
 return try decoder.decode(T.self, from: data)
 } catch {
 throw NetworkError.decodingFailed(error)
 }
 } catch let error as NetworkError {
 throw error
 } catch {
 throw NetworkError.requestFailed(error)
 }
 }
}
```

For projects using an `Endpoint` protocol pattern, Claude generates a more structured API client:

```swift
import Foundation

actor APIClient {
 private let baseURL: URL
 private let session: URLSession

 init(baseURL: String, session: URLSession = .shared) {
 self.baseURL = URL(string: baseURL)!
 self.session = session
 }

 func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
 let request = try endpoint.urlRequest(baseURL: baseURL)
 let (data, response) = try await session.data(for: request)

 guard let httpResponse = response as? HTTPURLResponse,
 (200...299).contains(httpResponse.statusCode) else {
 throw APIError.invalidResponse
 }

 let decoder = JSONDecoder()
 decoder.keyDecodingStrategy = .convertFromSnakeCase
 return try decoder.decode(T.self, from: data)
 }
}

enum APIError: Error {
 case invalidResponse
 case decodingError(Error)
 case networkError(Error)
}
```

## UI Testing with XCTest

iOS testing involves multiple layers: unit tests, UI tests, and integration tests. Claude helps generate [comprehensive test coverage](/claude-code-skills-for-qa-engineers-automating-test-suites/).

For UI Testing with XCTest:

```swift
class ProfileScreenTests: XCTestCase {
 var app: XCUIApplication!

 override func setUp() {
 super.setUp()
 continueAfterFailure = false
 app = XCUIApplication()
 app.launchArguments = ["--uitesting"]
 }

 @MainActor
 func testProfileDisplaysUserName() {
 app.launch()

 let nameLabel = app.staticTexts["userNameLabel"]
 XCTAssertTrue(nameLabel.waitForExistence(timeout: 5))
 XCTAssertEqual(nameLabel.label, "John Doe")
 }
}
```

## Working with Xcode, Swift Packages, and CocoaPods

When your iOS project uses Swift Package Manager, Claude assists with dependency management and package integration. Describe your package requirements:

```
I need to add Alamofire for networking and
SnapKit for Auto Layout to my iOS project.
Generate the Package.swift dependencies and
show how to integrate them in a ViewController.
```

Claude generates UIKit integration with SnapKit constraints:

```swift
import UIKit
import SnapKit

final class LoginViewController: UIViewController {

 private let emailTextField: UITextField = {
 let tf = UITextField()
 tf.placeholder = "Email"
 tf.borderStyle = .roundedRect
 tf.keyboardType = .emailAddress
 tf.autocapitalizationType = .none
 return tf
 }()

 private let passwordTextField: UITextField = {
 let tf = UITextField()
 tf.placeholder = "Password"
 tf.borderStyle = .roundedRect
 tf.isSecureTextEntry = true
 return tf
 }()

 private let loginButton: UIButton = {
 let btn = UIButton(type: .system)
 btn.setTitle("Login", for: .normal)
 btn.backgroundColor = .systemBlue
 btn.setTitleColor(.white, for: .normal)
 btn.layer.cornerRadius = 8
 return btn
 }()

 override func viewDidLoad() {
 super.viewDidLoad()
 setupUI()
 }

 private func setupUI() {
 view.backgroundColor = .systemBackground

 [emailTextField, passwordTextField, loginButton].forEach {
 view.addSubview($0)
 }

 emailTextField.snp.makeConstraints { make in
 make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
 make.leading.trailing.equalToSuperview().inset(20)
 make.height.equalTo(44)
 }

 passwordTextField.snp.makeConstraints { make in
 make.top.equalTo(emailTextField.snp.bottom).offset(16)
 make.leading.trailing.equalTo(emailTextField)
 make.height.equalTo(44)
 }

 loginButton.snp.makeConstraints { make in
 make.top.equalTo(passwordTextField.snp.bottom).offset(24)
 make.leading.trailing.equalTo(emailTextField)
 make.height.equalTo(50)
 }
 }
}
```

For Alamofire-based networking in a UIKit context:

```swift
import Alamofire
import SnapKit

class NetworkViewController: UIViewController {
 private let tableView = UITableView()
 private var users: [User] = []

 override func viewDidLoad() {
 super.viewDidLoad()
 setupUI()
 fetchUsers()
 }

 private func setupUI() {
 view.addSubview(tableView)
 tableView.snp.makeConstraints { make in
 make.edges.equalToSuperview()
 }
 tableView.register(UserCell.self,
 forCellReuseIdentifier: "UserCell")
 }

 private func fetchUsers() {
 AF.request("https://api.example.com/users")
 .validate()
 .responseDecodable(of: [User].self) { [weak self] response in
 switch response.result {
 case .success(let users):
 self?.users = users
 self?.tableView.reloadData()
 case .failure(let error):
 print(error)
 }
 }
 }
}
```

When working with CocoaPods or Swift Package Manager, Claude can suggest appropriate libraries for your use case, help configure dependencies in Podfile or Package.swift, and identify potential version conflicts.

## XcodeGen Integration

If your project uses XcodeGen, Claude Code can help modify your `project.yml` configuration:

```
Add a new SwiftUI view to project.yml with target MyApp, ensuring it compiles for iOS 15.0+.
```

Claude Code generates the appropriate configuration updates, ensuring proper deployment targets and Swift version settings.

## Documentation Generation for iOS Projects

The `pdf` skill helps generate documentation for your iOS project. After completing feature development, use it to create API documentation or architecture guides. For similar cross-platform mobile workflows, see [Claude Code Dart Flutter Cross Platform Development Guide](/claude-code-dart-flutter-cross-platform-development-guide/).

```
/pdf
```

This skill extracts information from your codebase and formats it into professional documents. For iOS projects, generate class documentation, API reference sheets, or architecture decision records.

The `docx` skill creates formatted documentation:

```
/docx
```

Use this to generate Swift documentation with proper formatting, including code blocks and inline examples.

The `supermemory` skill maintains context across development sessions. When working on complex features spanning multiple sessions, Claude recalls previous decisions, architectural choices, and implementation details.

## Debugging iOS Issues

When encountering runtime issues, Claude Code can help diagnose problems. Share error messages and relevant code:

```
I'm getting "EXC_BAD_ACCESS" when tapping a button in my SwiftUI view.
The view has a @StateObject view model that fetches data from a service.
```

Claude will analyze your code and suggest potential causes, often identifying retain cycles, threading issues, or state management problems. For larger debugging sessions, provide specific error messages and the relevant code sections; describe what you expected versus what occurred, and Claude suggests targeted fixes rather than generic solutions.

## Best Practices for iOS Development with Claude

1. Provide context. Share your Xcode project structure, Swift version, minimum deployment target, and key files so Claude understands your architecture.

2. Use TDD for complex features. Activate the tdd skill before implementing business logic, view models, or data layers.

3. Generate documentation incrementally. Use the pdf and docx skills after completing significant features rather than waiting until project end.

4. Specify iOS version targets. When asking for Swift code, mention your minimum deployment target (e.g., iOS 15.0, iOS 16.0) for appropriate API usage. Use `@Observable` for iOS 17+, `@StateObject` for earlier targets.

5. Specify architecture pattern. Whether using MVVM, MVP, VIPER, or TCA, state your architecture preference explicitly.

6. Combine skills for workflows. Chain multiple skills together. Use tdd to build features, then pdf to document the implementation. Explore the [use cases hub](/use-cases-hub/) for more domain-specific workflow guides.

7. Iterate incrementally. For larger features, break requests into smaller pieces. Generate the data models first, then the network layer, followed by the view layer. This incremental approach produces more maintainable code and helps Claude understand your architecture progressively.

8. Review generated code. Always validate generated code against Apple's latest guidelines and your team's coding standards, especially for security-sensitive operations.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-skills-for-ios-swift-development)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Code Dart Flutter Cross Platform Development Guide](/claude-code-dart-flutter-cross-platform-development-guide/). mobile cross-platform patterns with Claude Code
- [Claude TDD Skill: Test-Driven Development Guide](/claude-tdd-skill-test-driven-development-workflow/). full TDD skill reference and workflow
- [Claude Code Skills for QA Engineers Automating Test Suites](/claude-code-skills-for-qa-engineers-automating-test-suites/). broader test automation coverage
- [Claude Skill .md File Format: Full Specification Guide](/claude-skill-md-format-complete-specification-guide/). understanding the skill file format

Built by theluckystrike. More at [zovo.one](https://zovo.one)



**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

## See Also

**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.

- [Claude Code for Objective-C to Swift Conversion (2026)](/claude-code-objective-c-to-swift-conversion-2026/)
