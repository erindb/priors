require(dplyr)

d = read.table("results.csv", header=T, sep=",",quote="\"")
bins = read.csv("bins.txt",header=T)

## number choices (treated as bins)
give_number = d %>% filter(measure == "give_number") %>% droplevels() %>%
  select(workerid, tag, response, max)  %>%
  mutate(response = as.numeric(as.character(response)))
bins$Bin = bins$Bin + 1
give_number$chosen_bin = sapply(1:nrow(give_number), function(i) {
  response = give_number$response[i]
  tag = as.character(give_number$tag)[i]
  bins[bins$Item == tag & bins$Min <= response & bins$Max >= response,]$Bin
})

y.number = array(0, dim = c(50,8,1))
for (i in 1:nrow(give_number)){
  y.number[give_number$workerid[i] + 1, 
           as.numeric(give_number$tag)[i], # WTH does this enumerate starting at 2?
           1] = give_number$chosen_bin[i]
}
dimnames(y.number)[[2]] = sapply(1:8, function(i) levels(give_number$tag)[i])

## binned histograms
binned_histogram = droplevels(subset(d, measure == "binned_histogram")) %>%
  select(workerid, tag, bin, response) %>% 
  mutate(response = as.numeric(as.character(response)))
binned_histogram$bin_num = 1:15

y.slider = array(0, dim = c(50,8,15))
for (i in 1:nrow(binned_histogram)){
  y.slider[binned_histogram$workerid[i] + 1, 
           as.numeric(binned_histogram$tag)[i],
           binned_histogram$bin_num[i]] = binned_histogram$response[i]
}
dimnames(y.slider)[[2]] = sapply(1:8, function(i) levels(binned_histogram$tag)[i])
for (i in 1:dim(y.slider)[1]) {
  for (j in 1:dim(y.slider)[2]) {
    if (sum(y.slider[i,j,]) != 0) {
      y.slider[i,j,] = y.slider[i,j,] / sum(y.slider[i,j,])
    }
  }
}
# next: add.margin, take logit, get summaries as well
