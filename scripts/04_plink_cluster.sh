#!/bin/bash

# control for population structure by clustering
# in pairs (--mc 2)or K , such that any pair has a sig
# value less than 0.05 (--ppc 0.05).
plink --file ./myplinkp1recodFilt --cluster --mc 2 \
  --out str1 --allow-no-sex
