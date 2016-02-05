# Shigella-Die-off-Modeling
This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License 
http://creativecommons.org/licenses/by-nc/4.0/ by Philip Collender, Christopher Hoover, Howard Chang and Justin Remais. 
This work was supported in part by the National Institutes of Health/National Science Foundation Ecology of Infectious Disease 
program funded by the Fogarty International Center (grant R01TW010286), the National Institute of Allergy and Infectious Diseases 
(grant K01AI091864), and the National Science Foundation Water Sustainability and Climate Program (grant 1360330).

Per the terms of this license, if you are making derivative use of this work, you must identify that your work is a derivative work, 
give credit to the original work, provide a link to the license, and indicate changes that were made.

___

This branch contains BUGS/JAGS models that are intended to provide robust estimates of parameters describing the effect of temperature
on die-off of pathogenic bacteria by integrating data across various studies. The content presented here is split between models currently
under development, models developed in previous phases of our research, and a couple of incidental pieces of code. The newer models 
include rate parameter estimation from raw die-off data with classification of monophasic rate parameters as belonging to either the fast 
or slow group of biphasic rate parameters (this assumption may be adjusted at some point in the future), and estimation of the relationship 
of rate parameters with temperature. The older models do not seek to classify monophasic rate parameters and perform separate estimates to 
identify rate parameters from die-off data, and to identify parameters describing the effect of temperature on the rate of die-off. 
Model descriptions are below:

##New Phase

###Full_Model_Bernoulli_Classification_Simplified.txt:

This is the model currently under development. Hierarchical elements include error terms to allow some studies or observations to be 
treated as outliers, as well as the proportion parameter alpha, which I'm assuming is related to experimental conditions that are 
likely to be held constant throughout a study. There is an attempt at preventing label switching between k1 and k2 (fast and slow rate
parameters for biphasic die-off) by restricting k2_20 to always be less than k1_20 (the value of k2 and k1 at 20 degrees C, respectively). 
Initial runs indicate better parameter estimation than the preceding model, but poor mixing for many parameter estimation chains in JAGS. 
It appears that k1 and k2 are both over-estimated, which implies that the changepoint (based on the third derivative of the biphasic equation
with respect to time) may need to be restricted.

####Non-Working_Full_Model_Bernoulli_Classification_of_Monophasic_Parameters.txt

This is the previous version of the newer model, which attempted to estimate several hierarchical parameters allowed to vary by 
experiment or study. Due to the limited number of experiments present for each study, many parameters were not identifiable, and 
test runs with data generated from known parameters revealed very poor estimation, even after as many as 7,000,000 MCMC iterations.
This was the first model to incorporate the idea of identifying monophasic parameter estimates as belonging to the fast or slow biphasic
parameter set by estimating alpha from a bernoulli distribution (coin flip) for monophasic experiments. Unlike the latest model, the 
initial log concentration of organisms in each experiment is treated as a variable with an unknown distribution. This was later changed
since it was deemed to introduce unnecessary uncertainty.

##Old Phase

###OLD_Monophasic_Parameter_Estimates.txt

Old model for estimating monophasic die-off parameters for single experiments. Fairly straightforward.

###OLD_Biphasic_Parameter_Estimates.txt

Old model for estimating biphasic die-off parameters for single experiments. There are two restrictions in place that were important
for attaining good estimates. First, k2 was parameterized as k1 + positive number e^diff, to prevent label switching between the rate
parameters. Second, alpha was specified as a function of k1, k2, and Chgpt, which corresponds to the coordinate of the maximum rate of 
change in slope, or the vertex of the biphasic function, and is based off a third derivative of the biphasic die-off function with
respect to time. Chgpt was drawn from a uniform distribution, whose bounds were chosen to reflect the investigator's beliefs about the 
range in which the vertex should lie.

###Log of Temperature Parameter Estimates

A file containing a number of models for estimating the effect of temperature on rate parameter k. The models documented in this file
reveal rationales for setting the reference temperature at 20 degrees C, as well as choosing an exponential model to relate temperature
to the rate of die-off.

https://github.com/pcollender/Shigella-Die-off-Modeling/files/64706/Shigella.K.vs.temp.hierarchical.docx

##Miscellaneous

###Time_Uncertainty_to_K_Uncertainty.txt

A model to estimate uncertainty around a monophasic die-off rate parameter for experiments where uncertainty around time-to-90%
inactivation (T90) is provided.

