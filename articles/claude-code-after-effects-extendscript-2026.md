---
layout: default
title: "Claude Code for After Effects (2026)"
permalink: /claude-code-after-effects-extendscript-2026/
date: 2026-04-20
description: "Automate After Effects with ExtendScript and Claude Code. Build motion graphics templates, batch render compositions, and script expression controllers."
last_tested: "2026-04-22"
domain: "motion graphics"
---

## Why Claude Code for After Effects ExtendScript

After Effects ExtendScript (based on ES3 JavaScript) is the only way to automate complex motion graphics workflows: batch rendering 200 social media variants from a single template, building expression-driven animation rigs, generating data-driven infographics, and managing render queue operations. The ExtendScript API is vast but poorly documented, with quirks like 1-based indexing, blocking execution, and no modern JavaScript features. Motion designers who need automation often lack programming experience, while developers unfamiliar with AE's composition model write scripts that corrupt projects.

Claude Code understands the After Effects DOM (compositions, layers, properties, keyframes) and generates ExtendScript that correctly traverses the layer hierarchy, manipulates keyframe data, and handles AE's unique property access patterns.

## The Workflow

### Step 1: Set Up ExtendScript Development

```bash
# Install VS Code ExtendScript debugger
code --install-extension nicmilette.ae-script-runner

# Create project structure
mkdir -p ~/ae-scripts/{lib,templates,output}

# ExtendScript files use .jsx extension
touch ~/ae-scripts/batch-render.jsx
touch ~/ae-scripts/template-builder.jsx
```

### Step 2: Build a Data-Driven Template Engine

```javascript
// batch-render.jsx — Generate 200 social media variants from CSV data
// Run in After Effects via File > Scripts > Run Script File

#include "lib/json2.js"  // JSON polyfill for ES3

(function() {
    // Configuration
    var TEMPLATE_COMP = "Social_Template";
    var OUTPUT_FOLDER = new Folder("~/ae-scripts/output");
    var CSV_FILE = new File("~/ae-scripts/data/variants.csv");

    if (!OUTPUT_FOLDER.exists) OUTPUT_FOLDER.create();

    // Parse CSV data
    function parseCSV(file) {
        file.open("r");
        var content = file.read();
        file.close();

        var lines = content.split("\n");
        var headers = lines[0].split(",");
        var records = [];

        for (var i = 1; i < lines.length; i++) {
            if (lines[i].trim() === "") continue;
            var values = lines[i].split(",");
            var record = {};
            for (var j = 0; j < headers.length; j++) {
                record[headers[j].trim()] = values[j] ? values[j].trim() : "";
            }
            records.push(record);
        }
        return records;
    }

    // Find layer by name in composition (recursive)
    function findLayer(comp, layerName) {
        for (var i = 1; i <= comp.numLayers; i++) {
            if (comp.layer(i).name === layerName) {
                return comp.layer(i);
            }
        }
        return null;
    }

    // Update text layer content
    function setTextContent(comp, layerName, newText) {
        var layer = findLayer(comp, layerName);
        if (layer && layer instanceof TextLayer) {
            var textProp = layer.property("Source Text");
            var textDoc = textProp.value;
            textDoc.text = newText;
            textProp.setValue(textDoc);
            return true;
        }
        return false;
    }

    // Update color on shape or solid layer
    function setLayerColor(comp, layerName, hexColor) {
        var layer = findLayer(comp, layerName);
        if (!layer) return false;

        var r = parseInt(hexColor.substr(1, 2), 16) / 255;
        var g = parseInt(hexColor.substr(3, 2), 16) / 255;
        var b = parseInt(hexColor.substr(5, 2), 16) / 255;

        // For shape layers, update fill color
        var contents = layer.property("ADBE Root Vectors Group");
        if (contents) {
            for (var i = 1; i <= contents.numProperties; i++) {
                var fill = contents.property(i).property("ADBE Vector Graphic - Fill");
                if (fill) {
                    fill.property("ADBE Vector Fill Color").setValue([r, g, b]);
                }
            }
        }
        return true;
    }

    // Replace footage in layer
    function replaceFootage(comp, layerName, filePath) {
        var layer = findLayer(comp, layerName);
        if (!layer) return false;

        var newFile = new File(filePath);
        if (!newFile.exists) return false;

        var importOptions = new ImportOptions(newFile);
        var newFootage = app.project.importFile(importOptions);
        layer.replaceSource(newFootage, false);
        return true;
    }

    // Main batch rendering loop
    app.beginUndoGroup("Batch Render Variants");

    var templateComp = null;
    for (var i = 1; i <= app.project.numItems; i++) {
        if (app.project.item(i).name === TEMPLATE_COMP &&
            app.project.item(i) instanceof CompItem) {
            templateComp = app.project.item(i);
            break;
        }
    }

    if (!templateComp) {
        alert("Template composition '" + TEMPLATE_COMP + "' not found!");
        return;
    }

    var data = parseCSV(CSV_FILE);

    for (var d = 0; d < data.length; d++) {
        var record = data[d];
        var variantComp = templateComp.duplicate();
        variantComp.name = "Variant_" + record.id;

        // Apply data to template
        setTextContent(variantComp, "Headline", record.headline);
        setTextContent(variantComp, "Subtitle", record.subtitle);
        setTextContent(variantComp, "CTA_Text", record.cta);
        setLayerColor(variantComp, "Background", record.bg_color);

        if (record.product_image) {
            replaceFootage(variantComp, "Product_Image", record.product_image);
        }

        // Add to render queue
        var renderItem = app.project.renderQueue.items.add(variantComp);
        var outputModule = renderItem.outputModule(1);
        outputModule.file = new File(
            OUTPUT_FOLDER.fsName + "/" + record.id + ".mp4"
        );
    }

    app.endUndoGroup();
    alert("Added " + data.length + " variants to render queue.\nClick Render to process.");

})();
```

### Step 3: Build Expression Controller Script

```javascript
// expression-rig.jsx — Create animation rig with expression controls
(function() {
    var comp = app.project.activeItem;
    if (!(comp instanceof CompItem)) {
        alert("Select a composition first.");
        return;
    }

    app.beginUndoGroup("Create Expression Rig");

    // Create controller null layer
    var ctrl = comp.layers.addNull();
    ctrl.name = "CONTROLS";
    ctrl.label = 10;  // Yellow label

    // Add expression control effects
    var sliderEffect = ctrl.Effects.addProperty("ADBE Slider Control");
    sliderEffect.name = "Animation Speed";
    sliderEffect.property("Slider").setValue(1.0);

    var colorEffect = ctrl.Effects.addProperty("ADBE Color Control");
    colorEffect.name = "Primary Color";
    colorEffect.property("Color").setValue([0.2, 0.5, 1.0]);

    var checkboxEffect = ctrl.Effects.addProperty("ADBE Checkbox Control");
    checkboxEffect.name = "Show Subtitle";
    checkboxEffect.property("Checkbox").setValue(1);

    // Apply expressions to target layers
    var textLayer = findLayer(comp, "Title");
    if (textLayer) {
        // Link scale animation to speed control
        textLayer.property("Scale").expression =
            'ctrl = thisComp.layer("CONTROLS");\n' +
            'speed = ctrl.effect("Animation Speed")("Slider");\n' +
            't = time * speed;\n' +
            'ease(t, 0, 0.5, [0,0], [100,100])';
    }

    app.endUndoGroup();
})();
```

### Step 4: Verify

```bash
# Run script from command line (headless)
afterfx -r ~/ae-scripts/batch-render.jsx

# Or via aerender for render-only operations
aerender -project ~/projects/template.aep \
         -comp "Variant_001" \
         -output ~/ae-scripts/output/test.mp4

# Validate output files
ls -la ~/ae-scripts/output/*.mp4 | wc -l
```

## CLAUDE.md for After Effects ExtendScript

```markdown
# After Effects ExtendScript Standards

## Domain Rules
- ExtendScript uses ES3 (no let/const, no arrow functions, no template literals)
- Layer indexing is 1-based (not 0-based)
- Always wrap in app.beginUndoGroup() / app.endUndoGroup()
- Property access uses string names: layer.property("Position")
- Use #include for shared libraries
- Close File objects after read/write
- Test scripts on duplicate of production project (never on original)

## File Patterns
- *.jsx (ExtendScript files)
- lib/*.jsx (shared utility libraries)
- templates/*.aep (After Effects project templates)

## Common Commands
- afterfx -r script.jsx (run script headless)
- aerender -project file.aep -comp "Comp" -output output.mp4
- afterfx -noui -r script.jsx (no UI mode)
```

## Common Pitfalls in After Effects Scripting

- **Blocking execution freezes AE:** Long-running scripts with no progress bar freeze After Effects. Claude Code adds `app.beginSuppressDialogs()` and periodic `$.sleep(10)` calls to keep the UI responsive.

- **Property name locale dependency:** Property names like "Position" change in non-English AE installations. Claude Code uses match names (ADBE Vector Position) instead of display names for reliable cross-locale scripts.

- **Keyframe data type mismatch:** Setting a spatial property (Position) keyframe requires different methods than temporal properties (Opacity). Claude Code uses `setValueAtTime` for temporal and `setValueAtTime` with spatial tangents for spatial properties.

## Related

- [Claude Code for Blender Python Scripting](/claude-code-blender-python-scripting-2026/)
- [Claude Code for Three.js 3D Scene Development](/claude-code-threejs-3d-scene-development-2026/)
- [Claude Code for Processing and p5.js Creative Coding](/claude-code-processing-p5js-creative-coding-2026/)


## Frequently Asked Questions

### Do I need a paid Anthropic plan to use this?

Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours.

### How does this affect token usage and cost?

The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing.

### Can I customize this for my specific project?

Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start.

### What happens when Claude Code makes a mistake?

Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json.


## Practical Details

When working with Claude Code on this topic, keep these implementation details in mind:

**Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations.

**Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code.

**Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%.

**Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results.


## Related Guides

- [Before and After](/before-and-after-switching-to-claude-code-workflow/)
- [PATH Not Updated After Install — Fix](/claude-code-path-not-updated-after-install-fix-2026/)
- [Prisma Generate Failure After Schema](/claude-code-prisma-generate-failure-fix-2026/)
- [Fix Claude Code Not Working After](/claude-code-not-working-after-update-how-to-fix/)


## Implementation Details

When working with this in Claude Code, pay attention to these practical details:

**Project configuration.** Add specific instructions to your CLAUDE.md file describing how your project handles this area. Include file paths, naming conventions, and any patterns that differ from common defaults. Claude Code reads CLAUDE.md at the start of every session and uses it to guide all operations.

**Testing the setup.** After configuration, verify everything works by running a simple test task. Ask Claude Code to perform a read-only operation first (like listing files or reading a config) before moving to write operations. This confirms that permissions, paths, and tools are all correctly configured.

**Monitoring and iteration.** Track your results over several sessions. If Claude Code consistently makes the same mistake, the fix is usually a more specific CLAUDE.md instruction. If it makes different mistakes each time, the issue is likely in the project setup or toolchain configuration.

## Troubleshooting Checklist

When something does not work as expected, check these items in order:

1. **CLAUDE.md exists at the project root** — run `ls -la CLAUDE.md` to verify
2. **Node.js version is 18+** — run `node --version` to check
3. **API key is set** — run `echo $ANTHROPIC_API_KEY | head -c 10` to verify (shows first 10 characters only)
4. **Disk space is available** — run `df -h .` to check
5. **Network can reach the API** — run `curl -s -o /dev/null -w "%{http_code}" https://api.anthropic.com` (should return 401 without auth, meaning the server is reachable)
6. **No conflicting processes** — run `ps aux | grep claude | grep -v grep` to check for stale sessions

<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Do I need a paid Anthropic plan to use this?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), .claude/settings.json (permissions), and .claude/skills/ (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code..."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in git diff. If a change is wrong, revert it with git checkout -- <file> for a single file or git stash for all changes."
      }
    }
  ]
}
</script>
