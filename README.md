## Notes from priors meeting (5/8-9/2015)

- what do we mean by priors?

	- simple things
	
		- one binary outcome - how likely is it?
		
		- 3 binary outcomes
		
		- scalar settings
		
		- 15 outcomes...
	
	- complicated things
	
		- a whole intuitive theory is a prior
		
		
- what do we ask people (dv)? not probabilities, because they're bad at it
	
	- give an outcome (slider, typing, binned histograms)

	- give N outcomes (imagine 10 times that you tried this, how many marbles sank?)
	
	- binned histograms with different binning strategies
	
	- scrape priors	
	
	- -> results: squishing, expanding, task re-interpretation (make points add to 100); generally: often, qualitative results are similar, very different quantitatively

- issue: 

	- we don't know how what we elicit relates to the underlying prior		
	
	- we don't have a gold standard, so it's hard to calibrate
	
- example:

	- we thouhgt sinking marbles was a case of binomials -- but that doesn't work, so we can't use it as a gold standard
	
		
- what do we need:

	- linking function between prior and response behavior
	
	- try to jointly pin down priors and parameters of linking functions
	
	- issue:
	
		- explosion of conditions (we need more data)
		
		- explosion of computational tractability
	
	
- strategies:

	- if i want to transform to predict one DV outcome from another one, what would i need to do?
	
	- ordering task, to see if it matches sliders/other DVs?
	
	- let people choose their DV themselves?
	
## Results so far

### Experiment 1

http://stanford.edu/~erindb/priors/experiments/exp1/exp1.html

#### Method

20 participants. We elicited prior beliefs from each participant on 8 different items using 3 different DVs:	

- give a number -- adjust a slider that ranges between a min and max value

- binned histogram (15 bins) -- for each of 15 bins of pre-define intervals, say how likely that bin is using a slider with endpoints labeled "extremely likely" and "impossible", with intermediate labels "very likely", "neutral", "not very likely"

- lightning round -- for 5 paired comparisons (bins 0-1, 1-5, 5-10, 10-13, 13-14), say which one you think is more likely (2AFC)

Each participant saw each item in each DV, but the order of trials was randomized. Lightning rounds always occurred as a block of five trials (with order of comparisons randomized within that block).

Items were chosen from previous experiments run by Justine, Erin, Michael F., Ciyang, Anthea, and Judith:

- coffee temperatures (44F or less - 200F or more, steps of 13)

- blockbuster movie lengths (0 - 210 or more minutes, steps of 16)

- last week's TV watching durations (0 - 43 or more hours, steps of 3)

- yesterday's commute times (0 - 98 or more minutes, steps of 7)

- laptop prices (0 - more than $7500, steps of $500)

- watch prices (0 - more than $750, steps of $50)

- number of sinking marbles (0 - 14, steps of 1)

- number of kids that laughed when told a joke (0 - 14, steps of 1)

#### Results

Results for the three different DVs are shown below.

First, a histogram of the give-a-number task. Decent replication of the wonky worlds results. This looks like people are going for the mean/median rather than the mode of the binned histogram (see next plot).

![Give a number](/experiments/exp1/analysis/graphs/number_histogram.png "Give a number task")

Here are the (normalized) binned histogram data:

![Binned histogram (mean values)](/experiments/exp1/analysis/graphs/binned_histogram_norm_means.png "Binned histogram (normed mean slider values)")

This is a decent replication of wonky worlds as well as of Michael and Anthea's results. Also for laptop/watch prices? Interestingly, assuming that what people are doing in the give-a-number task is going for the mean/median looks like it'll serve as a good linking function for all the items except for the wonky worlds items (and there, really, just the sinking marbles item).

Looking more closely at the items by comparing them to the raw (unnormalized) slider means from the binned histogram task:

![Binned histogram (raw values)](/experiments/exp1/analysis/graphs/binned_histogram_raw_means.png "Binned histogram (raw mean slider values)")

All items look very similar again in their general shape, except for sinking marbles. Looks like in this case, different participants are just using the sliders very differently. Anthea remarked that this (and the other wonky item, "joke") is the only case where we need to evaluate for each object (i.e., 14 different ones), whether something happened to it or not. For all the other cases, we just need to say of that one object/event, what it likely cost/how long it took, etc. This relates also to something Uli Sauerland brought up after my MXPrag talk: for things like marbles sinking and ice cubes melting, etc, there will be intermediate stages when not all of the  marbles have sunk yet or not all of the ice cubes have melted yet, even if ultimately they all sink/melt. This may be an additional reason why people want to sometimes put some mass on the less-than-all states (besides not understanidng the sliders...). We may need a different linking function for these event cases.

Finally, here are the results from the lightning round:

![Lightning round](/experiments/exp1/analysis/graphs/lightning_round.png "Lightning round")

Here it seems that rather than comparing probabilities for each bin (from the binned histogram task) and making a choice based on that, people seem to be judging by how far from the mode/median/mean or from a random sample from the binned histogram distribution each comparison bin is. For example, for commute, the mean is around the fourth bin. For the 0-1 comparison, people are at ceiling for choosing the higher bin. For the 1-5 comparison, they're around 60%, and for all higher comparisons, they basically always choose the lower bin (that's closer to the mean). Here again, marbles is a little different. One would expect people to always choose the higher bin. Instead, there seems to be something special about the lowest comparison: despite one marble sinking being closer to all marbles sinking (the mode), they prefer to say that 0 marbles sinking is more likely than one marble sinking half the time. Presumably, there is some inference there of the form that marbles are typically the same, so if one of them sinks that's weird -- if none of them sink, that's weird, too, but at least they're still all the same.

#### Some ways forward

Michael/Anthea/I were thinking that the next reasonable step would be for the Michaels to start running the Bayesian data analysis. It looks like for most items, there will be a plausible linking assumption that can capture the data, with the exception of the marbles item. But this should show up in the results as the marbles item having a high guessing parameter value (if by-item guessing parameters are included). 

It'll be interesting to think more about the difference between these "repeated event" type cases like sinking marbles, vs the "stative property" type cases like watch prices.



	