---

layout: default
title: "Claude Code for Courier Notification"
description: "Build automated courier notification workflows with Claude Code. Learn to create skills that handle delivery tracking, status updates, and customer alerts."
date: 2026-03-15
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-for-courier-notification-workflow-guide/
reviewed: true
score: 7
geo_optimized: true
---

Building automated courier notification systems can transform your logistics operations, reducing manual tracking while keeping customers informed in real-time. Claude Code provides a powerful framework for creating skills that handle delivery notifications, status updates, and exception handling with minimal configuration. This guide walks you through building a practical courier notification workflow from scratch.

## Understanding Courier Notification Workflows

A courier notification workflow manages the lifecycle of package delivery communications. This includes sending initial shipment confirmations, providing tracking updates, alerting customers about delivery exceptions, and confirming successful completions. Each stage requires specific data points and timing considerations that Claude Code can orchestrate effectively.

Traditional approaches often rely on rigid webhook handlers or scheduled cron jobs. Claude Code skills offer a more flexible alternative by enabling natural language interfaces for managing notifications and handling complex conditional logic without extensive custom code.

The real advantage of using Claude Code for this task is the ability to describe intent rather than prescribe implementation. Instead of writing a hundred lines of conditional webhook-processing logic, you define the stages and rules in plain language, then let Claude Code generate or refine the underlying code. This speeds up iteration, especially when carrier APIs change their status code schemas or your business adds new notification channels.

## Mapping the Delivery Lifecycle

Before writing a single line of code, map out every event that could trigger a customer notification. A typical courier workflow has at least eight distinct states:

| Event | Customer Impact | Notify? |
|---|---|---|
| Order placed | High. first touchpoint | Always |
| Label created | Low. internal only | Optional |
| Package picked up | Medium. shipment confirmed | Always |
| In transit (first scan) | Low. routine | Yes, once |
| In transit (hub scans) | Very low. noise | No |
| Out for delivery | High. action is needed | Always |
| Delivered | High. confirms completion | Always |
| Exception / delay | Critical. needs response | Always |

This table guides your filtering logic. Most carrier APIs emit a scan event for every facility the package passes through. Without filtering, a customer shipping cross-country might receive fourteen "In Transit" messages. The table above makes the right behavior explicit before code is written.

## Setting Up Your Courier Notification Skill

Every Claude Code skill begins with a skill definition file. Create a new file for your courier notification skill:

```markdown
---
name: Courier Notification Handler
description: Manages courier delivery notifications including shipment confirmation, tracking updates, and delivery completion alerts
---
```

The trigger phrase allows you to invoke this skill naturally. Once defined, you can activate it by asking Claude to handle courier notifications for specific shipments.

For a real deployment, add context about your tech stack directly in the skill definition. This prevents Claude Code from suggesting incompatible libraries:

```markdown
---
name: Courier Notification Handler
description: Manages courier delivery notifications. Stack is Python 3.11, FastAPI, PostgreSQL, and Twilio for SMS. Email via SendGrid. Carriers: FedEx, UPS, USPS.
---
```

## Core Notification Functions

The foundation of any courier notification system involves three primary functions. Each handles a distinct stage in the delivery lifecycle and requires specific data handling.

## Shipment Confirmation

When a package ships, customers expect immediate confirmation with tracking details. Your skill should extract order information and generate appropriate notifications:

```python
def send_shipment_confirmation(order_id, customer_email, tracking_number, carrier):
 shipment_data = {
 "order_id": order_id,
 "tracking_number": tracking_number,
 "carrier": carrier,
 "estimated_delivery": calculate_delivery_date(carrier),
 "tracking_url": f"https://track.{carrier}.com/{tracking_number}"
 }

 message = f"""Your order has shipped!

Order ID: {order_id}
Tracking: {tracking_number}
Carrier: {carrier}
Expected Delivery: {shipment_data['estimated_delivery']}

Track your package: {shipment_data['tracking_url']}"""

 return send_email(customer_email, "Your shipment is on its way", message)
```

One improvement worth adding immediately: include a soft unsubscribe link in every shipment confirmation. Customers who receive too many follow-up messages will unsubscribe from everything. Giving them a "delivery updates only" opt-out preserves the relationship. Store this preference alongside the tracking record.

## Status Update Processing

Tracking updates occur throughout the delivery journey. Your Claude Code skill should filter meaningful events and avoid overwhelming customers with trivial notifications:

```python
def should_notify_customer(status_code, previous_status):
 significant_events = ['OUT_FOR_DELIVERY', 'DELIVERED', 'EXCEPTION', 'DELAYED']

 if status_code in significant_events:
 return True

 if status_code == 'IN_TRANSIT' and previous_status != 'IN_TRANSIT':
 return True

 return False
```

This filtering prevents notification fatigue while ensuring customers receive genuinely important updates.

Extend this function to handle carrier-specific quirks. FedEx uses `OD` for out-for-delivery while UPS uses `I` with a sub-code. USPS has its own entirely different schema. A normalization layer avoids duplicating the filtering logic per carrier:

```python
CARRIER_STATUS_MAP = {
 "fedex": {
 "OD": "OUT_FOR_DELIVERY",
 "DL": "DELIVERED",
 "DE": "EXCEPTION",
 "IT": "IN_TRANSIT"
 },
 "ups": {
 "I": "IN_TRANSIT",
 "D": "DELIVERED",
 "X": "EXCEPTION",
 "O": "OUT_FOR_DELIVERY"
 },
 "usps": {
 "003": "DELIVERED",
 "010": "EXCEPTION",
 "033": "OUT_FOR_DELIVERY",
 "073": "IN_TRANSIT"
 }
}

def normalize_status(carrier, raw_status_code):
 carrier_map = CARRIER_STATUS_MAP.get(carrier.lower(), {})
 return carrier_map.get(raw_status_code, "UNKNOWN")
```

With normalization in place, your `should_notify_customer` function works identically for every carrier without branching.

## Exception Handling

Delivery exceptions require immediate attention. Your workflow should escalate issues appropriately:

```python
def handle_delivery_exception(tracking_number, exception_type, resolution_required):
 exception_data = {
 "tracking": tracking_number,
 "type": exception_type,
 "priority": "high" if resolution_required else "normal",
 "timestamp": current_timestamp()
 }

 if exception_type == "ADDRESS_INVALID":
 notify_customer_immediately(tracking_number, "Address verification required")
 flag_for_review(exception_data)
 elif exception_type == "DAMAGED":
 initiate_claims_process(exception_data)
 notify_customer_immediately(tracking_number, "Package damage reported")
 elif exception_type == "WEATHER_DELAY":
 schedule_delayed_notification(tracking_number, hours=24)
```

Weather delays deserve a different treatment than address problems. The customer cannot resolve a weather delay, so immediate action language would be misleading and anxious. Scheduling a single follow-up 24 hours later respects the customer's time and keeps communication relevant.

## Building the Notification Pipeline

With core functions defined, assemble them into a cohesive pipeline that processes incoming tracking events:

```python
def process_tracking_event(event_data):
 tracking_number = event_data['tracking_number']
 carrier = event_data['carrier']
 raw_status = event_data['status']

 new_status = normalize_status(carrier, raw_status)
 previous_status = get_previous_status(tracking_number)

 customer_info = lookup_customer_by_tracking(tracking_number)

 if not should_send_notification(customer_info['id'], new_status):
 update_tracking_history(tracking_number, new_status)
 return {"result": "skipped", "reason": "preferences"}

 if should_notify_customer(new_status, previous_status):
 notification_content = build_notification(
 new_status,
 customer_info,
 tracking_number
 )

 deliver_notification(
 customer_info['preferred_channel'],
 customer_info['contact'],
 notification_content
 )

 log_notification_sent(tracking_number, new_status)

 update_tracking_history(tracking_number, new_status)
```

This pipeline balances efficiency with reliability, each notification gets logged for audit purposes, and the system maintains status history for future reference.

The return value on the preferences skip matters. Logging "skipped" events lets you audit customer preference compliance without storing personally identifiable information in your exception logs.

## Multi-Channel Notification Strategy

Modern customers expect to receive updates on their preferred channel. A complete implementation handles at least email, SMS, and push notifications, routing based on customer preference and event urgency:

```python
CHANNEL_PRIORITY = {
 "EXCEPTION": ["sms", "email", "push"],
 "OUT_FOR_DELIVERY": ["push", "sms", "email"],
 "DELIVERED": ["push", "email"],
 "IN_TRANSIT": ["email", "push"]
}

def deliver_notification(preferred_channel, contact_info, content, event_type):
 channels = CHANNEL_PRIORITY.get(event_type, ["email"])

 # Respect preference but fall back gracefully
 ordered = ([preferred_channel] +
 [c for c in channels if c != preferred_channel])

 for channel in ordered:
 handler = CHANNEL_HANDLERS.get(channel)
 if handler and contact_info.get(channel):
 result = handler(contact_info[channel], content)
 if result['status'] == 'sent':
 return result

 # All channels failed. queue for manual review
 queue_for_manual_review(contact_info, content, event_type)
 return {"status": "queued"}
```

This approach tries the customer's preferred channel first, then falls back down the priority list. For exceptions, SMS is first because it reaches customers who may not have push notifications enabled or who are away from email. For delivered confirmations, push is sufficient and creates less inbox noise.

## Integrating External Services

Real-world courier workflows connect with multiple external systems. Claude Code skills can orchestrate these integrations while maintaining clean separation of concerns.

## Courier API Connections

Major carriers provide APIs for tracking and notifications. Your skill can standardize these connections:

```python
class CourierAdapter:
 def __init__(self, carrier_name):
 self.carrier = carrier_name
 self.api = self._initialize_api(carrier_name)

 def get_tracking_status(self, tracking_number):
 response = self.api.tracking.get(tracking_number)
 return self._normalize_status(response)

 def schedule_notification(self, tracking_number, event, callback_url):
 return self.api.webhooks.subscribe(
 tracking_number=tracking_number,
 events=[event],
 callback=callback_url
 )
```

This adapter pattern allows your notification system to work uniformly across multiple carriers without code duplication.

When multiple carriers are involved, register your webhook callback once per carrier rather than per shipment. Most carrier APIs support wildcard subscriptions for verified merchant accounts. This reduces webhook registration overhead from thousands of calls per day to a single setup operation.

## Webhook Reliability

Carrier webhooks are not guaranteed to deliver in order, or at all. Build idempotency into your pipeline:

```python
def process_webhook(payload, delivery_id):
 # Idempotency check
 if already_processed(delivery_id):
 return {"result": "duplicate", "delivery_id": delivery_id}

 mark_as_processing(delivery_id)

 try:
 result = process_tracking_event(payload)
 mark_as_complete(delivery_id)
 return result
 except Exception as e:
 mark_as_failed(delivery_id, str(e))
 raise
```

Store the delivery ID (provided by the carrier in the webhook headers) in a processing log. Duplicate deliveries are common when carriers retry webhooks after network timeouts, and processing them twice can result in customers receiving the same notification message multiple times.

## Best Practices for Courier Notification Skills

Implementing effective courier notifications requires balancing multiple concerns. Follow these principles for reliable results.

## Respect Customer Preferences

Always honor notification frequency settings and channel preferences. Store these preferences per customer and check them before sending any communication:

```python
def should_send_notification(customer_id, notification_type):
 preferences = get_customer_preferences(customer_id)

 if not preferences['notifications_enabled']:
 return False

 if notification_type in preferences['disabled_types']:
 return False

 quiet_hours = preferences.get('quiet_hours', {})
 if is_within_quiet_hours(now(), quiet_hours):
 return False

 return True
```

Quiet hours are a frequently overlooked feature. A customer in California may have placed an order that shipped from an East Coast warehouse. Without quiet hours, they receive an "Out for Delivery" SMS at 5:30 AM Pacific time when the carrier scans the package at a local hub. This destroys goodwill that good shipping service had built.

## Handle Rate Limiting Gracefully

High-volume notification systems frequently encounter rate limits from email providers and carrier APIs. Implement exponential backoff:

```python
async def send_with_retry(notification, max_retries=3):
 for attempt in range(max_retries):
 try:
 return await notification.send()
 except RateLimitException as e:
 wait_time = (2 attempt) * e.retry_after
 await asyncio.sleep(wait_time)

 queue_for_later_delivery(notification)
 return {"status": "queued"}
```

Pair this with a dead-letter queue for notifications that exhaust their retries. Shipped confirmations and delivery exceptions are high-priority; a failed "In Transit" notification can be dropped if it ages past 12 hours, since a subsequent scan update will supersede it anyway. Build this TTL logic into the queue processing so stale low-priority notifications self-expire.

## Test Thoroughly Before Production

Claude Code skills benefit from comprehensive testing. Create test cases covering normal flows and edge cases:

```python
def test_notification_workflow():
 # Test shipment confirmation
 result = send_shipment_confirmation("ORD-123", "customer@test.com", "TRK456", "FastShip")
 assert result['status'] == 'sent'

 # Test duplicate filtering
 send_shipment_confirmation("ORD-123", "customer@test.com", "TRK456", "FastShip")
 assert notification_count() == 1 # Should not duplicate

 # Test exception handling
 exception_result = handle_delivery_exception("TRK456", "ADDRESS_INVALID", True)
 assert exception_result['priority'] == 'high'

 # Test quiet hours
 with freeze_time("2026-03-21 03:00:00"): # 3 AM
 result = should_send_notification("CUST-789", "IN_TRANSIT")
 assert result == False # Quiet hours block

 # Test carrier normalization
 assert normalize_status("fedex", "OD") == "OUT_FOR_DELIVERY"
 assert normalize_status("ups", "D") == "DELIVERED"
 assert normalize_status("usps", "003") == "DELIVERED"
```

Add load tests before high-volume periods like Black Friday and the winter holiday shipping rush. These periods can produce 20x normal webhook volume. A pipeline that handles 1,000 events per minute in testing may collapse at 20,000.

## Operational Monitoring

Once deployed, monitor three key metrics continuously:

Notification delivery rate. The percentage of triggered notifications that reach the customer. Drops below 95% signal a provider issue or rate limit problem.

End-to-end latency. Time from carrier webhook receipt to customer notification sent. Customers expect under 60 seconds for "Out for Delivery" alerts.

Exception escalation rate. What percentage of exceptions get resolved without manual intervention. High manual review rates suggest your automated resolution flows are too conservative.

Set up a simple dashboard query to surface these:

```sql
SELECT
 DATE_TRUNC('hour', sent_at) as hour,
 event_type,
 COUNT(*) as triggered,
 SUM(CASE WHEN status = 'sent' THEN 1 ELSE 0 END) as delivered,
 AVG(EXTRACT(EPOCH FROM (sent_at - triggered_at))) as avg_latency_seconds
FROM notification_log
WHERE sent_at > NOW() - INTERVAL '24 hours'
GROUP BY 1, 2
ORDER BY 1 DESC, 2;
```

## Actionable Next Steps

Start building your courier notification skill by first identifying the specific events that require customer communication in your existing system. Map these to the functions outlined above, then gradually implement each component.

Begin with the normalization layer if you work with multiple carriers. Without it, every carrier integration becomes its own special case. Add the filtering logic next, because wrong notification frequency causes opt-outs that take months to recover from. Build the multi-channel routing last, after the core pipeline is stable.

Remember to prioritize customer preferences from the beginning, retrofitting notification controls is significantly more complex than building them into the initial design. With Claude Code handling the orchestration logic, you can focus on crafting the perfect customer experience at each delivery stage.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-courier-notification-workflow-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for FluxCD Notification Workflow Guide](/claude-code-for-fluxcd-notification-workflow-guide/)
- [AI Assisted Architecture Design Workflow Guide](/ai-assisted-architecture-design-workflow-guide/)
- [AI Assisted Code Review Workflow Best Practices](/ai-assisted-code-review-workflow-best-practices/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


