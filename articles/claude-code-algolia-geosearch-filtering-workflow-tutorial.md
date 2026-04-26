---

layout: default
title: "Claude Code Algolia GeoSearch Filtering (2026)"
description: "Learn how to build powerful location-based search filtering workflows using Claude Code and Algolia's GeoSearch capabilities. Step-by-step guide with."
date: 2026-04-19
last_modified_at: 2026-04-19
author: "Claude Skills Guide"
categories: [tutorials]
tags: [claude-code, algolia, geosearch, filtering, workflow, tutorial, claude-skills]
permalink: /claude-code-algolia-geosearch-filtering-workflow-tutorial/
reviewed: true
score: 7
geo_optimized: true
---

Everything below targets algolia geosearch filtering and the specific Claude Code patterns that make algolia geosearch filtering work smoothly. For related approaches, see [Claude Code for Workspace Indexing Workflow Tutorial](/claude-code-for-workspace-indexing-workflow-tutorial/).

Location-based search is a fundamental feature for modern applications, from finding nearby restaurants to locating available delivery drivers. Algolia's GeoSearch capabilities combined with Claude Code's intelligent workflow automation make building these features straightforward and powerful. This tutorial walks you through creating a complete GeoSearch filtering workflow using Claude Code, covering everything from initial index configuration to advanced adaptive radius strategies and production-ready error handling.

## Understanding GeoSearch Fundamentals

Algolia's GeoSearch allows you to search records based on geographic coordinates. The core concept involves storing latitude and longitude values with your records and then querying around a central point with a specified radius. What makes this powerful is the ability to combine geographic filtering with traditional text search and faceted filtering.

When you work with Claude Code, you can create skills that understand both the Algolia API nuances and the best practices for implementing GeoSearch. The skill can guide you through index configuration, query construction, and result handling.

Before diving into code, it helps to understand the three primary GeoSearch query modes Algolia supports:

| Query Mode | Parameter | Best For |
|---|---|---|
| Around a point | `aroundLatLng` + `aroundRadius` | Nearest-to-me searches, delivery radius |
| Inside a bounding box | `insideBoundingBox` | Map viewport searches, city/region scoping |
| Inside a polygon | `insidePolygon` | Irregular delivery zones, neighborhood boundaries |
| Around multiple points | `aroundLatLng` (array) | Multi-hub searches, franchise coverage |

For most store-finder and proximity-search use cases, `aroundLatLng` with `aroundRadius` is the right starting point. Bounding-box searches become important when you are syncing search results with a visible map, users expect search results to match what they can see on screen, not an arbitrary circle centered off-screen.

## Setting Up Your Algolia Index for GeoSearch

Before implementing the filtering workflow, your Algolia index needs proper configuration. Records must include `_geoloc` attributes containing latitude and longitude values. Here's an example record structure for a store finder:

```json
{
 "objectID": "store_123",
 "name": "Downtown Coffee Shop",
 "address": "123 Main Street",
 "category": "coffee",
 "openHour": 7,
 "closeHour": 22,
 "outdoorSeating": true,
 "rating": 4.5,
 "_geoloc": {
 "lat": 40.7128,
 "lng": -74.0060
 }
}
```

Claude Code can help you transform existing data into this format. A well-designed skill would guide you through the data migration process, ensuring your coordinates are properly formatted and indexed. If your source data stores coordinates in a different schema, say, `location.coordinates` as a GeoJSON array, Claude Code can write the transformation script for you:

```javascript
// Transform GeoJSON coordinates to Algolia _geoloc format
function transformRecordForAlgolia(record) {
 const { location, ...rest } = record;
 return {
 ...rest,
 _geoloc: {
 lat: location.coordinates[1], // GeoJSON is [lng, lat]
 lng: location.coordinates[0]
 }
 };
}

// Batch-upload transformed records
const { algoliasearch } = require('algoliasearch');
const client = algoliasearch('YOUR_APP_ID', 'YOUR_ADMIN_KEY');
const index = client.initIndex('stores');

const records = rawData.map(transformRecordForAlgolia);
await index.saveObjects(records, { autoGenerateObjectIDIfNotExist: true });
```

The next step involves configuring searchable attributes and facets. Your category, name, and address should be searchable, while category becomes a faceted attribute for filtering. Configure this via the Algolia dashboard or programmatically:

```json
{
 "searchableAttributes": [
 "name",
 "address",
 "category"
 ],
 "attributesForFaceting": [
 "category",
 "outdoorSeating",
 "filterOnly(openHour)",
 "filterOnly(closeHour)",
 "_geoloc"
 ],
 "customRanking": [
 "desc(rating)"
 ],
 "attributesToRetrieve": [
 "name",
 "address",
 "category",
 "rating",
 "openHour",
 "closeHour",
 "outdoorSeating",
 "_geoloc"
 ]
}
```

The `filterOnly()` wrapper on `openHour` and `closeHour` tells Algolia to index these as filter-only facets, which avoids unnecessarily bloating the facet response with numeric ranges that users will never browse directly.

## Building the Claude Code Skill

Creating a Claude Code skill for Algolia GeoSearch involves defining clear instructions for constructing queries and handling responses. The skill should understand the relationship between geographic coordinates, search radius, and filtering parameters.

Your skill definition starts with clear documentation of the GeoSearch parameters:

```yaml
---
name: algolia-geosearch
description: "Build location-based search queries with Algolia"
---

Algolia GeoSearch Workflow

This skill helps you construct efficient GeoSearch queries combining location filtering with text search and faceted filtering.
```

The skill body should explain how to construct the query object. The critical parameters are `aroundLatLng` for the search center and `aroundRadius` for the search distance in meters:

```javascript
const searchQuery = {
 indexName: 'stores',
 query: searchText,
 aroundLatLng: `${userLat},${userLng}`,
 aroundRadius: 5000, // 5km radius
 filters: 'category:coffee',
 hitsPerPage: 20,
 attributesToRetrieve: ['name', 'address', 'category', '_geoloc']
};
```

One parameter worth calling out is `aroundPrecision`. By default Algolia ranks two records at exactly 1.2 km and 1.3 km apart in ranking, but for many use cases you want to group results by approximate proximity (within 500 m) and break ties using a relevance signal like rating. Setting `aroundPrecision` to 500 achieves this:

```javascript
const searchQuery = {
 indexName: 'stores',
 query: searchText,
 aroundLatLng: `${userLat},${userLng}`,
 aroundRadius: 5000,
 aroundPrecision: 500, // group by 500m buckets, then rank by customRanking
 filters: 'category:coffee',
 hitsPerPage: 20
};
```

This small addition makes a meaningful difference in result quality for category-driven searches.

## Implementing the Filtering Workflow

The real power of GeoSearch emerges when you combine it with additional filters. A practical workflow might involve finding coffee shops within 5km that are currently open and have outdoor seating. Claude Code can help you construct these compound queries:

```javascript
function buildGeoSearchQuery(params) {
 const { lat, lng, radius, category, openNow, outdoorSeating } = params;

 let filters = [];

 if (category) {
 filters.push(`category:${category}`);
 }

 if (openNow) {
 const currentHour = new Date().getHours();
 filters.push(`openHour <= ${currentHour} AND closeHour > ${currentHour}`);
 }

 if (outdoorSeating) {
 filters.push('outdoorSeating:true');
 }

 return {
 indexName: 'stores',
 aroundLatLng: `${lat},${lng}`,
 aroundRadius: radius,
 filters: filters.join(' AND '),
 hitsPerPage: 20
 };
}
```

This function demonstrates how Claude Code can guide you through building complex, multi-condition filters. The skill would explain that each filter condition uses Algolia's filter syntax, and conditions are combined with AND or OR operators.

For more complex filtering logic, you may need to group conditions with parentheses. Algolia's filter syntax supports this natively:

```javascript
// Find coffee OR tea shops that are open AND have seating
const filters = '(category:coffee OR category:tea) AND outdoorSeating:true AND openHour <= 14 AND closeHour > 14';
```

Here is a comparison of the main filter operators you will use when building GeoSearch workflows:

| Operator | Syntax Example | Use Case |
|---|---|---|
| Equality | `category:coffee` | Match a specific facet value |
| Numeric comparison | `rating >= 4` | Filter by score, price, hours |
| Boolean | `outdoorSeating:true` | Feature flags |
| AND | `A AND B` | Both conditions must match |
| OR | `A OR B` | Either condition matches |
| NOT | `NOT category:chain` | Exclude a value |
| Grouping | `(A OR B) AND C` | Complex logic grouping |
| Numeric range | `rating:3 TO 5` | Filter within a range |

## Geolocation from the Browser

Before you can run a GeoSearch query, you need the user's coordinates. The browser Geolocation API is the standard approach for client-side applications:

```javascript
function getUserLocation() {
 return new Promise((resolve, reject) => {
 if (!navigator.geolocation) {
 reject(new Error('Geolocation is not supported by your browser'));
 return;
 }

 navigator.geolocation.getCurrentPosition(
 (position) => {
 resolve({
 lat: position.coords.latitude,
 lng: position.coords.longitude,
 accuracy: position.coords.accuracy // meters
 });
 },
 (error) => {
 // Fall back to IP geolocation or a default city center
 switch (error.code) {
 case error.PERMISSION_DENIED:
 reject(new Error('Location permission denied'));
 break;
 case error.POSITION_UNAVAILABLE:
 reject(new Error('Location information unavailable'));
 break;
 case error.TIMEOUT:
 reject(new Error('Location request timed out'));
 break;
 }
 },
 {
 enableHighAccuracy: false, // faster, uses network location
 timeout: 5000,
 maximumAge: 300000 // cache location for 5 minutes
 }
 );
 });
}

// Use it in your search flow
async function searchNearMe(query, filters) {
 try {
 const { lat, lng } = await getUserLocation();
 return await runGeoSearch({ lat, lng, query, filters });
 } catch (err) {
 console.warn('Could not get location:', err.message);
 // Fall back to default location (city center, last known, etc.)
 return await runGeoSearch({ lat: DEFAULT_LAT, lng: DEFAULT_LNG, query, filters });
 }
}
```

Always plan for the permission-denied path. Users who decline location access should still be able to search, prompt them to enter a city or zip code and geocode that string to coordinates.

## Handling Results and User Experience

Once you execute the search, handling results properly is crucial for good user experience. Claude Code can guide you through parsing the response and extracting relevant information:

```javascript
function processGeoSearchResults(response, userLat, userLng) {
 return response.hits.map(hit => ({
 objectID: hit.objectID,
 name: hit.name,
 address: hit.address,
 distance: formatDistance(
 haversineDistance(userLat, userLng, hit._geoloc.lat, hit._geoloc.lng)
 ),
 category: hit.category,
 rating: hit.rating,
 isOpen: isCurrentlyOpen(hit.openHour, hit.closeHour)
 }));
}

function haversineDistance(lat1, lng1, lat2, lng2) {
 const R = 6371000; // Earth radius in meters
 const dLat = toRad(lat2 - lat1);
 const dLng = toRad(lng2 - lng1);
 const a =
 Math.sin(dLat / 2) * Math.sin(dLat / 2) +
 Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
 Math.sin(dLng / 2) * Math.sin(dLng / 2);
 const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
 return R * c;
}

function toRad(degrees) {
 return degrees * (Math.PI / 180);
}

function formatDistance(meters) {
 if (meters < 1000) {
 return `${Math.round(meters)} m`;
 }
 return `${(meters / 1000).toFixed(1)} km`;
}

function isCurrentlyOpen(openHour, closeHour) {
 const hour = new Date().getHours();
 return hour >= openHour && hour < closeHour;
}
```

The distance calculation is essential for displaying proximity information to users. Algolia returns hits sorted by geographic distance by default when using GeoSearch, but calculating the exact distance for display adds value. The haversine formula above accounts for the curvature of the Earth, giving accurate results for distances up to a few hundred kilometers.

The response object from Algolia also contains useful pagination and analytics fields you should extract:

```javascript
function extractSearchMetadata(response) {
 return {
 totalHits: response.nbHits,
 totalPages: response.nbPages,
 processingTimeMs: response.processingTimeMS,
 queryID: response.queryID, // needed for Click Analytics
 aroundLatLng: response.aroundLatLng // the center Algolia used
 };
}
```

Capturing `queryID` and sending it back with click events is how Algolia's Click Analytics and Conversion Analytics work. If you are using Algolia Insights, instrument your results like this:

```javascript
import { createInsightsMiddleware } from 'instantsearch.js/es/middlewares';
// or manually:
aa('clickedObjectIDsAfterSearch', {
 userToken: currentUserId,
 queryID: metadata.queryID,
 index: 'stores',
 objectIDs: [clickedStore.objectID],
 positions: [clickedStore.rankPosition]
});
```

## Advanced: Dynamic Radius and Multi-Location Search

As your application grows, you might need more sophisticated approaches. Dynamic radius adjustment based on result count improves user experience, when initial searches return few results, automatically expanding the radius helps users find what they need.

Claude Code can help you implement this pattern:

```javascript
async function adaptiveGeoSearch(params) {
 const { lat, lng, initialRadius, minResults = 10, maxRadius = 50000 } = params;
 let radius = initialRadius;
 let results = null;

 for (let attempt = 0; attempt < 4; attempt++) {
 const query = {
 indexName: 'stores',
 aroundLatLng: `${lat},${lng}`,
 aroundRadius: radius,
 hitsPerPage: 20
 };

 results = await index.search('', query);

 if (results.hits.length >= minResults || radius >= maxRadius) {
 break;
 }

 // Inform the UI that we are expanding
 params.onRadiusExpanded?.(radius, radius * 2);
 radius = Math.min(radius * 2, maxRadius);
 }

 return { results, usedRadius: radius };
}
```

This workflow starts with a 5km radius and doubles it until finding sufficient results or reaching a maximum of 50km.

For applications with multiple service hubs, a franchise with several distribution centers, for example, Algolia supports searching around multiple geographic points simultaneously:

```javascript
// Search around the two nearest warehouse locations
const warehouseCoords = [
 { lat: 40.7128, lng: -74.0060 },
 { lat: 40.6892, lng: -74.0445 }
];

const multiPointQuery = {
 indexName: 'drivers',
 aroundLatLng: warehouseCoords.map(c => `${c.lat},${c.lng}`).join(','),
 aroundRadius: 10000,
 hitsPerPage: 50
};
```

Combining bounding-box search with the map viewport keeps search results synchronized with what a user can see. When the user pans the map, re-run the query with updated bounds:

```javascript
function buildBoundingBoxQuery(mapBounds, textQuery = '') {
 // mapBounds: { ne: {lat, lng}, sw: {lat, lng} }
 return {
 indexName: 'stores',
 query: textQuery,
 insideBoundingBox: [
 [
 mapBounds.ne.lat,
 mapBounds.ne.lng,
 mapBounds.sw.lat,
 mapBounds.sw.lng
 ]
 ],
 hitsPerPage: 50
 };
}

// Debounce map move events to avoid flooding Algolia
import { debounce } from 'lodash-es';
const debouncedSearch = debounce(async (bounds) => {
 const results = await index.search('', buildBoundingBoxQuery(bounds));
 updateMarkers(results.hits);
}, 300);

map.on('moveend', () => debouncedSearch(map.getBounds()));
```

## Error Handling and Resilience

Production GeoSearch implementations need solid error handling. Algolia's JavaScript client throws on network failures and surfaces API errors through a structured error object:

```javascript
async function safeGeoSearch(params) {
 try {
 const results = await index.search('', buildGeoSearchQuery(params));
 return { success: true, data: results };
 } catch (error) {
 if (error.status === 400) {
 // Bad filter syntax. log for debugging, return empty results
 console.error('Algolia filter syntax error:', error.message, params);
 return { success: false, error: 'invalid_filters', data: null };
 }
 if (error.status === 403) {
 // Wrong API key. surface to developer, not end user
 console.error('Algolia authentication error. check API key');
 return { success: false, error: 'auth_error', data: null };
 }
 // Network or timeout. retry once
 try {
 const retryResults = await index.search('', buildGeoSearchQuery(params));
 return { success: true, data: retryResults };
 } catch (retryError) {
 return { success: false, error: 'network_error', data: null };
 }
 }
}
```

Rate limiting is rarely a concern for search traffic, but write operations (index updates) are subject to per-second limits. If you are batching record updates alongside your search workflow, use Algolia's `chunkedBatch` helper to stay within limits.

## Best Practices and Optimization

Claude Code skills for GeoSearch should emphasize several key optimization practices. First, always specify `attributesToRetrieve` to minimize data transfer, only fetch what you display. Second, use `aroundPrecision` to group results by approximate distance intervals, which reduces client-side processing.

The following table summarizes the most impactful configuration decisions for production GeoSearch deployments:

| Practice | Why It Matters | Implementation |
|---|---|---|
| Pin `attributesToRetrieve` | Reduces response payload by 40-70% | Set in index config or per-query |
| Use `aroundPrecision` | Better tie-breaking via custom ranking | Set to 200-1000 m depending on density |
| `filterOnly()` on numeric attrs | Keeps facets response lean | Wrap hour/price attrs in `filterOnly()` |
| Replica indices | Separate ranking per sort order | Create replicas for "sort by rating", "sort by price" |
| Debounce map moves | Cuts unnecessary API calls | 200-400 ms debounce on viewport change |
| Cache user coordinates | Avoid repeated permission prompts | Store in `sessionStorage` with 5-min TTL |
| `getRankingInfo: true` (dev only) | Debug ranking decisions | Disable in production to reduce payload |

Index performance matters significantly with GeoSearch. Ensure your `_geoloc` attribute is properly configured and consider using replica indices for different radius requirements. The trade-off between search speed and radius size should guide your implementation decisions.

For high-traffic applications, consider separating your search and write API keys. Use the search-only API key in client-side JavaScript (it is safe to expose) and restrict your admin key to server-side index management:

```javascript
// Client-side: search-only key is safe to expose
const searchClient = algoliasearch('YOUR_APP_ID', 'YOUR_SEARCH_ONLY_KEY');

// Server-side only: admin operations
const adminClient = algoliasearch('YOUR_APP_ID', process.env.ALGOLIA_ADMIN_KEY);
```

## Testing Your GeoSearch Implementation

Before shipping to production, validate your GeoSearch workflow with a set of structured test cases. Claude Code can generate these test cases for you given a description of your use case:

```javascript
import { describe, it, expect, vi } from 'vitest';

describe('buildGeoSearchQuery', () => {
 it('includes category filter when category is provided', () => {
 const query = buildGeoSearchQuery({
 lat: 40.7128, lng: -74.006,
 radius: 5000,
 category: 'coffee',
 openNow: false,
 outdoorSeating: false
 });
 expect(query.filters).toContain('category:coffee');
 });

 it('excludes openNow filter when openNow is false', () => {
 const query = buildGeoSearchQuery({
 lat: 40.7128, lng: -74.006,
 radius: 5000,
 openNow: false
 });
 expect(query.filters).not.toContain('openHour');
 });

 it('combines multiple filters with AND', () => {
 const query = buildGeoSearchQuery({
 lat: 40.7128, lng: -74.006,
 radius: 5000,
 category: 'coffee',
 outdoorSeating: true
 });
 expect(query.filters).toContain('AND');
 expect(query.filters).toContain('outdoorSeating:true');
 });

 it('respects the specified radius', () => {
 const query = buildGeoSearchQuery({
 lat: 40.7128, lng: -74.006,
 radius: 10000
 });
 expect(query.aroundRadius).toBe(10000);
 });
});

describe('adaptiveGeoSearch', () => {
 it('expands radius when results are below minimum', async () => {
 const mockSearch = vi.fn()
 .mockResolvedValueOnce({ hits: Array(3).fill({}) }) // first call: 3 results
 .mockResolvedValueOnce({ hits: Array(12).fill({}) }); // second: 12 results

 // inject mock search
 const result = await adaptiveGeoSearch(
 { lat: 40.7128, lng: -74.006, initialRadius: 2000, minResults: 10 },
 mockSearch
 );

 expect(mockSearch).toHaveBeenCalledTimes(2);
 expect(result.usedRadius).toBe(4000); // doubled from 2000
 });
});
```

## Conclusion

Building GeoSearch filtering workflows with Claude Code and Algolia combines powerful location-based search capabilities with intelligent automation. The skill-based approach ensures consistent query construction, proper error handling, and optimized results. Start with basic radius searches, then layer on faceted filters and adaptive radius logic as your requirements evolve.

The combination of Claude Code's workflow guidance and Algolia's GeoSearch creates a solid foundation for any location-aware application, from simple store finders to complex delivery logistics systems. Pay careful attention to index configuration details, particularly `aroundPrecision`, `filterOnly` attributes, and `attributesToRetrieve`, as these small decisions have outsized impact on both result quality and API cost at scale.

---

---




**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

*Last verified: April 2026. If this approach no longer works, check [Claude Code for Workspace Indexing Workflow Tutorial](/claude-code-for-workspace-indexing-workflow-tutorial/) for updated steps.*

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-algolia-geosearch-filtering-workflow-tutorial)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code Inngest Event Driven Function Workflow Tutorial](/claude-code-inngest-event-driven-function-workflow-tutorial/)
- [Claude Code for dbt Snapshot Workflow Tutorial](/claude-code-for-dbt-snapshot-workflow-tutorial/)
- [Claude Code for Next.js Middleware Workflow Tutorial](/claude-code-for-nextjs-middleware-workflow-tutorial/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Know your costs →** Use our [Claude Code Cost Calculator](/calculator/) to estimate your monthly spend.

**Configure permissions →** Build your settings with our [Permission Configurator](/permissions/).
