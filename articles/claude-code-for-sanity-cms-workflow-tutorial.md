---
layout: default
title: "Claude Code for Sanity CMS Workflow Tutorial"
description: "Learn how to automate Sanity CMS workflows using Claude Code. This tutorial covers content migration, schema validation, batch operations, and publishing workflows with practical code examples."
date: 2026-03-15
author: Claude Skills Guide
permalink: /claude-code-for-sanity-cms-workflow-tutorial/
categories: [tutorials]
tags: [claude-code, claude-skills]
---

{% raw %}
# Claude Code for Sanity CMS Workflow Tutorial

Sanity CMS is a powerful headless CMS that offers incredible flexibility through its real-time datastore and customizable schema. However, managing content at scale—migrations, batch edits, schema validation—can become tedious without automation. This tutorial shows you how to leverage Claude Code to streamline Sanity CMS workflows, reducing manual effort and preventing errors.

## Prerequisites

Before diving in, ensure you have:

- Node.js 18+ installed
- A Sanity project (created via `npm create sanity@latest`)
- Claude Code installed (`npm install -g @anthropic-ai/claude-code`)
- Basic familiarity with the Sanity CLI

## Setting Up Your Sanity Project

First, create a new Sanity project if you haven't already:

```bash
npm create sanity@latest my-sanity-project
cd my-sanity-project
npm install
```

Initialize Claude Code in your project:

```bash
claude init
```

Create a dedicated skill for Sanity operations. Save this as `CLAUDE.md` in your project root:

```markdown
# Sanity CMS Workflow Skill

This skill helps automate Sanity CMS operations including content queries, mutations, schema validation, and migration scripts.

## Available Tools

- `bash`: Execute Sanity CLI commands
- `read_file`: Read schema files and content
- `write_file`: Generate migration scripts and schema files

## Guidelines

- Always use the Sanity client for content operations
- Validate schema changes before applying them
- Use transaction batches for bulk operations
- Log all migration operations for auditing
```

## Querying Content with Claude

One of the most common tasks is querying your Sanity content. Claude can help you construct and execute GROQ queries efficiently.

### Example: Finding Unpublished Content

Ask Claude to find all documents that haven't been published:

```
Find all 'post' documents where _updatedAt is older than 30 days and status is not 'published'
```

Claude will generate and execute the appropriate GROQ query:

```javascript
const client = require('@sanity/client')
const sanityClient = client({
  projectId: 'your-project-id',
  dataset: 'production',
  useCdn: true,
  apiVersion: '2024-01-01'
})

const query = `*[_type == "post" && !defined(publishedAt) && dateTime(_updatedAt) < dateTime(now()) - 30 * 86400]{
  _id,
  title,
  _updatedAt,
  author->name
}`

const unpublishedPosts = await sanityClient.fetch(query)
console.log(`Found ${unpublishedPosts.length} unpublished posts`)
```

## Batch Content Operations

Claude excels at automating repetitive bulk operations. Let's explore a practical scenario: updating a field across multiple documents.

### Example: Adding Categories to Posts

Suppose you need to add a default category to all posts missing one:

```javascript
const client = require('@sanity/client')

const sanityClient = client({
  projectId: 'your-project-id',
  dataset: 'production',
  useCdn: false,
  apiVersion: '2024-01-01'
})

async function addDefaultCategory() {
  // Find posts without categories
  const posts = await sanityClient.fetch(
    `*[_type == "post" && !defined(categories)]{_id, title}`
  )
  
  console.log(`Found ${posts.length} posts without categories`)
  
  // Batch update in transactions of 500
  const batchSize = 500
  for (let i = 0; i < posts.length; i += batchSize) {
    const batch = posts.slice(i, i + batchSize)
    const transaction = sanityClient.transaction()
    
    batch.forEach(post => {
      transaction.patch(post._id, {
        set: {
          categories: [{ _type: 'reference', _ref: 'default-category-id' }]
        }
      })
    })
    
    await transaction.commit()
    console.log(`Processed batch ${i / batchSize + 1}`)
  }
}

addDefaultCategory()
```

## Schema Validation Workflows

Before making schema changes in production, validate them thoroughly. Claude can help you create validation scripts.

### Example: Schema Consistency Checker

Create a script to check for inconsistent field usage across document types:

```javascript
const fs = require('fs')
const path = require('path')

function validateSchemaConsistency(schemaDir) {
  const issues = []
  const fieldUsage = {}
  
  function analyzeObject(objDef, typeName) {
    if (!objDef.fields) return
    
    objDef.fields.forEach(field => {
      const key = `${typeName}.${field.name}`
      if (!fieldUsage[field.name]) {
        fieldUsage[field.name] = []
      }
      fieldUsage[field.name].push(key)
      
      if (field.type === 'object' && field.name !== 'seo') {
        analyzeObject(field, `${typeName}.${field.name}`)
      }
    })
  }
  
  // Read and analyze schema files
  const typesDir = path.join(schemaDir, 'types')
  fs.readdirSync(typesDir).forEach(file => {
    if (file.endsWith('.js')) {
      const content = fs.readFileSync(path.join(typesDir, file), 'utf-8')
      // Extract type definitions (simplified)
      const typeMatch = content.match(/export const (\w+)\s*=/)
      if (typeMatch) {
        try {
          const schema = eval(`(${content.replace('export const', 'const')})`)
          analyzeObject(schema, typeMatch[1])
        } catch (e) {
          // Skip parsing errors
        }
      }
    }
  })
  
  // Report inconsistencies
  Object.entries(fieldUsage).forEach(([field, usages]) => {
    if (usages.length > 1 && usages.length < 5) {
      issues.push(`Field '${field}' used inconsistently: ${usages.join(', ')}`)
    }
  })
  
  return issues
}

const issues = validateSchemaConsistency('./schema')
if (issues.length > 0) {
  console.log('Schema issues found:')
  issues.forEach(issue => console.log(`  - ${issue}`))
} else {
  console.log('Schema validation passed!')
}
```

## Migration Workflows

When your schema evolves, content migrations become essential. Claude can help generate migration scripts.

### Example: Renaming a Field

Here's a migration script to rename a field across all documents:

```javascript
const client = require('@sanity/client')

const sanityClient = client({
  projectId: 'your-project-id',
  dataset: 'production',
  useCdn: false,
  apiVersion: '2024-01-01'
})

async function migrateFieldRename() {
  const oldField = 'summary'
  const newField = 'excerpt'
  
  // First, find all documents with the old field
  const docs = await sanityClient.fetch(
    `*[_type in ["post", "page"] && defined(${oldField})]{_id, ${oldField}}`
  )
  
  console.log(`Found ${docs.length} documents to migrate`)
  
  // Perform the migration in batches
  const batchSize = 100
  for (let i = 0; i < docs.length; i += batchSize) {
    const batch = docs.slice(i, i + batchSize)
    const transaction = sanityClient.transaction()
    
    batch.forEach(doc => {
      // Set new field and unset old field
      transaction.patch(doc._id, {
        set: { [newField]: doc[oldField] },
        unset: [oldField]
      })
    })
    
    await transaction.commit()
    console.log(`Migrated batch ${Math.floor(i / batchSize) + 1}`)
  }
  
  console.log('Migration complete!')
}

migrateFieldRename()
```

## Publishing Workflows

Automate your publishing pipeline with Claude by creating scripts that handle draft-to-published transitions.

### Example: Scheduled Publishing

Set up automated publishing based on a `publishAt` timestamp:

```javascript
const client = require('@sanity/client')

const sanityClient = client({
  projectId: 'your-project-id',
  dataset: 'production',
  useCdn: false,
  apiVersion: '2024-01-01'
})

async function processScheduledPublishing() {
  const now = new Date().toISOString()
  
  // Find documents ready to publish
  const toPublish = await sanityClient.fetch(
    `*[_type == "post" && publishAt <= $now && !(_id in path("drafts.**"))]{
      _id,
      title,
      publishAt
    }`,
    { now }
  )
  
  console.log(`Found ${toPublish.length} documents to publish`)
  
  for (const doc of toPublish) {
    await sanityClient
      .patch(doc._id)
      .set({ status: 'published' })
      .commit()
    
    console.log(`Published: ${doc.title}`)
  }
}

// Run as a scheduled job (e.g., every minute via cron)
setInterval(processScheduledPublishing, 60000)
```

## Best Practices for Sanity Automation

When automating Sanity workflows with Claude, keep these tips in mind:

1. **Always use transactions**: Group related mutations into transactions for atomicity and performance
2. **Implement retry logic**: Network issues happen; wrap API calls with retry mechanisms
3. **Log everything**: Maintain audit trails for all automated operations
4. **Test in staging**: Never run migration scripts against production without testing
5. **Use projections wisely**: Request only needed fields to reduce payload size

## Conclusion

Claude Code transforms Sanity CMS management from manual drudgery into efficient, automated workflows. By combining Claude's natural language processing with Sanity's powerful API, you can query content, perform batch operations, validate schemas, and execute migrations with minimal effort. Start small—automate one repetitive task—and gradually expand your automation library.

The key is treating your CMS operations as code: version-controlled, tested, and reproducible. With these patterns, you'll spend less time on maintenance and more time building great content experiences.
{% endraw %}
