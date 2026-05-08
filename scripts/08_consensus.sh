#!/bin/bash

mkdir -p consensus

for SAMPLE_DIR in clair3_output/barcode*
do
    SAMPLE=$(basename ${SAMPLE_DIR})

    echo "Consensus ${SAMPLE}"

    bcftools consensus \
        -f denv2.reference.fasta \
        ${SAMPLE_DIR}/${SAMPLE}.pass.vcf.gz \
        -m masks/${SAMPLE}.coverage_mask.bed \
        -o consensus/${SAMPLE}.consensus.fasta

done

echo "Consensus generation completed successfully"

#this step generates consensus sequences for each sample using the filtered VCF files and the reference genome. The coverage mask is applied to exclude low-coverage regions from the consensus sequence. It's important to review the generated consensus sequences to ensure that they are of high quality and consistent with expectations based on the sequencing data and reference genome. The consensus sequences can be used for downstream analyses such as phylogenetic analysis, variant annotation, and functional analysis.
