from os.path import join
import os, sys
import glob
from datetime import datetime, date, time

configfile: "./config.yaml"

#GLOBALS
DIRS = ['VCF', 'HAPMAP', 'PHENO', 'logs', 'results', 'plots']
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
        rm -f plink*
        rm -f logs/*
        rm -f tmp.map
        rm -f *.png
        rm -f assoc*
        rm -f results/*
        rm -f plots/*
        rm -f str1*
        """
# run the entire analysis, will stop if no filtering vals set
rule all:
    input:
        expand("{path}", path=geno_file),
        "results/assoc1.qassoc.adjusted.tsv",
        "results/assoc2.assoc.linear.adjusted.tsv",
        "results/assoc3.qassoc.adjusted.tsv"

# subset commands
rule qc:
    input: "missing_snp_genotypes.png"

rule filter_snps:
    input: "plinkdataFiltered.bed"

rule assoc:
    input:
        "results/assoc1.qassoc.adjusted.tsv",
        "results/assoc2.assoc.linear.adjusted.tsv",
        "results/assoc3.qassoc.adjusted.tsv"

#rule pop_corrected_assoc:
#    input: "results/assoc2.assoc.linear.adjusted.tsv"

#rule structure_pop:
#    input: "results/assoc3.qassoc.adjusted.tsv"

# the indiv steps
rule load_data:
    input:
        geno = expand("{path}", path=geno_file),
        pheno = expand("{path}", path=pheno_file)
    output:
        ped="plinkdata.ped",
        map="plinkdata.map",
    log: "logs/read_data.log"
    threads: config['THREADS']
    shell:
        "plink --recode --vcf {input.geno} --pheno {input.pheno} "
        "--allow-no-sex --keep-allele-order --out plinkdata "
        "2>&1 | tee -a {log}"

## this adds a column for SNP id which is chr1_posn
rule fix_snp_ids:
    input: "plinkdata.map"
    output: "tmp.map",
    log: "logs/fix_map_ids.log"
    threads: config['THREADS']
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
    threads: config['THREADS']
    shell:
        "plink --bfile plinkdata --freq --missing --het "
        " --allow-no-sex --out plinkdata"

rule make_graphs:
    input: "plinkdata.frq"
    output: "missing_snp_genotypes.png"
    log: "logs/qc_data.log"
    threads: config['THREADS']
    shell:
        """
        Rscript scripts/qc_graphs.R  2>&1 | tee {log}
        echo 'Please check QC data and set filtering params'
        echo 'in config file'
        """

# --hwe
rule filter:
    input: "missing_snp_genotypes.png"
    output: "plinkdataFiltered.bed"
    log: "logs/filter.log"
    threads: config['THREADS']
    params:
        MAF=config['MAF'],
        GENO=config['GENO'],
        MIND=config['MIND']
    shell:
        "plink --bfile plinkdata --allow-no-sex --keep-allele-order "
        "--maf {params.MAF} --geno {params.GENO} --mind {params.MIND} "
        "--make-bed --out plinkdataFiltered 2>&1 | tee {log}"

rule basic_assoc:
    input: "plinkdataFiltered.bed"
    output: results="results/assoc1.qassoc.adjusted.tsv",
            plot="plots/assoc1.qassoc.adjusted_qq.png",
            manhattan="plots/assoc1.qassoc_man.png"
    threads: config['THREADS']
    log: "logs/assoc1.log"
    shell:
        """
        plink --bfile plinkdataFiltered --assoc --out assoc1 \
            --allow-no-sex --adjust --qq-plot 2>&1 | tee {log}
        cat assoc1.qassoc | tr -s ' ' '\t' > assoc1.qassoc.tsv
        cat assoc1.qassoc.adjusted | tr -s ' ' '\t' > assoc1.qassoc.adjusted.tsv
        mv *tsv results/
        Rscript scripts/qq_plot.R assoc1.qassoc.adjusted {output.plot}
        Rscript scripts/manhattan.R assoc1.qassoc {output.manhattan}
        """
# pop correction
rule assoc_pop_correction:
    input: "plinkdataFiltered.bed"
    output: results="results/assoc2.assoc.linear.adjusted.tsv",
            plot="plots/assoc2.assoc.linear.adjusted_qq.png",
            manhattan="plots/assoc2.assoc.linear_man.png"
    log: "logs/assoc1.log"
    threads: config['THREADS']
    shell:
        """
        plink --bfile plinkdataFiltered --linear --out assoc2 \
            --allow-no-sex --adjust --qq-plot 2>&1 | tee {log}
        cat assoc2.assoc.linear | tr -s ' ' '\t' > assoc2.assoc.linear.tsv 
        cat assoc2.assoc.linear.adjusted | tr -s ' ' '\t' > {output.results}
        mv *tsv results/
        Rscript scripts/qq_plot.R assoc2.assoc.linear.adjusted {output.plot}
        Rscript scripts/manhattan.R assoc2.assoc.linear {output.manhattan}
        """

# clustering
# ToDo: add r script to draw mds plot
rule cluster:
    input: "plinkdataFiltered.bed"
    output: "str1.cluster2"
    log: "logs/cluster.log"
    threads: config['THREADS']
    shell:
        """
        plink --bfile plinkdataFiltered --cluster --mc 2 \
            -out str1 --allow-no-sex 2>&1 | tee {log}
        plink --bfile plinkdataFiltered --distance-matrix \
            --genome 2>&1 | tee -a {log}
        plink --bfile plinkdataFiltered --read-genome plink.genome \
            --cluster --mds-plot 3 2>&1 | tee -a {log}
        #Rscript scripts/draw_mds.R plink.mds plink.mds.png
        """

rule cluster_perm:
    input: "str1.cluster2"
    output: "results/assoc3.qassoc.adjusted.tsv"
    log: "logs/clustering_perm.log"
    threads: config['THREADS']
    shell:
        """
        plink --bfile plinkdataFiltered --assoc --within {input} \
            --adjust --out assoc3 --allow-no-sex --perm 2>&1 | tee {log}
        cat assoc3.qassoc | tr -s ' ' '\t' > results/assoc3.qassoc.tsv
        cat assoc3.qassoc.adjusted | tr -s ' ' '\t' > results/assoc3.qassoc.adjusted.tsv
        cat assoc3.qassoc.perm | tr -s ' ' '\t' > results/assoc3.qassoc.perm.tsv
        """

onerror:
    print("If the filter rule fails then please check the config file")
    print("and make sure sensible values for maf, geno, and mind are set")
    print("If you get an error, can't find plink, remember to activate")
    print("via 'source activate plink' OR ")
    print("'conda create --name plink --file envs/plink.yaml'")
