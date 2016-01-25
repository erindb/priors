dat <- read.csv('data/exp1.csv')
bin_dat <- read.csv('data/bin_dat.csv')
choice_dat <- read.csv('data/choice_dat.csv')
number_dat <- read.csv('data/number_dat.csv')

## slider rating data
y.slider = array(0, dim = c(20,8,15))
for (i in 1:nrow(bin_dat)){
  y.slider[bin_dat$workerid[i] + 1, 
           as.numeric(bin_dat$tag)[i],
           bin_dat$bin_num[i]] = bin_dat$nresponse[i]
}
y.slider = logit(add.margin(y.slider))
y.slider_means = bin_dat %>% group_by(bin_num, tag) %>% 
  summarise(mymean = mean(nresponse)) %>% rename(bin = bin_num, item = tag)
y.slider_means = y.slider_means[order(y.slider_means$item,y.slider_means$bin),]

# number choice data
y.number = array(0, dim = c(20,8,1))
for (i in 1:nrow(number_dat)){
  y.number[number_dat$workerid[i] + 1, 
           as.numeric(number_dat$tag)[i],
           1] = number_dat$chosen_bin[i]
}

## lightning round choice data
choice_dat = choice_dat %>% mutate(condition = factor(ifelse(chosen_bin > unchosen_bin, unchosen_bin, chosen_bin)))
choice_dat$condition = as.numeric(choice_dat$condition)
y.choice = array(0, dim = c(20,8,5))
higher   = array(0, dim = c(20,8,5))
lower    = array(0, dim = c(20,8,5))
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