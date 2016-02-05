# Shigella-Die-off-Modeling
This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License 
http://creativecommons.org/licenses/by-nc/4.0/ by Philip Collender, Christopher Hoover, Howard Chang and Justin Remais. 
This work was supported in part by the National Institutes of Health/National Science Foundation Ecology of Infectious Disease 
program funded by the Fogarty International Center (grant R01TW010286), the National Institute of Allergy and Infectious Diseases 
(grant K01AI091864), and the National Science Foundation Water Sustainability and Climate Program (grant 1360330).

Per the terms of this license, if you are making derivative use of this work, you must identify that your work is a derivative work, 
give credit to the original work, provide a link to the license, and indicate changes that were made.

___

This branch contains R scripts to generate and process pathogen die-off data in preparation for Bayesian modeling.
Module descriptions are shown below:

#Data_Generator.R: 
Function to generate data for testing MCMC model performance with varying data quality. Assumes that all 
monophasic die-off parameters belong to either the fast or slow region of a biphasic die-off curve.

#Biphasic_non_linear_least_squares_regression.R: 
Function used to get initial estimates of rate parameters (k1, k2), 
as well as population proportion (alpha) subject to each rate parameter underlying biphasic die-off data. Convergence for the 
formula is a bit tricky, so the user is asked to guess y and x coordinates of point where change in slope is greatest 
to allow for informed initial estimates of the parameters. Regression results, as well as a monophasic regression, 
are plotted so that the user may assess how well they appear to fit the data.

