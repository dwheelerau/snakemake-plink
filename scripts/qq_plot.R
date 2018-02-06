#!/usr/bin/env Rscript
#library(qqman)

args<-commandArgs(TRUE)

#'assoc1.qassoc.adjusted'
data<-read.table(args[1], header=T)
png(args[2])
plot(-log(data$QQ, 10), -log(data$UNADJ,10),xlab="expected - logP value", ylab="observed -log Pvalue", main=args[1])
abline(a=0,b=1)
dev.off()

#results<-read.table('assoc1.qassoc', header=T)
#results<-na.omit(results)
#png('assoc1.qassoc_manhattan.png')
#manhattan(results, main="Manhattan assoc1.qassoc")
#dev.off()

#png('assoc1.qassoc_QQplot.png')
#qq(results$P)
#dev.off()
