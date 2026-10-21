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
  
To install packages from CRAN:  
```
install.packages("package_name")
```
1: You need htseq formatted files containing gene counts generated from STAR (see 
