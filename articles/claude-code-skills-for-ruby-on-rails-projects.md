---
layout: default
title: "Claude Code Skills for Ruby on Rails"
description: "Practical Claude Code skills that accelerate Ruby on Rails development: code generation, testing, database optimization, and API integration."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [tutorials]
tags: [claude-code, claude-skills, ruby, rails, testing]
author: "Claude Skills Guide"
reviewed: true
score: 8
permalink: /claude-code-skills-for-ruby-on-rails-projects/
geo_optimized: true
---

# Claude Code Skills for Ruby on Rails Projects

Ruby on Rails developers benefit significantly from Claude Code's specialized skills. These tools automate scaffolding, enhance test coverage, optimize database queries, and streamline API integrations. This guide covers practical skills that integrate directly into Rails workflows.

rails-generator: Scaffolding and Code Generation

[The rails-generator skill accelerates Rails application setup](/claude-skill-md-format-complete-specification-guide/) and CRUD operations. Instead of manually writing models, controllers, and views, invoke this skill to generate functional code structures.

```bash
Generate a complete resource with associations
"Create a Blog app with posts that belong to users and have comments"
```

This generates migration files, models with relationships, RESTful controllers, and ERB views. The skill understands Rails conventions and produces code following REST principles.

For more complex scenarios, specify custom attributes and validations:

```bash
"Generate a Product model with name:string, price:decimal, stock:integer, 
category:references, and validations for presence and uniqueness"
```

The output includes migration files, model code with associations and validations, controller actions, and corresponding view templates.

rspec-helper: Test-Driven Development

[The rspec-helper skill implements test-driven development patterns](/claude-tdd-skill-test-driven-development-workflow/) specific to Rails. It generates comprehensive test suites covering model validations, controller actions, and request specs.

```bash
Generate tests for a User model
"Write RSpec tests for a User model with email validation, password encryption,
and associations to posts and comments"
```

This produces model specs withshoulda-matchers configurations:

```ruby
RSpec.describe User, type: :model do
 it { should validate_presence_of(:email) }
 it { should validate_uniqueness_of(:email).case_insensitive }
 it { should have_many(:posts).dependent(:destroy) }
 it { should have_many(:comments).dependent(:destroy) }
 
 context "password encryption" do
 it "creates encrypted password using BCrypt" do
 user = User.create(email: "test@example.com", password: "password123")
 expect(user.encrypted_password).not_to be_empty
 end
 end
end
```

For controller testing, specify the resource and actions needed:

```bash
"Generate controller specs for PostsController with RESTful actions and 
authentication using Devise"
```

active-record-tuner: Query Optimization

The [active-record-tuner skill analyzes and optimizes database queries](/claude-code-skills-for-golang-microservices/) in Rails applications. It identifies N+1 queries, missing indexes, and inefficient joins.

```bash
Analyze query performance
"Find N+1 queries in the PostsController#index action"
```

The skill provides specific fixes:

```ruby
Before: N+1 query problem
@posts = Post.all
@posts.each do |post|
 puts post.author.name # Triggers separate query each iteration
end

After: Eager loading
@posts = Post.includes(:author).all
@posts.each do |post|
 puts post.author.name # Uses preloaded author data
end
```

For complex queries, request optimization suggestions:

```ruby
Original slow query
Post.where("created_at > ?", 1.week.ago)
 .order(:comments_count)
 .limit(10)

Optimized with counter cache
Post.where("posts.created_at > ?", 1.week.ago)
 .order("posts.comments_count DESC")
 .limit(10)
 .to_a
```

The skill also suggests appropriate database indexes based on query patterns:

```bash
"Add indexes to improve performance for user dashboard queries showing 
recent orders and pending notifications"
```

rails-api-builder: REST and GraphQL APIs

The rails-api-builder skill scaffolds API endpoints following Rails best practices. It generates JSON serializers, and supports both REST and GraphQL implementations.

```bash
Generate a REST API for products
"Create a JSON API for Products with CRUD operations, pagination, and 
filtering by category and price range"
```

The skill produces controller code with proper response formatting:

```ruby
class Api::ProductsController < ApplicationController
 def index
 products = Product.ransack(params[:q]).result
 .page(params[:page])
 .per(params[:per_page] || 25)
 
 render json: {
 data: products.map { |p| ProductSerializer.new(p) },
 meta: {
 current_page: products.current_page,
 total_pages: products.total_pages,
 total_count: products.total_count
 }
 }
 end
 
 def show
 product = Product.find(params[:id])
 render json: ProductSerializer.new(product)
 end
end
```

For GraphQL integration:

```bash
"Generate GraphQL mutations and queries for a Product type with 
connections and filtering support"
```

migration-manager: Schema Management

The migration-manager skill handles Rails database migrations intelligently. It creates clean migration files, handles schema changes safely, and rollback procedures.

```bash
Generate a migration with proper constraints
"Create a migration to add a status column to Orders with an enum 
and a default value of pending"
```

The skill outputs properly structured migrations:

```ruby
class AddStatusToOrders < ActiveRecord::Migration[7.1]
 def change
 add_column :orders, :status, :integer, default: 0, null: false
 add_index :orders, :status
 add_index :orders, [:user_id, :status]
 end
end
```

For complex schema changes, request data migration strategies:

```bash
"Create a migration to split the name column into first_name and last_name,
including a data migration to populate the new columns from existing records"
```

sidekiq-worker: Background Job Setup

The sidekiq-worker skill configures background processing for Rails applications. It generates worker classes, monitors job queues, and handles error retry logic.

```bash
Create a worker for sending welcome emails
"Generate a Sidekiq worker for sending welcome emails with retry logic
and rate limiting"
```

Output includes the worker class and configuration:

```ruby
class WelcomeEmailWorker
 include Sidekiq::Worker
 sidekiq_options retry: 3, queue: :mailers
 
 def perform(user_id)
 user = User.find(user_id)
 UserMailer.welcome(user).deliver_now
 rescue ActiveRecord::RecordNotFound
 # Handle case where user was deleted before job executed
 Rails.logger.warn "User #{user_id} not found for welcome email"
 end
end
```

Invoke jobs from controllers or models:

```bash
Trigger the worker
"Add code to call the WelcomeEmailWorker after user registration"
```

## Conclusion

These Claude Code skills transform Ruby on Rails development workflows. From generating scaffolded code to optimizing database queries and managing background jobs, each skill targets specific problems in Rails development. Integrate these skills into your workflow to reduce boilerplate code, improve test coverage, and build reliable Rails applications faster.

Start by invoking one skill for your next Rails task:

```bash
"Generate a new scaffold for a Task model with title:string, 
description:text, due_date:date, and status:integer"
```

## Advanced: Generating Complex Rails Features

Claude Code handles complex Rails patterns that typically require significant boilerplate. Some of the most time-saving use cases:

Polymorphic associations: Describe the relationship and Claude generates the migration, model macros, and the corresponding controller logic:

```ruby
Prompt: "Generate a polymorphic comment system for Posts and Articles"
Claude generates:
class Comment < ApplicationRecord
 belongs_to :commentable, polymorphic: true
 validates :body, presence: true, length: { minimum: 10, maximum: 2000 }
end

class Post < ApplicationRecord
 has_many :comments, as: :commentable, dependent: :destroy
end

class Article < ApplicationRecord
 has_many :comments, as: :commentable, dependent: :destroy
end
```

Background jobs with error handling: Describe retry logic and Claude generates the complete Sidekiq job with exponential backoff:

```ruby
class EmailDeliveryJob < ApplicationJob
 queue_as :emails
 retry_on Net::SMTPServerBusy, wait: :exponentially_longer, attempts: 5
 discard_on ActiveJob::DeserializationError

 def perform(user_id, template_name, params = {})
 user = User.find(user_id)
 UserMailer.with(user: user, params).public_send(template_name).deliver_now
 end
end
```

## Step-by-Step: Using Claude Code for a New Feature

1. Describe the feature in plain English: "Add a user reputation system where posts can be upvoted and downvoted, with reputation affecting user permissions"
2. Claude Code generates the migration files, model changes, and controller actions
3. Use the `tdd` skill to generate RSpec specs for the reputation logic before implementing
4. Run the specs to confirm behavior expectations match your intent
5. Implement the feature and iterate with Claude Code for edge cases
6. Use `supermemory` to store the reputation system's rules so future prompts in this project have context

## Comparison with Rails Scaffolding

| Feature | Claude Code | `rails generate scaffold` | Manual coding |
|---|---|---|---|
| Custom business logic | Yes | No (generic CRUD) | Yes |
| Test generation | Yes (via tdd skill) | Basic fixtures | Manual |
| Complex associations | Yes | No | Manual |
| Service objects | Yes | No | Manual |
| Time to working code | Minutes | Seconds (but needs customization) | Hours |

Claude Code wins for features with custom logic. `rails generate scaffold` wins for standard CRUD resources where you just need the skeleton.

## Troubleshooting Common Issues

Generated migrations conflicting with existing schema: Always review generated migrations before running `rails db:migrate`. Claude Code works from a description, not direct database inspection, so check for column name conflicts or missing indexes.

RSpec specs failing due to factory setup: When Claude Code generates specs, it may assume FactoryBot factories exist that do not. Add the missing factories before running the test suite.

Generated code not following your project conventions: Provide Claude Code with a brief style guide in your prompt: "Use service objects in `app/services/`, never put business logic in controllers, use keyword arguments for all service object `call` methods."

N+1 queries in generated associations: Claude Code often generates clean code but may not include eager loading. After generating controller code, check the query log with `bullet` gem enabled and add `.includes()` where needed.

These Claude Code skills transform Ruby on Rails development workflows. Integrate them into your workflow to reduce boilerplate, improve test coverage, and build reliable Rails applications faster.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-skills-for-ruby-on-rails-projects)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Automated Testing Pipeline with Claude TDD Skill](/claude-tdd-skill-test-driven-development-workflow/). apply TDD patterns to Rails testing with RSpec
- [Claude Code Skills for Golang Microservices](/claude-code-skills-for-golang-microservices/). compare microservice development patterns across languages
- [Claude Skill MD Format Complete Specification Guide](/claude-skill-md-format-complete-specification-guide/). build custom Rails-specific skills for your project
- [Use Cases Hub](/use-cases-hub/). explore Claude Code skills for web application development
- [Claude Skills vs Claude AI Projects — When to Use Code Skills vs Web-Based Project Instructions — 20](/claude-skills-vs-claude-ai-projects/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


