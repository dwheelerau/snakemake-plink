## Snakemake pipeline for plink  
This is a plink pipeline that will process either VCF or hapmap files.
NOTE: Hapmap is not yet in place.  

### Guide
1. Setup or activate the environment with conda  
```
source activate plink
# or if you need to clone the env
conda --name plink --file envs/plink.yaml
```

2. Setup the directory structure.  
```snakemake setup```

3. Copy your multisample VCF file into the ```VCF``` directory.  

4. Copy your phenotype file in the the ```PHENO``` directory (see below).   

5. Add the pheno and geno filenames (don`t append path) to the ```config.yaml``` file.

6. Run the pipeline to generate QC stats from the vcf.  
```snakemake qc --cores 2```

7. The pipeline will generate quality stats and plots, check these files before setting
   the filtering variables in the ```config.yaml``` file.  

8. After adding filtering paramaters, filter  
```snakemake filter_snps --cores 2```

9. Finally run the assoc.  
```snakemake assoc --cores 2```

The final results are in  ```results``` and ```plots```, also check logs!  

10. To cleanup (deletes all output).  
```snakemake clean```

### Important notes about the VCF file  
Expect a multisample VCF file. **Importantly**, the chromosome and scaffold
names need to be only numbers, so remove any `scaffold_` or `chr` strings from
the file before you used it.  
```sed `s/scaffold_//g` your_file.vcf > your_file_fixed.vcf```

### pheno file  
The phenotype file is in the following format, with space breaks. Note Header.  
```
FID IID dot
AUS AUS 93.33
NZ NZ -9
USA USA 33.33
```  
Here the `dot` is the phenotype heading, only include one phenotype. The IID
and FID are family and individual IDs. This pipeline is only setup for
unrelated indiv at this stage, so the FID and IID can be the same.  

### snakemake all
This rule is available but will stop unless values are added to the config file
for the filtering; useful if you are repeating analysis where you already know
these values in advance.

### Table headings (that are not obvious)   
```assoc1.qassoc.adjusted.tsv```  
UNADJ - unadj signif  
GC - Genomic control adusted signif (not multiple testing correction)   
QQ - QQ plot value  
BONF - Bonferroni adjusted pvalues  
HOLM - Holm step-down adjusted pvalues  
SIDAK_SS - single step adjusted pvalues 
SIDAK_SD - single step adjusted pvalues  
FDR_BH - Benjamini + Hochberg steup FDR (1995)  
FDR_BY - Benjamini + Yekutieli (2001)  

```assoc1.qassoc.tsv```
NMISS - number of no missing individuals  
BETA - Regression Coef  
SE - Standard error of the coef  
R2 - The regression R2 (multiple correlation coefficient)  
T - t-stat for regression of phenotpe on allele count  
P - Asymptotic significance value for coef  

```assoc2.assoc.linear.tsv```  
A1 - Tested Allele (minor by default, can be changed with --keep-allele-order  
TEST - code for test, by default additive  
NMISS - number of non-missing indiv  
BETA - Regression coef  
STAT - coef of the t-stat  
P - Asymptopic p-value of the t-statistic  

```assoc3.qassoc.perm.tsv```  
EMP1 - Ascend sort this, emprical p-value, smaller better  
NP - number of permiations performed. Can be NA if not going to be
significant.  
