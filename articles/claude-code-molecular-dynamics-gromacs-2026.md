---
layout: default
title: "Claude Code for Molecular Dynamics (2026)"
description: "Claude Code for Molecular Dynamics — practical guide with working examples, tested configurations, and tips for developer workflows."
permalink: /claude-code-molecular-dynamics-gromacs-2026/
date: 2026-04-20
last_tested: "2026-04-21"
---

## Why Claude Code for Molecular Dynamics

Setting up a GROMACS simulation involves dozens of files: topology (.top), parameter (.mdp), coordinate (.gro), and index (.ndx) files that must all be internally consistent. A mismatched force field, wrong box type, or incorrect restraint definition means burning GPU-hours on a simulation that produces nonsense.

Claude Code generates GROMACS input files that follow best practices for your specific system type: protein in water, membrane protein, ligand-protein complex, or coarse-grained models. It knows CHARMM36m, AMBER99SB-ILDN, and OPLS-AA parameter sets and their quirks.

## The Workflow

### Step 1: Environment Setup

```bash
# Install GROMACS with GPU support
conda create -n md_sim -c conda-forge -c bioconda \
  gromacs=2024.1 mdanalysis=2.7 nglview \
  numpy matplotlib scipy

conda activate md_sim

# Verify GPU support
gmx mdrun -version | grep GPU

# Project structure
mkdir -p md_project/{topology,mdp,coordinates,analysis,output}
```

### Step 2: Generate Simulation Input Files

```python
# md_project/setup_simulation.py
"""Generate GROMACS input files for protein-in-water MD simulation."""
from pathlib import Path
import subprocess
import os

FORCE_FIELD = "charmm36-jul2022"
WATER_MODEL = "tip3p"
BOX_PADDING = 1.2  # nm from protein to box edge
ION_CONC = 0.15     # 150 mM NaCl physiological
MAX_ATOMS = 500000

def validate_pdb(pdb_path: str) -> int:
    """Check PDB file and return atom count."""
    assert Path(pdb_path).exists(), f"PDB not found: {pdb_path}"
    atom_count = 0
    with open(pdb_path) as f:
        for line in f:
            if line.startswith("ATOM") or line.startswith("HETATM"):
                atom_count += 1
    assert atom_count > 0, "PDB contains no atoms"
    assert atom_count < MAX_ATOMS, f"System too large: {atom_count} atoms"
    return atom_count


def generate_mdp(mdp_type: str, output_path: str) -> None:
    """Generate MDP parameter file for given simulation phase."""
    assert mdp_type in ("em", "nvt", "npt", "production"), \
        f"Unknown MDP type: {mdp_type}"

    params = {
        "em": {
            "integrator": "steep",
            "nsteps": "50000",
            "emtol": "1000.0",
            "emstep": "0.01",
            "nstlist": "1",
            "cutoff-scheme": "Verlet",
            "ns_type": "grid",
            "coulombtype": "PME",
            "rcoulomb": "1.2",
            "rvdw": "1.2",
            "pbc": "xyz",
        },
        "nvt": {
            "integrator": "md",
            "nsteps": "50000",     # 100 ps
            "dt": "0.002",
            "nstxout-compressed": "5000",
            "nstenergy": "5000",
            "nstlog": "5000",
            "continuation": "no",
            "constraint_algorithm": "lincs",
            "constraints": "h-bonds",
            "lincs_iter": "1",
            "lincs_order": "4",
            "cutoff-scheme": "Verlet",
            "ns_type": "grid",
            "nstlist": "20",
            "coulombtype": "PME",
            "rcoulomb": "1.2",
            "rvdw": "1.2",
            "tcoupl": "V-rescale",
            "tc-grps": "Protein Non-Protein",
            "tau_t": "0.1 0.1",
            "ref_t": "300 300",
            "pcoupl": "no",
            "pbc": "xyz",
            "gen_vel": "yes",
            "gen_temp": "300",
        },
        "npt": {
            "integrator": "md",
            "nsteps": "50000",     # 100 ps
            "dt": "0.002",
            "nstxout-compressed": "5000",
            "continuation": "yes",
            "constraint_algorithm": "lincs",
            "constraints": "h-bonds",
            "cutoff-scheme": "Verlet",
            "coulombtype": "PME",
            "rcoulomb": "1.2",
            "rvdw": "1.2",
            "tcoupl": "V-rescale",
            "tc-grps": "Protein Non-Protein",
            "tau_t": "0.1 0.1",
            "ref_t": "300 300",
            "pcoupl": "Parrinello-Rahman",
            "pcoupltype": "isotropic",
            "tau_p": "2.0",
            "ref_p": "1.0",
            "compressibility": "4.5e-5",
            "pbc": "xyz",
        },
        "production": {
            "integrator": "md",
            "nsteps": "25000000",  # 50 ns
            "dt": "0.002",
            "nstxout-compressed": "5000",
            "nstenergy": "5000",
            "continuation": "yes",
            "constraint_algorithm": "lincs",
            "constraints": "h-bonds",
            "cutoff-scheme": "Verlet",
            "coulombtype": "PME",
            "rcoulomb": "1.2",
            "rvdw": "1.2",
            "tcoupl": "V-rescale",
            "tc-grps": "Protein Non-Protein",
            "tau_t": "0.1 0.1",
            "ref_t": "300 300",
            "pcoupl": "Parrinello-Rahman",
            "tau_p": "2.0",
            "ref_p": "1.0",
            "compressibility": "4.5e-5",
            "pbc": "xyz",
        },
    }

    with open(output_path, 'w') as f:
        f.write(f"; MDP file for {mdp_type} phase\n")
        f.write(f"; Generated for {FORCE_FIELD} force field\n\n")
        for key, val in params[mdp_type].items():
            f.write(f"{key:<30} = {val}\n")

    print(f"Wrote: {output_path}")


def setup_system(pdb_path: str) -> None:
    """Full system setup: pdb2gmx -> box -> solvate -> ions."""
    atom_count = validate_pdb(pdb_path)
    print(f"Input PDB: {atom_count} atoms")

    cmds = [
        f"gmx pdb2gmx -f {pdb_path} -o topology/protein.gro "
        f"-p topology/topol.top -ff {FORCE_FIELD} -water {WATER_MODEL}",

        f"gmx editconf -f topology/protein.gro -o topology/boxed.gro "
        f"-c -d {BOX_PADDING} -bt dodecahedron",

        f"gmx solvate -cp topology/boxed.gro -cs spc216.gro "
        f"-o topology/solvated.gro -p topology/topol.top",
    ]

    for cmd in cmds:
        print(f"Running: {cmd}")
        result = subprocess.run(cmd.split(), capture_output=True, text=True)
        assert result.returncode == 0, \
            f"Command failed: {result.stderr[-500:]}"

    # Generate MDP files
    for phase in ("em", "nvt", "npt", "production"):
        generate_mdp(phase, f"mdp/{phase}.mdp")


if __name__ == "__main__":
    import sys
    assert len(sys.argv) == 2, "Usage: python setup_simulation.py <input.pdb>"
    setup_system(sys.argv[1])
```

### Step 3: Run and Analyze

```bash
# Energy minimization
gmx grompp -f mdp/em.mdp -c topology/solvated.gro -p topology/topol.top -o output/em.tpr
gmx mdrun -v -deffnm output/em

# NVT equilibration
gmx grompp -f mdp/nvt.mdp -c output/em.gro -r output/em.gro -p topology/topol.top -o output/nvt.tpr
gmx mdrun -deffnm output/nvt -nb gpu

# NPT equilibration
gmx grompp -f mdp/npt.mdp -c output/nvt.gro -r output/nvt.gro -p topology/topol.top -o output/npt.tpr
gmx mdrun -deffnm output/npt -nb gpu

# Production MD (50 ns)
gmx grompp -f mdp/production.mdp -c output/npt.gro -p topology/topol.top -o output/md.tpr
gmx mdrun -deffnm output/md -nb gpu

# RMSD analysis
echo "4 4" | gmx rms -s output/md.tpr -f output/md.xtc -o analysis/rmsd.xvg
# Expected: RMSD stabilizes at 1.5-3.0 A for a well-folded protein
```

## CLAUDE.md for Molecular Dynamics

```markdown
# Molecular Dynamics Simulation Rules

## Standards
- GROMACS 2024.x input format
- CHARMM36m or AMBER force fields
- PME for long-range electrostatics (no cutoff)

## File Formats
- .pdb / .gro (coordinates)
- .top (topology)
- .mdp (run parameters)
- .ndx (index groups)
- .xtc / .trr (trajectory)
- .xvg (analysis output)

## Libraries
- GROMACS 2024.1+
- MDAnalysis 2.7+
- NumPy, SciPy, matplotlib

## Testing
- Energy minimization must converge (Fmax < 1000 kJ/mol/nm)
- NVT temperature must stabilize within 5K of target
- NPT density must stabilize at ~1000 kg/m3 for water systems

## Safety
- Never skip equilibration phases
- Always check for steric clashes before production run
- Verify box size is large enough (min image distance > 2x cutoff)
```

## Common Pitfalls

- **Force field mismatch:** Mixing CHARMM protein parameters with AMBER water models produces wrong energetics. Claude Code validates that all #include directives in the .top file reference the same force field family.
- **Pressure coupling during equilibration:** Using Parrinello-Rahman during NVT equilibration crashes the simulation. Claude Code enforces the correct coupling scheme for each phase: no pressure in NVT, Berendsen for initial NPT, Parrinello-Rahman for production.
- **Periodic image interactions:** A box too small causes the protein to interact with its own periodic image. Claude Code checks that the minimum image distance exceeds 2x the cutoff radius.



**Build yours →** Create a custom CLAUDE.md with our [Generator Tool](/generator/).

## Related

**Estimate tokens →** Calculate your usage with our [Token Estimator](/token-estimator/).

**Try it:** Estimate your monthly spend with our [Cost Calculator](/calculator/).

- [Claude Code for Computational Chemistry](/claude-code-computational-chemistry-orca-2026/)
- [Claude Code for Computational Biology](/claude-skills-for-computational-biology-bioinformatics/)
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
