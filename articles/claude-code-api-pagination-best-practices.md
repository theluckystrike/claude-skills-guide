---
layout: default
title: "Claude Code API Pagination Best Practices"
description: "Learn practical pagination patterns for Claude Code API integration. Offset, cursor-based, and keyset pagination with code examples for developers."
date: 2026-03-14
categories: [tutorials]
tags: [claude-code, api, pagination, best-practices, development]
author: theluckystrike
reviewed: true
score: 7
permalink: /claude-code-api-pagination-best-practices/
---

# Claude Code API Pagination Best Practices

When building integrations with the Claude Code API, handling large datasets efficiently requires thoughtful pagination implementation. This guide covers practical pagination patterns that developers and power users can apply immediately.

## Why Pagination Matters

Working with Claude Code's API—whether you're building a custom frontend using the frontend-design skill, generating documents with the pdf skill, or processing test results from the tdd skill—you'll eventually encounter endpoints that return large collections. Without proper pagination, you risk memory issues, slow response times, and potential rate limiting.

## Understanding Pagination Strategies

### Offset-Based Pagination

The most common approach uses `limit` and `offset` parameters:

```javascript
async function listConversations(offset = 0, limit = 50) {
  const response = await fetch(
    `https://api.claude.ai/v1/conversations?offset=${offset}&limit=${limit}`,
    {
      headers: {
        'Authorization': `Bearer ${API_KEY}`
      }
    }
  );
  
  const data = await response.json();
  return {
    items: data.conversations,
    hasMore: data.conversations.length === limit,
    nextOffset: offset + limit
  };
}
```

This pattern works well for random access but becomes inefficient with large offsets. If you're processing conversation history for the supermemory skill, consider fetching in descending order with a starting timestamp instead.

### Cursor-Based Pagination

For better performance with large datasets, use cursor-based pagination:

```python
import requests

def list_messages(cursor=None, limit=100):
    url = "https://api.claude.ai/v1/messages"
    params = {"limit": limit}
    
    if cursor:
        params["cursor"] = cursor
    
    response = requests.get(
        url,
        headers={"Authorization": f"Bearer {API_KEY}"},
        params=params
    )
    
    data = response.json()
    return {
        "messages": data["messages"],
        "next_cursor": data.get("pagination", {}).get("next_cursor")
    }

# Iterate through all pages
def fetch_all_messages():
    all_messages = []
    cursor = None
    
    while True:
        result = list_messages(cursor)
        all_messages.extend(result["messages"])
        
        if not result["next_cursor"]:
            break
            
        cursor = result["next_cursor"]
    
    return all_messages
```

Cursor-based pagination is ideal when sequential access is acceptable and provides consistent performance regardless of dataset size.

### Keyset Pagination

For time-series data like conversation history, keyset pagination outperforms offset pagination:

```typescript
interface ListParams {
  limit: number;
  before?: string;  // ISO timestamp
  messageId?: string;
}

async function listConversationsKeyset(params: ListParams) {
  const queryParams = new URLSearchParams({
    limit: params.limit.toString()
  });
  
  if (params.before) {
    queryParams.append('before', params.before);
  }
  
  if (params.messageId) {
    queryParams.append('message_id', params.messageId);
  }
  
  const response = await fetch(
    `https://api.claude.ai/v1/conversations?${queryParams}`,
    {
      headers: {
        'Authorization': `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      }
    }
  );
  
  return response.json();
}

// Fetch last 30 days of conversations
async function fetchRecentConversations() {
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
  
  const conversations = [];
  let params: ListParams = { 
    limit: 100,
    before: thirtyDaysAgo.toISOString()
  };
  
  while (true) {
    const result = await listConversationsKeyset(params);
    conversations.push(...result.conversations);
    
    if (!result.has_more || !result.pagination?.next_cursor) {
      break;
    }
    
    params = {
      limit: 100,
      before: result.pagination.next_cursor
    };
  }
  
  return conversations;
}
```

## Rate Limiting Considerations

The pdf skill and document processing workflows often involve bulk operations. Implement exponential backoff when you hit rate limits:

```javascript
async function fetchWithRetry(fn, maxRetries = 3) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (error.status === 429 && attempt < maxRetries - 1) {
        const delay = Math.pow(2, attempt) * 1000;
        console.log(`Rate limited. Retrying in ${delay}ms...`);
        await new Promise(resolve => setTimeout(resolve, delay));
      } else {
        throw error;
      }
    }
  }
}
```

## Choosing the Right Strategy

Selecting the appropriate pagination method depends on your specific use case. Offset-based pagination remains the simplest implementation for applications requiring random access to data, such as a dashboard displaying conversation lists in arbitrary order. However, as your dataset grows beyond a few thousand items, performance degrades noticeably.

Cursor-based pagination solves the performance issue by using an opaque identifier that marks the last item seen. This approach ensures consistent query times regardless of position in the dataset. The trade-off is that you cannot jump to a specific page—you must traverse sequentially.

Keyset pagination using timestamps or IDs provides the best of both worlds for time-series data. You get O(1) query performance while maintaining the ability to filter by date ranges. This makes it particularly valuable for analytics applications built with the canvas-design skill that display activity over specific periods.

## Real-World Example: Building a Conversation Archive

Consider a practical scenario where you're building an archive system for Claude Code conversations. This might support the supermemory skill for长期 memory retention or enable search functionality across historical data.

```javascript
class ConversationArchiver {
  constructor(apiKey, storage) {
    this.apiKey = apiKey;
    this.storage = storage;
    this.batchSize = 100;
  }

  async archiveAllConversations() {
    let cursor = null;
    let pageCount = 0;
    const totalArchived = 0;

    do {
      const page = await this.fetchPage(cursor);
      
      await this.storage.insertBatch(page.conversations);
      totalArchived += page.conversations.length;
      pageCount++;
      
      console.log(
        `Archived page ${pageCount}: ${totalArchived} total conversations`
      );
      
      cursor = page.nextCursor;
      
      // Respect rate limits between pages
      await this.sleep(100);
      
    } while (cursor);

    return { pages: pageCount, total: totalArchived };
  }

  async fetchPage(cursor) {
    const url = new URL('https://api.claude.ai/v1/conversations');
    url.searchParams.set('limit', this.batchSize.toString());
    
    if (cursor) {
      url.searchParams.set('cursor', cursor);
    }

    const response = await fetch(url, {
      headers: {
        'Authorization': `Bearer ${this.apiKey}`
      }
    });

    if (!response.ok) {
      throw new Error(
        `API error: ${response.status} ${response.statusText}`
      );
    }

    return response.json();
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
```

This archiver class demonstrates several best practices: consistent batch sizing, progress logging, rate limit awareness, and graceful handling of pagination cursors.

## Advanced Techniques

For complex integrations involving multiple API endpoints, consider implementing a unified pagination interface that abstracts the underlying strategy. This approach allows you to switch between methods without changing consuming code.

The canvas-design skill can help visualize pagination performance across different strategies, making it easier to communicate trade-offs to stakeholders. Similarly, when documenting your API client for other developers, use the docx skill to generate clear documentation.

## Common Pitfalls

**Missing pagination**: Always check for pagination metadata in API responses. The tdd skill will help you write tests that verify pagination logic handles edge cases correctly.

**Ignoring sort order**: Ensure your queries match the expected sort order. When fetching conversation history for the supermemory skill, most use cases need reverse chronological order.

**Not handling empty pages**: A response with zero items but a valid cursor still indicates more data exists in some APIs.

**Ignoring error responses**: Network failures can occur between pages. Always wrap pagination loops in try-catch blocks and implement proper error handling.

## Testing Pagination Logic

Use the tdd skill to write comprehensive pagination tests:

```
/tdd
Write tests for a paginated API client that handles:
- Normal pagination with multiple pages
- Empty result sets
- Rate limiting with exponential backoff
- Cursor invalidation errors
- Network failures mid-iteration
```

## Production Recommendations

1. **Cache pagination state**: Store cursors in your database for interrupted fetch operations
2. **Implement parallel fetching**: For independent collections, fetch multiple pages concurrently
3. **Monitor pagination latency**: Track how long paginated requests take to identify performance issues early
4. **Use streaming when available**: For very large datasets, consider streaming approaches instead of pagination
5. **Add health checks**: Monitor for pagination that takes unusually long, indicating potential issues

## Conclusion

Proper pagination implementation ensures your Claude Code integrations remain performant and reliable. Start with cursor-based pagination for most use cases, switch to keyset pagination for time-series data, and always implement retry logic for production systems.

Built by theluckystrike — More at [zovo.one](https://zovo.one)
