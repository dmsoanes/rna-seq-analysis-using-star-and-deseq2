# Gene quantification using [STAR](https://github.com/alexdobin/STAR)
Manual for STAR can be found [here](https://github.com/alexdobin/STAR/blob/master/doc/STARmanual.pdf)  
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
[star_alignment.sh](star_alignment.sh) - bash script to align reads / produce gene counts for all samples in directory 01_raw_reads

**Output:**  
i) bam file of reads aligned against reference genome (Aligned.sortedByCoord.out.bam)  
ii) tab-delimited file containing number of reads mapped to each gene (nameReadsPerGene.out.tab)

**Gene count output** (nameReadsPerGene.out.tab)  
&nbsp;&nbsp;&nbsp;&nbsp;**column 1:** gene ID  
&nbsp;&nbsp;&nbsp;&nbsp;**column 2:** counts for unstranded RNA-seq  
&nbsp;&nbsp;&nbsp;&nbsp;**column 3:** counts for the 1st read strand aligned with RNA (htseq-count option -s yes)  
&nbsp;&nbsp;&nbsp;&nbsp;**column 4:** counts for the 2nd read strand aligned with RNA (htseq-count option -s reverse)

The correct column to use depends on the library strandedness  
For a typical **unstranded** Illumina RNA-seq library, you would use: **column 2**  
If it is **reverse stranded**, you would generally use: **column 4** 

**7: Create files to be imported into downstream analysis packages**
To create files in the htseq format to import into analysis packages you need to extract column 1 and one of the other three columns depending on how the RNA-seq library was constructed.

```
for f in *Gene*; do cut -f 1,2 $f | tail -n +5 > $f.htseq; done
```
This line extracts columns 1 and 2 - adjust -f parameter for other columns.

 
