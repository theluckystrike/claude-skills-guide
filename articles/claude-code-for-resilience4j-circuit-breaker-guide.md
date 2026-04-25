---

layout: default
title: "Claude Code for Resilience4j Circuit"
description: "Learn how to use Claude Code to build resilient Java applications with Resilience4j circuit breakers. Practical examples and code snippets for."
date: 2026-03-15
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-for-resilience4j-circuit-breaker-guide/
reviewed: true
score: 7
geo_optimized: true
---


Claude Code for Resilience4j Circuit Breaker Guide

Building resilient distributed systems requires defensive programming patterns that protect your application from cascading failures. Resilience4j is the modern choice for Java developers seeking lightweight, functional fault tolerance mechanisms. When combined with Claude Code's AI-assisted development capabilities, you can rapidly implement and test circuit breaker patterns that keep your services running smoothly.

This guide walks you through implementing Resilience4j circuit breakers with practical examples you can apply to your projects today, from basic setup through advanced patterns like bulkheads, rate limiters, and time-limited calls.

## Understanding Circuit Breaker Fundamentals

A circuit breaker acts as a proxy that monitors calls to remote services. It has three distinct states that determine how it handles requests:

Closed. The normal state where requests pass through. The circuit breaker counts failures, and when they exceed a threshold, it transitions to the open state.

Open. When the circuit is open, requests fail immediately without attempting the remote call. This prevents cascading failures and gives the downstream service time to recover.

Half-Open. After a configured duration, the circuit allows a limited number of test requests through. If these succeed, the circuit closes; if they fail, it opens again.

Resilience4j provides a clean, annotation-driven approach to implementing these patterns in your Java applications. Unlike Hystrix (which reached end of life in 2018), Resilience4j is built for Java 8+ with functional programming idioms, has no external dependencies, and integrates natively with Spring Boot's health and metrics infrastructure.

Here is a quick comparison to put Resilience4j in context:

| Feature | Resilience4j | Hystrix | Sentinel |
|---------|-------------|---------|----------|
| Java 8+ support | Yes | Partial | Yes |
| Spring Boot 3 | Yes | No | Yes |
| Reactive (WebFlux) | Yes | Limited | Yes |
| External dependency | None | RxJava | None |
| Active maintenance | Yes | No (EOL) | Yes |
| Sliding window types | Count + Time | Count only | Count only |

The sliding window flexibility is one of Resilience4j's most practical advantages. you can evaluate failures over the last N calls (count-based) or the last N seconds (time-based), making it suitable for both high-throughput and bursty traffic patterns.

## Setting Up Resilience4j Dependencies

First, add the required dependencies to your Maven project:

```xml
<dependency>
 <groupId>io.github.resilience4j</groupId>
 <artifactId>resilience4j-spring-boot3</artifactId>
 <version>2.2.0</version>
</dependency>
<dependency>
 <groupId>org.springframework.boot</groupId>
 <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
<!-- Optional: metrics export to Prometheus -->
<dependency>
 <groupId>io.micrometer</groupId>
 <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
<!-- Optional: actuator health endpoint integration -->
<dependency>
 <groupId>org.springframework.boot</groupId>
 <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

For Gradle users, add this to your build.gradle:

```groovy
implementation 'io.github.resilience4j:resilience4j-spring-boot3:2.2.0'
implementation 'org.springframework.boot:spring-boot-starter-aop'
implementation 'io.micrometer:micrometer-registry-prometheus'
implementation 'org.springframework.boot:spring-boot-starter-actuator'
```

The AOP starter is required since Resilience4j uses AspectJ to intercept method calls and apply circuit breaker logic. Without it, the `@CircuitBreaker` annotation silently has no effect. a common source of confusion when first setting up the library.

Claude Code is useful at this stage for checking your dependency tree. You can ask "are there any version conflicts between resilience4j-spring-boot3 2.2.0 and my current Spring Boot version?" and Claude Code will parse your pom.xml or build.gradle to identify compatibility issues before they cause runtime errors.

## Configuring Circuit Breaker with Code

While you can configure circuit breakers through application.yml, defining them in code gives you more flexibility and type safety. Here's how to create a custom circuit breaker configuration:

```java
import io.github.resilience4j.circuitbreaker.CircuitBreaker;
import io.github.resilience4j.circuitbreaker.CircuitBreakerConfig;
import java.time.Duration;

public class CircuitBreakerFactory {

 public CircuitBreaker createCustomCircuitBreaker(String name) {
 CircuitBreakerConfig config = CircuitBreakerConfig.custom()
 .failureRateThreshold(50) // Open at 50% failure rate
 .waitDurationInOpenState(Duration.ofSeconds(30)) // Wait 30s before half-open
 .slidingWindowSize(10) // Evaluate last 10 calls
 .minimumNumberOfCalls(5) // Minimum calls before evaluating
 .permittedNumberOfCallsInHalfOpenState(3) // Allow 3 test calls
 .slowCallRateThreshold(80) // Also open if 80% of calls are slow
 .slowCallDurationThreshold(Duration.ofSeconds(2)) // Calls > 2s count as slow
 .build();

 return CircuitBreaker.of(name, config);
 }
}
```

This configuration opens the circuit when 50% of calls fail within a sliding window of 10 calls, with a minimum of 5 calls required before evaluation. The slow call thresholds are easy to overlook but are important for services that degrade silently. a database connection that returns results after 10 seconds is still a failure from a user experience perspective, even if it returns HTTP 200.

Claude Code can generate these configurations from a plain-English description. You might say "create a circuit breaker for a payment processing service that should open if more than 30% of calls fail or take longer than 3 seconds, and stay open for 60 seconds before trying again". Claude Code will translate that directly into the appropriate `CircuitBreakerConfig` builder chain.

## Applying Circuit Breaker with Annotations

The simplest way to add circuit breaker protection is through annotations. Here's a practical service class:

```java
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class ProductService {

 private final ProductApiClient productApiClient;
 private final ProductCache productCache;

 public ProductService(ProductApiClient productApiClient, ProductCache productCache) {
 this.productApiClient = productApiClient;
 this.productCache = productCache;
 }

 @CircuitBreaker(name = "productService", fallbackMethod = "getProductsFallback")
 public List<Product> getProducts() {
 // Call external product API
 return productApiClient.fetchAll();
 }

 private List<Product> getProductsFallback(Exception e) {
 // Return cached products or empty list
 log.warn("Circuit breaker active for productService: {}", e.getMessage());
 return productCache.get();
 }

 // Fallback can also be typed to handle specific exceptions differently
 private List<Product> getProductsFallback(CallNotPermittedException e) {
 log.error("Circuit is OPEN for productService. returning stale cache");
 return productCache.getStale();
 }
}
```

The fallback method executes when the circuit is open or an exception occurs. Always implement meaningful fallback logic that provides degraded functionality rather than complete failure. Note that you can define multiple fallback methods with different exception types. Resilience4j picks the most specific matching fallback.

A common mistake is writing a fallback that also makes a network call. If the fallback itself can fail, wrap it separately or use only local state (caches, defaults). Claude Code will flag this pattern when reviewing your service code and suggest keeping fallbacks dependency-free.

## Using Circuit Breakers with Reactive Streams

If your application uses Spring WebFlux, Resilience4j provides reactive decorators:

```java
import io.github.resilience4j.circuitbreaker.CircuitBreaker;
import io.github.resilience4j.reactor.circuitbreaker.operator.CircuitBreakerOperator;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
public class ReactiveProductService {

 private final CircuitBreaker circuitBreaker;
 private final WebClient productWebClient;

 public ReactiveProductService(CircuitBreakerRegistry registry, WebClient.Builder builder) {
 this.circuitBreaker = registry.circuitBreaker("reactiveProductService");
 this.productWebClient = builder.baseUrl("https://api.products.example.com").build();
 }

 public Flux<Product> getProducts() {
 return productWebClient.get()
 .uri("/products")
 .retrieve()
 .bodyToFlux(Product.class)
 .transformDeferred(CircuitBreakerOperator.of(circuitBreaker))
 .onErrorResume(CallNotPermittedException.class,
 e -> Flux.fromIterable(productCache.get()));
 }
}
```

The `transformDeferred` operator applies the circuit breaker to the entire reactive pipeline. This is the correct approach for WebFlux. do not use `@CircuitBreaker` annotations on reactive methods, as they interact unpredictably with reactive scheduling.

## Customizing Configuration with YAML

For environment-specific settings, configure circuit breakers in your application.yml:

```yaml
resilience4j:
 circuitbreaker:
 instances:
 productService:
 failureRateThreshold: 40
 waitDurationInOpenState: 20s
 slidingWindowSize: 20
 minimumNumberOfCalls: 10
 permittedNumberOfCallsInHalfOpenState: 5
 automaticTransitionFromOpenToHalfOpenEnabled: true
 slowCallRateThreshold: 70
 slowCallDurationThreshold: 3s
 recordExceptions:
 - java.io.IOException
 - java.util.concurrent.TimeoutException
 - org.springframework.web.client.HttpServerErrorException
 ignoreExceptions:
 - com.example.NotFoundException
 paymentService:
 failureRateThreshold: 20
 waitDurationInOpenState: 60s
 slidingWindowType: TIME_BASED
 slidingWindowSize: 60
 minimumNumberOfCalls: 10
 permittedNumberOfCallsInHalfOpenState: 2
```

A few important YAML settings to understand:

- `automaticTransitionFromOpenToHalfOpenEnabled: true` means the circuit transitions to half-open automatically after `waitDurationInOpenState` rather than waiting for the next call. Enable this for services where fast recovery matters.
- `ignoreExceptions` is essential for business exceptions like `NotFoundException` or `ValidationException` that should not count as failures. these are expected behaviors, not infrastructure problems.
- `slidingWindowType: TIME_BASED` with `slidingWindowSize: 60` evaluates failures over the last 60 seconds rather than the last 60 calls. This is better for low-traffic services where a count-based window is stale.

Claude Code is effective at generating environment-specific YAML overrides. You can have a conservative configuration in your base `application.yml` and ask Claude Code to generate looser `application-staging.yml` settings for testing, or stricter `application-prod.yml` settings for critical services.

## Combining Circuit Breakers with Retry

Resilience4j provides a `@Retry` annotation that pairs well with circuit breakers. The important rule is to place the retry decorator inside (below) the circuit breaker so retries count against the circuit's failure window:

```java
@Service
public class OrderService {

 // Retry is applied first (inner), then circuit breaker (outer)
 // Annotation order matters: the last annotation listed is applied innermost
 @CircuitBreaker(name = "orderService", fallbackMethod = "placeOrderFallback")
 @Retry(name = "orderService")
 public Order placeOrder(OrderRequest request) {
 return orderApiClient.submit(request);
 }

 private Order placeOrderFallback(OrderRequest request, Exception e) {
 // Queue the order for async processing
 orderQueue.enqueue(request);
 return Order.pending(request.getId());
 }
}
```

Configure the retry behavior in YAML:

```yaml
resilience4j:
 retry:
 instances:
 orderService:
 maxAttempts: 3
 waitDuration: 500ms
 enableExponentialBackoff: true
 exponentialBackoffMultiplier: 2
 retryExceptions:
 - java.io.IOException
 - java.util.concurrent.TimeoutException
```

With exponential backoff, the retry attempts at 500ms, 1000ms, and 2000ms before giving up. This totals about 3.5 seconds of retry time per call, which the circuit breaker will count as a single slow call if your `slowCallDurationThreshold` is set below that.

## Monitoring Circuit Breaker State

Production systems require visibility into circuit breaker behavior. Resilience4j integrates with Micrometer for metrics:

```java
import io.github.resilience4j.circuitbreaker.CircuitBreaker;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

@Component
public class CircuitBreakerMonitor {

 private final CircuitBreakerRegistry circuitBreakerRegistry;
 private final MeterRegistry meterRegistry;

 public CircuitBreakerMonitor(CircuitBreakerRegistry registry, MeterRegistry meterRegistry) {
 this.circuitBreakerRegistry = registry;
 this.meterRegistry = meterRegistry;
 }

 @EventListener(ApplicationReadyEvent.class)
 public void registerMetrics() {
 circuitBreakerRegistry.getAllCircuitBreakers()
 .forEach(cb -> {
 cb.getEventPublisher()
 .onStateTransition(event ->
 System.out.println("Circuit " + event.getCircuitBreakerName() +
 " transitioned to: " + event.getStateTransition()));
 cb.getEventPublisher()
 .onFailureRateExceeded(event ->
 alertingService.notify("Circuit breaker failure rate exceeded: "
 + event.getCircuitBreakerName()));
 });
 }
}
```

You can also access state programmatically:

```java
public CircuitBreaker.State getCircuitState(String breakerName) {
 CircuitBreaker breaker = circuitBreakerRegistry.circuitBreaker(breakerName);
 return breaker.getState();
}

public CircuitBreaker.Metrics getCircuitMetrics(String breakerName) {
 CircuitBreaker breaker = circuitBreakerRegistry.circuitBreaker(breakerName);
 return breaker.getMetrics();
}
```

Key Micrometer metrics exposed by Resilience4j (useful for Grafana dashboards):

| Metric Name | Type | Description |
|-------------|------|-------------|
| `resilience4j_circuitbreaker_state` | Gauge | Current state (0=closed, 1=open, 2=half-open) |
| `resilience4j_circuitbreaker_calls_total` | Counter | Calls by kind (successful, failed, not_permitted) |
| `resilience4j_circuitbreaker_failure_rate` | Gauge | Current failure rate percentage |
| `resilience4j_circuitbreaker_slow_call_rate` | Gauge | Percentage of slow calls |
| `resilience4j_circuitbreaker_buffered_calls` | Gauge | Number of calls in sliding window |

Alert on `resilience4j_circuitbreaker_state == 1` (circuit open) and `resilience4j_circuitbreaker_failure_rate > 30` to catch deteriorating services before they fully trip.

The Spring Boot Actuator health endpoint also exposes circuit breaker status when you enable it:

```yaml
management:
 health:
 circuitbreakers:
 enabled: true
 endpoint:
 health:
 show-details: always
```

This adds circuit breaker state to `/actuator/health`, which load balancers and Kubernetes readiness probes can use to route traffic away from unhealthy instances.

## Best Practices for Production Systems

When implementing circuit breakers in production environments, follow these guidelines:

Start conservative and tune based on real traffic. Initial configurations should have higher thresholds to avoid false positives. Monitor your metrics and adjust based on actual failure patterns. A circuit breaker that trips too easily is almost as bad as one that never trips. it creates unnecessary fallback invocations and alert fatigue.

Implement meaningful fallbacks. A fallback that returns cached data or sensible defaults is far better than propagating exceptions. Design your system to degrade gracefully rather than fail completely. Log fallback invocations so you can correlate them with downstream incidents.

Use consistent naming conventions. Name circuit breakers after the service or resource they protect. This makes debugging and monitoring significantly easier. A convention like `{serviceName}_{operation}` (e.g., `inventoryService_checkStock`) allows dashboard filtering by service.

Combine with retry patterns carefully. When using both retry and circuit breaker, place the retry inside the circuit breaker. Otherwise, repeated retries can trigger the circuit to open prematurely. Three retries per call effectively multiplies your failure count by three from the circuit breaker's perspective.

Test your failure scenarios. Use tools like Chaos Monkey for Spring Boot (`spring-boot-chaos-monkey`) or Testcontainers with Toxiproxy to simulate network failures, latency spikes, and service outages in integration tests. Verify that your circuit breakers and fallbacks behave correctly before they do so in production.

Differentiate expected from unexpected failures. Use `ignoreExceptions` to exclude business exceptions (HTTP 404, validation errors) from the failure rate calculation. Only infrastructure failures. timeouts, connection resets, HTTP 5xx. should influence circuit state.

## Integrating with Spring Boot Applications

Spring Boot integration makes Resilience4j even more powerful. The auto-configuration handles most setup automatically:

```java
@Configuration
public class Resilience4jConfig {

 @Bean
 public CircuitBreakerRegistry circuitBreakerRegistry(CircuitBreakerConfig defaultConfig) {
 return CircuitBreakerRegistry.of(defaultConfig);
 }

 @Bean
 public CircuitBreakerConfig defaultCircuitBreakerConfig() {
 return CircuitBreakerConfig.custom()
 .failureRateThreshold(50)
 .waitDurationInOpenState(Duration.ofSeconds(30))
 .slidingWindowSize(10)
 .minimumNumberOfCalls(5)
 .build();
 }
}
```

With proper configuration, Resilience4j automatically applies circuit breaker logic to any method annotated with @CircuitBreaker, requiring minimal boilerplate code.

For microservice architectures with many downstream dependencies, Claude Code can help you generate a complete Resilience4j configuration matrix. Describe your service topology. which services call which, their expected SLAs, and their criticality. and Claude Code will generate a full `application.yml` with appropriate circuit breaker, retry, and timeout settings for each dependency. This is significantly faster than hand-tuning each configuration and produces a consistent starting point for further refinement.

## Writing Tests for Circuit Breaker Behavior

Testing circuit breaker behavior requires forcing the breaker into specific states. Resilience4j provides a `CircuitBreakerRegistry` that makes this straightforward in unit and integration tests:

```java
@SpringBootTest
class ProductServiceCircuitBreakerTest {

 @Autowired
 private ProductService productService;

 @Autowired
 private CircuitBreakerRegistry circuitBreakerRegistry;

 @MockBean
 private ProductApiClient productApiClient;

 @Test
 void shouldReturnFallbackWhenCircuitIsOpen() {
 // Force the circuit open
 CircuitBreaker cb = circuitBreakerRegistry.circuitBreaker("productService");
 cb.transitionToOpenState();

 // Should invoke fallback
 List<Product> result = productService.getProducts();
 assertThat(result).isEqualTo(productCache.get());

 // Verify API was never called
 verifyNoInteractions(productApiClient);
 }

 @Test
 void shouldOpenCircuitAfterThresholdFailures() {
 // Simulate failures
 when(productApiClient.fetchAll()).thenThrow(new IOException("Connection refused"));

 // Trip the circuit by exceeding failure threshold
 IntStream.range(0, 10).forEach(i -> {
 try { productService.getProducts(); } catch (Exception ignored) {}
 });

 CircuitBreaker cb = circuitBreakerRegistry.circuitBreaker("productService");
 assertThat(cb.getState()).isEqualTo(CircuitBreaker.State.OPEN);
 }
}
```

Claude Code is effective at generating these test cases from your service implementation. Paste in your service class and ask "generate unit tests that verify circuit breaker open, half-open transition, and fallback behavior". Claude Code will produce a complete test class covering the key state transitions.

## Conclusion

Resilience4j provides a solid, lightweight solution for implementing circuit breaker patterns in Java applications. By combining it with Claude Code's AI-assisted development, you can rapidly prototype, test, and deploy fault-tolerant systems. Start with simple configurations, monitor your metrics, and progressively tune your circuit breakers based on real-world traffic patterns.

The key to success is treating circuit breakers as living components that require ongoing attention and refinement as your system evolves. A circuit breaker configured for last year's traffic profile will not serve you well as your service scales, and Claude Code can help you revisit and update configurations as your observability data reveals new patterns.


---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-resilience4j-circuit-breaker-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Failsafe Java Resilience Workflow](/claude-code-for-failsafe-java-resilience-workflow/)
- [Advanced Claude Skills with Tool Use and Function Calling](/advanced-claude-skills-with-tool-use-and-function-calling/)
- [Agent Handoff Strategies for Long Running Tasks Guide](/agent-handoff-strategies-for-long-running-tasks-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


