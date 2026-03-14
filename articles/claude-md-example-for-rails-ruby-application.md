---
layout: default
title: "Claude MD Example for Rails Ruby Application"
description: "A practical guide to using Claude with Markdown for Rails and Ruby development workflows."
date: 2026-03-14
author: theluckystrike
permalink: /claude-md-example-for-rails-ruby-application/
---

Using Claude with Markdown documentation in Rails and Ruby applications transforms how developers approach documentation, testing, and code generation. This guide provides concrete examples of integrating Claude into your Ruby workflow, showing practical patterns you can implement immediately.

## Setting Up Claude for Ruby Projects

The first step involves configuring your Rails project to work effectively with Claude. Create a `.claude` directory in your project root and add a `settings.local.md` file that defines project-specific context. This file tells Claude about your Rails version, Ruby version, and key dependencies.

```ruby
# Gemfile snippets for documentation workflow
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end
```

When Claude understands your stack, it generates more accurate code suggestions and documentation. Specify your Rails version and any custom configurations in the settings file to improve response quality.

## Generating Model Documentation with Claude

One of the most valuable use cases involves using Claude to document your ActiveRecord models. Instead of manually writing documentation, you can describe your models and let Claude generate comprehensive Markdown files.

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_many :posts
  has_many :comments
  validates :email, presence: true, uniqueness: true
  enum role: { user: 0, admin: 1, moderator: 2 }
  
  scope :active, -> { where(active: true) }
end
```

For this model, Claude can generate documentation covering associations, validations, enums, and scopes. The documentation becomes particularly useful when onboarding new team members or maintaining legacy codebases.

## Test-Driven Development with the TDD Skill

The tdd skill enhances your testing workflow significantly. When working on a new feature, describe the expected behavior and let Claude generate RSpec examples:

```ruby
# spec/models/post_spec.rb
RSpec.describe Post do
  describe 'validations' do
    it 'requires a title' do
      post = Post.new(body: 'Content without title')
      expect(post).not_to be_valid
    end
    
    it 'requires a unique slug' do
      create(:post, title: 'First Post', slug: 'first-post')
      duplicate = build(:post, title: 'Another Post', slug: 'first-post')
      expect(duplicate).not_to be_valid
    end
  end
end
```

The tdd skill understands Rails conventions and generates tests that follow RSpec best practices. It suggests using Factory Bot effectively and avoids common testing antipatterns.

## Creating API Documentation

Rails API documentation benefits greatly from Claude's ability to generate OpenAPI specifications from controller code. Describe your endpoints and Claude helps create comprehensive documentation:

```ruby
# app/controllers/api/v1/posts_controller.rb
module Api
  module V1
    class PostsController < ApplicationController
      before_action :authenticate_user!, except: [:index, :show]
      
      def index
        @posts = Post.published.page(params[:page])
        render json: @posts
      end
      
      def show
        @post = Post.friendly.find(params[:id])
        render json: @post
      end
      
      def create
        @post = current_user.posts.build(post_params)
        if @post.save
          render json: @post, status: :created
        else
          render json: @post.errors, status: :unprocessable_entity
        end
      end
    end
  end
end
```

For API documentation, use the pdf skill to generate downloadable documentation files or the docx skill to create formatted documentation for stakeholder reviews.

## Database Migration Documentation

Documenting migrations helps future developers understand schema evolution. When writing migrations, include descriptive comments:

```ruby
# db/migrate/20260314000000_add_role_to_users.rb
class AddRoleToUsers < ActiveRecord::Migration[7.1]
  # This migration adds role-based access control to support
  # the new moderation system introduced in v2.1
  def change
    add_column :users, :role, :integer, default: 0, null: false
    add_index :users, :role
    
    # Backfill existing admins
    User.where(admin: true).update_all(role: :admin)
    remove_column :users, :admin
  end
end
```

Claude can review your migrations and suggest improvements, ensuring backward compatibility and proper indexing strategies.

## Managing Project Context with Super Memory

The supermemory skill proves invaluable for maintaining project context across sessions. Store architectural decisions, coding standards, and team conventions:

```markdown
# Project Conventions

## Naming
- Use snake_case for methods and variables
- Use PascalCase for classes and modules
- Use SCREAMING_SNAKE_CASE for constants

## Controller Patterns
- Use service objects for complex business logic
- Return meaningful HTTP status codes
- Include pagination for collection endpoints

## Testing
- Minimum 80% coverage required
- Focus on integration tests for critical paths
- Use shared examples for common behaviors
```

This context persists across Claude sessions, ensuring consistent responses aligned with your project standards.

## Frontend Integration Documentation

When your Rails application includes JavaScript frontend code, the frontend-design skill helps maintain consistency. Document component interactions:

```javascript
// javascript/components/PostForm.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "content", "preview"]
  
  initialize() {
    this.debouncedUpdate = _.debounce(this.updatePreview, 300)
  }
  
  updatePreview() {
    this.previewTarget.innerHTML = marked(this.contentTarget.value)
  }
  
  validate() {
    return this.titleTarget.value.length > 0 &&
           this.contentTarget.value.length > 10
  }
}
```

Claude understands Stimulus patterns and can suggest improvements to your frontend architecture.

## Deployment and Environment Documentation

Document your deployment process using Markdown that Claude can reference:

```yaml
# config/deploy.rb
set :application, 'my_rails_app'
set :repo_url, 'git@github.com:company/my_rails_app.git'
set :deploy_to, '/var/www/my_rails_app'

namespace :deploy do
  task :restart do
    on roles(:app), in: :sequence do
      execute :sudo, :systemctl, :restart, 'puma'
    end
  end
end
```

Maintain environment-specific documentation for staging and production configurations to help team members understand deployment workflows.

## Conclusion

Integrating Claude into your Rails and Ruby workflow dramatically improves documentation quality, testing coverage, and code consistency. The key lies in providing proper context through settings files and leveraging specialized skills like tdd for testing, pdf for generated documentation, and supermemory for maintaining project knowledge. Start with one area—perhaps model documentation or test generation—and expand from there as your team becomes comfortable with the workflow.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
