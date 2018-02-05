## Snakemake pipeline for plink  
This is a plink pipeline that will process either VCF or hapmap files. To use
this pipeline run:  

'''snakemake setup'''

This will create two directories, one called '''VCF''', and the other called
'''hapmap'''. Depending on your starting files you would copy your raw data
into one of these two directories.  

### Software install is managed by conda  
'''snakemake --use-conda'''  

### Genotype VCF file  
Expect a multisample VCF file. **Importantly**, the chromsome and scaffold
names need to be only numbers, so remove any 'scaffold_' or 'chr' strings from
the file before you used it.  

You will need to add the filename to the '''config.yaml''' file.

### pheno file  
The phenotype file is in the following format, with space separated breaks.  
'''
FID IID dot
AUS AUS 93.33
NZ NZ -9
USA USA 33.33
'''  
Here the 'dot' is the phenotype heading, only include one phenotype. The IID
and FID are family and individual IDs. This pipeline is only setup for
unrelated indiv at this stage so the FID and IID can be the same.
