#!/bin/bash

# Basecalling Nanopore POD5 per barcode using Dorado (GPU)

# ---- User-defined paths ----

INPUT_BASE="/path/to/pod5_pass"
OUTPUT_DIR="/path/to/output_fastq"
DORADO="/path/to/dorado.sif"

# ---- Setup ----

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR" || exit 1

# ---- Basecalling loop ----

for bc in "$INPUT_BASE"/barcode*; do
name=$(basename "$bc")
echo "Processing $name at $(date)"

```
singularity exec --nv -B /path/to/data "$DORADO" \
dorado basecaller \
--device cuda:0 \
--emit-fastq \
dna_r10.4.1_e8.2_400bps_hac@v4.3.0 \
"$bc" \
> "${name}.fastq"
```

done

echo "Basecalling completed at $(date)"



