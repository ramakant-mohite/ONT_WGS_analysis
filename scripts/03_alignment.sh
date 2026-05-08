# Step 3 — Read Alignment to Reference Genome


#!/bin/bash

# Activate environment

conda activate artic_env

# ---- User-defined paths ----

REFERENCE="denv2.reference.mmi"
INPUT_DIR="filtered"
OUTPUT_DIR="bam"

# ---- Setup ----

mkdir -p "${OUTPUT_DIR}"

# ---- Alignment loop ----

for FASTQ in ${INPUT_DIR}/*.filtered.fastq
do

    NAME=$(basename ${FASTQ} .filtered.fastq)

    echo "Aligning ${NAME}"

    minimap2 \
    -ax map-ont \
    ${REFERENCE} \
    ${FASTQ} | \
    samtools sort \
    -o ${OUTPUT_DIR}/${NAME}.sorted.bam

    samtools index \
    ${OUTPUT_DIR}/${NAME}.sorted.bam

done

echo "Alignment completed"