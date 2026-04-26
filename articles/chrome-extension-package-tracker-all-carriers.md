---
layout: default
title: "Package Tracker All Carriers Chrome (2026)"
description: "Claude Code extension tip: learn how to build or use a Chrome extension that tracks packages across all carriers. Practical code examples and..."
date: 2026-03-15
last_modified_at: 2026-04-17
author: "Claude Skills Guide"
permalink: /chrome-extension-package-tracker-all-carriers/
reviewed: true
score: 8
categories: [guides]
tags: [chrome-extension, claude-skills]
geo_optimized: true
---
Tracking packages across multiple carriers in a single Chrome extension is a common challenge for developers building logistics tools. Whether you're creating a personal productivity extension or a full-featured shipment management tool, understanding the underlying architecture and APIs makes the difference between a fragile implementation and a solid solution.

This guide covers the technical foundation for building a Chrome extension that integrates with multiple shipping carriers, including practical code patterns, carrier comparison details, and architecture decisions you can adapt for your own projects.

## Understanding Carrier API Integration

Most major carriers (UPS, FedEx, USPS, DHL, etc.) provide tracking APIs, but they vary significantly in authentication methods, response formats, and rate limits. A well-designed extension abstracts these differences behind a unified interface.

Before writing any code, it helps to understand what you're dealing with across carriers:

| Carrier | Auth Method | Response Format | Free Tier Rate Limit | Number Format |
|---------|-------------|-----------------|----------------------|---------------|
| UPS | OAuth 2.0 | JSON | 500 req/day | 1Z + 16 chars |
| FedEx | OAuth 2.0 | JSON | 1000 req/day | 12-22 digits |
| USPS | API key (header) | XML or JSON | 1000 req/day | 20-22 digits |
| DHL | API key (query param) | JSON | 250 req/day | 10-11 digits |
| Amazon Logistics | No public API | N/A (scraping only) | N/A | TBA prefix |
| OnTrac | API key (basic auth) | JSON | 200 req/day | C digits |

Understanding these differences upfront informs your architecture. For example, USPS historically returned XML, so your adapter may need to handle XML parsing separately from the JSON-centric carriers.

Here's a TypeScript pattern for a carrier-agnostic tracking service:

```typescript
interface TrackingEvent {
 timestamp: Date;
 location: string;
 status: string;
 description: string;
}

interface TrackingResult {
 carrier: string;
 trackingNumber: string;
 events: TrackingEvent[];
 estimatedDelivery?: Date;
 status: 'pending' | 'in-transit' | 'delivered' | 'exception';
}

abstract class CarrierAdapter {
 abstract readonly name: string;
 abstract readonly trackingUrl: string;

 abstract parseResponse(data: unknown): TrackingResult;

 async fetchTracking(trackingNumber: string): Promise<TrackingResult> {
 const response = await this.makeRequest(trackingNumber);
 return this.parseResponse(response);
 }

 protected abstract makeRequest(trackingNumber: string): Promise<unknown>;
}
```

This abstraction lets you add new carriers without modifying the core extension logic. Each carrier implementation only needs to handle its specific API quirks. Here is a concrete UPS adapter implementation:

```typescript
class UPSAdapter extends CarrierAdapter {
 readonly name = 'UPS';
 readonly trackingUrl = 'https://www.ups.com/track';
 private accessToken: string | null = null;
 private tokenExpiry: number = 0;

 private async getAccessToken(): Promise<string> {
 if (this.accessToken && Date.now() < this.tokenExpiry) {
 return this.accessToken;
 }
 const response = await fetch('https://onlinetools.ups.com/security/v1/oauth/token', {
 method: 'POST',
 headers: {
 'Authorization': `Basic ${btoa(`${UPS_CLIENT_ID}:${UPS_CLIENT_SECRET}`)}`,
 'Content-Type': 'application/x-www-form-urlencoded',
 },
 body: 'grant_type=client_credentials',
 });
 const data = await response.json();
 this.accessToken = data.access_token;
 this.tokenExpiry = Date.now() + (data.expires_in * 1000) - 60000; // refresh 1 min early
 return this.accessToken;
 }

 protected async makeRequest(trackingNumber: string): Promise<unknown> {
 const token = await this.getAccessToken();
 const response = await fetch(
 `https://onlinetools.ups.com/api/track/v1/details/${trackingNumber}`,
 { headers: { 'Authorization': `Bearer ${token}` } }
 );
 return response.json();
 }

 parseResponse(data: any): TrackingResult {
 const shipment = data?.trackResponse?.shipment?.[0];
 const pkg = shipment?.package?.[0];
 return {
 carrier: 'UPS',
 trackingNumber: pkg?.trackingNumber ?? '',
 status: this.mapStatus(pkg?.status?.type ?? ''),
 estimatedDelivery: pkg?.deliveryDate?.[0]?.date
 ? new Date(pkg.deliveryDate[0].date)
 : undefined,
 events: (pkg?.activity ?? []).map((a: any) => ({
 timestamp: new Date(`${a.date} ${a.time}`),
 location: `${a.location?.address?.city ?? ''}, ${a.location?.address?.stateProvince ?? ''}`,
 status: a.status?.type ?? '',
 description: a.status?.description ?? '',
 })),
 };
 }

 private mapStatus(type: string): TrackingResult['status'] {
 const map: Record<string, TrackingResult['status']> = {
 'I': 'in-transit',
 'D': 'delivered',
 'X': 'exception',
 'P': 'pending',
 };
 return map[type] ?? 'pending';
 }
}
```

## Auto-Detecting Carriers from Tracking Numbers

One of the most useful features for users is automatic carrier detection. Most carriers use predictable number patterns that let you identify them from the tracking number alone.

```typescript
function detectCarrier(trackingNumber: string): string | null {
 const patterns = [
 { carrier: 'UPS', pattern: /^1Z[A-Z0-9]{16}$/i },
 { carrier: 'FedEx', pattern: /^[0-9]{12,22}$/ },
 { carrier: 'USPS', pattern: /^[0-9]{20,22}$/ },
 { carrier: 'DHL', pattern: /^[0-9]{10,11}$/ },
 { carrier: 'OnTrac', pattern: /^C[0-9]{14}$/ },
 { carrier: 'LaserShip', pattern: /^1LS[0-9A-Z]{10,}$/i },
 ];

 const normalized = trackingNumber.replace(/\s/g, '').toUpperCase();

 for (const { carrier, pattern } of patterns) {
 if (pattern.test(normalized)) {
 return carrier;
 }
 }

 return null;
}
```

This function returns the carrier name or null if detection fails. For mixed shipments that span multiple carriers, you'll need to check each carrier's API sequentially.

A more solid approach uses a priority-ordered list and tests multiple patterns, since some tracking number formats overlap between carriers (FedEx and USPS both use numeric strings of similar lengths). When overlap is possible, you can try both APIs and return the one that responds with valid data.

```typescript
async function detectCarrierWithFallback(
 trackingNumber: string,
 adapters: CarrierAdapter[]
): Promise<TrackingResult | null> {
 const detected = detectCarrier(trackingNumber);
 if (detected) {
 const adapter = adapters.find(a => a.name === detected);
 if (adapter) return adapter.fetchTracking(trackingNumber);
 }

 // Ambiguous number. try all adapters in parallel, return first success
 const results = await Promise.allSettled(
 adapters.map(a => a.fetchTracking(trackingNumber))
 );

 for (const result of results) {
 if (result.status === 'fulfilled') return result.value;
 }

 return null;
}
```

## Building the Extension Architecture

A typical Chrome extension for package tracking consists of three main components:

1. Popup UI - Quick status view when clicking the extension icon
2. Background Service Worker - Handles API calls, polling, and notifications
3. Content Scripts - Optionally detect and extract tracking numbers from e-commerce pages

The division of responsibility matters. Content scripts should only detect tracking numbers on pages like order confirmation emails or Amazon order pages, they should not make API calls directly. API calls belong in the service worker to keep credentials out of the page context.

Here is a manifest configuration for Manifest V3:

```json
{
 "manifest_version": 3,
 "name": "Multi-Carrier Package Tracker",
 "version": "1.0.0",
 "permissions": [
 "storage",
 "alarms",
 "notifications",
 "activeTab"
 ],
 "host_permissions": [
 "https://onlinetools.ups.com/*",
 "https://apis.fedex.com/*",
 "https://secure.shippingapis.com/*",
 "https://api-eu.dhl.com/*"
 ],
 "background": {
 "service_worker": "background/service-worker.js"
 },
 "action": {
 "default_popup": "popup/popup.html"
 },
 "content_scripts": [
 {
 "matches": ["https://www.amazon.com/gp/css/order-history*"],
 "js": ["content/amazon-detector.js"]
 }
 ]
}
```

The background service is where the heavy lifting happens. Here's a simplified service worker pattern:

```typescript
// background/service-worker.ts
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
 if (message.type === 'TRACK_PACKAGE') {
 handleTracking(message.trackingNumber, message.carrier)
 .then(result => sendResponse({ success: true, data: result }))
 .catch(error => sendResponse({ success: false, error: error.message }));
 return true; // Keep message channel open for async response
 }

 if (message.type === 'ADD_PACKAGE') {
 addAndTrack(message.trackingNumber)
 .then(result => sendResponse({ success: true, data: result }))
 .catch(error => sendResponse({ success: false, error: error.message }));
 return true;
 }
});

async function handleTracking(trackingNumber: string, carrier?: string): Promise<TrackingResult> {
 const detectedCarrier = carrier || detectCarrier(trackingNumber);

 if (!detectedCarrier) {
 throw new Error('Unable to detect carrier from tracking number');
 }

 const adapter = getCarrierAdapter(detectedCarrier);
 return adapter.fetchTracking(trackingNumber);
}
```

## Handling Rate Limits and Caching

Carrier APIs impose rate limits, and making excessive requests quickly leads to throttling or API key suspension. Implement caching to reduce redundant calls:

```typescript
const cache = new Map<string, { data: TrackingResult; timestamp: number }>();
const CACHE_TTL = 15 * 60 * 1000; // 15 minutes

async function getTrackingWithCache(
 adapter: CarrierAdapter,
 trackingNumber: string
): Promise<TrackingResult> {
 const cached = cache.get(trackingNumber);

 if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
 return cached.data;
 }

 const result = await adapter.fetchTracking(trackingNumber);
 cache.set(trackingNumber, { data: result, timestamp: Date.now() });

 return result;
}
```

For a production extension, consider using Chrome's storage API to persist the cache across browser sessions. In-memory Maps are cleared when the service worker goes idle (which happens frequently in Manifest V3). Here is a persistent cache using `chrome.storage.local`:

```typescript
const CACHE_TTL = 15 * 60 * 1000;

async function getCached(key: string): Promise<TrackingResult | null> {
 const stored = await chrome.storage.local.get(`cache:${key}`);
 const entry = stored[`cache:${key}`];
 if (!entry) return null;
 if (Date.now() - entry.timestamp > CACHE_TTL) {
 await chrome.storage.local.remove(`cache:${key}`);
 return null;
 }
 return entry.data as TrackingResult;
}

async function setCached(key: string, data: TrackingResult): Promise<void> {
 await chrome.storage.local.set({
 [`cache:${key}`]: { data, timestamp: Date.now() },
 });
}
```

## Polling and Delivery Notifications

A passive tracker that only updates when the user opens the popup is less useful than one that proactively notifies about status changes. Use `chrome.alarms` to schedule periodic polling:

```typescript
// Set up polling alarm on install
chrome.runtime.onInstalled.addListener(() => {
 chrome.alarms.create('pollTracking', { periodInMinutes: 30 });
});

chrome.alarms.onAlarm.addListener(async (alarm) => {
 if (alarm.name === 'pollTracking') {
 await pollAllPackages();
 }
});

async function pollAllPackages(): Promise<void> {
 const { packages = [] } = await chrome.storage.local.get('packages');

 for (const pkg of packages) {
 if (pkg.status === 'delivered') continue; // No need to keep polling

 try {
 const result = await handleTracking(pkg.trackingNumber, pkg.carrier);

 if (result.status !== pkg.lastKnownStatus) {
 // Status changed. fire notification
 chrome.notifications.create(`status-${pkg.trackingNumber}`, {
 type: 'basic',
 iconUrl: 'icons/icon48.png',
 title: 'Package Update',
 message: `${pkg.nickname || pkg.trackingNumber}: ${result.events[0]?.description ?? result.status}`,
 });
 // Update stored status
 pkg.lastKnownStatus = result.status;
 await savePackage(pkg);
 }
 } catch (err) {
 console.warn(`Polling failed for ${pkg.trackingNumber}:`, err);
 }
 }
}
```

Avoid polling too frequently. A 30-minute interval is sufficient for most carriers. Polling every few minutes will quickly exhaust free-tier rate limits and may get your API key banned.

## Integrating Multiple Carriers

When a shipment moves between carriers (common with international packages), you need to handle multi-carrier tracking. The key is storing the full journey rather than just the current status:

```typescript
interface MultiCarrierTracking {
 primaryTrackingNumber: string;
 segments: TrackingSegment[];
}

interface TrackingSegment {
 carrier: string;
 trackingNumber: string;
 origin: string;
 destination: string;
 events: TrackingEvent[];
}

function mergeTrackingSegments(segments: TrackingSegment[]): TrackingEvent[] {
 return segments
 .flatMap(s => s.events)
 .sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime());
}
```

A common real-world scenario is a package shipped from Asia via China Post, transferred to USPS at the US border, and then delivered by your local post office. Handling this well requires that users can link tracking numbers and see a unified timeline.

## Local Storage and Data Persistence

Chrome extensions can store tracking data using the chrome.storage API, which persists across sessions and syncs with the user's Google account:

```typescript
interface StoredPackage {
 trackingNumber: string;
 carrier: string;
 nickname?: string;
 lastUpdated: number;
 lastKnownStatus: string;
}

async function savePackage(pkg: StoredPackage): Promise<void> {
 const { packages = [] } = await chrome.storage.local.get('packages');

 const existing = packages.findIndex((p: StoredPackage) =>
 p.trackingNumber === pkg.trackingNumber && p.carrier === pkg.carrier
 );

 if (existing >= 0) {
 packages[existing] = { ...packages[existing], ...pkg };
 } else {
 packages.push(pkg);
 }

 await chrome.storage.local.set({ packages });
}

async function removePackage(trackingNumber: string): Promise<void> {
 const { packages = [] } = await chrome.storage.local.get('packages');
 const filtered = packages.filter((p: StoredPackage) => p.trackingNumber !== trackingNumber);
 await chrome.storage.local.set({ packages: filtered });
 await chrome.storage.local.remove(`cache:${trackingNumber}`);
}
```

If you use `chrome.storage.sync` instead of `chrome.storage.local`, data will sync across all of the user's Chrome instances using their Google account. This is convenient but comes with stricter size limits (100KB total, 8KB per key). For extensions with many tracked packages or detailed event histories, stick with `chrome.storage.local`.

## Content Script: Auto-Detecting Tracking Numbers on Pages

A great quality-of-life feature is automatically recognizing tracking numbers on Amazon order pages, email confirmations, or shipping confirmation pages. Here is a simple content script pattern:

```typescript
// content/detector.ts
const TRACKING_PATTERNS = [
 { carrier: 'UPS', pattern: /\b(1Z[A-Z0-9]{16})\b/gi },
 { carrier: 'FedEx', pattern: /\b([0-9]{12,22})\b/g },
 { carrier: 'USPS', pattern: /\b([0-9]{20,22})\b/g },
 { carrier: 'DHL', pattern: /\b([0-9]{10,11})\b/g },
];

function scanPageForTrackingNumbers(): Array<{ carrier: string; number: string }> {
 const text = document.body.innerText;
 const found: Array<{ carrier: string; number: string }> = [];

 for (const { carrier, pattern } of TRACKING_PATTERNS) {
 const matches = [...text.matchAll(pattern)];
 for (const match of matches) {
 found.push({ carrier, number: match[1] });
 }
 }

 return found;
}

const numbers = scanPageForTrackingNumbers();
if (numbers.length > 0) {
 chrome.runtime.sendMessage({ type: 'TRACKING_NUMBERS_FOUND', data: numbers });
}
```

The popup can then offer a one-click "Add all detected packages" button, making the workflow smooth for users who shop frequently.

## Security Considerations

When building package tracking extensions, keep these security practices in mind:

- Never hardcode API keys - Store credentials in `chrome.storage.local` or use a backend proxy. Do not include them in the extension bundle, anyone can unpack a `.crx` file and read your keys.
- Use a backend proxy - For production extensions, route all carrier API calls through your own server. This protects your API keys completely and allows you to implement server-side caching and rate limiting.
- Validate all inputs - Sanitize and validate tracking numbers before passing them to API calls. Reject inputs that do not match expected patterns.
- Use HTTPS exclusively - All carrier API calls should use TLS. Modern carrier APIs enforce this, but verify it is not silently downgraded anywhere in your code.
- Minimize permissions - Declare only the host permissions you actually need. A `host_permissions` entry for `https://*/*` will trigger Chrome Web Store security review flags.
- Avoid storing sensitive data long-term - Cache only what you need for UI performance; do not log or store full shipment histories indefinitely without user consent.

## Practical Tips for Production

Several issues come up repeatedly when this type of extension is used at scale:

Handle carrier outages gracefully. Carrier APIs go down. When a request fails, show the user the last known status with a timestamp rather than a generic error. Set retry logic with exponential backoff.

Account for timezone differences. Carrier event timestamps are often local times without timezone offsets. USPS events, for example, are in the local time of the scanning facility. Normalizing to UTC before storing avoids confusing chronology in the timeline display.

Deduplicate events. Some carrier APIs return duplicate events when polled multiple times (especially if a status was scanned twice). Before appending new events, compare timestamps and descriptions to remove duplicates.

Test with real tracking numbers. Carrier sandbox environments often return synthetic data that does not reflect real-world edge cases. Test with real shipments to catch issues like missing fields, unexpected null values, or unusual status codes.

## Conclusion

Building a Chrome extension for multi-carrier package tracking requires handling diverse API patterns, managing rate limits, and presenting unified data to users. The adapter pattern shown here scales well as you add carriers, while persistent caching, proactive polling, and proper storage ensure a responsive user experience that works even after the service worker sleeps.

For developers looking to extend this foundation, consider adding delivery notifications with estimated windows, a visual timeline UI in the popup, historical tracking data charts for frequent shippers, or integration with calendar apps to surface expected delivery dates as events. Each of these builds naturally on the architecture described here.

The most impactful single improvement for user experience is the content script that auto-detects tracking numbers on order pages. Users should not have to copy-paste tracking numbers manually, that friction is what separates a useful extension from one that sits unused after the first week.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=chrome-extension-package-tracker-all-carriers)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Chrome Extension Black Friday Deal Tracker: A.](/chrome-extension-black-friday-deal-tracker/)
- [Chrome Extension Linear Issue Tracker: A Developer's Guide](/chrome-extension-linear-issue-tracker/)
- [Chrome Extension Open Box Deal Tracker: Build Your Own.](/chrome-extension-open-box-deal-tracker/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

