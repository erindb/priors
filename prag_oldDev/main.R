library('coda')
library('ggmcmc')
library('jagsUI') # for parallel computing
source('helpers/helpers.R')
source('~/Desktop/data/svn/ProComPrag/dev_tmp/typicality_quantifiers/model/helpers.r')
source('process_data.R')


saveFlag = FALSE




data_aggr <- list(y.slider = y.slider, y.numer = y.number, y.choice = y.choice, 
                  higher = higher, lower = lower,
                  nSubjs = 20, nItems = 8, nBins = 15, nLightConds = 5,
                  ones = rep(1,15))
params <- c('w', 
            'a', 
            'sigma', 
            'item.pop', 
            'k.skewGlobal', 
            'b',
            "y.choicePPC", "y.numberPPC", "y.sliderPPC")

model = "models/model.jags.R"
burnin = 2000
iter = 2500
out = jags(data = data_aggr,
            inits = NULL,
            parameters.to.save = params,
            codaOnly = c("y.choicePPC", "y.numberPPC", "y.sliderPPC"),
            model.file = model,
            n.chains = 2,
            n.adapt = 500,
            n.iter = iter + burnin,
            n.burnin = burnin,
            n.thin = 2, 
            DIC = TRUE,
            verbose = TRUE,
            parallel = TRUE)

if (saveFlag) { save(out, file = "~/Desktop/Dropbox/priors_data/out_25.Rdat") }


stop()


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

