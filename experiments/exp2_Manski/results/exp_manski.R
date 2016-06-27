library(ggplot2)
library(rjson)
setwd("/Users/titlis/cogsci/projects/stanford/projects/priors/experiments/exp2_Manski/results")
source("helpers.R")

d = read.table("data/results.csv", header=T, sep=",",quote="\"")
summary(d)
unique(d[d$comments != "",]$comments)
summary(d$measure)

### NUMBER TASK
#by item histogram of given a number
give_number = subset(d, measure == "give_number")
give_number$response = as.numeric(as.character(give_number$response))
ggplot(give_number, aes(x=response)) +
  geom_histogram() +
  facet_wrap(~ tag,scale="free")
ggsave("graphs/number_histogram.pdf")
ggsave("graphs/number_histogram.png")

### BINNED HISTOGRAM
# by item histogram of binned histograms
binned_histogram = droplevels(subset(d, measure == "binned_histogram"))
summary(binned_histogram)
binned_histogram$response = as.numeric(as.character(binned_histogram$response))

##get bin_num
# library(dplyr)
# library(tidyr)
unique_bins = binned_histogram %>% group_by(tag, bins) %>% summarise(N = length(tag)) %>%
  as.data.frame
all_bins = lapply(as.character(unique_bins$bins), fromJSON)
names(all_bins) = as.character(unique_bins$tag)
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

agr = binned_histogram %>%
  group_by(bin,tag,bin_num) %>%
  summarise(response = mean(response),CILow = ci.low(response),CIHigh = ci.high(response)) %>%
  mutate(YMin=response-CILow,YMax=response+CIHigh)

ggplot(agr, aes(x=bin_num, y=response)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25) +
  facet_wrap(~ tag, scale="free")
ggsave("graphs/binned_histogram_raw_means.pdf")
ggsave("graphs/binned_histogram_raw_means.png")

# normalize responses
# library(dplyr)
# library(plyr)
agr =  binned_histogram %>%
  group_by(workerid,tag) %>%
  mutate(sumresponse=sum(response)) %>% 
  group_by(workerid,tag,bin_num,bin) %>%
  summarise(normresponse=response/sumresponse) %>%
  group_by(bin,tag,bin_num) %>%
  summarise(normresponse = mean(normresponse),CILow=ci.low(normresponse),CIHigh=ci.high(normresponse)) %>%
  mutate(YMin=normresponse-CILow,YMax=normresponse+CIHigh)

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

lightning_summary$choice_as_bin_number = mapply(function(choice, tag) {
  ## we did not do this comparison for any of the other items
  if (choice=='44°F - 56°F >?< 92°F - 104°F') {
    return(NA)
  }
  choice=strsplit(choice, ' +>\\?< +')[[1]][1]
  if (choice=='44°F') {
    choice='44°F or less'
  }
  bins = all_bins[[tag]]
  bin_num = which(bins==choice)
}, lightning_summary$choice, as.character(lightning_summary$tag))
lightning_summary$choice_as_bin_number = factor(lightning_summary$choice_as_bin_number,
                                                levels=c(1, 2, 6, 11, 14), labels=c("0 >?< 1", "1 >?< 5", "5 >?< 10", "10 >?< 13", '14'="13 >?< 14"))

ggplot(lightning_summary, aes(x=choice_as_bin_number, y=higher_chosen)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(x=choice_as_bin_number, ymin=YMin, ymax=YMax), width=0.1) +
  facet_wrap(~ tag, scale="free") +
  theme(axis.text.x = element_text(angle = -45, hjust = 0))
ggsave("graphs/lightning_round.pdf",height=8)
ggsave("graphs/lightning_round.png",height=8)
 
## COMPARISON OF BINNED HISTOGRAM AND NUMBER TASK
### NUMBER TASK
give_number = subset(d, measure == "give_number")
give_number$response = as.numeric(as.character(give_number$response))

max_values = data.frame(Value=c(14,14,235,45,104, 7500, 800, 212))
row.names(max_values) = c("marbles","joke","movies","tv","commute","laptop","watch","coffee")

summary(give_number)
give_number = give_number %>% select(workerid, response, tag)
head(give_number)
nrow(give_number)
row.names(give_number) = paste(give_number$workerid, give_number$tag)
give_number$scaled_response = give_number$response/max_values[as.character(give_number$tag),]

# record what bin each worker's response falls into (counting bins from 1-15 instead of 0-14)
bins = read.csv("data/bins.txt",header=T)
bins$Bin = bins$Bin + 1
give_number$bin = sapply(1:nrow(give_number), function(i) {
  response = give_number$response[i]
  tag = as.character(give_number$tag)[i]
  bins[bins$Item == tag & bins$Min <= response & bins$Max >= response,]$Bin
})

####################################################

### BINNED HISTOGRAM

# normalize responses
tmp =  binned_histogram %>%
  group_by(workerid,tag) %>%
  mutate(sumresponse = sum(response)) %>%
  group_by(workerid,tag,bin_num) %>%
  summarise(normresponse=response/sumresponse)

ggplot(tmp, aes(x=bin_num, y=normresponse,group=1)) +
  geom_point() +
  geom_line() +  
  geom_vline(data=give_number,aes(xintercept=bin),color="red") +
  facet_grid(workerid ~ tag, scale="free")

ggplot(tmp, aes(x=bin_num, y=normresponse,group=1)) +
  geom_point() +
  geom_line() +  
  geom_vline(data=give_number,aes(xintercept=bin),color="red") +
  facet_grid(workerid ~ tag, scale="free")
ggsave("graphs/histogram_and_number_bysubject_byitem.png",height=15)

# summarize binned histogram
bh_summary = tmp %>%
  group_by(workerid, tag) %>%
  summarise(bh_mean=sum(bin_num*normresponse),bh_mode=paste(which(normresponse == max(normresponse)),collapse="_"))
head(bh_summary)
bh_summary$bh_mode # there's a few cases with more than one mode 
bh_summary$bh_mode_na = as.numeric(as.character(bh_summary$bh_mode))
bh_summary$bh_mode_na
row.names(give_number) = paste(give_number$workerid, give_number$tag)
bh_summary$number_response = give_number[paste(bh_summary$workerid,bh_summary$tag),]$bin

library(hydroGOF)

# r=.77, mse=8.59, r2=.6
gof(bh_summary$number_response, bh_summary$bh_mean)
# r=.83, mse=6.2, r2=.69
gof(bh_summary$number_response, bh_summary$bh_mode_na)

# by-subject correlations for means
cor_means = bh_summary %>%
  group_by(workerid) %>%
  summarise(r=gof(number_response, bh_mean, na.rm=TRUE)["r",])
cor_modes = bh_summary[!is.na(bh_summary$bh_mode_na),] %>%
  group_by(workerid) %>%
  summarise(r=gof(number_response, bh_mode_na,na.rm=TRUE)["r",])


# mode vs number response, collapsed across subjects (37 cases where there was more than one mode were excluded)
ggplot(bh_summary, aes(x=number_response, y=bh_mode_na, color=tag, group=1)) +
  geom_jitter() +#width=.0000001,height=.0000001) +
#  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1) +
  scale_x_continuous(name="Number response (bin)") +
  scale_y_continuous(name="Mode of binned histogram (bin)")
ggsave("graphs/bh_mode_vs_number_response.png")

# mode vs number response, by subject (37 cases where there was more than one mode were excluded)
ggplot(bh_summary, aes(x=number_response, y=bh_mode_na, color=tag, group=1)) +
  geom_point() +
#  geom_smooth() +
  geom_abline(intercept=0,slope=1,alpha=.5) +
  scale_x_continuous(name="Number response (bin)") +
  scale_y_continuous(name="Mode of binned histogram (bin)") +
  facet_wrap(~workerid)
ggsave("graphs/bh_mode_vs_number_response_bysubject.png")

# mean vs number response, collapsed across subjects
ggplot(bh_summary, aes(x=number_response, y=bh_mean, color=tag, group=1)) +
  #geom_jitter() +#width=.0000001,height=.0000001) +
    geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1) +
  scale_x_continuous(name="Number response (bin)") +
  scale_y_continuous(name="Mean of binned histogram (bin)")
ggsave("graphs/bh_mean_vs_number_response.png")

# mean vs number response, by subject
ggplot(bh_summary, aes(x=number_response, y=bh_mean, color=tag, group=1)) +
  geom_point() +
  #  geom_smooth() +
  geom_abline(intercept=0,slope=1,alpha=.5) +
  scale_x_continuous(name="Number response (bin)") +
  scale_y_continuous(name="Mean of binned histogram (bin)") +
  facet_wrap(~workerid)
ggsave("graphs/bh_mean_vs_number_response_bysubject.png")

# plot both mean and mode against number response by subject to see which one does better overall and whether different subjects behave differently
gathered = bh_summary %>%
        select(workerid, tag, number_response, bh_mean, bh_mode_na) %>%
        gather(measure, value, bh_mean:bh_mode_na)
head(gathered)

ggplot(gathered, aes(x=number_response, y=value, color=measure, group=measure)) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,alpha=.5) +
  scale_x_continuous(name="Number response (bin)") +
  scale_y_continuous(name="Binned histogram summary measure") 
ggsave("graphs/bhmeasure_vs_number_response.png")

ggplot(gathered, aes(x=number_response, y=value, color=measure, group=measure)) +
  geom_point() +
  geom_abline(intercept=0,slope=1,alpha=.5) +
  scale_x_continuous(name="Number response (bin)") +
  scale_y_continuous(name="Binned histogram measure") +
  facet_wrap(~workerid)
ggsave("graphs/bhmeasure_vs_number_response_bysubject.png")


library(lmerTest)
head(bh_summary)
m = lmer(number_response ~ bh_mean + (1+bh_mean|workerid), data=bh_summary)
summary(m)

m = lmer(number_response ~ bh_mode_na + (1+bh_mode_na|workerid), data=bh_summary)
summary(m)

m.1 = lmer(number_response ~ bh_mode_na + bh_mean + (1+bh_mode_na+ bh_mean|workerid), data=bh_summary)
summary(m.1)


### MANSKI

manski_summary = subset(d, measure == "Manski_sliders") %>%
  select(workerid,tag,Manski_min,Manski_likely,Manski_max) %>%
  gather(Measure,Value,-workerid,-tag) %>%
  group_by(tag,Measure) %>%
  summarise(Mean = mean(Value), CILow = ci.low(Value), CIHigh = ci.high(Value))
manski_summary = as.data.frame(manski_summary)
manski_summary$YMin = manski_summary$Mean - manski_summary$CILow
manski_summary$YMax = manski_summary$Mean + manski_summary$CIHigh
manski_summary$Response = factor(x=gsub("Manski_","",as.character(manski_summary$Measure)),levels=c("min","likely","max"))

manski_ind = subset(d, measure == "Manski_sliders") %>%
  select(workerid,tag,Manski_min,Manski_likely,Manski_max) %>%
  gather(Measure,Value,-workerid,-tag) %>%
  group_by(tag,Measure,workerid) %>%
  summarise(Mean = mean(Value))
manski_ind = as.data.frame(manski_ind)
manski_ind$Response = factor(x=gsub("Manski_","",as.character(manski_ind$Measure)),levels=c("min","likely","max"))

ggplot(manski_summary, aes(x=Response,y=Mean)) +
  geom_bar(stat="identity") +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25) +
  geom_line(data=manski_ind,aes(group=workerid),alpha=.5,color="lightblue") +
  facet_wrap(~ tag,scale="free")
ggsave("graphs/manski_summary.png",width=8)


manski_cumulative = subset(d, measure %in% c("Manski_1","Manski_2","Manski_3","Manski_4","Manski_5","Manski_6")) %>%
  select(rating_M1,rating_M2,rating_M3,rating_M4,rating_M5,rating_M6,workerid,tag,number_M1,number_M2,number_M3,number_M4,number_M5,number_M6,measure)
manski_cumulative$Rating = rowSums(manski_cumulative[, c("rating_M1", "rating_M2","rating_M3","rating_M4","rating_M5","rating_M6")], na.rm=TRUE)
manski_cumulative$Number = rowSums(manski_cumulative[, c("number_M1", "number_M2","number_M3","number_M4","number_M5","number_M6")], na.rm=TRUE)
head(manski_cumulative)

ggplot(manski_cumulative, aes(x=Number,y=Rating,group=workerid)) +
  geom_smooth(aes(group=1),color="black") +
  geom_line(color="lightblue",alpha=.5) +  
  ylim(c(0,100)) +
  # geom_ribbon(aes(ymin=YMin,ymax=YMax)) +
  facet_wrap(~tag,scale="free")
ggsave("graphs/manski_cumulative.png",width=8)

ggplot(manski_cumulative, aes(x=Number,y=Rating,group=1)) +
  geom_line() +
  geom_vline(data=manski_ind,aes(xintercept=Mean,color=Response)) +
  facet_grid(workerid~tag,scale="free")
ggsave("graphs/manski_bysubj.png",width=12,height=30)
