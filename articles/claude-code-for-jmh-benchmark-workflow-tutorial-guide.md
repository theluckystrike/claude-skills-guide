---
layout: default
title: "Claude Code for JMH Java Benchmarks"
description: "Run JMH Java benchmarks with Claude Code. Project setup, benchmark implementation, result analysis, and continuous performance regression testing."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /claude-code-for-jmh-benchmark-workflow-tutorial-guide/
categories: [guides]
tags: [claude-code, claude-skills]
score: 7
reviewed: true
last_tested: "2026-04-21"
geo_optimized: true
---
Claude Code for JMH Benchmark Workflow Tutorial Guide

Java Microbenchmark Harness (JMH) is the standard tool for benchmarking Java code, but setting up and running JMH benchmarks effectively can be challenging. Writing benchmarks that produce trustworthy results requires avoiding JIT pitfalls, warmup subtleties, and dead-code elimination. This guide shows you how to use Claude Code to streamline every phase of your JMH workflow, project setup, benchmark implementation, execution, result analysis, and continuous performance regression testing.

Why Use Claude Code with JMH?

Claude Code brings several advantages to your benchmark workflow:

- Project scaffolding: Quickly generate JMH-enabled Maven or Gradle projects with proper dependencies
- Benchmark template generation: Create well-structured benchmark classes following JMH best practices
- Result interpretation: Analyze JMH output and explain what the numbers mean in practical terms
- Iteration and optimization: Rapidly modify and re-run benchmarks as you optimize your code
- Error detection: Catch common mistakes like missing Blackhole usage or incorrect scope annotations before you run

The combination of Claude Code's contextual understanding and JMH's precision makes for a powerful performance investigation workflow. Rather than reading through the full JMH documentation each time you start a new project, you can describe your goal in plain English and Claude Code generates a working starting point you can refine.

## Setting Up Your JMH Project

The first step is creating a JMH-capable project. Rather than manually configuring build files, ask Claude Code to scaffold everything for you.

## Maven Setup

For a Maven project, include the JMH dependencies and the JMH Maven plugin. The annotation processor dependency is what generates the benchmark runner code during compilation, this is easy to miss and will cause mysterious failures if omitted.

```xml
<dependency>
 <groupId>org.openjdk.jmh</groupId>
 <artifactId>jmh-core</artifactId>
 <version>1.37</version>
</dependency>
<dependency>
 <groupId>org.openjdk.jmh</groupId>
 <artifactId>jmh-generator-annprocess</artifactId>
 <version>1.37</version>
</dependency>
```

Add the shade plugin to package everything into a single executable jar:

```xml
<plugin>
 <groupId>org.apache.maven.plugins</groupId>
 <artifactId>maven-shade-plugin</artifactId>
 <version>3.5.1</version>
 <executions>
 <execution>
 <phase>package</phase>
 <goals>
 <goal>shade</goal>
 </goals>
 <configuration>
 <finalName>benchmark</finalName>
 <transformers>
 <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
 <mainClass>org.openjdk.jmh.Main</mainClass>
 </transformer>
 </transformers>
 </configuration>
 </execution>
 </executions>
</plugin>
```

You also need the maven-compiler-plugin to ensure annotation processing runs correctly:

```xml
<plugin>
 <groupId>org.apache.maven.plugins</groupId>
 <artifactId>maven-compiler-plugin</artifactId>
 <version>3.11.0</version>
 <configuration>
 <compilerVersion>17</compilerVersion>
 <source>17</source>
 <target>17</target>
 </configuration>
</plugin>
```

## Gradle Setup

For Gradle, the setup is simpler with the `jmh-gradle-plugin`:

```groovy
plugins {
 id 'me.champeau.jmh' version '0.7.2'
}

jmh {
 include = ['.*Benchmark.*']
 fork = 2
 warmupIterations = 3
 iterations = 5
 benchmarkMode = ['thrpt', 'avgt']
 resultsFile = project.file("${project.buildDir}/reports/jmh/results.json")
 resultFormat = 'JSON'
}
```

The `resultsFile` and `resultFormat` settings are worth configuring from the start. JSON output lets you parse and compare results across runs, which becomes essential when tracking performance regressions over time.

Ask Claude Code to generate either of these configurations and explain any parts you don't understand. A prompt like "Generate a complete Maven pom.xml for a JMH project targeting Java 17, including shade plugin setup" will produce a ready-to-use file.

## Writing Effective Benchmarks

A well-written benchmark is the key to meaningful results. Here's how Claude Code can help you write benchmarks that accurately measure what you care about.

## Basic Benchmark Structure

Every JMH benchmark follows a similar pattern:

```java
import org.openjdk.jmh.annotations.*;
import java.util.concurrent.TimeUnit;

@BenchmarkMode(Mode.Throughput)
@OutputTimeUnit(TimeUnit.MILLISECONDS)
@State(Scope.Thread)
@Warmup(iterations = 3, time = 1, timeUnit = TimeUnit.SECONDS)
@Measurement(iterations = 5, time = 1, timeUnit = TimeUnit.SECONDS)
@Fork(2)
public class StringBenchmark {

 private String input;

 @Setup(Level.Trial)
 public void prepare() {
 input = "hello world test string for benchmarking";
 }

 @Benchmark
 public String concat() {
 return input + " - appended";
 }

 @Benchmark
 public String builder() {
 return new StringBuilder(input).append(" - appended").toString();
 }
}
```

The annotations control everything about how JMH runs your benchmark. Ask Claude Code to explain each one: what `@BenchmarkMode` does, why `@State(Scope.Thread)` matters versus `Scope.Benchmark`, and how `@Setup(Level.Trial)` differs from `@Setup(Level.Iteration)`. Understanding these distinctions prevents subtle measurement errors.

## Annotation Reference

| Annotation | Purpose | Common Values |
|---|---|---|
| `@BenchmarkMode` | What to measure | `Throughput`, `AverageTime`, `SampleTime`, `SingleShotTime` |
| `@OutputTimeUnit` | Unit for reported times | `MICROSECONDS`, `MILLISECONDS`, `NANOSECONDS` |
| `@State` | Lifecycle scope for benchmark state | `Scope.Thread`, `Scope.Benchmark`, `Scope.Group` |
| `@Warmup` | Warmup configuration | iterations, time, timeUnit |
| `@Measurement` | Measurement configuration | iterations, time, timeUnit |
| `@Fork` | JVM fork count | Integer, typically 1-3 |
| `@Setup` | Pre-benchmark initialization | `Level.Trial`, `Level.Iteration`, `Level.Invocation` |
| `@TearDown` | Post-benchmark cleanup | Same levels as @Setup |
| `@Param` | Parameterize over multiple values | Array of string values |

## Common Benchmark Patterns

Claude Code can help you implement several common benchmark scenarios.

Comparing implementations: Compare different approaches to the same problem by writing multiple `@Benchmark` methods in the same class. This is the most common pattern and the easiest way to answer "which implementation is faster?"

Testing with different inputs: Use `@Param` to run the same benchmark with multiple input values:

```java
@State(Scope.Thread)
public class CollectionBenchmark {

 @Param({"100", "1000", "10000"})
 private int size;

 private List<Integer> data;

 @Setup
 public void setup() {
 data = new ArrayList<>(size);
 for (int i = 0; i < size; i++) {
 data.add(i);
 }
 }

 @Benchmark
 public long streamSum() {
 return data.stream().mapToLong(Integer::longValue).sum();
 }

 @Benchmark
 public long loopSum() {
 long sum = 0;
 for (int val : data) {
 sum += val;
 }
 return sum;
 }
}
```

This generates six benchmark results, two methods times three parameter values, letting you see how each implementation scales.

Blackhole consumption: Prevent the JIT compiler from optimizing away your benchmark by using Blackhole. If you compute a result but never use it, the JIT is allowed to skip the computation entirely, making your benchmark measure nothing:

```java
@Benchmark
public void processWithBlackhole(Blackhole bh) {
 String result = expensiveOperation();
 bh.consume(result);
}

// Alternative: return the result directly
@Benchmark
public String processWithReturn() {
 return expensiveOperation();
}
```

Both patterns are valid. Returning a value is simpler; Blackhole is useful when your method has side effects you want to include or when you need to consume multiple intermediate values.

Testing concurrent code: Use `@Group` and `Scope.Group` to benchmark producer-consumer patterns:

```java
@State(Scope.Group)
public class QueueBenchmark {

 private BlockingQueue<Integer> queue = new LinkedBlockingQueue<>(1000);

 @Benchmark
 @Group("producerConsumer")
 @GroupThreads(2)
 public void producer() throws InterruptedException {
 queue.put(42);
 }

 @Benchmark
 @Group("producerConsumer")
 @GroupThreads(2)
 public Integer consumer() throws InterruptedException {
 return queue.take();
 }
}
```

Ask Claude Code to generate thread-safety-aware benchmarks when you're working with concurrent data structures.

## Running Your Benchmarks

Once your benchmarks are written, running them properly is crucial for accurate results.

## Command Line Execution

Run benchmarks using Maven or Gradle:

```bash
Maven: build then run
mvn clean package -q
java -jar target/benchmark.jar

Run specific benchmark class
java -jar target/benchmark.jar StringBenchmark

Gradle
./gradlew jmh

Gradle with filter
./gradlew jmh --include '.*StringBenchmark.*'
```

## Key JMH Command-Line Flags

When running the jar directly, you have fine-grained control over execution:

```bash
Full example with common options
java -jar target/benchmark.jar \
 -f 2 \
 -wi 3 -w 1s \
 -i 5 -r 1s \
 -rf json \
 -rff results.json \
 StringBenchmark
```

| Flag | Description | Recommended Value |
|---|---|---|
| `-f <n>` | Fork count (separate JVM processes) | 2-3 for reliability |
| `-wi <n>` | Warmup iterations | 3-5 |
| `-w <time>` | Warmup iteration duration | 1s |
| `-i <n>` | Measurement iterations | 5-10 |
| `-r <time>` | Measurement iteration duration | 1s |
| `-rf <format>` | Result format (json, csv, text) | json |
| `-rff <file>` | Result file path | results.json |
| `-t <n>` | Thread count | 1 for single-threaded |
| `-prof gc` | Enable GC profiler | When GC pressure matters |

The `-prof gc` option is particularly valuable when benchmarking memory-intensive operations. It adds allocation rate and GC pause data to your output, letting you understand whether one implementation is faster because it allocates less.

## Interpreting Results

After running, JMH produces output like this:

```
Benchmark (size) Mode Cnt Score Error Units
CollectionBenchmark.loopSum 100 thrpt 10 85234.423 ± 1203.451 ops/ms
CollectionBenchmark.loopSum 1000 thrpt 10 9847.212 ± 234.892 ops/ms
CollectionBenchmark.loopSum 10000 thrpt 10 987.321 ± 45.123 ops/ms
CollectionBenchmark.streamSum 100 thrpt 10 72341.892 ± 2341.023 ops/ms
CollectionBenchmark.streamSum 1000 thrpt 10 8234.123 ± 198.341 ops/ms
CollectionBenchmark.streamSum 10000 thrpt 10 912.432 ± 41.234 ops/ms
```

Ask Claude Code to interpret these results in context. It can explain:
- What "thrpt" (throughput) means versus "avgt" (average time) and when to use each
- How to compare scores between benchmarks while accounting for error margins
- Whether a difference is statistically significant or within noise
- What the numbers mean for your specific use case (e.g., "at 1000 elements, loopSum is about 16% faster")

The `±` column is the 99.9% confidence interval. If two benchmarks' error ranges overlap, the difference may not be meaningful. Claude Code can help you determine whether you need more iterations to get a decisive result.

## Common Pitfalls and How Claude Code Helps You Avoid Them

JMH benchmarking has several well-known failure modes. Claude Code can audit your benchmark code and flag these issues before you waste time running flawed measurements.

## Dead Code Elimination

The JIT compiler aggressively eliminates code that doesn't affect observable program state. A benchmark that computes a value but never uses it is measuring nothing:

```java
// Wrong: JIT may eliminate this entirely
@Benchmark
public void badBenchmark() {
 int result = 0;
 for (int i = 0; i < 1000; i++) {
 result += i;
 }
 // result is never used
}

// Correct: return or consume the result
@Benchmark
public int goodBenchmark() {
 int result = 0;
 for (int i = 0; i < 1000; i++) {
 result += i;
 }
 return result;
}
```

## Constant Folding

If your benchmark inputs are constants, the JIT may precompute the result at compile time:

```java
// Wrong: JIT can fold this to a constant
@Benchmark
public double badMath() {
 return Math.sqrt(144); // Becomes 12.0 at compile time
}

// Correct: use state fields
@State(Scope.Thread)
public class MathBenchmark {
 private double value = 144.0;

 @Benchmark
 public double goodMath() {
 return Math.sqrt(value);
 }
}
```

## Loop Unrolling

The JIT may unroll or vectorize loops in ways that don't reflect real workload behavior. Use realistic data sizes and avoid trivially small loops.

## Setup Overhead in Measurements

Using `@Setup(Level.Invocation)` runs setup before every single benchmark invocation, which can dominate measurement time for fast operations. Reserve invocation-level setup for benchmarks where state must be reset between calls (like sorting an already-sorted array):

```java
// Only appropriate for benchmarks that modify state
@State(Scope.Thread)
public class SortBenchmark {
 private int[] data;
 private int[] original;

 @Setup(Level.Trial)
 public void prepare() {
 original = new int[1000];
 // ... fill with random data
 }

 @Setup(Level.Invocation)
 public void resetData() {
 data = Arrays.copyOf(original, original.length);
 }

 @Benchmark
 public void sort() {
 Arrays.sort(data);
 }
}
```

## Best Practices for Reliable Benchmarks

Follow these guidelines, and ask Claude Code to review your implementation against them:

1. Always warm up: Include at least 3 warmup iterations so JIT compilation and class loading don't skew results. Cold-start measurements are almost never what you want.

2. Use appropriate modes: Choose `Throughput` for batch processing operations, `AverageTime` for latency-sensitive code like database queries or API calls, and `SampleTime` when you need percentile distributions.

3. Avoid dead code elimination: Use Blackhole or return results. When in doubt, ask Claude Code to review whether your results are actually being observed.

4. Fork between iterations: Run each benchmark in a fresh JVM with `-f 2` or higher. This prevents JIT state from one benchmark contaminating another, and catches JVM-startup variability.

5. Measure realistic workloads: Your benchmark data should reflect actual production patterns. Benchmarking with 10-element lists when production uses 100,000-element lists will give you misleading guidance.

6. Run on stable hardware: Disable CPU frequency scaling and close other applications when running benchmarks you intend to compare across time. Laptop benchmarks vary significantly based on thermal throttling.

7. Version your benchmark results: Save JSON output alongside your code so you can compare across commits. Claude Code can help write scripts that diff two result files and flag regressions.

## Integrating Claude Code into Your Workflow

Here's a practical workflow for using Claude Code with JMH across a real performance investigation:

Step 1. Initial investigation: Describe the performance problem to Claude Code. "Our JSON serialization is taking too long under high load, what should we benchmark?" Claude Code may suggest specific methods to measure and propose a benchmark structure before you write any code.

Step 2. Scaffold project: Ask Claude Code to generate a properly configured JMH project matching your build tool. Provide your existing project structure and it will integrate the JMH configuration without disrupting existing code.

Step 3. Write benchmarks: Describe what you want to measure in plain English. "Compare Jackson ObjectMapper versus Gson for serializing a 50-field POJO, testing both single objects and lists of 100." Claude Code generates a complete benchmark class with appropriate `@Param` configurations.

Step 4. Review for pitfalls: Before running, paste your benchmark class back to Claude Code and ask it to review for common JMH mistakes. This catches dead code elimination issues and incorrect scope annotations.

Step 5. Run and analyze: Execute benchmarks with JSON output and paste the results to Claude Code. Ask for a plain-English summary: which approach is faster, by how much, and whether the difference matters at your scale.

Step 6. Iterate: As you make optimizations, re-run benchmarks and compare JSON output files. Ask Claude Code to summarize what changed between runs and whether improvements are statistically significant.

Step 7. Regression testing: Once you have baseline results, write a simple CI script that runs benchmarks and fails if key metrics regress by more than a threshold. Claude Code can generate both the benchmark and the comparison script.

This workflow transforms JMH from a complex tool into a natural part of your development process. Performance work that previously required deep JMH expertise becomes accessible to any developer on the team.

## A Complete Working Example

Here is a complete benchmark comparing four approaches to building a comma-separated string from a list:

```java
import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.infra.Blackhole;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.MICROSECONDS)
@State(Scope.Thread)
@Warmup(iterations = 3, time = 1, timeUnit = TimeUnit.SECONDS)
@Measurement(iterations = 5, time = 1, timeUnit = TimeUnit.SECONDS)
@Fork(2)
public class JoinBenchmark {

 @Param({"10", "100", "1000"})
 private int size;

 private List<String> items;

 @Setup
 public void setup() {
 items = new ArrayList<>(size);
 for (int i = 0; i < size; i++) {
 items.add("item" + i);
 }
 }

 @Benchmark
 public void stringJoin(Blackhole bh) {
 bh.consume(String.join(",", items));
 }

 @Benchmark
 public void streamCollect(Blackhole bh) {
 bh.consume(items.stream().collect(Collectors.joining(",")));
 }

 @Benchmark
 public void stringBuilder(Blackhole bh) {
 StringBuilder sb = new StringBuilder();
 for (int i = 0; i < items.size(); i++) {
 if (i > 0) sb.append(',');
 sb.append(items.get(i));
 }
 bh.consume(sb.toString());
 }

 @Benchmark
 public void stringConcat(Blackhole bh) {
 String result = "";
 for (String item : items) {
 if (!result.isEmpty()) result += ",";
 result += item;
 }
 bh.consume(result);
 }
}
```

This benchmark is complete and correct. It uses Blackhole properly, parameterizes over realistic sizes, and includes warmup and fork configuration. Generate this kind of starting template by describing your requirements to Claude Code, then customize it for your specific comparison.

## Conclusion

Claude Code makes JMH benchmarking accessible by handling project setup, generating benchmark code, reviewing implementations for common pitfalls, and interpreting results. Start with simple benchmarks that answer a specific question, follow the best practices around warmup and dead code elimination, and let Claude Code guide you through the process. Your performance optimization efforts will benefit from more accurate, reliable benchmark data, and you'll develop a solid understanding of JMH that carries forward to future investigations.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-jmh-benchmark-workflow-tutorial-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading


- [Getting Started Guide](/getting-started/). From zero to productive with Claude Code
- [Claude Code for API Benchmark Workflow Tutorial Guide](/claude-code-for-api-benchmark-workflow-tutorial-guide/)
- [Claude Code for Benchmark CI Integration Workflow](/claude-code-for-benchmark-ci-integration-workflow/)
- [Claude Code for Benchmark Regression Workflow Tutorial](/claude-code-for-benchmark-regression-workflow-tutorial/)
- [Claude Code for Babylon.js Workflow Tutorial Guide](/claude-code-for-babylon-js-workflow-tutorial-guide/)
- [Claude Code for Argo Rollouts Canary Workflow Guide](/claude-code-for-argo-rollouts-canary-workflow-guide/)
- [Claude Code For Tooljet Low Code — Complete Developer Guide](/claude-code-for-tooljet-low-code-workflow-guide/)
- [Claude Code for Across Protocol Workflow](/claude-code-for-across-protocol-workflow/)
- [Claude Code Phoenix LiveView Workflow Guide](/claude-code-phoenix-liveview-workflow-guide/)
- [Claude Code for Version Bump Workflow Tutorial Guide](/claude-code-for-version-bump-workflow-tutorial-guide/)
- [Claude Code for Pulsar Tenant Workflow Tutorial](/claude-code-for-pulsar-tenant-workflow-tutorial/)
- [Claude Code for Code Intelligence Indexing Workflow](/claude-code-for-code-intelligence-indexing-workflow/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)





---

## Frequently Asked Questions

### What is Setting Up Your JMH Project?

JMH project setup involves configuring either Maven or Gradle with the `jmh-core` and `jmh-generator-annprocess` dependencies (version 1.37). The annotation processor dependency generates benchmark runner code during compilation and is frequently overlooked, causing mysterious failures. Ask Claude Code to scaffold a complete build configuration with the shade plugin (Maven) or jmh-gradle-plugin (Gradle) targeting your Java version. Configure JSON result output from the start to enable cross-run comparisons and regression tracking.

### What is Maven Setup?

Maven setup requires three components: the `jmh-core` and `jmh-generator-annprocess` dependencies (version 1.37), the `maven-shade-plugin` (version 3.5.1) to package everything into a single executable jar with `org.openjdk.jmh.Main` as the main class, and the `maven-compiler-plugin` (version 3.11.0) configured for Java 17 to ensure annotation processing runs correctly. Build with `mvn clean package -q`, then run benchmarks with `java -jar target/benchmark.jar`.

### What is Gradle Setup?

Gradle setup uses the `me.champeau.jmh` plugin version 0.7.2 with configuration for include patterns, fork count, warmup/measurement iterations, benchmark modes (`thrpt` and `avgt`), and JSON result output via `resultsFile` and `resultFormat` settings. Run benchmarks with `./gradlew jmh` or filter specific classes with `--include '.*StringBenchmark.*'`. The JSON output format is essential for parsing and comparing results across runs for performance regression tracking.

### What is Writing Effective Benchmarks?

Effective JMH benchmarks follow specific patterns to avoid measurement errors. Every benchmark method needs the `@Benchmark` annotation. Use `@BenchmarkMode` to select Throughput, AverageTime, or SampleTime measurement. Prevent dead code elimination by returning computed values or consuming them with `Blackhole.consume()`. Use `@Param` for testing with multiple input sizes. Apply `@State(Scope.Thread)` for thread-local state and `@Setup(Level.Trial)` for one-time initialization to avoid setup overhead contaminating measurements.

### What is Basic Benchmark Structure?

The basic JMH benchmark structure is a Java class annotated with `@BenchmarkMode(Mode.Throughput)`, `@OutputTimeUnit(TimeUnit.MILLISECONDS)`, `@State(Scope.Thread)`, `@Warmup(iterations = 3, time = 1)`, `@Measurement(iterations = 5, time = 1)`, and `@Fork(2)`. State fields are initialized in a `@Setup(Level.Trial)` method. Each benchmark method carries the `@Benchmark` annotation and returns or consumes its result to prevent JIT dead code elimination. Multiple benchmark methods in one class enable direct comparison of implementations.
