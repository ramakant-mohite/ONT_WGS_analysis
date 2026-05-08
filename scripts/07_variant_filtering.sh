#!/bin/bash

for SAMPLE_DIR in clair3_output/barcode*
do
    SAMPLE=$(basename ${SAMPLE_DIR})

    echo "Filtering ${SAMPLE}"

    bcftools view \
        --include 'MIN(FMT/DP)>20 & MIN(FMT/GQ)>3' \
        ${SAMPLE_DIR}/merge_output.vcf.gz \
        -o ${SAMPLE_DIR}/${SAMPLE}.pass.vcf

    bcftools view \
        --include 'MIN(FMT/DP)<=20 | MIN(FMT/GQ)<=3' \
        ${SAMPLE_DIR}/merge_output.vcf.gz \
        -o ${SAMPLE_DIR}/${SAMPLE}.fail.vcf

done

echo "Variant filtering completed successfully"

#Minimum depth (DP) of 20 and minimum genotype quality (GQ) of 3 are commonly used thresholds for filtering variants in nanopore sequencing data. However, these thresholds may need to be adjusted based on the specific characteristics of the dataset and the research question being addressed. It's important to review the filtered VCF files to ensure that the filtering criteria are appropriate and that high-quality variants are retained for downstream analyses.
#bcftools view can be used to further filter the VCF files based on additional criteria, such as allele frequency, variant type, or functional annotation. This can help prioritize variants for downstream analyses and reduce the number of false positives. It's important to carefully consider the filtering criteria and review the resulting VCF files to ensure that they are appropriate for the research question being addressed.
