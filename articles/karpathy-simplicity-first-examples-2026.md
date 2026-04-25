---
layout: default
title: "Simplicity First: Before and After Code (2026)"
description: "Side-by-side code comparisons showing Claude Code output before and after applying Karpathy's Simplicity First principle across 6 scenarios."
permalink: /karpathy-simplicity-first-examples-2026/
date: 2026-04-20
last_tested: "2026-04-22"
---

# Simplicity First: Before and After Code (2026)

Six side-by-side comparisons of Claude Code output with and without the Simplicity First principle. Each shows the overengineered version, the simplified version, and why the simpler approach is better.

## The Principle

Start simple. Add complexity only when requirements demand it. See the [full principle guide](/karpathy-simplicity-first-principle-claude-code-2026/).

## Why It Matters

These examples show real token savings. Overengineered code costs 3-8x more tokens to generate and 2-5x more time to review. Every unnecessary line is a line you maintain forever.

## Example 1: API Error Handling

### Before (Overengineered)

```typescript
// Custom error hierarchy — 45 lines
class AppError extends Error {
  constructor(public statusCode: number, public code: string, message: string) {
    super(message);
  }
}
class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(404, 'NOT_FOUND', `${resource} ${id} not found`);
  }
}
class ValidationError extends AppError {
  constructor(public fields: Record<string, string>) {
    super(400, 'VALIDATION_ERROR', 'Validation failed');
  }
}
class AuthorizationError extends AppError {
  constructor() { super(403, 'FORBIDDEN', 'Not authorized'); }
}
// + error middleware + error mapper + 3 more error classes
```

### After (Simplified)

```typescript
// Direct error responses — 0 extra files
app.get('/users/:id', async (req, res) => {
  const user = await db.users.findUnique({ where: { id: req.params.id } });
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json(user);
});
```

**Why simpler is better:** The app has 8 endpoints. A full error hierarchy serves a framework with hundreds of endpoints. For 8 endpoints, inline error responses are readable, debuggable, and have zero abstraction overhead.

## Example 2: State Management in React

### Before (Overengineered)

```typescript
// Global state with context + reducer + actions + selectors
const AppContext = createContext<AppState>(initialState);
const appReducer = (state: AppState, action: AppAction): AppState => {
  switch (action.type) {
    case 'SET_USER': return { ...state, user: action.payload };
    case 'SET_THEME': return { ...state, theme: action.payload };
    case 'SET_SIDEBAR': return { ...state, sidebarOpen: action.payload };
    // ... 12 more cases
  }
};
// + AppProvider + useAppDispatch + useAppSelector + action creators + types
// 150+ lines across 4 files
```

### After (Simplified)

```typescript
// Three independent useState hooks where they're used
function Layout() {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  // ...
}

function Header() {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  // ...
}
```

**Why simpler is better:** The "global state" was 3 independent values that don't need to be global. Sidebar state belongs in Layout. Theme belongs in Header. User comes from the auth provider. No shared reducer needed.

## Example 3: Database Query Builder

### Before (Overengineered)

```typescript
// Generic query builder — 80 lines
class QueryBuilder<T> {
  private filters: Filter[] = [];
  private sorts: Sort[] = [];
  private pagination: { limit: number; offset: number } = { limit: 20, offset: 0 };

  where(field: keyof T, op: Operator, value: any) {
    this.filters.push({ field, op, value });
    return this;
  }
  orderBy(field: keyof T, dir: 'asc' | 'desc') {
    this.sorts.push({ field, dir });
    return this;
  }
  paginate(page: number, perPage: number) {
    this.pagination = { limit: perPage, offset: (page - 1) * perPage };
    return this;
  }
  async execute(): Promise<T[]> { /* builds and runs query */ }
}
// Used in exactly 2 places
```

### After (Simplified)

```typescript
// Direct ORM calls where needed
async function getActiveUsers(page: number) {
  return db.users.findMany({
    where: { status: 'active' },
    orderBy: { createdAt: 'desc' },
    take: 20,
    skip: (page - 1) * 20,
  });
}
```

**Why simpler is better:** The ORM (Drizzle/Prisma) already IS a query builder. Wrapping it in another query builder adds indirection without adding capability.

## Example 4: Event System

### Before (Overengineered)

```typescript
// Type-safe event emitter — 60 lines
type EventMap = {
  'user:created': { userId: string };
  'user:deleted': { userId: string };
};
class TypedEventEmitter {
  private handlers = new Map<string, Set<Function>>();
  on<K extends keyof EventMap>(event: K, handler: (data: EventMap[K]) => void) { /* ... */ }
  off<K extends keyof EventMap>(event: K, handler: (data: EventMap[K]) => void) { /* ... */ }
  emit<K extends keyof EventMap>(event: K, data: EventMap[K]) { /* ... */ }
}
// Used for 2 events with 1 handler each
```

### After (Simplified)

```typescript
// Direct function calls
async function createUser(data: UserInput) {
  const user = await db.users.create({ data });
  await sendWelcomeEmail(user.email); // the "event handler"
  return user;
}
```

**Why simpler is better:** An event system decouples producers from consumers. With 2 events and 1 handler each, there's nothing to decouple. Call the function directly.

## Example 5: Validation Layer

### Before (Overengineered)

```typescript
// Custom validation framework — 100+ lines
class Validator<T> {
  private rules: ValidationRule[] = [];
  string(field: keyof T) { return new StringValidator(this, field); }
  number(field: keyof T) { return new NumberValidator(this, field); }
  validate(data: unknown): ValidationResult<T> { /* ... */ }
}
class StringValidator {
  minLength(n: number) { /* ... */ return this; }
  maxLength(n: number) { /* ... */ return this; }
  pattern(regex: RegExp) { /* ... */ return this; }
}
// + NumberValidator + EmailValidator + 4 more
```

### After (Simplified)

```typescript
// Zod (already in the project)
const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().positive().optional(),
});
```

**Why simpler is better:** The project already has Zod installed. Building a custom validation framework duplicates existing capability.

## Example 6: API Client

### Before (Overengineered)

```typescript
// Generic API client with interceptors — 120 lines
class ApiClient {
  private interceptors: RequestInterceptor[] = [];
  private baseUrl: string;
  addInterceptor(i: RequestInterceptor) { /* ... */ }
  async get<T>(path: string, opts?: RequestOptions): Promise<ApiResponse<T>> { /* ... */ }
  async post<T>(path: string, body: unknown, opts?: RequestOptions): Promise<ApiResponse<T>> { /* ... */ }
  // + retry logic + caching + error mapping
}
```

### After (Simplified)

```typescript
// fetch with auth header
async function api<T>(path: string, opts?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE_URL}${path}`, {
    ...opts,
    headers: { Authorization: `Bearer ${getToken()}`, ...opts?.headers },
  });
  if (!res.ok) throw new Error(`API ${res.status}: ${await res.text()}`);
  return res.json();
}
```

**Why simpler is better:** The app makes 6 API calls. A generic client with interceptors, retry logic, and caching serves a large application making hundreds of calls to multiple APIs.

## Common Mistakes

1. **Simplifying below the project's quality bar** — if the codebase uses patterns like dependency injection consistently, don't write a raw function that breaks the pattern.

2. **Never refactoring to add complexity** — simplicity first means start simple. When a function is called in 5 places and each has a slight variation, that's a signal to add an abstraction.

## Related Principles

- [Implement Simplicity First](/karpathy-simplicity-first-implementation-2026/) — CLAUDE.md rules
- [Fix Claude Code Overengineering](/karpathy-simplicity-debugging-overengineered-2026/) — when simplicity fails
- [Claude Code Best Practices](/karpathy-skills-vs-claude-code-best-practices-2026/) — broader patterns
