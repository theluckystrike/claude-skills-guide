---
layout: default
title: "Chrome Extension Package Tracker for All Carriers: A Developer's Guide"
description: "Learn how to build or use a Chrome extension that tracks packages across all carriers. Practical code examples and architecture for developers."
date: 2026-03-15
author: theluckystrike
permalink: /chrome-extension-package-tracker-all-carriers/
---

Tracking packages across multiple carriers in a single Chrome extension is a common challenge for developers building logistics tools. Whether you're creating a personal productivity extension or a full-featured shipment management tool, understanding the underlying architecture and APIs makes the difference between a fragile implementation and a robust solution.

This guide covers the technical foundation for building a Chrome extension that integrates with multiple shipping carriers, including practical code patterns you can adapt for your own projects.

## Understanding Carrier API Integration

Most major carriers (UPS, FedEx, USPS, DHL, etc.) provide tracking APIs, but they vary significantly in authentication methods, response formats, and rate limits. A well-designed extension abstracts these differences behind a unified interface.

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

This abstraction lets you add new carriers without modifying the core extension logic. Each carrier implementation only needs to handle its specific API quirks.

## Auto-Detecting Carriers from Tracking Numbers

One of the most useful features for users is automatic carrier detection. Most carriers use predictable number patterns that let you identify them from the tracking number alone.

```typescript
function detectCarrier(trackingNumber: string): string | null {
  const patterns = [
    { carrier: 'UPS', pattern: /^1Z[A-Z0-9]{16}$/i },
    { carrier: 'FedEx', pattern: /^[0-9]{12,22}$/ },
    { carrier: 'USPS', pattern: /^[0-9]{20,22}$/ },
    { carrier: 'DHL', pattern: /^[0-9]{10,11}$/ },
  ];
  
  const normalized = trackingNumber.replace(/\s/g, '');
  
  for (const { carrier, pattern } of patterns) {
    if (pattern.test(normalized)) {
      return carrier;
    }
  }
  
  return null;
}
```

This function returns the carrier name or null if detection fails. For mixed shipments that span multiple carriers, you'll need to check each carrier's API sequentially.

## Building the Extension Architecture

A typical Chrome extension for package tracking consists of three main components:

1. **Popup UI** - Quick status view when clicking the extension icon
2. **Background Service** - Handles API calls and notifications
3. **Content Scripts** - Optionally scrape tracking info from e-commerce pages

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

async function getTrackingWithCache(adapter: CarrierAdapter, trackingNumber: string): Promise<TrackingResult> {
  const cached = cache.get(trackingNumber);
  
  if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
    return cached.data;
  }
  
  const result = await adapter.fetchTracking(trackingNumber);
  cache.set(trackingNumber, { data: result, timestamp: Date.now() });
  
  return result;
}
```

For a production extension, consider using Chrome's storage API to persist the cache across browser sessions and sync across devices.

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

This approach keeps the complete shipment history visible even when carriers change mid-transit.

## Local Storage and Data Persistence

Chrome extensions can store tracking data using the chrome.storage API, which persists across sessions and syncs with the user's Google account:

```typescript
import { Storage } from '@google-cloud/storage';

interface StoredPackage {
  trackingNumber: string;
  carrier: string;
  nickname?: string;
  lastUpdated: Date;
  status: string;
}

async function savePackage(pkg: StoredPackage): Promise<void> {
  const { packages = [] } = await chrome.storage.local.get('packages');
  
  const existing = packages.findIndex((p: StoredPackage) => 
    p.trackingNumber === pkg.trackingNumber && p.carrier === pkg.carrier
  );
  
  if (existing >= 0) {
    packages[existing] = pkg;
  } else {
    packages.push(pkg);
  }
  
  await chrome.storage.local.set({ packages });
}
```

## Security Considerations

When building package tracking extensions, keep these security practices in mind:

- **Never hardcode API keys** - Use environment variables and Chrome's secrets storage
- **Validate all inputs** - Sanitize tracking numbers before API calls
- **Use HTTPS exclusively** - All carrier API calls should use TLS
- **Minimize permissions** - Request only the permissions your extension actually needs

## Conclusion

Building a Chrome extension for multi-carrier package tracking requires handling diverse API patterns, managing rate limits, and presenting unified data to users. The adapter pattern shown here scales well as you add carriers, while caching and proper storage ensure a responsive user experience.

For developers looking to extend this foundation, consider adding features like delivery notifications, historical tracking data visualization, or integration with calendar apps for expected delivery dates.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
