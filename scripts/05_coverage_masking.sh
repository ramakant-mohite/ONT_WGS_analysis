
#!/bin/bash

mkdir -p masks

for BAM in trimmed_bam/*.trimmed.sorted.bam
do
    NAME=$(basename ${BAM} .trimmed.sorted.bam)

    echo "Masking ${NAME}"

    artic_make_depth_mask \
        denv2.reference.fasta \
        ${BAM} \
        masks/${NAME}.coverage_mask.txt

done

echo "Coverage masking completed successfully"
```
# The coverage mask files generated in the masks directory can be used in downstream analyses to exclude low-coverage regions from variant calling or consensus sequence generation. It's important to review the coverage mask files to ensure that they are appropriately masking regions with insufficient coverage, as this can impact the accuracy of the final results.
