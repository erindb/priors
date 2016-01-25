library('coda')
library('ggmcmc')
library('jagsUI') # for parallel computing
source('helpers/helpers.R')
source('~/Desktop/data/svn/ProComPrag/dev_tmp/typicality_quantifiers/model/helpers.r')
source('process_data.R')

readFlag = TRUE
savePlots = FALSE

if (readFlag){
  load(file = "~/Desktop/Dropbox/priors_data/out25.Rdat")
} else {
  source('main.R')
}


csamples = tbl_df(melt(out$sims.list))
colnames(csamples) = c("value", "step", "subject", "item", "bin", "variable")
csamples$item = levels(factor(bin_dat$tag))[csamples$item]

slider_ppv = filter(csamples, variable == "y.sliderPPC") %>% 
  mutate(value = logistic(value)) %>%
  group_by(subject, item, step) %>%
  mutate(nvalue = value / sum(value))

slider_aggr = slider_ppv %>% group_by(item, bin, step) %>%
  summarise(y.rep.mean = mean(nvalue)) %>%
  group_by(item, bin) %>%
  summarise(mean = mean(y.rep.mean),
            min = HDIofMCMC(y.rep.mean)[1],
            max = HDIofMCMC(y.rep.mean)[2])
slider_aggr = slider_aggr[order(slider_aggr$item,slider_aggr$bin),]
slider_aggr$y_means = y.slider_means$mymean


plotSliderPPC = ggplot(slider_aggr, aes(x = bin, y = mean)) + geom_line() + geom_point() + facet_wrap(~ item, scale = "free") + 
  geom_errorbar(aes(ymin = min, ymax = max), width = .5, position = position_dodge(.1), color = 'gray') +
  geom_line(aes(x = bin, y = y_means) , color = "red") + geom_point( aes(x = bin, y = y_means) , color = "red")

show(plotSliderPPC)

if (savePlots){
  ggsave('plots/ppc_slider.pdf', ppc_slider, width=10, height = 8)
}
