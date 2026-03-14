---
layout: default
title: "Claude Code Rails API Mode Full Stack Workflow"
description: "A comprehensive guide to building full stack Rails applications with API mode using Claude Code. Includes practical examples, skill recommendations, and workflow automation tips for developers."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-rails-api-mode-full-stack-workflow/
---

# Claude Code Rails API Mode Full Stack Workflow

Building a full stack Rails application with API mode has never been more efficient when you combine Rails 7's API capabilities with Claude Code's AI-assisted development workflow. This guide walks you through setting up a complete development pipeline that leverages Claude Code's skills for testing, frontend generation, and documentation.

## Why Rails API Mode for Full Stack Development

Rails API mode strips down the Rails stack to only the components needed for building JSON APIs. When paired with a modern frontend framework, you get a clean separation of concerns while maintaining the rapid development experience Rails is known for. The workflow is particularly effective for teams building SPAs, mobile backends, or any application requiring a robust API foundation.

## Setting Up Your Rails API Backend

Start by creating a new Rails application in API mode. Claude Code can generate the entire setup with a single well-crafted prompt:

```bash
rails new myapp --api --database=postgresql
```

The API mode configuration automatically configures ActiveRecord, ActionController, and ActionView for JSON responses. You'll want to add authentication early in the process. Devise Token Auth provides token-based authentication perfect for SPA and mobile integrations.

Add these gems to your Gemfile for a production-ready API setup:

```ruby
gem 'devise_token_auth'
gem 'rack-cors'
gem 'jsonapi-serializer'
gem 'pagy'
```

The rack-cors gem is essential when your frontend lives on a different domain or port during development. Configure it in config/initializers/cors.rb to allow requests from your frontend origin.

## Structuring Your API for Claude Code

Organize your controllers following RESTful conventions. Claude Code excels at understanding well-structured codebases, so consistent routing helps the AI assist with debugging and feature implementation.

```
app/controllers/api/v1/
├── articles_controller.rb
├── users_controller.rb
└── application_controller.rb
```

Use serializers to control your JSON output. JSONAPI::Serializer keeps your API responses consistent and includes relationship linking automatically:

```ruby
class ArticleSerializer
  include JSONAPI::Serializer
  attributes :title, :content, :created_at, :author
  belongs_to :author, serializer: UserSerializer
end
```

## Frontend Integration with Claude Code Skills

For the frontend, Claude Code pairs excellently with React, Vue, or any modern framework. The frontend-design skill helps generate component structures and styling patterns that match your Rails backend's data structures.

When integrating with a Rails API, establish clear contracts between your frontend and backend. JSON:API format provides a consistent structure that both Claude Code and your frontend can rely on:

```json
{
  "data": {
    "id": "1",
    "type": "articles",
    "attributes": {
      "title": "Getting Started with Rails API",
      "content": "..."
    },
    "relationships": {
      "author": {
        "data": { "id": "42", "type": "users" }
      }
    }
  }
}
```

## Testing Strategy with TDD Skill

The tdd skill transforms your testing workflow. For Rails API development, focus on three testing layers:

**Model tests** verify business logic and validations. Your Article model might need title presence and content length validations:

```ruby
class Article < ApplicationRecord
  validates :title, presence: true, length: { minimum: 5 }
  validates :content, presence: true
  
  belongs_to :author, class_name: 'User'
end
```

**Request tests** validate your API endpoints respond correctly. RSpec request specs test the complete flow from HTTP request to JSON response:

```ruby
describe 'GET /api/v1/articles' do
  let!(:articles) { create_list(:article, 5) }
  
  it 'returns all articles' do
    get '/api/v1/articles'
    
    expect(response).to have_http_status(:ok)
    expect(json['data'].size).to eq(5)
  end
end
```

**System tests** ensure your frontend integration works correctly when using a full stack approach with Rails views or when testing JavaScript interactions.

## Automating Documentation

The pdf skill generates API documentation from your Rails routes and controller comments. For API documentation, consider adding rswag to generate OpenAPI specs automatically:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api'
  
  namespace :api do
    namespace :v1 do
      resources :articles
    end
  end
end
```

Rswag generates interactive Swagger UI documentation that your frontend team can reference while building their integration. Claude Code can help explain existing endpoints and generate additional documentation when you add new features.

## Memory and Context Management

For larger projects, the supermemory skill helps maintain context across Claude Code sessions. When working on a complex Rails API with multiple resources and relationships, supermemory tracks:

- Database schema decisions and their rationale
- API versioning strategy and migration paths
- Authentication flow implementation details

This persistent context means Claude Code remembers your specific implementation choices across different development sessions, reducing the need to re-explain project conventions.

## Workflow Optimization Tips

**Prompt structure matters**. When working with Claude Code on your Rails API, be specific about the layer you're modifying:

- "Add a before_action to authenticate the user in the ApplicationController"
- "Create a JSON serializer for the Article model with author included"
- "Write a request spec for creating a new article"

**Use the resume flag** for long-running tasks. If Claude Code is generating multiple files or making extensive changes, the --resume flag helps pick up where you left off:

```bash
claude --resume
```

**Batch related changes**. Instead of making several small requests, describe the complete feature you want to implement. For example: "Create a new endpoint for filtering articles by category, add the route, controller action, serializer, and corresponding spec."

## Common Integration Patterns

Your Rails API will frequently need to handle relationships, nested resources, and filtering. Claude Code excels at implementing these patterns when you describe them clearly:

```ruby
# Nested resource for articles belonging to a user
resources :users do
  resources :articles, controller: 'api/v1/user_articles'
end
```

For filtering, query parameters keep your URLs clean:

```ruby
def index
  articles = Article.all
  
  articles = articles.where(category: params[:category]) if params[:category]
  articles = articles.order(created_at: :desc).limit(params[:limit])
  
  render json: ArticleSerializer.new(articles)
end
```

## Deployment Considerations

When deploying your Rails API, ensure your CORS configuration matches your production domain. Environment variables handle API keys and secrets:

```ruby
# config/initializers/cors.rb
Rails.application.config.cors_allowed_origins = ENV.fetch('CORS_ORIGINS', '').split(',')
```

Your frontend deployment (Vercel, Netlify, or similar) needs to point to your Rails API's production URL. Set this in your frontend's environment configuration rather than hardcoding URLs.

---

This workflow combines Rails' backend strength with Claude Code's AI capabilities, creating a development experience that handles the entire full stack development cycle. The key is maintaining clear API contracts and leveraging Claude Code's skills for testing and documentation generation at each layer of your application.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
