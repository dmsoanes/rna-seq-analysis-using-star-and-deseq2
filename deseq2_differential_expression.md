# Differential Gene Expression Analysis using [DESeq2](https://bioconductor.org/packages/release/bioc/html/DESeq2.html)
DESeq2 is an R package. For more detail information about how to use DESeq2 click [here](https://bioconductor.org/packages/3.23/bioc/vignettes/DESeq2/inst/doc/DESeq2.html).
The following R packages need to be installed.
  
**Bioconductor**  
[DESeq2](https://bioconductor.org/packages/release/bioc/html/DESeq2.html)  
[AnnotationDbi](https://bioconductor.org/packages/release/bioc/html/AnnotationDbi.html)  
[org.Hs.eg.db](https://bioconductor.org/packages/release/data/annotation/html/org.Hs.eg.db.html)  
[EnhancedVolcano](https://bioconductor.org/packages/release/bioc/html/EnhancedVolcano.html) 
  
To install Bioconductor packages:  
```
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("package_name")
```

  
**CRAN**  
[ggplot2](https://ggplot2.tidyverse.org/)  
[pheatmap](https://cran.r-project.org/web/packages/pheatmap/refman/pheatmap.html)  
[RColorBrewer](https://cran.r-project.org/web/packages/RColorBrewer/refman/RColorBrewer.html)   
  
To install packages from CRAN:  
```
install.packages("package_name")
```
1: You need htseq formatted files containing gene counts generated from STAR (see [Gene quantification using STAR](star_gene_counts.md)) that should be all in the same folder. 
  
2: Create a tab-delimited text file containing information about the your samples, an example file can be found [here](sample_info.txt).   
The file needs to contains a sample name, name of file containing gene counts and one or more conditions that can be tested for differential expression for each sample.

|sampleName |	fileName |	Cell |	Condition|
|-----------|----------|-------|-----------|
|12045_041_2008_NEUNpos_TDP43neg_S46 |	12045_041_2008_NEUNpos_TDP43neg_S46.ReadsPerGene.out.tab.htseq |	NEUN |	TDP43neg |
|12045_041_2008_NEUNpos_TDP43pos_S48 |	12045_041_2008_NEUNpos_TDP43pos_S48.ReadsPerGene.out.tab.htseq |	NEUN |	TDP43pos |
|12045_041_2008_SOX10pos_TDP43neg_S49	| 12045_041_2008_SOX10pos_TDP43neg_S49.ReadsPerGene.out.tab.htseq	| SOX10	| TDP43neg |
|12045_041_2008_SOX10pos_TDP43pos_S47	| 12045_041_2008_SOX10pos_TDP43pos_S47.ReadsPerGene.out.tab.htseq	| SOX10	| TDP43pos |
  
3: R code to create a heatmap to look at the similarity between samples  
```
library(DESeq2)
library("pheatmap")
library("RColorBrewer")

#define directory containing counts
directory <- "C:/Users/dmsoanes/OneDrive - University of Exeter/AD/NIHR-BRC projects/Jon Mill/Project_12045/03_gene_counts"

#import sample tables
sampleTable <- read.table(file = "sample_info.txt", header = TRUE)

#Create DESeq2 data object -all samples
dds_all <- DESeqDataSetFromHTSeqCount(sampleTable = sampleTable, directory = directory, design= ~ Cell + Condition)
count_all <- assay(dds_all)
nrow(dds_all)

# Filter lowly expressed genes
#keep genes with at least 2 samples with a count of > 10  
keep <- rowSums(counts(dds_all) > 10) >= 2 
dds_all <- dds_all[keep,]
nrow(dds_all)

#Variance stabilized transformation
vsd <- vst(dds_all, blind = TRUE)

#plot sample heatmap
sampleDists <- dist(t(assay(vsd)))
sampleDistMatrix <- as.matrix( sampleDists )
colnames(sampleDistMatrix) <- NULL
colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
pheatmap(sampleDistMatrix, clustering_distance_rows = sampleDists, clustering_distance_cols = sampleDists, col = colors)
```
Based on the heatmap you might want to remove some samples from differential expression analysis by editing the sample table.
