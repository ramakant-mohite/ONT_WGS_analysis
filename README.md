
# 🧬 Viral Whole-Genome Construction Pipeline

Workflow for constructing viral whole genomes from raw Oxford Nanopore Technologies (ONT) amplicon sequencing data. It follows an **ARTIC-style** approach optimized for generating high-quality consensus sequences for downstream phylogenetic visualization and mutation burden analysis.

> **Note:** The ARTIC workflow currently runs most reliably in a Python 3.10 environment.
            To ensure void system-level library conflicts (e.g., GLIBC errors) use singularity containers for Clair3 and Dorado.

---

## 📑 Table of Contents

1. [Step 1 — Basecalling](#step-1-basecalling)
2. [Step 2 — Read Filtering](#step-2-read-filtering)
3. [Step 3 — Read Alignment](#step-3-read-alignment-to-reference-genome)
4. [Step 4 — ARTIC Primer Trimming](#step-4-artic-primer-trimming)
5. [Step 5 — Coverage Masking](#step-5-coverage-mask-generation)
6. [Step 6 — Variant Calling Using Clair3](#step-6-variant-calling-using-clair3)
7. [Step 7 — Variant Filtering](#step-7-variant-filtering)
8. [Step 8 — Consensus Genome Generation](#step-8-consensus-genome-generation)
9. [Step 9 — Multiple Sequence Alignment (MAFFT)](#step-9-multiple-sequence-alignment-mafft)
10. [Step 10 — Phylogenetic Analysis (IQ-TREE)](#step-10-phylogenetic-analysis-iq-tree)
11. [Acknowledgements & Citation](#-acknowledgements--citation)

---

## 🛠 Workflow Steps

### Step 1: Basecalling

**Script:** `/01_basecalling.sh`

Converts raw current signals stored in `POD5` files into `FASTQ` reads. This pipeline uses **Dorado**, the state-of-the-art basecalling engine. Ensure you select the correct basecalling model (HAC or SUP) depending on your sequencing kit and flowcell chemistry. 
This usually indicates GPU resources were not detected. Dorado automatically falls back to CPU basecalling.


### Step 2: Read Filtering

**Script:** `/02_filtering.sh`

Reads are filtered using **NanoFilt** based on expected amplicon size. This removes noisy reads, incomplete fragments, and non-specific or chimeric products. Set filteration window based on your amplicon sizes.

### Step 3: Read Alignment to Reference Genome

**Script:** `/03_alignment.sh`

Filtered reads are aligned to the reference genome using `minimap2`.

**The Concept:** Why `minimap2` for ONT?
Oxford Nanopore produces exceptionally long reads but historically exhibits higher insertion, deletion, and homopolymer error rates compared to short-read platforms like Illumina. Standard short-read aligners (like BWA-MEM) penalize gap openings too heavily for this data. `minimap2` is specifically designed for long-read data. By using the `map-ont` preset, the algorithm adjusts its chaining heuristics and gap penalties to elegantly handle the frequent, small indels characteristic of Nanopore sequencing, ensuring accurate mapping even across noisy regions.

**Execution:**

```bash
minimap2 -d denv2.reference.mmi denv2.reference.fasta
# Align, sort, and index outputs using samtools

```

### Step 4: ARTIC Primer Trimming

**Script:** `/04_primer_trimming.sh`

Primer regions are soft-trimmed using `align_trim` based on an provided ARTIC primer scheme in `BED` format. This prevents amplification bias from masking true biological variants.

### Step 5: Coverage Mask Generation

**Script:** `/05_coverage_masking.sh`

This step scans the genomic depth and identifies low-coverage regions, generating mask files so these unreliable intervals are masked with `N` during consensus generation.

### Step 6: Variant Calling Using Clair3

**Script:** `/06_variant_calling.sh`

**The Concept:** Why Clair3 for ONT Variant Calling?
Traditional statistical variant callers struggle with ONT data because sequencing errors are systematically biased, particularly around homopolymer repeats. **Clair3** addresses this by using a deep neural network trained extensively on ONT data. It operates in two tiers: it first uses a rapid pileup-based model to call straightforward variants, and then leverages a computationally heavier full-alignment model to resolve complex, low-confidence regions. This machine-learning approach is critical for distinguishing true biological mutations from underlying sequencing noise.

The Clair3 workflow internally combines:

* processes aligned Nanopore BAM files

* scans genomic positions for candidate variants

* performs pileup-based variant detection

* refines low-confidence sites using full-alignment analysis

* generates compressed VCF variant files

**Execution:**

```bash
# Uses ONT-trained model: models/r1041_e82_400bps_hac_v500

```

### Step 7: Variant Filtering

**Script:** `/07_variant_filtering.sh`

`bcftools` is used to separate high-confidence from low-confidence variants using criteria such as Read Depth (`DP > 20`) and Genotype Quality (`GQ > 3`).

### Step 8: Consensus Genome Generation

**Script:** `/08_consensus_generation.sh`

The final sample-specific viral genome is reconstructed using `bcftools consensus`, applying high-confidence variants to the reference while masking low-coverage regions as `N`.

---

## 🌳 Downstream Analysis: Phylogeny & Visualization

Once consensus FASTA files are generated for all samples, they can be aligned and used to infer evolutionary relationships.

### Step 9: Multiple Sequence Alignment (MAFFT)

Combine all consensus sequences (and reference genomes) into one file and align them using MAFFT, which is highly accurate for viral genomes.

```bash
cat consensus/*.fasta > all_samples.fasta
mafft --auto --thread -1 all_samples.fasta > aligned_samples.fasta

```

### Step 10: Phylogenetic Analysis (IQ-TREE)

Infer the phylogenetic tree using Maximum Likelihood with IQ-TREE, automatically determining the best-fit substitution model.

```bash
iqtree -s aligned_samples.fasta -m MFP -B 1000 -T AUTO

```

### Phylogeny Visualization & Interpretation

The resulting `.treefile` can be visualized to analyze clade structures and geographical or temporal lineages. Below is the phylogenetic analysis of the Indian DENV2 consensus genomes generated from this pipeline:

**Phylogenetic Interpretation:**

![Phylogenetic Analysis of Indian DENV2 Consensus Genomes](plot/tree.png)

The maximum-likelihood phylogenetic tree confirms that the sequenced Indian DENV2 samples belong to Genotype II (the Cosmopolitan lineage). All internally generated consensus genomes (e.g., `India_Sample02` through `India_Sample35`) form a strongly supported monophyletic cluster (bootstrap support = 100). This distinct Indian clade shares a recent common ancestor with closely related G2 isolates from neighboring regions, including Nepal, Malaysia, and China. 

---

## 📖 Acknowledgements & Citation

This workflow was developed as part of dengue virus genomic surveillance work conducted at CSIR–Institute of Genomics and Integrative Biology (IGIB).

This workflow contributed to genomic analysis performed in the following study:

> **Ravi V., Khare K., Mohite R., Mishra P., Halder S., Shukla R., Liu C.S.C., Yadav A., Soni J., Kanika K., Chaudhary K., Neha N., Tarai B., Budhiraja S., Khosla P., Sethi T., Imran M., Pandey R.**
> *Genomic hotspots in the DENV-2 serotype (E, NS4B, and NS5 genes) are associated with dengue disease severity in the endemic region of India.*
> PLOS Neglected Tropical Diseases (2025)
> [https://doi.org/10.1371/journal.pntd.0013034]()


## Author
Mohite Ramakant
---
