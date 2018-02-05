#!/bin/bash

plink --file ./myplinkp1recodFilt --assoc --within str1.cluster2 \
  --adjust --out ./as2 --allow-no-sex --perm

# fix the funny spacing
cat as2.qassoc | tr -s ' ' '\t' > as2.qassoc.tsv
cat  as2.qassoc.adjusted | tr -s ' ' '\t' > as2.qassoc.adjusted.tsv
cat as2.qassoc.perm | tr -s ' ' '\t' > as2.qassoc.perm.tsv
