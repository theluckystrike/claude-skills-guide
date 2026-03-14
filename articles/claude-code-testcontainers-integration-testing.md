---
layout: default
title: "Claude Code TestContainers Integration Testing"
description: "Learn how to use TestContainers with Claude Code for reliable integration testing. Practical examples for database, message queue, and service testing."
date: 2026-03-14
author: theluckystrike
permalink: /claude-code-testcontainers-integration-testing/
---

# Claude Code TestContainers Integration Testing

Integration testing with real dependencies is essential for validating Claude Code skills that interact with databases, message queues, or external services. TestContainers provides Docker-based test fixtures that spin up actual services instead of mocks, giving you confidence that your skills work in production-like environments. This guide shows you how to integrate TestContainers into your Claude Code testing workflow.

## Why TestContainers for Claude Code Skills

When your skill needs to work with PostgreSQL, Redis, Kafka, or any containerized service, unit tests with mocks only get you so far. The real behavior of these services—connection pooling, timeouts, transaction semantics—only reveals itself in integration tests. TestContainers handles the lifecycle of these dependencies, creating fresh containers for each test and cleaning up afterward.

For Claude Code skills that use the `pdf` skill to process documents or the `xlsx` skill to generate spreadsheets, you often need a real database to validate the complete workflow. TestContainers makes this practical by automating container orchestration.

## Setting Up TestContainers

First, add the TestContainers dependency to your project. For a Python project, install the library:

```bash
pip install testcontainers
```

For Java projects using Maven:

```xml
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>testcontainers</artifactId>
    <version>1.19.3</version>
    <scope>test</scope>
</dependency>
```

Create a test fixture that starts and stops the container:

```python
import testcontainers.postgres
import testcontainers.redis

class TestContainerFixture:
    def __init__(self):
        self.postgres = testcontainers.postgres.PostgresContainer("postgres:15")
        self.redis = testcontainers.redis.RedisContainer("redis:7")
    
    def start(self):
        self.postgres.start()
        self.redis.start()
        # Set environment variables for your skill
        os.environ["DATABASE_URL"] = self.postgres.get_connection_url()
        os.environ["REDIS_URL"] = self.redis.get_connection_url()
    
    def stop(self):
        self.postgres.stop()
        self.redis.stop()
```

## Testing Database Interactions

If your Claude Code skill uses a database, TestContainers lets you test actual SQL queries and migrations. Here's how to structure these tests:

```python
import pytest
from your_skill import DatabaseSkill

@pytest.fixture
def db_fixture():
    fixture = TestContainerFixture()
    fixture.start()
    yield fixture
    fixture.stop()

def test_user_creation_integration(db_fixture):
    skill = DatabaseSkill()
    user_id = skill.create_user("test@example.com", "Test User")
    
    result = skill.get_user(user_id)
    assert result["email"] == "test@example.com"
    assert result["name"] == "Test User"
```

The `tdd` skill pairs well here—you can write your tests first following test-driven development principles, then use TestContainers to verify the implementation works with real database behavior.

## Testing Message Queue Interactions

Skills that process async messages via Kafka or RabbitMQ need integration tests with actual message brokers. TestContainers supports both:

```python
import testcontainers.kafka
import testcontainers.rabbitmq

def test_kafka_message_processing():
    kafka = testcontainers.kafka.KafkaContainer("confluentinc/cp-kafka:7.5.0")
    kafka.start()
    
    try:
        from kafka import KafkaProducer, KafkaConsumer
        
        producer = KafkaProducer(
            bootstrap_servers=kafka.get_bootstrap_servers(),
            value_serializer=lambda v: json.dumps(v).encode('utf-8')
        )
        
        # Send a test message that your skill would process
        producer.send("user_events", {"user_id": 123, "action": "signup"})
        producer.flush()
        
        # Verify your skill processes the message correctly
        skill = MessageProcessingSkill()
        result = skill.process_pending_messages()
        
        assert result["processed_count"] == 1
    finally:
        kafka.stop()
```

## Testing External API Clients

When your skill calls external APIs, you can use TestContainers with service simulators like WireMock:

```python
import testcontainers.wiremock

def test_api_client_integration():
    wiremock = testcontainers.wiremock.WireMockContainer("rodolpheche/wiremock:2.35.2")
    wiremock.start()
    
    try:
        # Configure mock response
        wiremock.create_stub_for(
            method="GET",
            url_path="/api/users",
            response_body='[{"id": 1, "name": "Test User"}]',
            content_type="application/json"
        )
        
        # Test your skill with the mocked API
        skill = ExternalApiSkill(wiremock.get_base_url())
        users = skill.fetch_users()
        
        assert len(users) == 1
        assert users[0]["name"] == "Test User"
    finally:
        wiremock.stop()
```

This approach works particularly well with the `supermemory` skill, which might query external memory services—you can test those interactions without depending on production services.

## CI/CD Integration

Running TestContainers in CI requires Docker access. GitHub Actions example:

```yaml
jobs:
  test:
    services:
      docker:
        image: docker:24-cli
        options: --privileged
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: |
          pip install -r requirements.txt
          pytest tests/ -v
```

The `frontend-design` skill might trigger visual regression tests that require a running browser environment—TestContainers can provide this via Selenium containers.

## Best Practices

Keep container images lightweight to speed up test execution. Use Alpine-based images when available and specific version tags rather than `latest` for reproducibility. Tag your containers with unique identifiers to avoid conflicts when running parallel tests.

Isolate each test with a fresh container. While TestContainers reuses containers by default for speed, integration tests benefit from clean state. Use the `withLabels` and `withName` options to create predictable container names for debugging.

Clean up containers in `finally` blocks or use context managers. Failing to stop containers leads to resource leaks and flaky tests.

Track container startup time in your test reports. If startup exceeds a few seconds, consider using Ryuk—a sidecar container that cleans up orphaned containers—combined with container image pre-caching in your CI pipeline.

## Advanced: Multi-Container Setups

Real-world applications often require multiple services running together. TestContainers supports docker-compose-style setups for testing complete stacks:

```python
import testcontainers.compose

def test_full_stack_integration():
    compose = testcontainers.compose.ComposeContainer(
        "./docker-compose.yml",
        pull=True
    )
    compose.start()
    
    try:
        # Wait for all services to be healthy
        compose.wait_for("postgres:5432")
        compose.wait_for("redis:6379")
        compose.wait_for("api:8080")
        
        # Run your integration test
        skill = FullStackSkill()
        result = skill.process_complete_workflow()
        
        assert result["status"] == "success"
    finally:
        compose.down()
```

This approach mirrors production deployments exactly, catching configuration issues that single-container tests miss. Your docker-compose.yml defines the same services your application uses in staging and production.

## Handling Container Networking

TestContainers creates an isolated network for each container or compose stack. When testing services that communicate between containers, ensure they join the same network:

```python
# Explicit network configuration
postgres = testcontainers.postgres.PostgresContainer(
    "postgres:15",
    network="test-network",
    network_mode="bridge"
)

redis = testcontainers.redis.RedisContainer(
    "redis:7",
    network="test-network"
)
```

Your skill connects using the container names as hostnames—just as services would in production. This catches DNS resolution issues and connection string problems early.

## Performance Considerations

Integration tests with TestContainers run slower than unit tests. Optimize your test suite by separating concerns: keep unit tests fast with mocks, reserve TestContainers for critical paths that require real dependencies. Use test organization to run quick tests in continuous integration while running full integration suites on schedule or before releases.

---

Built by theluckystrike — More at [zovo.one](https://zovo.one)
