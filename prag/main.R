library('R2jags')
source('helpers/helpers.R')


dat <- read.csv('data/exp1.csv')
bin_dat <- read.csv('data/bin_dat.csv')
choice_dat <- read.csv('data/choice_dat.csv')
number_dat <- read.csv('data/number_dat.csv')

# data useful for all dependent measures
data_gen <- with(dat,
            list('n.items' = nlevels(tag), 'ones' = rep(1, 15),
                 'n.subj' = length(unique(workerid))))

# data specific for the slider measure
data_slider <- with(bin_dat, # use normalized response
               list('y.slider' = logit(add.margin(nresponse)), 'bin.num' = bin_num,
                    'item.slider' = as.numeric(tag), 'worker.slider' = workerid + 1,
                    'N.slider' = nrow(bin_dat)))

# data specific for the number measure
data_number <- with(number_dat,
               list('y.number' = chosen_bin, 'item.number' = as.numeric(tag),
                    'worker.number' = workerid + 1, 'bin.max' = max,
                    'N.number' = nrow(number_dat), 'chosen_min' = chosen_min,
                    'chosen_max' = chosen_max, 'steps' = steps))

# data specific for the choice measure
data_choice <- with(choice_dat,
               list('y.choice' = as.numeric(lower_chosen),
                    'item.choice' = as.numeric(as.factor(tag)),
                    'N.choice' = nrow(choice_dat), 'chosen_bin' = chosen_bin,
                    'unchosen_bin' = unchosen_bin, 'worker.choice' = workerid + 1,
                    'higher' = sapply(1:nrow(choice_dat), function(i) max(chosen_bin[i], unchosen_bin[i])),
                    'lower' = sapply(1:nrow(choice_dat), function(i) min(chosen_bin[i], unchosen_bin[i])),
                    'chosen_higher' = chosen_higher))

data_aggr <- c(data_gen, data_slider, data_number, data_choice)
params <- c('w', 'a', 'tau', 'item.pop', 'k.skewGlobal',
            'y.sliderPPC', 'y.numberPPC', 'y.choicePPC')

samples <- jags(data_aggr, parameters.to.save = params,
                model.file = 'models/model.txt', n.chains = 2, n.iter = 500, 
                n.burnin = 5, n.thin = 1, DIC = TRUE)
csamples <- clean_samples(samples)

# construct all the posterior predictive samples; needs to be adjusted! (esp. slider ...)
slider_ppv <- construct_ppvs(samples)
number_ppv <- construct_ppvs(samples, ppv = 'y.numberPPC')
choice_ppv <- construct_ppvs(samples, ppv = 'y.choicePPC')

# get a specific posterior predictive sample across with the empirical response
nppv <- get_ppv(number_ppv, number_dat$chosen_bin)
sppv <- get_ppv(slider_ppv, bin_dat$nresponse)
cppv <- get_ppv(choice_ppv, as.numeric(choice_dat$lower_chosen))

# plot one specific posterior predictive sample
plot_ppv(nppv, type = 'numberPPC')
plot_ppv(sppv, type = 'sliderPPC')
plot_ppv(cppv, type = 'sliderPPC') # need to plot this differently ...

# average over all posterior predictive samples
aggr_number <- aggregate_ppv(number_ppv, number_dat$chosen_bin)
aggr_slider <- aggregate_ppv(slider_ppv, bin_dat$nresponse)
aggr_choice <- aggregate_ppv(choice_ppv, as.numeric(choice_dat$lower_chosen))
plot_ppv(aggr_number, type = 'numberPPC')
plot_ppv(aggr_slider, type = 'sliderPPC')
plot_ppv(aggr_choice, type = 'sliderPPC')
