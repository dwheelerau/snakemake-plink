#!/bin/bash 
# this is the simplest form of assoc testing for quantitative loci
# --adjust adds FDR, see next script
# sort the data -nr is reverse order of numeric data
# sort --key=9 -nr as1.qassoc | head sorts by wald test p-value
# --adjust adds FRD
# --lenear adds a linear model (ads .linear. to output)
plink --file ./myplinkp1recodFilt --assoc --out as1 \
  --allow-no-sex --adjust --linear

echo '----Raw values (manually check sorting!)----'
head -n1 as1.qassoc
sort --key=9 -nr as1.qassoc | head

echo '----FDR adjusted values----'
head as1.qassoc.adjusted
#sort --key=9 -nr as1.qassoc.adjusted | head

echo '----linear model----'
sort --key=9 -nr as1.assoc.linear | head

echo '----linear model FDR---'
head as1.assoc.linear.adjusted

# finally get rid of the crazzy spacing
cat as1.qassoc | tr -s ' ' '\t' > as1.qassoc.tsv
cat as1.qassoc.adjusted | tr -s ' ' '\t' > as1.qassoc.adjusted.tsv
cat as1.assoc.linear | tr -s ' ' '\t' > as1.assoc.linear.tsv 
cat as1.assoc.linear.adjusted | tr -s ' ' '\t' > as1.assoc.linear.adjusted.tsv
