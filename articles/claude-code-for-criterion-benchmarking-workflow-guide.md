---

layout: default
title: "Claude Code for Criterion Rust Benchmarks (2026)"
description: "Run Criterion benchmarks in Rust with Claude Code for statistical analysis, regression detection, and performance comparison. Workflow with examples."
date: 2026-03-15
last_modified_at: 2026-04-17
last_tested: "2026-04-21"
author: "Claude Skills Guide"
permalink: /claude-code-for-criterion-benchmarking-workflow-guide/
categories: [guides]
tags: [claude-code, claude-skills]
score: 7
reviewed: true
render_with_liquid: false
geo_optimized: true
---

{% raw %}
Claude Code for Criterion Benchmarking Workflow Guide

Benchmarking is essential for understanding your code's performance characteristics and identifying optimization opportunities. When working with Rust projects, the Criterion framework provides a solid solution for statistical benchmarking, and Claude Code can significantly streamline your benchmarking workflow. This guide walks you through building an efficient benchmarking pipeline using both tools together.

The combination is more powerful than either tool alone. Criterion gives you statistically rigorous measurements. Claude Code gives you the ability to interpret those measurements, generate hypothesis-driven optimizations, and automate the repetitive parts of the feedback loop. Together they let you move from "my function feels slow" to "my function is 2.3x faster and I have 95% confidence in that number" in a single focused session.

## Understanding Criterion Benchmarking

Criterion is a statistics-driven benchmarking framework for Rust that goes beyond simple timing measurements. It provides:

- Statistical analysis - Uses Welch's t-test to determine whether performance differences are statistically meaningful, not just noise
- Warmup phases - Ensures accurate measurements by warming up CPU caches and branch predictors before recording
- Plots and reports - Generates HTML reports with violin plots and regression charts in `target/criterion/`
- Regression tracking - Compares results against previous saved baselines and flags regressions automatically
- Outlier detection - Labels high and low outliers so you know when your environment was noisy

Before integrating with Claude Code, ensure you have Criterion set up in your Rust project:

```toml
Cargo.toml
[dev-dependencies]
criterion = { version = "0.5", features = ["html_reports"] }

[[bench]]
name = "my_benchmark"
harness = false
```

The `harness = false` line is required. it tells Cargo not to use the default test harness for this binary, so Criterion can own the `main` function and set up its own measurement loop.

## Setting Up Your Benchmarking Project

The first step is organizing your project for efficient benchmarking. Claude Code can help you set up the entire structure:

1. Create a benchmarks directory - Keep your benchmarks organized under `benches/`
2. Configure Criterion - Set up custom measurements and thresholds
3. Establish baseline metrics - Record initial performance data before any optimization
4. Group related benchmarks - Use `criterion_group!` to keep related measurements together in the report

Here's how to configure Criterion with custom settings and multiple benchmark groups:

```rust
// benches/my_benchmark.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId};
use std::time::Duration;

fn my_function(input: u64) -> u64 {
 (0..input).fold(0, |acc, x| acc + x)
}

fn benchmark_basic(c: &mut Criterion) {
 c.bench_function("sum_0_to_n", |b| {
 b.iter(|| my_function(black_box(1_000_000)))
 });
}

fn benchmark_scaling(c: &mut Criterion) {
 let mut group = c.benchmark_group("sum_scaling");
 // Configure the group to run longer for more accurate small measurements
 group.measurement_time(Duration::from_secs(10));

 for n in [100, 1_000, 10_000, 100_000, 1_000_000].iter() {
 group.bench_with_input(BenchmarkId::from_parameter(n), n, |b, &n| {
 b.iter(|| my_function(black_box(n)))
 });
 }
 group.finish();
}

criterion_group!(benches, benchmark_basic, benchmark_scaling);
criterion_main!(benches);
```

The `BenchmarkId` pattern is especially useful when you want to see how performance scales with input size. Criterion will plot all the data points together, making O(n) versus O(n²) behavior visually obvious in the generated report.

## Claude Code Integration Patterns

Claude Code excels at automating repetitive benchmarking tasks. Here are the key integration patterns:

## Automated Baseline Generation

Use Claude Code to generate and save baseline benchmarks before any optimization work:

```bash
Run Criterion and save baseline with a descriptive name
cargo bench --save-baseline before-optimization

Or use a timestamp for automated pipelines
BASELINE="baseline-$(date +%Y%m%d_%H%M%S)"
cargo bench --save-baseline "$BASELINE"
echo "Saved baseline: $BASELINE"
```

Claude Code can help you create scripts that automate this process and track baselines in version control:

```bash
#!/bin/bash
scripts/run_benchmark.sh
set -euo pipefail

BRANCH=$(git rev-parse --abbrev-ref HEAD)
COMMIT=$(git rev-parse --short HEAD)
BASELINE="baseline-${BRANCH}-${COMMIT}"

echo "Running benchmarks for ${BRANCH} @ ${COMMIT}"
cargo bench --save-baseline "$BASELINE"
echo "Baseline saved: $BASELINE"
echo "View report: open target/criterion/report/index.html"
```

## Regression Detection Workflow

Compare current results against baselines to detect regressions. This is where Criterion's statistical machinery earns its keep. it reports not just whether a difference exists but whether that difference is larger than measurement noise:

```bash
Compare current code against a named baseline
cargo bench --baseline before-optimization

Example output:
sum_0_to_n time: [1.2341 ms 1.2389 ms 1.2441 ms]
 change: [-15.234% -14.821% -14.391%] (p = 0.00 < 0.05)
 Performance has improved.
```

The three numbers in brackets are the lower bound, mean, and upper bound of a 95% confidence interval. When the change report shows `p = 0.00`, Criterion is confident the difference is real, not noise.

## Comparing Multiple Implementations

When you have two competing implementations and want to measure which is faster, structure your benchmark to test both in the same run:

```rust
fn benchmark_implementations(c: &mut Criterion) {
 let data: Vec<u64> = (0..10_000).collect();

 let mut group = c.benchmark_group("sum_comparison");

 group.bench_function("fold", |b| {
 b.iter(|| black_box(&data).iter().fold(0u64, |acc, x| acc + x))
 });

 group.bench_function("sum_intrinsic", |b| {
 b.iter(|| black_box(&data).iter().sum::<u64>())
 });

 group.bench_function("manual_loop", |b| {
 b.iter(|| {
 let mut total = 0u64;
 for x in black_box(&data) {
 total += x;
 }
 total
 })
 });

 group.finish();
}
```

Criterion generates a side-by-side comparison in the HTML report, showing the violin distributions overlaid. Claude Code can read the output and tell you which implementation is statistically fastest and by what margin.

## Batch Benchmarking

For comprehensive analysis, run multiple benchmarks and capture structured output:

```bash
Run all benchmarks with JSON output for further processing
cargo bench --message-format=json 2>/dev/null | \
 jq -r 'select(.type == "benchmark") | [.name, .mean.estimate] | @tsv'
```

## Practical Example: Optimizing a String Processing Function

Let's walk through a real-world optimization scenario using Claude Code and Criterion.

## Initial Benchmark

First, create a benchmark for the function you want to optimize:

```rust
// benches/string_processing.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn process_strings_original(items: &[String]) -> Vec<String> {
 items.iter()
 .map(|s| s.to_uppercase())
 .map(|s| s.trim().to_string())
 .collect()
}

fn benchmark_string_processing(c: &mut Criterion) {
 let data: Vec<String> = (0..1000)
 .map(|i| format!(" item {} ", i))
 .collect();

 c.bench_function("process_1000_strings_original", |b| {
 b.iter(|| process_strings_original(black_box(&data)))
 });
}

criterion_group!(benches, benchmark_string_processing);
criterion_main!(benches);
```

Run and save the baseline:

```bash
cargo bench --bench string_processing --save-baseline before
```

## Analysis and Optimization

Claude Code can analyze the benchmark results and suggest improvements. The original implementation has two obvious problems: it allocates an intermediate `String` per element for the `to_uppercase()` call, then allocates another `String` for the `trim().to_string()` call. That is two allocations per element, 2000 total for this input.

Here's an optimized version that reduces to one allocation per element:

```rust
fn process_strings_optimized(items: &[String]) -> Vec<String> {
 let mut result = Vec::with_capacity(items.len());

 for item in items {
 // trim() returns a &str (no allocation)
 // to_uppercase() on &str produces a String (one allocation per element)
 result.push(item.trim().to_uppercase());
 }

 result
}
```

The key insight: `trim()` returns `&str` pointing into the original `String` (zero allocation), and `to_uppercase()` on a `&str` produces one `String` directly. By swapping the order of operations from `to_uppercase().trim()` to `trim().to_uppercase()`, we eliminate one allocation per element.

For ASCII-only data, you can go further:

```rust
fn process_strings_ascii(items: &[String]) -> Vec<String> {
 let mut result = Vec::with_capacity(items.len());

 for item in items {
 let trimmed = item.trim();
 let mut s = String::with_capacity(trimmed.len());
 s.push_str(trimmed);
 s.make_ascii_uppercase(); // in-place, no extra allocation
 result.push(s);
 }

 result
}
```

This version allocates exactly once per element and does the uppercasing in place. For Unicode data `make_ascii_uppercase` is unsafe to use (it silently ignores non-ASCII), so only apply this in contexts where your inputs are guaranteed ASCII.

## Verify Improvements

Run the comparison to verify your optimizations actually helped:

```bash
cargo bench --bench string_processing --baseline before
```

A representative result:

```
process_1000_strings_original
 time: [312.45 µs 313.89 µs 315.41 µs]
process_1000_strings_optimized
 time: [198.12 µs 199.07 µs 200.14 µs]
 change: [-36.7% -36.5% -36.3%] (p = 0.00 < 0.05)
 Performance has improved.
```

A 36% improvement, statistically confirmed, from one optimization session.

## Best Practices for Benchmarking Workflows

## Consistent Environment

Environment noise is the enemy of reproducible benchmarks. These steps reduce it significantly:

- Run benchmarks on a quiet system with no background CPU load
- Disable CPU frequency scaling: `sudo cpupower frequency-set -g performance` on Linux
- Use fixed seeds for random data generation. nondeterministic inputs make results incomparable across runs
- Pin the benchmark process to a specific CPU core with `taskset` on Linux to avoid scheduler interference
- Disable Turbo Boost on Intel systems if you want consistent measurements across long runs

## Statistical Significance

Criterion's statistics are only as good as your sample size. For noisy benchmarks:

```rust
fn benchmark_with_more_samples(c: &mut Criterion) {
 let mut group = c.benchmark_group("careful_measurement");
 group.sample_size(200); // default is 100
 group.measurement_time(Duration::from_secs(20));
 group.warm_up_time(Duration::from_secs(5));

 group.bench_function("my_function", |b| {
 b.iter(|| expensive_operation(black_box(input)))
 });
 group.finish();
}
```

Never interpret a result without looking at the confidence interval width. A measurement of `[198 µs 200 µs 202 µs]` is tight and trustworthy. A measurement of `[150 µs 200 µs 280 µs]` suggests your system was noisy during measurement and the result is unreliable.

## Automation with Claude Code

Claude Code can help automate the entire pipeline. A configuration file that captures your thresholds and comparison targets gives Claude Code the context it needs to flag regressions automatically:

```yaml
.claude/benchmark.yml
benchmark:
 baseline_dir: "benches/baselines"
 compare_targets:
 - "baseline-main"
 - "baseline-2026-01"
 thresholds:
 regression_warning: 0.10 # 10% regression triggers warning
 regression_error: 0.25 # 25% regression triggers error
 environment:
 cpu_governor: "performance"
 sample_size: 150
```

When you ask Claude Code to run your benchmark suite, it reads this config, applies the appropriate Criterion flags, and reports only the benchmarks that crossed your thresholds. rather than making you scan hundreds of lines of output manually.

## Continuous Integration

Integrate benchmarking into your CI pipeline to catch regressions before they merge. Note that CI machines typically have noisy environments, so the primary goal is catching large regressions (>10%), not measuring sub-millisecond differences:

```yaml
.github/workflows/benchmark.yml
name: Benchmark

on:
 pull_request:
 branches: [main]

jobs:
 benchmark:
 runs-on: ubuntu-latest
 steps:
 - uses: actions/checkout@v4
 with:
 fetch-depth: 0

 - name: Install Rust
 uses: dtolnay/rust-toolchain@stable

 - name: Cache cargo registry
 uses: actions/cache@v3
 with:
 path: ~/.cargo/registry
 key: ${{ runner.os }}-cargo-${{ hashFiles('/Cargo.lock') }}

 - name: Restore baseline from main
 run: |
 git stash
 cargo bench --save-baseline main-baseline
 git stash pop

 - name: Run benchmarks and compare
 run: cargo bench --baseline main-baseline 2>&1 | tee benchmark-results.txt

 - name: Upload benchmark results
 uses: actions/upload-artifact@v3
 with:
 name: benchmark-results
 path: |
 benchmark-results.txt
 target/criterion/
```

## Interpreting Criterion Reports

The HTML report Criterion generates at `target/criterion/report/index.html` is worth spending time with. Each benchmark has:

- Mean and confidence interval - The primary number to watch
- Violin plot - Shows the distribution of individual sample times; bimodal distributions suggest context switching or cache effects
- Regression plot - Plots sample time against iteration count; a flat slope means Criterion is measuring the function itself, not startup costs

Claude Code can help you interpret anomalies. A violin plot with two distinct clusters usually means your function has two code paths with very different performance, or that the OS scheduler was interrupting your measurements. Either way it is worth investigating before trusting the mean.

## Conclusion

Combining Claude Code with Criterion creates a powerful benchmarking workflow. Claude Code handles the automation, organization, and analysis, while Criterion provides accurate, statistical measurements. Start with simple baselines, automate your comparison workflows, and progressively add sophistication as your benchmarking needs grow.

Remember: good benchmarks require careful setup and consistent execution. The `black_box` function is not optional. without it, the compiler may optimize away the computation entirely and you will be measuring nothing. Use Claude Code to automate the repetitive parts, but always verify results manually when making critical optimization decisions. A 36% improvement that only shows up in synthetic benchmarks is less valuable than a 10% improvement measured in production-representative workloads.

The workflow in this guide gives you a foundation that scales from a single-function optimization session to a project-wide performance regression detection pipeline.

---

*This guide helps developers build efficient benchmarking workflows using Claude Code and Criterion.*

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-criterion-benchmarking-workflow-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [AI Assisted Architecture Design Workflow Guide](/ai-assisted-architecture-design-workflow-guide/)
- [AI Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/)
- [Benchmarking Claude Code Skills Performance Guide](/benchmarking-claude-code-skills-performance-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)
{% endraw %}


