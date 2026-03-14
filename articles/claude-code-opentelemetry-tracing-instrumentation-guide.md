---
layout: default
title: "Claude Code OpenTelemetry Tracing Instrumentation Guide"
description: "Master OpenTelemetry tracing instrumentation with Claude Code. Learn how to set up distributed tracing, create custom spans, and monitor your."
date: 2026-03-14
categories: [guides]
tags: [claude-code, opentelemetry, tracing, instrumentation, observability, monitoring]
author: theluckystrike
reviewed: false
score: 0
permalink: /claude-code-opentelemetry-tracing-instrumentation-guide/
---

# Claude Code OpenTelemetry Tracing Instrumentation Guide

OpenTelemetry has become the industry standard for observability, providing vendor-neutral APIs, SDKs, and tools for collecting distributed traces, metrics, and logs. When combined with Claude Code's AI assistance, you can rapidly implement comprehensive tracing in your applications without deep prior knowledge of OpenTelemetry internals.

This guide walks you through setting up OpenTelemetry tracing instrumentation using Claude Code as your coding partner.

## Why OpenTelemetry Matters for Modern Applications

Modern applications often consist of multiple microservices communicating across networks. When something goes wrong, pinpointing the exact location of a failure can feel like finding a needle in a haystack. OpenTelemetry solves this by providing distributed tracing—a way to follow a request as it travels through your entire system.

Traditional debugging often involves adding log statements, restarting services, and hoping you captured enough information. With OpenTelemetry, every request gets a unique trace ID that follows it through all services, making it trivial to see exactly where time is being spent and where errors occur.

Claude Code accelerates your OpenTelemetry journey by generating boilerplate code, explaining complex concepts, and helping you debug tracing issues when they arise.

## Setting Up OpenTelemetry with Claude Code

### Initial Project Configuration

Start by describing your tracing needs to Claude. Be specific about your language, framework, and what you want to achieve:

```
/opentelemetry Set up OpenTelemetry tracing for a Node.js Express API. I want to trace HTTP requests, database queries, and external API calls.
```

Claude will generate the initial setup, typically including package installation and basic configuration. For Node.js, this might look like:

```bash
npm install @opentelemetry/api @opentelemetry/sdk-node @opentelemetry/auto-instrumentations-node @opentelemetry/exporter-trace-otlp-http
```

### Creating the Tracing Setup File

Claude can generate a proper tracing initialization file tailored to your needs:

```javascript
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');
const { Resource } = require('@opentelemetry/resources');
const { ATTR_SERVICE_NAME, ATTR_SERVICE_VERSION } = require('@opentelemetry/semantic-conventions');

const sdk = new NodeSDK({
  resource: new Resource({
    [ATTR_SERVICE_NAME]: 'your-service-name',
    [ATTR_SERVICE_VERSION]: '1.0.0',
  }),
  traceExporter: new OTLPTraceExporter(),
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start()
  .then(() => console.log('Tracing initialized'))
  .catch((error) => console.error('Error initializing tracing', error));

process.on('SIGTERM', () => {
  sdk.shutdown()
    .then(() => console.log('Tracing terminated'))
    .catch((error) => console.error('Error terminating tracing', error));
});
```

Notice that this code uses standard JavaScript, not Liquid template syntax, so no raw tag is needed.

## Manual Instrumentation with Custom Spans

While auto-instrumentation covers many common frameworks, you'll often need to create custom spans for business logic that frameworks don't automatically capture.

### Creating Spans for Business Logic

Describe your business operations to Claude and ask for custom span creation:

```
/opentelemetry Create spans for our order processing workflow that includes validation, inventory check, payment processing, and notification sending.
```

Claude will generate code like this:

```javascript
const { trace, SpanKind, StatusCode } = require('@opentelemetry/api');
const { meter } = require('@opentelemetry/api');

const tracer = trace.getTracer('order-service');
const orderMeter = meter.getMeter('order-service');

async function processOrder(orderData) {
  return tracer.startActiveSpan('processOrder', async (span) => {
    try {
      // Add order ID to trace for correlation
      span.setAttribute('order.id', orderData.id);
      span.setAttribute('order.total', orderData.total);

      // Validation span
      const validationSpan = tracer.startSpan('validateOrder', {
        kind: SpanKind.INTERNAL,
        parent: span,
      });
      const isValid = await validateOrder(orderData);
      validationSpan.setAttribute('validation.result', isValid);
      validationSpan.end();
      
      if (!isValid) {
        span.setStatus({ code: StatusCode.ERROR, message: 'Order validation failed' });
        span.end();
        return { success: false, error: 'Validation failed' };
      }

      // Inventory check span
      const inventorySpan = tracer.startSpan('checkInventory', {
        kind: SpanKind.CLIENT,
        parent: span,
      });
      const inventoryResult = await checkInventory(orderData.items);
      inventorySpan.setAttribute('inventory.available', inventoryResult.available);
      inventorySpan.end();

      if (!inventoryResult.available) {
        span.setStatus({ code: StatusCode.ERROR, message: 'Insufficient inventory' });
        span.end();
        return { success: false, error: 'Insufficient inventory' };
      }

      // Payment processing span
      const paymentSpan = tracer.startSpan('processPayment', {
        kind: SpanKind.CLIENT,
        parent: span,
      });
      const paymentResult = await processPayment(orderData.payment);
      paymentSpan.setAttribute('payment.id', paymentResult.transactionId);
      paymentSpan.setAttribute('payment.status', paymentResult.status);
      paymentSpan.end();

      // Notification span
      const notificationSpan = tracer.startSpan('sendNotification', {
        kind: SpanKind.PRODUCER,
        parent: span,
      });
      await sendNotification(orderData.customerId, 'order_confirmed');
      notificationSpan.end();

      span.setAttribute('order.status', 'completed');
      span.end();
      return { success: true, orderId: orderData.id };
      
    } catch (error) {
      span.setStatus({ 
        code: StatusCode.ERROR, 
        message: error.message 
      });
      span.recordException(error);
      span.end();
      throw error;
    }
  });
}
```

### Adding Custom Attributes

Make your traces more useful by adding relevant attributes:

```javascript
function addUserContext(span, user) {
  span.setAttribute('user.id', user.id);
  span.setAttribute('user.email', user.email);
  span.setAttribute('user.tier', user.subscriptionTier);
}

function addRequestContext(span, request) {
  span.setAttribute('http.method', request.method);
  span.setAttribute('http.url', request.url);
  span.setAttribute('http.route', request.route?.path || 'unknown');
  span.setAttribute('http.status_code', response.statusCode);
}
```

## Tracing Database Operations

Database queries are often the biggest source of latency. OpenTelemetry auto-instrumentation captures many queries automatically, but custom spans provide more context.

### Tracing with Detailed Query Information

```
/opentelemetry Add detailed tracing for PostgreSQL queries including query text, execution time, and row counts.
```

```javascript
const { trace, SpanKind } = require('@opentelemetry/api');

const dbTracer = trace.getTracer('database');

async function tracedQuery(pool, text, params) {
  const span = dbTracer.startSpan('database.query', {
    kind: SpanKind.CLIENT,
    attributes: {
      'db.system': 'postgresql',
      'db.statement': text,
      'db.operation': text.split(' ')[0].toUpperCase(),
    },
  });

  const startTime = Date.now();
  try {
    const result = await pool.query(text, params);
    span.setAttribute('db.row_count', result.rowCount);
    span.setAttribute('db.execution_time_ms', Date.now() - startTime);
    return result;
  } catch (error) {
    span.setStatus({
      code: StatusCode.ERROR,
      message: error.message,
    });
    span.recordException(error);
    throw error;
  } finally {
    span.end();
  }
}
```

## Context Propagation

When requests span multiple services, trace context must propagate through headers.

### W3C Trace Context

The W3C Trace Context standard is now the default:

```javascript
const { propagation, ROOT_CONTEXT } = require('@opentelemetry/api');

// Extract trace context from incoming request
function extractTraceContext(req) {
  const carrier = {
    traceparent: req.headers['traceparent'],
    tracestate: req.headers['tracestate'],
  };
  return propagation.extract(ROOT_CONTEXT, carrier);
}

// Add trace context to outgoing requests
function injectTraceContext(outgoingOptions) {
  propagation.inject(
    trace.getActiveSpan().spanContext(),
    outgoingOptions.headers || (outgoingOptions.headers = {})
  );
  return outgoingOptions;
}

// Usage with HTTP client
async function callDownstreamService(url, data) {
  const span = trace.getActiveSpan();
  const outgoing = injectTraceContext({
    method: 'POST',
    url,
    headers: {},
  });
  
  return fetch(url, {
    ...outgoing,
    body: JSON.stringify(data),
  });
}
```

### Custom Propagators

For systems using custom headers:

```javascript
const { TextMapPropagator, W3C_TRACE_CONTEXT_PARENT_HEADER } = require('@opentelemetry/api');

class CustomTracePropagator extends TextMapPropagator {
  inject(context, carrier) {
    const spanContext = context.getValue(SPAN_KEY);
    if (!spanContext) return;
    
    carrier['x-trace-id'] = spanContext.traceId;
    carrier['x-span-id'] = spanContext.spanId;
  }

  extract(context, carrier) {
    const traceId = carrier['x-trace-id'];
    const spanId = carrier['x-span-id'];
    
    if (!traceId || !spanId) return context;
    
    const spanContext = new SpanContext({
      traceId: TraceId.fromHex(traceId),
      spanId: SpanId.fromHex(spanId),
      traceFlags: TraceFlags.SAMPLED,
    });
    
    return context.setValue(SPAN_KEY, spanContext);
  }
}
```

## Sampling Strategies

High-throughput applications may need sampling to control trace volume.

### Common Sampling Strategies

```javascript
const { AlwaysSample, AlwaysOffSampler, ParentBasedSampler } = require('@opentelemetry/sdk-trace-base');

// Always sample for development
const devSampler = AlwaysSample;

// Production: only sample 10% of traces
const prodSampler = new ParentBasedSampler({
  root: new TraceIdRatioBased(0.1),
});

// Sample based on specific criteria
const customSampler = new ParentBasedSampler({
  root: new TraceIdRatioBased(0.1),
  onRootSpanStart: (rootSpan) => {
    // Always sample API requests
    if (rootSpan.attributes['http.url']?.includes('/api/')) {
      return AlwaysSample;
    }
    // Skip health checks
    if (rootSpan.attributes['http.url']?.includes('/health')) {
      return AlwaysOffSampler;
    }
    return new TraceIdRatioBased(0.1);
  },
});
```

## Integration with Claude Code for Debugging

When traces reveal performance issues, Claude can help analyze and resolve them.

### Analyzing Trace Data

Share your trace data with Claude for analysis:

```
/opentelemetry Analyze this trace data showing 3 second latency in our checkout flow. The spans show: validateOrder (50ms), checkInventory (2800ms), processPayment (100ms), sendNotification (50ms). What's causing the bottleneck?
```

Claude will identify that checkInventory is the bottleneck and suggest optimizations like caching inventory data or using asynchronous processing.

### Troubleshooting Common Issues

Common problems Claude can help debug:

- **Missing traces**: Check if sampling is too aggressive or if span export is failing
- **Incomplete context**: Verify propagator configuration across services
- **Performance overhead**: Reduce attribute cardinality, adjust sampling rate
- **Export failures**: Verify OTLP endpoint connectivity and authentication

## Best Practices

### Naming Conventions

Use consistent, meaningful span names:

```javascript
// Good: descriptive, consistent naming
'processOrder'
'database.query'
'http.post:/api/checkout'

// Bad: dynamic values in span names
`processOrder-${orderId}`  // Creates too many unique span names
`query-${Math.random()}`    // Absolutely forbidden
```

### Attribute Guidelines

```javascript
// Use semantic conventions for standard attributes
const { SemanticAttributes } = require('@opentelemetry/semantic-conventions');

span.setAttribute(SemanticAttributes.DB_SYSTEM, 'redis');
span.setAttribute(SemanticAttributes.DB_STATEMENT, 'GET user:123');
span.setAttribute(SemanticAttributes.HTTP_METHOD, 'GET');
span.setAttribute(SemanticAttributes.HTTP_URL, 'https://api.example.com/users');

// Avoid high-cardinality values as attributes
// Bad: span.setAttribute('user.email', user.email); // Too many unique values
// Good: span.setAttribute('user.id', user.id);
```

### Performance Considerations

```javascript
// Don't create spans in tight loops
// Instead, batch operations

async function processItems(items) {
  const span = tracer.startSpan('processItems');
  try {
    const batchSpan = tracer.startSpan('batchProcessing', { parent: span });
    // Process all items in batch
    await processBatch(items);
    batchSpan.end();
  } finally {
    span.end();
  }
}

// Use span.addEvent for logging-like information
span.addEvent('Processing item', {
  'item.id': itemId,
  'item.status': 'started',
});
```

## Conclusion

OpenTelemetry tracing provides visibility into your application's behavior across service boundaries. With Claude Code as your partner, you can rapidly implement comprehensive instrumentation without becoming an OpenTelemetry expert. The key is starting simple with auto-instrumentation, then adding custom spans for your specific business logic.

Remember to iterate: start with basic setup, add meaningful attributes, implement proper context propagation, and refine with sampling strategies as your observability needs grow.

## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Best Claude Skills for Developers in 2026](/claude-skills-guide/best-claude-skills-for-developers-2026/)
- [Claude Skills Guides Hub](/claude-skills-guide/guides-hub/)

