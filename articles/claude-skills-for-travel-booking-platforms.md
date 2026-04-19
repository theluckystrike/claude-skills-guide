---
title: "Claude Skills for Travel Booking Platforms — Automate GDS Parsing, Fare Rules, and PNR Validation — 2026"
description: "Build a Claude Code skill that parses Amadeus/Sabre GDS responses, validates PNR structures, enforces fare rule constraints, and generates booking confirmations."
permalink: /claude-skills-for-travel-booking-platforms/
render_with_liquid: false
categories: [skills, 2026]
tags: [claude-code, claude-skills, travel, booking-platforms]
last_updated: 2026-04-19
---

## The Specific Situation

Your travel booking platform integrates with Amadeus or Sabre GDS (Global Distribution System). Every flight search returns cryptic response formats: fare basis codes like "YOWUS" (Y=economy, OW=one-way, US=origin), booking class letters, segment status codes (HK=confirmed, HL=waitlisted, UC=unable to confirm). A developer unfamiliar with GDS conventions will write parsers that silently drop waitlisted segments or miscalculate baggage allowances based on fare class.

A Claude Code skill encodes GDS response structures, fare basis code decomposition, PNR (Passenger Name Record) field validation, and IATA airport/airline code lookups. When a developer touches the booking engine code, Claude loads these conventions automatically and catches parsing errors before they reach production.

## Technical Foundation

The skill uses `paths: ["src/gds/**/*", "src/booking/**/*", "src/flights/**/*"]` to activate only in travel-related code. The `references/` directory holds the full GDS response format documentation (4,000+ words) that Claude reads on demand through progressive disclosure -- keeping the main SKILL.md body focused on the most common operations.

Dynamic context injection pulls live configuration: `!`cat config/gds-credentials.json | jq '.active_provider'`` tells Claude whether the current integration targets Amadeus, Sabre, or Travelport, so instructions adapt to the active GDS. The `allowed-tools` field pre-approves `Bash(node *)` for running fare calculation scripts.

## The Working SKILL.md

Create at `.claude/skills/travel-booking/SKILL.md`:

```yaml
---
name: travel-booking
description: >
  Travel booking platform skill. Use when working with GDS integrations
  (Amadeus, Sabre, Travelport), PNR parsing, fare basis code decomposition,
  booking class mapping, or IATA code validation. Knows segment status
  codes, fare rule categories, and ticket time limit conventions.
paths:
  - "src/gds/**/*"
  - "src/booking/**/*"
  - "src/flights/**/*"
allowed-tools: Bash(node *) Read Grep
---

# Travel Booking Platform Skill

## GDS Response Parsing

### Segment Status Codes
- **HK**: Holding confirmed (seats booked)
- **HL**: Waitlisted (not confirmed, do NOT display as confirmed to user)
- **UC**: Unable to confirm (GDS rejected)
- **TK**: Schedule change (re-confirm with passenger)
- **SS**: Sold (passive segment, used for manual bookings)
- **GK**: Ghost segment (placeholder, not ticketable)

### Fare Basis Code Decomposition
Format: [Class][Type][Season][Advance][Restrictions]
Examples:
- `YOWUS`: Y(economy full-flex) OW(one-way) US(domestic)
- `BLXAP14`: B(economy discounted) L(low season) X(no changes) AP14(14-day advance purchase)
- `JRTNN`: J(business) RT(round-trip) NN(non-refundable)

### Booking Class Hierarchy (typical)
First: F, A, P | Business: J, C, D, I | Premium Economy: W, E
Economy Full: Y, B | Economy Discount: M, H, Q, K, L, V, N, S, T

### IATA Codes
- Airline: 2-letter (AA=American, BA=British Airways, LH=Lufthansa)
- Airport: 3-letter (LAX, LHR, NRT, CDG, SIN)
- Validate against `data/iata-airlines.json` and `data/iata-airports.json`

## PNR Validation Rules
A valid PNR must contain:
1. At least one passenger name (SSR field, format: LASTNAME/FIRSTNAME)
2. At least one itinerary segment with status HK
3. Contact information (CTCE for email, CTCM for mobile)
4. Ticketing time limit (TL field, format: TAW/date)
5. Received-from field (RF)

Flag PNRs missing any of these as INCOMPLETE. Do not allow ticketing on incomplete PNRs.

## Fare Rule Categories (ATPCO)
- Cat 5: Advance purchase (AP requirements)
- Cat 6: Minimum stay (e.g., Saturday night rule)
- Cat 7: Maximum stay
- Cat 10: Combinability (can segments use different fare bases?)
- Cat 16: Penalties (change fee amounts, refund rules)
- Cat 31: Voluntary changes
- Cat 33: Voluntary refunds

When implementing fare rules, always check Cat 16 and Cat 33 before displaying "refundable" or "changeable" labels to users.

## Pricing Calculations
- Base fare + taxes/fees = total. Never display base fare alone to consumers.
- Tax codes: US(US transportation tax), XF(passenger facility charge), YQ/YR(carrier surcharges)
- Currency: Always store in fare currency (from GDS), convert at display time
- Infant pricing: Typically 10% of adult fare, no seat. Check GDS response for IN fare type.

## References
- Full Amadeus response format: see `references/amadeus-api-format.md`
- Sabre REST API mapping: see `references/sabre-rest-mapping.md`
- ATPCO fare rule categories: see `references/atpco-categories.md`
```

PNR validation function example:

```typescript
interface PNRValidation {
  hasPassenger: boolean;
  hasConfirmedSegment: boolean;
  hasContact: boolean;
  hasTimeLimit: boolean;
  hasReceivedFrom: boolean;
  isComplete: boolean;
}

function validatePNR(pnr: ParsedPNR): PNRValidation {
  const result = {
    hasPassenger: pnr.passengers.length > 0,
    hasConfirmedSegment: pnr.segments.some(s => s.status === 'HK'),
    hasContact: !!(pnr.ctce || pnr.ctcm),
    hasTimeLimit: !!pnr.ticketingLimit,
    hasReceivedFrom: !!pnr.receivedFrom,
    isComplete: false,
  };
  result.isComplete = Object.values(result).every(v => v === true);
  return result;
}
```

## Common Problems and Fixes

**Waitlisted segments shown as confirmed bookings.** Segment status HL gets treated like HK in the UI. Add a strict filter: only segments with status HK or SS should display as "confirmed." All other statuses must show a warning banner.

**Fare basis code parser breaks on codeshare flights.** Codeshare flights may return the marketing carrier's fare basis format, which differs from the operating carrier. Always parse fare basis codes using the marketing carrier's convention, not the operating carrier's.

**Currency conversion applied twice.** GDS returns fares in the point-of-sale currency. If your backend converts and then the frontend converts again, prices are wrong. Store the original currency code alongside the amount and convert exactly once at the display layer.

**PNR time limit ignored.** The ticketing time limit (TAW) is a hard deadline. After that timestamp, the GDS auto-cancels the PNR. Display this deadline to the user and trigger a reminder notification 4 hours before expiry.

## Production Gotchas

GDS sandbox environments return different response structures than production. Amadeus test mode uses a subset of segment status codes and does not return real fare rule categories. Always test fare rule parsing against production responses (anonymized) before launch.

Multi-city itineraries create multiple HL (hierarchical level) segments in the PNR. Your parser must handle variable segment counts -- a round-trip has 2, a multi-city can have 6+. Do not hardcode segment array lengths.

## Checklist

- [ ] IATA airline and airport code databases are current (`data/iata-*.json`)
- [ ] GDS response test fixtures cover HK, HL, UC, and TK statuses
- [ ] Fare basis parser handles at least 10 distinct code patterns
- [ ] PNR validation rejects incomplete records before ticketing
- [ ] Currency conversion happens in exactly one layer of the stack

## Related Guides

- [Claude Skills for E-Commerce Platforms](/claude-skills-for-ecommerce-platforms/) -- checkout and payment patterns
- [Claude Skills for Logistics and Supply Chain](/claude-skills-for-logistics-supply-chain/) -- cargo and freight booking
- [Claude Skill Composition Patterns](/claude-skill-composition-patterns/) -- combining booking with notification skills

## Related Articles

- [Claude Code Skills for Nonprofit Donation Platforms (2026)](/claude-code-skills-for-nonprofit-donation-platforms/)
- [Claude Code Skills for Travel Booking Platforms](/claude-code-skills-for-travel-booking-platforms/)
