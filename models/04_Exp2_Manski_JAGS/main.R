library('coda')
library('ggmcmc')
library('jagsUI') # for parallel computing
source('helpers/helpers.R')
source('~/Desktop/data/svn/ProComPrag/dev_tmp/typicality_quantifiers/model/helpers.r')
source('process_data.R')

saveFlag = TRUE

data_aggr <- list(y.slider = y.slider, y.number = y.number, y.choice = y.choice, 
                  higher = higher, lower = lower,
                  nSubjs = 50, nItems = 8, nBins = 15, nLightConds = 5,
                  ones = rep(1,15))
params <- c('w', 
            'a', 
            'sigma', 
            'item.pop',
            'subj',
            'k', 
            'b',
            "y.choicePPC", 
            "y.numberPPC",
            "y.sliderPPC"
            )

model = "models/model.jags.R"
# burnin = 100
# iter = 100
burnin = 10000
iter = 10000
out = jags(data = data_aggr,
            inits = NULL,
            parameters.to.save = params,
            codaOnly = c("y.choicePPC", "y.numberPPC", "y.sliderPPC", "subj"),
            model.file = model,
            n.chains = 2,
            n.adapt = 5000,
            n.iter = iter + burnin,
            n.burnin = burnin,
            n.thin = 2, 
            DIC = TRUE,
            verbose = TRUE,
            parallel = TRUE)

if (saveFlag) { save(out, file = "~/Desktop/Dropbox/priors_data/outExp2.Rdat") }

stop()

p = out$sims.list$item.pop[1,1,]

ggplot(melt(rdirichlet(alpha= p*190 + 1, n = 10)), aes(x = Var2, y = value, fill = factor(Var1))) + geom_line(color = "gray") + geom_line(data = cbind(melt(p), x=1:15, Var1 = "a"), aes(x = x, y = value, color = "red"))

x = out$sims.list$subj[,1,1,]
y = out$sims.list$subj[,2,1,]
z = out$sims.list$subj[,3,1,]

ggplot(melt(x), aes(x = Var2, y = value, fill = factor(Var1))) + geom_line(color = "gray") + geom_line(data = melt(y), color = "darkgray") +
  geom_line(data = melt(z), color = "green")
