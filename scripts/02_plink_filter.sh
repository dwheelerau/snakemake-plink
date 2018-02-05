#!/bin/bash

# this command filters the VCF files
#--maf: only INCLUDE SNPs with MAF >= value
# ie xxxxxxxx
#--geno 0.05: INCLUDE only SNPs with 95% genotyping rate (5% missing)
#--geno 0.1: INCLUDE only SNPs with 90% genotyping rate (10% missing)
#--mind 0.1: EXCLUDE SAMPLES (ie indiv) with MISSING genotypes GREATER than 10%
#--hwe 0.00001: EXCLUDE SNPs with HW p-values < this cutoff

plink --recode --file ./myplinkp1recod --mind 0.05 --geno 0.05 \
 --maf 0.02 --out ./myplinkp1recodFilt --allow-no-sex
