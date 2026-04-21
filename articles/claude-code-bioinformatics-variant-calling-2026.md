---
title: "Claude Code for FASTQ to Variant Calls (2026)"
description: "Bioinformatics variant calling pipeline with Claude Code. Automate FASTQ QC through VCF annotation in one workflow."
permalink: /claude-code-bioinformatics-variant-calling-2026/
last_tested: "2026-04-21"
render_with_liquid: false
---

## Why Claude Code for Variant Calling

A whole-genome sequencing analysis pipeline has dozens of steps: FASTQ quality control, adapter trimming, alignment to reference genome, duplicate marking, base quality recalibration, variant calling, filtering, and annotation. Each tool has its own parameter space, and a misconfigured BQSR table or wrong GATK genotyping mode can silently produce thousands of false-positive variants.

Claude Code understands the BWA/GATK/samtools toolchain, knows which parameters are critical vs cosmetic, and generates Snakemake or Nextflow pipelines that follow GATK Best Practices. It catches the mistakes that waste a week of compute time on your HPC cluster.

## The Workflow

### Step 1: Environment Setup

```bash
# Install bioinformatics tools via conda
conda create -n variant_calling -c bioconda -c conda-forge \
  fastqc=0.12.1 trimmomatic=0.39 bwa-mem2=2.2.1 \
  samtools=1.19 gatk4=4.5.0 bcftools=1.19 \
  snpeff=5.2 multiqc=1.21 snakemake=8.4

conda activate variant_calling

# Download reference genome (GRCh38)
wget -P ref/ https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.15_GRCh38/seqs_for_alignment_pipelines.ucsc_ids/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz
bwa-mem2 index ref/GRCh38_no_alt.fna.gz
samtools faidx ref/GRCh38_no_alt.fna.gz
gatk CreateSequenceDictionary -R ref/GRCh38_no_alt.fna.gz
```

### Step 2: Snakemake Pipeline

```python
# Snakefile — GATK Best Practices variant calling
import os

SAMPLES = glob_wildcards("fastq/{sample}_R1.fastq.gz").sample
REF = "ref/GRCh38_no_alt.fna.gz"
KNOWN_SITES = "ref/dbsnp_146.hg38.vcf.gz"
THREADS = 8
MAX_MEMORY = "16g"

assert len(SAMPLES) > 0, "No FASTQ files found in fastq/ directory"

rule all:
    input:
        expand("vcf/{sample}.filtered.vcf.gz", sample=SAMPLES),
        "qc/multiqc_report.html"

rule fastqc:
    input:
        r1="fastq/{sample}_R1.fastq.gz",
        r2="fastq/{sample}_R2.fastq.gz"
    output:
        "qc/fastqc/{sample}_R1_fastqc.html",
        "qc/fastqc/{sample}_R2_fastqc.html"
    threads: 2
    shell:
        "fastqc -t {threads} -o qc/fastqc/ {input.r1} {input.r2}"

rule trim:
    input:
        r1="fastq/{sample}_R1.fastq.gz",
        r2="fastq/{sample}_R2.fastq.gz"
    output:
        r1="trimmed/{sample}_R1.fastq.gz",
        r2="trimmed/{sample}_R2.fastq.gz",
        r1_unpaired="trimmed/{sample}_R1_unpaired.fastq.gz",
        r2_unpaired="trimmed/{sample}_R2_unpaired.fastq.gz"
    threads: 4
    shell:
        """
        trimmomatic PE -threads {threads} \
          {input.r1} {input.r2} \
          {output.r1} {output.r1_unpaired} \
          {output.r2} {output.r2_unpaired} \
          ILLUMINACLIP:adapters/TruSeq3-PE.fa:2:30:10 \
          LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
        """

rule align:
    input:
        r1="trimmed/{sample}_R1.fastq.gz",
        r2="trimmed/{sample}_R2.fastq.gz"
    output:
        bam="aligned/{sample}.sorted.bam"
    params:
        rg=r"@RG\tID:{sample}\tSM:{sample}\tPL:ILLUMINA\tLB:lib1"
    threads: THREADS
    shell:
        """
        bwa-mem2 mem -t {threads} -R '{params.rg}' {REF} \
          {input.r1} {input.r2} | \
        samtools sort -@ {threads} -m 2G -o {output.bam}
        samtools index {output.bam}
        """

rule mark_duplicates:
    input:
        "aligned/{sample}.sorted.bam"
    output:
        bam="dedup/{sample}.dedup.bam",
        metrics="dedup/{sample}.metrics.txt"
    shell:
        """
        gatk MarkDuplicates \
          -I {input} -O {output.bam} -M {output.metrics} \
          --VALIDATION_STRINGENCY SILENT
        samtools index {output.bam}
        """

rule base_recalibration:
    input:
        bam="dedup/{sample}.dedup.bam"
    output:
        table="bqsr/{sample}.recal.table",
        bam="bqsr/{sample}.recal.bam"
    shell:
        """
        gatk BaseRecalibrator \
          -I {input.bam} -R {REF} \
          --known-sites {KNOWN_SITES} \
          -O {output.table}
        gatk ApplyBQSR \
          -I {input.bam} -R {REF} \
          --bqsr-recal-file {output.table} \
          -O {output.bam}
        samtools index {output.bam}
        """

rule haplotype_caller:
    input:
        "bqsr/{sample}.recal.bam"
    output:
        "vcf/{sample}.g.vcf.gz"
    shell:
        """
        gatk HaplotypeCaller \
          -I {input} -R {REF} \
          -O {output} -ERC GVCF \
          --native-pair-hmm-threads 4
        """

rule genotype_and_filter:
    input:
        "vcf/{sample}.g.vcf.gz"
    output:
        "vcf/{sample}.filtered.vcf.gz"
    shell:
        """
        gatk GenotypeGVCFs -R {REF} -V {input} -O vcf/{wildcards.sample}.raw.vcf.gz
        gatk VariantFiltration -R {REF} \
          -V vcf/{wildcards.sample}.raw.vcf.gz \
          -O {output} \
          --filter-expression "QD < 2.0" --filter-name "LowQD" \
          --filter-expression "FS > 60.0" --filter-name "StrandBias" \
          --filter-expression "MQ < 40.0" --filter-name "LowMQ" \
          --filter-expression "MQRankSum < -12.5" --filter-name "MQRankSum" \
          --filter-expression "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum"
        """

rule multiqc:
    input:
        expand("qc/fastqc/{sample}_R1_fastqc.html", sample=SAMPLES),
        expand("dedup/{sample}.metrics.txt", sample=SAMPLES)
    output:
        "qc/multiqc_report.html"
    shell:
        "multiqc qc/ dedup/ -o qc/ --force"
```

### Step 3: Validate Results

```bash
# Run the pipeline
snakemake --cores 16 --use-conda

# Check variant counts
bcftools stats vcf/sample1.filtered.vcf.gz | grep "number of SNPs"
# Expected: ~4.5M SNPs for a 30x WGS sample (human)

# Check Ti/Tv ratio (should be ~2.1 for WGS, ~2.8 for WES)
bcftools stats vcf/sample1.filtered.vcf.gz | grep "Ts/Tv"
```

## CLAUDE.md for Variant Calling

```markdown
# Bioinformatics Variant Calling Rules

## Standards
- GATK Best Practices (Broad Institute)
- SAM/BAM spec (SAMtools hts-specs)
- VCF 4.3 specification

## File Formats
- .fastq.gz (raw reads)
- .bam / .cram (aligned reads)
- .vcf.gz / .bcf (variant calls)
- .bed (target regions)

## Libraries
- GATK 4.5+ (variant calling)
- BWA-MEM2 2.2+ (alignment)
- samtools/bcftools 1.19+
- Snakemake 8.x (workflow manager)
- MultiQC 1.21+ (reporting)

## Testing
- Ti/Tv ratio sanity check: 2.0-2.2 for WGS, 2.7-3.0 for WES
- Known-site concordance with GIAB truth set (NA12878)
- Coverage uniformity: >80% of targets at >20x

## Reference
- GRCh38 no-alt analysis set (required)
- dbSNP 146+ for BQSR known sites
```

## Common Pitfalls

- **Missing read group tags:** GATK refuses BAMs without @RG headers. Claude Code always includes the -R flag in BWA-MEM2 alignment commands with proper SM, PL, and LB tags.
- **BQSR without known sites:** Running BaseRecalibrator without dbSNP or Mills indels produces a garbage recalibration table. Claude Code ensures the --known-sites parameter is always populated.
- **GVCF vs VCF mode confusion:** HaplotypeCaller in GVCF mode (-ERC GVCF) produces reference confidence blocks needed for joint genotyping. Accidentally using normal mode on a single sample loses the ability to do cohort calling later.

## Related

- [Claude Code for Computational Biology](/claude-skills-for-computational-biology-bioinformatics/)
- [Claude Code for Genomics GWAS](/claude-code-genomics-gwas-pipeline-2026/)
- [CLAUDE.md File Guide](/claude-md-file-complete-guide-what-it-does/)
