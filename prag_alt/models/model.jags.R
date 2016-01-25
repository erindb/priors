model {
    ## SLIDER
    for (i in 1:N.slider) {
        p[i] <- subj[item.slider[i], worker.slider[i], bin.num[i]]
        pred[i] = 1/ (1 + exp(-k.skewGlobal*(log(p[i]/(1-p[i]))-threshold)))
        y.slider[i] ~ dnorm(pred[i], tau) T(0,1)
        # y.sliderPPC[i] ~ dnorm(y[i], tau)
    }
    
    ## NUMBERS
   for (i in 1:N.number) {
       y.number[i] ~ dcat(pow(subj[item.number[i], worker.number[i], 1:15], a))
       y.numberPPC[i] ~ dcat(pow(subj[item.number[i], worker.number[i], 1:15], a))
   }

    ## CHOICE
    for (i in 1:N.choice) {
        # bin.L[i] ~ dcat(pow(subj[item.choice[i], worker.choice[i], 1:15], b))
        for (j in 1:15) {
          pTemp[i,j] <- exp( 1000 * subj[item.choice[i], worker.choice[i],j] )
        }
        for (j in 1:15) {
          pTempNorm[i,j] <- pTemp[i,j] / sum(pTemp[i,1:15])
        }
        mode[i] ~ dcat(pTempNorm[i,1:15])
      
        # difference between choice alternatives and modal bin
        d.lo[i] <- abs(mode[i] - lower[i])
        d.hi[i] <- abs(mode[i] - higher[i])
                            
        probT[i,1] <- exp(b * (15 - d.lo[i]))
        probT[i,2] <- exp(b * (15 - d.hi[i]))
        prob[i] <- probT[i,2] / sum(probT[i,])
        
        y.choice[i] ~ dbern(prob[i])                            
#         y.choicePPC[i] ~ dbern(prob[i])
                              
    }
    
    # noise parameter
    w ~ dgamma(2, 0.1)
    a ~ dgamma(2, 1)
    b ~ dgamma(2, 1)
    sigma ~ dgamma(.0001, .0001)
    tau <- 1/sigma^2
    threshold ~ dnorm(0,1)
    
    # priors for logistic skew
    # for (i in 1:n.subj) { k.skew[i] ~ dgamma(2, 1) }
    k.skewGlobal ~ dgamma(5,5)
    for (i in 1:n.subj) { k.skew[i] <- k.skewGlobal }
    
    # population item priors
    for (j in 1:n.items) {
        item.pop[j,1:15] ~ ddirch(ones[])
        
        # subject specific priors
        for (i in 1:n.subj) {
            subj[j, i, 1:15] ~ ddirch((item.pop[j,1:15] * w) + 1)
            # subj[j, i, 1:15] <- item.pop[1:15, j]
        }
    }
}