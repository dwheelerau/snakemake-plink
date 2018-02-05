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
geno_file = os.path.join(DIRS[0], config['GENOTYPES'])
pheno_file = os.path.join(DIRS[2], config['PHENO'])
print(geno_file)
print(pheno_file)

rule setup:
    output: DIRS
    shell:
        "mkdir -p "+' '.join(DIRS)

rule clean:
    shell:
        """
        rm -f plinkdata*
        rm -f logs/*
        rm -f tmp.map
        rm -f *.png
        """

rule all:
    input:
        expand("{path}", path=geno_file),
        "plinkdataFiltered.bed"

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
rule make_bed:
    input: "tmp.map"
    output: "plinkdata.bed"
    log: "logs/convert_to_bed.log"
    threads: config['THREADS']
    shell:
        "plink --make-bed --file plinkdata --allow-no-sex "
        "--keep-allele-order --out plinkdata 2>&1 | tee -a {log}"

rule report_stats:
    input: "plinkdata.bed"
    output: "plinkdata.frq"
    shell:
        "plink --bfile plinkdata --freq --missing --het "
        " --allow-no-sex --out plinkdata"

rule make_graphs:
    input: "plinkdata.frq"
    output: "missing_snp_genotypes.png"
    shell:
        """
        Rscript scripts/qc_graphs.R
        echo 'Please check QC data and set filtering params'
        echo 'in config file'
        """

# --hwe
rule filter:
    input: "missing_snp_genotypes.png"
    output: "plinkdataFiltered.bed"
    log: "logs/filter.log"
    params:
        MAF=config['MAF'],
        GENO=config['GENO'],
        MIND=config['MIND']
    shell:
        "plink --bfile plinkdata --allow-no-sex --keep-allele-order "
        "--maf {params.MAF} --geno {params.GENO} --mind {params.MIND} "
        "--make-bed --out plinkdataFiltered 2>&1 | tee {log}"

onerror:
    print("If the filter rule fails then please check the config file")
    print("and make sure sensible values for maf, geno, and mind are set")
