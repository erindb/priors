# library('R2jags')
library(jagsUI) # for parallel computing
library(ggmcmc)
library(coda)
library(BEST)
source('helpers/helpers.R')
source('~/Desktop/data/svn/ProComPrag/dev_tmp/typicality_quantifiers/model/helpers.r')


dat <- read.csv('data/exp1.csv')
bin_dat <- read.csv('data/bin_dat.csv')
choice_dat <- read.csv('data/choice_dat.csv')
number_dat <- read.csv('data/number_dat.csv')

# focus = "coffee"
# dat = droplevels(filter(dat, tag == focus))
# bin_dat = droplevels(filter(bin_dat, tag == focus))
# choice_dat = droplevels(filter(choice_dat, tag == focus))
# number_dat = droplevels(filter(number_dat, tag == focus))

# data useful for all dependent measures
data_gen <- with(dat,
            list('n.items' = nlevels(tag), 'ones' = rep(1, 15),
                 'n.subj' = length(unique(workerid))))

# data specific for the slider measure
data_slider <- with(bin_dat, # use normalized response
               list('y.slider' = response,
                    'bin.num' = bin_num,
                    'item.slider' = as.numeric(tag), 
                    'worker.slider' = workerid + 1,
                    'N.slider' = nrow(bin_dat)))

# data specific for the number measure
data_number <- with(number_dat,
               list('y.number' = chosen_bin, 
                    'item.number' = as.numeric(tag),
                    'worker.number' = workerid + 1,
                    'N.number' = nrow(number_dat)))

# data specific for the choice measure
data_choice <- with(choice_dat,
               list('y.choice' = as.numeric(higher_chosen),
                    'item.choice' = as.numeric(as.factor(tag)),
                    'N.choice' = nrow(choice_dat), 'worker.choice' = workerid + 1,
                    'higher' = sapply(1:nrow(choice_dat), function(i) max(chosen_bin[i], unchosen_bin[i])),
                    'lower' = sapply(1:nrow(choice_dat), function(i) min(chosen_bin[i], unchosen_bin[i]))))

data_aggr <- c(data_gen, data_slider, data_number, data_choice)
params <- c('w', 
            'a', 
            'sigma', 
            'item.pop', 
            'k.skewGlobal',
            'threshold',
            'b'
            #'y.sliderPPC',
            #'y.numberPPC'
            # 'y.choicePPC'
            )
burnin = 5000
iter = 5000
out <- jags(data = data_aggr,
            inits = NULL,
            parameters.to.save = params,
            codaOnly = c('y.sliderPPC', 'y.numberPPC', 'y.choicePPC'),
            model.file = 'models/model.jags.R',
            n.chains = 2,
            n.adapt = 1000,
            n.iter = iter + burnin,
            n.burnin = burnin,
            n.thin = 2, 
            DIC = TRUE,
            verbose = TRUE,
            parallel = TRUE)

ms = ggs(out$samples)

mcmcPlot(ms, "item.pop")

stop()


mcmcPlot(ms, "k.skewGlobal")
mcmcPlot(ms, "tau")



mys = out$sims.list
mysDF = as.data.frame(mys)

csamples <- clean_samples(samples, ppv = 'none')

# construct all the posterior predictive samples; needs to be adjusted! (esp. slider ...)
slider_ppv <- construct_ppvs(samples)
number_ppv <- construct_ppvs(samples, ppv = 'y.numberPPC')
#choice_ppv <- construct_ppvs(samples, ppv = 'y.choicePPC')
# 
# # get a specific posterior predictive sample across with the empirical response
# nppv <- get_ppv(number_ppv, number_dat$chosen_bin)
# sppv <- get_ppv(slider_ppv, bin_dat$nresponse)
# cppv <- get_ppv(choice_ppv, as.numeric(choice_dat$lower_chosen))
# 
# # plot one specific posterior predictive sample
# plot_ppv(nppv, type = 'numberPPC')
# plot_ppv(sppv, type = 'sliderPPC')
# plot_ppv(cppv, type = 'sliderPPC') # need to plot this differently ...
# 
# # average over all posterior predictive samples
aggr_slider <- aggregate_ppv_slider(slider_ppv, bin_dat)
aggr_number <- aggregate_ppv_number(number_ppv, data_number)
# aggr_choice <- aggregate_ppv(choice_ppv, as.numeric(choice_dat$lower_chosen))
# plot_ppv(aggr_slider, type = 'sliderBins')
# plot_ppv(aggr_number, type = 'numberPPC')
# plot_ppv(aggr_choice, type = 'sliderPPC')

# unconverged = rownames(samples$BUGSoutput$summary)[which(samples$BUGSoutput$summary[,"Rhat"] > 1.1)]

pop_priors = plot_populationPriors(slider_ppv, aggr_slider)
ggsave('plots/pop_priors.pdf', pop_priors, width=10, height = 8)

posterior_parameters = plot_parameters()
ggsave('plots/posterior_parameters.pdf', posterior_parameters, width=10, height = 8)

ppc_slider = plot_ppvMF(aggr_slider)
ggsave('plots/ppc_slider.pdf', ppc_slider, width=10, height = 8)

ppc_number = plot_ppvMF(aggr_number, 'numberChoice')
ggsave('plots/ppc_number.pdf', ppc_number, width=10, height = 8)

mean_KL_divergence()

