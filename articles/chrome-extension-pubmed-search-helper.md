---
layout: default
title: "Chrome Extension PubMed Search Helper: Build Your Own Research Tool"
description: "Learn how to build a Chrome extension that enhances PubMed search with custom filters, quick access to saved searches, and automated citation formatting for researchers and developers."
date: 2026-03-15
author: theluckystrike
categories: [development, chrome-extension]
tags: [chrome-extension, pubmed, research-tools, browser-extension]
permalink: /chrome-extension-pubmed-search-helper/
---

# Chrome Extension PubMed Search Helper: Build Your Own Research Tool

PubMed remains the primary research database for biomedical literature, but its interface can feel dated and cumbersome for power users managing multiple searches. Building a Chrome extension to enhance PubMed search functionality gives you complete control over your research workflow. This guide walks through creating a practical PubMed search helper extension from scratch.

## Why Build a PubMed Search Helper

The default PubMed interface requires repeated navigation through filters, manual entry of search terms, and separate steps to access saved searches. A custom Chrome extension can consolidate these operations into a single popup or side panel. Researchers who conduct literature reviews across multiple sessions particularly benefit from automation that preserves search history and provides one-click access to frequently used queries.

The PubMed E-utilities API provides programmatic access to search results, citations, and metadata. This API serves as the backend for any extension that fetches data beyond what the web interface displays.

## Extension Architecture Overview

A Chrome extension for PubMed search assistance typically consists of three components:

1. **Manifest file** — Defines permissions, browser action, and extension metadata
2. **Popup or side panel** — Provides the user interface for search input and results
3. **Background script** — Handles API calls and long-running tasks

The manifest version 3 format represents the current standard. Here is a minimal manifest configuration:

```json
{
  "manifest_version": 3,
  "name": "PubMed Search Helper",
  "version": "1.0",
  "description": "Enhanced PubMed search with custom filters and saved queries",
  "permissions": ["storage", "activeTab"],
  "host_permissions": ["https://eutils.ncbi.nlm.nih.gov/*"],
  "action": {
    "default_popup": "popup.html",
    "default_icon": "icon.png"
  }
}
```

The `host_permissions` field grants the extension access to the PubMed E-utilities API domain. The `storage` permission enables persisting saved searches across browser sessions.

## Building the Search Interface

The popup HTML provides the primary interaction point. A clean interface includes a search input field, filter options, and a results container:

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 320px; padding: 12px; font-family: system-ui; }
    .search-box { width: 100%; padding: 8px; margin-bottom: 8px; }
    .filters { display: flex; gap: 8px; margin-bottom: 12px; }
    .filter-btn { flex: 1; padding: 6px; cursor: pointer; }
    .filter-btn.active { background: #0066cc; color: white; }
    #results { max-height: 300px; overflow-y: auto; }
    .result-item { padding: 8px; border-bottom: 1px solid #eee; }
  </style>
</head>
<body>
  <input type="text" id="searchInput" class="search-box" placeholder="Search PubMed...">
  <div class="filters">
    <button class="filter-btn active" data-filter="all">All</button>
    <button class="filter-btn" data-filter="review">Reviews</button>
    <button class="filter-btn" data-filter="clinical">Clinical</button>
  </div>
  <div id="results"></div>
  <script src="popup.js"></script>
</body>
</html>
```

The filter buttons apply pre-configured search modifiers. PubMed supports specialized filters like `[review]` for review articles and `[clinicaltrials]` for clinical trial publications.

## Implementing the Search Logic

The popup JavaScript handles user interactions and communicates with the PubMed API. The E-search endpoint returns PMIDs matching your query:

```javascript
document.getElementById('searchInput').addEventListener('keypress', async (e) => {
  if (e.key === 'Enter') {
    const query = e.target.value;
    const activeFilter = document.querySelector('.filter-btn.active').dataset.filter;
    const modifiedQuery = applyFilter(query, activeFilter);
    const pmids = await searchPubMed(modifiedQuery);
    displayResults(pmids);
  }
});

function applyFilter(query, filter) {
  if (filter === 'review') return `${query} AND review[pt]`;
  if (filter === 'clinical') return `${query} AND clinical trial[pt]`;
  return query;
}

async function searchPubMed(query) {
  const baseUrl = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi';
  const params = new URLSearchParams({
    db: 'pubmed',
    term: query,
    retmode: 'json',
    retmax: '20',
    sort: 'relevance'
  });
  
  const response = await fetch(`${baseUrl}?${params}`);
  const data = await response.json();
  return data.esearchresult?.idlist || [];
}
```

The `esearch.fcgi` endpoint returns PMIDs (PubMed IDs) as an array. Each PMID can then fetch detailed article information through the `esummary` or `efetch` endpoints.

## Adding Citation Formatting

One of the most useful features for researchers is automatic citation generation. The extension can format citations in multiple styles:

```javascript
async function fetchArticleDetails(pmid) {
  const url = `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=${pmid}&retmode=json`;
  const response = await fetch(url);
  const data = await response.json();
  return data.result[pmid];
}

function formatCitation(article, style = 'apa') {
  const { title, authors, source, pubdate } = article;
  const authorList = authors?.author?.map(a => a.name).join(', ') || 'Unknown';
  
  if (style === 'apa') {
    return `${authorList} (${pubdate}). ${title}. ${source}.`;
  }
  if (style === 'bibtex') {
    const key = authors?.author?.[0]?.name?.split(' ').pop() || 'unknown';
    return `@article{${key}${pubdate?.split(' ')[0]},
  author = {${authorList}},
  title = {${title}},
  journal = {${source}},
  year = {${pubdate?.split(' ')[0]}}
}`;
  }
  return `${authorList}. ${title}. ${source}. ${pubdate}`;
}
```

Storing the selected citation style in Chrome storage ensures the preference persists:

```javascript
chrome.storage.sync.set({ citationStyle: 'apa' });
chrome.storage.sync.get(['citationStyle'], (result) => {
  const style = result.citationStyle || 'apa';
  // Apply style to citations
});
```

## Saving Searches for Quick Access

The storage permission enables saving frequent searches. This approach works well for literature reviews that require recurring queries:

```javascript
function saveSearch(query, label) {
  chrome.storage.sync.get(['savedSearches'], (result) => {
    const searches = result.savedSearches || [];
    searches.push({ query, label, date: new Date().toISOString() });
    chrome.storage.sync.set({ savedSearches: searches });
  });
}

function loadSavedSearches() {
  chrome.storage.sync.get(['savedSearches'], (result) => {
    const container = document.getElementById('savedSearches');
    (result.savedSearches || []).forEach(search => {
      const btn = document.createElement('button');
      btn.textContent = search.label;
      btn.onclick = () => {
        document.getElementById('searchInput').value = search.query;
        document.getElementById('searchInput').dispatchEvent(new KeyboardEvent('keypress', { key: 'Enter' }));
      };
      container.appendChild(btn);
    });
  });
}
```

## Loading Saved Searches on Startup

Initialize the saved searches when the popup opens:

```javascript
document.addEventListener('DOMContentLoaded', () => {
  loadSavedSearches();
  setupFilterButtons();
});
```

## Extension Deployment

Once development completes, package the extension through Chrome's developer dashboard or load it locally for testing:

1. Navigate to `chrome://extensions/`
2. Enable Developer mode (toggle in top right)
3. Click Pack extension and select your extension directory
4. Note the generated `.crx` file for distribution

For testing without packaging, use the Load unpacked option to select your extension directory directly.

## Extending the Extension

Several enhancements expand the utility further:

- **Abstract fetching** — Retrieve and display article abstracts directly in results
- **Citation export** — Export selected citations to BibTeX or RIS format for reference managers
- **Search history** — Track and visualize search patterns over time
- **Keyboard shortcuts** — Bind global shortcuts for quick popup access

The PubMed E-utilities API supports additional endpoints for fetching full records, checking citation counts, and accessing related articles. These features transform a basic search helper into a comprehensive research tool.

---

*Built by theluckystrike — More at [zovo.one](https://zovo.one)*
