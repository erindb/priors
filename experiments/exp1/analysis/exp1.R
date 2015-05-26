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

binned_histogram_summary = bootsSummary(binned_histogram, measurevar="response",
                                        groupvars=c("bin", "tag", "bin_num"))

ggplot(binned_histogram_summary, aes(x=bin_num, y=response)) +
  geom_bar(stat="identity") +
  facet_wrap(~ tag, scale="free")

lightning = subset(d, measure == "lightning")
lightning$response = paste(lightning$response, ">", lightning$unchosen_contrast)
lightning$choice = paste(lightning$response, ">", lightning$unchosen_contrast)

lightning$response = as.character(lightning$response)
lightning$unchosen_contrast = as.character(lightning$unchosen_contrast)

lightning$choice = sapply(i:nrow(lightning), function(i) {
  chosen = lightning$response[i]
  unchosen = lightning$unchosen_contrast[i]
  paste(sort(c(chosen, unchosen)), collapse=" ")
})