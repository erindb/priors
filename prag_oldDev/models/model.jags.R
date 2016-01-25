model {
  ## SLIDERS
  for (i in 1:nSubjs) {
    for (j in 1:nItems) {
      for (k in 1:nBins){
        y[i,j,k] <- k.skew[i] * log(subj[i,j,k] / (1 - subj[i,j,k]))
        y.slider[i,j,k]    ~ dnorm(y[i,j,k], tau)
        y.sliderPPC[i,j,k] ~ dnorm(y[i,j,k], tau)   
      }
    }
  }
  ## NUMBERS
  for (i in 1:nSubjs) {
    for (j in 1:nItems) {
        y.number[i,j,1]    ~ dcat(pow(subj[i,j, 1:15], a))
        y.numberPPC[i,j,1] ~ dcat(pow(subj[i,j, 1:15], a))
    }
  }

  ## CHOICE
  for (i in 1:nSubjs) {
    for (j in 1:nItems) {
      for (b in 1:15) {
        pTemp[i,j,b] <- exp( 1000 * subj[i,j,b] )
        pTempNorm[i,j,b] = pTemp[i,j,b] / sum(pTemp[i,j,1:15])
      }
      mode[i,j] ~ dcat(pTempNorm[i,j,1:15])
      for (k in 1:nLightConds) {
        # difference between choice alternatives and modal bin
        d.lo[i,j,k] <- abs(mode[i,j] - lower[i,j,k])
        d.hi[i,j,k] <- abs(mode[i,j] - higher[i,j,k])
        probT[i,j,k,1] <- exp(b * (15 - d.lo[i,j,k]))
        probT[i,j,k,2] <- exp(b * (15 - d.hi[i,j,k]))
        prob[i,j,k] <- probT[i,j,k,2] / sum(probT[i,j,k,1:2])
        y.choice[i,j,k] ~ dbern(prob[i,j,k])                            
        y.choicePPC[i,j,k] ~ dbern(prob[i,j,k])
      }
    }
  }
    # noise parameter
    w ~ dgamma(2, 0.1)
    a ~ dgamma(2, 1)
    b ~ dgamma(2, 1)
    sigma ~ dgamma(.0001, .0001)
    tau <- 1/sigma^2
    
    # priors for logistic skew
    # for (i in 1:n.subj) { k.skew[i] ~ dgamma(2, 1) }
    k.skewGlobal ~ dgamma(5,5)
    for (i in 1:nSubjs) { k.skew[i] <- k.skewGlobal }
    
    # population item priors
    for (j in 1:nItems) {
        item.pop[j, 1:15] ~ ddirch(ones[])
        # subject specific priors
        for (i in 1:nSubjs) {
            subj[i, j, 1:15] ~ ddirch((item.pop[j, 1:15] * w) + 1)
        }
    }
}