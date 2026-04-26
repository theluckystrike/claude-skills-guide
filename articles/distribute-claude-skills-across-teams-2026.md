---
layout: post
title: "How to Distribute Claude Skills Across (2026)"
description: "Package and distribute Claude skills to engineering teams: npm packages, Git submodules, managed settings, and versioning strategies."
permalink: /distribute-claude-skills-across-teams-2026/
date: 2026-04-21
last_tested: "2026-04-21"
render_with_liquid: false
---
{% raw %}

## The Workflow

Package Claude Code skills for distribution across multiple teams and repositories. This covers four distribution methods (Git submodules, npm packages, managed settings, plugin registries), versioning strategies, and update propagation patterns that scale from 5 to 500 developers.

Expected time: 30-45 minutes to set up a distribution channel
Prerequisites: Claude Code installed, Git repository for skills, npm account (for package distribution)

## Setup

### 1. Create a Skills Monorepo

```bash
mkdir -p claude-skills-shared/{skills,scripts,tests}
cd claude-skills-shared
git init
```

Structure for a distributable skills package:

```
claude-skills-shared/
├── skills/
│   ├── api-conventions/
│   │   └── SKILL.md
│   ├── code-review/
│   │   └── SKILL.md
│   ├── testing-standards/
│   │   └── SKILL.md
│   └── security-checklist/
│       └── SKILL.md
├── scripts/
│   ├── install.sh
│   └── update.sh
├── tests/
│   └── validate-skills.sh
├── package.json
├── CHANGELOG.md
└── README.md
```

### 2. Create the Package Configuration

```json
{
  "name": "@yourorg/claude-skills",
  "version": "1.0.0",
  "description": "Shared Claude Code skills for engineering teams",
  "files": ["skills/**/*.md"],
  "scripts": {
    "install-skills": "bash scripts/install.sh",
    "validate": "bash tests/validate-skills.sh",
    "postinstall": "bash scripts/install.sh"
  },
  "publishConfig": {
    "registry": "https://npm.pkg.github.com"
  }
}
```

### 3. Write the Installation Script

```bash
cat > scripts/install.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# Determine target directory
if [ -d ".claude/skills" ]; then
  TARGET=".claude/skills"
elif [ -d "$(git rev-parse --show-toplevel 2>/dev/null)/.claude/skills" ]; then
  TARGET="$(git rev-parse --show-toplevel)/.claude/skills"
else
  TARGET=".claude/skills"
  mkdir -p "$TARGET"
fi

# Find the skills source (works from node_modules or standalone)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/../skills"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "Error: skills directory not found at $SKILLS_DIR"
  exit 1
fi

# Copy skills to project
echo "Installing shared skills to $TARGET..."
cp -r "$SKILLS_DIR"/* "$TARGET/"

INSTALLED=$(find "$TARGET" -name "SKILL.md" | wc -l | tr -d ' ')
echo "Installed $INSTALLED skills successfully."
echo "Skills are now available in Claude Code."
EOF
chmod +x scripts/install.sh
```

## Usage Example

### Method 1: Git Submodules (Best for Controlled Updates)

```bash
# In the consuming project:
git submodule add https://github.com/yourorg/claude-skills-shared.git .claude/shared-skills

# Create a symlink setup script
cat > .claude/link-shared-skills.sh << 'EOF'
#!/bin/bash
SHARED=".claude/shared-skills/skills"
TARGET=".claude/skills"
mkdir -p "$TARGET"

for skill_dir in "$SHARED"/*/; do
  skill_name=$(basename "$skill_dir")
  if [ ! -L "$TARGET/$skill_name" ]; then
    ln -sf "$(pwd)/$skill_dir" "$TARGET/$skill_name"
    echo "Linked: $skill_name"
  fi
done
EOF
chmod +x .claude/link-shared-skills.sh

# Run after clone or submodule update
.claude/link-shared-skills.sh
```

Update skills across all projects:

```bash
# In the skills repo: bump version, push
cd claude-skills-shared
git tag v1.1.0
git push origin v1.1.0

# In consuming projects: update submodule
git submodule update --remote .claude/shared-skills
git add .claude/shared-skills
git commit -m "chore: update shared Claude skills to v1.1.0"
```

### Method 2: npm Package (Best for Automated Updates)

```bash
# Publish to GitHub Packages or npm
npm publish

# In consuming projects:
npm install --save-dev @yourorg/claude-skills
# postinstall script automatically copies skills to .claude/skills/
```

For automated updates across all repositories:

```bash
# Renovate or Dependabot config for automatic PRs
# renovate.json
{
  "extends": ["config:base"],
  "packageRules": [
    {
      "matchPackageNames": ["@yourorg/claude-skills"],
      "automerge": true,
      "schedule": ["every weekday"]
    }
  ]
}
```

### Method 3: Managed Settings (Best for Enterprise Enforcement)

```bash
# Deploy via Ansible to all developer machines
cat > ansible/claude-skills.yml << 'EOF'
---
- name: Deploy Claude Code managed skills
  hosts: developers
  become: yes
  tasks:
    - name: Create managed skills directory
      file:
        path: /Library/Application Support/ClaudeCode/skills
        state: directory
        mode: '0755'

    - name: Copy shared skills
      copy:
        src: "{{ item }}"
        dest: "/Library/Application Support/ClaudeCode/skills/"
        mode: '0644'
      with_fileglob:
        - "skills/*/SKILL.md"

    - name: Deploy managed CLAUDE.md
      copy:
        src: managed-claude.md
        dest: "/Library/Application Support/ClaudeCode/CLAUDE.md"
        mode: '0644'
EOF
```

### Method 4: Plugin Registry (Best for Optional Skills)

```bash
# Create a plugin manifest
cat > plugin.json << 'EOF'
{
  "name": "acme-engineering-skills",
  "version": "1.0.0",
  "skills": [
    {
      "name": "api-conventions",
      "path": "skills/api-conventions/SKILL.md",
      "description": "REST API design patterns for Acme platform"
    },
    {
      "name": "code-review",
      "path": "skills/code-review/SKILL.md",
      "description": "Automated code review checklist"
    }
  ],
  "installCommand": "git clone https://github.com/yourorg/claude-skills-shared.git ~/.claude/plugins/acme-engineering"
}
EOF
```

### Versioning Strategy

Use semantic versioning for skill packages:

```bash
# Version bump script
cat > scripts/bump-version.sh << 'EOF'
#!/bin/bash
TYPE="${1:-patch}"  # major, minor, patch

case "$TYPE" in
  major) # Breaking changes: skill renamed, removed, or behavior changed
    npm version major --no-git-tag-version ;;
  minor) # New skills added, non-breaking enhancements
    npm version minor --no-git-tag-version ;;
  patch) # Typo fixes, clarifications, no behavior change
    npm version patch --no-git-tag-version ;;
esac

VERSION=$(node -p "require('./package.json').version")
echo "## v$VERSION - $(date +%Y-%m-%d)" >> CHANGELOG.md
echo "" >> CHANGELOG.md

git add package.json CHANGELOG.md
git commit -m "chore: bump skills to v$VERSION"
git tag "v$VERSION"
echo "Tagged v$VERSION — run 'git push && git push --tags' to publish"
EOF
chmod +x scripts/bump-version.sh
```

## Common Issues

- **Submodule not initialized after clone:** New team members must run `git submodule update --init --recursive` after cloning. Add this to your project's setup documentation or a Makefile `setup` target.
- **npm postinstall fails on CI:** CI environments may not have `.claude/` in the expected location. Add a check: `[ -d "$(git rev-parse --show-toplevel)" ] && bash scripts/install.sh || echo "Skipping skill install (no git root)"`.
- **Skills version conflict between teams:** Use namespaced skill names: `@team/skill-name` in the skill's `name` field. Claude Code respects the namespace and will not conflict with other teams' skills.

## Why This Matters

Without distribution infrastructure, each team reinvents the same Claude Code configurations. A shared skills package ensures consistent AI behavior across 10+ repositories while allowing teams to update without manual intervention.

## Related Guides

- [How to Share Claude Skills with Team](/how-to-share-claude-skills-with-team/)
- [Claude Skill Naming Conventions](/claude-skill-naming-conventions/)
- [How Do I Test a Claude Skill Before Deploying to Team](/how-do-i-test-a-claude-skill-before-deploying-to-team/)

## Frequently Asked Questions

### What is the minimum setup required?

You need Claude Code installed (Node.js 18+), a project with a `CLAUDE.md` file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively.

### How long does the initial setup take?

For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring `.claude/settings.json` for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists.

### Can I use this with a team?

Yes. Commit your `.claude/` directory and `CLAUDE.md` to version control so the entire team uses the same configuration. Each developer can add personal preferences in `~/.claude/settings.json` (user-level) without affecting the project configuration. Review CLAUDE.md changes in pull requests like any other configuration file.

### What if Claude Code produces incorrect output?

First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation. For persistent issues, add explicit rules to CLAUDE.md (e.g., "Always use single quotes" or "Never modify files in the config/ directory").


## Best Practices

1. **Start with a clear CLAUDE.md.** Describe your project structure, tech stack, coding conventions, and common commands in under 300 words. This single file has the largest impact on Claude Code's accuracy and efficiency.

2. **Use skills for domain knowledge.** Move detailed reference information (API routes, database schemas, deployment procedures) into `.claude/skills/` files. This keeps CLAUDE.md concise while making specialized knowledge available when needed.

3. **Review changes before committing.** Always run `git diff` after Claude Code makes changes. Verify the edits are correct, match your project style, and do not introduce unintended side effects. This habit prevents compounding errors across sessions.

4. **Set up permission guardrails.** Configure `.claude/settings.json` with explicit allow and deny lists. Allow your standard development commands (test, build, lint) and deny destructive operations (rm -rf, git push --force, database drops).

5. **Keep sessions focused.** Give Claude Code one clear task per prompt. Multi-step requests like "refactor auth, add tests, and update docs" produce better results when broken into three separate prompts, each building on the previous result.


<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is the minimum setup required?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "You need Claude Code installed (Node.js 18+), a project with a CLAUDE.md file, and the relevant toolchain for your project type (e.g., npm for JavaScript, pip for Python). The CLAUDE.md file should describe your project structure, conventions, and common commands so Claude Code can work effectively."
      }
    },
    {
      "@type": "Question",
      "name": "How long does the initial setup take?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "For a typical project, initial setup takes 10-20 minutes. This includes creating the CLAUDE.md file, configuring .claude/settings.json for permissions, and running a test task to verify everything works. Subsequent sessions start immediately because the configuration persists."
      }
    },
    {
      "@type": "Question",
      "name": "Can I use this with a team?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Commit your .claude/ directory and CLAUDE.md to version control so the entire team uses the same configuration. Each developer can add personal preferences in ~/.claude/settings.json (user-level) without affecting the project configuration."
      }
    },
    {
      "@type": "Question",
      "name": "What if Claude Code produces incorrect output?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "First check that your CLAUDE.md accurately describes your project conventions. Incorrect or outdated context is the most common cause of wrong output. If the output is still wrong, provide feedback in the same session — Claude Code learns from corrections within a conversation."
      }
    }
  ]
}
</script>

{% endraw %}
