#!/usr/bin/env Rscript
library(qqman)
args<-commandArgs(TRUE)

#assoc1.qassoc
results<-read.table(args[1], header=T)
results<-na.omit(results)
png(args[2])
manhattan(results, main=args[1])
dev.off()
