#!/bin/bash

mkdir -p trimmed_bam

for BAM in bam/*.sorted.bam
do
    NAME=$(basename ${BAM} .sorted.bam)

    echo "Processing ${NAME}"

    align_trim \
        --report trimmed_bam/${NAME}.alignreport.txt \
        primer_scheme.bed \
        < ${BAM} | \
    samtools sort \
        -o trimmed_bam/${NAME}.trimmed.sorted.bam

    samtools index \
        trimmed_bam/${NAME}.trimmed.sorted.bam

done

echo "Primer trimming completed successfully"


#check the alignreport.txt files for the number of reads trimmed and untrimmed, and the percentage of reads trimmed. If the percentage is very low, it may indicate an issue with the primer scheme or the alignment parameters.
#samtools quickcheck trimmed_bam/*.trimmed.sorted.bam can be used to quickly check the integrity of the BAM files. If any files are reported as truncated or corrupted, they may need to be reprocessed.
#samtools depth -a trimmed_bam/*.trimmed.sorted.bam > depth.txt can be used to calculate the depth of coverage across the genome. This can help identify any regions with low coverage that may need further investigation.
#
