# Gene quantification using [STAR](https://github.com/alexdobin/STAR)

**1: Start ISCA interactive session**
```
srun --time=12:00:00 -c 16 -p mrcq -A Research_Project-MRC190311 --pty bash
```
**2: Load STAR software**
```
module load STAR
```
**3: Create STAR genome index**  
Download primary assembly fasta file and matching GTF annotation from GENCODE (https://www.gencodegenes.org/human/) using wget and then unzip the files.
```
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_50/GRCh38.primary_assembly.genome.fa.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_50/gencode.v50.primary_assembly.annotation.gtf.gz

gunzip GRCh38.primary_assembly.genome.fa.gz
gunzip gencode.v50.primary_assembly.annotation.gtf.gz
```
**4: Make directory for STAR index**
```
mkdir star_index
```
**5: Create genome index**
```
STAR --runThreadN 16 --runMode genomeGenerate --genomeDir star_index --genomeFastaFiles GRCh38.primary_assembly.genome.fa --sjdbGTFfile gencode.v50.primary_assembly.annotation.gtf --sjdbOverhang 149
```
The rule of thumb for STAR is --sjdbOverhang = (Read Length - 1). For 150bp reads, use 149

**6: Align reads against reference sequence (using gzipped paired-end reads) and produce gene counts**
```
STAR --runThreadN NumberOfThreads --genomeDir /path/to/genomeDir --readFilesIn /path/to/read1 /path/to/read2 --readFilesCommand zcat --outFileNamePrefix name --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts
```
Bash script to align reads / produce gene counts for all samples in directory 01_raw_reads
```
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
```
**Output:**  
i) bam file of reads aligned against reference genome (Aligned.sortedByCoord.out.bam)  
ii) tab-delimited file containing number of reads mapped to each gene (nameReadsPerGene.out.tab)
