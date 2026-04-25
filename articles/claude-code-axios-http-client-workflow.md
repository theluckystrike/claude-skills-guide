---
layout: default
title: "Claude Code Axios HTTP Client Workflow"
description: "Claude Code Axios HTTP Client Workflow — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-axios-http-client-workflow/
reviewed: true
score: 7
categories: [guides]
tags: [claude-code, claude-skills]
geo_optimized: true
---

When building modern applications, HTTP requests are the backbone of data exchange. Whether you're fetching from a REST API, sending form data, or handling authentication tokens, having a solid HTTP client workflow saves hours of debugging. This guide walks you through creating a practical Axios workflow that integrates smoothly with Claude Code. covering everything from initial setup to caching strategies and file uploads.

## Why Axios Over the Native Fetch API

Before diving into configuration, it is worth understanding why developers reach for Axios rather than the built-in `fetch`. Both work, but Axios has ergonomic advantages that matter at scale:

| Feature | Axios | Fetch |
|---|---|---|
| Automatic JSON parsing | Yes. response body parsed automatically | No. must call `response.json()` manually |
| Request/response interceptors | Built-in | Requires wrapper code |
| Request cancellation | `CancelToken` / `AbortController` | `AbortController` only |
| Upload progress | `onUploadProgress` callback | No built-in progress events |
| Automatic error on 4xx/5xx | Yes. rejects the promise | No. must check `response.ok` |
| Node.js support | Works natively | Requires Node 18+ or polyfill |
| Default timeout | Configurable per instance | No timeout by default |

The automatic rejection on 4xx/5xx status codes is particularly important. A `fetch` call to an endpoint that returns 404 resolves successfully unless you check `response.ok`. With Axios, a 404 throws and lands in your catch block, which is almost always the behavior you actually want.

## Setting Up Your Axios Instance

The first step involves configuring a centralized Axios instance with sensible defaults. Rather than making ad-hoc requests throughout your codebase, create a dedicated HTTP client module:

```javascript
// src/api/client.js
import axios from 'axios';

const apiClient = axios.create({
 baseURL: process.env.API_BASE_URL || 'https://api.example.com',
 timeout: 10000,
 headers: {
 'Content-Type': 'application/json',
 },
});

export default apiClient;
```

This approach allows you to modify global settings. such as base URL or default headers. in one place rather than hunting through dozens of files. When your staging and production APIs live at different URLs, you flip one environment variable rather than updating forty request calls.

For TypeScript projects, add a type declaration to make the client more ergonomic:

```typescript
// src/api/client.ts
import axios, { AxiosInstance, AxiosRequestConfig } from 'axios';

const apiClient: AxiosInstance = axios.create({
 baseURL: process.env.VITE_API_BASE_URL || 'https://api.example.com',
 timeout: 10000,
 headers: {
 'Content-Type': 'application/json',
 },
});

export type ApiConfig = AxiosRequestConfig;
export default apiClient;
```

Exposing `ApiConfig` as a named export lets service modules accept typed options without importing from Axios directly.

## Request and Response Interceptors

Interceptors are powerful tools for handling cross-cutting concerns like authentication tokens and error logging. Add these to your client configuration:

```javascript
// src/api/client.js (continued)
apiClient.interceptors.request.use(
 (config) => {
 const token = localStorage.getItem('authToken');
 if (token) {
 config.headers.Authorization = `Bearer ${token}`;
 }
 return config;
 },
 (error) => Promise.reject(error)
);

apiClient.interceptors.response.use(
 (response) => response,
 (error) => {
 if (error.response?.status === 401) {
 // Handle token refresh or logout
 window.location.href = '/login';
 }
 return Promise.reject(error);
 }
);
```

This pattern ensures every request includes authentication automatically, while responses are normalized before reaching your components.

A more sophisticated pattern adds token refresh logic rather than immediately redirecting to login. This is critical for applications with short-lived access tokens paired with refresh tokens:

```javascript
let isRefreshing = false;
let failedQueue = [];

function processQueue(error, token = null) {
 failedQueue.forEach(prom => {
 if (error) {
 prom.reject(error);
 } else {
 prom.resolve(token);
 }
 });
 failedQueue = [];
}

apiClient.interceptors.response.use(
 (response) => response,
 async (error) => {
 const originalRequest = error.config;

 if (error.response?.status === 401 && !originalRequest._retry) {
 if (isRefreshing) {
 // Queue this request until the token refresh completes
 return new Promise((resolve, reject) => {
 failedQueue.push({ resolve, reject });
 }).then(token => {
 originalRequest.headers.Authorization = `Bearer ${token}`;
 return apiClient(originalRequest);
 });
 }

 originalRequest._retry = true;
 isRefreshing = true;

 try {
 const refreshToken = localStorage.getItem('refreshToken');
 const { data } = await axios.post('/auth/refresh', { refreshToken });
 localStorage.setItem('authToken', data.accessToken);
 apiClient.defaults.headers.Authorization = `Bearer ${data.accessToken}`;
 processQueue(null, data.accessToken);
 return apiClient(originalRequest);
 } catch (refreshError) {
 processQueue(refreshError, null);
 localStorage.clear();
 window.location.href = '/login';
 return Promise.reject(refreshError);
 } finally {
 isRefreshing = false;
 }
 }

 return Promise.reject(error);
 }
);
```

The queue mechanism handles the case where multiple requests fail simultaneously with 401. without it, each would independently attempt a token refresh, causing a race condition. Only the first refresh attempt goes through; the rest wait for it to resolve.

## Building Service Modules

Organize your API calls into service modules grouped by feature or domain. For instance, a user service might look like:

```javascript
// src/api/services/userService.js
import apiClient from '../client';

export const userService = {
 getProfile: () => apiClient.get('/users/me'),

 updateProfile: (data) => apiClient.put('/users/me', data),

 getOrders: (params) => apiClient.get('/users/me/orders', { params }),

 deleteAccount: () => apiClient.delete('/users/me'),
};
```

Service modules keep your components clean and make testing straightforward. When you need to swap the underlying HTTP library, only these service files require updates.

For larger projects, split service files by resource and group them under a single entry point:

```javascript
// src/api/services/index.js
export { userService } from './userService';
export { orderService } from './orderService';
export { notificationService } from './notificationService';
export { productService } from './productService';
```

Components then import from a single path: `import { userService, orderService } from '@/api/services'`.

## Handling Concurrent Requests

Modern applications often need to fetch multiple resources simultaneously. Axios provides `Promise.all` for parallel requests:

```javascript
async function loadDashboardData() {
 const [user, orders, notifications] = await Promise.all([
 userService.getProfile(),
 userService.getOrders({ limit: 5 }),
 notificationService.getUnread(),
 ]);

 return { user: user.data, orders: orders.data, notifications: notifications.data };
}
```

This pattern reduces wait time significantly compared to sequential requests. If the three requests each take 200ms, parallel execution takes 200ms total versus 600ms sequential.

For cases where one failing request should not block others, use `Promise.allSettled`:

```javascript
async function loadDashboardDataResilient() {
 const results = await Promise.allSettled([
 userService.getProfile(),
 userService.getOrders({ limit: 5 }),
 notificationService.getUnread(),
 ]);

 const [userResult, ordersResult, notificationsResult] = results;

 return {
 user: userResult.status === 'fulfilled' ? userResult.value.data : null,
 orders: ordersResult.status === 'fulfilled' ? ordersResult.value.data : [],
 notifications: notificationsResult.status === 'fulfilled' ? notificationsResult.value.data : [],
 errors: results
 .filter(r => r.status === 'rejected')
 .map(r => r.reason.message),
 };
}
```

Dashboard pages typically benefit from `allSettled`. a failing notification count should not blank out the entire dashboard.

## Error Handling Strategies

Solid error handling distinguishes production-ready code from prototypes. Create a utility function that categorizes errors:

```javascript
// src/api/utils/errorHandler.js
export function handleApiError(error) {
 if (error.response) {
 // Server responded with error status
 const { status, data } = error.response;
 switch (status) {
 case 400:
 return 'Invalid request data';
 case 403:
 return 'Access denied';
 case 404:
 return 'Resource not found';
 case 500:
 return 'Server error';
 default:
 return data.message || 'An error occurred';
 }
 } else if (error.request) {
 return 'Network error - please check your connection';
 }
 return 'Unexpected error';
}
```

Displaying user-friendly messages while logging detailed errors for debugging is essential for maintainability. For production, combine this with structured error logging:

```javascript
// src/api/utils/errorHandler.js (extended)
import { captureException } from '@sentry/browser'; // or your preferred service

export function handleApiError(error, context = {}) {
 // Always log the full error for debugging
 if (process.env.NODE_ENV === 'production') {
 captureException(error, {
 extra: {
 url: error.config?.url,
 method: error.config?.method,
 status: error.response?.status,
 ...context,
 },
 });
 } else {
 console.error('[API Error]', {
 url: error.config?.url,
 status: error.response?.status,
 data: error.response?.data,
 });
 }

 if (error.response) {
 const { status, data } = error.response;
 // Return structured error info for UI consumption
 return {
 code: status,
 message: data?.message || statusToMessage(status),
 fields: data?.errors || null, // validation errors by field
 };
 } else if (error.request) {
 return { code: 0, message: 'Network error - please check your connection', fields: null };
 }
 return { code: -1, message: 'Unexpected error', fields: null };
}

function statusToMessage(status) {
 const messages = {
 400: 'Invalid request data',
 401: 'Authentication required',
 403: 'Access denied',
 404: 'Resource not found',
 422: 'Validation failed',
 429: 'Too many requests. please slow down',
 500: 'Server error. our team has been notified',
 503: 'Service temporarily unavailable',
 };
 return messages[status] || `Unexpected error (${status})`;
}
```

Returning structured error objects (with `code`, `message`, and `fields`) lets your UI layer handle validation errors inline on form fields rather than showing a generic toast message.

## Integrating with Claude Code Skills

Your Axios workflow pairs excellently with Claude Code skills for enhanced productivity. When generating API documentation, the pdf skill helps create downloadable API guides. For frontend integration, the frontend-design skill provides component patterns that consume your service modules elegantly.

If you're practicing test-driven development, the tdd skill assists in writing unit tests for your service functions before implementation. The supermemory skill stores API schemas and endpoint documentation, making future refactoring faster.

For example, when documenting your API contract:

```javascript
/
 * @typedef {Object} User
 * @property {string} id
 * @property {string} email
 * @property {string} name
 * @property {string} createdAt ISO 8601 timestamp
 */

/
 * Fetches current user profile
 * @returns {Promise<import('axios').AxiosResponse<User>>}
 */
export const getProfile = () => apiClient.get('/users/me');
```

This JSDoc format works well with documentation generation tools and gives editors enough type information to show autocomplete on `response.data`.

## Testing Your HTTP Client

Writing tests for your Axios setup prevents regressions:

```javascript
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { userService } from '../services/userService';
import apiClient from '../client';

describe('userService', () => {
 let mock;

 beforeEach(() => {
 mock = new MockAdapter(apiClient);
 });

 afterEach(() => {
 mock.restore();
 });

 it('fetches user profile successfully', async () => {
 const mockUser = { id: '1', email: 'test@example.com', name: 'Test User' };
 mock.onGet('/users/me').reply(200, mockUser);

 const response = await userService.getProfile();
 expect(response.data).toEqual(mockUser);
 });

 it('rejects on server error', async () => {
 mock.onGet('/users/me').reply(500, { message: 'Internal server error' });

 await expect(userService.getProfile()).rejects.toThrow();
 });

 it('includes auth token in request headers', async () => {
 localStorage.setItem('authToken', 'test-token-123');
 mock.onGet('/users/me').reply((config) => {
 expect(config.headers.Authorization).toBe('Bearer test-token-123');
 return [200, {}];
 });

 await userService.getProfile();
 });
});
```

The third test is particularly valuable. it verifies that the request interceptor is actually attaching the token, not just that the service call resolves. Use `axios-mock-adapter` bound to your `apiClient` instance (not the base `axios` import) so your interceptors run during tests.

For more on this topic, see [Claude Code for DuckDB — Workflow Guide](/claude-code-for-duckdb-workflow-guide/).

For more on this topic, see [Claude Code Academic Workflow Guide](/claude-code-academic-workflow-guide-2026/).


For more on this topic, see [Claude Code for Zoxide — Workflow Guide](/claude-code-for-zoxide-workflow-guide/).



## Performance Optimization Tips

Consider implementing request caching for frequently accessed data:

```javascript
const cache = new Map();
const CACHE_TTL = 60 * 1000; // 1 minute

apiClient.interceptors.response.use((response) => {
 const cacheKey = response.config.url + JSON.stringify(response.config.params);
 if (response.config.method === 'get') {
 cache.set(cacheKey, { data: response.data, timestamp: Date.now() });
 }
 return response;
});

// Intercept outgoing requests to serve from cache
apiClient.interceptors.request.use((config) => {
 if (config.method !== 'get' || config.skipCache) return config;

 const cacheKey = config.url + JSON.stringify(config.params);
 const cached = cache.get(cacheKey);
 if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
 // Signal a cache hit by using a custom adapter
 config.adapter = () => Promise.resolve({
 data: cached.data,
 status: 200,
 statusText: 'OK (cached)',
 headers: {},
 config,
 });
 }
 return config;
});
```

Pass `{ skipCache: true }` in config for requests that must always be fresh. This is a lightweight cache appropriate for read-heavy data that changes infrequently (navigation items, user preferences, lookup tables). For more sophisticated caching with stale-while-revalidate semantics, consider integrating React Query or SWR in front of your service modules.

For large file downloads or uploads, Axios supports progress events:

```javascript
apiClient.post('/upload', formData, {
 onUploadProgress: (progressEvent) => {
 const percentCompleted = Math.round((progressEvent.loaded * 100) / progressEvent.total);
 console.log(`Upload progress: ${percentCompleted}%`);
 },
});

// Download progress (for streaming responses)
apiClient.get('/export/report', {
 responseType: 'blob',
 onDownloadProgress: (progressEvent) => {
 if (progressEvent.total) {
 const percent = Math.round((progressEvent.loaded * 100) / progressEvent.total);
 updateProgressBar(percent);
 }
 },
});
```

For request cancellation. essential for search-as-you-type inputs where stale responses should not overwrite fresh ones. use `AbortController`:

```javascript
let controller = null;

async function searchProducts(query) {
 // Cancel previous in-flight request
 if (controller) controller.abort();
 controller = new AbortController();

 try {
 const response = await apiClient.get('/products/search', {
 params: { q: query },
 signal: controller.signal,
 });
 return response.data;
 } catch (error) {
 if (axios.isCancel(error)) {
 // Silently ignore cancelled requests
 return null;
 }
 throw error;
 }
}
```

Connecting this to a debounced input handler prevents both excessive API calls and race conditions where a slow earlier request resolves after a faster later one.

## Summary

A well-structured Axios HTTP client workflow transforms raw API calls into maintainable, testable code. Centralize your configuration, use interceptors wisely for auth and error normalization, organize services by domain, implement thorough error handling with structured error objects, and add caching and cancellation where performance matters.

Pair this workflow with Claude Code skills like pdf for documentation, frontend-design for UI components, and tdd for comprehensive test coverage. Your API integration becomes not just functional, but professional-grade. the kind of code that survives team growth, API changes, and the inevitable security audit that asks "how do you handle token expiry?"

## Step-by-Step Guide: Building a Production Axios Client

Here is a concrete approach to building an Axios client that handles real-world API complexity.

Step 1. Create a centralized instance factory. Rather than calling axios.create() inline, create a factory function that accepts the API configuration and returns a configured instance. Claude Code generates the factory with environment-specific defaults: shorter timeouts for development, longer timeouts for production, and debug logging enabled only when LOG_LEVEL=debug is set.

Step 2. Add request interceptors for authentication. Authentication headers need to be fresh on every request, especially when using short-lived JWTs. Claude Code generates the request interceptor that reads the current token from your auth store, checks if it is expired, refreshes it if necessary (using a mutex to prevent concurrent refresh races), and attaches the fresh token to the request.

Step 3. Add response interceptors for token refresh. When a 401 response arrives, your client should automatically refresh the token and retry the original request rather than letting the error propagate. Claude Code generates the 401 interceptor with a queue mechanism that holds pending requests while the token refresh is in progress, then replays them all once the new token is available.

Step 4. Implement request cancellation for navigation. In single-page applications, requests started on one route should be cancelled when the user navigates to a different route. Claude Code generates the request manager that tracks all in-flight requests using AbortController, and the React hook that cancels pending requests on component unmount.

Step 5. Add structured error handling with error transformation. Network errors, HTTP errors, and application-level errors need different handling. Claude Code generates the error transformer that converts Axios errors into your application's error type hierarchy, with serializable properties that can be passed to error boundaries and displayed in UI.

## Common Pitfalls

Not clearing interceptors when the client is destroyed. If you create Axios instances inside React components (rare but sometimes necessary), each render creates new interceptors that accumulate. Call axios.interceptors.request.eject() and axios.interceptors.response.eject() in the component's cleanup function. Claude Code generates the cleanup hook.

Race conditions in concurrent requests. When multiple components simultaneously make requests to the same endpoint, you may want request deduplication. Without it, you get N requests for N subscribers. Claude Code generates the deduplication layer using a shared request cache Map keyed on the serialized URL and parameters.

Not serializing complex query parameters correctly. Axios serializes nested objects and arrays in query strings using PHP-style brackets by default. Many APIs expect comma-separated values or repeated keys. Configure Axios's paramsSerializer to match your API's expected format. Claude Code generates the custom serializer configured to your API's conventions.

Caching responses without considering cache invalidation. Response caching saves bandwidth but can serve stale data. Without a strategy for invalidating cache entries after mutations, your application shows outdated data. Claude Code generates the cache manager with time-based expiration and manual invalidation methods that are called after write operations.

## Best Practices

Use TypeScript generics for typed responses. Axios supports generic type parameters for response data: axios.get<User[]>('/users'). Claude Code generates the typed API module where every endpoint is represented as a function with typed request parameters and typed return values, giving full IntelliSense coverage across your API surface.

Test interceptors independently. Interceptors are the most complex part of an Axios client and the most error-prone. Unit test each interceptor by calling it directly rather than through the full Axios stack. Claude Code generates isolated test cases for the authentication interceptor, the retry interceptor, and the error transform interceptor.

Document base URL and authentication requirements. Each Axios instance should have a comment explaining which API it targets, what authentication it uses, and any special request or response handling. Claude Code generates the JSDoc comments for each instance factory that document these details and appear in IDE tooltips.

## Integration Patterns

React Query integration. React Query manages server state and caching on top of any fetch mechanism. Claude Code generates the Axios adapter for React Query that configures sensible defaults (stale time, retry count, error boundary integration) and generates typed query hooks for each of your API endpoints.

Vue.js with Pinia. In Vue applications using Pinia for state management, Claude Code generates the Axios instance as a Pinia plugin that shares the auth state store reference, allowing interceptors to read and write authentication tokens from the central store without circular dependencies.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-axios-http-client-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading


- [Error Handling Reference](/error-handling/). Complete error diagnosis and resolution guide
- [What Is the Best Claude Skill for REST API Development?](/what-is-the-best-claude-skill-for-rest-api-development/)
- [Claude Code Tutorials Hub](/tutorials-hub/)
- [Best Claude Skills for Developers in 2026](/best-claude-skills-for-developers-2026/)
- [Claude Code Guides Hub](/guides-hub/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


