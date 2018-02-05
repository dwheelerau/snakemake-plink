from os.path import join
import os, sys
import glob
from datetime import datetime, date, time
configfile: "./config.yaml"

#GLOBALS
DIRS = ['VCF', 'HAPMAP', 'PHENO', 'logs']
now = datetime.now().strftime('%Y-%m-%d-%H-%M')
date_string = "{}".format(now)

# genotype and phenotype file paths
geno_file = os.path.join(DIRS[0], config['GENO'])
pheno_file = os.path.join(DIRS[2], config['PHENO'])
print(geno_file)
print(pheno_file)

THREAD = config['THREADS']

rule setup:
    output: DIRS
    shell:
        "mkdir -p "+' '.join(DIRS)

rule clean:
    shell:
        "rmdir --ignore-fail-on-non-empty "+' '.join(DIRS)

rule all:
    input:
        expand("{path}", path=geno_file),
        "tmp.map"

#"plinkdata.ped",
rule load_data:
    input:
        geno = expand("{path}", path=geno_file),
        pheno = expand("{path}", path=pheno_file)
    output:
        ped="plinkdata.ped",
        map="plinkdata.map",
    log: "logs/read_data.log"
    shell:
        "plink --recode --vcf {input.geno} --pheno {input.pheno} "
        "--allow-no-sex --keep-allele-order --out plinkdata "
        "2>&1 | tee -a {log}"

## this adds a column for SNP id which is chr1_posn
rule fix_snp_ids:
    input: "plinkdata.map"
    output: "tmp.map",
    log: "logs/fix_map_ids.log"
    shell:
        """
        echo 'Map file currently looks like this' | tee {log}
        head -n5 {input} | tee -a {log}
        python3 scripts/fix_snpID.py {input} {output}
        rm {input}
        cp {output} {input}
        echo 'Map file now looks like this' | tee -a {log} 
        head -n5 {input} | tee -a {log}
        touch {output} 
        """

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
