---

layout: default
title: "Claude Code for GraphQL Federation Workflow Guide"
description: "Learn how to use Claude Code to streamline GraphQL Federation development, from schema design to subgraph configuration and federated query testing."
date: 2026-03-15
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-for-graphql-federation-workflow-guide/
reviewed: true
score: 7
geo_optimized: true
---

GraphQL Federation allows you to compose multiple GraphQL services into a unified supergraph, enabling teams to build independent services that expose a smooth API. However, managing federated schemas, coordinating between subgraphs, and debugging federated queries can quickly become complex. This guide shows you how to use Claude Code to automate and accelerate your GraphQL Federation workflow. from initial schema design through to production debugging.

## Why Federation Development Gets Complicated

GraphQL Federation is powerful precisely because it distributes schema ownership across teams. But distributed ownership introduces coordination problems that compound as your graph grows. The `@key`, `@external`, `@requires`, and `@provides` directives need to be applied consistently across multiple repositories. A field added in one subgraph may break composition in another. Entity reference resolution depends on correct type definitions in both the defining and consuming service.

Teams typically encounter the same problems repeatedly: composition errors with cryptic messages, confusion about which subgraph owns an entity field, and difficulty constructing queries that test cross-service resolution paths. Claude Code can help at each of these friction points by serving as a knowledgeable collaborator who understands your schema structure and can reason about federation-specific patterns.

## Setting Up Claude Code for GraphQL Projects

Before diving into federation-specific workflows, ensure Claude Code has the right context for your GraphQL project. Create a skill that understands your federation setup:

```yaml
---
name: graphql-federation
description: "Assists with GraphQL Federation development workflows"
---

GraphQL Federation Development Assistant

You help with:
- Designing federated schemas and entity definitions
- Configuring Apollo Federation subgraph schemas
- Writing and testing federated queries
- Resolving schema composition errors
- Generating TypeScript types from federated schemas
```

Store this skill in your `.claude/skills/` directory and invoke it with `/graphql-federation` when working on federation tasks.

A more detailed skill context pays dividends when debugging composition errors. Include specifics about your graph:

```yaml
---
name: graphql-federation
description: "Assists with GraphQL Federation development for the commerce platform"
---

Commerce Platform Federation Assistant

Our Subgraphs
- users (port 4001): Authentication, user profiles, addresses
- products (port 4002): Product catalog, categories, pricing
- orders (port 4003): Order processing, fulfillment status
- inventory (port 4004): Stock levels, warehouse locations

Entity Ownership
- User entity owned by: users subgraph
- Product entity owned by: products subgraph
- Order entity owned by: orders subgraph

Federation Version
We use Apollo Federation 2.x with the @apollo/subgraph package.

Key Directives in Use
- @key for entity primary keys
- @shareable for fields defined in multiple subgraphs
- @requires for computed fields needing data from another subgraph
- @override for migrating field ownership between subgraphs
```

The extra specificity means Claude can give you answers calibrated to your actual setup rather than generic federation guidance.

## Designing Federated Schemas with Claude

One of the most valuable workflows is using Claude to design federated schemas. When defining entities that span multiple subgraphs, clarity is essential. Describe your domain requirements, and Claude can generate proper entity definitions with the `@key` directive:

```
Create a federated Product entity for an e-commerce platform. Products should have:
- id (unique identifier)
- name (String)
- price (Float)
- sku (external reference from inventory service)
- reviews (reference to review subgraph)
```

Claude will generate the appropriate schema:

```graphql
extend type Product @key(fields: "id") {
 id: ID! @external
 name: String!
 price: Float!
 sku: String! @external
 reviews: [Review!]!
}
```

The `@external` directive marks fields provided by another subgraph, while `@key` defines the primary entity identifier that enables reference resolution across services.

## Designing Entity Relationships Across Subgraphs

A more nuanced pattern involves entities that need fields from sibling subgraphs to compute their own fields. The `@requires` directive handles this, but the setup is easy to get wrong. Here is a concrete example: the orders service needs the product's weight to calculate shipping cost.

Ask Claude:

```
The orders service needs to calculate shipping cost using product weight.
Product weight lives in the products subgraph. How should I model this with
@requires and @external in Federation 2?
```

Claude generates both sides of the relationship:

```graphql
In products subgraph
type Product @key(fields: "id") {
 id: ID!
 name: String!
 price: Float!
 weight: Float! # defined and owned here
}
```

```graphql
In orders subgraph
type Product @key(fields: "id") {
 id: ID! @external
 weight: Float! @external # referenced from products subgraph
}

type OrderItem {
 product: Product!
 quantity: Int!
 shippingCost: Float! @requires(fields: "product { weight }")
}

type OrderItemResolver {
 shippingCost(orderItem: OrderItem): Float
 # resolver receives product.weight via query plan
}
```

This pattern frequently causes composition errors when the `@external` declaration in the consuming subgraph doesn't exactly match the type in the owning subgraph. Claude can check both schemas simultaneously and flag discrepancies before you push.

## Automating Subgraph Configuration

Each subgraph in your federation needs its own schema with federation-specific directives. Claude can generate these configurations automatically based on your service structure. Here's a typical workflow:

First, provide Claude with your service architecture:

```
Our architecture:
- Users service: handles user profiles, authentication
- Products service: handles product catalog, pricing
- Orders service: handles order processing, history
- Inventory service: handles stock levels
```

Claude can then generate a comprehensive federation configuration:

```yaml
federation-config.yaml
services:
 users:
 schema: ./schemas/users.graphql
 url: http://localhost:4001/graphql
 subgraph: true

 products:
 schema: ./schemas/products.graphql
 url: http://localhost:4002/graphql
 subgraph: true

 orders:
 schema: ./schemas/orders.graphql
 url: http://localhost:4003/graphql
 subgraph: true

 inventory:
 schema: ./schemas/inventory.graphql
 url: http://localhost:4004/graphql
 subgraph: true
```

## Rover CLI Configuration

The Apollo Rover CLI is the standard tool for managing federated schemas. Claude can help you set up your `rover.yaml` and automate common operations:

```yaml
rover.yaml
federation_version: =2.4.0
```

```bash
Publish a subgraph schema to Apollo Studio
rover subgraph publish my-graph@production \
 --name products \
 --schema ./schemas/products.graphql \
 --routing-url https://products.example.com/graphql

Check composition locally before publishing
rover subgraph check my-graph@production \
 --name products \
 --schema ./schemas/products.graphql

Fetch the composed supergraph schema
rover supergraph fetch my-graph@production > supergraph.graphql
```

Ask Claude to generate a Makefile that wraps these operations:

```
Create a Makefile for managing our federation subgraph schemas. I need targets
for checking, publishing, and fetching schemas for each of our four subgraphs.
```

Claude generates reusable targets with proper error handling and environment variable support, saving the Rover command boilerplate from living in scattered shell scripts.

## Resolving Composition Errors

Schema composition failures are common in federated development. When your gateway fails to compose, Claude can analyze the errors and suggest fixes. Share the composition error output and ask:

```
Fix these composition errors:
- Product.sku is marked @external but is not used by any other subgraph
- Order.product references Product but doesn't satisfy @key requirement
- User.email is defined in two subgraphs with different @shareable settings
```

Claude will explain each issue and provide corrected schema snippets. For the `@shareable` error, it might suggest:

```graphql
In users subgraph - mark as shareable if needed in multiple services
extend type User @key(fields: "id") {
 id: ID! @external
 email: String! @shareable
}
```

## Common Composition Error Patterns

Understanding which errors indicate which underlying problems saves significant debugging time:

| Error Message | Root Cause | Fix |
|---------------|------------|-----|
| `Field X is not resolvable across subgraphs` | Entity @key not declared in all subgraphs referencing the type | Add `@key` stub in consuming subgraph |
| `Field X is marked @external but is not used` | @requires or @provides referencing the field was removed | Remove the orphaned @external declaration |
| `Type X is defined in multiple subgraphs without @shareable` | Two subgraphs define the same field on a value type | Add @shareable to both definitions or consolidate to one subgraph |
| `@key directive missing required field` | @key references a compound key but one field is not defined | Add the missing field to the key definition |
| `Invalid use of @override` | Trying to override a field that doesn't exist in the other subgraph | Check the subgraph name in @override matches exactly |

Paste any of these errors into Claude with your schema context and it can pinpoint the exact lines that need changing.

## Testing Federated Queries

Once your schema composes successfully, test federated queries across subgraphs. Claude can help construct queries that exercise multiple services:

```
Write a federated query that:
- Fetches user profile with their recent orders
- Each order should include product name and price
- Include the current stock level from inventory
- Filter orders to only show those from the last 30 days
```

Claude generates the federated query:

```graphql
query GetUserWithRecentOrders($userId: ID!, $since: DateTime!) {
 user(id: $userId) {
 id
 name
 email
 orders(where: { createdAt: { gte: $since } }) {
 id
 status
 total
 items {
 product {
 id
 name
 price
 inventory {
 stockLevel
 }
 }
 }
 }
 }
}
```

## Writing Query Plan Tests

Beyond constructing queries, you can ask Claude to write tests that verify the federation query planner routes correctly. Using Apollo Gateway's `buildQueryPlan` API:

```typescript
import { buildQueryPlan, buildOperationContext } from '@apollo/gateway';
import { parse } from 'graphql';

describe('User order query plan', () => {
 it('fetches user from users subgraph and orders from orders subgraph', async () => {
 const query = parse(`
 query GetUser($id: ID!) {
 user(id: $id) {
 name
 orders {
 total
 }
 }
 }
 `);

 const queryPlan = buildQueryPlan(
 buildOperationContext({ schema: supergraph, document: query })
 );

 // Verify users subgraph is queried first
 expect(queryPlan.node.nodes[0].serviceName).toBe('users');
 // Verify orders subgraph is queried with user id for entity resolution
 expect(queryPlan.node.nodes[1].serviceName).toBe('orders');
 });
});
```

Ask Claude to generate a full suite of query plan tests for your critical paths. This is especially valuable before you migrate field ownership between subgraphs. tests catch cases where the query plan changes in unexpected ways.

## Integration Testing with Subgraph Mocking

End-to-end federation tests that spin up all four services are slow and brittle. Claude can help you write integration tests that mock individual subgraphs while letting others run real:

```typescript
import { ApolloServer } from '@apollo/server';
import { buildSubgraphSchema } from '@apollo/subgraph';

// Mock the inventory subgraph for tests that don't touch stock levels
const mockInventorySubgraph = new ApolloServer({
 schema: buildSubgraphSchema([{
 typeDefs: inventoryTypeDefs,
 resolvers: {
 Product: {
 __resolveReference(ref: { id: string }) {
 return { id: ref.id, stockLevel: 100 }; // always in stock in tests
 }
 }
 }
 }])
});
```

This pattern isolates test failures to the subgraph under test rather than requiring all services to be healthy.

## Generating TypeScript Types

Maintain type safety across your federated application by generating TypeScript types from your composed schema. Claude can create a script that uses the Apollo CLI:

```bash
#!/bin/bash
generate-federated-types.sh

APOLLO_GRAPH_REF=my-graph@variant
SCHEMA_PATH=./schema.graphql

apollo service:download --graphid $APOLLO_GRAPH_REF $SCHEMA_PATH

npx @apollo/federation-types generate \
 --graph Schema:$SCHEMA_PATH \
 --output ./src/types/federated.ts
```

Run this script after any schema changes to keep your client types in sync. Claude can also help you set up a pre-commit hook that validates schema changes don't break composition.

## GraphQL Code Generator Setup

The `graphql-code-generator` ecosystem has first-class support for federation. Claude can configure the codegen setup across all your subgraphs:

```yaml
codegen.yml (in the products subgraph)
overwrite: true
schema: "http://localhost:4002/graphql"
generates:
 src/generated/types.ts:
 plugins:
 - "typescript"
 - "typescript-resolvers"
 config:
 federation: true
 mappers:
 Product: "../models#ProductModel"
 contextType: "../context#Context"
```

Ask Claude to generate the full codegen configuration for all four subgraphs in your project, and it will produce consistent configurations with appropriate mappers for each service's domain model.

## Debugging Federation in Production

When a federated query fails in production, diagnosing whether the problem is in the gateway, a specific subgraph, or the query plan itself requires a systematic approach. Claude can help structure your debugging workflow.

Start by isolating the subgraph. If a query touching three services fails, test each subgraph's resolver independently with a direct query (bypassing the gateway). Then check whether the gateway's query plan for the failing operation matches your expectations.

Apollo Studio's trace view is invaluable here, but you can also enable trace logging in the gateway:

```typescript
const gateway = new ApolloGateway({
 serviceList: [...],
 experimental_pollIntervalInMs: 5000,
 buildService({ name, url }) {
 return new RemoteGraphQLDataSource({
 url,
 willSendRequest({ request, context }) {
 // Pass trace context to subgraphs
 request.http?.headers.set(
 'x-trace-id',
 context.traceId
 );
 }
 });
 }
});
```

Paste your trace output or gateway logs to Claude and ask it to identify where in the query plan the failure occurs. Claude can read the structured trace data and tell you which subgraph call failed and what the entity reference looked like at that point.

## Best Practices for Federation Workflows

Follow these practices to maintain a healthy federated architecture:

Define clear ownership boundaries: Each subgraph should have a single team responsible for its schema. Use the `@tag` directive to mark fields as internal or experimental before promoting them to stable.

Version your subgraphs carefully: When making breaking changes, introduce new fields rather than removing existing ones. Use deprecation marks and communicate changes through your federation's changelog.

Test composition locally: Run `rover subgraph check` before pushing schema changes to catch composition errors early. Integrate this check into your CI pipeline.

Document entity relationships: Maintain a living diagram of how entities reference each other across subgraphs. This helps new team members understand the data graph architecture.

Validate before publish: Set up a CI job that runs `rover supergraph compose` against your local schema changes before any subgraph publish reaches production. A failing composition in CI is far less painful than a failing gateway in production.

Use @override for migrations: When moving a field from one subgraph to another, use `@override` to manage the transition period rather than trying to do it atomically. The progressive migration path gives you time to verify the new resolver before removing the old one.

## Conclusion

Claude Code transforms GraphQL Federation development from manual schema coordination into an assisted workflow. By defining federation-specific skills, you get intelligent help with schema design, configuration, debugging, and testing. Start by creating a GraphQL Federation skill tailored to your architecture, and watch your development velocity increase as Claude handles the boilerplate and helps troubleshoot complex composition issues. The biggest gains come from schema design reviews before changes are published, and from composition error diagnosis. both tasks where having an assistant that can read multiple schema files simultaneously and reason about their relationships saves substantial time.

---

---

<div class="mastery-cta">

I'm a solo developer in Vietnam. 50K Chrome extension users. $500K+ on Upwork. 5 Claude Max subscriptions running agent fleets in parallel.

These are my actual CLAUDE.md templates, orchestration configs, and prompts. Not a course. Not theory. The files I copy into every project before I write a line of code.

**[See what's inside →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-default&utm_campaign=claude-code-for-graphql-federation-workflow-guide)**

$99 once. Free forever. 47/500 founding spots left.

</div>

Related Reading

- [Claude Code for GraphQL Code Generation Workflow](/claude-code-for-graphql-code-generation-workflow/)
- [Claude Code for GraphQL Codegen Workflow Tutorial](/claude-code-for-graphql-codegen-workflow-tutorial/)
- [Claude Code for GraphQL Complexity Workflow Guide](/claude-code-for-graphql-complexity-workflow-guide/)
- [Claude Code for Prometheus Federation Workflow Guide](/claude-code-for-prometheus-federation-workflow-guide/)
- [Claude Code for Webpack Federation Workflow Guide](/claude-code-for-webpack-federation-workflow-guide/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


