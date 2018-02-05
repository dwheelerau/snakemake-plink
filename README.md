## Snakemake pipeline for plink  
This is a plink pipeline that will process either VCF or hapmap files.
NOTE: Hapmap is not yet in place.  

### Guide
1. Setup or activate the environment with conda  
'''
source activate plink
# or if you need to clone the env
conda --name plink --file envs/plink.yaml
'''

2. Setup the directory structure.  
'''snakemake setup'''

3. Copy your multisample VCF file into the '''VCF''' directory.  

4. Copy your phenotype file in the the '''PHENO''' directory (see below).   

5. Add the pheno and geno filenames (don't append path) to the '''config.yaml''' file.

6. Run the pipeline to generate QC stats from the vcf.  
'''snakemake all --cores 2'''

7. The pipeline will generate quality stats and plots, check these files before setting
   the filtering variables in the '''config.yaml''' file.  

8. After adding filtering paramaters restart the pipeline  
'''snakemake all --cores 2'''

9. The final results are in '''results/'''.  

10. To cleanup (deletes all output).  
'''snakemake clean'''

### Important notes about the VCF file  
Expect a multisample VCF file. **Importantly**, the chromosome and scaffold
names need to be only numbers, so remove any 'scaffold_' or 'chr' strings from
the file before you used it.  
'''sed 's/scaffold_//g' your_file.vcf > your_file_fixed.vcf'''

### pheno file  
The phenotype file is in the following format, with space breaks. Note Header.  
'''
FID IID dot
AUS AUS 93.33
NZ NZ -9
USA USA 33.33
'''  
Here the 'dot' is the phenotype heading, only include one phenotype. The IID
and FID are family and individual IDs. This pipeline is only setup for
unrelated indiv at this stage, so the FID and IID can be the same.
