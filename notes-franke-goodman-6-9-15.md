# Meeting: June 9, 2015

Contributors

+ noah
+ michael franke
+ mh tessler

### preliminaries

1. analysis of anthea's data on many/few
2. franke's data with ciyang, alternative to lifted-threshold threshold: tall/long

## priors discussion

### general approach

1. Do we wish to model this by subject vs aggregate?
2. What is the goal?
    A. Stipulate true population prior?
        	1. For each item, distribution over the scale known to all people.
		2. Small perturbations for each subject
		3. One issue: If you scale prior (raise to power), this can be undone by changing parameters of the linking parameters
			D. In principle, you can get the shape but not the scale.
	B. Run each dependent measure jointly & separately, to see how reliable each is in recovering true prior
3. How would we know we had it right?
	A. Posterior predictive -- train model on data and have it show back the data it predicts.
	B. Insights from Behavioral economics -- "Scoring rule", incentive scheme to make people more accurate for reporting various statistics (e.g. means, mode, CIs)
		1. Train people on distribution
		2. Run tests
		3. See if you recover distribution
		4. **Caveat**: This is only accessable by filtering through an implicit learning model. 
		5. **Push-back**: Yes. But if it's right, it's unlikely the learning model biased it in exactly the right way. So if it's right, it's probably right.
	C. More extensive language tasks? (Using explicit models of language understanding.)
	D. Split data across dependent measures. (Like posterior predictive, but only fit to one dependent measure?)
6. Nonidentifiability
	A. Not a problem if you don't care about true underlying prior (i.e. if you only care about posterior predictive.)
		
### our particular approach

1. Item-wise prior over scale 
2. Doing hierarchically by subject, straightforward
	A. Does each subject have their own (noisy) copy of the true prior?
3. Linking function is big question
4. Dependent measures
	A. Choose a number -- Categorical (alpha^power)
		B. Is there a difference between a subject sampling from their subjective prior, and a subject sampling from the true prior (but with linking function paramete e.g. raise-to-power)?
	C. Sliders -- logit with noise
		1. Fitting unnormalized (raw) data
			A. Model each state independently. 
			B. Is normalizing is like detrending (removing the mean)?
		2. Do subjects have a trial-wise noisy copy of her own subjective prior? (Double subjective prior)
			A. Is logit-normal-logistic same thing as double subjective?
		3. We would want a linking funciton that allows for endpont-avoiding and endpoint-seaking behavior
5. Coupling parameters with strict criteria (don't deviate too much from one another)
	A. Is this better or worse for inference?
	
## concluding remarks

Goal is to do BDA that adequately accounts for DMs, with flexibility enough to capture the variation we see, and is tractable with some tool
		
Ciyang has priors for adjectives (binned histograms), with forced choice (like our give-a-number, but with bins)
	
	
### next steps

MHT write down one or two models in STAN, send to Noah and Michael for comments

+ parameterizied linking functions for subjects
+ confidence (concentration) based linking functions for items
+ something with very few linking assumptions, also
