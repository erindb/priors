require(dplyr)
require('bootstrap')
library('rjson')
library('stringr')
source('//Users/micha/Desktop/data/svn/priors/models/04_Exp2_Manski_JAGS/helpers/helpers.R')

## for bootstrapping 95% confidence intervals
theta <- function(x,xdata,na.rm=T) {mean(xdata[x],na.rm=na.rm)}
ci.low <- function(x,na.rm=T) {
  mean(x,na.rm=na.rm) - quantile(bootstrap(1:length(x),1000,theta,x,na.rm=na.rm)$thetastar,.025,na.rm=na.rm)}
ci.high <- function(x,na.rm=T) {
  quantile(bootstrap(1:length(x),1000,theta,x,na.rm=na.rm)$thetastar,.975,na.rm=na.rm) - mean(x,na.rm=na.rm)}

d = read.table("//Users/micha/Desktop/data/svn/priors/models/04_Exp2_Manski_JAGS/data/results.csv", header=T, sep=",",quote="\"")
bins = read.csv("//Users/micha/Desktop/data/svn/priors/models/04_Exp2_Manski_JAGS/data/bins.txt",header=T)

## number choices (treated as bins)
give_number = d %>% filter(measure == "give_number") %>% droplevels() %>%
  select(workerid, tag, response, max)  %>%
  mutate(response = as.numeric(as.character(response)))
bins$Bin = bins$Bin + 1
give_number$chosen_bin = sapply(1:nrow(give_number), function(i) {
  response = give_number$response[i]
  tag = as.character(give_number$tag)[i]
  bins[bins$Item == tag & bins$Min <= response & bins$Max >= response,]$Bin
})

y.number = array(0, dim = c(50,8,1))
for (i in 1:nrow(give_number)){
  y.number[give_number$workerid[i] + 1, 
           as.numeric(give_number$tag)[i], # WTH does this enumerate starting at 2?
           1] = give_number$chosen_bin[i]
}
dimnames(y.number)[[2]] = sapply(1:8, function(i) levels(give_number$tag)[i])

## binned histograms

binned_histogram = droplevels(subset(d, measure == "binned_histogram")) %>%
  select(workerid, tag, bin, response) %>% 
  mutate(response = as.numeric(as.character(response))) %>%
  group_by(tag, workerid) %>% mutate(nresponse = normalize(response))
binned_histogram$bin_num = 1:15

y.slider = array(0, dim = c(50,8,15))
for (i in 1:nrow(binned_histogram)){
  y.slider[binned_histogram$workerid[i] + 1, 
           as.numeric(binned_histogram$tag)[i],
           binned_histogram$bin_num[i]] = binned_histogram$nresponse[i]
}
dimnames(y.slider)[[2]] = sapply(1:8, function(i) levels(binned_histogram$tag)[i])
y.slider = logit(add.margin(y.slider))
y.slider_means = binned_histogram %>% group_by(bin_num, tag) %>% 
  summarise(mymean = mean(nresponse),
            cilow  = mean(nresponse) - ci.low(nresponse),
            cihigh = mean(nresponse) + ci.high(nresponse)) %>% rename(bin = bin_num, item = tag)
y.slider_means = y.slider_means[order(y.slider_means$item,y.slider_means$bin),]

## try plotting the data to see if it looks like what Judith got
# sliderDataPlot = ggplot(y.slider_means, aes(x = bin, y = mymean)) + 
#   geom_point() + geom_line() + facet_wrap(~ item, nrow = 4, scales = "free")
# show(sliderDataPlot)

## lightning round choice data

choice_dat  = d %>%
  filter(measure == 'lightning') %>% droplevels() %>%
  select(workerid, response, unchosen_contrast, tag) %>% 
  mutate(unchosen_contrast = as.character(unchosen_contrast),
         tag = as.character(tag), response = as.character(response))

extract_tag <- function(response) {
  sapply(response, function(res) {
    cleaned <- str_match(res, "(\\$?[0-9]+([^0-9]F )?-? ?\\$?[0-9]*([^0-9]F)?)[^0-9]")
    restag <- cleaned[[2]]
    str_trim(restag)
  })
}

choice_dat$chosen_tag <- extract_tag(choice_dat$response)
choice_dat$unchosen_tag <- extract_tag(choice_dat$unchosen_contrast)

choice_dat$lower_chosen = mapply(function(chosen, unchosen) {
  chosen_first_num = as.numeric(str_match(chosen, "\\$?([0-9]+)([^0-9]?-[^0-9]?)?")[[2]])
  unchosen_first_num = as.numeric(str_match(unchosen, "\\$?([0-9]+)([^0-9]?-[^0-9]?)?")[[2]])
  chosen_first_num < unchosen_first_num
}, choice_dat$chosen_tag, choice_dat$unchosen_tag)

choice_dat$higher_chosen = mapply(function(chosen, unchosen) {
  chosen_first_num = as.numeric(str_match(chosen, "\\$?([0-9]+)([^0-9]?-[^0-9]?)?")[[2]])
  unchosen_first_num = as.numeric(str_match(unchosen, "\\$?([0-9]+)([^0-9]?-[^0-9]?)?")[[2]])
  if (chosen_first_num == unchosen_first_num) {
    return(nchar(chosen) > nchar(unchosen))
  } else {
    return(chosen_first_num > unchosen_first_num)
  }
}, choice_dat$chosen_tag, choice_dat$unchosen_tag)

all_bins <- as.character(unique(filter(d, measure == "binned_histogram")$bins))
all_bins <- c(all_bins, all_bins[1])
all_bins <- lapply(all_bins, function(str) {
  str <- gsub("u", "", str)
  str <- gsub("'", "\"", str)
  str <- gsub(".xb0", "", str)
  fromJSON(str)
})
names(all_bins) = c("joke", "laptop", "commute", "movies", "watch", "coffee", "tv", "marbles")

extract_chosen_bin <- function(dat, which = 'chosen_tag') {
  sapply(1:nrow(dat), function(i) {
    row <- dat[i, ]
    curbin <- all_bins[[row$tag]]
    curbin <- str_trim(gsub("[a-z]", "", curbin))
    which(curbin == str_trim(row[[which]]))
  })
}
choice_dat$chosen_bin <- unlist(extract_chosen_bin(choice_dat))
choice_dat$unchosen_bin <- unlist(extract_chosen_bin(choice_dat, which = 'unchosen_tag'))
choice_dat <- choice_dat %>% 
  select(-c(response, unchosen_contrast)) %>% 
  mutate(chosen_higher = as.numeric(chosen_bin > unchosen_bin))

choice_dat = choice_dat %>% 
  mutate(condition = factor(ifelse(chosen_bin > unchosen_bin, unchosen_bin, chosen_bin))) %>%
  mutate(tag = factor(tag))
choice_dat$condition = as.numeric(choice_dat$condition)
y.choice = array(0, dim = c(50,8,5))
higher   = array(0, dim = c(50,8,5))
lower    = array(0, dim = c(50,8,5))
for (i in 1:nrow(choice_dat)){
  y.choice[choice_dat$workerid[i] + 1, 
           as.numeric(choice_dat$tag)[i],
           choice_dat$condition[i]] = ifelse(choice_dat$higher_chosen[i] , 1, 0)
  higher[choice_dat$workerid[i] + 1, 
         as.numeric(choice_dat$tag)[i],
         choice_dat$condition[i]] = max(choice_dat$chosen_bin[i], choice_dat$unchosen_bin[i])
  lower[choice_dat$workerid[i] + 1, 
        as.numeric(choice_dat$tag)[i],
        choice_dat$condition[i]] = min(choice_dat$chosen_bin[i], choice_dat$unchosen_bin[i])
}

save(y.slider, y.slider_means, y.choice, y.number, file = "data/processed_data.RData")
