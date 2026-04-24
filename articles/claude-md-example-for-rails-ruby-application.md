---
layout: default
title: "CLAUDE.md Example for Rails and Ruby (2026)"
description: "CLAUDE.md Example for Rails and Ruby — practical guide with working examples, tested configurations, and tips for developer workflows."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-md-example-for-rails-ruby-application/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
geo_optimized: true
---
Using Claude with Markdown documentation in Rails and Ruby applications transforms how developers approach documentation, testing, and code generation. This guide provides concrete examples of integrating Claude into your Ruby workflow, showing practical patterns you can implement immediately. Whether you are working on a greenfield Rails 7 API or maintaining a decade-old monolith, the patterns here apply directly.

## Setting Up Claude for Ruby Projects

The first step involves configuring your Rails project to work effectively with Claude. Create a `CLAUDE.md` file in your project root. This file acts as persistent project context that Claude reads at the start of every session. It tells Claude about your Rails version, Ruby version, key dependencies, and team conventions. reducing back-and-forth and improving the accuracy of every code suggestion.

A minimal but effective `CLAUDE.md` for a Rails project looks like this:

```markdown
Project: MyApp

Stack
- Ruby 3.3.0
- Rails 7.1
- PostgreSQL 16
- Sidekiq for background jobs
- RSpec + Factory Bot for testing
- Pundit for authorization
- Devise for authentication

Conventions
- Service objects live in app/services/
- Presenters live in app/presenters/
- Use Interactor gem for multi-step business logic
- All controllers should be thin; push logic to service objects
- Prefer named scopes over raw where clauses in controllers

Testing rules
- Minimum 80% coverage enforced in CI
- Use FactoryBot, never fixtures
- Use shared_examples for repeated behavior
- Avoid stubbing ActiveRecord. prefer database-backed tests

Off-limits
- Do not use .all without a limit or scope
- Do not call external APIs directly from controllers
```

Pair this with a `Gemfile` that includes your development tooling so Claude understands what helpers are available:

```ruby
group :development, :test do
 gem 'rspec-rails'
 gem 'factory_bot_rails'
 gem 'faker'
 gem 'shoulda-matchers'
 gem 'simplecov', require: false
end

group :development do
 gem 'annotate' # adds schema comments to models
 gem 'bullet' # detects N+1 queries
 gem 'brakeman' # security scanning
end
```

When Claude understands your stack at session start, it generates more accurate code suggestions and documentation. It will stop recommending gems you do not use and will follow the naming conventions you have defined.

## Generating Model Documentation with Claude

One of the most valuable use cases involves using Claude to document your ActiveRecord models. Instead of manually writing documentation, you can describe your models and let Claude generate comprehensive Markdown files that explain associations, validations, enums, scopes, and business rules.

```ruby
app/models/user.rb
class User < ApplicationRecord
 has_many :posts, dependent: :destroy
 has_many :comments, dependent: :destroy
 has_one :profile, dependent: :destroy

 validates :email, presence: true, uniqueness: { case_sensitive: false }
 validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 30 }

 enum role: { user: 0, admin: 1, moderator: 2 }

 scope :active, -> { where(active: true) }
 scope :admins, -> { where(role: :admin) }
 scope :recent, -> { order(created_at: :desc) }

 before_save :normalize_email

 private

 def normalize_email
 self.email = email.downcase.strip
 end
end
```

For this model, ask Claude: "Generate full documentation for this ActiveRecord model including all associations, validations, enums, scopes, and any gotchas." Claude will produce a Markdown document suitable for your internal wiki or a `docs/models/user.md` file.

Claude is also useful for reviewing models against common Rails antipatterns. Ask it to check for missing indexes on foreign keys, N+1-prone associations, or validations that should be at the database level as well.

| Claude task | What to ask |
|---|---|
| Document model | "Generate Markdown docs for this model" |
| Audit for N+1 risk | "Which associations here risk N+1 queries?" |
| Suggest indexes | "What indexes should this table have?" |
| Review validations | "Are there validations that should also be DB constraints?" |

## Test-Driven Development with the TDD Skill

The tdd skill enhances your testing workflow significantly. When working on a new feature, describe the expected behavior and let Claude generate RSpec examples before you write the implementation. This forces you to think about the interface first and catches edge cases early.

Here is a realistic set of model specs for a `Post` model:

```ruby
spec/models/post_spec.rb
RSpec.describe Post, type: :model do
 describe 'associations' do
 it { should belong_to(:user) }
 it { should have_many(:comments).dependent(:destroy) }
 it { should have_many(:taggings) }
 it { should have_many(:tags).through(:taggings) }
 end

 describe 'validations' do
 it { should validate_presence_of(:title) }
 it { should validate_length_of(:title).is_at_most(200) }
 it { should validate_presence_of(:body) }

 it 'requires a unique slug' do
 create(:post, slug: 'existing-slug')
 duplicate = build(:post, slug: 'existing-slug')
 expect(duplicate).not_to be_valid
 expect(duplicate.errors[:slug]).to include('has already been taken')
 end
 end

 describe 'scopes' do
 describe '.published' do
 it 'returns only posts with published_at in the past' do
 published = create(:post, published_at: 1.day.ago)
 unpublished = create(:post, published_at: nil)
 scheduled = create(:post, published_at: 1.day.from_now)

 expect(Post.published).to include(published)
 expect(Post.published).not_to include(unpublished, scheduled)
 end
 end
 end

 describe '#reading_time' do
 it 'estimates 200 words per minute' do
 post = build(:post, body: ('word ' * 400).strip)
 expect(post.reading_time).to eq(2)
 end
 end
end
```

The tdd skill understands Rails conventions and generates tests that follow RSpec best practices. It suggests using Factory Bot effectively, recommends `shoulda-matchers` for boilerplate association and validation specs, and avoids common testing antipatterns like over-mocking or testing implementation details.

For request specs and controller-level tests, ask Claude to write specs that hit the full stack including authentication and authorization checks:

```ruby
spec/requests/api/v1/posts_spec.rb
RSpec.describe "Api::V1::Posts", type: :request do
 let(:user) { create(:user) }
 let(:headers) { auth_headers_for(user) }

 describe "GET /api/v1/posts" do
 it "returns paginated published posts" do
 create_list(:post, 15, :published)
 get "/api/v1/posts", headers: headers
 expect(response).to have_http_status(:ok)
 json = JSON.parse(response.body)
 expect(json['data'].length).to eq(10)
 expect(json['meta']['total']).to eq(15)
 end
 end

 describe "POST /api/v1/posts" do
 context "with valid params" do
 it "creates a post and returns 201" do
 post_params = { post: { title: "Hello", body: "World" * 10 } }
 post "/api/v1/posts", params: post_params, headers: headers
 expect(response).to have_http_status(:created)
 end
 end

 context "without authentication" do
 it "returns 401" do
 post "/api/v1/posts", params: {}
 expect(response).to have_http_status(:unauthorized)
 end
 end
 end
end
```

## Creating API Documentation

Rails API documentation benefits greatly from Claude's ability to generate OpenAPI specifications from controller code. Describe your endpoints and Claude helps create comprehensive documentation:

```ruby
app/controllers/api/v1/posts_controller.rb
module Api
 module V1
 class PostsController < ApplicationController
 before_action :authenticate_user!, except: [:index, :show]
 before_action :set_post, only: [:show, :update, :destroy]
 before_action :authorize_post!, only: [:update, :destroy]

 def index
 @posts = Post.published.includes(:user, :tags).page(params[:page]).per(10)
 render json: PostSerializer.new(@posts, meta: pagination_meta(@posts)).serializable_hash
 end

 def show
 render json: PostSerializer.new(@post, include: [:user, :comments]).serializable_hash
 end

 def create
 @post = current_user.posts.build(post_params)
 if @post.save
 render json: PostSerializer.new(@post).serializable_hash, status: :created
 else
 render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
 end
 end

 private

 def set_post
 @post = Post.friendly.find(params[:id])
 rescue ActiveRecord::RecordNotFound
 render json: { error: "Post not found" }, status: :not_found
 end

 def authorize_post!
 render json: { error: "Forbidden" }, status: :forbidden unless @post.user == current_user
 end

 def post_params
 params.require(:post).permit(:title, :body, :published_at, tag_ids: [])
 end
 end
 end
end
```

When you paste this controller into a Claude session and ask for OpenAPI YAML, it produces a spec covering all four endpoints, response schemas, error responses, and authentication requirements. For documentation that goes to stakeholders, use the pdf skill to generate downloadable documentation files or the docx skill to create formatted documentation for non-technical reviewers.

## Database Migration Documentation

Documenting migrations helps future developers understand schema evolution. When writing migrations, include descriptive comments that explain the business reason for the change, not just the mechanical operation:

```ruby
db/migrate/20260314000000_add_role_to_users.rb
class AddRoleToUsers < ActiveRecord::Migration[7.1]
 # Adds role-based access control to support the moderation system
 # introduced in v2.1. Replaces the boolean `admin` column with an
 # integer enum that Pundit policies read via User#role.
 #
 # Rollback: re-adds `admin` boolean and removes `role` column.
 # Data: existing admin users are backfilled to role = 1 before
 # the old column is dropped.
 def change
 add_column :users, :role, :integer, default: 0, null: false
 add_index :users, :role

 reversible do |dir|
 dir.up do
 User.reset_column_information
 User.where(admin: true).update_all(role: 1)
 end
 dir.down do
 User.reset_column_information
 User.where(role: 1).update_all(admin: true)
 end
 end

 remove_column :users, :admin, :boolean
 end
end
```

A few migration patterns where Claude adds the most value:

- Backfill safety: ask Claude to generate a migration that runs data backfills in batches to avoid locking large tables
- Index strategy: paste your migration and ask "what indexes are missing?"
- Reversibility audit: ask "is this migration safely reversible? What would happen on rollback?"
- Down method: ask Claude to fill in the `down` method when you have written only `up`

## Managing Project Context with Super Memory

The supermemory skill proves invaluable for maintaining project context across sessions. Store architectural decisions, coding standards, and team conventions so that every Claude session starts with full awareness of how your project is structured:

```markdown
Project Conventions

Naming
- Use snake_case for methods and variables
- Use PascalCase for classes and modules
- Use SCREAMING_SNAKE_CASE for constants
- Service objects end in a verb: UserRegistrationService, OrderCancellationService

Controller Patterns
- Use service objects for any logic beyond simple CRUD
- Return meaningful HTTP status codes. never return 200 with an error in the body
- Include pagination for all collection endpoints using Kaminari
- Serializers go in app/serializers/ using jsonapi-serializer

Testing
- Minimum 80% coverage enforced in CI
- Focus on request specs for API endpoints; unit specs for models and services
- Use shared examples for policy authorization tests
- Do not test private methods directly

Background Jobs
- All jobs go through Sidekiq
- Jobs should be idempotent. safe to run twice
- Use unique jobs (sidekiq-unique-jobs) for user-triggered actions
```

This context persists across Claude sessions, ensuring consistent responses aligned with your project standards. When you add a new convention, update the memory and Claude will immediately follow it in the next session.

## Frontend Integration Documentation

When your Rails application includes JavaScript frontend code, Claude helps maintain consistency across the stack. Document component interactions and ask Claude to review Stimulus controllers against your application's patterns:

```javascript
// javascript/controllers/post_form_controller.js
import { Controller } from "@hotwired/stimulus"
import { marked } from "marked"
import debounce from "debounce"

export default class extends Controller {
 static targets = ["title", "body", "preview", "charCount", "submitBtn"]
 static values = { minLength: { type: Number, default: 50 } }

 connect() {
 this.updatePreview = debounce(this._updatePreview.bind(this), 300)
 this._validate()
 }

 onBodyInput() {
 this.updatePreview()
 this._updateCharCount()
 this._validate()
 }

 _updatePreview() {
 this.previewTarget.innerHTML = marked.parse(this.bodyTarget.value)
 }

 _updateCharCount() {
 this.charCountTarget.textContent = `${this.bodyTarget.value.length} characters`
 }

 _validate() {
 const valid = this.titleTarget.value.length > 0 &&
 this.bodyTarget.value.length >= this.minLengthValue
 this.submitBtnTarget.disabled = !valid
 }
}
```

Claude understands Stimulus patterns and can suggest improvements to your frontend architecture. When you paste a Stimulus controller and ask "what could go wrong with this on mobile?" or "how would I add optimistic UI updates here?", the answers are grounded in your actual stack rather than generic JavaScript advice.

## Deployment and Environment Documentation

Document your deployment process using Markdown that Claude can reference. When an incident happens at 2am, clear documentation saves time. Claude can help generate runbooks from your Capistrano or Kamal configuration:

```yaml
config/deploy.rb
set :application, 'myapp'
set :repo_url, 'git@github.com:company/myapp.git'
set :deploy_to, '/var/www/myapp'
set :linked_files, %w[config/database.yml config/master.key .env.production]
set :linked_dirs, %w[log tmp/pids tmp/cache storage]

namespace :deploy do
 after :publishing, :restart

 task :restart do
 on roles(:app), in: :sequence, wait: 5 do
 execute :sudo, :systemctl, :restart, 'puma'
 end
 end

 task :seed do
 on roles(:db), primary: true do
 within release_path do
 with rails_env: fetch(:rails_env) do
 execute :rake, 'db:seed'
 end
 end
 end
 end
end
```

Paste this into Claude with your deployment steps and ask: "Write a deployment runbook in Markdown covering normal deploys, rollback procedure, and database migration failures." The result is a structured document you can commit to your repo under `docs/deployment.md`.

## Practical Workflow: The Full Loop

The highest-value workflow combines all of these pieces into a repeatable loop for every new feature:

1. Update `CLAUDE.md` with any new patterns introduced by the feature
2. Ask Claude to generate the migration and review it for safety
3. Ask Claude to generate the model with validations, associations, and scopes
4. Use the tdd skill to generate RSpec examples before writing implementation
5. Write the service object and ask Claude to review it against your conventions
6. Paste the controller and ask Claude to generate request specs and OpenAPI docs
7. Commit the updated `CLAUDE.md` along with the feature code

This loop keeps documentation current automatically, because the conventions you add to `CLAUDE.md` during a feature become the context that improves the next feature.

## Conclusion

Integrating Claude into your Rails and Ruby workflow dramatically improves documentation quality, testing coverage, and code consistency. The key lies in providing rich context through `CLAUDE.md`, maintaining conventions in the supermemory skill, and using specialized skills like tdd for testing, pdf for generated documentation, and supermemory for maintaining project knowledge. Start with one area. model documentation or test generation. and expand the workflow as your team becomes comfortable. The compound effect of consistent context means every session gets more useful over time.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-md-example-for-rails-ruby-application)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude MD Example for Flutter Mobile Application](/claude-md-example-for-flutter-mobile-application/)
- [Claude Code Code Example Generation Workflow](/claude-code-code-example-generation-workflow/)
- [Claude Code RSpec Ruby BDD Workflow Guide](/claude-code-rspec-ruby-bdd-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


