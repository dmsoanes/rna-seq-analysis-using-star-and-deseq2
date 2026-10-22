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
library(pheatmap)
library(RColorBrewer)

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
Based on the heatmap you might want to remove some samples from differential expression analysis by editing the sample table. If that is the case then you need to rerun the above script with your new sample table.

Rest of the script to plot a PCA, perform differential gene expression and make a volcano plot.

```
#PCA plot that shows Cell and Condition
library(DESeq2)
library(ggplot2)

# 1. Extract the PCA coordinates data frame from plotPCA
# Include BOTH variables in the 'intgroup' argument
pcaData <- plotPCA(vsd, intgroup = c("Condition", "Cell"), returnData = TRUE)

# 2. Extract the percentage of variance for the axis labels
percentVar <- round(100 * attr(pcaData, "percentVar"))

# 3. Create your custom ggplot mapping color to Condition and shape to Cell
ggplot(pcaData, aes(x = PC1, y = PC2, color = Condition, shape = Cell)) +
  geom_point(size = 4) + # Adjust dot size here
  xlab(paste0("PC1: ", percentVar[1], "% variance")) +
  ylab(paste0("PC2: ", percentVar[2], "% variance")) +
  coord_fixed() +        # Ensures 1:1 aspect ratio typical for PCA plots
  theme_bw()             # Clean background theme


#Differential Gene Expression Analysis
dds_all <- DESeq(dds_all)
res <- results(dds_all, alpha = 0.05)
summary(res)
res

#Annotating and exporting result, in this case selecting results with padj < 0.05
library(AnnotationDbi)
library(org.Hs.eg.db)
ens.str <- substr(rownames(res), 1, 15)
res$symbol <- mapIds(org.Hs.eg.db,
                     keys=ens.str,
                     column="SYMBOL",
                     keytype="ENSEMBL",
                     multiVals="first")
res$entrez <- mapIds(org.Hs.eg.db,
                     keys=ens.str,
                     column="ENTREZID",
                     keytype="ENSEMBL",
                     multiVals="first")
resSig <- subset(res, padj < 0.05)
write.csv(as.data.frame(resSig),file="results_sig.csv")

#volcano plot
library(EnhancedVolcano)

# 1. Convert DESeq2 results to a standard data frame
res_df <- as.data.frame(res)

# 2. Filter out rows where padj is NA (standard DESeq2 independent filtering)
res_clean <- res_df[!is.na(res_df$padj), ]

# 3. Create a fallback label vector: Use Symbol, but if Symbol is NA, use the Ensembl ID (rowname)
gene_labels <- ifelse(
  is.na(res_clean$symbol) | res_clean$symbol == "", 
  rownames(res_clean), 
  as.character(res_clean$symbol)
)

# 4. Generate the Volcano Plot with connector arrows
p <- EnhancedVolcano(
  res_clean,
  lab = gene_labels,
  x = 'log2FoldChange',
  y = 'padj',
  pCutoff = 0.05,
  FCcutoff = 1.0,
  pointSize = 2.0,
  labSize = 2.0,
  title = 'DESeq2 Volcano Plot',
  subtitle = 'TDP43pos vs TDP43neg',
  
  # --- Connector and Arrow Configurations ---
  drawConnectors = TRUE,          # Enables lines connecting text to dots
  widthConnectors = 0.2,          # Thickness of the connecting line
  colConnectors = 'grey30',       # Colour of the connecting line
  arrowheads = FALSE,              # Turns the line ends into arrows
  max.overlaps = 20               # Allows more labels to draw lines before giving up
)

#save volcano plot
ggsave(
  filename = "enhanced_volcano_plot.tiff", # Can also use .pdf, .tiff, or .jpeg
  plot = p,
  width = 8,        # Width of the output image in inches
  height = 10,       # Height of the output image in inches
  dpi = 300         # Publication-quality resolution
)
```

**results_sig.csv** file show significantly differentially expressed genes (padj < 0.05)

| Gene	| baseMean	| log2FoldChange	| lfcSE	| stat	| pvalue	| padj	| symbol	| entrez |
|-------|-----------|-----------------|-------|-------|---------|-------|---------|--------|
| ENSG00000101327.10 | 617.2900562 | 24.53161273 | 3.456142637 | 7.097974624 | 1.27E-12 | 4.04E-10 | PDYN | 5173 |
| ENSG00000169083.19 | 111.2404403 | 22.23865575 | 3.001345154 | 7.409562918 | 1.27E-13 | 4.49E-11 | AR | 367 |
| ENSG00000169836.6 | 115.6030873 | 22.17312919 | 2.984259242 | 7.430027821 | 1.09E-13 | 3.93E-11 | TACR3 | 6870 |
| ENSG00000126583.13 | 104.7631083 | 22.0468387 | 3.046456679 | 7.236879111 | 4.59E-13 | 1.56E-10 | PRKCG | 5582 |
| ENSG00000144583.5 | 102.7689654 | 22.02551863 | 3.047019343 | 7.228545722 | 4.88E-13 | 1.62E-10 | MARCHF4 | 57574 |
| ENSG00000156486.9 | 93.36005721 | 21.85469912 | 3.118543797 | 7.007982105 | 2.42E-12 | 7.57E-10 | KCNS2 | 3788 |

**Gene** - Ensembl Gene ID  
**log2FoldChange** - log2 fold-change TDP43pos / TDP43neg    
**pvalue** - Wald test p-value: Condition TDP43pos vs TDP43neg  
**padj** - p-value adjusted for multiple testing (FDR)  
**symbol** - gene symbol  
**entrez** - Entrez database ID
