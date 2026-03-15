---

layout: default
title: "Claude Code for JMH Benchmark Workflow Tutorial Guide"
description: "Learn how to use Claude Code to streamline your JMH benchmark workflow. From project setup to running benchmarks and analyzing results, this guide covers practical examples and actionable advice."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /claude-code-for-jmh-benchmark-workflow-tutorial-guide/
categories: [guides]
tags: [claude-code, claude-skills]
---

{% raw %}
# Claude Code for JMH Benchmark Workflow Tutorial Guide

Java Microbenchmark Harness (JMH) is the standard tool for benchmarking Java code, but setting up benchmarks, running them correctly, and analyzing results can be error-prone. Claude Code transforms this workflow by helping you write correct benchmarks, configure proper measurement settings, and interpret results accurately. This guide walks you through using Claude Code to create a complete JMH benchmark workflow.

## Why Use Claude Code with JMH

JMH benchmarks require careful setup to produce meaningful results. Common pitfalls include dead code elimination, JIT compiler optimizations, and improper warmup configuration. Claude Code helps you avoid these issues by:

- Generating correct benchmark scaffolding
- Explaining JMH annotations and their effects
- Validating benchmark code for common mistakes
- Interpreting benchmark results in context
- Suggesting optimizations based on performance data

Whether you're optimizing a critical algorithm or comparing implementation approaches, Claude Code accelerates your benchmark workflow significantly.

## Setting Up Your JMH Project

### Maven Configuration

Start by creating a proper Maven project structure. Claude Code can generate the necessary pom.xml configuration with JMH dependencies:

```xml
<dependencies>
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
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-shade-plugin</artifactId>
            <version>3.5.1</version>
            <executions>
                <execution>
                    <phase>package</phase>
                    <goals><goal>shade</goal></goals>
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
    </plugins>
</build>
```

### Project Structure

Ask Claude Code to create a standard project structure:

```
src/
└── main/
    └── java/
        └── com/
            └── example/
                └── benchmark/
                    └── MyBenchmark.java
```

Claude Code will ensure your benchmark class follows JMH conventions with proper package placement.

## Writing Your First Benchmark

### Basic Benchmark Structure

Here's a properly structured JMH benchmark that Claude Code can help you create:

```java
package com.example.benchmark;

import org.openjdk.jmh.annotations.*;

@BenchmarkMode(Mode.Throughput)
@OutputTimeUnit(java.util.concurrent.TimeUnit.MILLISECONDS)
@State(Scope.Thread)
@Warmup(iterations = 3, time = 1)
@Measurement(iterations = 5, time = 1)
@Fork(2)
public class StringBuilderBenchmark {

    private StringBuilder stringBuilder;

    @Setup
    public void setup() {
        stringBuilder = new StringBuilder();
    }

    @Benchmark
    public String appendSingle() {
        stringBuilder.setLength(0);
        for (int i = 0; i < 100; i++) {
            stringBuilder.append("a");
        }
        return stringBuilder.toString();
    }

    @Benchmark
    public String appendMultiple() {
        stringBuilder.setLength(0);
        stringBuilder.append("a").append("b").append("c");
        return stringBuilder.toString();
    }
}
```

### Key Annotations Explained

Claude Code can explain each annotation's purpose:

- **@Benchmark**: Marks methods to be measured
- **@State(Scope.Thread)**: Creates separate state for each thread
- **@Setup**: Runs before each benchmark iteration
- **@BenchmarkMode(Mode.Throughput)**: Measures operations per time unit
- **@Warmup**: Configures warmup iterations to trigger JIT compilation
- **@Measurement**: Sets the actual measurement iterations
- **@Fork**: Runs benchmarks in separate JVM processes

When writing benchmarks, ask Claude Code to verify your annotations are correct and appropriate for your use case.

## Running Benchmarks with Claude Code

### Command-Line Execution

Build and run your benchmarks using Maven:

```bash
mvn clean package
java -jar target/benchmark.jar -f 1
```

Claude Code can help you construct the right command-line arguments. Common useful options include:

- `-f 1`: Run each fork once (use more forks for stable results)
- `-wi 5`: Override warmup iterations
- `-i 5`: Override measurement iterations
- `-o results.json`: Output results to JSON
- `-rf json`: Use JSON result format

### Interactive Benchmark Development

Work with Claude Code iteratively:

1. Describe what you want to benchmark
2. Ask Claude Code to generate initial benchmark code
3. Run the benchmark and collect results
4. Share results with Claude Code for interpretation
5. Modify benchmarks based on feedback
6. Repeat until you have reliable data

This loop accelerates learning JMH while producing accurate benchmarks.

## Analyzing Benchmark Results

### Understanding the Output

JMH output includes critical metrics. Here's a sample output line:

```
Benchmark                              Mode  Cnt    Score    Error  Units
StringBuilderBenchmark.appendSingle  thrpt   10  1234.567 ± 18.234  ops/ms
```

Key columns include:

- **Mode**: Throughput (ops/time), Average time (time/op), Sample time, or Single shot
- **Cnt**: Number of benchmark invocations
- **Score**: The measured value (operations per millisecond in throughput mode)
- **Error**: 99.9% confidence interval
- **Units**: Measurement units (ops/ms for throughput)

### Common Interpretation Mistakes

Claude Code can help you avoid these errors:

1. **Ignoring error margins**: A score of 100 ± 50 is meaningless; 100 ± 1 is reliable
2. **Insufficient warmup**: Always verify JIT compilation completed
3. **Comparing incompatible modes**: Don't compare throughput to average time
4. **Overlooking outliers**: Use `-tu us` for microsecond precision on fast operations

## Advanced Patterns

### Parameterized Benchmarks

Test multiple inputs with @Param:

```java
@State(Scope.Thread)
@Params({
    @Param("100"),
    @Param("1000"),
    @Param("10000")
})
public class ListBenchmark {
    @Param("1000")
    private int size;
    
    private List<String> arrayList;
    private List<String> linkedList;
    
    @Setup
    public void setup() {
        arrayList = new ArrayList<>(size);
        linkedList = new LinkedList<>();
        for (int i = 0; i < size; i++) {
            arrayList.add("item" + i);
            linkedList.add("item" + i);
        }
    }
    
    @Benchmark
    public void arrayListGet(Blackhole bh) {
        for (int i = 0; i < size; i++) {
            bh.consume(arrayList.get(i));
        }
    }
}
```

### Blackhole for Result Consumption

Use Blackhole to prevent dead code elimination:

```java
@Benchmark
public void measureSomething(Blackhole bh) {
    String result = expensiveOperation();
    bh.consume(result); // Prevents JIT from eliminating the call
}
```

## Best Practices

1. **Start simple**: Benchmark one thing at a time
2. **Run adequate iterations**: Use at least 5 measurements with 2+ forks
3. **Use @State correctly**: Understand Thread vs Benchmark scope
4. **Avoid benchmarking infrastructure**: Focus on your code, not framework overhead
5. **Verify warmup**: Check JIT compilation logs with `-XX:+PrintCompilation`
6. **Profile before optimizing**: Use async-profiler with JMH to find hotspots

## Conclusion

Claude Code transforms JMH benchmarking from a technical challenge into an accessible workflow. By leveraging Claude Code's understanding of Java performance and JMH internals, you can quickly create accurate benchmarks, interpret results correctly, and make informed optimization decisions. Start with simple benchmarks, iterate with Claude Code's guidance, and build confidence in your performance measurements.

Remember: benchmark results are only as good as the benchmark code. Use Claude Code to verify your benchmarks are correct before acting on the numbers.
{% endraw %}
Built by theluckystrike — More at [zovo.one](https://zovo.one)
