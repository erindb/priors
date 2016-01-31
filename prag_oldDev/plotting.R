library('coda')
library('ggmcmc')
library('jagsUI') # for parallel computing
source('helpers/helpers.R')
source('~/Desktop/data/svn/ProComPrag/dev_tmp/typicality_quantifiers/model/helpers.r')
source('process_data.R')

theme_set(theme_bw() + theme(plot.background=element_blank()) )

readFlag = TRUE
savePlots = TRUE

if (readFlag){
  # load(file = "/Users/micha/Desktop/Dropbox/priors_data/out_25.Rdat")
  # load(file = "/Users/micha/Desktop/Dropbox/priors_data/outTMP.Rdat")
  load(file = "/Users/micha/Desktop/Dropbox/priors_data/out.Rdat")
} else {
  # source('main.R')
}

# prepare samples
csamples = tbl_df(melt(out$sims.list))
colnames(csamples) = c("value", "step", "subject", "item", "bin", "variable")
csamples$item = levels(factor(bin_dat$tag))[csamples$item]

#######################
# posteriors
#######################

# item pop
meansIP = tbl_df(melt(out$sims.list$item.pop)) %>%
  rename(step = Var1, item = Var2, bin = Var3) %>%
  mutate(item = levels(factor(bin_dat$tag))[item] ) %>%
  group_by(item, bin) %>%
  summarise(
    mean = mean(value),
    max = HDIofMCMC(value)[2],
    min = HDIofMCMC(value)[1]
  )
meansIP$y_emp = y.slider_means$mymean
pop_priors = ggplot(meansIP, aes(x = bin, y = mean)) + geom_line() + geom_point() + facet_wrap(~ item, scale = "free") +
  geom_ribbon(aes(ymin=min, ymax=max), fill="gray", alpha="0.5") +
  geom_line(aes(x = bin, y = y_emp) , color = "firebrick")  + geom_point(aes(x = bin, y = y_emp ), color = "firebrick") +
  ylab(" mean posterior Q_{ijk} / average slider rating")

pop_priorsPaper = ggplot(meansIP, aes(x = bin, y = mean)) + geom_line() + geom_point() + facet_wrap(~ item, scales = "free_y", ncol=2) +
  geom_ribbon(aes(ymin=min, ymax=max), fill="gray", alpha="0.5") +
  geom_line(aes(x = bin, y = y_emp) , color = "firebrick")  + geom_point(aes(x = bin, y = y_emp ), color = "firebrick") +
  ylab(" mean posterior Q_{ijk} / average slider rating")


# subjective priors
meansIPSubj = tbl_df(melt(out$sims.list$subj)) %>%
  rename(step = Var1, subject = Var2, item = Var3, bin = Var4) %>%
  mutate(item = levels(factor(bin_dat$tag))[item] ) %>%
  filter(subject <= 20) %>%
  group_by(subject, item, bin) %>%
  summarise(
    mean = mean(value),
    max = HDIofMCMC(value)[2],
    min = HDIofMCMC(value)[1]
  )
meansIPSubj$y_emp = y.slider_means$mymean
meansIPSubj$subject = factor(meansIPSubj$subject)
meansIPSubj$meanPop = meansIP$mean
meansIPSubj$minPop = meansIP$min
meansIPSubj$maxPop = meansIP$max
pop_priorsSubj = ggplot(meansIPSubj, aes(x = bin, y = mean, group = subject)) + 
  geom_ribbon(aes(ymin=minPop, ymax=maxPop), fill="lightgray", alpha=0.5) +
  geom_line(color="darkgray", size = 0.5, alpha = 0.7)  +
  facet_wrap(~ item, scale = "free") +
  # geom_line(aes(x = bin, y = y_emp) , color = "firebrick")  + geom_point(aes(x = bin, y = y_emp ), color = "firebrick") +
  geom_line(aes(x = bin, y = meanPop) , color = "black", alpha = 0.7)
show(pop_priorsSubj)

# parameters
p = c("a", "b", "w", "sigma", "k")
meansIP <- csamples %>% filter(variable %in% p) %>%
  group_by(variable) %>%
  summarise(
    mean = mean(value),
    max = HDIofMCMC(value)[2],
    min = HDIofMCMC(value)[1]
  )
plotData = csamples %>% select(value, variable) %>% filter(variable %in% p)
plotData$maxHDI = unlist(sapply(1:nrow(plotData), function(x) meansIP[which(meansIP$variable == plotData$variable[x]), 3]))
plotData$minHDI = unlist(sapply(1:nrow(plotData), function(x) meansIP[which(meansIP$variable == plotData$variable[x]), 4]))
posterior_parameters = ggplot(plotData, aes(x = value)) + geom_density() + facet_wrap(~ variable, scales = "free")
show(posterior_parameters)



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
slider_aggr$cilow = y.slider_means$cilow
slider_aggr$cihigh = y.slider_means$cihigh
plotSliderPPC = ggplot(slider_aggr, aes(x = bin, y = mean)) + geom_line() + geom_point() + facet_wrap(~ item, scale = "free") + 
  geom_ribbon(aes(ymin=min, ymax=max), fill="gray", alpha="0.5") +
  # geom_errorbar(aes(ymin = min, ymax = max), width = .5, position = position_dodge(.1), color = 'gray') +
  geom_line(aes(x = bin, y = y_means) , color = "firebrick") + geom_point( aes(x = bin, y = y_means) , color = "firebrick") +
  ylab("slider rating")
plotSliderPPCPaper = ggplot(slider_aggr, aes(x = bin, y = mean)) + geom_line() + geom_point() + facet_wrap(~ item, scale = "free_y", ncol=2) + 
  geom_ribbon(aes(ymin=min, ymax=max), fill="gray", alpha="0.5") +
  # geom_errorbar(aes(ymin = min, ymax = max), width = .5, position = position_dodge(.1), color = 'gray') +
  geom_line(aes(x = bin, y = y_means) , color = "firebrick") + geom_point( aes(x = bin, y = y_means) , color = "firebrick") +
  ylab("slider rating")
plotSliderData = ggplot(slider_aggr, aes(x = bin, y = y_means)) + geom_line() + geom_point() + facet_wrap(~ item, scale = "free") + 
  geom_errorbar(aes(ymin = cilow, ymax = cihigh), width = .5, position = position_dodge(.1), color = 'gray') +
  ylab("mean slider rating")
plotSliderDataPaper = ggplot(slider_aggr, aes(x = bin, y = y_means)) + geom_line() + geom_point() + facet_wrap(~ item, scale = "free_y", ncol = 2) + 
  geom_errorbar(aes(ymin = cilow, ymax = cihigh), width = .5, position = position_dodge(.1), color = 'gray') +
  ylab("mean slider rating")



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
plotNumbersPPC = ggplot(number_aggr, aes(x = bin, y = mean)) + geom_point() + geom_line() +
  facet_wrap(~ item, scale = "free") + 
  geom_ribbon(aes(ymin=low,ymax=high), fill="gray", alpha="0.5") +
  geom_line( aes(x = bin, y = value) , color = "firebrick") + geom_point( aes(x = bin, y = value) , color = "firebrick") +
  ylab("frequency")
plotNumbersPPCPaper = ggplot(number_aggr, aes(x = bin, y = mean)) + geom_point() + geom_line() +
  facet_wrap(~ item, scale = "free_y", ncol = 2) + 
  geom_ribbon(aes(ymin=low,ymax=high), fill="gray", alpha="0.5") +
  geom_line( aes(x = bin, y = value) , color = "firebrick") + geom_point( aes(x = bin, y = value) , color = "firebrick") +
  ylab("frequency")
plotNumbersData = ggplot(number_aggr, aes(x = bin, y = value)) + geom_bar(stat = "identity") +
  facet_wrap(~ item, scale = "free") + ylab("frequency number choice")
plotNumbersDataPaper = ggplot(number_aggr, aes(x = bin, y = value)) + geom_bar(stat = "identity") +
  facet_wrap(~ item, scale = "free_y", ncol = 2) + ylab("frequency number choice")
plotSliderNumberDataPaper = ggplot(slider_aggr, aes(x = bin, y = y_means)) + geom_line() + geom_point() + facet_wrap(~ item, scale = "free_y", ncol = 2) + 
  geom_errorbar(aes(ymin = cilow, ymax = cihigh), width = .5, position = position_dodge(.1), color = 'gray') +
  ylab("mean slider rating / bin proportion of number choice") + geom_bar(data = number_aggr, aes(x = bin, y = value/20), stat = "identity", fill = "firebrick", alpha = 0.5)


# lightning choices
choice_emp = choice_dat %>% group_by(condition, tag) %>%
  summarise(yemp = mean(chosen_higher),
            cilow = mean(chosen_higher) - ci.low(chosen_higher),
            cihigh = mean(chosen_higher) + ci.high(chosen_higher)) %>% 
  rename(bin = condition, item = tag)
choice_emp = choice_emp[order(choice_emp$item, choice_emp$bin),]
choice_ppc = filter(csamples, variable == "y.choicePPC") %>%
  group_by(bin, item, step) %>% summarise(yrep = mean(value)) %>%
  group_by(bin, item) %>% summarise(mean = mean(yrep),
                                    low = HDIofMCMC(yrep)[1],
                                    high = HDIofMCMC(yrep)[2])
choice_ppc = choice_ppc[order(choice_ppc$item, choice_ppc$bin),]
choice_ppc$yemp = choice_emp$yemp
choice_ppc$cilow = choice_emp$cilow
choice_ppc$cihigh = choice_emp$cihigh
plotChoicesPPC = ggplot(choice_ppc, aes(x = bin, y = mean)) + geom_point() + geom_line() +
  facet_wrap(~ item, scale = "free") + 
  geom_ribbon(aes(ymin=low,ymax=high), fill="gray", alpha="0.5") +
  geom_line( aes(x = bin, y = yemp) , color = "firebrick") + geom_point( aes(x = bin, y = yemp) , color = "firebrick") +
  xlab("condition") + ylab("choice prop. higher bin") + 
  scale_x_discrete(labels=c("1" = "1 vs 2", 
                            "2" = "2 vs 6",
                            "3" = "6 vs 11",
                            "4" = "11 vs 14",
                            "5" = "14 vs 15"
  ))
plotChoicesPPCPaper = ggplot(choice_ppc, aes(x = bin, y = mean)) + geom_point() + geom_line() +
  facet_wrap(~ item, scale = "fixed", ncol = 4) + 
  geom_ribbon(aes(ymin=low,ymax=high), fill="gray", alpha="0.5") +
  geom_line( aes(x = bin, y = yemp) , color = "firebrick") + geom_point( aes(x = bin, y = yemp) , color = "firebrick") +
  xlab("condition") + ylab("choice prop. higher bin") + 
  scale_x_discrete(labels=c("1" = "1&2", 
                            "2" = "2&6",
                            "3" = "6&11",
                            "4" = "11&14",
                            "5" = "14&15"
  )) + theme(axis.text.x = element_text( angle=-25))
plotChoicesData = ggplot(choice_ppc, aes(x = factor(bin), y = yemp)) + geom_bar(stat = "identity", fill = "lightgray") +
  facet_wrap(~ item, scale = "free") +
  geom_errorbar(aes(ymin = cilow, ymax = cihigh), color = "darkgray", width = .5) +
  xlab("condition") + ylab("choce prop. higher bin") + 
  scale_x_discrete(labels=c("1" = "1 & 2", 
                            "2" = "2 & 6",
                            "3" = "6 & 11",
                            "4" = "11 & 14",
                            "5" = "14 & 15"
  )) + theme(axis.text.x = element_text( angle=-30))
plotChoicesDataPaper = ggplot(choice_ppc, aes(x = factor(bin), y = yemp)) + geom_bar(stat = "identity", fill = "lightgray") +
  facet_wrap(~ item, scale = "free_y", ncol = 2) +
  geom_errorbar(aes(ymin = cilow, ymax = cihigh), color = "darkgray", width = .5) +
  xlab("condition") + ylab("choce prop. higher bin") + 
  scale_x_discrete(labels=c("1" = "1 vs 2", 
                            "2" = "2 vs 6",
                            "3" = "6 vs 11",
                            "4" = "11 vs 14",
                            "5" = "14 vs 15"
                            )) + theme(axis.text.x = element_text( angle=-25))



# save plots for presentations
if (savePlots){
  # pdfs
  ggsave('plots/pop_priors.pdf', pop_priors, width=10, height = 8)
  ggsave('plots/pop_priorsSubj.pdf', pop_priorsSubj, width=10, height = 8)
  ggsave('plots/posterior_parameters.pdf', posterior_parameters, width=10, height = 8)
  ggsave('plots/ppc_slider.pdf', plotSliderPPC,  width=10, height = 8)
  ggsave('plots/ppc_number.pdf', plotNumbersPPC, width=10, height = 8)
  ggsave('plots/ppc_choice.pdf', plotChoicesPPC, width=10, height = 8)
  ggsave('plots/data_slider.pdf', plotSliderData,  width=10, height = 8)
  ggsave('plots/data_number.pdf', plotNumbersData,  width=10, height = 8)
  ggsave('plots/data_choice.pdf', plotChoicesData, width=10, height = 8)
  # pngs
  ggsave('plots/pop_priors.png', pop_priors, width=10, height = 8)
  ggsave('plots/pop_priorsSubj.png', pop_priorsSubj, width=10, height = 8)
  ggsave('plots/posterior_parameters.png', posterior_parameters, width=10, height = 8)
  ggsave('plots/ppc_slider.png', plotSliderPPC,  width=10, height = 8)
  ggsave('plots/ppc_number.png', plotNumbersPPC, width=10, height = 8)
  ggsave('plots/ppc_choice.png', plotChoicesPPC, width=10, height = 8)
  ggsave('plots/data_slider.png', plotSliderData,  width=10, height = 8)
  ggsave('plots/data_number.png', plotNumbersData,  width=10, height = 8)
  ggsave('plots/data_choice.png', plotChoicesData, width=10, height = 8)
}

# save plots for CogSciPaper  
factor = 0.55
if (savePlots){
  # pdfs
  ggsave('../text/01_CogSci_abstract/plots/pop_priors.pdf', pop_priorsPaper, width=10*factor, height = 8*factor)
#   ggsave('../text/01_CogSci_abstract/plots/pop_priorsSubj.pdf', pop_priorsSubj, width=10*factor, height = 8*factor)
#   ggsave('../text/01_CogSci_abstract/plots/posterior_parameters.pdf', posterior_parameters, width=10*factor, height = 8*factor)
  ggsave('../text/01_CogSci_abstract/plots/ppc_slider.pdf', plotSliderPPCPaper,  width=10*factor, height = 8*factor)
  ggsave('../text/01_CogSci_abstract/plots/ppc_number.pdf', plotNumbersPPCPaper, width=10*factor, height = 8*factor)
  ggsave('../text/01_CogSci_abstract/plots/ppc_choice.pdf', plotChoicesPPCPaper, width=10*factor, height = 6*factor)
  ggsave('../text/01_CogSci_abstract/plots/data_slider.pdf', plotSliderDataPaper,  width=10*factor, height = 8*factor)
  ggsave('../text/01_CogSci_abstract/plots/data_sliderNumber.pdf', plotSliderNumberDataPaper,  width=10*factor, height = 10*factor)
  ggsave('../text/01_CogSci_abstract/plots/data_number.pdf', plotNumbersDataPaper,  width=10*factor, height = 8*factor)
  ggsave('../text/01_CogSci_abstract/plots/data_choice.pdf', plotChoicesDataPaper, width=10*factor, height = 8*factor)
}
