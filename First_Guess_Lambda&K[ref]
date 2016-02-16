#This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License 
#<http://creativecommons.org/licenses/by-nc/4.0/> by Philip Collender, Christopher Hoover, Howard Chang,
#and Justin Remais. This work was supported in part by the National Institutes of Health/National Science 
#Foundation Ecology of Infectious Disease program funded by the Fogarty International Center (grant R01TW010286), 
#the National Institute of Allergy and Infectious Diseases (grant K01AI091864), and the National Science Foundation 
#Water Sustainability and Climate Program (grant 1360330).

#Per the terms of this license, if you are making derivative use of this work, you must identify that your work is a derivative work, 
#give credit to the original work, provide a link to the license, and indicate changes that were made.

rm(list=ls())
source('Exp_Data_Reader.R')
kdat=read.csv(paste('current_Kdat_Reclassed_', chooz,'.csv', sep=''))

kdatbiph=subset(kdat, Type==1)


plot(kdatbiph$Temp, log(kdatbiph$K1_Init))
k1breaks=readline(prompt=cat(paste(strwrap('Input the temperature coordinate of point at which the slope of the relationship between temperature and K1 appears to change (NA if no clear change):  \n',
                                                                width=100, simplify=TRUE), collapse ='\n')))

plot(kdatbiph$Temp, log(kdatbiph$K2_Init))
k2breaks=readline(prompt=cat(paste(strwrap('Input the temperature coordinate of point at which the slope of the relationship between temperature and K2 appears to change (NA if no clear change):  \n',
                                                                width=100, simplify=TRUE), collapse ='\n')))
Temptemps=kdatbiph$Temp-20
Tempk1s=log(kdatbiph$K1_Init)
Tempk2s=log(kdatbiph$K2_Init)
  
lambda1res=glm(Tempk1s~Temptemps)


lambda2res=glm(Tempk2s~Temptemps)

newdat<-data.frame(seq(min(Temptemps),max(Temptemps),by=abs((min(Temptemps)-min(subset(Temptemps, Temptemps>min(Temptemps))))/40)))
names(newdat)='Temperature'

lambda1_Init=lambda1res$coefficients[2]
lnk1_20_Init=lambda1res$coefficients[1]

plot(newdat$Temperature+20,exp(lnk1_20_Init)*exp(lambda1_Init*newdat$Temperature),
     type='l',xlab='Temperature',ylab='K1',
     sub=sprintf('INITIAL ESTIMATES'),ylim=c(min(kdatbiph$K1_Init),max(kdatbiph$K1_Init)))+points(kdatbiph$Temp,kdatbiph$K1_Init)
readline(prompt='Hit enter to continue')


lambda2_Init=lambda2res$coefficients[2]
lnk2_20_Init=lambda2res$coefficients[1]

plot(newdat$Temperature+20,exp(lnk2_20_Init)*exp(lambda2_Init*newdat$Temperature),
     type='l',xlab='Temperature',ylab='K2',
     sub=sprintf('INITIAL ESTIMATES'),ylim=c(min(kdatbiph$K2_Init),max(kdatbiph$K2_Init)))+points(kdatbiph$Temp,kdatbiph$K2_Init)
readline(prompt='Hit enter to continue')

rm(kdatbiph, newdat, lambda1res, lambda2res, Tempk1s, Tempk2s, Temptemps)
