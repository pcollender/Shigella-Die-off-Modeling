#This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License 
#<http://creativecommons.org/licenses/by-nc/4.0/> by Philip Collender, Christopher Hoover, Howard Chang,
#and Justin Remais. This work was supported in part by the National Institutes of Health/National Science 
#Foundation Ecology of Infectious Disease program funded by the Fogarty International Center (grant R01TW010286), 
#the National Institute of Allergy and Infectious Diseases (grant K01AI091864), and the National Science Foundation 
#Water Sustainability and Climate Program (grant 1360330).

#Per the terms of this license, if you are making derivative use of this work, you must identify that your work is a derivative work, 
#give credit to the original work, provide a link to the license, and indicate changes that were made.

#Data Read In
dd=readline(prompt='Input data directory:  \n')
setwd(dd)
chooz=readline(prompt='Type "g" if using generated dataset, "o" if using observational dataset: \n' )
if(chooz=='g'){
  nom=readline(prompt='What title was provided for generated data? \n')
  mexp = read.csv (paste(nom, "_SummConcDat.csv", sep=''))}
if(chooz=='o'){
  nom=readline(prompt='Paste file name for observed dataset: \n')
  mexp = read.csv (nom)}

rm(list=c('chooz', 'nom'))
