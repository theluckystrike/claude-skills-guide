---

layout: default
title: "How to Make Claude Code Follow DRY and SOLID Principles"
description: "Learn practical strategies for applying DRY and SOLID design principles when working with Claude Code and AI assistants."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /how-to-make-claude-code-follow-dry-solid-principles/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
---

<<<<<<< HEAD

{% raw %}
=======
>>>>>>> d103d2003802453259ba0638c75428ce7618f4f9
# How to Make Claude Code Follow DRY and SOLID Principles

When you work with Claude Code, the AI doesn't just write code—it generates architectural decisions, file structures, and interaction patterns. Without intentional guidance, this can lead to duplicated logic, fragile abstractions, and code that fights against the very principles that make software maintainable. Applying DRY (Don't Repeat Yourself) and SOLID principles to your AI-assisted workflow transforms Claude from a code generator into a genuine engineering partner.

## Understanding the AI Coding Challenge

Traditional coding involves a human making deliberate choices about abstraction and responsibility. With Claude Code, the AI often makes these decisions autonomously based on context. The result can be problematic: copy-pasted utility functions across files, classes that violate single responsibility, and tight coupling that makes refactoring painful.

The solution isn't to abandon AI assistance—it's to guide Claude toward better architectural decisions through explicit prompts, consistent conventions, and structural expectations.

## Applying DRY in AI-Generated Code

DRY states that every piece of knowledge should have a single, unambiguous representation. When Claude generates code, it frequently violates this principle by creating similar functions or data structures in multiple places.

### Centralize Repeated Patterns

Before generating new code, establish shared modules for common operations:

```typescript
// lib/utils.ts - Shared utilities
export function formatDate(date: Date): string {
  return date.toISOString().split('T')[0];
}

export function capitalize(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1);
}
```

When working with Claude, explicitly reference existing utilities rather than generating new ones. Use prompts like "Use the existing `formatDate` from `lib/utils.ts` instead of creating a new date formatter."

### Extract Shared Types

Type duplication is common in AI-generated code. Create shared type definitions:

```typescript
// types/api.ts
export interface ApiResponse<T> {
  data: T;
  status: number;
  message?: string;
}

export interface PaginationParams {
  page: number;
  limit: number;
}
```

Guide Claude by stating "Define shared types in `types/` directory and import them rather than redefining types inline."

## Applying SOLID Principles with Claude

### Single Responsibility Principle (SRP)

Claude tends to create classes or modules that handle too many concerns. When generating code, specify clear boundaries:

```typescript
// Good: Separate responsibilities
class UserValidator {
  validate(user: User): boolean {
    return Boolean(user.email && user.name);
  }
}

class UserRepository {
  constructor(private db: Database) {}
  
  save(user: User): void {
    this.db.users.insert(user);
  }
}

class UserNotifier {
  notify(user: User, message: string): void {
    // Send notification
  }
}
```

When working with skills like `pdf` for document generation or `frontend-design` for UI components, explicitly ask Claude to separate business logic from presentation and data access concerns.

### Open/Closed Principle (OCP)

Design should be open for extension but closed for modification. Guide Claude to use abstractions:

```typescript
// Instead of modifying this class for each new format
interface ReportGenerator {
  generate(data: ReportData): string;
}

class PdfReportGenerator implements ReportGenerator {
  generate(data: ReportData): string {
    // PDF generation logic
  }
}

class HtmlReportGenerator implements ReportGenerator {
  generate(data: ReportData): string {
    // HTML generation logic
  }
}
```

When using `tdd` for test-driven development, write tests that expect extension points before implementing concrete classes.

### Dependency Inversion Principle (DIP)

Depend on abstractions, not concretions. Instruct Claude to use interfaces:

```typescript
interface StorageService {
  save(key: string, value: string): Promise<void>;
  get(key: string): Promise<string | null>;
}

class AppService {
  constructor(private storage: StorageService) {}
  // Now you can swap implementations
}
```

This becomes especially valuable when combining Claude skills with external services—your business logic remains independent of specific implementations.

## Practical Workflow Integration

### Use SuperMemo for Pattern Documentation

When you identify successful patterns through Claude interactions, document them using `supermemory` or similar tools. Record not just the code, but the prompts that produced good results. This creates a knowledge base that guides future AI interactions toward DRY/SOLID compliance.

### Structured Prompting for Architecture

Before generating significant code, provide Claude with architectural context:

```
Create a TypeScript module for user management. Follow these constraints:
- Single responsibility: user validation, persistence, and notifications are separate modules
- Use interfaces for all external dependencies
- Place shared types in types/user.ts
- Don't duplicate validation logic already in lib/validation.ts
```

### Review and Refactor Iteratively

Claude generates functional code first. Treat the initial output as a starting point:

1. Identify violations of DRY (duplicated logic, repeated types)
2. Identify SOLID violations (god classes, tight coupling)
3. Refactor with explicit instructions to Claude
4. Test that functionality remains intact

When using `pptx` or `docx` for documentation alongside code, ensure your documentation code also follows these principles—duplicated API references across documentation files create maintenance nightmares.

## Real-World Example

Consider a project that generates invoices. Without guidance, Claude might create:

```typescript
// invoice.ts - Everything in one file
function calculateItemTotal(price, quantity) { ... }
function calculateTax(total) { ... }
function formatCurrency(amount) { ... }
function generateInvoiceHtml(invoice) { ... }
```

Instead, guide toward:

```typescript
// domain/invoice.ts
export class InvoiceCalculator {
  calculate(invoice: Invoice): number { ... }
}

// presentation/invoice-renderer.ts  
export class InvoiceHtmlRenderer {
  render(invoice: Invoice): string { ... }
}

// shared/currency.ts
export function formatCurrency(amount: number): string { ... }
```

This separation allows you to modify tax calculation without touching rendering logic—a classic SOLID benefit that Claude can achieve when given proper direction.

## Conclusion

Claude Code amplifies your productivity, but it also amplifies your architectural decisions. By applying DRY and SOLID principles intentionally—through explicit prompts, shared module conventions, and iterative refinement—you transform AI-generated code from disposable scripts into maintainable systems.

The key is treating Claude as a junior developer: provide clear requirements, establish conventions upfront, and review output against the same standards you'd apply to human-written code. Your documentation skills (whether using `docx` for specifications or `pdf` for reports), testing practices (through `tdd` workflows), and design capabilities (via `frontend-design`) all benefit from this disciplined approach.

## Related Reading

- [Claude Code Cyclomatic Complexity Reduction](/claude-skills-guide/claude-code-cyclomatic-complexity-reduction/) — DRY and SOLID reduce complexity
- [How to Make Claude Code Match Existing Code Patterns](/claude-skills-guide/how-to-make-claude-code-match-existing-code-patterns/) — SOLID patterns should match existing codebase conventions
- [Claude Code Technical Debt Tracking Workflow](/claude-skills-guide/claude-code-technical-debt-tracking-workflow/) — DRY violations are a common debt source
- [Advanced Claude Skills Hub](/claude-skills-guide/advanced-hub/) — Advanced code quality patterns

Built by theluckystrike — More at [zovo.one](https://zovo.one)
