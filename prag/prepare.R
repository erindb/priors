library('rjson')
library('dplyr')
library('stringr')
source('helpers/helpers.R')

dat <- read.csv('data/exp1.csv')

############
# bin data #
############
bin_dat <- dat %>% 
  filter(measure == 'binned_histogram') %>%
  mutate(response = as.numeric(as.character(response)))

all_bins <- as.character(unique(bin_dat$bins))
all_bins <- c(all_bins, all_bins[1])
all_bins <- lapply(all_bins, function(str) {
  str <- gsub("u", "", str)
  str <- gsub("'", "\"", str)
  str <- gsub(".xb0", "", str)
  fromJSON(str)
})
names(all_bins) = c("joke", "movies", "tv", "coffee", "watch", "commute", "laptop", "marbles")

bin_dat$bin_num = sapply(1:nrow(bin_dat), function(i) {
  bin = as.character(bin_dat$bin)[i]
  tag = as.character(bin_dat$tag)[i]
  which(all_bins[[tag]] == bin)
})

bin_dat <- select(bin_dat, workerid, tag, bin_num, response)
bin_dat <- bin_dat %>% group_by(tag, workerid) %>% mutate(nresponse = normalize(response)) %>% data.frame()
# write.csv(bin_dat, file = "data/bin_dat.csv", row.names = FALSE )

###############
# number data #
###############
number_dat <- dat %>%
  filter(measure == 'give_number') %>% 
  mutate(response = as.numeric(as.character(response)))

steps <- list('coffee' = 13, 'movies' = 16, 'tv' = 3, 'commute' = 7, 'laptop' = 500,
              'watch' = 50, 'marbles' = 1, 'joke' = 1)

# TEST IF THIS WORKS! edge cases: last bin (or more), first bin (0-3, 44 or less etc.)
number_dat$chosen_bin <- sapply(1:nrow(number_dat), function(i) {
  res <- number_dat$response[i]
  tag <- as.character(number_dat$tag)[i]
  bins <- all_bins[[tag]]
  names(bins) <- 1:15
  bins <- regmatches(bins, gregexpr('\\(?[0-9,.]+', bins)) # remove everything except numbers
  bins.log <- numeric(15)
  
  # ugh
  flag <- FALSE
  for (i in 1:15) {
    bounds <- bins[[i]]
    lo <- as.numeric(bounds[1])
    hi <- as.numeric(bounds[2])
    if (!flag) {
      if (!is.na(lo) && res == lo) {
        bins.log[i] <- TRUE
        flag <- TRUE
      } else if (!is.na(hi) && res == hi) {
        bins.log[i] <- TRUE
        flag <- TRUE
      } else {
        bins.log[i] <- ifelse(lo < res && hi > res, TRUE, FALSE)
      }
    }
  }
  which(as.logical(bins.log))
})

get_bounds <- function(which = 1) {
  sapply(1:nrow(number_dat), function(i) {
    bin <- number_dat$chosen_bin[i]
    tag <- as.character(number_dat$tag[i])
    bins <- all_bins[[tag]]
    names(bins) <- 1:15
    bins <- regmatches(bins, gregexpr('\\(?[0-9,.]+', bins))
    
    bounds <- bins[[bin]]
    as.numeric(ifelse(is.na(bounds[which]), bounds[1], bounds[which]))
  })
}
number_dat$chosen_min <- get_bounds(which = 1)
number_dat$chosen_max <- get_bounds(which = 2)

number_dat$steps <- sapply(1:nrow(number_dat), function(i) {
  tag <- as.character(number_dat$tag[i])
  steps[[tag]]
})

number_dat <- select(number_dat, workerid, tag, response, max,
                     chosen_bin, chosen_min, chosen_max, steps)

#############
# choice data
#############
choice_dat <- dat %>%
  filter(measure == 'lightning') %>%
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

extract_chosen_bin <- function(dat, which = 'chosen_tag') {
  sapply(1:nrow(dat), function(i) {
    row <- dat[i, ]
    curbin <- all_bins[[row$tag]]
    curbin <- str_trim(gsub("[a-z]", "", curbin))
    which(curbin == str_trim(row[[which]]))
  })
}
choice_dat$chosen_bin <- extract_chosen_bin(choice_dat)
choice_dat$unchosen_bin <- extract_chosen_bin(choice_dat, which = 'unchosen_tag')
choice_dat <- choice_dat %>% 
  select(-c(response, unchosen_contrast)) %>% 
  mutate(chosen_higher = as.numeric(chosen_bin > unchosen_bin))
# note: there are ties in 167 214 497 784
ties <- c(167, 214, 497, 784)
choice_dat[ties, ]
choice_dat[ties, ]$lower_chosen <- TRUE # upon inspection, manually change the value