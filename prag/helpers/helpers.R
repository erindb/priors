library('dplyr')
library('ggplot2')
library('reshape2')


logit <- function(x) log(x / (1 - x))
logistic <- function(x) exp(x) / (1 + exp(x))
add.margin <- function(x, eps = 0.000001) (1 - 2*eps)*x + eps 
normalize <- function(x) (x - min(x)) / (max(x) - min(x))


# Computes highest density interval from a sample of representative values,
#   estimated as shortest credible interval.
# Arguments:
#   sampleVec
#     is a vector of representative values from a probability distribution.
#   credMass
#     is a scalar between 0 and 1, indicating the mass within the credible
#     interval that is to be estimated.
# Value:
#   HDIlim is a vector containing the limits of the HDI
HDIofMCMC = function( sampleVec , credMass = 0.95 ) {
  sortedPts = sort( sampleVec )
  ciIdxInc = ceiling( credMass * length( sortedPts ) )
  nCIs = length( sortedPts ) - ciIdxInc
  ciWidth = rep( 0 , nCIs )
  for ( i in 1:nCIs ) {
    ciWidth[ i ] = sortedPts[ i + ciIdxInc ] - sortedPts[ i ]
  }
  HDImin = sortedPts[ which.min( ciWidth ) ]
  HDImax = sortedPts[ which.min( ciWidth ) + ciIdxInc ]
  HDIlim = c( HDImin , HDImax )
  return( HDIlim )
}


# get the all the samples into a data.frame
# first get the parameters, and the the posterior predictive values
# otherwise it messes with the number of bins; until now: only sliderPPC
construct_ppvs <- function(samples, ppv = 'y.sliderPPC') {
  slist <- samples$BUGSoutput$sims.list
  ppv_df <- slist[[ppv]]
  ppv_df <- tbl_df(melt(ppv_df))
  
  # poor man's solution as of yet
  if (ppv == 'y.sliderPPC') {
    bins <- rep(bin_dat$bin_num, each = max(ppv_df$Var1))
    items <- rep(bin_dat$tag, each = max(ppv_df$Var1))
    ppv_df <- ppv_df %>%
                mutate(item = items, bin = bins, variable = ppv) %>% select(1, 2, 5, 3, 4, 6)
    ppv_df$value = logistic(ppv_df$value)
  } else if (ppv == 'y.numberPPC') {
    ppv_df$variable <- ppv
    items <- rep(number_dat$tag, each = max(ppv_df$Var1))
    ppv_df <- ppv_df %>% 
                mutate(item = items) %>% 
                select(1, 2, 4, 5, 3)
  } else {
    ppv_df$variable <- ppv
    items <- rep(choice_dat$tag, each = max(ppv_df$Var1))
    ppv_df <- ppv_df %>% 
                mutate(item = items) %>% 
                select(1, 2, 4, 5, 3)
  }
  
  names(ppv_df) <- c('step', 'sample', names(ppv_df)[3:ncol(ppv_df)])
  ppv_df
}


clean_samples <- function(samples, ppv = c('y.sliderPPC', 'y.numberPPC', 'y.choicePPC')) {
  slist <- samples$BUGSoutput$sims.list
  samplesDF <- tbl_df(melt(slist[-which(names(slist) %in% ppv)]))
  colnames(samplesDF) <- c('step', 'bin', 'value', 'item', 'variable')
  samplesDF
}


get_ppv <- function(ppv_df, y_emp, sampl = 1) {
  ppv_df %>% filter(step == sampl) %>% mutate(y_emp = y_emp)
}


aggregate_ppv <- function(ppv_df, y_emp) {
  ppv_df %>% group_by(sample, item) %>%
    summarize(value = median(value)) %>%
    tbl_df %>%  mutate(y_emp = y_emp)
}


plot_ppv <- function(ppv, type, items = unique(ppv$item)) {
  pred <- melt(select(ppv, value, y_emp, item))
  pred <- filter(pred, item %in% items)
  predicted <- filter(pred, variable == 'value')
  empirical <- filter(pred, variable == 'y_emp')
  
  if (type == 'numberPPC') {
    ggplot(pred, aes(x = value, fill = variable)) +
      geom_histogram(data = predicted, fill = 'red', alpha = .2) +
      geom_histogram(data = empirical, fill = 'blue', alpha = .2) +
      theme(axis.text = element_text(size = 14), axis.title = element_text(size = 20),
            plot.title = element_text(size = 20, face = 'bold'),
            strip.text.x = element_text(size = 14)) +
      labs(x = 'chosen bin', title = 'Posterior Predictive for Number') +
    
      # not working as of yet!
      scale_fill_manual(name = 'legend',
                        values = c('red', 'blue'),
                        labels = c('value', 'y_emp')) + facet_wrap( ~ item, ncol = 4)
  } else {
    ggplot(pred, aes(x = value, fill = variable)) +
      geom_density(data = predicted, fill = 'red', alpha = .2) +
      geom_density(data = empirical, fill = 'blue', alpha = .2) +
      theme(axis.text = element_text(size = 14), axis.title = element_text(size = 20),
            plot.title = element_text(size = 20, face = 'bold'),
            strip.text.x = element_text(size = 14)) +
      labs(x = 'normalized response', title = 'Posterior Predictive for Slider') +
      
      facet_wrap( ~ item, ncol = 4)
  }
}


plot_items <- function() {
  meansIP <- csamples %>% filter(variable == "item.pop") %>%
    group_by(bin, item) %>%
    summarise(
      mean = mean(value),
      max = HDIofMCMC(value)[2],
      min = HDIofMCMC(value)[1]
    ) %>%
    mutate(item = levels(bin_dat$tag)[item])
  
  ggplot(meansIP, aes(x = bin, y = mean)) + geom_line() + geom_point() + facet_wrap(~ item) +  
    geom_errorbar(aes(ymin = min, ymax = max), width = .5, position = position_dodge(.1), color = 'gray')
}
