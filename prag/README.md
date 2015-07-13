## Notes on JAGS implementation (7/13/2015)

what happens here:

* use data from experiment 1, which had three dependent measures:
 	1. binned-slider ratings
	2. number choice
	3. lightning round (compare two bins)

* infer from all the data in conjunction a latent population-level prior for each of the 8 items used (coffee, commute, ...)
	* **Motivation**: Such a population-level aggregate belief would be useful in further applications, if it can be reliably inferred, (i.e., if possible, we would like not to bother with individual-level differences to test psychological/linguistic models; we would like a 'cheap' and 'good enough' procedure to measure group-level beliefs for coarse-grained computational models).
* **goal**: get a first model off the ground with reasonable linking functions for these dependent variables; keep model austere (few parameters) and check explanatory success

### Sketch of model

The model assumes that for each item *j* (*j* in {1, ..., 8}), there is a population-level prior *Q_j*, so that *Q_jk* is the probability of bin *k* (*k* in {1, ..., 15}) for item *j*. 

Population-level priors are sampled from an unbiased an Dirichtlet distribution.

	Q_j ~ ddirich([1, 1, ...., 1])

To validate whether population-level priors can be assumed, we must look at individual-level data. So, the model is fit to individual-level data from Experiment 1.

Each individual subject *i* (*i* in {1, ..., 20}) is assumed to have her own "noisy copy" of the "true" population prior *Q_j*. Presently, the model assumes that there is a single parameter *w* that measures inverse noise / fidelity. Fidelity is implemented as a factor for Dirichlet weights. We use a reasonably looking, preliminary prior for *w*.

	w ~ dgamma(2, 0.1)
	P[i, j, 1:15] ~ ddirch((Q[j.1:15] * w) + 1)

[Note that the current implementation uses slightly different variable names and ways of indexing than the pseudo-JAGS given here.]

The individual-level copies *P_ij* are then used to explain data from all three dependent measures.

#### Binned slider ratings

We have data *x_ijk* in [0;1]: a normalized slider rating for each subject *i*, item *j* and bin *k*. 

[ToDo: think about using unnormalized data!?!]

The idea is that we think of each *x_ijk* as a noise-perturbed realization of *P_ijk* morphed so as to reflect a preference for or against the use of extreme slider positions. To apply noise, we transform ratings / probabilities from [0;1] to the reals with a logit transform. Noise is then just Gaussian noise around the real-valued logit of *P_ijk* with precision *tau*. To implement slider-range biases, we take a parameterized logit with parameter *k*. Priors are preliminary.

	sigma ~ dgamma(.001, .001)
    tau <- 1/sigma^2
    k ~ dgamma(5,5)
    
    Pl[i,j,k] <- k * log(P[i,j,k] / (1 - P[i,j,k]))  # parameterized logit
    xl[i,j,k] <- log(x[i,j,k] / (1 - x[i,j,k])) # standard logit
    xl[i,j,k] ~ dnorm(Pl[i,j,k], tau)
    
#### Number choice

We have as data *n_ij* in {1, ..., 15}: an integer that gives the bin in which subject *i*'s number choice for item *j* lives. In other words, we model bin-choice not number choice for practical convenience. 

[ToDo: rethink precise number choice]

The model assumes that bin choice *n_ij* is just a categorical sample from *P_ij*, with more or less emphasis on modal bins. This is implemented by a power-law transform with parameter *a*.

	a ~ dgamma(2, 1)
	n[i,j] ~ dcat(pow(P[i,j,1:15], a))

#### Lightning round

This one is troubling. We only have a preliminary approach, which we didn't include in the analyses so far, because it seems to mess up otherwise tidy results, and we are not sure whether this approach even makes sense. The idea so far is this:

Data to explain are binary decisions *c_ijl* with *l* in {1, ..., 5} the lightning round comparison: (i) bin 1 >?< bin 2, (ii) bin 2 >?< bin 5, ... We assume that *c_ijl* is 1 if subject *i* choose the higher bin for item *j* in bin-comparison *l*.

Following previous discussions (Judith, Anthea, Noah, Michael H.), we here assume that lightning round choices are based on comparisons of distance to the mode. Concretely, if  comparison *l* requires that bin X and bin Y are to be compared for item *j*, subject *i* consults the mode of her *P_ij*: suppose it is *m[i,j]*. Then, we ask how far away bin X and bin Y are from mode *m[i,j]*. Inverse distance is fed into a soft-max choice rule with parameter *b*.

	b ~ dgamma(2, 1)
	m[i,j] <- mode(P[i,j])
	...
	... well, in JAGS, even easy stuff like this can become ugly ... 

	
## Results 

Results are based on 20,000 samples from the posterior distribution, after a burn-in of 30,000, from two chains (taking every second sample to diminish autocorrelation).

#### Convergence

MCMC-chains ran via R2jags seem stable enough in the relevant respects so that we can explore the behavior of the model, but we haven't been able to have them converge, e.g., by the Gelman-Rubin R-hat statistic. This is chiefly an issue for prior components *Q_ij*, which are not independent anyway. Need to think whether this is a problem or not. If this model survives scrutiny, we would anyway need to massage the priors, and run much longer chains eventually. Presently, we should not be too worried about that. Still, it does suggest that the data underspecifies the model slightly. More data might be helpful in any case.

#### Posteriors

Estimated posteriors over model parameters are plotted below. Parameter *tau* did not converge. In this high precision region, there is too little difference between different values. Otherwise interesting:

* *k* (here called 'k.skewGlobal') is almost 1, so no preference for/against extreme slider positions seems credible, given model and the other parameter values
* *w* values are not too high, suggesting reasonable, but earthly inter-individual differences
* *b* is just the prior, because the model was not conditioned on the lightning round data (see above)

![Posteriors over model parameters](/prag/plots/posterior_parameters.png "Posteriors over model parameters")

Theoretically more interesting are the posterior estimates of the population priors *Q_j*. They are plotted below. The black dots & lines are means of the posterior estimates; the gray lines are 95% credibility intervals (marginalized over each bin individually, so strictly speaking not necessarily quite right, because we neglect interdependencies between values for different bins). The red dots and lines are the normalized average binned-slider ratings that we have used before as priors to feed into our pragmatic model. Interestingly, the **inferred population priors are more extreme** and some values of the averaged binned-slider rating task are quite far outside of the 95% credible intervals. This would suggest that inferring latent priors is reasonable and worthwhile.

![Posterior inferred population priors](/prag/plots/pop_priors.png "Posterior inferred population priors")

#### Kullback-Leibler divergence: inferred vs. average slider-bins

How much information would we lose if we used the normalized average slider-bin ratings, like we did before, instead of the estimated latent population priors? We can calculate the mean KL-divergence between all sampled population priors (taking these to be the "true" priors) and the corresponding normalized average slider-bin ratings. We get:

	     item     meanKL
	1  coffee 0.11022084
	2 commute 0.18299228
	3    joke 0.04055645
	4  laptop 0.41863908
	5 marbles 0.08787755
	6  movies 0.33767400
	7      tv 0.19430524
	8   watch 0.10456436

This means that we are not terribly off the mark in some cases (joke, marbles), but somewhat off in some others (movies, laptop). [Not quite sure, though, how to judge when close is close enough. ???]

#### Posterior predictive checks

Given the data, is the trained model surprised by the data that we used to train it on? If so, the model misses crucial aspects of the data. To check, we generated 20,000 simulated data points from the trained model. We want to compare it (visually) to the data. 

As for the binned-slider ratings task, the model is spot-on! If posterior predictive samples are normalized (by subject; just like the real data), the means of these normalized simulated samples (black dots in the plot below) are pretty much indistinguishable from the observations (red dots in the plot below). The plot also shows (point-wise -> wrong!!) 95% credible intervals of the simulated samples. We would have to worry if the observed data fell outside of these, but clearly it doesn't.

![Posterior predictive checks for binned-slider ratings](/prag/plots/ppc_slider.png "Posterior predictive checks for number choice")

As for the number choice task, we also generated 20,000 simulated data sets and compared their averages to the observed data. Averages of the simulated data are the black bars in the plot below, the observed data are the red dots & lines. This seems okay, but we also have very little data from this condition to begin with. We haven't implemented credible intervals for posterior predictive checks for number choice yet. 
	
![Posterior predictive checks for binned-slider ratings](/prag/plots/ppc_number.png "Posterior predictive checks for number choice")

### Summary

* model seems to work alright: robust inferences about latent population priors
* suggests divergence between latent priors and averages from binned-slider task, but this is only a very preliminary result that we need to check, also against model variations

### ToDo-s

##### Conceptually

everybody, chime in, if you please:

* how reasonable is the model? what should be different?
* what is the main point we would like to make / check with a model of this kind?

##### Techie

* more individual-level or item-level parameter differences?
* tweak to convergence: initial starting values, priors ...
* check individual-level probability distributions and their fit to individual-level data?
* fix a model for lightning round & run combined model
* eventually port main.R to use jrags, which is faster, but less convenient for exploration