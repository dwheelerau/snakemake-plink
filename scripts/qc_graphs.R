#!/usr/bin/env Rscript

# simple script to plot some data from plink
#args<-commandArgs(TRUE)
HetData <-read.table("plinkdata.het", head=T)
HetData
png("heterozygousity_dist.png")
hist(HetData$F, breaks=100)
dev.off()

missing_calls_indiv<-read.table("plinkdata.imiss", head=T)
missing_calls_indiv
png("proportion_missing_indiv_calls.png")
hist(missing_calls_indiv$F_MISS, breaks=10)
dev.off()

missing_genotypes<-read.table('plinkdata.lmiss',head=T)
head(missing_genotypes)
png("missing_snp_genotypes.png")
hist(missing_genotypes$F_MISS, breaks=100)
dev.off()
