---
layout: default
title: "Claude Code RSpec Ruby BDD Workflow Guide"
description: "A practical guide to integrating Claude Code with RSpec for Behavior-Driven Development in Ruby. Learn AI-assisted BDD workflow, test writing, and Cucumber integration."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-rspec-ruby-bdd-workflow-guide/
---

# Claude Code RSpec Ruby BDD Workflow Guide

Integrating Claude Code into your RSpec and BDD workflow transforms how Ruby developers write, maintain, and debug tests. This guide provides practical strategies for combining Claude's AI capabilities with RSpec, Cucumber, and Behavior-Driven Development practices to accelerate your test-driven development cycle.

## Setting Up RSpec with Claude Code

Before implementing the workflow, ensure your Ruby project has RSpec properly configured alongside Claude Code. The combination works exceptionally well when your testing infrastructure is clean and organized.

Initialize RSpec in your project:

```bash
rails generate rspec:install
# or for plain Ruby gems
gem install rspec
rspec --init
```

Configure your `.rspec` file for optimal output:

```ruby
--require spec_helper
--format documentation
--color
--order random
```

Claude Code can navigate your RSpec setup quickly when you provide context about your Rails version, Ruby version, and testing dependencies. Include these details in your CLAUDE.md file for faster onboarding.

## Writing RSpec Tests with Claude Code

Claude Code excels at generating RSpec examples that follow BDD principles. When requesting test creation, specify the expected behavior rather than implementation details.

Request test generation using natural language:

```
Write RSpec tests for a User model that validates email format, 
requires password minimum length of 8 characters, and ensures 
unique usernames. Use shoulda-matchers where appropriate.
```

Claude Code produces well-structured specs following these patterns:

```ruby
RSpec.describe User do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:username) }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid').for(:email) }
    it { should validate_length_of(:password).is_at_least(8) }
  end
end
```

The generated tests follow RSpec best practices, including the use of Factory Bot, shoulda-matchers, and descriptive example names that document behavior.

## Implementing BDD with Cucumber and RSpec

Behavior-Driven Development in Ruby typically combines Cucumber's Gherkin syntax with RSpec for underlying step definitions. Claude Code helps bridge these two layers efficiently.

When working with Cucumber scenarios, describe the business behavior:

```gherkin
Feature: User registration
  As a new user
  I want to create an account
  So that I can access the platform

  Scenario: Successful registration with valid credentials
    Given I am on the registration page
    When I fill in "Email" with "newuser@example.com"
    And I fill in "Password" with "securepass123"
    And I fill in "Password confirmation" with "securepass123"
    And I click "Create Account"
    Then I should see "Welcome, newuser!"
    And I should be on the dashboard page
```

Claude Code generates corresponding step definitions:

```ruby
Given('I am on the registration page') do
  visit new_user_registration_path
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I click {string}') do |button|
  click_button button
end

Then('I should see {string}') do |message|
  expect(page).to have_content(message)
end
```

The step definitions follow the Arrange-Act-Assert pattern and integrate cleanly with Capybara for feature testing.

## Using the TDD Skill for Test-First Development

The claude-tdd skill specifically enhances test-driven development workflows. This skill emphasizes writing tests before implementation, a core BDD principle that improves code design and reduces bugs.

When using the TDD workflow with RSpec:

1. Write a failing test first
2. Run the test to confirm the failure
3. Implement the minimum code to pass
4. Refactor while keeping tests green

Claude Code with the TDD skill maintains this discipline by suggesting test cases based on requirements and helping you stay in the red-green-refactor loop.

For feature specs using RSpec, request comprehensive coverage:

```
Create a feature spec for the shopping cart functionality:
- Add items with quantity
- Update item quantities
- Remove items
- Calculate total with tax
- Apply discount codes
```

The skill generates detailed feature specs with Capybara DSL:

```ruby
RSpec.describe 'Shopping Cart', type: :feature do
  let(:product) { create(:product, price: 29.99) }
  
  scenario 'adding items to cart' do
    visit products_path
    click_button 'Add to Cart'
    
    expect(page).to have_content('1 item in cart')
    expect(page).to have_content('$29.99')
  end
  
  scenario 'updating quantity' do
    cart = create(:cart_with_items)
    visit cart_path(cart)
    
    fill_in 'quantity', with: 3
    click_button 'Update'
    
    expect(cart.total).to eq(89.97)
  end
end
```

## Managing Test Data with Factory Bot

Effective BDD requires clean, reproducible test data. Claude Code understands Factory Bot patterns and generates factories that support your test scenarios.

Request factory generation:

```
Create factories for:
- User (with associations)
- Order (with line items)
- Product (with variants)
- Address (for shipping/billing)
```

Claude Code produces well-structured factories:

```ruby
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    password { 'password123' }
    password_confirmation { 'password123' }
    
    trait :admin do
      role { 'admin' }
    end
    
    factory :admin_user, traits: [:admin]
  end
  
  factory :order do
    user
    sequence(:number) { |n| "ORD-#{n.to_s.rjust(6, '0')}" }
    
    trait :completed do
      status { 'completed' }
      completed_at { Time.current }
    end
  end
end
```

## Integrating Documentation Workflows

The pdf skill complements BDD workflows by generating test reports and documentation. After running your RSpec suite, use this skill to create formatted documentation for stakeholders.

The supermemory skill helps maintain context across test sessions, remembering which scenarios you've covered and identifying gaps in your test suite.

## Best Practices for RSpec and BDD Workflows

Follow these practices when combining Claude Code with RSpec:

- **Describe behavior, not implementation**: Write examples that document what the system does, not how it does it
- **Use context blocks liberally**: Group related examples with meaningful context descriptions
- **Keep examples independent**: Each test should run in isolation without relying on execution order
- **Leverage shared examples**: DRY up repetitive test patterns for similar behaviors
- **Tag tests appropriately**: Use metadata for filtering slow tests, integration tests, or feature-specific suites

Example of well-structured RSpec:

```ruby
RSpec.describe Order do
  describe '#total' do
    context 'with no line items' do
      let(:order) { build(:order, line_items: []) }
      
      it 'returns zero' do
        expect(order.total).to eq(0)
      end
    end
    
    context 'with multiple line items' do
      let(:order) do
        build(:order, line_items: [
          build(:line_item, quantity: 2, unit_price: 10.00),
          build(:line_item, quantity: 1, unit_price: 25.00)
        ])
      end
      
      it 'calculates sum of all items' do
        expect(order.total).to eq(45.00)
      end
    end
    
    context 'with tax applied' do
      let(:order) do
        build(:order, line_items: [build(:line_item, quantity: 1, unit_price: 100.00)],
             tax_rate: 0.08)
      end
      
      it 'includes tax in total' do
        expect(order.total).to eq(108.00)
      end
    end
  end
end
```

This structure makes tests self-documenting and easy to maintain when requirements change.

## Automating Test Maintenance

Claude Code assists with common RSpec maintenance tasks:

- **Converting legacy tests**: Update old-style shoulda tests to modern expect syntax
- **Adding missing coverage**: Identify untested branches and generate examples
- **Fixing flaky tests**: Analyze and resolve tests that pass intermittently
- **Refactoring test code**: Extract shared examples, reduce duplication

When refactoring, describe the desired structure:

```
Refactor these repetitive specs using shared examples:
- All resource controllers respond to JSON
- All admin-only actions redirect non-admins
- All create actions validate required fields
```

Claude Code produces clean, DRY test code that follows RSpec conventions.

## CI Integration and Reporting

Integrate your RSpec workflow with continuous integration:

```yaml
# .github/workflows/test.yml
name: RSpec Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
      - run: bundle install
      - run: bundle exec rspec --format progress --format RspecJunitFormatter --out test-results.xml
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: test-results.xml
```

Claude Code can generate CI configurations and help interpret test failures in CI environments.

## Conclusion

Combining Claude Code with RSpec and BDD practices creates a powerful development workflow. The AI assistant generates clean, maintainable tests following RSpec conventions, helps implement BDD with Cucumber, and supports the test-first mentality that leads to better-designed Ruby applications.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
