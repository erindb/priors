library('coda')
library('ggmcmc')
library('jagsUI') # for parallel computing
library('xtable')
source('helpers/helpers.R')
# source('~/Desktop/data/svn/ProComPrag/dev_tmp/typicality_quantifiers/model/helpers.r')
source('process_data.R')

theme_set(theme_bw() + theme(plot.background=element_blank()) )

readFlag = TRUE

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
