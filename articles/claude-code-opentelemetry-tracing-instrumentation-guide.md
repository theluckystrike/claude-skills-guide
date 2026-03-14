---


layout: default
title: "Claude Code OpenTelemetry Tracing Instrumentation Guide"
description: "Learn how to implement OpenTelemetry tracing instrumentation in your applications using Claude Code. Practical examples for Python, Node.js, and Go."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-opentelemetry-tracing-instrumentation-guide/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
---


# Claude Code OpenTelemetry Tracing Instrumentation Guide

Distributed tracing has become essential for understanding how requests flow through modern microservices architectures. OpenTelemetry provides vendor-neutral instrumentation that works with various backends. This guide shows you how to implement OpenTelemetry tracing in your applications using Claude Code, with practical examples you can apply immediately.

## Understanding OpenTelemetry Tracing Fundamentals

OpenTelemetry traces follow a hierarchical model where each operation becomes a span. A trace represents an end-to-end request, while spans represent individual operations within that request. Spans contain timing information, attributes, events, and optionally links to other spans.

The key components you need to understand are:

- **Tracer**: Creates spans and manages trace context
- **Span**: Represents a single operation with timing and metadata
- **SpanContext**: Contains trace and span IDs for propagation
- **Attributes**: Key-value pairs providing context about operations

Claude Code can help you scaffold OpenTelemetry instrumentation across multiple services. The tdd skill proves particularly useful when building instrumentation layers, as you can write tests that verify spans contain the expected attributes before implementing the actual tracing code.

## Setting Up OpenTelemetry in Python

Install the required packages first:

```bash
pip install opentelemetry-api opentelemetry-sdk opentelemetry-exporter-otlp
```

Create a tracing initialization module that your entire application can import:

```python
# tracing.py
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource, SERVICE_NAME

def setup_tracing(service_name: str, otlp_endpoint: str = "http://localhost:4317"):
    """Initialize OpenTelemetry tracing for a service."""
    resource = Resource.create({SERVICE_NAME: service_name})
    provider = TracerProvider(resource=resource)
    
    otlp_exporter = OTLPSpanExporter(endpoint=otlp_endpoint)
    processor = BatchSpanProcessor(otlp_exporter)
    provider.add_span_processor(processor)
    
    trace.set_tracer_provider(provider)
    return trace.get_tracer(__name__)
```

Ask Claude Code to generate decorator functions that automatically trace your functions:

```python
from functools import wraps
from typing import Callable, Any

def traced_function(tracer: Any, attributes: dict = None):
    """Decorator to automatically instrument functions."""
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        def wrapper(*args, **kwargs) -> Any:
            with tracer.start_as_current_span(
                f"{func.__module__}.{func.__name__}",
                attributes=attributes or {}
            ) as span:
                try:
                    result = func(*args, **kwargs)
                    span.set_attribute("result", "success")
                    return result
                except Exception as e:
                    span.set_attribute("error", str(e))
                    span.record_exception(e)
                    raise
        return wrapper
    return decorator
```

Apply this decorator to your service functions:

```python
# Order service example
tracer = setup_tracing("order-service")

@traced_function(tracer, {"service": "order", "layer": "business"})
def process_order(order_id: str, user_id: str):
    # Your business logic here
    pass

@traced_function(tracer, {"service": "order", "layer": "data"})
def get_order_from_db(order_id: str):
    # Database access here
    pass
```

## Instrumenting Node.js Services

For JavaScript and TypeScript applications, initialize tracing differently:

```javascript
// tracing.js
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-grpc');

const sdk = new NodeSDK({
  serviceName: 'user-service',
  traceExporter: new OTLPTraceExporter({
    url: 'http://localhost:4317',
  }),
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();
```

Create wrapper functions for Express middleware that automatically captures request context:

```javascript
// middleware/tracing.js
const { trace } = require('@opentelemetry/api');

function tracingMiddleware(req, res, next) {
  const tracer = trace.getTracer('express-server');
  
  const span = tracer.startSpan(`${req.method} ${req.route?.path || req.path}`, {
    kind: 1, // SpanKind.SERVER
    attributes: {
      'http.method': req.method,
      'http.url': req.url,
      'http.target': req.route?.path || req.path,
      'http.host': req.headers.host,
      'user-agent': req.headers['user-agent'],
    },
  });
  
  res.on('finish', () => {
    span.setAttribute('http.status_code', res.statusCode);
    span.end();
  });
  
  next();
}

module.exports = { tracingMiddleware };
```

Apply the middleware in your Express app:

```javascript
const express = require('express');
const { tracingMiddleware } = require('./middleware/tracing');

const app = express();

app.use(tracingMiddleware);
app.get('/api/users/:id', (req, res) => {
  // Your route handler
});
```

## Propagating Trace Context Across Services

When requests flow between microservices, trace context must propagate so you get a complete view. OpenTelemetry provides several propagation formats including W3C Trace Context, B3, and Jaeger.

For Python services using HTTP calls:

```python
from opentelemetry import context
from opentelemetry.propagate import inject, extract
from opentelemetry.trace.propagation.tracecontext import TraceContextTextMapPropagator

propagator = TraceContextTextMapPropagator()

def call_downstream_service(url: str, headers: dict):
    """Call another service while propagating trace context."""
    # Extract context from incoming request headers
    ctx = extract(headers)
    
    with tracer.start_as_current_span("http.client", context=ctx) as span:
        # Inject context into outgoing request headers
        outgoing_headers = {}
        inject(outgoing_headers)
        
        # Make the HTTP call with propagated context
        response = requests.get(url, headers=outgoing_headers)
        
        span.set_attribute("http.status_code", response.status_code)
        return response.json()
```

## Instrumenting Database Operations

Database calls often represent the largest portion of request latency. Instrument your database layer to see query performance:

```python
# database/tracing.py
import opentelemetry.instrumentation.sqlite3 as otel_sqlite3

# After creating your SQLite connection
conn = sqlite3.connect("app.db")
otel_sqlite3.instrument_connection(conn, "app-database")

# For SQLAlchemy with PostgreSQL
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor

engine = create_engine("postgresql://localhost/mydb")
SQLAlchemyInstrumentor().instrument_engine(engine)
```

These auto-instrumentation packages automatically create spans for each query, capturing query text, duration, and connection pool statistics.

## Adding Custom Attributes for Better Insights

Custom attributes transform generic spans into meaningful business metrics. Add user, tenant, and feature context:

```python
def enrich_span_with_user_context(span, user_id: str, tenant_id: str):
    """Add business context to the current span."""
    span.set_attribute("user.id", user_id)
    span.set_attribute("user.tenant_id", tenant_id)
    span.set_attribute("user.authenticated", True)

def enrich_span_with_business_context(span, order_value: float, currency: str):
    """Add transaction-specific attributes."""
    span.set_attribute("transaction.value", order_value)
    span.set_attribute("transaction.currency", currency)
    span.set_attribute("transaction.type", "purchase")
```

Call these functions within your traced operations to add meaningful context for debugging and analysis.

## Using Claude Code Skills for Tracing Implementation

Several Claude skills accelerate OpenTelemetry adoption. The frontend-design skill helps when building observability dashboards. The pdf skill assists in generating documentation for your tracing implementation. The supermemory skill maintains context about your instrumentation decisions across Claude sessions.

For teams implementing tracing at scale, create a custom skill that encapsulates your organization's tracing patterns. Define standard attributes, span naming conventions, and export configurations that all services should follow.

## Verifying Your Instrumentation

Before deploying, verify spans appear correctly in your backend. Use the OTLP collector with Jaeger for local testing:

```yaml
# docker-compose.yml
otel-collector:
  image: otel/opentelemetry-collector-contrib
  ports:
    - "4317:4317"
    - "16686:16686"
  config: |
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
    exporters:
      jaeger:
        endpoint: jaeger:14250
      logging:
        loglevel: debug
    service:
      pipelines:
        traces:
          receivers: [otlp]
          exporters: [jaeger, logging]
```

Run your application and trigger some requests. Access the Jaeger UI at localhost:16686 to visualize traces and verify attributes appear correctly.

## Conclusion

OpenTelemetry tracing instrumentation provides visibility into how your applications operate in production. Start with basic span creation, add custom attributes relevant to your business domain, and propagate context across service boundaries. Claude Code accelerates this process by generating boilerplate code and helping you structure instrumentation that scales.

The investment in proper tracing pays dividends when debugging production issues or optimizing performance. You'll immediately see which operations contribute to latency and where errors occur across distributed systems.


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
