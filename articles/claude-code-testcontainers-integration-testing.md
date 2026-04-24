---

layout: default
title: "Claude Code TestContainers Integration"
description: "Learn how to use TestContainers with Claude Code for reliable integration testing. Practical examples for database, message queue, and service testing."
date: 2026-03-14
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-testcontainers-integration-testing/
reviewed: true
score: 7
categories: [integrations]
tags: [claude-code, claude-skills]
geo_optimized: true
last_tested: "2026-04-22"
---

Integration testing with real dependencies is essential for validating Claude Code skills that interact with databases, message queues, or external services. TestContainers provides Docker-based test fixtures that spin up actual services instead of mocks, giving you confidence that your skills work in production-like environments. This guide shows you how to integrate TestContainers into your Claude Code testing workflow, from basic setup through advanced multi-service orchestration.

## Why TestContainers for Claude Code Skills

When your skill needs to work with PostgreSQL, Redis, Kafka, or any containerized service, unit tests with mocks only get you so far. The real behavior of these services, connection pooling, timeouts, transaction semantics, index behavior, message ordering guarantees, only reveals itself in integration tests. TestContainers handles the lifecycle of these dependencies, creating fresh containers for each test and cleaning up afterward.

For Claude Code skills that use the `pdf` skill to process documents or the `xlsx` skill to generate spreadsheets, you often need a real database to validate the complete workflow. TestContainers makes this practical by automating container orchestration.

The fundamental problem that TestContainers solves is the "works on my machine" gap. In-memory databases and mock clients simulate the interface of a real service, but they omit the edge cases that matter most in production: transaction isolation levels, index-only scans, connection timeout behavior, serialization errors under concurrent load. By running real containers, your integration tests catch these issues before they reach production.

Here is a comparison of testing approaches for database-dependent code:

| Approach | Accuracy | Speed | CI Complexity | Maintenance |
|---|---|---|---|---|
| Unit tests with mocks | Low | Very fast | None | Mock drift risk |
| In-memory SQLite | Medium | Fast | None | Dialect differences |
| Shared test database | High | Medium | High | Data isolation issues |
| TestContainers | High | Moderate | Low | None (ephemeral) |
| Dedicated test environment | High | Slow | Very high | Infra team required |

TestContainers hits a practical sweet spot: production-accurate behavior with minimal infrastructure overhead and no shared-state flakiness.

## Setting Up TestContainers

First, add the TestContainers dependency to your project. For a Python project, install the library:

```bash
pip install testcontainers
```

For Java projects using Maven, you typically install the BOM plus individual module dependencies:

```xml
<dependencyManagement>
 <dependencies>
 <dependency>
 <groupId>org.testcontainers</groupId>
 <artifactId>testcontainers-bom</artifactId>
 <version>1.19.3</version>
 <type>pom</type>
 <scope>import</scope>
 </dependency>
 </dependencies>
</dependencyManagement>

<dependencies>
 <dependency>
 <groupId>org.testcontainers</groupId>
 <artifactId>postgresql</artifactId>
 <scope>test</scope>
 </dependency>
 <dependency>
 <groupId>org.testcontainers</groupId>
 <artifactId>kafka</artifactId>
 <scope>test</scope>
 </dependency>
 <dependency>
 <groupId>org.testcontainers</groupId>
 <artifactId>junit-jupiter</artifactId>
 <scope>test</scope>
 </dependency>
</dependencies>
```

Create a reusable test fixture that starts and stops containers and exposes connection details to your skill under test:

```python
import os
import testcontainers.postgres
import testcontainers.redis

class TestContainerFixture:
 def __init__(self):
 self.postgres = testcontainers.postgres.PostgresContainer("postgres:15-alpine")
 self.redis = testcontainers.redis.RedisContainer("redis:7-alpine")

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

Note the use of Alpine-based images (`postgres:15-alpine`, `redis:7-alpine`). These are smaller than the full Debian-based variants and start faster in CI. For a test that runs hundreds of times, startup time compounds into meaningful wall-clock overhead.

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

The `tdd` skill pairs well here, you can write your tests first following test-driven development principles, then use TestContainers to verify the implementation works with real database behavior.

You can extend this to test database migrations as part of the integration test. This is one of the most valuable uses of TestContainers, verifying that your migration scripts apply cleanly to an empty schema:

```python
import pytest
import alembic.config
import alembic.command
from sqlalchemy import create_engine, text

@pytest.fixture(scope="session")
def migrated_db():
 container = testcontainers.postgres.PostgresContainer("postgres:15-alpine")
 container.start()

 db_url = container.get_connection_url()

 # Run migrations against the fresh container
 alembic_cfg = alembic.config.Config("alembic.ini")
 alembic_cfg.set_main_option("sqlalchemy.url", db_url)
 alembic.command.upgrade(alembic_cfg, "head")

 yield db_url

 container.stop()

def test_schema_version_after_migration(migrated_db):
 engine = create_engine(migrated_db)
 with engine.connect() as conn:
 result = conn.execute(text("SELECT version_num FROM alembic_version"))
 version = result.scalar()
 assert version is not None
 assert len(version) > 0

def test_user_table_exists(migrated_db):
 engine = create_engine(migrated_db)
 with engine.connect() as conn:
 result = conn.execute(text(
 "SELECT COUNT(*) FROM information_schema.tables "
 "WHERE table_name = 'users'"
 ))
 count = result.scalar()
 assert count == 1
```

Using `scope="session"` on the fixture creates the container once and shares it across all tests in the module, reducing startup overhead when many tests need the same empty schema.

## Testing Message Queue Interactions

Skills that process async messages via Kafka or RabbitMQ need integration tests with actual message brokers. TestContainers supports both:

```python
import json
import testcontainers.kafka

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

For RabbitMQ-based skills, the pattern is nearly identical but uses the RabbitMQ container module:

```python
import testcontainers.rabbitmq
import pika

def test_rabbitmq_message_routing():
 rabbitmq = testcontainers.rabbitmq.RabbitMqContainer("rabbitmq:3.12-management-alpine")
 rabbitmq.start()

 try:
 # Connect using the container's exposed port
 credentials = pika.PlainCredentials(
 rabbitmq.RABBITMQ_USER,
 rabbitmq.RABBITMQ_PASS
 )
 params = pika.ConnectionParameters(
 host="localhost",
 port=rabbitmq.get_exposed_port(5672),
 credentials=credentials
 )
 connection = pika.BlockingConnection(params)
 channel = connection.channel()
 channel.queue_declare(queue="orders")

 # Publish a test order
 channel.basic_publish(
 exchange="",
 routing_key="orders",
 body=json.dumps({"order_id": "ORD-001", "amount": 99.99})
 )

 # Test that your skill correctly consumes and processes it
 skill = OrderProcessingSkill(rabbitmq_params=params)
 result = skill.process_next_order()

 assert result["order_id"] == "ORD-001"
 assert result["status"] == "processed"
 finally:
 rabbitmq.stop()
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

This approach works particularly well with the `supermemory` skill, which might query external memory services, you can test those interactions without depending on production services.

WireMock is especially useful for testing error handling. You can configure stubs that simulate rate limiting (429 responses), server errors (503), and slow responses (fixed delays). Testing that your skill retries correctly and respects backoff policies requires a controllable server, WireMock in TestContainers gives you exactly that:

```python
def test_api_client_handles_rate_limiting():
 wiremock = testcontainers.wiremock.WireMockContainer("rodolpheche/wiremock:2.35.2")
 wiremock.start()

 try:
 # Return 429 on first request, then 200 on retry
 wiremock.create_scenario_stub(
 scenario_name="rate-limit-then-recover",
 required_state="Started",
 new_state="Recovered",
 method="GET",
 url_path="/api/data",
 response_status=429,
 response_headers={"Retry-After": "1"}
 )
 wiremock.create_scenario_stub(
 scenario_name="rate-limit-then-recover",
 required_state="Recovered",
 method="GET",
 url_path="/api/data",
 response_body='{"data": "ok"}',
 response_status=200
 )

 skill = ExternalApiSkill(wiremock.get_base_url(), max_retries=3)
 result = skill.fetch_data()

 assert result["data"] == "ok"
 # Verify the skill retried exactly once
 assert wiremock.get_request_count("/api/data") == 2
 finally:
 wiremock.stop()
```

## CI/CD Integration

Running TestContainers in CI requires Docker access. GitHub Actions provides this by default on standard runners. Here is a complete workflow that runs integration tests with TestContainers:

```yaml
name: Integration Tests

on:
 pull_request:
 branches: [main]
 push:
 branches: [main]

jobs:
 integration-test:
 runs-on: ubuntu-latest
 # No special services configuration needed. TestContainers
 # launches its own Docker containers via the Docker socket
 steps:
 - uses: actions/checkout@v4

 - name: Set up Python
 uses: actions/setup-python@v5
 with:
 python-version: "3.12"
 cache: pip

 - name: Install dependencies
 run: pip install -r requirements.txt

 - name: Pre-pull container images to reduce startup time
 run: |
 docker pull postgres:15-alpine
 docker pull redis:7-alpine
 docker pull confluentinc/cp-kafka:7.5.0

 - name: Run integration tests
 env:
 DOCKER_HOST: unix:///var/run/docker.sock
 TESTCONTAINERS_RYUK_DISABLED: "false"
 run: |
 pytest tests/integration/ -v \
 --timeout=120 \
 --junitxml=reports/integration-results.xml

 - name: Publish test results
 uses: actions/upload-artifact@v4
 if: always()
 with:
 name: integration-test-results
 path: reports/
```

The `frontend-design` skill might trigger visual regression tests that require a running browser environment, TestContainers can provide this via Selenium containers:

```python
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
import testcontainers.selenium

def test_visual_workflow():
 selenium = testcontainers.selenium.BrowserWebDriverContainer(
 capabilities=DesiredCapabilities.CHROME
 )
 selenium.start()

 try:
 driver = webdriver.Remote(
 command_executor=selenium.get_driver_url(),
 desired_capabilities=DesiredCapabilities.CHROME
 )
 driver.get("http://host.docker.internal:8080")
 assert "Dashboard" in driver.title
 driver.quit()
 finally:
 selenium.stop()
```

## Best Practices

Keep container images lightweight to speed up test execution. Use Alpine-based images when available and specific version tags rather than `latest` for reproducibility. Tag your containers with unique identifiers to avoid conflicts when running parallel tests.

Isolate each test with a fresh container. While TestContainers reuses containers by default for speed, integration tests benefit from clean state. Use the `withLabels` and `withName` options to create predictable container names for debugging.

Clean up containers in `finally` blocks or use context managers. Failing to stop containers leads to resource leaks and flaky tests:

```python
Preferred: context manager guarantees cleanup
from testcontainers.postgres import PostgresContainer

def test_with_context_manager():
 with PostgresContainer("postgres:15-alpine") as pg:
 skill = DatabaseSkill(pg.get_connection_url())
 result = skill.list_users()
 assert isinstance(result, list)
 # Container is stopped and removed automatically here
```

Track container startup time in your test reports. If startup exceeds a few seconds, consider using Ryuk, a sidecar container that cleans up orphaned containers, combined with container image pre-caching in your CI pipeline.

Follow a clear naming convention for integration test files to make it easy to run them separately from unit tests:

```
tests/
 unit/
 test_skill_logic.py # fast, no containers
 test_data_transforms.py
 integration/
 test_db_skill.py # uses TestContainers
 test_kafka_skill.py
 test_api_client.py
```

With pytest, you can run only unit tests in pre-commit hooks (`pytest tests/unit/`) and run full integration tests in CI (`pytest tests/`).

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

For Java with JUnit 5, TestContainers provides a clean annotation-based API for multi-container setups:

```java
@Testcontainers
class FullStackIntegrationTest {

 @Container
 static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
 .withDatabaseName("testdb")
 .withUsername("test")
 .withPassword("test");

 @Container
 static GenericContainer<?> redis = new GenericContainer<>("redis:7-alpine")
 .withExposedPorts(6379)
 .waitingFor(Wait.forListeningPort());

 @Container
 static KafkaContainer kafka = new KafkaContainer(
 DockerImageName.parse("confluentinc/cp-kafka:7.5.0")
 );

 @BeforeEach
 void configureSkill() {
 System.setProperty("db.url", postgres.getJdbcUrl());
 System.setProperty("redis.host", redis.getHost());
 System.setProperty("redis.port", String.valueOf(redis.getMappedPort(6379)));
 System.setProperty("kafka.brokers", kafka.getBootstrapServers());
 }

 @Test
 void testCompleteOrderWorkflow() {
 FullStackSkill skill = new FullStackSkill();
 WorkflowResult result = skill.processOrder("ORD-TEST-001");
 assertEquals("completed", result.getStatus());
 assertNotNull(result.getConfirmationId());
 }
}
```

The `@Container` annotation manages the full container lifecycle, start before tests, stop after. Declaring containers as `static` means they are shared across all test methods in the class, which reduces startup overhead when you have many tests against the same stack.

## Handling Container Networking

TestContainers creates an isolated network for each container or compose stack. When testing services that communicate between containers, ensure they join the same network:

```python
Explicit network configuration
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

Your skill connects using the container names as hostnames, just as services would in production. This catches DNS resolution issues and connection string problems early.

A subtle networking issue with TestContainers is port mapping. The container's internal port (e.g., 5432 for Postgres) is mapped to a random host port. Always use the container's `get_exposed_port()` or `get_connection_url()` methods rather than hardcoding port numbers in test configuration. Hardcoded ports cause spurious failures when another process is using the same port on the host.

## Performance Considerations

Integration tests with TestContainers run slower than unit tests. A typical Postgres container takes 2-5 seconds to start; a Kafka container can take 10-15 seconds. Optimize your test suite by separating concerns: keep unit tests fast with mocks, reserve TestContainers for critical paths that require real dependencies.

Practical strategies for keeping integration test time manageable:

- Use `scope="session"` fixtures to share containers across all tests that need the same service version
- Pre-pull images in CI before test execution to eliminate pull time from test time
- Use health checks and `wait_for_logs` instead of fixed `time.sleep()` calls, containers are ready faster than a fixed sleep assumes
- Run integration tests in parallel using `pytest-xdist` with separate containers per worker

Use test organization to run quick tests in continuous integration while running full integration suites on schedule or before releases. A typical configuration runs unit tests on every commit (under 30 seconds), integration tests on every pull request (under 5 minutes), and full stack tests nightly or before releases.

---

---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-deploy&utm_campaign=claude-code-testcontainers-integration-testing)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Chrome Enterprise VPN Integration - A Practical Guide.](/chrome-enterprise-vpn-integration/)
- [Chrome Extension Anki Web Integration: A Developer Guide](/chrome-extension-anki-web-integration/)
- [Chrome Extension Outlook Calendar Integration: A.](/chrome-extension-outlook-calendar-integration/)
- [Claude Code Artillery Performance Testing — Developer Guide](/claude-code-artillery-performance-testing/)
- [Claude Code Vitest Fast Testing Workflow](/claude-code-vitest-fast-testing-workflow/)
- [Claude Code for PWA Testing and Auditing Workflow](/claude-code-for-pwa-testing-and-auditing-workflow/)
- [Claude Code for Performance Testing Strategy Workflow](/claude-code-for-performance-testing-strategy-workflow/)
- [Claude Code For Sam Local Testing — Complete Developer Guide](/claude-code-for-sam-local-testing-workflow/)
- [Claude Code Mockito Java Testing Workflow](/claude-code-mockito-java-testing-workflow/)
- [Claude Code Mutation Testing Workflow Guide](/claude-code-mutation-testing-workflow-guide/)
- [Claude Code Firebase Security Rules Validation Testing Guide](/claude-code-firebase-security-rules-validation-testing-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


