---

layout: default
title: "Claude Code Laravel Sanctum API (2026)"
description: "A comprehensive guide to implementing secure API authentication in Laravel using Sanctum. Learn to protect your routes, issue tokens, and build."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-laravel-sanctum-api-authentication-guide/
reviewed: true
score: 7
geo_optimized: true
---


Claude Code Laravel Sanctum API Authentication Guide

Building secure APIs requires solid authentication mechanisms. Laravel Sanctum provides a lightweight, token-based authentication system perfect for SPAs, mobile applications, and APIs. This guide walks you through implementing complete API authentication with Laravel Sanctum, from installation to advanced token management, using Claude Code to accelerate the process.

What is Laravel Sanctum?

Laravel Sanctum is Laravel's official authentication package for SPAs and mobile applications. Unlike OAuth2, Sanctum uses simple token-based authentication that doesn't require complex JWT libraries or external providers. It issues personal access tokens that clients include in request headers.

Sanctum is ideal when you need to authenticate: single-page applications communicating with Laravel APIs, mobile apps consuming Laravel backends, or any client requiring simple API token authentication without the overhead of Passport.

## Sanctum vs. Passport vs. JWT: When to Choose What

| Feature | Sanctum | Passport | JWT (tymon) |
|---|---|---|---|
| Complexity | Low | High | Medium |
| OAuth2 support | No | Yes | No |
| SPA cookie auth | Yes | No | No |
| Token abilities/scopes | Yes (simple) | Yes (full OAuth) | Custom |
| Third-party integrations | No | Yes | No |
| Setup time | Minutes | Hours | 30–60 min |
| Best for | APIs, SPAs, mobile | Enterprise OAuth flows | Stateless microservices |

Sanctum is the right choice for the majority of Laravel API projects. If you're building an internal API consumed by your own frontend or mobile app, Sanctum gets you production-ready in minutes rather than hours.

## Installing and Configuring Sanctum

Begin by installing Sanctum via Composer in your Laravel project:

```bash
composer require laravel/sanctum
```

Publish the Sanctum configuration and migration files:

```bash
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

Run the migrations to create the necessary database tables:

```bash
php artisan migrate
```

This creates the `personal_access_tokens` table, which stores every issued token alongside its hashed value, abilities, and optional expiration timestamp.

Next, configure your User model to use the HasApiTokens trait:

```php
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
 use HasApiTokens, Notifiable;

 protected $fillable = [
 'name',
 'email',
 'password',
 ];

 protected $hidden = [
 'password',
 'remember_token',
 ];

 protected $casts = [
 'email_verified_at' => 'datetime',
 'password' => 'hashed',
 ];
}
```

Finally, add the Sanctum middleware to your API route group in your HTTP kernel or route file:

```php
use Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful;

Route::middleware(['auth:sanctum'])->get('/user', function (Request $request) {
 return $request->user();
});
```

## Configuring Token Expiration

Out of the box, Sanctum tokens do not expire. For most production APIs, you should set a sensible default expiration in `config/sanctum.php`:

```php
// config/sanctum.php
'expiration' => 60 * 24 * 30, // 30 days in minutes

// Or null for tokens that never expire (not recommended for production)
'expiration' => null,
```

You can also set expiration per token at creation time:

```php
$token = $user->createToken(
 'mobile-app',
 ['*'],
 now()->addDays(30)
)->plainTextToken;
```

## Creating API Authentication Endpoints

Build authentication endpoints for registration, login, and logout. Create a dedicated controller to handle these operations:

```php
namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
 public function register(Request $request)
 {
 $validated = $request->validate([
 'name' => 'required|string|max:255',
 'email' => 'required|string|email|max:255|unique:users',
 'password' => 'required|string|min:8|confirmed',
 ]);

 $user = User::create([
 'name' => $validated['name'],
 'email' => $validated['email'],
 'password' => Hash::make($validated['password']),
 ]);

 $token = $user->createToken('auth-token')->plainTextToken;

 return response()->json([
 'user' => $user,
 'token' => $token
 ], 201);
 }

 public function login(Request $request)
 {
 $request->validate([
 'email' => 'required|email',
 'password' => 'required',
 ]);

 $user = User::where('email', $request->email)->first();

 if (!$user || !Hash::check($request->password, $user->password)) {
 throw ValidationException::withMessages([
 'email' => ['The provided credentials are incorrect.'],
 ]);
 }

 $token = $user->createToken('auth-token')->plainTextToken;

 return response()->json([
 'user' => $user,
 'token' => $token
 ]);
 }

 public function logout(Request $request)
 {
 $request->user()->currentAccessToken()->delete();

 return response()->json(['message' => 'Logged out successfully']);
 }

 public function logoutAll(Request $request)
 {
 // Revoke all tokens for this user (log out from all devices)
 $request->user()->tokens()->delete();

 return response()->json(['message' => 'Logged out from all devices']);
 }
}
```

Register these routes in your API routes file:

```php
use App\Http\Controllers\AuthController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
 Route::post('/logout', [AuthController::class, 'logout']);
 Route::post('/logout-all', [AuthController::class, 'logoutAll']);
});
```

## Adding a Token Refresh Endpoint

Unlike JWTs, Sanctum tokens don't have a built-in refresh mechanism. A pragmatic pattern is to issue a new token on request and revoke the old one:

```php
public function refresh(Request $request)
{
 $user = $request->user();

 // Delete the current token
 $user->currentAccessToken()->delete();

 // Issue a fresh token
 $newToken = $user->createToken('auth-token')->plainTextToken;

 return response()->json([
 'token' => $newToken,
 ]);
}
```

Add the route under the `auth:sanctum` middleware group:

```php
Route::post('/token/refresh', [AuthController::class, 'refresh']);
```

## Protecting API Routes

Secure your API endpoints using the auth:sanctum middleware. This ensures only authenticated users with valid tokens can access protected resources:

```php
Route::middleware('auth:sanctum')->group(function () {
 // Get authenticated user
 Route::get('/user', function (Request $request) {
 return $request->user();
 });

 // Protected resource endpoints
 Route::apiResource('/posts', PostController::class);

 // User-specific data
 Route::get('/dashboard', function (Request $request) {
 return response()->json([
 'user' => $request->user(),
 'stats' => $request->user()->stats,
 ]);
 });
});
```

For role-based access control, create custom middleware or use a package like Spatie:

```php
Route::middleware(['auth:sanctum', 'can:admin'])->prefix('admin')->group(function () {
 Route::get('/users', [AdminController::class, 'users']);
 Route::delete('/users/{user}', [AdminController::class, 'destroyUser']);
});
```

Token Abilities (Scopes)

Sanctum supports a lightweight ability system that lets you restrict what a given token can do. This is useful for issuing read-only tokens to third-party integrations:

```php
// Issue a token with specific abilities
$token = $user->createToken('readonly-token', ['read:posts', 'read:comments'])->plainTextToken;

// Issue an admin token with all abilities
$token = $user->createToken('admin-token', ['*'])->plainTextToken;
```

Check abilities in your controllers or middleware:

```php
public function store(Request $request)
{
 if (!$request->user()->tokenCan('create:posts')) {
 abort(403, 'This token does not have permission to create posts.');
 }

 // proceed with creating the post
}
```

You can also use the `CheckAbilities` and `CheckForAnyAbility` middleware provided by Sanctum:

```php
use Laravel\Sanctum\Http\Middleware\CheckAbilities;
use Laravel\Sanctum\Http\Middleware\CheckForAnyAbility;

Route::middleware(['auth:sanctum', CheckAbilities::class . ':create:posts,update:posts'])
 ->post('/posts', [PostController::class, 'store']);
```

## Managing Tokens Effectively

Sanctum provides powerful token management capabilities. Issue tokens with descriptive names for better tracking:

```php
// Create token with name for identification
$token = $user->createToken('mobile-app-iphone')->plainTextToken;

// Get all tokens for the user
$tokens = $user->tokens;

// Revoke specific token by ID
$user->tokens()->where('id', $tokenId)->delete();

// Revoke all tokens (logout from all devices)
$user->tokens()->delete();

// Check token abilities
if ($token->can('create-posts')) {
 // User can create posts
}
```

## Building a Token Management Endpoint

Expose token management to your users so they can see and revoke active sessions:

```php
class TokenController extends Controller
{
 public function index(Request $request)
 {
 return response()->json([
 'tokens' => $request->user()->tokens->map(function ($token) {
 return [
 'id' => $token->id,
 'name' => $token->name,
 'abilities' => $token->abilities,
 'last_used_at' => $token->last_used_at,
 'created_at' => $token->created_at,
 'expires_at' => $token->expires_at,
 ];
 }),
 ]);
 }

 public function destroy(Request $request, int $tokenId)
 {
 $deleted = $request->user()
 ->tokens()
 ->where('id', $tokenId)
 ->delete();

 if (!$deleted) {
 return response()->json(['message' => 'Token not found'], 404);
 }

 return response()->json(['message' => 'Token revoked']);
 }
}
```

Register the routes:

```php
Route::middleware('auth:sanctum')->group(function () {
 Route::get('/tokens', [TokenController::class, 'index']);
 Route::delete('/tokens/{token}', [TokenController::class, 'destroy']);
});
```

## Consuming the API from Clients

When making authenticated requests, include the Bearer token in the Authorization header:

```javascript
// JavaScript fetch example
async function fetchProtectedData(token) {
 const response = await fetch('/api/user', {
 headers: {
 'Authorization': `Bearer ${token}`,
 'Content-Type': 'application/json',
 'Accept': 'application/json',
 },
 });

 return response.json();
}

// Axios example with an interceptor that attaches the token to every request
import axios from 'axios';

const api = axios.create({ baseURL: '/api' });

api.interceptors.request.use((config) => {
 const token = localStorage.getItem('auth_token');
 if (token) {
 config.headers.Authorization = `Bearer ${token}`;
 }
 return config;
});

// Usage
const user = await api.get('/user');
```

## Handling Token Expiry on the Client

When a token expires, the API returns a 401 Unauthorized response. A solid client should handle this gracefully:

```javascript
api.interceptors.response.use(
 (response) => response,
 async (error) => {
 if (error.response?.status === 401) {
 // Clear stored token and redirect to login
 localStorage.removeItem('auth_token');
 window.location.href = '/login';
 }
 return Promise.reject(error);
 }
);
```

For mobile applications, store tokens securely using platform-specific secure storage and attach them to every authenticated request:

```dart
// Flutter/Dart example with flutter_secure_storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final storage = FlutterSecureStorage();

Future<Map<String, dynamic>> fetchUserData() async {
 final token = await storage.read(key: 'auth_token');

 final response = await http.get(
 Uri.parse('https://api.example.com/api/user'),
 headers: {
 'Authorization': 'Bearer $token',
 'Accept': 'application/json',
 },
 );

 return json.decode(response.body);
}
```

## Testing Sanctum Authentication

Always write tests for your authentication endpoints. Laravel provides convenient helpers for authenticating as a user in tests:

```php
use Laravel\Sanctum\Sanctum;

class AuthTest extends TestCase
{
 public function test_user_can_register()
 {
 $response = $this->postJson('/api/register', [
 'name' => 'Test User',
 'email' => 'test@example.com',
 'password' => 'password123',
 'password_confirmation' => 'password123',
 ]);

 $response->assertStatus(201)
 ->assertJsonStructure(['user', 'token']);
 }

 public function test_user_can_login()
 {
 $user = User::factory()->create([
 'password' => bcrypt('password123'),
 ]);

 $response = $this->postJson('/api/login', [
 'email' => $user->email,
 'password' => 'password123',
 ]);

 $response->assertOk()->assertJsonStructure(['user', 'token']);
 }

 public function test_protected_route_requires_authentication()
 {
 $response = $this->getJson('/api/dashboard');

 $response->assertUnauthorized();
 }

 public function test_authenticated_user_can_access_dashboard()
 {
 $user = User::factory()->create();

 Sanctum::actingAs($user, ['*']);

 $response = $this->getJson('/api/dashboard');

 $response->assertOk();
 }

 public function test_token_with_limited_abilities_is_restricted()
 {
 $user = User::factory()->create();

 Sanctum::actingAs($user, ['read:posts']); // read-only token

 $response = $this->postJson('/api/posts', ['title' => 'New Post']);

 $response->assertForbidden();
 }
}
```

## Best Practices for Production

Follow these security best practices when deploying Sanctum in production. First, always use HTTPS to encrypt token transmission. Configure CORS properly to restrict which domains can access your API:

```php
// config/cors.php
'paths' => ['api/*'],
'allowed_origins' => ['https://your-frontend-app.com'],
'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
'allowed_headers' => ['Content-Type', 'Authorization', 'X-Requested-With'],
```

Implement rate limiting to prevent brute force attacks on your login endpoint:

```php
Route::post('/login', [AuthController::class, 'login'])
 ->middleware('throttle:5,1'); // 5 attempts per minute
```

## Security Checklist

| Practice | Why it matters |
|---|---|
| Always use HTTPS | Tokens are bearer credentials. anyone who intercepts them can impersonate the user |
| Set token expiration | Limits the damage window if a token is leaked |
| Rate-limit login | Prevents brute-force credential attacks |
| Use token abilities | Limits blast radius for compromised third-party tokens |
| Revoke on logout | Ensures server-side invalidation, not just client-side deletion |
| Log token creation and revocation | Provides an audit trail for suspicious activity |
| Hash passwords with bcrypt | Laravel's default; never store plain text passwords |
| Validate email on registration | Reduces fake accounts and spam |

## Cleaning Up Expired Tokens

Expired tokens accumulate in the `personal_access_tokens` table over time. Use Laravel's pruning feature to clean them up automatically:

```bash
php artisan sanctum:prune-expired --hours=24
```

Schedule this in your `routes/console.php` (Laravel 11) or `app/Console/Kernel.php` (Laravel 10):

```php
// Laravel 11. routes/console.php
Schedule::command('sanctum:prune-expired --hours=24')->daily();
```

## Using Claude Code to Scaffold Sanctum Authentication

Claude Code can accelerate the entire setup process. A well-structured prompt like the one below generates most of the boilerplate instantly:

```
Set up Laravel Sanctum API authentication with:
- AuthController with register, login, logout, logoutAll methods
- Token abilities: read:profile, write:profile, admin
- Rate limiting on login (5 req/min)
- Tests for all endpoints using Sanctum::actingAs
- CORS configured for https://app.example.com
```

Claude Code understands the full Laravel ecosystem and can generate the controller, routes, middleware, and tests in a single pass. You can then iterate with follow-up prompts to add features like two-factor authentication, social login, or custom token expiration logic.

## Conclusion

Laravel Sanctum provides a secure, straightforward solution for API authentication in Laravel applications. Its token-based approach integrates smoothly with Laravel's authentication system while remaining simple enough for quick implementation. By following this guide, you can build solid API authentication that protects your endpoints while providing a smooth experience for API consumers.

The key areas to get right in production are: setting meaningful token expiration, using abilities to scope third-party integrations, implementing rate limiting on auth endpoints, and writing comprehensive tests using `Sanctum::actingAs`. With these practices in place, your Laravel API will have professional-grade authentication ready for production use.


---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-laravel-sanctum-api-authentication-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code API Authentication Patterns Guide](/claude-code-api-authentication-patterns-guide/)
- [Best AI Tools for API Development in 2026: A Practical Guide](/best-ai-tools-for-api-development-2026/)
- [Best Way to Batch Claude Code Requests to Reduce API Calls](/best-way-to-batch-claude-code-requests-reduce-api-calls/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

