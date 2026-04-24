---
title: "Prisma Generate Failure After Schema"
permalink: /claude-code-prisma-generate-failure-fix-2026/
description: "Fix prisma generate failure after Claude edits schema. Run prisma format, then generate, then migrate to sync database."
last_tested: "2026-04-22"
render_with_liquid: false
---

## The Error

```
Error: Prisma schema validation error:
  Error parsing attribute "@relation": The relation field `author` on Model `Post` is missing
  an opposite relation field on the model `User`.
  → schema.prisma:24
```

This error occurs when Claude edits the Prisma schema and creates an incomplete relation — adding a field on one side without the corresponding field on the other side.

## The Fix

1. Fix the missing relation field:

```prisma
// Add the missing back-relation to User model:
model User {
  id    Int    @id @default(autoincrement())
  posts Post[] // Add this line
}

model Post {
  id       Int  @id @default(autoincrement())
  author   User @relation(fields: [authorId], references: [id])
  authorId Int
}
```

2. Format and validate the schema:

```bash
npx prisma format
npx prisma validate
```

3. Generate the client:

```bash
npx prisma generate
```

4. Create a migration if the database needs updating:

```bash
npx prisma migrate dev --name add_user_posts_relation
```

## Why This Happens

Prisma requires all relations to be defined on both sides of the relationship. Claude often adds a relation field to one model (e.g., `author User` on Post) without adding the corresponding array field (`posts Post[]` on User). This is a common oversight because the schema appears logical from one model's perspective but Prisma validates the full graph.

## If That Doesn't Work

- Reset the Prisma client completely:

```bash
rm -rf node_modules/.prisma
npx prisma generate
```

- If the migration is stuck, reset the dev database:

```bash
npx prisma migrate reset
```

- Check for conflicting field names or duplicate relations:

```bash
grep -n "@relation" prisma/schema.prisma
```

## Prevention

Add this to your `CLAUDE.md`:

```markdown
# Prisma
- Every @relation must have back-references on both models.
- After editing schema.prisma, always run: npx prisma validate
- Run npx prisma generate before running the app.
- Never manually edit migration SQL files.
```
