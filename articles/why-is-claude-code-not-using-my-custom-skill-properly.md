---

layout: default
title: "Why Is Claude Code Not Using My Custom Skill Properly?"
description: "Troubleshooting guide for custom skill issues in Claude Code. Learn why your skills might not be loading or being recognized properly."
date: 2026-03-14
categories: [troubleshooting]
tags: [claude-code, claude-skills]
author: "Claude Skills Guide"
permalink: /why-is-claude-code-not-using-my-custom-skill-properly/
reviewed: true
score: 7
---


{% raw %}
# Why Is Claude Code Not Using My Custom Skill Properly?

If you've created a custom skill for Claude Code but it's not being recognized or used as expected, you're not alone. Many users encounter issues when first creating and integrating custom skills. This guide will walk you through the most common reasons why your custom skill might not be working and how to fix them.

## Understanding How Skills Work in Claude Code

Before diving into troubleshooting, it's essential to understand how Claude Code loads and uses skills. Skills in Claude Code work on a **progressive disclosure** model:

1. **Level 1 (Metadata)**: At startup, Claude Code loads skill names and descriptions
2. **Level 2 (Full Content)**: The complete skill guidance loads only when you explicitly request it using `get_skill(skill_name)`
3. **Level 3 (Resources)**: Additional files and scripts referenced by the skill are loaded as needed

This design keeps startup fast while allowing complex, resource-heavy skills to load on demand.

## Common Reasons Why Your Skill Isn't Being Used

### 1. Incorrect Skill File Location

One of the most frequent issues is placing the skill file in the wrong directory. Claude Code looks for skills in specific locations:

- The `skills/` directory in your workspace
- A global skills directory configured in your settings

Make sure your skill file is in the correct location. The file should be named with a `.md` extension and follow the naming convention that matches the skill name.

### 2. Missing or Incorrect Skill Metadata

Every skill needs proper metadata at the start of the skill file. This metadata tells Claude Code what the skill does and when to consider using it. Without this information, your skill might never be loaded or selected.

Your skill file should start with a clear description of what the skill does. This description is what Claude Code uses at Level 1 to determine if your skill is relevant to the current task.

### 3. Vague or Generic Skill Descriptions

If your skill description is too generic, Claude Code won't know when to use it. For example, a description like "helps with programming" is too broad. Instead, be specific: "Creates and edits Python scripts for data analysis, including pandas operations and matplotlib visualizations."

### 4. Not Explicitly Calling the Skill

Remember the progressive disclosure model! Claude Code won't automatically use your skill just because it exists. You need to explicitly call it using:

```
get_skill("your-skill-name")
```

This is a common misunderstanding. Having a skill file in the right place doesn't automatically activate it for relevant tasks.

### 5. Syntax Errors in Skill Files

If your skill file has syntax errors or formatting issues, it might fail to load properly. Common problems include:
- Broken Markdown formatting
- Missing required sections
- Incorrect YAML or front matter (if used)

## Practical Examples

Let's look at some concrete examples of skill issues and fixes.

### Example 1: The Skill File

Here's a properly structured skill file:

```markdown
# My Custom Data Processing Skill

This skill provides expert guidance for processing CSV files using Python pandas.

## When to Use This Skill

Use this skill when:
- Working with CSV or TSV files
- Performing data cleaning operations
- Aggregating or transforming tabular data
- Generating data visualizations

## How to Use

1. Load the skill using get_skill("data-processing")
2. Describe your data file and desired outcome
3. Follow the guidance for processing steps

## Capabilities

- Read and parse CSV files
- Handle missing data
- Perform aggregations
- Export results to various formats
```

### Example 2: Calling the Skill

When you want to use your skill, you must explicitly invoke it:

```
I need help processing a large CSV file. Let me load the data processing skill first.
get_skill("data-processing")

Now can you help me clean this dataset?
```

Without the `get_skill()` call, Claude Code won't have access to the full skill guidance.

### Example 3: Diagnosing Skill Issues

If your skill isn't working, here's a diagnostic approach:

1. **Verify the file exists**: Check that your skill file is in the correct directory
2. **Check the description**: Ensure it's specific and accurately describes your skill's purpose
3. **Test the call**: Use `get_skill("your-skill-name")` explicitly
4. **Review for errors**: Check for any syntax issues in the file

## Best Practices for Custom Skills

To ensure your custom skills work reliably, follow these best practices:

### Write Clear, Specific Descriptions

Your skill description is the most important part. It determines whether Claude Code considers your skill for a given task. Be specific about:
- What the skill does
- When to use it
- What types of problems it solves

### Keep Skills Focused

Rather than creating one broad skill, consider breaking it into smaller, focused skills. This makes each skill more discoverable and relevant to specific tasks.

### Test Your Skills

After creating a skill, test it to ensure it loads properly:
1. Call `get_skill("your-skill-name")`
2. Ask a question relevant to the skill
3. Verify you get the expected guidance

### Document Required Resources

If your skill depends on external files, scripts, or tools, clearly document these in the skill file. Include setup instructions and any prerequisites.

## Debugging Tips

When your skill still isn't working:

1. **Check for typos**: Skill names are case-sensitive
2. **Verify file extension**: Must be `.md`
3. **Restart Claude Code**: Sometimes a restart is needed to recognize new skills
4. **Check permissions**: Ensure the skill file is readable
5. **Look at the logs**: Some issues may be logged with helpful error messages

## Conclusion

Custom skills in Claude Code are powerful tools for extending its capabilities, but they require proper setup and explicit invocation. Remember the key points:

- Skills must be in the correct location
- Clear, specific descriptions are crucial
- Always use `get_skill()` to load skills explicitly
- Test your skills after creating them

By following these guidelines and troubleshooting steps, you should be able to get your custom skills working properly and take full advantage of Claude Code's extensibility.
{% endraw %}


## Related Reading

- [Claude Code for Beginners: Complete Getting Started Guide](/claude-skills-guide/claude-code-for-beginners-complete-getting-started-2026/)
- [Claude Code Not Working After Update: How to Fix](/claude-skills-guide/claude-code-not-working-after-update-how-to-fix/)
- [Claude Code Troubleshooting Hub](/claude-skills-guide/troubleshooting-hub/)

Built by theluckystrike — More at [zovo.one](https://zovo.one)
