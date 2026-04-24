---
title: "Claude Code for Objective-C to Swift"
permalink: /claude-code-objective-c-to-swift-conversion-2026/
description: "Convert Objective-C iOS codebases to Swift with Claude Code. Migrate headers, categories, blocks, and Core Data models systematically."
last_tested: "2026-04-22"
domain: "iOS development"
render_with_liquid: false
---

## Why Claude Code for Objective-C to Swift

Apple has signaled the long-term deprecation path for Objective-C, with new frameworks like SwiftUI, SwiftData, and Observation available only in Swift. Legacy iOS apps with hundreds of thousands of lines of Objective-C need systematic migration: converting .h/.m file pairs, replacing categories with extensions, modernizing blocks to closures, and updating delegate patterns to async/await. The interop bridging header approach only delays the inevitable.

Claude Code understands Objective-C's message-passing semantics, property attributes (nonatomic, strong, copy), and the bridging patterns needed for incremental migration. It generates idiomatic Swift that uses value types, protocol-oriented design, and modern concurrency rather than line-by-line translation.

## The Workflow

### Step 1: Assess the Objective-C Codebase

```bash
# Count files and estimate scope
find ~/ios-project -name "*.m" | wc -l
find ~/ios-project -name "*.h" | wc -l
find ~/ios-project -name "*.swift" | wc -l

# Identify bridging header dependencies
cat ~/ios-project/*-Bridging-Header.h

# Find heaviest Objective-C files (most lines = most work)
find ~/ios-project -name "*.m" -exec wc -l {} + | sort -rn | head -20

# Check for ARC vs MRC (manual reference counting)
grep -rn "autorelease\|release\]\|retain\]" ~/ios-project --include="*.m" | head -10
```

### Step 2: Convert Core Data Models and Managers

Original Objective-C:

```objectivec
// UserManager.h
#import <CoreData/CoreData.h>

@class User;

typedef void (^UserCompletionBlock)(User * _Nullable user, NSError * _Nullable error);

@interface UserManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *context;

+ (instancetype)sharedManager;
- (void)fetchUserWithID:(NSString *)userID
             completion:(UserCompletionBlock)completion;
- (void)saveUser:(User *)user
      completion:(void (^)(BOOL success, NSError * _Nullable error))completion;
- (NSArray<User *> *)fetchActiveUsersWithLimit:(NSInteger)limit
                                         error:(NSError **)error;

@end

// UserManager.m
#import "UserManager.h"
#import "User+CoreDataProperties.h"

@implementation UserManager

+ (instancetype)sharedManager {
    static UserManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)fetchUserWithID:(NSString *)userID
             completion:(UserCompletionBlock)completion {
    [self.context performBlock:^{
        NSFetchRequest *request = [User fetchRequest];
        request.predicate = [NSPredicate predicateWithFormat:@"userID == %@", userID];
        request.fetchLimit = 1;

        NSError *error = nil;
        NSArray *results = [self.context executeFetchRequest:request error:&error];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completion(nil, error);
            } else {
                completion(results.firstObject, nil);
            }
        });
    }];
}

- (NSArray<User *> *)fetchActiveUsersWithLimit:(NSInteger)limit
                                         error:(NSError **)error {
    NSFetchRequest *request = [User fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"isActive == YES"];
    request.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]
    ];
    request.fetchLimit = limit;
    return [self.context executeFetchRequest:request error:error];
}

@end
```

Claude Code generates idiomatic Swift:

```swift
// UserManager.swift
import CoreData

actor UserManager {
    static let shared = UserManager()

    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext {
        container.viewContext
    }

    private init() {
        container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in
            if let error { fatalError("Core Data load failed: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func fetchUser(withID userID: String) async throws -> User? {
        let request = User.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %@", userID)
        request.fetchLimit = 1
        return try context.performAndWait {
            try self.context.fetch(request).first
        }
    }

    func saveUser(_ user: User) async throws {
        try context.performAndWait {
            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }

    func fetchActiveUsers(limit: Int) async throws -> [User] {
        let request = User.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \User.lastName, ascending: true)
        ]
        request.fetchLimit = limit
        return try context.performAndWait {
            try self.context.fetch(request)
        }
    }
}
```

### Step 3: Convert Categories to Extensions and Protocols

```objectivec
// NSString+Validation.h — Objective-C category
@interface NSString (Validation)
- (BOOL)isValidEmail;
- (BOOL)isValidPhoneNumber;
- (NSString *)sanitizedForDatabase;
@end
```

```swift
// String+Validation.swift — Swift extension
extension String {
    var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    var isValidPhoneNumber: Bool {
        let digits = filter(\.isNumber)
        return (10...15).contains(digits.count)
    }

    var sanitizedForDatabase: String {
        replacingOccurrences(of: "'", with: "''")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
```

### Step 4: Verify

```bash
# Build with strict concurrency checking
xcodebuild -project MyApp.xcodeproj \
  -scheme MyApp \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  SWIFT_STRICT_CONCURRENCY=complete \
  build

# Run tests
xcodebuild test -project MyApp.xcodeproj \
  -scheme MyApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Check for remaining Objective-C
echo "Remaining .m files: $(find . -name '*.m' -not -path '*/Pods/*' | wc -l)"
echo "Swift files: $(find . -name '*.swift' -not -path '*/Pods/*' | wc -l)"
```

## CLAUDE.md for Objective-C to Swift Migration

```markdown
# Objective-C to Swift Migration Standards

## Domain Rules
- Singletons become actors (thread safety by default)
- Completion blocks become async/await functions
- NSError** out-params become throwing functions
- Categories become extensions
- Protocols keep @objc only when needed for UIKit compatibility
- Use value types (struct) unless reference semantics required
- Replace NSNotificationCenter with Combine or Observation framework
- Replace KVO with @Observable macro (iOS 17+)

## File Patterns
- Remove: .h/.m pairs after conversion
- Create: single .swift file per type
- Bridging header: shrink incrementally, remove when empty
- Tests: XCTest with async test methods

## Common Commands
- xcodebuild build -scheme App -destination 'generic/platform=iOS'
- xcodebuild test -scheme App -destination 'platform=iOS Simulator,name=iPhone 16'
- swift package resolve
- swiftlint --strict
- periphery scan (detect unused code)
```

## Common Pitfalls in Objective-C to Swift Conversion

- **Nil messaging semantics:** Objective-C silently returns nil/0 when messaging nil. Swift crashes on force-unwrap. Claude Code adds proper optional chaining and guard-let patterns instead of assuming non-nil values.

- **performSelector memory leaks:** Objective-C's `performSelector:` has ARC memory management ambiguity. Claude Code replaces these with direct method calls, closures, or protocol-based dispatch.

- **Bridging header circular dependencies:** Adding Swift classes to the bridging header while Objective-C still references them creates circular imports. Claude Code plans the migration order to convert leaf classes first, working inward.

## Related

- [Claude Code for VB6 to .NET Migration](/claude-code-vb6-to-dotnet-migration-2026/)
- [Claude Code for Delphi to C# Conversion](/claude-code-delphi-to-csharp-migration-2026/)
- [Claude Code for Classic ASP to Modern Web Migration](/claude-code-classic-asp-to-modern-web-migration-2026/)
