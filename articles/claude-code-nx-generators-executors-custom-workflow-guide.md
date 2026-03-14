---

layout: default
title: "Claude Code Nx Generators Executors Custom Workflow Guide"
description: "A comprehensive guide to building custom workflows with Nx generators and executors using Claude Code. Learn how to automate your development workflow efficiently."
date: 2026-03-14
author: Claude Skills Guide
permalink: /claude-code-nx-generators-executors-custom-workflow-guide/
categories: [guides]
tags: [claude-code, claude-skills]
---

{% raw %}
# Claude Code Nx Generators Executors Custom Workflow Guide

Nx is a powerful build system and monorepo management tool that has become essential for modern JavaScript and TypeScript development. When combined with Claude Code, Nx's generators and executors become even more powerful, enabling you to create sophisticated custom workflows that automate repetitive tasks and enforce best practices across your projects.

This guide walks you through building custom Nx workflows with Claude Code, providing practical examples and actionable advice you can start using immediately.

## Understanding Nx Generators and Executors

Before diving into custom workflows, let's clarify what generators and executors do in the Nx ecosystem.

### What Are Nx Generators?

Nx generators are code generators that scaffold new components, applications, libraries, and other project structures. They follow the convention of `@nx/plugin:generator` and can create:

- New applications and libraries
- Component templates
- Configuration files
- Entire feature modules

Generators are essential for maintaining consistency across your monorepo. Instead of manually creating files, you run a generator and get a standardized, best-practice implementation.

### What Are Nx Executors?

Executors are the runtime engines that run your tasks. While generators create code, executors perform actions like:

- Building applications (`@nx/js:tsc`, `@nx/vite:build`)
- Running tests (`@nx/jest:jest`, `@nx/vite:test`)
- Linting code (`@nx/eslint:lint`)
- Deploying applications

Executors consume options defined in your `project.json` files and execute the actual work.

## Setting Up Your Nx Project with Claude Code

Let's start by setting up an Nx project where you can implement custom generators and executors.

### Initialize Your Workspace

```bash
# Create a new Nx workspace
npx create-nx-workspace@latest my-workspace \
  --preset=apps \
  --packageManager=npm

# Navigate to the workspace
cd my-workspace
```

### Install Required Dependencies

```bash
# Install Nx plugin for creating custom generators
npm install --save-dev @nx/plugin

# Create the plugin
npx nx g @nx/plugin:plugin my-plugin \
  --directory=packages/my-plugin
```

## Creating Custom Generators

Custom generators allow you to define reusable scaffolding patterns specific to your organization's needs.

### Generator Structure

A custom generator follows this structure:

```
my-plugin/
├── generators/
│   └── my-generator/
│       ├── schema.d.ts
│       ├── schema.json
│       └── index.ts
├── executors/
└── package.json
```

### Implementing a Custom Generator

Create a generator that scaffolds a feature with all necessary files:

```typescript
// packages/my-plugin/generators/my-generator/src/index.ts
import {
  Tree,
  formatFiles,
  installPackagesTask,
  generateFiles,
  readProjectConfiguration,
} from '@nx/devkit';
import { runTasksInSerial } from '@nx/plugin/src/utils/run-tasks-in-serial';
import * as path from 'path';

interface MyGeneratorSchema {
  name: string;
  directory?: string;
  skipFormat?: boolean;
}

export async function myGenerator(
  tree: Tree,
  options: MyGeneratorSchema
): Promise<void> {
  const project = readProjectConfiguration(tree, options.name);
  
  const templateOptions = {
    ...options,
    template: '',
  };

  generateFiles(
    tree,
    path.join(__dirname, 'files'),
    project.sourceRoot,
    templateOptions
  );

  if (!options.skipFormat) {
    await formatFiles(tree);
  }
}

export default myGenerator;
```

### Generator Schema Definition

Define the options your generator accepts:

```json
// packages/my-plugin/generators/my-generator/schema.json
{
  "$schema": "http://json-schema.org/schema",
  "id": "my-generator",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "description": "Project name",
      "$alias": "projectName"
    },
    "directory": {
      "type": "string",
      "description": "Directory to place files"
    },
    "skipFormat": {
      "type": "boolean",
      "description": "Skip formatting files"
    }
  },
  "required": ["name"]
}
```

## Building Custom Executors

Custom executors let you define specialized task runners for your workflow.

### Executor Implementation

Here's an executor that runs a custom build process:

```typescript
// packages/my-plugin/executors/my-executor/src/executor.ts
import { ExecutorContext, runExecutor } from '@nx/devkit';
import { MyExecutorSchema } from './schema';

export async function myExecutor(
  options: MyExecutorSchema,
  context: ExecutorContext
): Promise<{ success: boolean }> {
  console.log(`Executing ${context.projectName}...`);
  
  // Your custom logic here
  const buildResult = await performBuild(options, context);
  
  if (!buildResult.success) {
    return { success: false };
  }

  return { success: true };
}

async function performBuild(
  options: MyExecutorSchema,
  context: ExecutorContext
): Promise<{ success: boolean }> {
  // Implement your build logic
  return { success: true };
}

export default myExecutor;
```

### Executor Schema

```json
// packages/my-plugin/executors/my-executor/schema.json
{
  "$schema": "http://json-schema.org/schema",
  "executor": "my-plugin:my-executor",
  "title": "My Custom Executor",
  "type": "object",
  "properties": {
    "outputPath": {
      "type": "string",
      "description": "Output path for build artifacts"
    },
    "watch": {
      "type": "boolean",
      "description": "Watch for changes",
      "default": false
    }
  }
}
```

## Integrating with Claude Code

Now comes the powerful part—using Claude Code to interact with your custom Nx workflows.

### Using Claude Code to Run Generators

Claude Code can execute Nx generators directly through its bash tool:

```bash
# Run your custom generator
npx nx g my-plugin:my-feature my-project --directory=features/new-feature
```

### Creating a Claude Code Workflow Script

For complex workflows, create a script that combines multiple Nx operations:

```typescript
// scripts/custom-workflow.ts
import { execSync } from 'child_process';

function runNxCommand(command: string): void {
  console.log(`Running: ${command}`);
  execSync(command, { stdio: 'inherit' });
}

async function customWorkflow() {
  // Step 1: Generate a new feature
  runNxCommand('npx nx g my-plugin:feature my-app --name payments');
  
  // Step 2: Run linter
  runNxCommand('npx nx lint my-app');
  
  // Step 3: Run tests
  runNxCommand('npx nx test my-app');
  
  // Step 4: Build
  runNxCommand('npx nx build my-app');
  
  console.log('Workflow complete!');
}

customWorkflow();
```

## Best Practices for Custom Nx Workflows

Follow these recommendations to get the most out of your custom workflows.

### 1. Keep Generators Focused

Each generator should do one thing well. Rather than creating a monolithic generator, break complex scaffolding into multiple focused generators that users can combine.

### 2. Document Your Custom Tools

Create README files for each generator and executor. Document:

- Required and optional parameters
- Dependencies and prerequisites
- Expected output
- Usage examples

### 3. Test Your Generators

Nx provides testing utilities for generators:

```typescript
// packages/my-plugin/generators/my-generator/my-generator.spec.ts
import { Tree, readProjectConfiguration } from '@nx/devkit';
import { createTreeWithEmptyWorkspace } from '@nx/devkit/tests';
import { myGenerator } from './generator';

describe('my-generator', () => {
  let tree: Tree;

  beforeEach(() => {
    tree = createTreeWithEmptyWorkspace();
  });

  it('should generate a new feature', async () => {
    await myGenerator(tree, { name: 'test-app' });
    
    expect(tree.exists('apps/test-app/src/index.ts')).toBe(true);
  });
});
```

### 4. Use TypeScript for Type Safety

Always use TypeScript for your generators and executors. The Nx ecosystem provides excellent type definitions that catch errors at development time.

## Advanced: Composing Multiple Generators

For complex workflows, compose multiple generators:

```typescript
// A generator that runs other generators
import { runGenerator } from '@nx/devkit';

export async function compositeGenerator(
  tree: Tree,
  options: CompositeSchema
): Promise<void> {
  // Run the base feature generator
  await runGenerator(tree, {
    generator: '@nx/react:component',
    options: { ... }
  });
  
  // Run your custom generator
  await runGenerator(tree, {
    generator: 'my-plugin:feature',
    options: { ... }
  });
}
```

## Conclusion

Nx generators and executors provide a powerful foundation for automating your development workflow. By creating custom generators, you can enforce organizational standards and accelerate development. Custom executors let you encapsulate complex build and deployment logic.

When combined with Claude Code's ability to understand and interact with your codebase, these tools become even more powerful. Claude Code can help you:

- Generate new features using your custom generators
- Debug executor issues
- Create composite workflows
- Maintain consistency across your monorepo

Start small with a single custom generator, then expand your collection over time. Your team will thank you for the consistency and time savings.
{% endraw %}
