## Snakemake pipeline for plink
This is a plink pipeline that will process either VCF or hapmap files. To use
this pipeline run:

'''snakemake setup'''

This will create two directories, one called '''VCF''', and the other called
'''hapmap'''. Depending on your starting files you would copy your raw data
into one of these two directories.

### Software install is managed by conda
'''snakemake --use-conda'''
