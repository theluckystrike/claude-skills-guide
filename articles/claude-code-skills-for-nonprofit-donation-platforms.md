---
layout: default
title: "Claude Code Skills for Nonprofit Donation Platforms (2026)"
description: "Claude Code Skills for Nonprofit Donation Platforms. Practical guide with working examples for developers. Includes code examples and fixes."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [use-cases]
tags: [claude-code, claude-skills, nonprofit, donations, automation]
author: "Claude Skills Guide"
reviewed: true
score: 7
permalink: /claude-code-skills-for-nonprofit-donation-platforms/
geo_optimized: true
last_tested: "2026-04-22"
---

# Claude Code Skills for Nonprofit Donation Platforms

Building a nonprofit donation platform requires handling sensitive financial data, generating tax receipts, managing donor relationships, and ensuring PCI compliance. Claude Code skills accelerate these tasks by providing structured workflows for common nonprofit platform patterns. This guide covers the most useful skills for donation platform development. For more industry-specific automation patterns, see the [use cases hub](/use-cases-hub/).

## Understanding the Skill Model

Claude skills are instruction files loaded from `~/.claude/skills/` when you invoke them with slash commands. They do not execute code. they guide Claude to produce better code for your specific domain. For nonprofit donation platforms, this means getting Stripe-ready implementations, proper receipt generation, and donor data handling patterns from the start. See the [skill .md format specification](/claude-skill-md-format-complete-specification-guide/) for writing these instruction files correctly.

A skill file for nonprofit donation work typically looks like this:

```markdown
/stripe-integration skill
Context
Nonprofit 501(c)(3) platform. Stripe is the payment processor.
Recurring donations use Stripe Subscriptions, not PaymentIntents.
Platform collects optional donor-covered fees (tip model).

Rules
- Always include idempotency keys on PaymentIntent creation
- Metadata must include donor_id, designation, and campaign_id
- Webhook signatures must be verified before processing any event
- Amounts are always stored and transmitted in cents (integer)
```

When you load this skill and ask Claude to write payment code, the output reflects those constraints automatically. Without it, you get generic Stripe code that is correct but not tuned to your platform's requirements.

/stripe-integration: Payment Processing Foundation

The stripe-integration skill helps you set up donation payment flows correctly. For nonprofit platforms, you need to handle one-time donations, recurring subscriptions, and donor-covered fees.

```javascript
// Using the skill's guidance to create a donation intent
import Stripe from 'stripe';
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export async function createDonationIntent(amount, donorEmail, isRecurring) {
 const paymentIntent = await stripe.paymentIntents.create({
 amount: amount, // amount in cents
 currency: 'usd',
 metadata: {
 donor_email: donorEmail,
 donation_type: isRecurring ? 'recurring' : 'one-time',
 platform_fee: Math.round(amount * 0.029 + 30), // Stripe fees
 },
 automatic_payment_methods: { enabled: true },
 });

 return paymentIntent.client_secret;
}
```

This skill also covers Stripe Webhook handling for donation confirmations, failed payment recovery, and refund processing. critical for maintaining donor trust.

## One-Time vs. Recurring Donations: What Changes

One-time and recurring donations use different Stripe objects, and the skill helps Claude keep them straight:

| Scenario | Stripe Object | Key Consideration |
|---|---|---|
| One-time gift | `PaymentIntent` | Idempotency key prevents double charges |
| Monthly recurring | `Subscription` + `Customer` | Must handle `invoice.payment_failed` |
| Annual recurring | `Subscription` with `interval: year` | Reminder emails 30 days before renewal |
| Donor covers fees | Fee amount added to `PaymentIntent` | Disclose this clearly in the UI |
| Tribute gift | `PaymentIntent` with tribute metadata | Notification email to honoree required |

For recurring donors, the skill generates the full Customer + Subscription setup:

```javascript
export async function createRecurringDonor(donorEmail, amount, interval = 'month') {
 // Create or retrieve a Stripe customer
 const existing = await stripe.customers.list({ email: donorEmail, limit: 1 });
 const customer = existing.data.length > 0
 ? existing.data[0]
 : await stripe.customers.create({ email: donorEmail });

 // Create a price for this recurring amount
 const price = await stripe.prices.create({
 unit_amount: amount,
 currency: 'usd',
 recurring: { interval },
 product_data: { name: 'Monthly Donation' },
 });

 // Subscribe the donor
 const subscription = await stripe.subscriptions.create({
 customer: customer.id,
 items: [{ price: price.id }],
 metadata: {
 donor_email: donorEmail,
 donation_type: 'recurring',
 },
 payment_behavior: 'default_incomplete',
 expand: ['latest_invoice.payment_intent'],
 });

 return {
 subscriptionId: subscription.id,
 clientSecret: subscription.latest_invoice.payment_intent.client_secret,
 };
}
```

The `payment_behavior: 'default_incomplete'` pattern ensures the subscription only activates after the first payment confirms, preventing ghost subscribers in your donor database.

/pdf: Tax Receipt Generation

Every nonprofit donation platform needs to generate tax receipts. The pdf skill produces properly formatted 501(c)(3) donation receipts with all required IRS information.

```python
Receipt generation with PDF skill guidance
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

def generate_donation_receipt(donor_name, amount, date, organization_ein):
 receipt_number = f"DON-{date.strftime('%Y%m%d')}-{uuid4().hex[:6]}"

 c = canvas.Canvas(f"receipts/{receipt_number}.pdf", pagesize=letter)
 c.setFont("Helvetica-Bold", 16)
 c.drawString(50, 750, "DONATION RECEIPT")

 c.setFont("Helvetica", 12)
 c.drawString(50, 720, f"Receipt Number: {receipt_number}")
 c.drawString(50, 700, f"Date: {date.strftime('%B %d, %Y')}")
 c.drawString(50, 680, f"Donor: {donor_name}")
 c.drawString(50, 660, f"Donation Amount: ${amount:.2f}")
 c.drawString(50, 640, f"Organization EIN: {organization_ein}")

 c.drawString(50, 600, "This organization is a 501(c)(3) tax-exempt organization.")
 c.drawString(50, 580, "No goods or services were provided in exchange for this contribution.")

 c.save()
 return receipt_number
```

The skill ensures your receipts include: organization legal name, EIN, donation date, amount, statement of goods/services provided (or lack thereof), and good-faith estimate of value.

## IRS Requirements: What Must Be on a 501(c)(3) Receipt

The IRS has specific requirements for donation acknowledgment letters. Missing any of these fields can invalidate the donor's deduction claim:

| Field | Required | Notes |
|---|---|---|
| Organization legal name | Yes | Must match IRS filing exactly |
| EIN (Employer ID Number) | Strongly recommended | Not legally required but donors expect it |
| Donation date | Yes | Date of contribution, not date of receipt |
| Amount | Yes | Must be exact dollar amount |
| Cash or non-cash | Yes | "Cash" includes checks and credit card |
| Goods/services statement | Yes | "No goods or services were provided" if none |
| Good-faith value estimate | Yes if goods provided | e.g., gala dinner = $75 value |
| Signature | No | But professional presentation builds trust |

## Year-End Tax Summary Generation

For recurring donors, you need an annual summary that aggregates all gifts. The pdf skill handles this pattern too:

```python
def generate_year_end_summary(donor_id, year, db_session):
 """Generate a year-end tax summary for a recurring donor."""
 donations = db_session.query(Donation).filter(
 Donation.donor_id == donor_id,
 extract('year', Donation.created_at) == year,
 Donation.status == 'completed'
 ).order_by(Donation.created_at).all()

 if not donations:
 return None

 total = sum(d.amount for d in donations)
 donor = donations[0].donor

 summary_number = f"SUMM-{year}-{donor_id[:6]}"
 c = canvas.Canvas(f"summaries/{summary_number}.pdf", pagesize=letter)

 c.setFont("Helvetica-Bold", 16)
 c.drawString(50, 750, f"{year} Donation Summary")

 c.setFont("Helvetica", 12)
 c.drawString(50, 720, f"Donor: {donor.full_name}")
 c.drawString(50, 700, f"Total Donated in {year}: ${total / 100:.2f}")
 c.drawString(50, 680, f"Number of Gifts: {len(donations)}")

 # Individual gift table
 y = 640
 c.setFont("Helvetica-Bold", 10)
 c.drawString(50, y, "Date")
 c.drawString(200, y, "Amount")
 c.drawString(350, y, "Receipt #")
 y -= 20

 c.setFont("Helvetica", 10)
 for d in donations:
 c.drawString(50, y, d.created_at.strftime('%m/%d/%Y'))
 c.drawString(200, y, f"${d.amount / 100:.2f}")
 c.drawString(350, y, d.receipt_number)
 y -= 18

 c.setFont("Helvetica", 10)
 c.drawString(50, 100, "This organization is a 501(c)(3) tax-exempt nonprofit.")
 c.drawString(50, 85, "No goods or services were provided in exchange for these contributions.")

 c.save()
 return summary_number
```

Send these summaries in January each year. Donors use them when filing their taxes, and sending them proactively improves donor retention.

/security: Donor Data Protection

Nonprofit platforms handle sensitive donor information. The security skill generates implementations following OWASP guidelines and data protection best practices.

Key patterns from this skill include:

```javascript
// Encrypted donor data storage
import { encrypt, decrypt } from './crypto-utils';

export async function storeDonorInfo(donorData) {
 // PII fields that must be encrypted
 const piiFields = ['email', 'phone', 'address'];
 const encryptedData = { ...donorData };

 for (const field of piiFields) {
 if (donorData[field]) {
 encryptedData[field] = await encrypt(donorData[field]);
 }
 }

 // Store in database with encrypted PII
 return db.donors.create({
 ...encryptedData,
 pii_encrypted: true,
 created_at: new Date(),
 });
}
```

This skill also covers GDPR compliance for international donors, data retention policies, and secure logging practices that avoid exposing donor information. For a deeper look at credential and secret protection, see the [secret scanning guide](/claude-code-secret-scanning-prevent-credential-leaks-guide/).

## PCI DSS Compliance: What Nonprofits Must Know

Even though Stripe handles card data, your platform still falls under PCI DSS scope. The security skill helps Claude produce code that meets the relevant requirements:

| PCI Requirement | What It Means for Your Code |
|---|---|
| Never store raw card numbers | Stripe tokens only. no raw PAN in your DB |
| HTTPS everywhere | Enforce TLS 1.2+ on all donation endpoints |
| Access logging | Log all access to donor records with user ID |
| Minimal data retention | Delete or anonymize donor PII after retention period |
| Separate test and production | Never use live Stripe keys in dev/staging |

A practical audit log implementation that the security skill generates:

```javascript
export async function auditLogDonorAccess(userId, donorId, action, metadata = {}) {
 await db.audit_logs.create({
 user_id: userId,
 donor_id: donorId,
 action, // 'view', 'update', 'export', 'delete'
 ip_address: metadata.ip,
 user_agent: metadata.userAgent,
 timestamp: new Date(),
 // Never log the actual PII values. only the action and who took it
 });
}
```

Attach this to every endpoint that reads or modifies donor records. When a data breach investigation occurs. and for any platform that handles money, it eventually does. this log is what protects you.

## GDPR for International Donors

If your nonprofit accepts donations from donors in the EU, GDPR applies. The security skill generates a deletion workflow:

```javascript
export async function handleDonorDeletionRequest(donorId) {
 // 1. Anonymize PII but keep financial records for tax compliance
 await db.donors.update(donorId, {
 email: `deleted_${donorId}@anon.invalid`,
 first_name: 'Deleted',
 last_name: 'Donor',
 phone: null,
 address: null,
 pii_deleted: true,
 pii_deleted_at: new Date(),
 });

 // 2. Remove from marketing lists
 await emailService.unsubscribeAll(donorId);

 // 3. Notify payment processor
 const donor = await db.donors.findById(donorId);
 if (donor.stripe_customer_id) {
 await stripe.customers.del(donor.stripe_customer_id);
 }

 // 4. Retain donation records for IRS/audit purposes (7 years)
 // Financial records are exempt from GDPR erasure
 await db.audit_logs.create({
 action: 'gdpr_erasure',
 donor_id: donorId,
 timestamp: new Date(),
 });
}
```

Financial records are exempt from GDPR's right to erasure because tax law requires retention. The skill knows this distinction and generates code that handles it correctly.

/api-design: Donor Management Endpoints

The api-design skill helps you build clean REST or GraphQL endpoints for donor management. Nonprofit platforms need specific endpoints for:

```python
FastAPI example from api-design skill guidance
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

class DonationCreate(BaseModel):
 amount: int
 donor_id: str
 designation: str # restricted fund, general fund, etc.

@app.post("/api/v1/donations")
async def create_donation(donation: DonationCreate):
 # Verify donor exists and is authorized
 donor = await get_donor(donation.donor_id)
 if not donor:
 raise HTTPException(status_code=404, detail="Donor not found")

 # Process donation through payment gateway
 result = await process_payment(donation.amount, donor.email)

 # Record donation with designation
 record = await db.donations.create({
 ...donation.model_dump(),
 transaction_id: result.id,
 status: result.status,
 })

 return record
```

The skill ensures consistent error handling, proper HTTP status codes, and documentation generation for your donor management API.

## Complete Nonprofit API Surface

A well-designed nonprofit platform needs a consistent set of endpoints. The api-design skill helps Claude produce these with correct HTTP semantics:

```python
Donations
POST /api/v1/donations # Create donation intent
GET /api/v1/donations/{id} # Get single donation
GET /api/v1/donations?donor_id=&year= # List donations with filters

Donors
POST /api/v1/donors # Create donor profile
GET /api/v1/donors/{id} # Get donor (PII-protected)
PATCH /api/v1/donors/{id} # Update donor info
DELETE /api/v1/donors/{id} # GDPR erasure

Receipts
POST /api/v1/receipts # Generate receipt for donation
GET /api/v1/receipts/{id} # Download receipt PDF
GET /api/v1/receipts/annual/{donor_id}/{year} # Year-end summary

Subscriptions
POST /api/v1/subscriptions # Create recurring donation
GET /api/v1/subscriptions/{id} # Subscription status
DELETE /api/v1/subscriptions/{id} # Cancel recurring donation
```

Each endpoint should return consistent error shapes. The api-design skill enforces this:

```python
class APIError(BaseModel):
 error: str # machine-readable code: "donor_not_found"
 message: str # human-readable: "The donor ID you provided does not exist."
 request_id: str # for log correlation

@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
 return JSONResponse(
 status_code=exc.status_code,
 content=APIError(
 error=exc.detail.get('code', 'unknown_error'),
 message=exc.detail.get('message', str(exc.detail)),
 request_id=request.state.request_id,
 ).model_dump()
 )
```

Consistent error shapes let your frontend display helpful messages rather than crashing on unexpected response formats.

/email-templates: Donor Communication

The email-templates skill generates transactional emails for donation confirmations, recurring donation alerts, and year-end tax summary generation. These are required for donor retention and IRS compliance.

```javascript
// Donation confirmation email from email-templates skill
export function buildDonationConfirmation(donation, donor) {
 return {
 to: donor.email,
 subject: `Thank you for your ${formatCurrency(donation.amount)} donation`,
 template: 'donation-confirmation',
 context: {
 donor_name: donor.first_name,
 amount: formatCurrency(donation.amount),
 date: donation.created_at.toLocaleDateString(),
 receipt_link: `https://platform.org/receipts/${donation.receipt_number}`,
 organization_name: 'Your Nonprofit Name',
 tax_deduction_notice: 'Your donation is tax-deductible to the fullest extent allowed by law.',
 }
 };
}
```

## The Full Donor Communication Lifecycle

Donor communication is not just a confirmation email. Each event in the donation lifecycle needs a corresponding template:

| Event | Email Type | Key Content |
|---|---|---|
| First-time donation | Confirmation + welcome | Receipt link, mission statement, what gift funds |
| Recurring donation created | Subscription confirmation | Schedule, amount, cancellation link |
| Recurring payment processed | Monthly receipt | Receipt link, impact update |
| Recurring payment failed | Recovery alert | Update payment method link (urgent tone) |
| Subscription cancelled | Cancellation confirm + re-engagement | Thank you, option to reinstate |
| Year-end | Tax summary | Summary PDF, total given, full receipt list |
| Lapsed donor (90 days) | Re-engagement | Impact story, easy one-click re-donate |

The email-templates skill generates all of these. Here is the failed payment recovery email pattern, which is critical for revenue retention:

```javascript
export function buildFailedPaymentAlert(subscription, donor, paymentMethod) {
 const updateUrl = `https://platform.org/account/payment?token=${generateSecureToken(donor.id)}`;

 return {
 to: donor.email,
 subject: 'Action needed: Your recurring donation could not be processed',
 template: 'payment-failed',
 context: {
 donor_name: donor.first_name,
 amount: formatCurrency(subscription.amount),
 failed_date: new Date().toLocaleDateString(),
 card_last_four: paymentMethod.last4,
 update_payment_url: updateUrl,
 // This link expires in 7 days for security
 link_expiry: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toLocaleDateString(),
 }
 };
}
```

Send this email immediately on failure, then again at 3 days and 7 days. Most platforms recover 40-60% of failed recurring donations through this sequence.

/webhook: Payment Event Handling

The webhook skill handles the complex event flows from payment processors. For recurring donations, you need to handle:

```javascript
// Stripe webhook handler for donation events
export async function handleStripeWebhook(payload, signature) {
 const event = stripe.webhooks.constructEvent(
 payload,
 signature,
 process.env.STRIPE_WEBHOOK_SECRET
 );

 switch (event.type) {
 case 'payment_intent.succeeded':
 await fulfillDonation(event.data.object);
 break;
 case 'payment_intent.payment_failed':
 await handleFailedDonation(event.data.object);
 break;
 case 'customer.subscription.created':
 await activateRecurringDonation(event.data.object);
 break;
 case 'customer.subscription.deleted':
 await cancelRecurringDonation(event.data.object);
 break;
 case 'invoice.payment_succeeded':
 await generateRecurringReceipt(event.data.object);
 break;
 }
}
```

This skill covers idempotency (critical for payment webhooks), retry logic, and alerting for failed processing.

## Idempotency: The Most Important Webhook Concept

Stripe retries failed webhooks up to 24 hours. Without idempotency, a temporary database outage causes every donation during that period to be processed twice. The webhook skill generates idempotency-safe handlers:

```javascript
export async function fulfillDonation(paymentIntent) {
 const existingDonation = await db.donations.findOne({
 stripe_payment_intent_id: paymentIntent.id,
 status: 'completed',
 });

 // Already processed. this is a retry. Return without side effects.
 if (existingDonation) {
 console.log(`Idempotency hit: donation ${paymentIntent.id} already fulfilled`);
 return existingDonation;
 }

 // Use a database transaction to prevent race conditions
 return db.transaction(async (trx) => {
 const donation = await trx.donations.update(
 { stripe_payment_intent_id: paymentIntent.id },
 { status: 'completed', completed_at: new Date() }
 );

 await generateAndEmailReceipt(donation, trx);
 return donation;
 });
}
```

The database transaction prevents the scenario where two simultaneous webhook deliveries both pass the initial check and both generate receipts.

## Webhook Event Priority Table

Not all webhook events are equally important. Here is how to prioritize your implementation:

| Priority | Event | What Happens if Missed |
|---|---|---|
| Critical | `payment_intent.succeeded` | Donor paid but no record. major trust issue |
| Critical | `invoice.payment_failed` | Recurring donor loses active status silently |
| Critical | `customer.subscription.deleted` | Cancelled donor still treated as active |
| High | `invoice.payment_succeeded` | No monthly receipt generated |
| High | `payment_intent.payment_failed` | No retry email sent |
| Medium | `customer.updated` | Card update not reflected in UI |
| Low | `charge.refunded` | Refund not reflected in donation history |

Implement Critical events first. High and Medium can follow in the next iteration.

## Practical Integration Workflow

Combine these skills for a complete donation flow:

1. Use /api-design to define your donation endpoint
2. Use /stripe-integration to handle the payment
3. Use /webhook to process the confirmation
4. Use /pdf to generate the tax receipt
5. Use /email-templates to send confirmation
6. Use /security to encrypt stored donor data

Each skill produces production-ready code that handles the edge cases specific to nonprofit donation platforms.

## End-to-End Sequence Diagram

Here is the complete data flow for a one-time donation, showing how each skill's output connects:

```
Donor fills checkout form
 |
 v
POST /api/v1/donations ← /api-design skill
 |
 v
createDonationIntent() ← /stripe-integration skill
 → returns client_secret
 |
 v
Frontend confirms payment ← Stripe.js handles card capture
 |
 v
Stripe sends webhook ← /webhook skill
 payment_intent.succeeded
 |
 v
fulfillDonation() ← idempotency-safe handler
 |
 _____|_____
 | |
 v v
storeDonorInfo() generate_donation_receipt()
 ← /security skill ← /pdf skill
 (encrypt PII) (IRS-compliant PDF)
 |
 v
 buildDonationConfirmation()
 ← /email-templates skill
 (send receipt to donor)
```

This sequence handles the happy path. Each skill also handles the failure modes at its step: Stripe retries cover webhook failures, the PDF generator handles rendering errors, and the email service queues retries on delivery failure.

## Choosing the Right Tech Stack

When Claude generates the initial scaffold, the skill context helps it pick appropriate libraries for your stack:

| Layer | Library | Why for Nonprofits |
|---|---|---|
| Payment | `stripe` (Node) or `stripe` (Python) | Best docs, strongest webhook tooling |
| PDF receipts | `reportlab` (Python) or `puppeteer` (Node) | ReportLab for simple layouts; Puppeteer for HTML-to-PDF with branding |
| Email | `SendGrid` or `Postmark` | Postmark has better deliverability for transactional mail |
| Encryption | `cryptography` (Python) or `node:crypto` | Built-in modules preferred over third-party for PII |
| ORM | `SQLAlchemy` (Python) or `Prisma` (Node) | Transaction support is essential for idempotency |
| Background jobs | `Celery` (Python) or `BullMQ` (Node) | Receipt generation should be async |

Load all of these preferences into your skill files so Claude generates code that uses your chosen stack from the first prompt rather than requiring correction.

---

---

<div class="mastery-cta">

This site was built by 5 autonomous agents running in tmux while I was in Bali. 2,500 articles. Zero manual work. 100% quality gate pass rate.

The orchestration configs, sprint templates, and quality gates that made that possible are in the Zovo Lifetime bundle. Along with 16 CLAUDE.md templates and 80 tested prompts.

**[See how the pipeline works →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-skills&utm_campaign=claude-code-skills-for-nonprofit-donation-platforms)**

$99 once. I'm a solo dev in Da Nang. This is how I scale.

</div>

Related Reading

- [Claude Skill MD Format Complete Specification Guide](/claude-skill-md-format-complete-specification-guide/). write donation workflow skills with correct metadata and instruction structure
- [Claude Code Secret Scanning: Prevent Credential Leaks Guide](/claude-code-secret-scanning-prevent-credential-leaks-guide/). keep Stripe API keys and donor data out of your version history
- [Claude Code Skills for Insurance Claims Processing](/claude-code-skills-for-insurance-claims-processing/). similar document-handling and compliance automation patterns
- [Use Cases Hub](/use-cases-hub/). explore Claude Code skills for other regulated-industry platforms

Built by theluckystrike. More at [zovo.one](https://zovo.one)


