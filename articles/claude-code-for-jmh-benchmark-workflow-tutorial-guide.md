---

layout: default
title: "Claude Code for JMH Benchmark Workflow Tutorial Guide"
description: "Learn how to use Claude Code to streamline your JMH benchmark workflow—from setting up benchmarks to analyzing results and optimizing performance."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /claude-code-for-jmh-benchmark-workflow-tutorial-guide/
categories: [guides]
tags: [claude-code, claude-skills]
reviewed: true
score: 8
---


{% raw %}
# Claude Code for JMH Benchmark Workflow Tutorial Guide

Java Microbenchmark Harness (JMH) is the standard tool for benchmarking Java code, but setting up and running benchmarks effectively requires understanding its intricacies. This guide shows you how to use Claude Code to streamline your entire JMH workflow—from project setup to result analysis.

## Why Use Claude Code with JMH?

Claude Code brings several advantages to your benchmark workflow:

- **Scaffold JMH projects quickly** without memorizing Maven configurations
- **Generate benchmark templates** for common patterns
- **Explain benchmark results** and identify optimization opportunities
- **Debug benchmark issues** like dead code elimination and JIT optimizations
- **Automate repetitive benchmarking tasks**

## Setting Up Your JMH Project

The first step is creating a proper Maven project with JMH dependencies. Instead of manually configuring your pom.xml, ask Claude Code to generate the right configuration:

```
Create a Maven pom.xml for JMH benchmarking with Java 17. Include the JMH dependencies, proper compiler settings, and JAR plugin configuration for creating an executable benchmark JAR.
```

Claude will generate a pom.xml similar to this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>jmh-benchmarks</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>jar</packaging>

    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <jmh.version>1.37</jmh.version>
        <jar.plugin.version>3.3.0</jar.plugin.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.openjdk.jmh</groupId>
            <artifactId>jmh-core</artifactId>
            <version>${jmh.version}</version>
        </dependency>
        <dependency>
            <groupId>org.openjdk.jmh</groupId>
            <artifactId>jmh-generator-annprocess</artifactId>
            <version>${jmh.version}</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-jar-plugin</artifactId>
                <version>${jar.plugin.version}</version>
                <configuration>
                    <archive>
                        <manifest>
                            <mainClass>org.openjdk.jmh.Main</mainClass>
                        </manifest>
                    </archive>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

## Writing Your First Benchmark

Creating effective JMH benchmarks requires understanding annotations and proper benchmark structure. Here's how Claude Code can help you write benchmarks correctly:

```
Write a JMH benchmark for comparing ArrayList vs LinkedList performance for random access operations. Include proper Warmup and Measurement annotations, and use Blackhole for consuming results.
```

Claude will generate a well-structured benchmark:

```java
package com.example.benchmarks;

import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.infrastructure.Blackhole;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Random;

@State(Scope.Thread)
@OutputTimeUnit(java.util.concurrent.TimeUnit.MICROSECONDS)
public class ListAccessBenchmark {

    private List<Integer> arrayList;
    private List<Integer> linkedList;
    private Random random;
    private int[] accessIndices;

    @Setup
    public void setup() {
        int size = 10000;
        arrayList = new ArrayList<>(size);
        linkedList = new LinkedList<>();
        random = new Random(42);

        for (int i = 0; i < size; i++) {
            arrayList.add(i);
            linkedList.add(i);
        }

        accessIndices = new int[1000];
        for (int i = 0; i < accessIndices.length; i++) {
            accessIndices[i] = random.nextInt(size);
        }
    }

    @Benchmark
    @Warmup(iterations = 3, time = 1)
    @Measurement(iterations = 5, time = 2)
    @Fork(value = 2, warmupFork = 1)
    public void arrayListRandomAccess(Blackhole bh) {
        for (int index : accessIndices) {
            bh.consume(arrayList.get(index));
        }
    }

    @Benchmark
    @Warmup(iterations = 3, time = 1)
    @Measurement(iterations = 5, time = 2)
    @Fork(value = 2, warmupFork = 1)
    public void linkedListRandomAccess(Blackhole bh) {
        for (int index : accessIndices) {
            bh.consume(linkedList.get(index));
        }
    }

    public static void main(String[] args) throws Exception {
        Options opt = new OptionsBuilder()
                .include(ListAccessBenchmark.class.getSimpleName())
                .build();

        new Runner(opt).run();
    }
}
```

## Running and Analyzing Benchmarks

Running benchmarks is straightforward with Maven:

```bash
mvn clean package
java -jar target/jmh-benchmarks-1.0-SNAPSHOT.jar -f 1
```

The `-f 1` flag runs one fork. For production results, use `-f 3` or more.

After running, you'll get output like:

```
Benchmark                               Mode  Cnt    Score    Error  Units
ListAccessBenchmark.arrayListRandomAccess  avgt    5    0.892 ±  0.023  us/op
ListAccessBenchmark.linkedListRandomAccess avgt    5  142.341 ± 15.207  us/op
```

When you need to interpret results or debug issues, ask Claude Code:

```
Explain these JMH results and explain why LinkedList is slower for random access. Also suggest how to benchmark the add() operation for both implementations.
```

Claude will explain that ArrayList has O(1) random access while LinkedList is O(n), making it much slower for random access patterns. It will also guide you on writing additional benchmarks for add() operations.

## Avoiding Common JMH Pitfalls

Claude Code helps you avoid several common benchmark mistakes:

### 1. Dead Code Elimination

Always consume results via Blackhole or return values. Without this, the JIT compiler may optimize away your entire benchmark:

```java
// Wrong - will be optimized away
@Benchmark
public void badBenchmark() {
    int sum = 0;
    for (int i = 0; i < 1000; i++) {
        sum += i;
    }
}

// Correct - results consumed
@Benchmark
public void goodBenchmark(Blackhole bh) {
    int sum = 0;
    for (int i = 0; i < 1000; i++) {
        sum += i;
    }
    bh.consume(sum);
}
```

### 2. Improper Warmup

JMH needs warmup iterations to trigger JIT compilation. Claude can configure appropriate settings:

```
Add proper warmup and measurement configuration to benchmark JSON parsing. Use at least 3 warmup iterations and 5 measurement iterations with 2 forks.
```

### 3. Benchmarking the Wrong Thing

Sometimes you want to test a specific operation, not the entire method. Use `@BenchmarkMode(Mode.SingleShotTime)` for measuring single operations or isolate the specific code path.

## Advanced Tips for Claude-Assisted Benchmarking

- **Profile while benchmarking**: Ask Claude to help add `-prof gc` or `-prof perf` to understand memory allocation and CPU behavior
- **Compare implementations**: Use `@Param` annotation to test multiple implementations in one benchmark run
- **Generate flame graphs**: For deep analysis, combine JMH with async-profiler and ask Claude for integration steps
- **Automate regression testing**: Create scripts that fail if performance degrades beyond a threshold

## Conclusion

Claude Code significantly accelerates your JMH workflow by generating correct configurations, writing well-structured benchmarks, and helping interpret results. By using Claude's assistance, you can focus on what matters: writing meaningful benchmarks and optimizing your Java code's performance.

Start by setting up a basic JMH project, write your first benchmark with Claude's help, and gradually explore advanced features like profilers and parameterization. The combination of Claude Code and JMH makes performance optimization accessible to every Java developer.
{% endraw %}
