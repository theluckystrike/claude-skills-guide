---
layout: default
title: "Claude Code for Materials Science (2026)"
permalink: /claude-code-materials-science-vasp-lammps-2026/
date: 2026-04-20
description: "Claude Code for Materials Science — practical guide with working examples, tested configurations, and tips for developer workflows."
last_tested: "2026-04-22"
render_with_liquid: false
---
{% raw %}


## Why Claude Code for Materials Science Simulation

First-principles calculations with VASP (Vienna Ab initio Simulation Package) and classical molecular dynamics with LAMMPS (Large-scale Atomic/Molecular Massively Parallel Simulator) require intricate input files where a single wrong parameter -- a k-point mesh too coarse for a metallic system, a timestep too large for a stiff potential -- invalidates days of HPC compute time. VASP alone has over 300 input tags across INCAR, KPOINTS, POSCAR, and POTCAR files that interact in non-obvious ways.

Claude Code generates VASP input sets that follow computational materials science best practices, builds LAMMPS scripts with proper potential selection and ensemble control, and creates post-processing workflows that extract elastic constants, band structures, and diffusion coefficients from raw output files.

## The Workflow

### Step 1: Simulation Environment Setup

```bash
pip install pymatgen ase  # Materials science Python libraries
pip install phonopy       # Phonon calculations
pip install atomsk        # Atomic model manipulation

mkdir -p vasp/{relax,static,band,dos} lammps/ analysis/
```

### Step 2: Generate VASP Input Files

```python
# src/vasp_generator.py
"""Generate VASP input files for DFT calculations.
Uses pymatgen for structure manipulation and input set generation.
"""

from pymatgen.core import Structure, Lattice
from pymatgen.io.vasp import Incar, Kpoints, Poscar, Potcar
from pymatgen.io.vasp.sets import MPRelaxSet, MPStaticSet
from pathlib import Path

def create_relaxation_inputs(structure: Structure,
                              output_dir: str,
                              encut: float = 520.0,
                              kpoints_density: int = 64
                              ) -> None:
    """Generate VASP inputs for ionic relaxation.
    Follows Materials Project conventions.
    """
    Path(output_dir).mkdir(parents=True, exist_ok=True)

    relax_set = MPRelaxSet(structure)

    # Custom INCAR overrides
    incar = relax_set.incar
    incar['ENCUT'] = encut           # Plane-wave cutoff (eV)
    incar['EDIFF'] = 1e-6            # Electronic convergence (eV)
    incar['EDIFFG'] = -0.02          # Ionic convergence (eV/Angstrom)
    incar['ISMEAR'] = 1              # Methfessel-Paxton for metals
    incar['SIGMA'] = 0.2             # Smearing width (eV)
    incar['ISPIN'] = 2               # Spin-polarized
    incar['LREAL'] = 'Auto'          # Real-space projection
    incar['ALGO'] = 'Fast'           # Davidson + RMM-DIIS
    incar['ISIF'] = 3                # Relax cell shape + volume + ions
    incar['NSW'] = 100               # Max ionic steps
    incar['PREC'] = 'Accurate'
    incar['LWAVE'] = False           # Don't write WAVECAR (save disk)
    incar['LCHARG'] = False

    incar.write_file(f"{output_dir}/INCAR")

    # KPOINTS: Gamma-centered mesh
    kpoints = Kpoints.automatic_density(structure, kpoints_density)
    kpoints.write_file(f"{output_dir}/KPOINTS")

    # POSCAR: Structure file
    poscar = Poscar(structure)
    poscar.write_file(f"{output_dir}/POSCAR")

    # POTCAR: Pseudopotentials (requires VASP license)
    # potcar = Potcar(relax_set.potcar_symbols)
    # potcar.write_file(f"{output_dir}/POTCAR")

    print(f"VASP inputs written to {output_dir}/")
    print(f"  ENCUT: {encut} eV")
    print(f"  K-mesh: {kpoints.kpts}")
    print(f"  Atoms: {structure.num_sites}")

def create_band_structure_inputs(structure: Structure,
                                  output_dir: str) -> None:
    """Generate VASP inputs for band structure calculation."""
    Path(output_dir).mkdir(parents=True, exist_ok=True)

    static_set = MPStaticSet(structure)
    incar = static_set.incar
    incar['ICHARG'] = 11     # Read charge density from static calc
    incar['ISMEAR'] = 0      # Tetrahedron method not valid for line mode
    incar['SIGMA'] = 0.05
    incar['LORBIT'] = 11     # Projected DOS
    incar['LWAVE'] = False
    incar['LCHARG'] = False
    incar.write_file(f"{output_dir}/INCAR")

    # High-symmetry k-path
    from pymatgen.symmetry.bandstructure import HighSymmKpath
    kpath = HighSymmKpath(structure)
    kpoints = Kpoints.automatic_linemode(20, kpath)
    kpoints.write_file(f"{output_dir}/KPOINTS")

    Poscar(structure).write_file(f"{output_dir}/POSCAR")
    print(f"Band structure inputs written to {output_dir}/")

# Example: FCC Aluminum
al_structure = Structure(
    Lattice.cubic(4.05),
    ["Al"],
    [[0, 0, 0]]
)
```

### Step 3: Build LAMMPS Molecular Dynamics Script

```python
# src/lammps_generator.py
"""Generate LAMMPS input scripts for classical MD simulations."""

def generate_lammps_melt_quench(element: str = "Cu",
                                 lattice_const: float = 3.615,
                                 supercell: tuple = (10, 10, 10),
                                 potential: str = "Cu_mishin.eam.alloy",
                                 melt_temp: int = 2000,
                                 quench_rate: float = 1e12,
                                 ) -> str:
    """Generate LAMMPS script for melt-quench simulation.
    Used for amorphous metal production and glass transition studies.
    """
    nx, ny, nz = supercell
    total_atoms = 4 * nx * ny * nz  # FCC: 4 atoms per unit cell

    script = f"""# LAMMPS melt-quench simulation for {element}
# Generated with Claude Code
# Atoms: {total_atoms} ({nx}x{ny}x{nz} FCC supercell)

units           metal
atom_style      atomic
boundary        p p p

# Create FCC lattice
lattice         fcc {lattice_const}
region          box block 0 {nx} 0 {ny} 0 {nz}
create_box      1 box
create_atoms    1 box

# Interatomic potential
pair_style      eam/alloy
pair_coeff      * * {potential} {element}

# Neighbor list
neighbor        2.0 bin
neigh_modify    every 1 delay 0 check yes

# Initial velocity at 300 K
velocity        all create 300.0 12345 dist gaussian

# Equilibrate at 300 K (NPT)
fix             1 all npt temp 300 300 0.1 iso 0 0 1.0
thermo          1000
thermo_style    custom step temp pe ke press vol density
timestep        0.001  # 1 fs

dump            1 all custom 5000 dump.equilibrate.* id type x y z vx vy vz
run             50000  # 50 ps equilibration
undump          1

# Heat to melt temperature
unfix           1
fix             1 all npt temp 300 {melt_temp} 0.1 iso 0 0 1.0
dump            2 all custom 10000 dump.heating.* id type x y z
run             200000  # 200 ps heating ramp
undump          2

# Hold at melt temperature
unfix           1
fix             1 all npt temp {melt_temp} {melt_temp} 0.1 iso 0 0 1.0
run             100000  # 100 ps liquid equilibration

# Quench: cool at {quench_rate:.0e} K/s
unfix           1
variable        quench_steps equal {int((melt_temp - 300) / (quench_rate * 1e-15))}
fix             1 all npt temp {melt_temp} 300 0.1 iso 0 0 1.0
dump            3 all custom 10000 dump.quench.* id type x y z
run             ${{quench_steps}}
undump          3

# Final structure
write_data      quenched_{element}.data
write_dump      all custom final_{element}.dump id type x y z
print           "Simulation complete"
"""
    return script
```

### Step 4: Verify Input Files

```bash
python3 -c "
from pymatgen.core import Structure, Lattice
from src.vasp_generator import create_relaxation_inputs

# Create FCC Cu structure
cu = Structure(Lattice.cubic(3.615), ['Cu'], [[0,0,0]])
create_relaxation_inputs(cu, '/tmp/vasp_test', encut=520)

# Validate INCAR
from pymatgen.io.vasp import Incar
incar = Incar.from_file('/tmp/vasp_test/INCAR')
assert incar['ENCUT'] == 520, 'Wrong ENCUT'
assert incar['ISPIN'] == 2, 'Missing spin polarization'
assert incar['EDIFF'] == 1e-6, 'Wrong electronic convergence'
print(f'INCAR tags: {len(incar)} validated')
print('VASP input generation: PASS')
"
```

## CLAUDE.md for Materials Science Simulation

```markdown
# Materials Science Simulation Standards

## VASP Rules
- ENCUT >= 1.3 * max(ENMAX in POTCAR) for convergence
- K-point density: >= 30 per reciprocal atom for metals, >= 20 for insulators
- Always converge ENCUT and k-points independently before production runs
- ISMEAR=1 for metals, ISMEAR=0 for insulators/molecules, ISMEAR=-5 for DOS
- Check CONTCAR for reasonable bond lengths after relaxation

## LAMMPS Rules
- Timestep <= 1/10 of fastest vibrational period
- Equilibrate for 10x correlation time before sampling
- Verify conservation of energy in NVE before production NPT/NVT
- Use velocity-Verlet integrator (default) for time-reversibility

## Libraries
- pymatgen 2024.1+ (structure I/O, VASP input generation)
- ase 3.22+ (Atomic Simulation Environment)
- phonopy 2.24+ (phonon calculations)
- VASPKIT (VASP post-processing)

## File Patterns
- INCAR, KPOINTS, POSCAR, POTCAR — VASP input
- OUTCAR, vasprun.xml, CONTCAR — VASP output
- .lmp, .in — LAMMPS input scripts
- .eam.alloy, .meam — interatomic potential files

## Common Commands
- vaspkit -task 102 — generate k-path for band structure
- pymatgen structure analyze CONTCAR — check bond lengths
- ovito dump.*.lammpstrj — visualize MD trajectory
- phonopy -p mesh.yaml — plot phonon dispersion
```

## Common Pitfalls

- **Insufficient k-point convergence:** Metallic systems need denser k-meshes than expected. A 4x4x4 mesh that converges for Si may be 100 meV/atom off for Fe. Claude Code runs convergence tests and picks the smallest mesh within 1 meV/atom of the converged value.
- **Wrong POTCAR version:** Mixing GGA and LDA pseudopotentials in the same calculation produces nonsense. Claude Code verifies POTCAR functional consistency with INCAR GGA/METAGGA settings.
- **LAMMPS potential cutoff mismatch:** Using a potential file with a 6 Angstrom cutoff on a 5 Angstrom simulation box causes periodic image artifacts. Claude Code checks that the box dimensions exceed 2x the potential cutoff.

## Related

- [Claude Code for Computational Chemistry (ORCA)](/claude-code-computational-chemistry-orca-2026/)
- [Claude Code for Molecular Dynamics (GROMACS)](/claude-code-molecular-dynamics-gromacs-2026/)
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

- [Claude Code for Computer Science](/claude-code-for-computer-science-bootcamp-students/)
- [Claude.md Example for Data Science](/claude-md-example-for-data-science-python-project/)
- [Claude Code for Data Science Analysis](/how-data-scientists-use-claude-code-for-analysis/)
- [Claude Skills for Data Science](/claude-skills-for-data-science-and-jupyter-notebooks/)

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

{% endraw %}
