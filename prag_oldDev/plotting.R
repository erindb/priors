library('coda')
library('ggmcmc')
library('jagsUI') # for parallel computing
source('helpers/helpers.R')
source('~/Desktop/data/svn/ProComPrag/dev_tmp/typicality_quantifiers/model/helpers.r')
source('process_data.R')

readFlag = TRUE
savePlots = FALSE

if (readFlag){
  # load(file = "/Users/micha/Desktop/Dropbox/priors_data/out_25.Rdat")
  load(file = "/Users/micha/Desktop/Dropbox/priors_data/out.Rdat")
} else {
  source('main.R')
}

# prepare samples
csamples = tbl_df(melt(out$sims.list))
colnames(csamples) = c("value", "step", "subject", "item", "bin", "variable")
csamples$item = levels(factor(bin_dat$tag))[csamples$item]

#######################
# posterior predictives
#######################

# sliders
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

# numbers
number_dat$chosen_bin = factor(number_dat$chosen_bin, levels = 1:15)
DNm = tbl_df(melt(table(number_dat$tag, number_dat$chosen_bin))) %>%
  rename(item = Var1, bin = Var2)
DNm = DNm[order(DNm$item, DNm$bin),]
number_ppv = filter(csamples, variable == "y.numberPPC")
number_ppv$value = factor(number_ppv$value)
ppcM = tbl_df(melt(table(number_ppv$step, number_ppv$value, number_ppv$item)))  %>%
  rename(step = Var1, bin = Var2, item = Var3) 
number_aggr = ppcM %>% 
  group_by(bin, item) %>%
  summarize(mean = mean(value),
            low = HDIofMCMC(value)[1],
            high = HDIofMCMC(value)[2])
number_aggr = number_aggr[order(number_aggr$item, number_aggr$bin),]
number_aggr$value = DNm$value
plotNumbersPPC = ggplot(number_aggr, aes(x = bin, y = mean)) + geom_bar(color = "black", fill = "gray", stat = 'identity') + 
  facet_wrap(~ item, scale = "free") + 
  geom_errorbar(aes(ymin = low, ymax = high), width = .5, position = position_dodge(.1), color = 'gray') +
  geom_line( aes(x = bin, y = value) , color = "red") + geom_point( aes(x = bin, y = value) , color = "red")
show(plotNumbersPPC)

# save plots  
if (savePlots){
  ggsave('plots/ppc_slider.pdf', plotSliderPPC,  width=10, height = 8)
  ggsave('plots/ppc_number.pdf', plotNumbersPPC, width=10, height = 8)
}
