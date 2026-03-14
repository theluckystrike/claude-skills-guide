---

layout: default
title: "Claude Code + FastAPI + Pydantic V2 Validation Deep Dive"
description: "Master input validation in FastAPI with Pydantic v2. Learn advanced validation techniques, custom validators, and how Claude Code can help you build robust APIs."
date: 2026-03-14
author: Claude Skills Guide
permalink: /claude-code-fastapi-pydantic-v2-validation-deep-dive/
categories: [guides]
tags: [claude-code, claude-skills]
---

{% raw %}
# Claude Code + FastAPI + Pydantic V2 Validation Deep Dive

Building robust APIs requires solid input validation. FastAPI combined with Pydantic v2 provides one of the most powerful validation systems available in Python today. This guide dives deep into validation patterns that will help you build production-ready APIs, with practical examples you can apply immediately.

## Why Pydantic V2 Validation Matters

Pydantic v2 represents a complete rewrite with significant performance improvements—up to 50x faster than v1 in many scenarios. But beyond speed, it offers a declarative approach to validation that integrates seamlessly with FastAPI's dependency injection system.

When you're building APIs, validation isn't optional. It's your first line of defense against bad data, security vulnerabilities, and runtime errors. With Claude Code, you can rapidly prototype and iterate on your validation logic.

## Getting Started: Basic Pydantic Models

Let's start with a fundamental Pydantic v2 model that you might use in a user registration endpoint:

```python
from pydantic import BaseModel, Field, EmailStr
from typing import Optional
from datetime import datetime

class UserCreate(BaseModel):
    username: str = Field(min_length=3, max_length=50)
    email: EmailStr
    password: str = Field(min_length=8)
    full_name: Optional[str] = None
    created_at: datetime = datetime.now()
```

This model automatically validates:
- Username length constraints
- Email format (using EmailStr)
- Password minimum length
- Optional fields with defaults

## Field-Level Validation with Field()

The `Field()` function is your primary tool for defining field-level constraints. Here's a more comprehensive example:

```python
from pydantic import Field, field_validator
from typing import Annotated

class ProductInventory(BaseModel):
    product_id: str = Field(pattern=r"^PROD-\d{6}$")
    quantity: int = Field(ge=0, le=10000)
    price: float = Field(gt=0, decimal_places=2)
    sku: Annotated[str, Field(min_length=5, max_length=20)]
```

The parameters available in Field() include:
- `gt`, `ge`, `lt`, `le`: Greater than, greater or equal, less than, less or equal
- `min_length`, `max_length`: String length constraints
- `pattern`: Regex pattern for string validation
- `decimal_places`: Precision for float fields

## Custom Validators

Sometimes built-in validators aren't enough. Pydantic v2 provides several ways to create custom validation logic.

### Field Validators

Use `@field_validator` when you need to validate a single field:

```python
from pydantic import field_validator

class OrderRequest(BaseModel):
    order_id: str
    quantity: int
    unit_price: float
    
    @field_validator('order_id')
    @classmethod
    def validate_order_id(cls, v: str) -> str:
        if not v.startswith('ORD-'):
            raise ValueError('Order ID must start with ORD-')
        return v
    
    @field_validator('quantity')
    @classmethod
    def validate_quantity(cls, v: int) -> int:
        if v <= 0:
            raise ValueError('Quantity must be positive')
        return v
```

### Model Validators

Use `@model_validator` when you need to validate relationships between fields:

```python
from pydantic import model_validator

class SubscriptionPlan(BaseModel):
    plan_type: str
    monthly_price: float
    annual_price: float
    
    @model_validator(mode='after')
    def validate_pricing(self) -> 'SubscriptionPlan':
        if self.plan_type == 'annual':
            expected_annual = self.monthly_price * 12 * 0.8  # 20% discount
            if self.annual_price > expected_annual:
                raise ValueError('Annual price should include 20% discount')
        return self
```

## Working with Nested Models

Real-world APIs often have complex nested structures. Here's how to handle them:

```python
from pydantic import BaseModel, Field
from typing import List, Optional

class Address(BaseModel):
    street: str
    city: str
    state: str = Field(min_length=2, max_length=2)
    zip_code: str = Field(pattern=r"^\d{5}$")

class UserProfile(BaseModel):
    basic_info: UserCreate  # Nested model
    addresses: List[Address]
    primary_address_index: int = Field(ge=0)
    
    @field_validator('primary_address_index')
    @classmethod
    def validate_address_index(cls, v, info):
        # Access the addresses through info.data
        addresses = info.data.get('addresses', [])
        if v >= len(addresses):
            raise ValueError('Invalid primary address index')
        return v
```

## Integrating with FastAPI

Now let's see how these models work in a FastAPI application:

```python
from fastapi import FastAPI, HTTPException, Depends
from pydantic import ValidationError

app = FastAPI()

@app.post("/users", response_model=UserCreate)
async def create_user(user: UserCreate):
    # Validation happens automatically before this point
    # Your business logic goes here
    return user

@app.exception_handler(ValidationError)
async def validation_exception_handler(request, exc):
    return JSONResponse(
        status_code=422,
        content={"detail": exc.errors()}
    )
```

## Advanced: Validation with Computed Fields

Pydantic v2's `computed_field` decorator lets you add derived fields that are automatically computed:

```python
from pydantic import computed_field

class Invoice(BaseModel):
    items: List[InvoiceItem]
    tax_rate: float = 0.08
    
    @computed_field
    @property
    def subtotal(self) -> float:
        return sum(item.quantity * item.unit_price for item in self.items)
    
    @computed_field
    @property
    def tax_amount(self) -> float:
        return self.subtotal * self.tax_rate
    
    @computed_field
    @property
    def total(self) -> float:
        return self.subtotal + self.tax_amount
```

## Best Practices for API Validation

1. **Validate early, validate often**: Define your Pydantic models close to your data layer and reuse them across endpoints.

2. **Use descriptive error messages**: Custom validators should return clear, actionable error messages.

3. **Separate concerns**: Keep validation models lean and focused. Use composition for complex forms.

4. **Leverage type hints**: Pydantic v2 heavily relies on type hints. Use them consistently.

5. **Test your validators**: Write unit tests for custom validation logic to ensure edge cases are handled.

## How Claude Code Can Help

Claude Code excels at rapidly generating Pydantic models from existing data structures or API specifications. Simply describe your data requirements, and Claude can:

- Generate complete Pydantic models with appropriate validators
- Suggest improvements to existing validation logic
- Identify potential validation gaps in your API
- Create comprehensive test cases for edge cases

## Conclusion

Pydantic v2 validation combined with FastAPI provides a robust foundation for building APIs that handle data correctly from the start. By leveraging field validators, model validators, computed fields, and proper error handling, you can create APIs that are both flexible and secure.

Remember: validation is not about restricting your users—it's about providing clear feedback and preventing errors before they reach your business logic. Master these patterns, and you'll build more reliable applications.
{% endraw %}
