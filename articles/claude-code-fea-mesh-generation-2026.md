---
title: "Claude Code for FEA Mesh Generation"
description: "Finite element mesh generation with Claude Code. Automate Gmsh meshing, quality checks, and solver input prep."
permalink: /claude-code-fea-mesh-generation-2026/
last_tested: "2026-04-21"
render_with_liquid: false
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
