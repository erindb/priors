library(ggplot2)
library(rjson)
#setwd("/Users/titlis/cogsci/projects/stanford/projects/priors/experiments/exp1/analysis")
#source("~/opt/r_helper_scripts/bootsSummary.r")
source("helpers.R")

d = read.table("exp1.csv", header=T, sep=",")

### NUMBER TASK
#by item histogram of given a number
give_number = subset(d, measure == "give_number")
give_number$response = as.numeric(as.character(give_number$response))
ggplot(give_number, aes(x=response)) +
  geom_histogram() +
  facet_wrap(~ tag,scale="free")
ggsave("graphs/number_histogram.pdf")

summary(d)
unique(d[d$comments != "",]$comments)
summary(d$measure)

### BINNED HISTOGRAM
# by item histogram of binned histograms
binned_histogram = droplevels(subset(d, measure == "binned_histogram"))
summary(binned_histogram)
binned_histogram$response = as.numeric(as.character(binned_histogram$response))

##get bin_num
all_bins = as.character(unique(binned_histogram$bins))
all_bins = c(all_bins, all_bins[1])
all_bins = lapply(all_bins, function(str) {
  str = gsub("u", "", str)
  str = gsub("'", "\"", str)
  str = gsub(".xb0", "°", str)
  fromJSON(str)
})
names(all_bins) = c("joke", "movies", "tv", "coffee", "watch", "commute", "laptop", "marbles")
binned_histogram$bin_num = sapply(1:nrow(binned_histogram), function(i) {
  bin = as.character(binned_histogram$bin)[i]
  tag = as.character(binned_histogram$tag)[i]
  which(all_bins[[tag]] == bin)
})

# binned_histogram_summary = bootsSummary(binned_histogram, measurevar="response",
#                                         groupvars=c("bin", "tag", "bin_num"))
# 
# ggplot(binned_histogram_summary, aes(x=bin_num, y=response)) +
#   geom_bar(stat="identity") +
#   facet_wrap(~ tag, scale="free")

agr = aggregate(response~bin+tag+bin_num,data=binned_histogram,FUN="mean")
agr$CILow = aggregate(response~bin+tag+bin_num,data=binned_histogram,FUN="ci.low")$response
agr$CIHigh = aggregate(response~bin+tag+bin_num,data=binned_histogram,FUN="ci.high")$response
agr$YMin = agr$response - agr$CILow
agr$YMax = agr$response + agr$CIHigh

ggplot(agr, aes(x=bin_num, y=response)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25) +
  facet_wrap(~ tag, scale="free")
ggsave("graphs/binned_histogram_raw_means.pdf")

# normalize responses
library(dplyr)
library(plyr)
tmp =  ddply(binned_histogram, .(workerid,tag), summarise, bin=bin, bin_num=bin_num,normresponse=response/sum(response))

agr = aggregate(normresponse~bin+tag+bin_num,data=tmp,FUN="mean")
agr$CILow = aggregate(normresponse~bin+tag+bin_num,data=tmp,FUN="ci.low")$normresponse
agr$CIHigh = aggregate(normresponse~bin+tag+bin_num,data=tmp,FUN="ci.high")$normresponse
agr$YMin = agr$normresponse - agr$CILow
agr$YMax = agr$normresponse + agr$CIHigh

ggplot(agr, aes(x=bin_num, y=normresponse)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25) +
  facet_wrap(~ tag, scale="free")
ggsave("graphs/binned_histogram_norm_means.pdf")


### LIGHTNING ROUND
lightning = subset(d, measure == "lightning") %>% select(workerid,response, unchosen_contrast,tag,pairs)
lightning$choice = paste(lightning$response, ">", lightning$unchosen_contrast)

all_pairs = as.character(unique(lightning$pairs))

