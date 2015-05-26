library(ggplot2)
library(rjson)
source("~/opt/r_helper_scripts/bootsSummary.r")

d = read.table("exp1.csv", header=T, sep=",")

#by item histogram of given a number
give_number = subset(d, measure == "give_number")
give_number$response = as.numeric(as.character(give_number$response))
ggplot(give_number, aes(x=response)) +
  geom_histogram() +
  facet_wrap(~ tag,scale="free")

summary(d)
unique(d[d$comments != "",]$comments)
summary(d$measure)

# by item histogram of binned histograms
binned_histogram = droplevels(subset(d, measure == "binned_histogram"))
summary(binned_histogram)
binned_histogram$response = as.numeric(as.character(binned_histogram$response))

binned_histogram_summary = bootsSummary(binned_histogram, measurevar="response",
                                        groupvars=c("bin", "tag"))

all_bins = as.character(unique(binned_histogram$bins))
all_bins = c(all_bins, all_bins[1])
lapply(all_bins, function(str) {fromJSON(str)})
names(all_bins) = c("joke", "movies", "tv", "coffee", "watch", "commute", "laptop", "marbles")


binned_histogram_summary$bin_num = 

ggplot(binned_histogram_summary, aes(x=bin, y=response)) +
  geom_bar(stat="identity") +
  facet_wrap(~ tag, scale="free")

agr = aggregate(response ~ bin+tag,data=binned_histogram,FUN="mean")
agr$CILow = aggregate(response ~ bin+tag,data=binned_histogram,FUN="ci.low")$response

str(binned_histogram)
