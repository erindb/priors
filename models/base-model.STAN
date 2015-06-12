data { 
  int<lower=1> subjects_giveN;
  int<lower=1> subjects_binnedHist;
  int<lower=1> subjects_lightning;
  int<lower=0> states;
  int<lower=1> items;
  int<lower=0> data_giveN[items,subjects_giveN];
  vector<lower=0>[states] data_binnedHist[items,subjects_binnedHist];
  matrix<lower=0>[states, states] data_lightning[items,subjects_lightning];
  vector<lower=0>[states] ones;
}
parameters {
  simplex[states] priors[items];
}
transformed parameters {
  vector<lower=0>[states] xform_priors[items];
  matrix<lower=0>[states, states] lightning_priors[items];
  for (j in 1:items){
    // "uninformative concentration"
    xform_priors[j] <- 16*priors[j];
  }
  for (j in 1:items){
    for (i in 1:states)
      for (k in 1:states){
        // probability of two states into bernoulli parameter
        lightning_priors[j,i,k] <- 0.5+(priors[j,i]-priors[j,k])/2;
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
    for (i in 1:subjects_giveN){
        data_giveN[j,i] ~ categorical(priors[j]);
    }

    for (i in 1:subjects_binnedHist){
        data_binnedHist[j,i] ~ dirichlet(xform_priors[j]);
    }

    for (i in 1:subjects_lightning){
      for (k in 1:states){
        for (m in 1:states){
          if (data_lightning[j,i,k,m] != -1){     // If lightning data exists
            data_lightning[j,i,k,m] ~ bernoulli(lightning_priors[j,k,m])
          }
        }
      }
    }
  }
}