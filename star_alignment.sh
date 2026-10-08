#!/bin/bash

THREADS=16

READ_DIR="01_raw_reads"
OUT_DIR="02_star_alignment"
GENOME_DIR="star_index"

mkdir -p "$OUT_DIR"

for R1 in "$READ_DIR"/*_R1_001.fastq.gz
do
    SAMPLE=$(basename "$R1" _R1_001.fastq.gz)
    R2="$READ_DIR/${SAMPLE}_R2_001.fastq.gz"

    echo "=========================================="
    echo "Processing: $SAMPLE"
    echo "R1: $R1"
    echo "R2: $R2"
    echo "=========================================="

    if [[ ! -f "$R2" ]]; then
        echo "ERROR: R2 file not found for $SAMPLE"
        exit 1
    fi

    STAR \
        --runThreadN "$THREADS" \
        --genomeDir "$GENOME_DIR" \
        --readFilesIn "$R1" "$R2" \
        --readFilesCommand zcat \
        --outFileNamePrefix "$OUT_DIR/${SAMPLE}." \
        --outSAMtype BAM SortedByCoordinate \
        --quantMode GeneCounts

done
