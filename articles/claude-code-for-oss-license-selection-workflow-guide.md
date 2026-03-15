---
layout: default
title: "Claude Code for OSS License Selection Workflow Guide"
description: "Build a Claude Code skill that guides developers through open source license selection with practical examples, decision trees, and automated compliance checks."
date: 2026-03-15
author: "Claude Skills Guide"
permalink: /claude-code-for-oss-license-selection-workflow-guide/
categories: [guides]
tags: [claude-code, claude-skills]
---

{% raw %}
# Claude Code for OSS License Selection Workflow Guide

Choosing the right open source license is one of the most important decisions you'll make when starting a new project. The wrong choice can lead to legal complications, missed opportunities for collaboration, or unintended commercial use of your code. This guide shows you how to build a Claude Code skill that systematically guides developers through license selection, helping them make informed decisions while avoiding common pitfalls.

## Why Automate License Selection?

License selection isn't just about copying a generic MIT or Apache 2.0 license into your repository. It requires understanding your project's goals, your tolerance for commercial use, your preferences for derivative works, and your obligations regarding patent grants. A well-designed Claude Code skill can:

- Ask targeted questions about your project requirements
- Provide clear explanations of license obligations
- Check existing dependencies for license compatibility
- Generate appropriate LICENSE files with proper attribution
- Warn about potential conflicts with your dependencies

## Designing the License Selection Skill

The core of this skill is a decision tree that maps your project characteristics to suitable licenses. Here's how to structure it:

```yaml
---
name: license-selector
description: "Guides developers through open source license selection based on project requirements"
tools: [Read, Write, Bash]
---

# Open Source License Selection Assistant

I'll help you choose the right open source license for your project. Let me ask you a few questions to narrow down the options.

## Question 1: Commercial Use

Do you want to allow commercial use of your software?
- **Yes**: Continue to next question
- **No**: Consider GPL family licenses (AGPL, GPLv3, GPLv2)

## Question 2: Source Code Distribution

Do you want to require that derivative works must also be open source?
- **Yes**: Consider GPLv3, AGPL, MPL
- **No**: Consider MIT, Apache 2.0, BSD

## Question 3: Patent Grants

Do you want to include an explicit patent grant?
- **Yes**: Apache 2.0 provides strong patent provisions
- **No**: MIT or BSD may be simpler choices
```

This basic structure provides the framework, but the real value comes from adding practical checks and automated actions.

## Implementing Dependency License Analysis

A truly useful license selection skill should check your project's dependencies to identify potential conflicts. Create a function that analyzes your package.json, requirements.txt, or Cargo.toml:

```javascript
async function analyzeDependencies(projectPath) {
  const packageJson = await readFile(`${projectPath}/package.json`);
  const dependencies = {
    ...packageJson.dependencies,
    ...packageJson.devDependencies
  };
  
  const licenseInfo = {};
  for (const [dep, version] of Object.entries(dependencies)) {
    const info = await fetchPackageLicense(dep);
    licenseInfo[dep] = info.license;
  }
  
  return licenseInfo;
}
```

This function collects license information for all dependencies, which you can then cross-reference against your chosen license using a compatibility matrix:

```javascript
const licenseCompatibility = {
  'MIT': ['MIT', 'Apache-2.0', 'BSD-2-Clause', 'BSD-3-Clause', 'ISC', 'Unlicense'],
  'Apache-2.0': ['MIT', 'Apache-2.0', 'BSD-2-Clause', 'BSD-3-Clause', 'ISC', 'Unlicense'],
  'GPL-3.0': ['GPL-3.0', 'AGPL-3.0', 'LGPL-3.0'],
  'GPL-2.0': ['GPL-2.0', 'LGPL-2.1']
};

function checkCompatibility(projectLicense, depLicenses) {
  const compatible = [];
  const conflicts = [];
  
  for (const dep of depLicenses) {
    if (licenseCompatibility[projectLicense]?.includes(dep)) {
      compatible.push(dep);
    } else {
      conflicts.push(dep);
    }
  }
  
  return { compatible, conflicts };
}
```

## Creating Interactive Decision Flows

The most effective license selection workflows are interactive. Claude Code skills can maintain conversation context to drill down through a series of questions:

```markdown
## License Selection Workflow

Let me guide you through the license selection process. Answer each question, and I'll provide recommendations based on your responses.

### Question 1: What is the primary purpose of your project?

1. **Library/Framework** - Used by other projects
2. **Application** - End-user software
3. **Tool/Utility** - Developer productivity
4. **SaaS/Service** - Running as a hosted service

### For Library/Framework:
If others will embed or extend your code, consider:
- **LGPL**: Allows proprietary use if you link dynamically
- **MPL**: Balanced approach for Firefox-style licensing
- **MIT/Apache**: Maximum compatibility with other projects

### For SaaS/Service:
If you're building a hosted service, you may want:
- **AGPL**: Requires sharing modifications if you run a hosted service
- **MIT/Apache**: No obligation to share your modifications
```

## Generating the LICENSE File

Once the skill helps users select a license, it should generate the appropriate LICENSE file:

```markdown
## Generate License File

Based on your responses, I recommend the **MIT License** for your project. It provides:

- Simple, permissive terms
- Commercial use allowed
- No source code redistribution requirements
- Minimal liability

Shall I generate the LICENSE file now? I can:
1. Create a standard MIT LICENSE file
2. Customize it with your name and project year
3. Add a NOTICE file for attribution requirements

Example output for MIT:
```
MIT License

Copyright (c) 2026 Your Name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```
```

## Best Practices for License Selection Skills

When building this skill, keep these principles in mind:

1. **Provide context, not just recommendations**: Explain *why* a license suits their use case
2. **Warn about trademark issues**: License ≠ trademark protection
3. **Consider future flexibility**: Some licenses are easier to change than others
4. **Address dual licensing**: Explain how dual licensing works for commercial projects
5. **Include jurisdiction notes**: Different countries have different legal interpretations

## Testing Your License Selection Skill

Validate your skill works correctly by testing various scenarios:

```bash
# Test case 1: Commercial library
echo "Library for commercial use, no copyleft" | claude -s license-selector

# Test case 2: Open source application
echo "Application, want attribution, allow modifications" | claude -s license-selector

# Test case 3: Check dependencies
cd my-project && claude -s license-selector --check-deps
```

## Conclusion

Building a Claude Code skill for OSS license selection transforms a complex legal decision into a guided, informed process. By combining interactive questioning, dependency analysis, and automated file generation, you create a tool that helps developers choose licenses confidently while avoiding common mistakes.

Remember that this skill provides guidance, not legal advice. For complex projects or uncertain situations, always recommend consulting with an open source legal expert. But for the vast majority of projects, a well-designed license selection workflow saves time and prevents costly mistakes.
{% endraw %}
