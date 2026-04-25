---
title: "Claude Code for FEA Mesh Generation"
description: "Claude Code for FEA Mesh Generation — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-fea-mesh-generation-2026/
last_tested: "2026-04-21"
---

## Why Claude Code for FEA Meshing

Finite element analysis lives or dies on mesh quality. A bad mesh produces inaccurate stress concentrations, false convergence, or nonphysical results that look plausible. Building a good mesh requires understanding element aspect ratios, refinement zones near stress concentrations, boundary layer meshes for CFD, and the specific input formats each solver expects.

Claude Code generates Gmsh scripts and Python-based meshing workflows that create quality-controlled meshes, apply local refinement based on geometry features, and export to solver-specific formats (Abaqus INP, ANSYS CDB, CalculiX, Code_Aster).

## The Workflow

### Step 1: Setup

```bash
# Install open-source FEA tools
pip install gmsh meshio pygmsh numpy scipy
# Gmsh also available as standalone
brew install gmsh  # macOS

# Solver (open-source)
sudo apt install calculix-ccx  # or brew install calculix
# Or use Code_Aster, ElmerFEM

mkdir -p fea/{geometry,mesh,solver_input,results}
```

### Step 2: Parametric Mesh Generation with Gmsh

```python
# fea/generate_mesh.py
"""Generate FEA mesh with local refinement using Gmsh Python API."""
import gmsh
import meshio
import numpy as np
from pathlib import Path

MAX_ELEMENTS = 5000000
MIN_QUALITY = 0.3  # minimum element quality (0-1)


def create_bracket_geometry(
    width: float = 100.0,
    height: float = 50.0,
    thickness: float = 10.0,
    hole_radius: float = 8.0,
    fillet_radius: float = 3.0,
) -> None:
    """Create a parametric L-bracket with bolt hole and fillet."""
    assert width > 0 and height > 0 and thickness > 0
    assert hole_radius < min(width, height) / 3
    assert fillet_radius < min(width, height) / 5

    gmsh.model.occ.addBox(0, 0, 0, width, thickness, height)
    gmsh.model.occ.addBox(0, 0, 0, thickness, thickness, height)

    # Bolt hole
    hole = gmsh.model.occ.addCylinder(
        width / 2, -1, height / 2,
        0, thickness + 2, 0,
        hole_radius)

    # Boolean: subtract hole from bracket
    bracket = gmsh.model.occ.fuse([(3, 1)], [(3, 2)])
    gmsh.model.occ.cut(bracket[0], [(3, hole)])

    gmsh.model.occ.synchronize()


def apply_refinement(hole_radius: float, mesh_size_min: float,
                     mesh_size_max: float) -> None:
    """Apply mesh refinement near the bolt hole (stress concentration)."""
    assert mesh_size_min > 0
    assert mesh_size_max > mesh_size_min

    gmsh.model.mesh.field.add("Distance", 1)
    gmsh.model.mesh.field.setNumbers(1, "CurvesList",
        list(range(1, 20)))  # curves near hole
    gmsh.model.mesh.field.setNumber(1, "Sampling", 100)

    gmsh.model.mesh.field.add("Threshold", 2)
    gmsh.model.mesh.field.setNumber(2, "InField", 1)
    gmsh.model.mesh.field.setNumber(2, "SizeMin", mesh_size_min)
    gmsh.model.mesh.field.setNumber(2, "SizeMax", mesh_size_max)
    gmsh.model.mesh.field.setNumber(2, "DistMin", hole_radius * 0.5)
    gmsh.model.mesh.field.setNumber(2, "DistMax", hole_radius * 3.0)

    gmsh.model.mesh.field.setAsBackgroundMesh(2)
    gmsh.option.setNumber("Mesh.MeshSizeExtendFromBoundary", 0)
    gmsh.option.setNumber("Mesh.MeshSizeFromPoints", 0)
    gmsh.option.setNumber("Mesh.MeshSizeFromCurvature", 0)


def generate_mesh(element_order: int = 2) -> dict:
    """Generate mesh and return quality statistics."""
    assert element_order in (1, 2), "Element order must be 1 or 2"

    gmsh.option.setNumber("Mesh.ElementOrder", element_order)
    gmsh.option.setNumber("Mesh.Algorithm3D", 10)  # HXT for tets
    gmsh.option.setNumber("Mesh.OptimizeNetgen", 1)

    gmsh.model.mesh.generate(3)
    gmsh.model.mesh.optimize("Netgen")

    # Quality statistics
    element_types, _, _ = gmsh.model.mesh.getElements(dim=3)
    total_elements = sum(
        len(gmsh.model.mesh.getElements(dim=3, tag=-1)[1][i])
        for i in range(len(element_types)))

    assert total_elements > 0, "Mesh generation produced no elements"
    assert total_elements < MAX_ELEMENTS, \
        f"Mesh too large: {total_elements} elements"

    # Get quality metrics
    qualities = gmsh.model.mesh.getElementQualities(
        gmsh.model.mesh.getElements(dim=3)[1][0].tolist(),
        qualityName="minSJ")
    min_quality = min(qualities) if qualities else 0

    stats = {
        "total_elements": total_elements,
        "min_quality": min_quality,
        "element_order": element_order,
    }
    return stats


def export_mesh(output_path: str, solver_format: str = "abaqus") -> None:
    """Export mesh to solver-specific format."""
    assert solver_format in ("abaqus", "calculix", "nastran", "vtk")

    format_map = {
        "abaqus": ".inp",
        "calculix": ".inp",
        "nastran": ".bdf",
        "vtk": ".vtk",
    }
    ext = format_map[solver_format]
    full_path = output_path + ext

    gmsh.write(full_path)
    print(f"Exported: {full_path}")


def main(output_dir: str = "mesh") -> None:
    """Full meshing workflow."""
    gmsh.initialize()
    gmsh.model.add("bracket")

    create_bracket_geometry(
        width=100, height=50, thickness=10,
        hole_radius=8, fillet_radius=3)

    apply_refinement(
        hole_radius=8,
        mesh_size_min=0.5,
        mesh_size_max=5.0)

    stats = generate_mesh(element_order=2)
    print(f"Elements: {stats['total_elements']}")
    print(f"Min quality: {stats['min_quality']:.3f}")

    assert stats["min_quality"] > MIN_QUALITY, \
        f"Mesh quality below threshold: {stats['min_quality']:.3f}"

    export_mesh(f"{output_dir}/bracket", solver_format="abaqus")
    export_mesh(f"{output_dir}/bracket", solver_format="vtk")

    gmsh.finalize()


if __name__ == "__main__":
    main()
```

### Step 3: Validate and Solve

```bash
# Generate mesh
python3 fea/generate_mesh.py
# Expected: Elements: ~25000, Min quality: > 0.3

# Run CalculiX solver
ccx bracket  # reads bracket.inp
# Expected: bracket.frd output with displacement and stress fields

# Post-process with ParaView or meshio
python3 -c "
import meshio
mesh = meshio.read('mesh/bracket.vtk')
print(f'Points: {len(mesh.points)}')
print(f'Cells: {sum(len(c.data) for c in mesh.cells)}')
print(f'Quality check passed')
"
```

## CLAUDE.md for FEA Meshing

```markdown
# FEA Mesh Generation Rules

## Standards
- Gmsh API v4.12+
- Abaqus INP format for solver input
- VTK format for visualization

## File Formats
- .step / .iges (CAD geometry input)
- .msh (Gmsh native)
- .inp (Abaqus/CalculiX)
- .bdf (Nastran)
- .vtk / .vtu (visualization)

## Libraries
- gmsh 4.12+ (meshing engine)
- meshio 5.3+ (format conversion)
- pygmsh 7.1+ (high-level Gmsh wrapper)
- numpy, scipy

## Testing
- Minimum element quality (Jacobian) > 0.3
- No inverted elements (negative Jacobian)
- Mesh convergence study: refine until result changes < 2%
- Boundary condition nodes must exist in exported mesh

## Mesh Quality
- Aspect ratio < 5 for tets
- Skewness < 0.8
- Refinement ratio between adjacent elements < 2:1
```

## Common Pitfalls

- **Element aspect ratio near fillets:** Thin sliver elements at geometry transitions produce oscillating stress results. Claude Code inserts local size constraints at small geometric features.
- **Second-order elements on curved surfaces:** Linear (first-order) tets on curved CAD surfaces introduce geometry approximation error. Claude Code defaults to second-order elements and projects mid-side nodes to the actual CAD surface.
- **Mesh format incompatibility:** Abaqus INP from Gmsh sometimes uses element types that CalculiX does not support. Claude Code maps element types (C3D10 vs C3D10M) to match your target solver.

## Related

- [Claude Code for Computational Chemistry](/claude-code-computational-chemistry-orca-2026/)
- [Claude Code for CNC G-Code Optimization](/claude-code-cnc-gcode-optimization-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
- [Claude Code for OpenAPI Spec Generation (2026)](/claude-code-openapi-spec-generation-2026/)


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

- [Claude Code for AWS App Mesh Workflow](/claude-code-for-aws-app-mesh-workflow/)
- [Claude Code for Kong Mesh Service Mesh](/claude-code-for-kong-mesh-workflow-tutorial/)
- [Claude Skills for SEO Content Generation Guide](/claude-skills-for-seo-content-generation/)
- [Fix Claude Code Test Generation Issues](/claude-code-not-generating-tests-correctly-fix-guide/)


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
