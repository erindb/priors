require('HapEstXXR') # for powerset

ns = 11
nm = 8
states = 0:(ns-1)
semantics = matrix(c( 1, 0, 0, 0, 0, 0, 0, 0,
                      0, 1, 0, 0, 0, 0, 0, 1,
                      0, 0, 1, 0, 0, 0, 0, 1,
                      0, 0, 0, 1, 0, 0, 0, 1,
                      0, 0, 0, 0, 0, 0, 0, 1,
                      0, 0, 0, 0, 1, 0, 0, 1,
                      0, 0, 0, 0, 1, 1, 0, 1,
                      0, 0, 0, 0, 1, 1, 0, 1,
                      0, 0, 0, 0, 1, 1, 0, 1,
                      0, 0, 0, 0, 1, 1, 0, 1,
                      0, 0, 0, 0, 1, 1, 1, 1
                            ),nrow=11,byrow=T)
rownames(semantics) = paste('t',0:10,sep='-')
colnames(semantics) = c('none', 'one', 'two', 'three', 'many' , 'most', 'all', 'some')

R0 = prop.table(t(semantics),1)

# power sets
psetL = powerset(1:nm)[129:255] # list representation of all relevant powersets
psetM = matrix(0,nrow=length(psetL),ncol=nm) # bit vector representation
psetMC = matrix(0,nrow=length(psetL),ncol=nm)
pindM = matrix(0,nrow=length(psetL),ncol=nm)
for (i in 1:length(psetL)){
  pindM[i,] = c(psetL[[i]], rep(8, 8-length(psetL[[i]])))
  for (m in 1:nm){
    if (m %in% psetL[[i]]){
      psetM[i,m] = 1
    }
    else{
      psetMC[i,m] = 1
    }
  }
}


## MCMC chain handling

extractSamples = function(ms, parameter) {
  if ( parameter %in% levels(ms$Parameter) ) {
    out = droplevels(filter(ms, Parameter == parameter))
  } else {
    out = droplevels(ms[grep(paste0("^",parameter,"[\\[$]"), ms$Parameter),])
  }
  if (nrow(out) == 0) {
    stop(paste0("Chosen parameter '" , parameter, "' is not in parameter list!"))
  } else {
    return(out)
  }
}

getSlice = function(ms, parameter, chain = 1 , iteration = 1) {
  ms = extractSamples(ms, parameter)
  vectorFlag = ! grepl(",", ms$Parameter[1], fixed = TRUE) # whether we have a vector
  singletonFlag = ! grepl("[", ms$Parameter[1], fixed = TRUE) # whether we have a singleton
  paraLevs = levels(ms$Parameter)
  if (singletonFlag) {
    rowMax = 1
    colMax = 1
    return(filter(ms, Chain == chain, Iteration == iteration)$value)
  } else if (vectorFlag) {
    rowMax = 1
    colMax = max(as.numeric(sapply(paraLevs, 
                                   function(p) substr(p,
                                                      start = regexpr("[", p, fixed = TRUE)[[1]] + 1, 
                                                      stop  = regexpr("]", p, fixed = TRUE)[[1]] - 1)))  )
  } else {
    rowMax = max(as.numeric(sapply(paraLevs, 
                                   function(p) substr(p,
                                                      start = regexpr("[", p, fixed = TRUE)[[1]] + 1, 
                                                      stop  = regexpr(",", p, fixed = TRUE)[[1]] - 1)))  )
    colMax = max(as.numeric(sapply(paraLevs, 
                                   function(p) substr(p,
                                                      start = regexpr(",", p, fixed = TRUE)[[1]] + 1, 
                                                      stop  = regexpr("]", p, fixed = TRUE)[[1]] - 1)))  )
  }
  matrix(filter(ms, Chain == chain, Iteration == iteration)$value[1:(colMax*rowMax)], nrow = rowMax, ncol = colMax)
}

mcmcPlot = function(ms, parameter) {
  # specify parameter name or supply a vector
  ms = extractSamples(ms, parameter)
  nc = max(ms$Chain)
  vectorFlag = ! grepl(",", ms$Parameter[1], fixed = TRUE) # whether we have a vector
  singletonFlag = ! grepl("[", ms$Parameter[1], fixed = TRUE) # whether we have a singleton
  plotData = ms %>% group_by(Parameter,Chain) %>% 
    summarise(HDIlow95  = HPDinterval(as.mcmc(value), prob = 0.95)[1],
              HDIlow80  = HPDinterval(as.mcmc(value), prob = 0.80)[1],
              mean = mean(value),
              HDIhigh80 = HPDinterval(as.mcmc(value), prob = 0.80)[2],
              HDIhigh95 = HPDinterval(as.mcmc(value), prob = 0.95)[2])
  if (singletonFlag) {
    plotData$col = 1
  } else if ( vectorFlag ){
    plotData$col = as.numeric(sapply(1:nrow(plotData), 
                                     function(i) substr(plotData$Parameter[i],
                                                        start = regexpr("[", plotData$Parameter[i], fixed = TRUE)[[1]] + 1, 
                                                        stop  = regexpr("]", plotData$Parameter[i], fixed = TRUE)[[1]] - 1)))
  } else {
    plotData$row = as.numeric(sapply(1:nrow(plotData), 
                                     function(i) substr(plotData$Parameter[i],
                                                        start = regexpr("[", plotData$Parameter[i], fixed = TRUE)[[1]] + 1, 
                                                        stop  = regexpr(",", plotData$Parameter[i], fixed = TRUE)[[1]] - 1)))
    plotData$col = as.numeric(sapply(1:nrow(plotData), 
                                     function(i) substr(plotData$Parameter[i],
                                                        start = regexpr(",", plotData$Parameter[i], fixed = TRUE)[[1]] + 1, 
                                                        stop  = regexpr("]", plotData$Parameter[i], fixed = TRUE)[[1]] - 1)))
  }
  plotData$Chain = factor(plotData$Chain)
  outPlot = ggplot() + 
    geom_linerange(data = plotData, 
                   mapping = aes(x = col, y = mean, 
                                 ymin = HDIlow95, ymax = HDIhigh95, 
                                 color = Chain), size = 0.75) +
    geom_linerange(data = plotData, 
                   mapping = aes(x = col, y = mean, 
                                 ymin = HDIlow80, ymax = HDIhigh80, 
                                 color = Chain), size = 1.75) +
    geom_point(data = plotData, 
               mapping = aes(x = col, y = mean, 
                             shape = Chain), size = 3.5) + scale_shape(solid = FALSE) +
    ylab("estimate") + xlab("column")
  if (!vectorFlag) {
    outPlot = outPlot + facet_wrap(~ row, scales = "free", nrow = 6)
  }
  return(outPlot)
}

