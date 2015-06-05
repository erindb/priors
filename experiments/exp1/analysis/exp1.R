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
ggsave("graphs/number_histogram.png")

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
ggsave("graphs/binned_histogram_raw_means.png")

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
ggsave("graphs/binned_histogram_norm_means.png")


### LIGHTNING ROUND
lightning = subset(d, measure == "lightning") %>% select(workerid,response, unchosen_contrast,tag,pairs)

library(stringr)

lightning$response = as.character(lightning$response)
lightning$unchosen_contrast = as.character(lightning$unchosen_contrast)

lightning$chosen_tag = sapply(lightning$response, function(response) {
  response_numbers = str_match(response, "(\\$?[0-9]+([^0-9]F )?-? ?\\$?[0-9]*([^0-9]F)?)[^0-9]")
  response_tag = response_numbers[[2]]
  response_tag
})

lightning$unchosen_tag = sapply(lightning$unchosen_contrast, function(bin) {
  bin_numbers = str_match(bin, "(\\$?[0-9]+([^0-9]F )?-? ?\\$?[0-9]*([^0-9]F)?)[^0-9]")
  bin_tag = bin_numbers[[2]]
  bin_tag
})

lightning$choice = mapply(function(chosen, unchosen) {
  chosen_first_num = str_match(chosen, "\\$?([0-9]+)([^0-9]?-[^0-9]?)?")[[2]]
  unchosen_first_num = str_match(unchosen, "\\$?([0-9]+)([^0-9]?-[^0-9]?)?")[[2]]
  paste(c(chosen, unchosen)[order(as.numeric(c(chosen_first_num, unchosen_first_num)))], collapse=" >?< ")
}, lightning$chosen_tag, lightning$unchosen_tag)

lightning$lower_chosen = mapply(function(chosen, unchosen) {
  chosen_first_num = as.numeric(str_match(chosen, "\\$?([0-9]+)([^0-9]?-[^0-9]?)?")[[2]])
  unchosen_first_num = as.numeric(str_match(unchosen, "\\$?([0-9]+)([^0-9]?-[^0-9]?)?")[[2]])
  chosen_first_num < unchosen_first_num
}, lightning$chosen_tag, lightning$unchosen_tag)

lightning$higher_chosen = mapply(function(chosen, unchosen) {
  chosen_first_num = as.numeric(str_match(chosen, "\\$?([0-9]+)([^0-9]?-[^0-9]?)?")[[2]])
  unchosen_first_num = as.numeric(str_match(unchosen, "\\$?([0-9]+)([^0-9]?-[^0-9]?)?")[[2]])
  if (chosen_first_num == unchosen_first_num) {
    return(nchar(chosen) > nchar(unchosen))
  } else {
    return(chosen_first_num > unchosen_first_num)
  }
}, lightning$chosen_tag, lightning$unchosen_tag)

lightning_summary = aggregate(higher_chosen~choice+tag,FUN="mean",data=lightning)
lightning_summary$YMin = lightning_summary$higher_chosen - aggregate(higher_chosen~choice+tag,FUN="ci.low",data=lightning)$higher_chosen
lightning_summary$YMax = lightning_summary$higher_chosen + aggregate(higher_chosen~choice+tag,FUN="ci.high",data=lightning)$higher_chosen

current_levels = c(
  ### marbles / joke
  "0  >?< 1 ", "1  >?< 5 ", "5  >?< 10 ", "10  >?< 13 ", "13  >?< 14 ",
  ### movies
  "0-15 >?< 15-30", "15-30 >?< 75-90", "75-90 >?< 150-165", "150-165 >?< 195-210", "195-210 >?< 210 ",
  ### TV
  "0-3 >?< 4-6", "4-6 >?< 16-18", "16-18 >?< 31-33", "31-33 >?< 40-42", "40-42 >?< 43 ",
  ### commute
  "0-6 >?< 7-13", "7-13 >?< 35-41", "35-41 >?< 70-76", "70-76 >?< 91-97", "91-97 >?< 98 ",
  ### laptop
  "$0-$500 >?< $500-$1000", "$500-$1000 >?< $2500-$3000", "$2500-$3000 >?< $5000-$5500",
  "$5000-$5500 >?< $6500-$7000", "$6500-$7000 >?< $7500",
  ### watch
  "$0-$50 >?< $50-$100", "$50-$100 >?< $250-$300", "$250-$300 >?< $500-$550",
  "$500-$550 >?< $650-$700", "$650-$700 >?< $750",
  ### coffee
  "44°F - 56°F >?< 44°F ", "44°F  >?< 44°F - 56°F", "44°F - 56°F >?< 92°F - 104°F",
  "92°F - 104°F >?< 152°F - 164°F", "152°F - 164°F >?< 188°F - 200°F", "188°F - 200°F >?< 200°F "
)
desired_levels = c(
  ### marbles/joke
  "0 >?< 1", "1 >?< 5", "5 >?< 10", "10 >?< 13", "13 >?< 14",
  ### movies
  "0 >?< 1", "1 >?< 5", "5 >?< 10", "10 >?< 13", "13 >?< 14",
  ### TV
  "0 >?< 1", "1 >?< 5", "5 >?< 10", "10 >?< 13", "13 >?< 14",
  ### commute
  "0 >?< 1", "1 >?< 5", "5 >?< 10", "10 >?< 13", "13 >?< 14",
  ### laptop
  "0 >?< 1", "1 >?< 5", "5 >?< 10", "10 >?< 13", "13 >?< 14",
  ### watch
  "0 >?< 1", "1 >?< 5", "5 >?< 10", "10 >?< 13", "13 >?< 14",
  ### coffee
  "0 >?< 1",
  "0 >?< 1", "1 >?< 5", "5 >?< 10", "10 >?< 13", "13 >?< 14"
)
names(desired_levels) = current_levels

lightning_summary$choice_as_bin_number = sapply(lightning_summary$choice, function(choice) {
  return(desired_levels[choice])
})
lightning_summary$choice_as_bin_number = factor(lightning_summary$choice_as_bin_number,
                                                levels=c("0 >?< 1", "1 >?< 5", "5 >?< 10", "10 >?< 13", "13 >?< 14"))

ggplot(lightning_summary, aes(x=choice_as_bin_number, y=higher_chosen)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(x=choice_as_bin_number, ymin=YMin, ymax=YMax), width=0.1) +
  facet_wrap(~ tag, scale="free") +
  theme(axis.text.x = element_text(angle = -45, hjust = 0))
ggsave("graphs/lightning_round.pdf",height=8)
ggsave("graphs/lightning_round.png",height=8)
 