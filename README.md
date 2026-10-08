# RNA-seq analysis workflow using STAR and DESeq2

Example workflow using STAR and DESeq2 to analyse short-read RNA-seq data looking at differential gene expression.

This example is based on human RNA-seq data

1: Load STAR software

module load STAR

2: Create STAR genome index
Download primary assembly fasta file and matching GTF annotation from GENCODE (https://www.gencodegenes.org/human/) using wget and unzip them.
```
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_50/GRCh38.primary_assembly.genome.fa.gz
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_50/gencode.v50.primary_assembly.annotation.gtf.gz

gunzip GRCh38.primary_assembly.genome.fa.gz
gunzip gencode.v50.primary_assembly.annotation.gtf.gz
```
3: Make directory for STAR index
```
mkdir star_index
```
4: Create genome index
```
STAR --runThreadN 16 --runMode genomeGenerate --genomeDir star_index --genomeFastaFiles GRCh38.primary_assembly.genome.fa --sjdbGTFfile gencode.v50.primary_assembly.annotation.gtf --sjdbOverhang 149
```
The rule of thumb for STAR is --sjdbOverhang = (Read Length - 1). For 150bp reads, use 149
