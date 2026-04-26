---

layout: default
title: "Claude Code Hypothesis Property Testing (2026)"
description: "Learn how to use Hypothesis for property-based testing in Python with Claude Code. Write smarter tests that catch edge cases automatically. Updated for 2026."
last_tested: "2026-04-22"
date: 2026-04-19
last_modified_at: 2026-04-19
author: "Claude Skills Guide"
permalink: /claude-code-hypothesis-property-testing-guide/
categories: [guides]
tags: [claude-code, hypothesis, property-testing, python, tdd, claude-skills]
reviewed: true
score: 7
geo_optimized: true
---


Working with hypothesis property means dealing with proper hypothesis property configuration, integration testing, and ongoing maintenance. This guide covers the exact steps for using Claude Code to handle these hypothesis property challenges after you have your basic environment configured.

Property-based testing transforms how you verify software correctness. Instead of writing dozens of example-based tests, you define properties that should hold true for any input, and let a library generate hundreds of test cases automatically. Hypothesis, Python's premier property-based testing library, does exactly this. Combined with Claude Code's coding assistance, you can build solid test suites that catch bugs you didn't even know existed.

## Understanding Property-Based Testing

Traditional example-based testing requires you to manually craft specific inputs:

```python
def test_sort_list():
 assert sorted([3, 1, 2]) == [1, 2, 3]
 assert sorted([5]) == [5]
 assert sorted([]) == []
```

Property-based testing shifts the burden to the framework. You state a property, "sorting a list should produce a sorted result", and Hypothesis generates hundreds of random inputs to verify it holds:

```python
from hypothesis import given, strategies as st

@given(st.lists(st.integers()))
def test_sort_produces_sorted_result(xs):
 sorted_xs = sorted(xs)
 assert sorted_xs == sorted(sorted_xs)
```

This simple test runs against thousands of automatically generated lists, catching edge cases like empty lists, single elements, duplicates, and massive collections that manual testing would never cover.

## Property-Based vs Example-Based Testing: When to Use Each

Both approaches have their place. Knowing when to reach for each one prevents over-engineering while ensuring you get coverage where it matters most.

| Dimension | Example-Based | Property-Based |
|---|---|---|
| Best for | Known edge cases, regression prevention | Discovering unknown edge cases |
| Test maintenance | Higher. must update examples manually | Lower. properties rarely change |
| Readability | High. intent is obvious | Moderate. requires understanding properties |
| Execution speed | Fast | Slower (many runs per test) |
| Failure messages | Immediately actionable | Requires understanding shrunk example |
| Coverage | Limited to what you imagine | Broad, systematic |
| CI run time | Predictable | Variable (can be tuned) |

A practical rule: use example-based tests for documented requirements ("given input X, return Y") and property-based tests for algorithmic correctness ("this operation should always preserve these invariants"). In most production Python codebases, a 70/30 split favoring example-based tests works well, with property tests concentrated around data transformation, validation, and serialization code.

## Setting Up Hypothesis with Claude Code

When starting a new Python project, use the tdd skill to scaffold your testing infrastructure:

```
Load the tdd skill and set up Hypothesis for my Python project.
```

The tdd skill helps configure your test environment, install dependencies, and establish testing conventions. For Hypothesis specifically, add it to your project:

```bash
pip install hypothesis
```

In your test file, import Hypothesis decorators and strategies. Claude Code can suggest appropriate strategies based on your function's input types. For instance, if you're testing a function accepting JSON-like dictionaries with specific key types, ask Claude:

```
What Hypothesis strategies would test a function accepting Dict[str, List[int]]?
```

Claude will recommend `st.dicts(st.text(), st.lists(st.integers()))` and may generate the complete test scaffold.

## Configuring Hypothesis for Your Project

Hypothesis is highly configurable. Create a `conftest.py` at your project root to set project-wide defaults:

```python
conftest.py
from hypothesis import settings, HealthCheck, Phase

Development profile: fast, good for local iteration
settings.register_profile(
 'dev',
 max_examples=50,
 suppress_health_check=[HealthCheck.too_slow],
 deadline=500, # 500ms per test
)

CI profile: thorough, catches more edge cases
settings.register_profile(
 'ci',
 max_examples=500,
 suppress_health_check=[],
 deadline=2000,
 phases=[Phase.explicit, Phase.reuse, Phase.generate, Phase.shrink],
)

Nightly profile: exhaustive
settings.register_profile(
 'nightly',
 max_examples=5000,
 deadline=None,
)

settings.load_profile('dev') # Default
```

Then in your CI pipeline, set the profile via environment variable before running pytest:

```bash
In CI
HYPOTHESIS_PROFILE=ci pytest tests/
```

This approach keeps local test runs fast while ensuring your CI pipeline runs a thorough search for failures. Ask Claude Code to generate this configuration when you describe your project's CI setup.

## The Hypothesis Database

One of Hypothesis's most powerful features is its failure database. When a failing example is found, Hypothesis saves it so future runs always replay the known failure first:

```python
from hypothesis import settings
from hypothesis.database import DirectoryBasedExampleDatabase

settings.register_profile(
 'with_db',
 database=DirectoryBasedExampleDatabase('.hypothesis/examples'),
)
```

Commit the `.hypothesis/examples` directory to version control. This way, a failure found on one developer's machine is guaranteed to be tested on every other machine and in every CI run. When a bug is fixed, delete the saved example with `hypothesis database --clear` to stop replaying it.

## Writing Effective Property Tests

The art of property-based testing lies in identifying genuine properties. Here are patterns that work well:

## Reversibility

Many operations have inverses. Sorting should be reversible only in specific ways, but encoding and decoding should be perfect inverses:

```python
@given(st.binary())
def test_base64_encode_decode_inverse(data):
 encoded = base64.b64encode(data)
 decoded = base64.b64decode(encoded)
 assert decoded == data
```

## Idempotence

Applying an operation multiple times should produce the same result as applying it once:

```python
@given(st.lists(st.integers()))
def test_deduplication_idempotent(items):
 result = list(set(items))
 assert result == list(set(result))
```

## Invariants

Certain properties should remain true regardless of input. The sum of numbers doesn't depend on their order:

```python
@given(st.lists(st.floats(allow_nan=False, allow_infinity=False)))
def test_sum_order_independent(numbers):
 assert sum(numbers) == sum(reversed(numbers))
```

## Commutativity and Associativity

Mathematical operations that should commute or associate give you powerful invariant properties:

```python
@given(st.integers(), st.integers())
def test_addition_commutative(a, b):
 assert a + b == b + a

@given(st.integers(), st.integers(), st.integers())
def test_addition_associative(a, b, c):
 assert (a + b) + c == a + (b + c)
```

These seem trivial for built-in addition, but become non-trivial when you write your own `BigDecimal`, `Money`, or `Percentage` classes that wrap numeric types.

## Oracle Testing: Comparing Two Implementations

One of the most powerful property testing patterns is comparing a fast, optimized implementation against a slow but obviously correct reference implementation:

```python
def naive_search(needle, haystack):
 """O(n*m) reference implementation. obviously correct."""
 n, m = len(needle), len(haystack)
 return [i for i in range(n - m + 1) if haystack[i:i+m] == needle]

def optimized_search(needle, haystack):
 """Your fast KMP or Boyer-Moore implementation."""
 # ... complex implementation here

@given(
 needle=st.text(min_size=1, max_size=10),
 haystack=st.text(max_size=100),
)
def test_optimized_search_matches_naive(needle, haystack):
 assert optimized_search(needle, haystack) == naive_search(needle, haystack)
```

This oracle pattern lets you confidently refactor or optimize algorithms without maintaining exhaustive example-based test suites. The reference implementation documents intent while the property test enforces correctness.

## Metamorphic Properties

Sometimes there is no oracle, but you can reason about how a function should respond to related inputs:

```python
@given(st.lists(st.integers(), min_size=1))
def test_max_element_not_affected_by_duplicating(items):
 """Duplicating all elements should not change the maximum."""
 doubled = items + items
 assert max(items) == max(doubled)

@given(st.lists(st.integers(), min_size=1), st.integers())
def test_max_with_appended_element(items, element):
 """The max of a list with one element appended is the max of both options."""
 result = max(items + [element])
 assert result == max(max(items), element)
```

## Handling Complex Data Structures

Hypothesis provides strategies for most Python types, but complex data requires custom strategies. Suppose you're testing a function that processes user profiles:

```python
@given(st.builds(
 UserProfile,
 name=st.text(min_size=1, max_size=100),
 email=st.emails(),
 age=st.integers(min_value=0, max_value=150)
))
def test_user_profile_validation(profile):
 assert profile.is_valid() or profile.errors
```

The `st.builds` strategy constructs objects directly using your existing class, saving boilerplate code.

For even more complex structures, ask Claude to help design a strategy. The pdf skill can generate documentation for your testing patterns if you need to share them with team members.

## Building Composite Strategies

The `@st.composite` decorator lets you build strategies that combine multiple simpler strategies with constraints. This is essential for testing functions that require valid relationships between their inputs:

```python
from hypothesis import given, strategies as st

@st.composite
def valid_date_range(draw):
 """Generate a start date that always precedes the end date."""
 start_year = draw(st.integers(min_value=2000, max_value=2025))
 start_month = draw(st.integers(min_value=1, max_value=12))
 start_day = draw(st.integers(min_value=1, max_value=28))

 # End date is always after start
 end_year = draw(st.integers(min_value=start_year, max_value=2030))
 end_month = draw(st.integers(min_value=1 if end_year > start_year else start_month, max_value=12))
 end_day = draw(st.integers(min_value=1, max_value=28))

 from datetime import date
 start = date(start_year, start_month, start_day)
 end = date(end_year, end_month, end_day)
 return start, end

@given(valid_date_range())
def test_date_range_duration_always_positive(date_range):
 start, end = date_range
 assert (end - start).days >= 0
```

Ask Claude Code to generate composite strategies for your domain types by describing the relationships and constraints that must hold between fields.

## Strategies for API Data

Testing HTTP API handlers often means generating realistic but random JSON bodies. Hypothesis handles this cleanly:

```python
from hypothesis import given, strategies as st
import json

valid_product_strategy = st.fixed_dictionaries({
 'name': st.text(min_size=1, max_size=255),
 'price': st.decimals(min_value='0.01', max_value='99999.99', places=2),
 'quantity': st.integers(min_value=0, max_value=10000),
 'sku': st.from_regex(r'[A-Z]{3}-[0-9]{6}', fullmatch=True),
 'tags': st.lists(st.text(min_size=1, max_size=50), max_size=10),
})

@given(valid_product_strategy)
def test_product_serialization_roundtrip(product_data):
 """Products should survive JSON serialization unchanged."""
 serialized = json.dumps(product_data)
 deserialized = json.loads(serialized)
 assert deserialized['name'] == product_data['name']
 assert deserialized['quantity'] == product_data['quantity']
 # Note: float precision issues mean we check strings for price
 assert deserialized['sku'] == product_data['sku']
```

The `st.from_regex` strategy is particularly useful for generating data that must match a format like SKUs, postal codes, phone numbers, or reference IDs.

Filtering Strategies with `assume`

Sometimes generating the right input requires filtering out invalid combinations. Use `assume` to tell Hypothesis to discard generated values that don't meet your preconditions:

```python
from hypothesis import given, assume, strategies as st

@given(st.integers(), st.integers())
def test_integer_division_properties(a, b):
 assume(b != 0) # Skip cases where b is zero
 result = a // b
 # Verify floor division invariant: b * (a // b) <= a
 assert b * result <= a
```

Use `assume` sparingly. If Hypothesis has to discard too many generated values, it will raise a `Unsatisfiable` error. When you find yourself writing complex `assume` conditions, a composite strategy is usually a better choice.

## Debugging Failing Property Tests

When Hypothesis finds a failing case, it shrinks the example to the minimal reproducible case. This "minimal failing example" appears in your test output:

```
Falsifying Example: test_sort_produces_sorted_result([0, 0, 0])
```

This is incredibly valuable. Instead of debugging with a massive 10,000-element list, you get `[0, 0, 0]`, the simplest case that breaks your property.

When this happens, ask Claude Code to analyze the failure:

```
Why does my sort test fail on [0, 0, 0]? Here's my implementation:
```

Claude will examine your code, identify the bug, and suggest a fix. This pairing, Hypothesis finding bugs and Claude explaining them, creates a powerful debugging loop.

## Reproducing Failures Deterministically

After Hypothesis shrinks a failing example, it prints a `@reproduce_failure` decorator you can add to your test to always run that exact failing case:

```python
from hypothesis import reproduce_failure

@reproduce_failure('6.92.1', b'AXicY2BkYGBgYmBiYAAAAiAA')
@given(st.lists(st.integers()))
def test_sort_produces_sorted_result(xs):
 sorted_xs = sorted(xs)
 assert sorted_xs == sorted(sorted_xs)
```

This is more reliable than copying the output value directly because it uses Hypothesis's internal binary encoding. Use this in combination with a debugger to step through the exact failing execution.

## Structuring Your Bug Report to Claude

When sharing a Hypothesis failure with Claude Code, include the full context for the fastest resolution:

```
Hypothesis found a failing case for my function. Here is everything:

Function under test:
[paste the function]

Property test:
[paste the test]

Failing example from Hypothesis:
[paste the exact Falsifying Example output]

What I expected: [describe the expected behavior]
What happened: [describe the actual behavior]

Python version: 3.12
Hypothesis version: 6.92.0
```

This structured format lets Claude immediately skip clarifying questions and jump to diagnosis. In most cases it will identify the root cause and suggest both a fix and an additional example-based regression test to prevent recurrence.

## Integrating with Test Suites

Property tests coexist with traditional tests. Add Hypothesis tests alongside example-based tests in the same file:

```python
Traditional example-based test
def test_sort_simple_list():
 assert sorted([3, 1, 2]) == [1, 2, 3]

Property-based test
@given(st.lists(st.integers()))
def test_sort_properties(xs):
 sorted_xs = sorted(xs)
 # Verify sortedness
 assert all(sorted_xs[i] <= sorted_xs[i+1] for i in range(len(sorted_xs)-1))
 # Verify contains same elements
 assert sorted(sorted_xs) == sorted(xs)
```

The tdd skill can help you balance both approaches, suggesting when property-based tests add value versus when simple examples suffice.

## Organizing Property Tests in a Large Codebase

As your property test suite grows, a clear file organization prevents duplication and makes it easier to run subsets of tests:

```
tests/
 unit/
 test_user.py # Example-based unit tests
 test_order.py
 properties/
 test_serialization.py # Property tests for all serialization
 test_validation.py # Property tests for all validation logic
 test_algorithms.py # Property tests for algorithms
 strategies/
 __init__.py
 domain.py # Reusable composite strategies
 api.py # API payload strategies
```

Keep your shared strategies in a dedicated `strategies/` module. This prevents strategy duplication and gives Claude Code a focused target when you ask it to generate new strategies for your domain.

```python
tests/properties/strategies/domain.py
from hypothesis import strategies as st
from myapp.models import User, Order, Product

@st.composite
def valid_user(draw):
 return User(
 name=draw(st.text(min_size=1, max_size=100).filter(str.isprintable)),
 email=draw(st.emails()),
 age=draw(st.integers(min_value=18, max_value=120)),
 )

@st.composite
def valid_order(draw, user=None):
 if user is None:
 user = draw(valid_user())
 items = draw(st.lists(
 st.fixed_dictionaries({
 'product_id': st.uuids().map(str),
 'quantity': st.integers(min_value=1, max_value=100),
 }),
 min_size=1,
 max_size=20,
 ))
 return Order(user=user, items=items)
```

## Advanced Hypothesis Features

Once comfortable with basics, explore Hypothesis' advanced capabilities:

- Settings: Customize deadline, max_examples, and database storage for known failures
- Phase: Control discovery, shrinking, and termination phases
- Composite strategies: Build reusable custom strategies for domain-specific types
- Stateful testing: Automatically generate sequences of method calls to test object protocols

For stateful testing specifically, Hypothesis can generate complex interaction sequences:

```python
from hypothesis.stateful import RuleBasedStateMachine, rule

class StackMachine(RuleBasedStateMachine):
 def __init__(self):
 self.stack = []

 @rule(value=st.integers())
 def push(self, value):
 self.stack.append(value)

 @rule()
 def pop(self):
 if self.stack:
 self.stack.pop()
```

This tests your stack implementation against thousands of random push-pop sequences, ensuring internal consistency.

## Stateful Testing for REST APIs

Stateful testing is particularly powerful for testing REST APIs where the order of operations matters. Here is a more complete stateful test for a simple task management API:

```python
from hypothesis.stateful import RuleBasedStateMachine, rule, invariant, initialize
from hypothesis import strategies as st
import requests

class TaskAPIStateMachine(RuleBasedStateMachine):
 """
 Tests a task management API by generating random sequences of
 create, update, complete, and delete operations.
 """

 def __init__(self):
 super().__init__()
 self.tasks = {} # Local model: id -> task dict
 self.base_url = 'http://localhost:8000/api'

 @initialize()
 def clear_database(self):
 requests.delete(f'{self.base_url}/tasks')

 @rule(
 title=st.text(min_size=1, max_size=200),
 priority=st.sampled_from(['low', 'medium', 'high']),
 )
 def create_task(self, title, priority):
 resp = requests.post(f'{self.base_url}/tasks', json={
 'title': title,
 'priority': priority,
 })
 assert resp.status_code == 201
 task = resp.json()
 self.tasks[task['id']] = task

 @rule(data=st.data())
 def complete_task(self, data):
 if not self.tasks:
 return
 task_id = data.draw(st.sampled_from(list(self.tasks.keys())))
 resp = requests.patch(f'{self.base_url}/tasks/{task_id}', json={
 'completed': True
 })
 assert resp.status_code == 200
 self.tasks[task_id]['completed'] = True

 @rule(data=st.data())
 def delete_task(self, data):
 if not self.tasks:
 return
 task_id = data.draw(st.sampled_from(list(self.tasks.keys())))
 resp = requests.delete(f'{self.base_url}/tasks/{task_id}')
 assert resp.status_code == 204
 del self.tasks[task_id]

 @invariant()
 def count_matches_model(self):
 """The API task count should always match our local model."""
 resp = requests.get(f'{self.base_url}/tasks')
 assert resp.status_code == 200
 assert len(resp.json()) == len(self.tasks)

TestTaskAPI = TaskAPIStateMachine.TestCase
```

The `@invariant()` decorator runs after every step, continuously asserting that your system's state matches the expected model. This is how Hypothesis finds race conditions, state machine bugs, and inconsistencies that no manually crafted test sequence would ever hit.

## Hypothesis and pytest-xdist Parallelism

Running Hypothesis tests in parallel with pytest-xdist speeds up large suites significantly. However, the failure database can cause conflicts when multiple workers write to it simultaneously. Configure it safely:

```python
conftest.py
import pytest
from hypothesis import settings
from hypothesis.database import InMemoryExampleDatabase

@pytest.fixture(scope='session', autouse=True)
def hypothesis_parallel_config(tmp_path_factory):
 """Use per-worker in-memory databases when running in parallel."""
 if hasattr(pytest, 'xdist_worker_id'):
 settings.register_profile(
 'parallel',
 database=InMemoryExampleDatabase(),
 max_examples=100,
 )
 settings.load_profile('parallel')
```

Ask Claude to generate the full parallel testing configuration once you describe your CI environment and the number of workers you run.

## Targeting: Guiding Hypothesis Toward Interesting Inputs

The `target` function lets you guide Hypothesis to search for inputs that maximize a metric. This is useful for performance testing or finding worst-case inputs:

```python
from hypothesis import given, target, strategies as st

@given(st.lists(st.integers(), min_size=1, max_size=1000))
def test_sort_performance_does_not_degrade(items):
 import time
 start = time.perf_counter()
 sorted(items)
 elapsed = time.perf_counter() - start

 # Guide Hypothesis to try larger and more adversarial lists
 target(elapsed * 1000, label='sort_time_ms')

 assert elapsed < 0.1 # 100ms budget
```

Hypothesis will try to maximize `elapsed` across its search, effectively performing automated adversarial testing of your algorithm's performance characteristics.

## Common Property Testing Mistakes and How to Fix Them

Understanding common mistakes helps you write more effective property tests from the start. Claude Code is good at identifying these patterns in code review:

| Mistake | Example | Fix |
|---|---|---|
| Testing too-specific examples | `assume(len(xs) == 3)` filters away 99% of cases | Use composite strategy instead |
| Duplicate logic in test and code | Reimplementing the function inside the test | Use oracle or invariant instead |
| Overly weak property | `assert len(result) >= 0` always passes | Strengthen. assert length equals input length |
| No `allow_nan=False` on floats | Float comparison failures from NaN != NaN | Always set `allow_nan=False, allow_infinity=False` unless you specifically test NaN handling |
| Missing `min_size` on required collections | Empty list breaks function precondition | Set `min_size=1` when function requires non-empty input |
| Testing internal implementation | Asserting on private attribute values | Test observable behavior only |

## Getting Started Today

Property-based testing with Hypothesis catches bugs that example-based testing misses. Combined with Claude Code's assistance, explaining failures, suggesting strategies, and generating test scaffolds, you have a powerful combination for building reliable Python software.

Start small: pick one function with complex input handling and write a property test. Let Hypothesis generate cases. Watch as it finds edge cases you never considered. Then expand to more functions as you develop intuition for what properties matter.

The tdd skill provides a starting framework. The pdf skill can export test documentation. The supermemory skill helps retain insights about what properties matter in your specific codebase.

When you bring Hypothesis into your workflow alongside Claude Code, the feedback loop becomes remarkably tight. Hypothesis surfaces a counterexample. Claude explains why it fails and suggests a fix. You patch the code and re-run. Within minutes you have both a corrected implementation and a permanent regression guard that will catch any future regression at the exact boundary that once caused a failure. That combination, automated exploration plus AI-powered explanation, produces more solid software than either tool delivers alone.

Your tests become more comprehensive with less manual effort. That's the power of property-based testing, and Claude Code makes it accessible.

---

---




**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

*Last verified: April 2026. If this approach no longer works, check [Mendeley Chrome Extension — Honest Review 2026](/mendeley-chrome-extension-review/) for updated steps.*

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-hypothesis-property-testing-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>



**Know your costs →** Use our [Claude Code Cost Calculator](/calculator/) to estimate your monthly spend.

## Related Topics

- Test-Driven Development with Claude Code
- Python Testing Best Practices
- [Claude Skills for Developers](/best-claude-skills-for-developers-2026/)

Related Reading

- [Claude Code Skills for Backend: Node.js and Python](/claude-code-skills-for-backend-developers-node-and-python/)
- [Claude Code Contract Testing with Pact Guide](/claude-code-contract-testing-pact-guide/)
- [Claude Code Cypress Component Testing Guide](/claude-code-cypress-component-testing-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)



