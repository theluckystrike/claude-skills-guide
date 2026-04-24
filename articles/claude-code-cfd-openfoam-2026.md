---
title: "Claude Code for CFD with OpenFOAM"
permalink: /claude-code-cfd-openfoam-2026/
description: "Computational fluid dynamics with Claude Code and OpenFOAM. Automate mesh generation, solver setup, and post-processing."
last_tested: "2026-04-22"
render_with_liquid: false
---
{% raw %}


## Why Claude Code for CFD (OpenFOAM)

OpenFOAM is the most widely used open-source CFD toolkit, but its dictionary-based configuration system is notoriously unforgiving. A simulation requires coordinating blockMeshDict (mesh generation), transportProperties (fluid properties), turbulenceProperties (turbulence model selection), fvSchemes (numerical discretization), fvSolution (linear solver settings), and controlDict (time stepping) -- all plain text files with no schema validation. A typo in a boundary condition name compiles fine but produces divergent results after hours of compute.

Claude Code generates syntactically correct OpenFOAM dictionaries from physical problem descriptions, validates boundary condition consistency across all field files, and produces paraFoam/ParaView post-processing scripts. It knows which solver (simpleFoam vs pimpleFoam vs interFoam) matches your physics and which discretization schemes are stable for your flow regime.

## The Workflow

### Step 1: OpenFOAM Case Setup

```bash
# Source OpenFOAM environment
source /opt/openfoam11/etc/bashrc  # or openfoam2312

# Create case from template
mkdir -p pipe_flow/{0,constant,system}

# Verify installation
which blockMesh simpleFoam checkMesh
```

### Step 2: Generate Case Files

```python
# src/openfoam_generator.py
"""Generate OpenFOAM case files for pipe flow simulation."""

from pathlib import Path

def generate_block_mesh_dict(case_dir: str,
                              pipe_length: float = 1.0,
                              pipe_radius: float = 0.05,
                              cells_axial: int = 200,
                              cells_radial: int = 40) -> None:
    """Generate blockMeshDict for a 2D axisymmetric pipe."""
    content = f"""FoamFile
{{
    version     2.0;
    format      ascii;
    class       dictionary;
    object      blockMeshDict;
}}

convertToMeters 1;

vertices
(
    (0       0       0)              // 0
    ({pipe_length} 0 0)              // 1
    ({pipe_length} {pipe_radius} 0)  // 2
    (0       {pipe_radius} 0)        // 3
    (0       0       0.01)           // 4 (wedge z+)
    ({pipe_length} 0 0.01)           // 5
    ({pipe_length} {pipe_radius} 0.01) // 6
    (0       {pipe_radius} 0.01)     // 7
);

blocks
(
    hex (0 1 2 3 4 5 6 7)
    ({cells_axial} {cells_radial} 1)
    simpleGrading (1 0.2 1)  // Wall refinement: grade toward pipe wall
);

boundary
(
    inlet
    {{
        type patch;
        faces ((0 3 7 4));
    }}
    outlet
    {{
        type patch;
        faces ((1 5 6 2));
    }}
    wall
    {{
        type wall;
        faces ((3 2 6 7));
    }}
    axis
    {{
        type symmetryPlane;
        faces ((0 4 5 1));
    }}
    front
    {{
        type empty;
        faces ((0 1 2 3));
    }}
    back
    {{
        type empty;
        faces ((4 5 6 7));
    }}
);
"""
    Path(f"{case_dir}/system").mkdir(parents=True, exist_ok=True)
    with open(f"{case_dir}/system/blockMeshDict", 'w') as f:
        f.write(content)

def generate_control_dict(case_dir: str,
                           end_time: float = 1.0,
                           write_interval: float = 0.1,
                           solver: str = "simpleFoam") -> None:
    """Generate controlDict for steady-state or transient simulation."""
    if solver == "simpleFoam":
        time_scheme = "steadyState"
        dt = 1  # iteration count for SIMPLE
    else:
        time_scheme = "adjustable"
        dt = 1e-4

    content = f"""FoamFile
{{
    version     2.0;
    format      ascii;
    class       dictionary;
    object      controlDict;
}}

application     {solver};
startFrom       startTime;
startTime       0;
stopAt          endTime;
endTime         {end_time};
deltaT          {dt};
writeControl    timeStep;
writeInterval   {int(end_time / write_interval)};
purgeWrite      3;
writeFormat     ascii;
writePrecision  8;
writeCompression off;
timeFormat      general;
timePrecision   6;
runTimeModifiable true;

functions
{{
    fieldAverage1
    {{
        type            fieldAverage;
        libs            ("libfieldFunctionObjects.so");
        writeControl    writeTime;
        fields
        (
            U
            {{
                mean        on;
                prime2Mean  on;
                base        time;
            }}
            p
            {{
                mean        on;
                prime2Mean  off;
                base        time;
            }}
        );
    }}

    wallShearStress
    {{
        type            wallShearStress;
        libs            ("libfieldFunctionObjects.so");
        writeControl    writeTime;
        patches         (wall);
    }}
}}
"""
    with open(f"{case_dir}/system/controlDict", 'w') as f:
        f.write(content)

def generate_fv_schemes(case_dir: str, turbulent: bool = True) -> None:
    """Generate fvSchemes with appropriate discretization."""
    content = f"""FoamFile
{{
    version     2.0;
    format      ascii;
    class       dictionary;
    object      fvSchemes;
}}

ddtSchemes
{{
    default         steadyState;
}}

gradSchemes
{{
    default         Gauss linear;
    grad(p)         Gauss linear;
    grad(U)         cellLimited Gauss linear 1;
}}

divSchemes
{{
    default         none;
    div(phi,U)      bounded Gauss linearUpwind grad(U);
    div(phi,k)      bounded Gauss upwind;
    div(phi,omega)  bounded Gauss upwind;
    div(phi,epsilon) bounded Gauss upwind;
    div((nuEff*dev2(T(grad(U))))) Gauss linear;
}}

laplacianSchemes
{{
    default         Gauss linear corrected;
}}

interpolationSchemes
{{
    default         linear;
}}

snGradSchemes
{{
    default         corrected;
}}
"""
    with open(f"{case_dir}/system/fvSchemes", 'w') as f:
        f.write(content)

def generate_initial_conditions(case_dir: str,
                                 inlet_velocity: float = 1.0,
                                 kinematic_viscosity: float = 1e-6
                                 ) -> None:
    """Generate 0/ directory boundary condition files."""
    Path(f"{case_dir}/0").mkdir(parents=True, exist_ok=True)

    # Velocity field
    u_content = f"""FoamFile
{{
    version     2.0;
    format      ascii;
    class       volVectorField;
    object      U;
}}

dimensions      [0 1 -1 0 0 0 0];
internalField   uniform (0 0 0);

boundaryField
{{
    inlet
    {{
        type            fixedValue;
        value           uniform ({inlet_velocity} 0 0);
    }}
    outlet
    {{
        type            zeroGradient;
    }}
    wall
    {{
        type            noSlip;
    }}
    axis
    {{
        type            symmetryPlane;
    }}
    front
    {{
        type            empty;
    }}
    back
    {{
        type            empty;
    }}
}}
"""
    with open(f"{case_dir}/0/U", 'w') as f:
        f.write(u_content)

    # Pressure field
    p_content = f"""FoamFile
{{
    version     2.0;
    format      ascii;
    class       volScalarField;
    object      p;
}}

dimensions      [0 2 -2 0 0 0 0];
internalField   uniform 0;

boundaryField
{{
    inlet
    {{
        type            zeroGradient;
    }}
    outlet
    {{
        type            fixedValue;
        value           uniform 0;
    }}
    wall
    {{
        type            zeroGradient;
    }}
    axis
    {{
        type            symmetryPlane;
    }}
    front
    {{
        type            empty;
    }}
    back
    {{
        type            empty;
    }}
}}
"""
    with open(f"{case_dir}/0/p", 'w') as f:
        f.write(p_content)
```

### Step 3: Run and Post-Process

```bash
# Generate case files
python3 -c "
from src.openfoam_generator import *
case = 'pipe_flow'
generate_block_mesh_dict(case, pipe_length=1.0, pipe_radius=0.05)
generate_control_dict(case, end_time=1000, write_interval=100)
generate_fv_schemes(case)
generate_initial_conditions(case, inlet_velocity=1.0)
print('Case files generated')
"

# Run OpenFOAM
cd pipe_flow
blockMesh && checkMesh && simpleFoam
# Post-process
postProcess -func 'patchAverage(name=outlet, p)'
```

### Step 4: Verify Mesh Quality

```bash
checkMesh 2>&1 | tail -20
# Expected: "Mesh OK" with max non-orthogonality < 70, max skewness < 4
```

## CLAUDE.md for CFD (OpenFOAM)

```markdown
# OpenFOAM CFD Development

## Solver Selection
- simpleFoam: steady-state incompressible (SIMPLE)
- pimpleFoam: transient incompressible (PIMPLE = PISO + SIMPLE)
- interFoam: two-phase VOF (free surface)
- buoyantSimpleFoam: buoyancy-driven (natural convection)
- rhoCentralFoam: compressible (shocks, supersonic)

## Mesh Quality Thresholds
- Max non-orthogonality < 70 degrees (warning at 65)
- Max skewness < 4.0
- Max aspect ratio < 100 for boundary layer cells
- First cell y+ ~ 1 for k-omega SST, y+ ~ 30 for wall functions

## Common Commands
- blockMesh — generate structured hex mesh
- snappyHexMesh — generate unstructured mesh around geometry
- checkMesh — validate mesh quality
- simpleFoam / pimpleFoam — run solver
- paraFoam — launch ParaView for visualization
- postProcess -func 'Ux' — extract field components
- foamLog log.simpleFoam — parse residual history
```

## Common Pitfalls

- **Boundary condition name mismatch:** A patch named "inlet" in blockMeshDict but "Inlet" in 0/U causes a runtime crash with an unhelpful error message. Claude Code validates boundary patch names across all files before you run the solver.
- **Wrong turbulence wall treatment:** Using kqRWallFunction with y+ < 5 gives wrong shear stress; nutUSpaldingWallFunction works across all y+ values. Claude Code selects the wall function based on your estimated y+ and mesh resolution.
- **Divergence from unstable schemes:** Using Gauss linear for convection in high-Re flows causes oscillations. Claude Code defaults to bounded linearUpwind for velocity and upwind for turbulence quantities, switching to higher-order only when the mesh supports it.

## Related

- [Claude Code for FEA Mesh Generation](/claude-code-fea-mesh-generation-2026/)
- [Claude Code for Climate Model Data Processing](/claude-code-climate-model-netcdf-processing-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
{% endraw %}
