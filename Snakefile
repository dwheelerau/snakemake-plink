from os.path import join
import os, sys
import glob
from datetime import datetime, date, time
configfile: "./config.yaml"

#GLOBALS
now = datetime.now().strftime('%Y-%m-%d-%H-%M')
date_string = "{}".format(now)
geno_file = config['geno']
pheno_file = config['pheno']

DIRS = ['VCF', 'HAPMAP', 'PHENO', 'logs']

# initially this will only work with VCF

#vcf = os.listdir(DIRS[0])
#hm = os.listdir(DIRS[1])
#if len(vcf) == 1:
#    target_f = os.path.join(DIRS[0], vcf[0])
#elif len(hm) == 1:
#    target_f = os.path.join(DIRS[1], hm[0])
#    print("sorry only VCF is working ATM")
#    sys.exit(1)
#else:
#    print("Please run 'snakemake setup'")
#    print("and then copy your VCF or HAPMAP file")
#    print("into the corresponding directory.")
#    print("Otherwise please ensure only ONE of these")
#    print("directories contains a SINGLE file")
#    sys.exit(1)

#try:
#    pheno_f = os.listdir(DIRS[2])
#    assert len(pheno_f) == 1
#    pheno_target = os.path.join(DIRS[2], pheno_f[0])
#except AssertionError:
#    print('Please ensure phenotype file contains only')
#    print('one space separated file that looks like the following.')
#    print('(missing data is coded with -9')
#    print('FID IID dot')
#    print('NZE NZE 10.2')
#    print('ALP ALP -9')

THREAD = config['THREADS']

rule setup:
    output: DIRS
    shell:
        "mkdir -p "+' '.join(DIRS)

rule clean:
    shell:
        "rmdir -f "+' '.join(DIRS)

#rule all:
#    input:
#        geno = target_f,
#        pheno = pheno_target
#rule load_data:
#    input: target_f
#    ouput: plinkdata.ped
#    log: "logs/read_data.log"
#    shell:
#        "plink --recode --vcf {input.geno} --pheno {input.pheno'} --allow-no-seq --keep-allele-order --out plinkdata 2>&1 | tee -a {log}"
#
## this adds a column for SNP id which is chr1_posn
#rule fix_snp_ids:
#    input: plinkdata.map
#    output: plinkdataIds.map
#    run:
#        "scripts/fix_snpID.py {input} {output}"
#
## this converts the files to binary for fast acccess
#rule make_bed:
#    input:
#         ped=plinkdataIds.ped,
#    output:
#        plinkdataIds.bed
#    log: "logs/convert_to_bed.log"
#    shell:
#        """
#        plink --make-bed --file plinkdataIds --allow-no-sex \
#            --keep-allele-order 2>&1 | tee -a {log}
#        """
