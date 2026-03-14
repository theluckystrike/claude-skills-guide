---
layout: default
title: "Claude Code Laravel Sanctum API Authentication Guide"
description: "A comprehensive guide to implementing secure API authentication in Laravel using Sanctum. Learn to protect your routes, issue tokens, and build authenticated endpoints with practical examples."
date: 2026-03-14
categories: [guides]
tags: [claude-code, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-laravel-sanctum-api-authentication-guide/
---

{% raw %}
# Claude Code Laravel Sanctum API Authentication Guide

Building secure APIs requires robust authentication mechanisms. Laravel Sanctum provides a lightweight, token-based authentication system perfect for SPAs, mobile applications, and APIs. This guide walks you through implementing complete API authentication with Laravel Sanctum, from installation to advanced token management.

## What is Laravel Sanctum?

Laravel Sanctum (formerly Aircode) is Laravel's official authentication package for SPAs and mobile applications. Unlike OAuth2, Sanctum uses simple token-based authentication that doesn't require complex JWT libraries or external providers. It issues personal access tokens that clients include in request headers.

Sanctum is ideal when you need to authenticate: single-page applications communicating with Laravel APIs, mobile apps consuming Laravel backends, or any client requiring simple API token authentication without the overhead of Passport.

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

Next, configure your User model to use the HasApiTokens trait:

```php
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use HasApiTokens;
    // ... rest of the model
}
```

Finally, add the Sanctum middleware to your API route group in your HTTP kernel or route file:

```php
use Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful;

Route::middleware(['auth:sanctum'])->get('/user', function (Request $request) {
    return $request->user();
});
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
}
```

Register these routes in your API routes file:

```php
use App\Http\Controllers\AuthController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
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

## Managing Tokens Effectively

Sanctum provides powerful token management capabilities. Issue tokens with descriptive names for better tracking:

```php
// Create token with name for identification
$token = $user->createToken('mobile-app-iphone')->plainTextToken;

// Get all tokens for the user
$tokens = $user->tokens;

// Revoke specific token
$token->delete();

// Revoke all tokens (logout from all devices)
$user->tokens()->delete();

// Check token abilities
if ($token->can('create-posts')) {
    // User can create posts
}
```

Implement token expiration for enhanced security by configuring the expiration in your auth config:

```php
// config/auth.php
'guards' => [
    'sanctum' => [
        'driver' => 'sanctum',
        'provider' => 'users',
        'token_expiration' => 60 * 24 * 7, // 7 days in minutes
    ],
],
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

// Axios example
axios.get('/api/user', {
    headers: {
        'Authorization': `Bearer ${userToken}`,
        'Accept': 'application/json'
    }
});
```

For mobile applications, store tokens securely (not in localStorage) and attach them to every authenticated request:

```dart
// Flutter/Dart example
Future<Map<String, dynamic>> fetchUserData(String token) async {
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

Rotate tokens periodically and provide mechanisms for users to revoke all sessions. Log token creation and revocation for audit purposes, and consider implementing two-factor authentication for sensitive operations.

## Conclusion

Laravel Sanctum provides a secure, straightforward solution for API authentication in Laravel applications. Its token-based approach integrates seamlessly with Laravel's authentication system while remaining simple enough for quick implementation. By following this guide, you can build robust API authentication that protects your endpoints while providing a smooth experience for API consumers.

Remember to keep your tokens secure, implement proper CORS and rate limiting configurations, and provide clear token management features for your users. With these practices in place, your Laravel API will have professional-grade authentication ready for production use.
{% endraw %}
