---

layout: default
title: "Claude Code Laravel Eloquent ORM Guide"
description: "Master Laravel Eloquent ORM with Claude Code. Learn relationship handling, query scopes, eager loading, and performance optimization techniques."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-laravel-eloquent-orm-guide/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
---


# Claude Code Laravel Eloquent ORM Guide

Building robust Laravel applications requires mastering Eloquent ORM, and Claude Code can significantly accelerate your learning curve and development speed. This guide walks you through practical techniques for working with Eloquent, from basic model relationships to advanced query optimization.

## Setting Up Your Laravel Project with Claude Code

Before diving into Eloquent, ensure Claude Code understands your Laravel project structure. Create a CLAUDE.md file in your project root:

```
This is a Laravel 10+ application using PHP 8.2+. The project uses:
- Eloquent ORM for database interactions
- MySQL/PostgreSQL database
- Laravel Sanctum for API authentication
```

With this context, Claude Code will generate code that follows Laravel conventions and uses appropriate Eloquent methods.

## Defining Models and Relationships

Eloquent's power lies in its relationship handling. Let's examine how Claude Code helps you define models with proper relationships.

### One-to-Many Relationships

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

### Many-to-Many Relationships

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

### Nested Eager Loading

For deeper relationships:

```php
$categories = Category::with('products.reviews.user')->get();
```

This loads categories, their products, product reviews, and the user who created each review in just three queries instead of hundreds.

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

## Working with the TDD Skill

When building Eloquent models and relationships, the TDD skill helps you write tests first:

```bash
# Install the tdd skill
claude code install tdd
```

With TDD, you define expected behavior before implementation:

```php
// tests/Unit/ProductTest.php
/** @test */
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

## Generating Documentation with PDF Skills

For team documentation, use the pdf skill to generate comprehensive API documentation:

```
claude code install pdf
```

This helps you create printable documentation of your Eloquent models and their relationships, useful for onboarding new team members.

## Performance Optimization Tips

1. **Index foreign keys**: Always add database indexes to foreign key columns
2. **Use select()**: Only fetch required columns when you don't need the full model
3. **Chunk results**: For large datasets, use `chunk()` or `cursor()` to process records in batches
4. **Cache relationships**: For frequently accessed but rarely changed data, use relationship caching

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

## Conclusion

Claude Code transforms Laravel Eloquent ORM development by generating correct relationship definitions, identifying performance bottlenecks, and suggesting best practices. The key is providing clear context about your Laravel version, database type, and specific use cases in your prompts.

Combine Claude Code with Laravel's built-in features like scopes, accessors, and eager loading to build performant applications. Remember to test your Eloquent models thoroughly using the TDD skill to ensure your data layer remains reliable as your application grows.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
