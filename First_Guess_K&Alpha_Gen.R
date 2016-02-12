#This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License 
#<http://creativecommons.org/licenses/by-nc/4.0/> by Philip Collender, Christopher Hoover, Howard Chang,
#and Justin Remais. This work was supported in part by the National Institutes of Health/National Science 
#Foundation Ecology of Infectious Disease program funded by the Fogarty International Center (grant R01TW010286), 
#the National Institute of Allergy and Infectious Diseases (grant K01AI091864), and the National Science Foundation 
#Water Sustainability and Climate Program (grant 1360330).

#Per the terms of this license, if you are making derivative use of this work, you must identify that your work is a derivative work, 
#give credit to the original work, provide a link to the license, and indicate changes that were made.

wd=readline(prompt='Input work directory:  \n')
setwd(wd)
library (minpack.lm)
source ('Cerf_Regression.R')
source ('Exp_Data_Reader.R')

attach (mexp)
layout(1)
torun = unique(mexp$Exp)

Fits=list()
Studs=NA
Tempr=NA
Type=NA
K1_Init=NA
K2_Init=NA
alpha_Init=NA
K_Lin_Init=NA
Chgpt_Init=NA
Chgpt.L=NA

#Use CPest(alpha,k1,k2) at prompts to estimate changepoint from nls trace
s=readline(prompt='Start from which experiment?  \n')
s=which(torun==s)
stp=readline(prompt='Run up to which experiment?  \n')
stp=which(torun=stp)
             
for (i in s:stp){
  Studs[i]=min(mexp$Stud[mexp$Exp==torun[i]])
  Tempr[i]=min(mexp$Temp[mexp$Exp==torun[i]])
  Type[i]=2  
  Fits[[i]]=CerfReg(mexp,torun[i])
  K_Lin_Init[i]=Fits[[i]][[4]]$coefficients[2,1]
  K1_Init[i]=NA
  K2_Init[i]=NA
  alpha_Init[i]=NA
  Chgpt_Init[i]=NA
  Chgpt.L[i]=NA
  if(length(Fits[[i]][[2]])>1){
    Type[i]=1
    K1_Init[i]=Fits[[i]][[2]][3,1]
    K2_Init[i]=Fits[[i]][[2]][4,1]
    alpha_Init[i]=Fits[[i]][[2]][2,1]
    Chgpt_Init[i]=log(alpha_Init[i]/(1-alpha_Init[i]))/(K1_Init[i]-K2_Init[i])
    Chgconc=lnConc[1]+log(alpha_Init[i]*exp(-K1_Init[i]*Chgpt_Init[i])+(1-alpha_Init[i])*exp(-K2_Init[i]*Chgpt_Init[i]))
    layout(1)
    check=1
    while(check==1){
      plot(newdat$Time,lnConc[1]+log(alpha_Init[i]*exp(-K1_Init[i]*newdat$Time)+(1-alpha_Init[i])*exp(-K2_Init[i]*newdat$Time)),
           type='l',xlab='Time',ylab='Ln(Concentration)',ylim=c(min(lnConc),max(lnConc)),xlim=c(min(newdat$Time),max(newdat$Time)))+
        points(mexp$Time[mexp$Exp==torun[i]],lnConc)+points(Chgpt_Init[i],Chgconc, pch=16,col='blue')+text(Chgpt_Init[i],Chgconc,'Estimated Change Point',pos=1)
      check=0
      Chgpt.L[i]=eval(parse(text=readline(prompt='Provide an estimate of the earliest time at which the change point could occur:  \n')))
      Chglconc=lnConc[1]+log(alpha_Init[i]*exp(-K1_Init[i]*Chgpt.L[i])+(1-alpha_Init[i])*exp(-K2_Init[i]*Chgpt.L[i]))
      points(Chgpt.L[i],Chglconc, pch=15,col='green')+text(Chgpt.L[i],Chglconc,'Earliest Possible Change Point',pos=1)
      chuck=readline(prompt='Does the earliest possible change point look reasonable? (y or n)  \n')
      if(chuck=='n'){
        check=1
      }
    }
  }else(readline(prompt='Hit enter to continue'))
}

kdat<-data.frame('Stud'=Studs,'Exp'=torun,'Temp'=Tempr,K_Lin_Init,K1_Init,K2_Init,alpha_Init,Chgpt_Init,Chgpt.L)
write.csv(kdat, 'current_Kdat.csv',row.names=FALSE)
rm(list=c('s','stp','Studs','Tempr','K_Lin_Init','K1_Init','K2_Init','alpha_Init','Chgpt_Init','Chgpt.L','check','chuck','Chgconc','Chglconc','Time','lnConc','newdat','Fits','torun','Type'))
