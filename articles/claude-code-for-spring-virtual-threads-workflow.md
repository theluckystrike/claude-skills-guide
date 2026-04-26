---

layout: default
title: "Claude Code for Spring Virtual Threads (2026)"
description: "Learn how to use Claude Code to build efficient Spring applications with Virtual Threads. Practical examples and workflow patterns for modern Java."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-spring-virtual-threads-workflow/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---


Claude Code for Spring Virtual Threads Workflow

Virtual Threads, introduced in Java 21 and backported to Java 17+ via the Thread API, represent a paradigm shift in concurrent Java application development. When combined with Spring Boot's powerful ecosystem, they enable building highly scalable applications with minimal thread management overhead. This guide shows you how to use Claude Code to streamline your Spring Virtual Threads development workflow.

## Understanding Virtual Threads in Spring Context

Traditional platform threads are expensive to create and manage. Each thread consumes significant memory (roughly 1MB of stack space by default) and requires context switching overhead that adds latency under heavy concurrency. The result is that traditional Java web applications hit scalability ceilings long before they exhaust CPU capacity. the bottleneck is thread count, not computation.

Virtual threads solve this by decoupling thread execution from OS threads. The JVM manages a small pool of carrier threads (typically one per CPU core) and multiplexes millions of virtual threads onto them. When a virtual thread blocks on I/O, it parks automatically and the carrier thread picks up another virtual thread. From the developer's perspective, you write straightforward blocking code. From the runtime's perspective, the CPU never sits idle waiting for a network call to return.

In Spring applications, Virtual Threads are particularly valuable for:

- IO-bound microservices: Handling thousands of concurrent requests with minimal resource usage. A single node can sustain 50,000+ concurrent virtual threads without OOM errors.
- Reactive-to-synchronous migration: Converting reactive code to simpler synchronous patterns without sacrificing scalability. You get the throughput of WebFlux with the readability of traditional Spring MVC.
- Batch processing: Processing large datasets concurrently without thread pool exhaustion. Each item in a batch can run in its own virtual thread.
- Integration services: Services that fan out to multiple downstream APIs benefit enormously. All those blocking HTTP calls overlap in time instead of queuing.

The distinction matters most in I/O-heavy work. CPU-bound tasks (encryption, image processing, heavy computation) do not benefit from virtual threads the same way. Virtual threads shine where threads spend most of their time waiting rather than computing.

## Setting Up Spring Boot with Virtual Threads

Claude Code can help you configure Virtual Threads quickly. Start by ensuring you have the right Java version and Spring Boot dependencies.

```java
// First, verify your Java version supports Virtual Threads
// Run: java -version (requires Java 21+ or Java 17+ with --enable-preview)

@Configuration
public class VirtualThreadConfig {

 @Bean
 public TaskExecutor taskExecutor() {
 TaskExecutorBuilder builder = new TaskExecutorBuilder();
 builder.threadNamePrefix("virtual-");
 // Use Spring's VirtualThreadPerTaskExecutor
 return new VirtualThreadPerTaskExecutor();
 }
}
```

For Spring Boot 3.2 and later, you can enable virtual threads for the entire embedded Tomcat container with a single property:

```yaml
spring:
 threads:
 virtual:
 enabled: true
```

This one line switches Tomcat's request-handling thread pool to virtual threads. Every incoming HTTP request runs in a fresh virtual thread, so blocking database calls or downstream HTTP calls no longer hold platform threads hostage. Claude Code can generate this configuration automatically when you describe your requirements. simply explain your async needs, and Claude will produce the appropriate Spring configuration.

For projects on Spring Boot 3.1 or earlier, you need to configure the servlet container manually:

```java
@Configuration
public class TomcatVirtualThreadConfig {

 @Bean
 public TomcatProtocolHandlerCustomizer<?> protocolHandlerCustomizer() {
 return protocolHandler -> {
 protocolHandler.setExecutor(
 Executors.newVirtualThreadPerTaskExecutor()
 );
 };
 }
}
```

If you use Spring's `@Async` annotation for background tasks, wire a virtual thread executor as the default:

```java
@Configuration
@EnableAsync
public class AsyncConfig implements AsyncConfigurer {

 @Override
 public Executor getAsyncExecutor() {
 return Executors.newVirtualThreadPerTaskExecutor();
 }
}
```

Claude Code is particularly useful here because the correct configuration differs depending on your Spring Boot version, your container choice (Tomcat, Jetty, Undertow), and whether you are using reactive or servlet-based MVC. Rather than hunting through changelogs, you can describe your stack and let Claude generate the exact configuration.

## Building Async Workflows with Virtual Threads

The real power of Virtual Threads emerges when building async workflows. Here's a practical pattern for handling multiple IO operations concurrently:

```java
@Service
public class OrderProcessingService {

 private final RestTemplate restTemplate;
 private final OrderRepository orderRepository;

 public OrderProcessingService(RestTemplateBuilder builder,
 OrderRepository orderRepository) {
 this.restTemplate = builder.build();
 this.orderRepository = orderRepository;
 }

 public List<OrderResult> processOrders(List<Long> orderIds) {
 // Virtual threads make this pattern practical
 return orderIds.parallelStream()
 .map(this::processSingleOrder)
 .toList();
 }

 @Async
 public OrderResult processSingleOrder(Long orderId) {
 // Each order runs in its own virtual thread
 Order order = orderRepository.findById(orderId);
 PaymentResult payment = callPaymentService(order);
 NotificationResult notification = sendNotification(order);

 return new OrderResult(orderId, payment, notification);
 }
}
```

This pattern becomes scalable with Virtual Threads because creating millions of virtual threads is as cheap as creating regular objects. Claude Code can refactor existing async code to use these patterns.

A more explicit approach using `StructuredTaskScope` (available in Java 21 preview, stabilizing in 22+) gives you even finer control over concurrent subtasks:

```java
@Service
public class ProductAggregatorService {

 public ProductBundle fetchProductBundle(Long productId)
 throws InterruptedException, ExecutionException {

 try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
 // All three calls run concurrently in separate virtual threads
 StructuredTaskScope.Subtask<Product> productTask =
 scope.fork(() -> productRepository.findById(productId));

 StructuredTaskScope.Subtask<List<Review>> reviewsTask =
 scope.fork(() -> reviewService.fetchReviews(productId));

 StructuredTaskScope.Subtask<InventoryStatus> inventoryTask =
 scope.fork(() -> inventoryService.getStatus(productId));

 scope.join(); // Wait for all subtasks
 scope.throwIfFailed(); // Propagate any failure

 return new ProductBundle(
 productTask.get(),
 reviewsTask.get(),
 inventoryTask.get()
 );
 }
 }
}
```

The `ShutdownOnFailure` scope cancels all subtasks the moment any one of them fails, which prevents dangling threads and simplifies error handling. Claude Code can generate the `StructuredTaskScope` pattern from a description of your fan-out logic. you describe which calls should run in parallel and what to do on failure, and Claude produces the correct scope type and subtask wiring.

## Integrating with Spring WebFlux

If you're migrating from WebFlux to traditional Spring MVC with Virtual Threads, Claude can help identify blocking operations that need attention:

```java
@RestController
public class ProductController {

 private final ProductService productService;

 public ProductController(ProductService productService) {
 this.productService = productService;
 }

 @GetMapping("/products/{id}")
 public ResponseEntity<Product> getProduct(@PathVariable Long id) {
 // With Virtual Threads, this blocking call doesn't
 // block the carrier thread pool
 Product product = productService.findById(id);
 return ResponseEntity.ok(product);
 }
}
```

The migration path from WebFlux to synchronous Spring MVC with Virtual Threads is not always straightforward. Claude can analyze your existing WebFlux controllers and suggest which ones can safely migrate to synchronous patterns with Virtual Threads, reducing code complexity while maintaining throughput.

When migrating, the key things Claude checks for include:

- Operators that have no synchronous equivalent (e.g., `delayElements`, `buffer`, `window`). these require alternative approaches
- Backpressure requirements that the caller genuinely needs (rare in HTTP APIs, common in streaming pipelines)
- Reactive database drivers like R2DBC. if your data layer is reactive, you cannot simply block on it without switching drivers

A practical migration approach is to tackle one controller at a time. Claude can diff a WebFlux controller against a synchronous equivalent and flag any semantic differences, making the review process faster than doing it manually.

## Virtual Threads vs. Traditional Thread Pools: When to Choose

Understanding which approach fits your workload helps you use Claude Code prompts more effectively.

| Scenario | Platform Threads | Virtual Threads | Reactive (WebFlux) |
|---|---|---|---|
| Low concurrency (< 200 req/s) | Fine | Fine | Overkill |
| High I/O concurrency (thousands of simultaneous requests) | Thread pool exhaustion risk | Ideal | Ideal |
| CPU-intensive work | Ideal | No benefit | Avoid |
| Existing blocking libraries (JDBC, RestTemplate) | Fine | Ideal | Requires reactive drivers |
| Team familiar with reactive programming | Fine | Fine | Fine |
| Team unfamiliar with reactive | Fine | Ideal (simpler code) | Steep learning curve |
| Mixed I/O + CPU | Separate executors | Separate executors | Separate schedulers |

For the vast majority of microservices. CRUD APIs hitting a database and calling downstream services. virtual threads are the right choice in 2026. The synchronous code is easier to read, profile, and debug, and the scalability is comparable to reactive.

## Testing Virtual Thread Applications

Testing concurrent code is challenging, but Claude Code can help generate comprehensive test scenarios:

```java
@SpringBootTest
class OrderProcessingServiceTest {

 @Autowired
 private OrderProcessingService service;

 @Test
 void shouldProcessMultipleOrdersConcurrently() throws Exception {
 List<Long> orderIds = LongStream.range(1, 1000)
 .boxed()
 .toList();

 var startTime = Instant.now();
 List<OrderResult> results = service.processOrders(orderIds);
 var duration = Duration.between(startTime, Instant.now());

 assertEquals(1000, results.size());
 assertTrue(duration.toSeconds() < 10,
 "Processing should complete within 10 seconds");
 }
}
```

Beyond timing assertions, you want to verify that your code handles concurrent access to shared state correctly. Claude Code can generate tests that deliberately stress concurrent paths:

```java
@Test
void shouldHandleConcurrentRequestsWithoutDataCorruption()
 throws InterruptedException {
 int threadCount = 500;
 CountDownLatch latch = new CountDownLatch(threadCount);
 ConcurrentLinkedQueue<OrderResult> results = new ConcurrentLinkedQueue<>();
 ConcurrentLinkedQueue<Throwable> errors = new ConcurrentLinkedQueue<>();

 ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();
 for (int i = 0; i < threadCount; i++) {
 long orderId = i + 1;
 executor.submit(() -> {
 try {
 results.add(service.processSingleOrder(orderId));
 } catch (Throwable t) {
 errors.add(t);
 } finally {
 latch.countDown();
 }
 });
 }

 latch.await(30, TimeUnit.SECONDS);
 executor.shutdown();

 assertTrue(errors.isEmpty(),
 "No errors expected, got: " + errors.size());
 assertEquals(threadCount, results.size(),
 "All requests should complete");
}
```

Claude can also help you write load tests using tools like Gatling or JMeter to verify your Virtual Thread implementation handles expected traffic. For detecting pinning issues (see performance section below), use JFR (Java Flight Recorder) events. Claude can generate the JFR configuration and a parsing script that flags pinned virtual thread events in test output.

## Performance Considerations

While Virtual Threads simplify concurrent programming, keep these considerations in mind:

Avoid synchronized blocks: They can cause virtual thread pinning to carrier threads. When a virtual thread enters a `synchronized` block, the JVM currently pins it to its carrier thread for the duration. Use `ReentrantLock` instead:

```java
// Problematic: can pin virtual threads
private final Object lock = new Object();
public void updateCounter() {
 synchronized (lock) {
 counter++;
 }
}

// Correct: ReentrantLock supports virtual thread unmounting
private final ReentrantLock lock = new ReentrantLock();
public void updateCounter() {
 lock.lock();
 try {
 counter++;
 } finally {
 lock.unlock();
 }
}
```

Thread-local variables: Each virtual thread has its own thread-local storage, but excessive use can increase memory overhead when you have millions of virtual threads. Prefer `ScopedValue` (JEP 429, available as a preview in Java 21) for passing context through call stacks:

```java
// Prefer ScopedValue over ThreadLocal for context propagation
static final ScopedValue<RequestContext> REQUEST_CONTEXT = ScopedValue.newInstance();

public ResponseEntity<Product> handleRequest(RequestContext ctx, Long productId) {
 return ScopedValue.where(REQUEST_CONTEXT, ctx)
 .call(() -> productService.findById(productId));
}
```

Database connections: Ensure your connection pool can handle the increased concurrency. HikariCP with appropriately sized pools works well with Virtual Threads. With virtual threads you can suddenly have far more concurrent database requests than your pool can serve. size accordingly or you will simply shift the bottleneck from threads to connections:

```yaml
spring:
 datasource:
 hikari:
 maximum-pool-size: 50 # Tune based on DB capacity
 minimum-idle: 10
 connection-timeout: 3000 # Fail fast rather than queue indefinitely
```

Monitoring: Use Spring Boot Actuator with Micrometer to track virtual thread metrics:

```yaml
management:
 metrics:
 enable:
 virtual: true
 threads:
 virtual:
 enabled: true
```

Enable JFR pinning events in your staging environment to catch `synchronized` usage before it reaches production:

```bash
java -XX:StartFlightRecording=filename=recording.jfr \
 -Djdk.tracePinnedThreads=full \
 -jar your-application.jar
```

Claude Code can analyze JFR recordings and pinpoint specific methods that trigger pinning, saving hours of manual profiling.

## Claude Code Workflow for Virtual Threads Projects

Here's a practical workflow for using Claude Code effectively in your Virtual Threads projects:

Step 1. Initial setup: Ask Claude to generate Spring Boot configuration with Virtual Threads enabled, specifying your Spring Boot version and container type. Claude produces the exact properties and `@Configuration` classes you need.

Step 2. Code migration: Share existing async code (CompletableFuture chains, WebFlux pipelines, thread pool submits) and request Virtual Thread refactoring. Claude identifies which patterns map cleanly to blocking synchronous code and which require more careful handling.

Step 3. Pinning audit: Paste your service classes and ask Claude to identify `synchronized` blocks and third-party library calls that may trigger pinning. Claude can suggest `ReentrantLock` replacements and flag libraries with known pinning issues (some older JDBC drivers, certain logging frameworks).

Step 4. Testing: Have Claude generate comprehensive concurrency tests, including both correctness tests (no data corruption under load) and performance tests (latency stays within SLA under N concurrent virtual threads).

Step 5. Optimization: Request analysis of potential thread-local overuse, connection pool sizing, and `ScopedValue` migration opportunities.

Step 6. Documentation: Generate API documentation explaining Virtual Thread patterns used, including guidance for future maintainers on which locks are safe to use and why certain code patterns were chosen.

Claude's ability to understand context makes it particularly effective for Virtual Threads work, as it can reason about concurrent execution patterns and suggest improvements specific to your application's needs.

## Conclusion

Virtual Threads in Spring represent a significant advancement in building scalable Java applications. By using Claude Code as your development partner, you can accelerate Virtual Thread adoption through automated code generation, refactoring, and testing assistance. The combination of Spring's powerful framework and AI-assisted development creates an efficient workflow for building modern, highly concurrent applications.

The migration path is incremental: start by enabling virtual threads at the container level, verify that your throughput improves and your error rates stay flat, then progressively refactor any remaining thread pool usage. Use Claude to surface pinning issues before they reach production, generate realistic concurrency tests, and produce the configuration boilerplate that would otherwise require reading multiple changelogs.

Virtual threads do not replace all concurrency patterns. CPU-bound work still needs dedicated thread pools, and streaming data pipelines may still warrant reactive approaches. But for the common case of I/O-bound microservices with blocking libraries, virtual threads give you reactive-grade scalability with synchronous-grade code simplicity. That tradeoff is hard to beat.


---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-spring-virtual-threads-workflow)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for Java Virtual Threads (Loom) Workflow](/claude-code-for-java-virtual-threads-loom-workflow/)
- [Claude Code for Node.js Worker Threads Workflow](/claude-code-for-nodejs-worker-threads-workflow/)
- [Claude Code for Spring WebFlux Workflow Tutorial](/claude-code-for-spring-webflux-workflow-tutorial/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


