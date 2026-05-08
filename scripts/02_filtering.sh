#!/bin/bash

# Length filtering of Nanopore FASTQ reads for ARTIC workflow

# ---- Activate ARTIC environment ----

conda activate artic_env

# ---- User-defined paths ----

INPUT_DIR="/path/to/fastq_pass"
OUTPUT_DIR="${INPUT_DIR}/filtered"

# ---- Setup ----

mkdir -p "${OUTPUT_DIR}"

cd "${INPUT_DIR}" || exit 1

# ---- Filtering loop ----

for BARCODE in barcode*
do

    NAME=$(basename "${BARCODE}")

    echo "Processing ${NAME} at $(date)"

    gunzip -c "${BARCODE}"/*.fastq.gz | \
    NanoFilt \
    -l 400 \
    --maxlength 700 \
    > "${OUTPUT_DIR}/${NAME}.filtered.fastq"

done

echo "Filtering completed at $(date)"