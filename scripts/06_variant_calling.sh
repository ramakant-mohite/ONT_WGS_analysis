#!/bin/bash

mkdir -p clair3_output

for BAM in trimmed_bam/*.trimmed.sorted.bam
do
    SAMPLE=$(basename ${BAM} .trimmed.sorted.bam)

    echo "Processing ${SAMPLE}"

    singularity exec \
        -B $(pwd) \
        Clair3/clair3.sif \
        run_clair3.sh \
        --bam_fn ${BAM} \
        --ref_fn denv2.reference.fasta \
        --threads 40 \
        --platform ont \
        --include_all_ctgs \
        --no_phasing_for_fa \
        --chunk_size 20000 \
        --model_path models/r1041_e82_400bps_hac_v500 \
        --output clair3_output/${SAMPLE}

done

echo "Clair3 variant calling completed successfully"

# The Clair3 output directory will contain VCF files for each sample, which can be used for downstream analyses such as variant annotation, filtering, and consensus sequence generation. It's important to review the VCF files to ensure that the variant calls are of high quality and consistent with expectations based on the sequencing data and reference genome.
