---
layout: default
title: "Claude Code for Laravel Eloquent ORM"
description: "Master Eloquent ORM with Claude Code handling relationships, query scopes, eager loading, and N+1 detection. Practical patterns for Laravel developers."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-laravel-eloquent-orm-guide/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
geo_optimized: true
last_tested: "2026-04-21"
---
Building solid Laravel applications requires mastering Eloquent ORM, and Claude Code can significantly accelerate your learning curve and development speed. This guide walks you through practical techniques for working with Eloquent, from basic model relationships to advanced query optimization.

## Setting Up Your Laravel Project with Claude Code

Before diving into Eloquent, ensure Claude Code understands your Laravel project structure. Create a CLAUDE.md file in your project root:

```
This is a Laravel 10+ application using PHP 8.2+. The project uses:
- Eloquent ORM for database interactions
- MySQL/PostgreSQL database
- Laravel Sanctum for API authentication
```

With this context, Claude Code will generate code that follows Laravel conventions and uses appropriate Eloquent methods. It will also avoid suggesting deprecated APIs or patterns from older Laravel versions, which is especially helpful when your project has specific version requirements.

Beyond the CLAUDE.md file, you can guide Claude Code at query time by referencing your schema. Paste in a migration file or describe your table structure, and Claude Code will produce correct column names, appropriate indexes, and sensible relationship definitions without you needing to correct basic mistakes repeatedly.

## Defining Models and Relationships

Eloquent's power lies in its relationship handling. Let's examine how Claude Code helps you define models with proper relationships.

## One-to-Many Relationships

A typical e-commerce application might have categories with multiple products:

```php
// app/Models/Category.php
class Category extends Model
{
 protected $fillable = ['name', 'slug', 'description'];

 public function products()
 {
 return $this->hasMany(Product::class);
 }
}
```

When prompting Claude Code, specify the relationship type and any custom foreign keys. For example: "Create a Category model with a hasMany relationship to Product, using category_id as the foreign key."

You can also ask Claude Code to generate the inverse relationship on the Product model at the same time:

```php
// app/Models/Product.php
class Product extends Model
{
 protected $fillable = ['name', 'slug', 'description', 'price', 'category_id', 'status'];

 protected $casts = [
 'price' => 'decimal:2',
 'created_at' => 'datetime',
 'updated_at' => 'datetime',
 ];

 public function category()
 {
 return $this->belongsTo(Category::class);
 }
}
```

Asking Claude Code to generate both sides of a relationship at once keeps your models consistent and reduces back-and-forth prompting.

## Many-to-Many Relationships

For roles and permissions in an application:

```php
// app/Models/Role.php
class Role extends Model
{
 public function permissions()
 {
 return $this->belongsToMany(Permission::class, 'role_permissions')
 ->withTimestamps();
 }

 public function users()
 {
 return $this->belongsToMany(User::class)
 ->withTimestamps();
 }
}
```

Claude Code excels at generating pivot table models and the intermediate relationship setup. Mention "pivot table" or "many-to-many" in your prompts to get the correct structure.

For pivot tables that store additional data (for example, storing when a user was assigned a role, or who assigned it), ask Claude Code to add `withPivot()` to the relationship definition and generate a corresponding pivot model:

```php
// app/Models/Role.php
public function users()
{
 return $this->belongsToMany(User::class)
 ->withTimestamps()
 ->withPivot(['assigned_by', 'assigned_at'])
 ->using(UserRole::class);
}

// app/Models/UserRole.php
use Illuminate\Database\Eloquent\Relations\Pivot;

class UserRole extends Pivot
{
 protected $casts = [
 'assigned_at' => 'datetime',
 ];
}
```

## Polymorphic Relationships

Polymorphic relationships are one of the trickier Eloquent concepts to set up correctly. Claude Code handles them well when you describe the scenario clearly:

```php
// A Comment can belong to either a Post or a Video
// app/Models/Comment.php
class Comment extends Model
{
 public function commentable()
 {
 return $this->morphTo();
 }
}

// app/Models/Post.php
class Post extends Model
{
 public function comments()
 {
 return $this->morphMany(Comment::class, 'commentable');
 }
}

// app/Models/Video.php
class Video extends Model
{
 public function comments()
 {
 return $this->morphMany(Comment::class, 'commentable');
 }
}
```

The migration for a polymorphic relationship needs `commentable_id` and `commentable_type` columns. Prompt Claude Code: "Generate a migration for a polymorphic comments table that can belong to posts or videos." It will produce the correct column definitions and index.

## Query Scopes for Reusable Logic

Query scopes keep your code DRY by encapsulating frequently used query conditions. Here's how to implement them effectively:

```php
// app/Models/Product.php
class Product extends Model
{
 // Local scope for active products
 public function scopeActive($query)
 {
 return $query->where('status', 'active');
 }

 // Scope with parameters
 public function scopePriceRange($query, $min, $max)
 {
 return $query->whereBetween('price', [$min, $max]);
 }

 // Scope for recently created items
 public function scopeRecent($query, $days = 7)
 {
 return $query->where('created_at', '>=', now()->subDays($days));
 }
}

// Usage in controller
$activeProducts = Product::active()->get();
$affordableProducts = Product::priceRange(10, 100)->active()->get();
```

When working with scopes, ask Claude Code to convert repetitive where conditions into scopes. This makes your code more maintainable and testable.

## Global Scopes

Global scopes apply to every query on a model automatically. A common use case is soft deletes, but you can build your own for tenant isolation in multi-tenant applications:

```php
// app/Scopes/TenantScope.php
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Scope;

class TenantScope implements Scope
{
 public function apply(Builder $builder, Model $model): void
 {
 $builder->where('tenant_id', auth()->user()?->tenant_id);
 }
}

// app/Models/Product.php
protected static function booted(): void
{
 static::addGlobalScope(new TenantScope);
}
```

Ask Claude Code: "Add a global scope to the Product model that filters by the authenticated user's tenant_id." It will generate both the scope class and the `booted` method registration.

## Scope Comparison Table

| Scope Type | Applies To | Removable? | Best Use Case |
|---|---|---|---|
| Local scope | Explicit calls only | N/A | Optional filters, reusable conditions |
| Global scope | Every query | Yes, with `withoutGlobalScope()` | Tenant isolation, soft deletes |
| Dynamic scope | Explicit calls with args | N/A | Parameterized filters |

## Eager Loading to Prevent N+1 Queries

The N+1 query problem occurs when you fetch records and access relationships in loops. Eager loading solves this by loading related records in a single query:

```php
// Without eager loading - N+1 problem
$categories = Category::all();
foreach ($categories as $category) {
 foreach ($category->products as $product) { // Each iteration triggers a query
 echo $product->name;
 }
}

// With eager loading - single query
$categories = Category::with('products')->get();
foreach ($categories as $category) {
 foreach ($category->products as $product) {
 echo $product->name;
 }
}
```

Claude Code can analyze your code and suggest where to add eager loading. Use prompts like "Find and fix N+1 queries in this controller" to get targeted improvements.

## Nested Eager Loading

For deeper relationships:

```php
$categories = Category::with('products.reviews.user')->get();
```

This loads categories, their products, product reviews, and the user who created each review in just three queries instead of hundreds.

## Conditional Eager Loading

You can filter the eagerly loaded relationship using a closure, which keeps your query results focused:

```php
$categories = Category::with([
 'products' => function ($query) {
 $query->where('status', 'active')
 ->orderBy('price');
 },
 'products.reviews' => function ($query) {
 $query->where('approved', true);
 },
])->get();
```

Ask Claude Code: "Eager load only active products with approved reviews for the Category model." It will structure the nested closure correctly.

## Lazy Eager Loading

When you have a collection already loaded and realize you need relationships, use `loadMissing()` to avoid redundant queries:

```php
$categories = Category::all();

// Later in the same request cycle:
$categories->loadMissing('products');
```

This is safer than `load()` because it will not re-query relationships that are already present on the collection.

## Counting Relations Without Loading

To display a product count per category without loading the products themselves:

```php
$categories = Category::withCount('products')->get();

foreach ($categories as $category) {
 echo $category->products_count; // No product records loaded into memory
}
```

## Using Query Builder for Complex Queries

Eloquent pairs perfectly with Laravel's query builder for complex operations:

```php
// Advanced filtering with conditions
$products = Product::query()
 ->when($request->category, fn($q) => $q->where('category_id', $request->category))
 ->when($request->min_price, fn($q) => $q->where('price', '>=', $request->min_price))
 ->when($request->search, fn($q) => $q->where('name', 'like', "%{$request->search}%"))
 ->orderByDesc('created_at')
 ->paginate(15);
```

The `when()` method conditionally adds query clauses, keeping your code clean and readable.

## Subqueries and Raw Expressions

For more advanced requirements, Eloquent supports subqueries directly:

```php
// Add the latest order date as a column on each user
$users = User::addSelect([
 'latest_order_at' => Order::select('created_at')
 ->whereColumn('user_id', 'users.id')
 ->latest()
 ->take(1),
])->get();
```

Claude Code handles subquery patterns well when you describe the goal in plain language: "For each user, add a column showing their most recent order date without a separate query."

## Aggregates in Queries

```php
// Products with average review score
$products = Product::withAvg('reviews', 'score')
 ->withCount('reviews')
 ->having('reviews_avg_score', '>=', 4.0)
 ->orderByDesc('reviews_avg_score')
 ->get();
```

## Accessors and Mutators

Transform data when reading or writing to the database:

```php
// app/Models/User.php
class User extends Model
{
 // Automatically capitalize name when setting it
 public function setNameAttribute($value)
 {
 $this->attributes['name'] = ucwords($value);
 }

 // Format the birth_date when accessing it
 public function getBirthDateAttribute($value)
 {
 return $value ? Carbon\Carbon::parse($value)->format('F j, Y') : null;
 }

 // Compute full name dynamically
 public function getFullNameAttribute()
 {
 return "{$this->first_name} {$this->last_name}";
 }
}
```

## Laravel 9+ Casts API

Laravel 9 introduced a cleaner unified accessor/mutator API using `Attribute`:

```php
use Illuminate\Database\Eloquent\Casts\Attribute;

class User extends Model
{
 protected function fullName(): Attribute
 {
 return Attribute::make(
 get: fn () => "{$this->first_name} {$this->last_name}",
 );
 }

 protected function password(): Attribute
 {
 return Attribute::make(
 set: fn (string $value) => bcrypt($value),
 );
 }
}
```

When asking Claude Code to generate accessors, specify which Laravel version you are using. With Laravel 9+, Claude Code will default to the `Attribute` class-based syntax. With Laravel 8, it will use the older `get{Name}Attribute` convention.

## Custom Cast Classes

For complex transformations shared across multiple models, create a custom cast:

```php
// app/Casts/Money.php
use Illuminate\Contracts\Database\Eloquent\CastsAttributes;

class Money implements CastsAttributes
{
 public function get($model, string $key, $value, array $attributes): float
 {
 return round($value / 100, 2);
 }

 public function set($model, string $key, $value, array $attributes): int
 {
 return (int) round($value * 100);
 }
}

// app/Models/Product.php
protected $casts = [
 'price' => Money::class,
];
```

Storing prices as integers (cents) and casting them to floats on read is a standard pattern that avoids floating-point rounding errors. Ask Claude Code to generate a `Money` cast for your project and it will produce a complete implementation.

## Model Events and Observers

Eloquent fires events during the model lifecycle: `creating`, `created`, `updating`, `updated`, `deleting`, `deleted`, and more. Observers consolidate event listeners for a model into a single class:

```php
// app/Observers/ProductObserver.php
class ProductObserver
{
 public function creating(Product $product): void
 {
 // Auto-generate slug from name if not set
 if (empty($product->slug)) {
 $product->slug = \Str::slug($product->name);
 }
 }

 public function deleted(Product $product): void
 {
 // Remove associated images from storage
 \Storage::delete($product->images->pluck('path')->toArray());
 }
}

// app/Providers/AppServiceProvider.php
public function boot(): void
{
 Product::observe(ProductObserver::class);
}
```

Prompt Claude Code: "Create an observer for the Product model that generates a slug on create and cleans up storage files on delete." It will produce the full observer class and the registration in `AppServiceProvider`.

## Working with the TDD Skill

When building Eloquent models and relationships, the TDD skill helps you write tests first:

```bash
Install the tdd skill
Place tdd skill in ~/.claude/skills/tdd.md
```

With TDD, you define expected behavior before implementation:

```php
// tests/Unit/ProductTest.php
/ @test */
public function it_can_calculate_discounted_price()
{
 $product = new Product(['price' => 100]);

 $this->assertEquals(90, $product->discountedPrice(10));
}
```

Then implement the accessor to make the test pass:

```php
public function getDiscountedPriceAttribute()
{
 return $this->price * (1 - $this->discount_percentage / 100);
}
```

## Testing Eloquent Relationships

Use factories to generate test data for relationship tests:

```php
// tests/Unit/CategoryTest.php
use App\Models\Category;
use App\Models\Product;
use Illuminate\Foundation\Testing\RefreshDatabase;

class CategoryTest extends TestCase
{
 use RefreshDatabase;

 / @test */
 public function it_has_many_products()
 {
 $category = Category::factory()
 ->has(Product::factory()->count(3))
 ->create();

 $this->assertCount(3, $category->products);
 }

 / @test */
 public function it_only_returns_active_products_through_scope()
 {
 $category = Category::factory()->create();
 Product::factory()->count(2)->for($category)->create(['status' => 'active']);
 Product::factory()->count(1)->for($category)->create(['status' => 'inactive']);

 $this->assertCount(2, $category->products()->active()->get());
 }
}
```

Ask Claude Code: "Write relationship tests for the Category model using factories and RefreshDatabase." It will produce tests covering both the relationship existence and scope behavior.

## Generating Documentation with PDF Skills

For team documentation, use the pdf skill to generate comprehensive API documentation:

```
Place pdf skill in ~/.claude/skills/pdf.md
```

This helps you create printable documentation of your Eloquent models and their relationships, useful for onboarding new team members.

## Performance Optimization Tips

1. Index foreign keys: Always add database indexes to foreign key columns
2. Use select(): Only fetch required columns when you don't need the full model
3. Chunk results: For large datasets, use `chunk()` or `cursor()` to process records in batches
4. Cache relationships: For frequently accessed but rarely changed data, use relationship caching

```php
// Only fetch needed columns
$products = Product::select('id', 'name', 'price', 'slug')->get();

// Chunk through large datasets
Product::chunk(100, function ($products) {
 foreach ($products as $product) {
 // Process each batch
 }
});
```

## Using cursor() for Memory Efficiency

When you only need to iterate through records without modifying them in bulk, `cursor()` uses a PHP generator and keeps only one model in memory at a time:

```php
foreach (Product::cursor() as $product) {
 // Only one Product model in memory at a time
 Cache::put("product:{$product->id}", $product->toArray(), 3600);
}
```

Compare this with `chunk()`, which loads 100 records at once but allows you to use collection methods, and `all()`, which loads the entire result set into memory.

## Caching Expensive Queries

For queries that are expensive and rarely change, wrap them in a cache call:

```php
$topCategories = Cache::remember('top_categories', 3600, function () {
 return Category::withCount('products')
 ->orderByDesc('products_count')
 ->take(10)
 ->get();
});
```

Prompt Claude Code: "Wrap this query in a cache call with a 1-hour TTL and a descriptive cache key." It will produce correctly structured cache code and suggest appropriate TTL values based on data volatility.

## Query Performance Comparison

| Method | Memory Usage | Query Count | Best For |
|---|---|---|---|
| `all()` | High | 1 | Small datasets, full processing |
| `chunk(n)` | Medium | ceil(total/n) | Batch updates, exports |
| `cursor()` | Very low | 1 (streaming) | Read-only iteration |
| `lazy()` | Low | 1 (streaming) | Lazy collections with filtering |

## Identifying Slow Queries

Claude Code can help you instrument your application for slow query detection. Ask it to add a query log listener to your `AppServiceProvider`:

```php
// app/Providers/AppServiceProvider.php
public function boot(): void
{
 if (config('app.debug')) {
 \DB::listen(function ($query) {
 if ($query->time > 100) { // Log queries slower than 100ms
 \Log::warning('Slow query detected', [
 'sql' => $query->sql,
 'bindings' => $query->bindings,
 'time_ms' => $query->time,
 ]);
 }
 });
 }
}
```

This listener is invaluable during development for catching performance regressions before they reach production.

## Soft Deletes and Data Retention

Soft deletes allow you to mark records as deleted without physically removing them from the database, which is important for audit trails and data recovery:

```php
// app/Models/Product.php
use Illuminate\Database\Eloquent\SoftDeletes;

class Product extends Model
{
 use SoftDeletes;
}
```

The migration must include the `softDeletes()` column:

```php
$table->softDeletes();
```

Once soft deletes are enabled, `Product::all()` automatically excludes deleted records. To include them, use `withTrashed()`. To query only deleted records, use `onlyTrashed()`. Restore a deleted record with `$product->restore()`.

Ask Claude Code: "Add soft deletes to the Product model and generate the migration change." It will handle both the trait addition and the correct `addColumn` migration syntax.

## Conclusion

Claude Code transforms Laravel Eloquent ORM development by generating correct relationship definitions, identifying performance bottlenecks, and suggesting best practices. The key is providing clear context about your Laravel version, database type, and specific use cases in your prompts.

Combine Claude Code with Laravel's built-in features like scopes, accessors, eager loading, observers, and soft deletes to build performant, maintainable applications. Use it to catch N+1 problems early, generate factory-based tests, and produce cast classes that keep your data layer consistent. Remember to test your Eloquent models thoroughly using the TDD skill to ensure your data layer remains reliable as your application grows.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-laravel-eloquent-orm-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Django ORM Optimization Guide](/claude-code-django-orm-optimization-guide/)
- [Claude Code for Drizzle ORM TypeScript Database Workflow](/claude-code-drizzle-orm-typescript-database-workflow/)
- [Claude Code Laravel Queues, Jobs, Workers & Workflow Guide](/claude-code-laravel-queues-jobs-workers-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



---

## Frequently Asked Questions

### What is Setting Up Your Laravel Project with Claude Code?

Setting up involves creating a CLAUDE.md file in your project root specifying your Laravel version (10+), PHP version (8.2+), database type (MySQL/PostgreSQL), and authentication package (e.g., Laravel Sanctum). This context ensures Claude Code generates code following correct Laravel conventions and avoids deprecated APIs from older versions. Paste migration files or describe your table structure so Claude Code produces correct column names, indexes, and relationship definitions automatically.

### What is Defining Models and Relationships?

Eloquent relationships are defined as methods on Model classes that return relationship objects. Claude Code generates both sides of relationships simultaneously for consistency. The key relationship types are `hasMany`/`belongsTo` (one-to-many), `belongsToMany` with pivot tables (many-to-many), and `morphTo`/`morphMany` (polymorphic). Specify the relationship type and any custom foreign keys in your prompt to get correct relationship definitions with proper `$fillable` arrays and `$casts` configurations.

### What is One-to-Many Relationships?

One-to-many relationships in Eloquent use `hasMany()` on the parent model and `belongsTo()` on the child model. For example, a Category model defines `return $this->hasMany(Product::class)` while Product defines `return $this->belongsTo(Category::class)` using `category_id` as the foreign key. Ask Claude Code to generate both sides simultaneously to keep models consistent. The `$casts` array on the child model handles type conversion for fields like `'price' => 'decimal:2'`.

### What is Many-to-Many Relationships?

Many-to-many relationships use `belongsToMany()` with an intermediate pivot table. For roles and permissions, the Role model defines `return $this->belongsToMany(Permission::class, 'role_permissions')->withTimestamps()`. For pivot tables storing additional data, use `withPivot(['assigned_by', 'assigned_at'])` and `using(UserRole::class)` with a custom Pivot model class. Claude Code generates both the relationship methods and the corresponding migration for the pivot table when prompted with "many-to-many" or "pivot table."

### What is Polymorphic Relationships?

Polymorphic relationships allow a model to belong to multiple parent types using `morphTo()` on the child and `morphMany()` on each parent. A Comment model uses `return $this->morphTo()` via the `commentable()` method, while Post and Video models each define `return $this->morphMany(Comment::class, 'commentable')`. The migration requires `commentable_id` and `commentable_type` columns. Ask Claude Code to "generate a migration for a polymorphic comments table" to get the correct column definitions and composite index.
