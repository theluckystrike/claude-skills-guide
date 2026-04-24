---
title: "Claude Code for Blender Python (2026)"
description: "Blender Python scripting workflow with Claude Code. Automate 3D asset pipelines, procedural generation, and batch rendering."
permalink: /claude-code-blender-python-scripting-2026/
last_tested: "2026-04-21"
---

## Why Claude Code for Blender Scripting

Blender's Python API (bpy) exposes over 10,000 functions across mesh operations, materials, modifiers, constraints, and rendering. The API changes between major versions, documentation is scattered across wiki pages and source code, and common tasks like batch-processing 500 FBX files or generating procedural geometry require 100+ lines of bpy calls that are hard to discover.

Claude Code generates working bpy scripts that target your Blender version, use the correct context overrides for headless operation, and handle the operator polling that causes "context is incorrect" errors. It produces scripts for procedural modeling, automated UV unwrapping, batch export, and render farm job generation.

## The Workflow

### Step 1: Setup

```bash
# Blender 4.x with Python module
# macOS
brew install blender
# Verify Python access
blender --background --python-expr "import bpy; print(bpy.app.version_string)"

# For headless/CI usage
pip install fake-bpy-module-4.0  # type stubs for IDE completion

mkdir -p blender/{scripts,assets,output}
```

### Step 2: Procedural Asset Generator

```python
# blender/scripts/procedural_building.py
"""Generate procedural building geometry in Blender."""
import bpy
import bmesh
import math
import random
from mathutils import Vector

MAX_FLOORS = 200
MAX_WINDOWS_PER_FLOOR = 50
MIN_DIMENSION = 0.1


def clear_scene() -> None:
    """Remove all objects from the current scene."""
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    assert len(bpy.data.objects) == 0, "Scene not cleared"


def create_floor_plate(width: float, depth: float,
                       height: float, floor_num: int) -> bpy.types.Object:
    """Create a single floor of the building."""
    assert width > MIN_DIMENSION, f"Width too small: {width}"
    assert depth > MIN_DIMENSION, f"Depth too small: {depth}"
    assert height > MIN_DIMENSION, f"Height too small: {height}"

    bpy.ops.mesh.primitive_cube_add(
        size=1,
        location=(0, 0, floor_num * height + height / 2))

    obj = bpy.context.active_object
    obj.name = f"Floor_{floor_num:03d}"
    obj.scale = (width, depth, height)

    # Apply scale
    bpy.ops.object.transform_apply(scale=True)
    assert obj is not None, "Floor object creation failed"

    return obj


def add_windows(floor_obj: bpy.types.Object,
                window_width: float = 1.2,
                window_height: float = 1.5,
                spacing: float = 3.0,
                inset_depth: float = 0.15) -> int:
    """Boolean-cut windows into a floor plate."""
    assert floor_obj is not None
    assert window_width > 0 and window_height > 0

    dims = floor_obj.dimensions
    n_windows_x = max(1, int((dims.x - spacing) / spacing))
    n_windows_y = max(1, int((dims.y - spacing) / spacing))

    assert n_windows_x <= MAX_WINDOWS_PER_FLOOR
    assert n_windows_y <= MAX_WINDOWS_PER_FLOOR

    window_count = 0
    floor_z = floor_obj.location.z

    # Front and back faces
    for i in range(n_windows_x):
        x_pos = -dims.x / 2 + spacing + i * spacing
        for y_sign in (-1, 1):
            y_pos = y_sign * dims.y / 2

            bpy.ops.mesh.primitive_cube_add(
                size=1,
                location=(x_pos, y_pos, floor_z))
            window = bpy.context.active_object
            window.name = f"Window_temp_{window_count}"
            window.scale = (window_width, inset_depth * 2, window_height)
            bpy.ops.object.transform_apply(scale=True)

            # Boolean difference
            mod = floor_obj.modifiers.new("Window", 'BOOLEAN')
            mod.operation = 'DIFFERENCE'
            mod.object = window
            bpy.context.view_layer.objects.active = floor_obj
            bpy.ops.object.modifier_apply(modifier="Window")

            bpy.data.objects.remove(window)
            window_count += 1

    return window_count


def create_building(num_floors: int = 10, width: float = 20.0,
                    depth: float = 12.0, floor_height: float = 3.5,
                    add_detail: bool = True) -> bpy.types.Object:
    """Generate a complete procedural building."""
    assert 1 <= num_floors <= MAX_FLOORS, \
        f"Floor count {num_floors} out of range"

    clear_scene()

    floor_objects = []
    for i in range(num_floors):
        # Slight width variation for visual interest
        w = width * (1.0 - i * 0.005)
        d = depth * (1.0 - i * 0.005)
        floor = create_floor_plate(w, d, floor_height, i)

        if add_detail and i > 0:
            add_windows(floor, spacing=3.0)

        floor_objects.append(floor)

    # Join all floors into one object
    bpy.ops.object.select_all(action='SELECT')
    bpy.context.view_layer.objects.active = floor_objects[0]
    bpy.ops.object.join()

    building = bpy.context.active_object
    building.name = "Procedural_Building"

    # Add material
    mat = bpy.data.materials.new("Building_Concrete")
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (0.65, 0.62, 0.58, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.85
    building.data.materials.append(mat)

    assert building is not None, "Building creation failed"
    print(f"Created building: {num_floors} floors, "
          f"{len(building.data.vertices)} vertices")

    return building


def batch_export(directory: str, format: str = "FBX") -> None:
    """Export all objects in scene to individual files."""
    assert format in ("FBX", "OBJ", "GLTF"), f"Unknown format: {format}"

    export_funcs = {
        "FBX": lambda p: bpy.ops.export_scene.fbx(filepath=p, use_selection=True),
        "OBJ": lambda p: bpy.ops.export_scene.obj(filepath=p, use_selection=True),
        "GLTF": lambda p: bpy.ops.export_scene.gltf(filepath=p, use_selection=True),
    }

    for obj in bpy.data.objects:
        bpy.ops.object.select_all(action='DESELECT')
        obj.select_set(True)
        filepath = f"{directory}/{obj.name}.{format.lower()}"
        export_funcs[format](filepath)
        print(f"Exported: {filepath}")


if __name__ == "__main__":
    building = create_building(
        num_floors=15, width=24.0, depth=14.0,
        floor_height=3.2, add_detail=True)

    # Render
    bpy.context.scene.render.engine = 'CYCLES'
    bpy.context.scene.cycles.samples = 128
    bpy.context.scene.render.filepath = "output/building_render.png"
    bpy.ops.render.render(write_still=True)
    print("Render complete: output/building_render.png")
```

### Step 3: Run Headless

```bash
# Run script in headless Blender
blender --background --python blender/scripts/procedural_building.py
# Expected: building_render.png in output/

# Batch processing pipeline
for file in assets/*.fbx; do
  blender --background --python scripts/process_asset.py -- "$file"
done
```

## CLAUDE.md for Blender Scripting

```markdown
# Blender Python Scripting Rules

## Standards
- Blender 4.x Python API (bpy)
- PEP 8 for script formatting
- Headless-compatible (--background flag)

## File Formats
- .py (Blender scripts)
- .blend (Blender project)
- .fbx / .gltf / .obj (exchange formats)
- .exr / .png (render output)

## Libraries
- bpy (Blender Python API)
- bmesh (mesh editing API)
- mathutils (Vector, Matrix, Quaternion)
- fake-bpy-module-4.0 (IDE type stubs)

## Testing
- Scripts must run headless (no GUI dependency)
- Verify mesh integrity: no zero-area faces, no isolated vertices
- Render output resolution must match scene settings

## Rules
- Always apply transforms before export
- Clear scene before procedural generation
- Use bmesh for complex mesh operations (faster than operators)
- Context overrides for operators that require specific context
```

## Common Pitfalls

- **"Context is incorrect" errors:** Many bpy.ops operators require specific active objects or edit modes. Claude Code wraps operator calls with proper context overrides and mode switches.

For more on this topic, see [Best Claude Code Plugins for Python](/best-claude-code-plugins-python-2026/).

- **Memory leaks in batch processing:** Blender accumulates orphan data blocks across iterations. Claude Code adds `bpy.ops.outliner.orphans_purge(do_recursive=True)` between batch iterations.
- **API changes between versions:** bpy.context.scene.render.engine changed between 3.x and 4.x. Claude Code checks `bpy.app.version` and uses version-appropriate API calls.

## Related

- [Claude Code for Unity Shader Development](/claude-code-unity-hlsl-shader-development-2026/)
- [Claude Code for Beginners](/claude-code-for-beginners-complete-getting-started-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)


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

- [Python Virtualenv Not Activated Fix — Fix (2026)](/claude-code-python-virtualenv-not-activated-fix-2026/)
- [Migrate VBA Excel Macros to Python](/claude-code-vba-excel-macros-to-python-migration/)
- [Best AI Coding Tools for Python (2026)](/best-ai-coding-tools-python-comparison-2026/)
- [Claude Code For Rye Python](/claude-code-for-rye-python-project-workflow-guide/)

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
        "text": "Claude Code works with any Anthropic API plan, including the free tier. However, the free tier has lower rate limits (requests per minute and tokens per minute) that may slow down multi-step workflows. For professional use, the Build or Scale plan provides higher limits and priority access during peak hours."
      }
    },
    {
      "@type": "Question",
      "name": "How does this affect token usage and cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The token cost depends on the size of your prompts and Claude's responses. Typical development tasks consume 10K-50K tokens per interaction. Using a CLAUDE.md file and skills reduces exploration tokens by 50-80%, which directly lowers costs. Monitor your usage at console.anthropic.com/settings/billing."
      }
    },
    {
      "@type": "Question",
      "name": "Can I customize this for my specific project?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. All Claude Code behavior can be customized through CLAUDE.md (project rules), `.claude/settings.json` (permissions), and `.claude/skills/` (domain knowledge). The most impactful customization is adding your project's specific patterns, conventions, and common commands to CLAUDE.md so Claude Code follows your standards from the start."
      }
    },
    {
      "@type": "Question",
      "name": "What happens when Claude Code makes a mistake?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Claude Code creates files and edits through standard filesystem operations, so all changes are visible in `git diff`. If a change is wrong, revert it with `git checkout -- <file>` for a single file or `git stash` for all changes. Claude Code does not make irreversible changes unless you explicitly allow destructive commands in settings.json. When working with Claude Code on this topic, keep these implementation details in mind: **Project Configuration.** Your CLAUDE.md should include specific references to how your project handles this area. Include file paths, naming conventions, and any project-specific patterns that differ from defaults. Claude Code reads this file at session start and uses it to guide all operations. **Integration with Existing Tools.** Claude Code works alongside your existing development tools rather than replacing them. It respects .gitignore for file visibility, uses your project's installed dependencies, and follows the build/test scripts defined in package.json (or equivalent). Ensure your toolchain is working correctly before involving Claude Code. **Performance Considerations.** For large codebases (10,000+ files), Claude Code's file scanning can be slow if not properly scoped. Use `.claudeignore` to exclude generated directories (dist, build, .next, coverage) and dependency directories (node_modules, vendor). This typically reduces scan time by 80-90%. **Version Control Integration.** All changes Claude Code makes are regular filesystem operations visible to git. Use `git diff` after each significant change to review what was modified. For experimental changes, create a branch first with `git checkout -b experiment/topic` so you can easily discard or keep the results."
      }
    }
  ]
}
</script>
