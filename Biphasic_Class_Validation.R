#This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License 
#<http://creativecommons.org/licenses/by-nc/4.0/> by Philip Collender, Christopher Hoover, Howard Chang,
#and Justin Remais. This work was supported in part by the National Institutes of Health/National Science 
#Foundation Ecology of Infectious Disease program funded by the Fogarty International Center (grant R01TW010286), 
#the National Institute of Allergy and Infectious Diseases (grant K01AI091864), and the National Science Foundation 
#Water Sustainability and Climate Program (grant 1360330).

#Per the terms of this license, if you are making derivative use of this work, you must identify that your work is a derivative work, 
#give credit to the original work, provide a link to the license, and indicate changes that were made.

rm(list=ls())
wd=readline(prompt='Input work directory:  \n')
bd=readline(prompt='Input BUGS/JAGS code directory:  \n')
setwd(wd)
source('Exp_Data_Reader.R')
kdat=read.csv(paste('current_Kdat_', chooz,'.csv', sep=''))

library(runjags)

kdatbiph=subset(kdat, Type==1)
mexpbiph=subset(mexp, Exp %in% kdatbiph$Exp)
torun=as.character(kdatbiph$Exp)

#Temporary error imputation code
{mexpbiph$Var_val[which(is.na(mexpbiph$Var_val))]<-mean(mexpbiph$Var_val,na.rm=TRUE)}

MCMCCerf<-function(data,kdata,experiment){
  
  DAT=subset(data, Exp==experiment)
  KDAT=subset(kdata, Exp==experiment)
  Time = DAT$Time
  ln_Conc=DAT$ln_Conc
  ln_Conc0=ln_Conc[1]
  Nobs=length(Time)
  Var=DAT$Var_val
  Prec=1/Var
  Prec0=Prec[1]
  Chgpt_lower=KDAT$Chgpt.L
  Chgpt_upper=Time[length(Time)]
  if(KDAT$Chgpt_Init<Chgpt_lower){
    KDAT$Chgpt_Init=Chgpt_lower+.1
  }
  
  dat<-list('Time'=Time,'ln_Conc'=ln_Conc,'Nobs'=Nobs,'tau.ln_Conc'=Prec,'Chgpt_lower'=Chgpt_lower,
            'Chgpt_upper'=Chgpt_upper, 'ln_Conc0'=ln_Conc0,'tau.ln_Conc0'=Prec0)

  inits<-function(){
    inips=list()
    for (i in 1:3){
      inips[[i]]=list(K1=rnorm(1,KDAT$K1_Init,.1),diff=log(abs(rnorm(1,KDAT$K1_Init,.1)-rnorm(1,KDAT$K2_Init,.1))),
                      mu.K1=rnorm(1,KDAT$K1_Init,.1),mu.diff=log(abs(rnorm(1,KDAT$K1_Init,.1)-rnorm(1,KDAT$K2_Init,.1))),
                      Chgpt=KDAT$Chgpt_Init+rnorm(1,0,.001),
                      tau.K1=rgamma(1,shape=.1, scale=.000001),tau.diff=rgamma(1,shape=.1, scale=.000001))
      }
    return(inips)
  }
  setwd(bd)
  linear.sim=try(run.jags(model="Biphasic_Validation.txt",monitor=c('K1','K2','Chgpt','alpha'),
                          data=dat,n.chains=3,inits=inits(),sample=260000,burnin=50000,adapt=10000,
                          modules='glm',thin=4))
  if(class(linear.sim)=='try-error'){
    failed.jags(c('model','data','inits'))
  }
  try(plot(linear.sim))
  return(linear.sim)
}

SavedMCs=list()

for(i in 1:length(torun)){
  SavedMCs[[i]]=MCMCCerf(mexpbiph,kdatbiph,torun[i])
}
RANGE=NA
Conf=NA
NEWTYPE=NA
for(i in 1:length(torun)){
  RANGE[i]=0.9*max(mexpbiph$Time[mexpbiph$Exp==torun[i]])-kdatbiph$Chgpt.L[i]
  Conf[i]=SavedMCs[[i]]$summaries[3,3]-SavedMCs[[i]]$summaries[3,1]
  if((Conf[i]/RANGE[i])>0.85){NEWTYPE[i]=2}else{NEWTYPE[i]=1}
  }

kdatbiph$Type=NEWTYPE
kdat=subset(kdat,Type==2)
kdat=rbind(kdatbiph,kdat)
write.csv(kdat, paste('current_Kdat_Reclassed_', chooz,'.csv', sep=''),row.names=FALSE)
rm(NEWTYPE, RANGE, SavedMCs,Conf,torun)
gc()
