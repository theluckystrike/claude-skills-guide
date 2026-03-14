---
layout: default
title: "Claude Code Skills for Nonprofit Donation Platforms"
description: "Practical Claude Code skills for building nonprofit donation platforms — from Stripe integration to donor management and receipt generation."
date: 2026-03-14
categories: [use-cases]
tags: [claude-code, claude-skills, nonprofit, donations, automation]
author: "Claude Skills Guide"
reviewed: true
score: 7
---

# Claude Code Skills for Nonprofit Donation Platforms

Building a nonprofit donation platform requires handling sensitive financial data, generating tax receipts, managing donor relationships, and ensuring PCI compliance. Claude Code skills accelerate these tasks by providing structured workflows for common nonprofit platform patterns. This guide covers the most useful skills for donation platform development.

## Understanding the Skill Model

Claude skills are instruction files loaded from `~/.claude/skills/` when you invoke them with slash commands. They do not execute code — they guide Claude to produce better code for your specific domain. For nonprofit donation platforms, this means getting Stripe-ready implementations, proper receipt generation, and donor data handling patterns from the start.

## /stripe-integration: Payment Processing Foundation

The **stripe-integration** skill helps you set up donation payment flows correctly. For nonprofit platforms, you need to handle one-time donations, recurring subscriptions, and donor-covered fees.

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

This skill also covers Stripe Webhook handling for donation confirmations, failed payment recovery, and refund processing — critical for maintaining donor trust.

## /pdf: Tax Receipt Generation

Every nonprofit donation platform needs to generate tax receipts. The **pdf** skill produces properly formatted 501(c)(3) donation receipts with all required IRS information.

```python
# Receipt generation with PDF skill guidance
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

## /security: Donor Data Protection

Nonprofit platforms handle sensitive donor information. The **security** skill generates implementations following OWASP guidelines and data protection best practices.

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

This skill also covers GDPR compliance for international donors, data retention policies, and secure logging practices that avoid exposing donor information.

## /api-design: Donor Management Endpoints

The **api-design** skill helps you build clean REST or GraphQL endpoints for donor management. Nonprofit platforms need specific endpoints for:

```python
# FastAPI example from api-design skill guidance
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

class DonationCreate(BaseModel):
    amount: int
    donor_id: str
    designation: str  # restricted fund, general fund, etc.

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

## /email-templates: Donor Communication

The **email-templates** skill generates transactional emails for donation confirmations, recurring donation alerts, and year-end tax summary generation. These are required for donor retention and IRS compliance.

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

## /webhook: Payment Event Handling

The **webhook** skill handles the complex event flows from payment processors. For recurring donations, you need to handle:

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

## Practical Integration Workflow

Combine these skills for a complete donation flow:

1. Use **/api-design** to define your donation endpoint
2. Use **/stripe-integration** to handle the payment
3. Use **/webhook** to process the confirmation
4. Use **/pdf** to generate the tax receipt
5. Use **/email-templates** to send confirmation
6. Use **/security** to encrypt stored donor data

Each skill produces production-ready code that handles the edge cases specific to nonprofit donation platforms.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
