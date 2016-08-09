library('coda')
library('ggmcmc')
library('jagsUI') # for parallel computing
library('xtable')
library(grid)
library(gridExtra)
source('helpers/helpers.R')
# source('~/Desktop/data/svn/ProComPrag/dev_tmp/typicality_quantifiers/model/helpers.r')
source('process_data.R')

theme_set(theme_bw() + theme(plot.background=element_blank()) )

readFlag = FALSE

if (readFlag){
  load(file = "/Users/micha/Desktop/Dropbox/priors_data/outExp2.Rdat")
} else {
  # source('main.R')
}

## get summary data
statsSum = data.frame(
  parameter = c("w", "kappa", "sigma", "a", "b"),
  hdiMean = c(mean(out$sims.list$w), 
              mean(out$sims.list$k), 
              mean(out$sims.list$sigma),
              mean(out$sims.list$a),
              mean(out$sims.list$b)),
  hdiLow = c(HDIofMCMC(out$sims.list$w)[1], 
             HDIofMCMC(out$sims.list$k)[1], 
             HDIofMCMC(out$sims.list$sigma)[1],
             HDIofMCMC(out$sims.list$a)[1],
             HDIofMCMC(out$sims.list$b)[1]),
  hdiHigh = c(HDIofMCMC(out$sims.list$w)[2], 
              HDIofMCMC(out$sims.list$k)[2], 
              HDIofMCMC(out$sims.list$sigma)[2],
              HDIofMCMC(out$sims.list$a)[2],
              HDIofMCMC(out$sims.list$b)[2]))

show(xtable(t(statsSum)))
  

entropy = function(p){
  - sum(p*log(p))
}

y.rep = logistic(out$sims.list$y.sliderPPC)
y.emp = logistic(y.slider)

posteriorMeans = array(0, dim = c(dim(y.rep)[1], dim(y.rep)[2], dim(y.rep)[3]))
posteriorEntrs = array(0, dim = c(dim(y.rep)[1], dim(y.rep)[2], dim(y.rep)[3]))
pValueMean = matrix(0, nrow = 50, ncol = 8)
pValueEntr = matrix(0, nrow = 50, ncol = 8)

for (i in 1:(dim(y.rep)[2])) {
  for (j in 1:(dim(y.rep)[3])) {
    for (s in 1:(dim(y.rep)[1])) {
      posteriorMeans[s,i,j] = sum(1:15*y.rep[s,i,j,])
      posteriorEntrs[s,i,j] = entropy(y.rep[s,i,j,])
    }
    empMean = sum(1:15*y.emp[i,j,])
    empEntr = entropy(y.emp[i,j,])
    biggerMean  = sum(ifelse(posteriorMeans[,i,j] > empMean, 1, 0)) / dim(y.rep)[1]
    smallerMean = sum(ifelse(posteriorMeans[,i,j] < empMean, 1, 0)) / dim(y.rep)[1]
    pValueMean[i,j] = min(biggerMean,smallerMean) * 2
    biggerEntr  = sum(ifelse(posteriorEntrs[,i,j] > empEntr, 1, 0)) / dim(y.rep)[1]
    smallerEntr = sum(ifelse(posteriorEntrs[,i,j] < empEntr, 1, 0)) / dim(y.rep)[1]
    pValueEntr[i,j] = min(biggerEntr,smallerEntr) * 2
  }
}

## two failures for means: two y.repects who gave "extreme" ratings for marble case fall out!!
## check empirical means for marbles:
sapply(1:50, function(i) sum(1:15*y.emp[i,5,]))

## a few failures for "entropy: the two "extreme" cases plus another 18 cases of (almost) flat input

show(pValueMean < 0.05)
show(pValueEntr < 0.05)

## make data frame with posterior p-value violations

postPs = melt(pValueMean) %>% rename(subject = Var1, item = Var2, pMean = value) %>%
  mutate(pMeanViol = as.numeric(pMean <= 0.05),
         item = levels(factor(dimnames(y.emp)[[2]]))[item])
postPsTMP = melt(pValueEntr) %>% rename(subject = Var1, item = Var2, pEntr = value) %>%
  mutate(pEntrViol = as.numeric(pEntr <= 0.05))
postPs$pEntr = postPsTMP$pEntr
postPs$pEntrViol = postPsTMP$pEntrViol
postPs$viol = paste0(as.character(postPs$pMeanViol), as.character(postPs$pEntrViol))
postPs$viol = ifelse(postPs$viol == "00", "none", 
                     ifelse(postPs$viol == "10", "mean", 
                            ifelse(postPs$viol == "01", "entropy", "both")))
postPs$bin = 1
postPs$rating_scaled = 0.5


## plot individual-level slider ratings

rescale = function(x) {
  if (max(x) == min(x)) {return(rep(0.5, length(x)))}
  (x-min(x)) / (max(x) - min(x))
}

y.slider_individual = melt(y.emp) %>% rename(subject = Var1, item = Var2, bin = Var3, rating = value) %>%
  mutate(itemNr = as.numeric(item)) %>%
  group_by(subject, item) %>% mutate(rating_scaled = rescale(rating))

bh_rating_individual_1 = ggplot(filter(y.slider_individual, subject <= 25), aes(x = bin, y = rating_scaled)) + 
  geom_rect(data = filter(postPs, subject <= 25, viol != "none"), 
            aes(xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf, fill = viol), alpha = 0.4) +
  geom_line(size = 0.8, color = "gray") + geom_point(size=0.8) +   
  facet_grid(item ~ subject, scales = "free") +
  theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.position="none",
        # panel.background=element_blank(),
        # panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank()) +
  scale_fill_manual(name="posterior p-value violations",
                    values=c(entropy="firebrick", mean="skyblue"),
                    guide = guide_legend()) + 
  theme(legend.position="top")

bh_rating_individual_2 = ggplot(filter(y.slider_individual, subject > 25), aes(x = bin, y = rating_scaled)) + 
  geom_rect(data = filter(postPs, subject > 25, viol != "none"), 
            aes(xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf, fill = viol), alpha = 0.4) +
  geom_line(size = 0.8, color = "gray") + geom_point(size=0.8) + 
  facet_grid(item ~ subject, scales = "free") +
  theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.position="none",
        # panel.background=element_blank(),
        # panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank()) +
  scale_fill_manual(name="posterior p-value violations",
                    values=c(entropy="firebrick", mean="skyblue"),
                    guide = guide_legend()) + 
  theme(legend.position="bottom")

bh_rating_individual = grid.arrange(bh_rating_individual_1, bh_rating_individual_2, nrow=2)
show(bh_rating_individual)
f = 2
ggsave("plots/posteriorPvalues_individualSliders.pdf", bh_rating_individual, width = 9*f, height = 6*f)
ggsave("plots/posteriorPvalues_individualSliders.png", bh_rating_individual, width = 9*f, height = 6*f)