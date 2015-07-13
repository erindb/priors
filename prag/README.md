## Notes on JAGS implementation (7/13/2015)

what happens here:

* use data from experiment 1, which had three dependent measures:
 	1. binned-slider ratings
	2. number choice
	3. lightning round (compare two bins)

* infer from all the data in conjunction a latent population-level prior for each of the 8 items used (coffee, commute, ...)

### Sketch of model

The model assumes that for each item *j* (*j* in {1, ..., 8}), there is a population-level prior *Q_j*, so that *P_jk* is the probability of bin *k* (*k* in {1, ..., 15}) for item *j*. This is because it is this population-level aggregate that, if it can be reliably inferred, would be useful to use in further applications (i.e., if possible we would like not to bother with individual-level differences to test psychological/linguistic models).

Population-level priors are sampled from an unbiased Dirichtlet.

	Q_j ~ ddirich([1, 1, ...., 1])

To validate whether population-level priors can be assumed, we must look at individual-level data. So, the model is fit to individual-level data from Experiment 1.

Each individual subject *i* (*i* in {1, ..., 20}) is assumed to have her own "noisy copy" of the "true" population prior *Q_j*. Presently, the model assumes that there is a single parameter *w* that measures inverse noise / fidelity. Fidelity is implemented as a factor for Dirichlet weights. We use a reasonably looking, preliminary prior for *w*.

	w ~ dgamma(2, 0.1)

	P[i, j, 1:15] ~ ddirch((Q[j.1:15] * w) + 1)

[Note that the current implementation uses slightly different variable names and ways of indexing than given here.]

[Future extension could have *w* depend on item, possibly participant, but that would probably be reasonable only if more data per participant is available.]

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

We have as data *n_ij* in {1, ..., 15}: an integer that gives the bin in which subject *i*'s number choice for item *j* lives. In other words, we model bin-choice not number choice. This is because almost all bins are equally long, and so a random choice of number within each bin would not make much difference, expect to demote the relevance of the number-choice task in comparison to data from other tasks (less likelihood of a success).

[ToDo: rethink precise number choice -> maybe in STAN?]

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
	... well, in JAGS, it's complicated ... 

	
## Results 

#### Convergence

MCMC-chains ran via R2jags seem stable enough in the relevant respects so that we can explore the behavior of the model, but we haven't been able to have them converge, e.g., by the Gelman-Rubin R-hat statistic. This is chiefly an issue for prior components *Q_ij*, which are not independent anyway. Need to think whether this is a problem or not.

If this model survives scrutiny, we would anyway need to massage the priors, and run much longer chains eventually. Presently, we should not be too worried about that. Still, it does suggest that the data underspecifies the model slightly. More data would be helpful in any case.

#### Posteriors

Estimated posteriors over model parameters are plotted below. Parameter *tau* did not converge. In this high precision region, there is too little difference between different values. Otherwise interesting:

* *k* (here called 'k.skewGlobal') is almost 1, so no preference for/against extreme slider positions seems credible, given model and the other parameter values
* *w* values are not too high, suggesting reasonable inter-individual differences
* *b* is just the prior, because the model was not condition on the lightning round data (see above)

![Posteriors over model parameters](/prag/plots/posterior_parameters.png "Posteriors over model parameters")

Theoretically more interesting are the posterior estimates of the population priors *Q_j*. They are plotted below. The black dots & lines are means of the posterior estimates; the gray lines are 95% credibility intervals (individually for each bin, so strictly speaking not quite right, because we neglect interdependencies between values for different bins). The red dots and lines are the normalized average binned-slider ratings that we have used before as priors in our pragmatics experiments. Interestingly, the **inferred population priors are more extreme** and some values of the averaged binned-slider rating task are quite far outside of the 95% credible intervals. This would suggest that the latent inferring of priors has something to add.

![Smaller icon](/prag/plots/pop_priors.png "Title here")

![Posterior inferred population priors](/prag/plots/pop_priors.png "Posterior inferred population priors")

#### Posterior predictive checks

![Posterior predictive checks for binned-slider ratings](/prag/plots/ppc_slider.png "Posterior predictive checks for number choice")
	
![Posterior predictive checks for binned-slider ratings](/prag/plots/ppc_number.png "Posterior predictive checks for number choice")