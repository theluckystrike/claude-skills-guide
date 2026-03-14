---

layout: default
title: "Claude Code Pull Request Description Generator Workflow"
description: "Learn how to build an automated workflow that generates comprehensive pull request descriptions using Claude Code, saving time and ensuring consistent documentation."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-pull-request-description-generator-workflow/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills]
---
{% raw %}

Pull request descriptions are critical for effective code reviews, but writing them manually is time-consuming and often inconsistent. This guide shows you how to build an automated pull request description generator using Claude Code that analyzes your changes and generates comprehensive, well-structured descriptions automatically.

## Why Automate PR Descriptions?

Manual PR descriptions often suffer from several problems: they're incomplete, inconsistently formatted, or missing key information like test impacts and breaking changes. An automated workflow solves these issues by:

- **Consistency**: Every PR gets a uniform structure
- **Time savings**: Developers focus on code, not documentation
- **Completeness**: No more forgetting to mention dependencies or test impacts
- **Review efficiency**: Reviewers get all the context they need upfront

## Setting Up the PR Description Generator

The foundation of this workflow is a Claude Code skill that analyzes your git changes and generates structured descriptions. Create a new skill for this purpose:

```bash
claude skill create pr-description-generator
```

This creates a skill scaffold. Now you'll configure it to extract the right information from your codebase.

### Core Components of the Generator

Your PR description generator needs several key components working together:

**1. Git Diff Analysis**
The generator must first understand what changed. Use git commands to extract the necessary information:

```bash
# Get the list of changed files
git diff --name-only HEAD~1 HEAD

# Get detailed diff for each file
git diff HEAD~1 HEAD

# Get commit messages for context
git log --oneline -10
```

**2. File Change Classification**
Not all changes are equal. Your generator should categorize changes:

- **New files**: Feature additions, new components
- **Modified files**: Bug fixes, refactoring, optimizations
- **Deleted files**: Deprecations, cleanup
- **Config changes**: Environment, build configuration

**3. Impact Analysis**
A good PR description explains the impact of changes. The generator should identify:

- Which tests might be affected
- Whether documentation needs updates
- If there are breaking changes
- Performance implications

## Implementing the Workflow

Here's a practical implementation using a Claude Code skill:

### Step 1: Create the Analysis Script

```bash
#!/bin/bash
# pr-analyze.sh - Analyze git changes for PR description

BRANCH=$(git branch --show-current)
BASE_BRANCH="main"

echo "## Changes Summary"
echo ""
git diff --stat $BASE_BRANCH...$BRANCH

echo ""
echo "## Files Changed"
echo "```"
git diff --name-only $BASE_BRANCH...$BRANCH
echo "```"

echo ""
echo "## Recent Commits"
git log $BASE_BRANCH...$BRANCH --oneline
```

### Step 2: Build the Claude Skill

Create `skill.ts` with the main logic:

```typescript
import { Git } from './git';
import { Analyzer } from './analyzer';

export const skill = {
  name: 'pr-description-generator',
  description: 'Generate comprehensive pull request descriptions',
  
  async run(context: SkillContext) {
    const git = new Git();
    const analyzer = new Analyzer();
    
    // Get changes
    const changes = await git.getChanges();
    const diff = await git.getDiff();
    const commits = await git.getCommits();
    
    // Analyze the changes
    const analysis = analyzer.analyze({ changes, diff, commits });
    
    // Generate description
    const description = this.generateDescription(analysis);
    
    return { description };
  },
  
  generateDescription(analysis: AnalysisResult): string {
    return `
## Summary
${analysis.summary}

## Changes Made
${analysis.changes.map(c => `- ${c.file}: ${c.description}`).join('\n')}

## Testing
${analysis.testImpact}

## Breaking Changes
${analysis.breakingChanges || 'None'}

## Additional Notes
${analysis.additionalNotes}
`.trim();
  }
};
```

### Step 3: Configure the Workflow

Add a configuration file to customize the generator behavior:

```yaml
# pr-description-config.yaml
include:
  - fileList: true
  - diffStats: true
  - commitHistory: true
  - testImpact: true

categorize:
  patterns:
    - { pattern: "src/**", category: "Source Code" }
    - { pattern: "test/**", category: "Tests" }
    - { pattern: "docs/**", category: "Documentation" }
    - { pattern: "*.config.*", category: "Configuration" }

templates:
  summary: "This PR {verb} {impact} in {scope}"
  breakingChanges: "⚠️ WARNING: This contains breaking changes"
```

## Using the Generator in Your Workflow

Once configured, using the generator is straightforward:

### Manual Generation

```bash
claude skill invoke pr-description-generator
```

This outputs a generated description that you can copy and paste into your PR.

### Pre-Push Automation

Integrate the generator into your development workflow by adding it to your pre-push hook:

```bash
# .git/hooks/pre-push
#!/bin/bash

while read local_ref local_sha remote_ref remote_sha; do
  if [ "$remote_ref" = "refs/heads/main" ]; then
    echo "Generating PR description..."
    claude skill invoke pr-description-generator > .github/PR_DESCRIPTION.md
  fi
done
```

### CI Integration

For automated PR description generation on GitHub Actions:

```yaml
name: Generate PR Description
on: [pull_request]

jobs:
  describe:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.head_ref }}
      
      - name: Generate Description
        run: |
          claude skill invoke pr-description-generator > pr_description.md
      
      - name: Comment PR
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const description = fs.readFileSync('pr_description.md', 'utf8');
            await github.rest.issues.createComment({
              issue_number: context.issue.number,
              body: '## Auto-generated PR Description\n' + description
            });
```

## Best Practices and Tips

### Review Generated Descriptions

Always review the generated description before submitting. The generator captures technical details, but you should add context about business logic, user impact, and any manual testing performed.

### Customize for Your Team

Every team has different requirements. Adjust the generator to include:

- **Ticket references**: Link to project management tools
- **Screenshots**: For UI changes, auto-attach screenshots
- **Deployment notes**: For infrastructure changes
- **Migration guides**: For database or API changes

### Maintain the Generator

As your codebase evolves, update the generator to recognize new patterns. Keep the categorization rules current with your project structure.

## Conclusion

Automating pull request descriptions with Claude Code improves consistency, saves time, and ensures reviewers always have the context they need. Start with the basic workflow shown here, then customize it to match your team's specific needs and conventions.

The key is to balance automation with human oversight—let Claude handle the mechanical aspects of description writing while you focus on adding the nuanced context that only a human developer can provide.
{% endraw %}
