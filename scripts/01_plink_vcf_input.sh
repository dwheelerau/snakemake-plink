#!/bin/bash

# import a vcf file into plink format using a pheno.txt file (space sep) to 
# include phenotpye data
# cat traits.txt # quantitative data, 0,1,2 would be case control. -9 is missing
# data
##FID IID dot
##NZE2 NZE2 -9
##COLN COLN -9
##NZE8 NZE8 -9
##NZE10 NZE10 10.54
##ALP3 ALP3 77.84
##AUS4 AUS4 2.03
##BHU1 BHU1 0.99
##CAN3 CAN3 10.37
##CHI17 CHI17 0.26
##COLN COLN 8.14
##COLS COLS 0.33
##DEN1 DEN1 1.43
##ECU13 ECU13 7.49
##GRE1 GRE1 0.6
##GUA1 GUA1 12.16
##GUA2 GUA2 16.85
##RUS1 RUS1 5.96
##SAF4 SAF4 21.58
##SLV1 SLV1 6.6
##USA12 USA12 0.53

# --allow-no-sex because not family data is know
#NOTE: chr1 or chromosome_1 needs to be modified to 1, unless use use a flag to specify names
OUT='myplinkp1'
plink --recode --vcf combined.freebayes.p1.annot.q30.chmrename.vcf \
 --pheno ./trait_dot_plink.txt --allow-no-sex --out $OUT

# now fix . missing snp ids which are need for ident of position with FDR
# testing
#./fix_snpID.py <infile.map> <outfile.map>
OUT2=${OUT}.fix
python2 fix_snpID.py ${OUT}.map $OUT2

rm -f $OUT.map
mv $OUT2 $OUT.map

echo 'check that dot(.) is replaced by chr_pos in second col'
head -n 5 $OUT.map
