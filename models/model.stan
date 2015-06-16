data { 
  // these 3 numbers will be the same if it's all within-subjects
  int<lower=1> subjects_numChoice;
  int<lower=1> subjects_sliderBins;
  int<lower=1> subjects_lightning;
  // number of bins/states
  int<lower=0> bins;
  //n number of items
  int<lower=1> items;
  int<lower=0> data_numChoice[subjects_numChoice,items];
  vector<lower=0>[bins] data_sliderBins[subjects_sliderBins,items];
  matrix<lower=0>[bins, bins] data_lightning[subjects_lightning,items];
  // vector of ones (maybe there is an easy to do this in STAN?)
  vector<lower=0>[bins] ones;
}
parameters {
  // the big prior in the sky
  simplex[bins] priors[items];

  
  ///////////////////////////
  // subject-wise parameters
  ///////////////////////////

  // "number choice"
  int<lower=0> alpha[subjects_numChoice]
  // "slider bins"
  int offset[subjects_sliderBins]
  int<lower=0> scale[subjects_sliderBins]
  // "lightning round"
  int<lower=0> lambda[subjects_lightning]

  ///////////////////////////
  // item-wise paramaters
  ///////////////////////////
  // "number choice"
  // "slider bins"
  int<lower=0> concentration[items]
  // "lightning round"

}
transformed parameters {
  vector<lower=0>[bins] link_numChoice[subjects_numChoice,items];
  vector<lower=0>[bins] link_sliderBins[subjects_sliderBins,items];
  matrix<lower=0>[bins, bins] link_lightning[subjects_lightning,items];

  int<lower=0, upper=1>lightning_tmp_a;
  int<lower=0, upper=1>lightning_tmp_b;

  //////////////////////////////////////////////////////
  // subject-wise linking function for "number choice"
  //////////////////////////////////////////////////////
  // raise to power (subject-wise alpha), and renormalize

  for (i in 1:subjects_numChoice){
    for (j in 1:items){
      link_numChoice[i,j] <- pow(priors[j], alpha[i])
      link_numChoice[i,j] <- link_numChoice[i,j]/sum(link_numChoice[i,j])
    }
  }
  //////////////////////////////////////////////////////
  // subject-wise linking function for "slider bin"
  //////////////////////////////////////////////////////
  // transform to [-Infinity,Infinity] scale
  // shift by some offset (subject-wise midpoint)
  // multiply by some scale (subject-wise sensitivity)
  // transform back to [0,1] scale
  // normalize, and multiply by some concentration (item-wise concentration)
  for (i in 1:subjects_sliderBins){
    for (j in 1:items){
      link_sliderBins[i,j] <- inv_logit(scale[i] * (logit(priors[i,j]) - offset[i]))
      link_sliderBins[i,j] <- link_sliderBins[i,j]/sum(link_sliderBins[i,j])
      link_sliderBins[i,j] <- concentration[j] * link_sliderBins[i,j]
    }
  }

  //////////////////////////////////////////////////////
  // subject-wise linking function for "lightning round"
  //////////////////////////////////////////////////////
  // raise to power (subject-wise lambda), and renormalize
  // transform 2 coin-weights to one relative-coin weight
  for (i in 1:subjects_lightning){
    for (j in 1:items){
      for (k1 in 1:bins){
        for (k2 in 1:bins){
          lightning_tmp_a <- pow(priors[j,k1], lambda[i])
          lightning_tmp_b <- pow(priors[j,k2], lambda[i])
          lightning_tmp_a <- lightning_tmp_a / (lightning_tmp_a+lightning_tmp_b)
          lightning_tmp_b <- lightning_tmp_b / (lightning_tmp_a+lightning_tmp_b)
          // probability of two bins into bernoulli parameter
          link_lightning[i,j,k1,k2] <- (1+lightning_tmp_a-lightning_tmp_b)/2;
        }
      }
    }
  }

}

model {
  // Priors
  for (j in 1:items){
    priors[j] ~ dirichlet(ones);
  }

  // Model
  for (j in 1:items){

    for (i in 1:subjects_numChoice){
        data_giveN[i,j] ~ categorical(link_numChoice[i,j]);
    }

    for (i in 1:subjects_sliderBins){
        data_binnedHist[i,j] ~ dirichlet(link_sliderBins[i,j]);
    }

    for (i in 1:subjects_lightning){
      for (k1 in 1:bins){
        for (k2 in 1:bins){
          if (data_lightning[i,j,k1,k2] != -1){     // If lightning data exists
            data_lightning[i,j,k1,k2] ~ bernoulli(link_lightning[i,j,k1,k2])
          }
        }
      }
    }
  }
}