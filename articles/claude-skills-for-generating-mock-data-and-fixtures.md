---
layout: default
title: "Claude Skills for Generating Mock Data and Fixtures"
description: "A practical guide to using Claude Code skills for generating mock data and test fixtures. Real examples for developers building applications with realistic test data."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, claude-skills, mock-data, fixtures, testing, development]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /claude-skills-for-generating-mock-data-and-fixtures/
---

# Claude Skills for Generating Mock Data and Fixtures

Generating realistic [mock data](/claude-skills-guide/automated-testing-pipeline-with-claude-tdd-skill-2026/) and test fixtures is a common pain point in software development. Whether you are building a new application, writing automated tests, or prototyping features, having access to well-structured fake data accelerates your workflow significantly. Claude Code skills offer a powerful approach to generating this data without external libraries or manual data entry.

## Understanding Mock Data Generation in Claude

[Claude Code handles mock data generation through its skill system](/claude-skills-guide/best-claude-code-skills-to-install-first-2026/) When you invoke a skill focused on data generation, Claude uses its understanding of data structures, programming patterns, and domain-specific requirements to produce realistic test data. The key advantage is that Claude generates data that matches your specific data models rather than generic random values.

The primary approach for mock data generation is through custom skills you build for your domain-specific needs, or by describing your requirements directly to Claude Code without a skill. Each skill loads instructions that guide Claude's output to produce structured, type-safe data matching your project requirements.

## Creating a Basic Mock Data Skill

The simplest approach involves creating a custom skill file in your Claude skills directory. This skill contains prompts that tell Claude exactly what data structure you need:

```markdown
# Mock Data Generation Skill

When the user asks for mock data or test fixtures, generate realistic sample data based on the data models they describe. 

For each field, apply these rules:
- IDs should use UUID v4 format
- Names should be realistic full names
- Emails should match the name pattern
- Dates should be within the past 2 years
- Numeric values should fall within realistic business ranges
- Arrays should contain 3-10 items unless specified otherwise

Output data in the requested format (JSON, YAML, or code literals).
```

Save this as `~/.claude/skills/mock-data.md` and invoke it with `/mock-data` in your Claude session.

## Generating JSON Fixtures for API Testing

A practical use case involves generating JSON fixtures that mimic your API responses. This is particularly useful when building frontend applications that need to consume API data before the backend is fully developed.

Consider a user profile endpoint that returns:

```json
{
  "id": "user_123abc",
  "email": "sarah.johnson@example.com",
  "profile": {
    "firstName": "Sarah",
    "lastName": "Johnson",
    "avatar": "https://api.example.com/avatars/sarah.jpg",
    "bio": "Software engineer with 8 years of experience",
    "location": "San Francisco, CA"
  },
  "subscription": {
    "plan": "pro",
    "status": "active",
    "renewalDate": "2026-06-15T00:00:00Z"
  },
  "createdAt": "2024-01-20T10:30:00Z"
}
```

Ask Claude to generate multiple variations:

```
/mock-data
Generate 5 user profile JSON objects with varied subscription plans (free, starter, pro, enterprise), different account ages, and realistic variation in profile fields.
```

Claude produces five distinct fixtures with realistic variations, which you can save directly to your test fixtures directory:

```json
[
  {
    "id": "user_8f3a2b1c",
    "email": "michael.chen@example.com",
    "profile": {
      "firstName": "Michael",
      "lastName": "Chen",
      "avatar": "https://api.example.com/avatars/michael.jpg",
      "bio": "Product manager focused on developer tools",
      "location": "Seattle, WA"
    },
    "subscription": {
      "plan": "enterprise",
      "status": "active",
      "renewalDate": "2026-09-01T00:00:00Z"
    },
    "createdAt": "2023-03-15T14:22:00Z"
  },
  {
    "id": "user_7c9d4e2f",
    "email": "emma.wilson@example.com",
    "profile": {
      "firstName": "Emma",
      "lastName": "Wilson",
      "avatar": "https://api.example.com/avatars/emma.jpg",
      "bio": "UX designer and accessibility advocate",
      "location": "Portland, OR"
    },
    "subscription": {
      "plan": "free",
      "status": "active",
      "renewalDate": null
    },
    "createdAt": "2025-11-02T09:15:00Z"
  }
]
```

## Python Fixtures with Faker and Factory Boy

For Python projects using pytest, you can combine Claude skills with established libraries like Faker and Factory Boy. Describe your data models to Claude and it generates the factory classes:

```python
# tests/factories.py
import factory
from faker import Faker

fake = Faker()

class UserFactory(factory.Factory):
    class Meta:
        model = dict

    id = factory.LazyFunction(lambda: f"user_{fake.uuid4()}")
    email = factory.LazyFunction(lambda: fake.email())
    username = factory.LazyFunction(lambda: fake.user_name())
    created_at = factory.LazyFunction(lambda: fake.date_time_between(start_date="-2y"))
    is_active = factory.LazyFunction(lambda: fake.boolean(chance_of_getting_true=85))
    role = factory.LazyFunction(lambda: fake.random_element(["admin", "user", "moderator"]))


class OrderFactory(factory.Factory):
    class Meta:
        model = dict

    id = factory.LazyFunction(lambda: f"order_{fake.uuid4()}")
    user_id = factory.LazyFunction(lambda: f"user_{fake.uuid4()}")
    total = factory.LazyFunction(lambda: round(fake.pydecimal(min_value=10, max_value=1000, positive=True), 2))
    status = factory.LazyFunction(lambda: fake.random_element(["pending", "processing", "shipped", "delivered"]))
    items_count = factory.LazyFunction(lambda: fake.random_int(min=1, max=15))
    created_at = factory.LazyFunction(lambda: fake.date_time_between(start_date="-1y"))
```

Ask Claude to generate these factories from your database schema or API documentation. The output integrates directly with pytest fixtures:

```python
# tests/conftest.py
import pytest
from tests.factories import UserFactory, OrderFactory

@pytest.fixture
def sample_user():
    return UserFactory()

@pytest.fixture
def sample_users():
    return [UserFactory() for _ in range(5)]

@pytest.fixture
def sample_order():
    return OrderFactory()

@pytest.fixture
def sample_orders_with_users():
    user = UserFactory()
    orders = [OrderFactory(user_id=user["id"]) for _ in range(3)]
    return {"user": user, "orders": orders}
```

## Generating Database Seed Scripts

For database development and testing, Claude skills can generate SQL or ORM seed scripts. Describe your schema and requirements:

```
/mock-data
Generate a PostgreSQL seed script that inserts 50 users with varied subscription tiers, 200 orders distributed across those users, and 500 order line items. Include realistic foreign key relationships and varied order statuses.
```

Claude produces executable SQL:

```sql
-- seeds/test_data.sql

-- Users
INSERT INTO users (id, email, name, subscription_tier, created_at)
VALUES 
  ('usr_001', 'alice.martinez@example.com', 'Alice Martinez', 'enterprise', '2024-02-15 10:30:00'),
  ('usr_002', 'david.kim@example.com', 'David Kim', 'pro', '2024-05-22 14:45:00'),
  -- ... 48 more rows
  ('usr_050', 'jennifer@example.com', 'Jennifer Foster', 'free', '2025-12-01 09:00:00');

-- Orders (distributed across users with varied statuses)
INSERT INTO orders (id, user_id, status, total, created_at)
SELECT 
  'ord_' || gen_random_uuid(),
  'usr_' || LPAD((random() * 49 + 1)::INT::TEXT, 3, '0'),
  (ARRAY['pending', 'processing', 'shipped', 'delivered', 'cancelled'])[floor(random() * 5 + 1)],
  (random() * 490 + 10)::DECIMAL(10,2),
  NOW() - (random() * 365 || ' days')::INTERVAL
FROM generate_series(1, 200);
```

## TypeScript Mock Data with Zod Schemas

When building TypeScript applications with Zod for runtime validation, generate mock data that conforms to your schemas:

```typescript
// src/schemas/user.schema.ts
import { z } from 'zod';

export const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.object({
    first: z.string().min(1),
    last: z.string().min(1),
  }),
  age: z.number().int().min(18).max(120),
  preferences: z.object({
    newsletter: z.boolean(),
    notifications: z.boolean(),
    theme: z.enum(['light', 'dark', 'system']),
  }),
  roles: z.array(z.enum(['user', 'admin', 'moderator'])),
});

export type User = z.infer<typeof UserSchema>;
```

Ask Claude to generate mock users matching this schema:

```
/mock-data
Generate 10 User objects matching this Zod schema. Include varied ages (18-65), different role combinations, and realistic preference settings.
```

## Best Practices for Mock Data

Follow these practices when generating test fixtures with Claude skills:

**Maintain consistency across test runs.** Use seeded random number generators or fixed data sets for tests that need deterministic behavior. This ensures your tests produce consistent results.

**Create realistic data distributions.** Instead of uniform random values, generate data that reflects real-world patterns—most users have basic subscriptions, only a few have enterprise plans, order values follow a specific distribution.

**Separate seed data from test-specific fixtures.** Store generic seed data in dedicated files and generate specific test cases on demand or in setup functions.

**Version your fixtures.** Keep your mock data under version control alongside your code. Changes to data models should update both the schema and the fixture generation logic.

---

## Related Reading

- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/) — Full developer skill stack including data handling
- [Claude Code Pytest Fixtures and Parametrize Workflow](/claude-skills-guide/claude-code-pytest-fixtures-parametrize-workflow-tutorial-20/) — Advanced pytest patterns
- [Claude Skills for Data Analysis](/claude-skills-guide/best-claude-skills-for-data-analysis/) — Data handling with Claude


Built by theluckystrike — More at [zovo.one](https://zovo.one)
