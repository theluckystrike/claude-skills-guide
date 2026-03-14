---
layout: default
title: "Claude Code TypeORM Entities Relations Migration Workflow"
description: "A comprehensive guide to building TypeORM entities, defining relationships, and managing database migrations using Claude Code skills."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-typeorm-entities-relations-migration-workflow/
categories: [workflows, databases]
tags: [claude-code, claude-skills]
---

{% raw %}
# Claude Code TypeORM Entities Relations Migration Workflow

Building robust database layers with TypeORM requires careful attention to entity design, relationship mapping, and migration management. This guide walks you through a practical workflow using Claude Code to accelerate TypeORM development while maintaining code quality and database integrity.

## Setting Up Your TypeORM Project

Before diving into entities, ensure your TypeORM project is properly configured. Claude Code can help scaffold the initial setup quickly:

```typescript
import { DataSource } from "typeorm";
import { User } from "./entities/User";
import { Product } from "./entities/Product";
import { Order } from "./entities/Order";

export const AppDataSource = new DataSource({
  type: "postgres",
  host: "localhost",
  port: 5432,
  username: "your_username",
  password: "your_password",
  database: "your_database",
  entities: [User, Product, Order],
  migrations: ["src/migrations/*.ts"],
  synchronize: false,
});
```

Always set `synchronize: false` in production environments. Relying on automatic synchronization can lead to unintended schema changes and data loss.

## Creating TypeORM Entities

Entities are the foundation of your database layer. Each entity maps to a database table, and properties map to columns. Here's a well-structured User entity:

```typescript
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from "typeorm";
import { Order } from "./Order";

@Entity()
export class User {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  passwordHash: string;

  @Column({ nullable: true })
  firstName: string;

  @Column({ nullable: true })
  lastName: string;

  @Column({ default: false })
  isActive: boolean;

  @OneToMany(() => Order, (order) => order.user)
  orders: Order[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

Notice the use of `PrimaryGeneratedColumn("uuid")` for secure, unique identifiers. Always prefer UUIDs over sequential IDs for user-facing records.

## Defining Entity Relationships

TypeORM supports multiple relationship types: OneToOne, OneToMany, ManyToMany, and ManyToOne. Understanding when to use each is crucial for maintaining data integrity.

### One-to-Many Relationship

A User can have multiple Orders:

```typescript
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from "typeorm";
import { User } from "./User";

@Entity()
export class Order {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column()
  totalAmount: number;

  @Column({ default: "pending" })
  status: string;

  @ManyToOne(() => User, (user) => user.orders)
  @JoinColumn({ name: "userId" })
  user: User;

  @Column()
  userId: string;
}
```

The `@JoinColumn` decorator specifies which column represents the foreign key. Always include the foreign key column explicitly for clarity.

### Many-to-Many Relationship

Products can belong to multiple Categories:

```typescript
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToMany,
  JoinTable,
} from "typeorm";
import { Category } from "./Category";

@Entity()
export class Product {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column()
  name: string;

  @Column("decimal", { precision: 10, scale: 2 })
  price: number;

  @ManyToMany(() => Category, (category) => category.products)
  @JoinTable({
    name: "product_categories",
    joinColumn: { name: "productId", referencedColumnName: "id" },
    inverseJoinColumn: { name: "categoryId", referencedColumnName: "id" },
  })
  categories: Category[];
}
```

Use `@JoinTable` only on the owning side of the relationship. The inverse side simply references the entity without additional decorators.

### Handling Cascade Deletes

Cascade operations determine what happens to related entities when the parent is deleted:

```typescript
@OneToMany(() => Order, (order) => order.user, { onDelete: "CASCADE" })
orders: Order[];
```

Be cautious with `onDelete: "CASCADE"`. While convenient, it can lead to accidental data loss. Consider using soft deletes instead:

```typescript
@Column({ default: false })
isDeleted: boolean;

@OneToMany(() => Order, (order) => order.user)
@Where("isDeleted = :isDeleted", { isDeleted: false })
orders: Order[];
```

## Generating and Running Migrations

Never modify your schema directly in production. Instead, use migrations to track all changes:

### Creating Migrations

```bash
typeorm migration:create src/migrations/UserEntity
```

This generates a migration file where you define up and down methods:

```typescript
import { MigrationInterface, QueryRunner, Table } from "typeorm";

export class UserEntity1700000000000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: "user",
        columns: [
          {
            name: "id",
            type: "uuid",
            isPrimary: true,
          },
          {
            name: "email",
            type: "varchar",
            isUnique: true,
          },
          {
            name: "passwordHash",
            type: "varchar",
          },
          {
            name: "isActive",
            type: "boolean",
            default: false,
          },
          {
            name: "createdAt",
            type: "timestamp",
            default: "now()",
          },
          {
            name: "updatedAt",
            type: "timestamp",
            default: "now()",
          },
        ],
      }),
      true
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable("user");
  }
}
```

### Running Migrations

Apply migrations to your database:

```bash
typeorm migration:run
```

Revert the last migration if needed:

```bash
typeorm migration:revert
```

## Best Practices for TypeORM Development

Follow these guidelines for maintainable TypeORM code:

1. **Use explicit column types** - Don't rely on TypeORM's type inference for production databases
2. **Add indexes frequently** - Query performance matters; add indexes on foreign keys and frequently queried columns
3. **Version your migrations** - Never modify existing migrations; create new ones for changes
4. **Use transactions** - Wrap multiple related operations in transactions to maintain data consistency
5. **Separate concerns** - Keep entities lean; use separate service classes for business logic

## Conclusion

A solid TypeORM workflow combines proper entity design, clear relationship definitions, and disciplined migration management. Claude Code can help you generate entities, write migrations, and maintain consistency across your database layer. By following these patterns, you'll build database code that's reliable, maintainable, and scalable.

Remember: your database schema is the foundation of your application. Invest time in proper design, use migrations for all changes, and your future self will thank you.
{% endraw %}
