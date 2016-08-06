data { 
  int<lower=1> subjects_numChoice;
  int<lower=1> subjects_sliderBins;
  int<lower=1> subjects_lightning;
  int<lower=0> bins;
  int<lower=1> items;
  int<lower=0> data_numChoice[subjects_numChoice,items];
  vector<lower=0>[bins] data_sliderBins[subjects_sliderBins,items];
  matrix<lower=0>[bins, bins] data_lightning[subjects_lightning,items];
  vector<lower=0>[bins] ones;
}
parameters {
  simplex[bins] priors[items];
}
transformed parameters {
  vector<lower=0>[bins] xform_priors[items];
  matrix<lower=0>[bins, bins] lightning_priors[items];
  for (j in 1:items){
    // "uninformative concentration" (is this right?)
    xform_priors[j] <- 16*priors[j];
  }
  for (j in 1:items){
    for (k1 in 1:bins)
      for (k2 in 1:bins){
        // probability of two bins into bernoulli parameter
        lightning_priors[j,k1,k2] <- 0.5+(priors[j,k1]-priors[j,k2])/2;
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
        data_giveN[i,j] ~ categorical(priors[j]);
    }

    for (i in 1:subjects_sliderBins){
        data_binnedHist[i,j] ~ dirichlet(xform_priors[j]);
    }

    for (i in 1:subjects_lightning){
      for (k1 in 1:bins){
        for (k2 in 1:bins){
          if (data_lightning[i,j,k1,k2] != -1){     // If lightning data exists
            data_lightning[i,j,k1,k2] ~ bernoulli(lightning_priors[j,k1,k2])
          }
        }
      }
    }
  }
}