#Generate data for model testing

rm(list=ls())

#Function to generate scenarios:
datagen<-function(){
  Nstudy=as.numeric(readline(prompt='How many studies to simulate? \n' ))
  Studies<-seq(1:Nstudy) 
  
  expsper<-as.numeric(readline(prompt='How many experiments per study on average? \n'))
  expdist<-(readline(prompt= 'Should studies have equal numbers of experiments (y or n)? \n'))
  
  if(expdist=='y'){
    nexp=rep(NA,Nstudy)
    for (i in 1:Nstudy){
      nexp[i]<-expsper
    }
  }
  
  if(expdist=='n'){
    nexp=rep(NA,Nstudy)
    for (i in 1:Nstudy){
      nexp[i]<-rpois(1,expsper)
      while(nexp[i]==0){
        nexp[i]<-rpois(1,expsper)
      }
    }
  }
  
  Stud=NA
  
  for(i in 2:Nstudy){
    Stud[1:(nexp[1]*1)]<-rep(Studies[1],nexp[1])
    placehold<-length(Stud)
    Stud[(placehold+1):(placehold+nexp[i])]<-rep(Studies[i],nexp[i])
  }
  
  Nexp<-length(Stud)
  Exp<-seq(1:Nexp)
  
  probbiph<-as.numeric(readline(prompt= 'What proportion of experiments should be biphasic (answer in decimal form)? \n'))
  biphdist<-(readline(prompt= 'Should studies have equal rates of biphasic experiments (y or n)? \n'))
  
  
  
  Type=NA
  
  if(biphdist=='y'){
    placehold=NA
    for(i in 1:Nexp){
      placehold[i]=rbinom(1,1,probbiph)
    }
    Type[placehold==1]<-'Biphasic'
    Type[placehold==0]<-'Monophasic'
  }
  
  if(biphdist=='n'){
    distvar<-(readline(prompt= 'Should proportion of biphasic experiments be dispersed or relatively evenly distributed (d or e)? \n'))
    placehold1=NA
    placehold2=NA
    if(distvar=='d'){
      a=runif(1,min=1.E-6,max=0.1)
    }
    if(distvar=='e'){
      a=runif(1,min=1,max=5)
    }
    b=(a-probbiph*a)/probbiph
    for(i in 1:Nstudy){
      placehold1[i]=rbeta(1,a,b)
    }
    for(i in 1:Nexp){
      placehold2[i]=rbinom(1,1,placehold1[Studies==Stud[i]])
    }
    Type[placehold2==1]<-'Biphasic'
    Type[placehold2==0]<-'Monophasic'
  }
  Temp=NA
  Tempmax<-as.numeric(readline(prompt= 'What maximum Temperature should experiments examine? \n'))
  Tempmin<-as.numeric(readline(prompt= 'What minimum Temperature should experiments examine? \n'))
  Tempdist<-(readline(prompt= 'Should studies be equally likely to examine the same range of temperatures (y or n)? \n'))
  
  if(Tempdist=='y'){
    for (i in 1:Nexp){
      Temp[i]<-round(runif(1,min=Tempmin,max=Tempmax))
    }
  }
  
  if(Tempdist=='n'){
    T1=NA
    T2=NA
    for(i in 1:Nstudy){
      T1[i]=round(runif(1,min=Tempmin,max=Tempmax))
      T2[i]=round(runif(1,min=Tempmin,max=Tempmax))
    }
    for(i in 1:Nexp){
      Temp[i]<-round(runif(1,min=min(T1[Studies==Stud[i]],T2[Studies==Stud[i]]),
                           max=max(T1[Studies==Stud[i]],T2[Studies==Stud[i]])))
    }
  }
  
  mulambda1<-as.numeric(readline(prompt='Provide the multiplicative effect of a degree increase in temperature on the fast rate parameter (e^x, sugg x=0.01,0.1,1): \n'))
  mulambda2<-as.numeric(readline(prompt='Provide the multiplicative effect of a degree increase in temperature on the slower rate parameter (e^x, sugg x=0.001,0.01,0.1): \n'))
  
  muk1_ref<-as.numeric(readline(prompt='Provide the mean value of the fast rate parameter at the minimum tempearture (sugg 0.2-2): \n'))
  muk2_ref<-as.numeric(readline(prompt='Provide the mean value of the slower rate parameter at the minimum temperature (sugg 0.02-0.2): \n'))
  
  mgnstuderr<-readline(prompt='Should the magnitude of study level error be extra large, large, medium, small, or extra small with respect to the mean values (xl, l, m, s, xs)? \n')
  if(mgnstuderr=='xl'){
    sdfact=0.25
  }
  if(mgnstuderr=='l'){
    sdfact=0.10
  }
  if(mgnstuderr=='m'){
    sdfact=0.05
  }
  if(mgnstuderr=='s'){
    sdfact=0.01
  }
  if(mgnstuderr=='xs'){
    sdfact=0.001
  }
  
  lambda1=NA
  lambda2=NA
  k1_ref=NA
  k2_ref=NA
  
  for(i in 1:Nstudy){
    lambda1[i]<-rnorm(1,mulambda1,mulambda1*sdfact)
    lambda2[i]<-rnorm(1,mulambda2,mulambda2*sdfact)
    k1_ref[i]<-rnorm(1,muk1_ref,muk1_ref*sdfact)
    k2_ref[i]<-rnorm(1,muk2_ref,muk2_ref*sdfact)
  }
  
  mgnexperr<-readline(prompt='Should the magnitude of experiment level error be extra large, large, medium, small, or extra small with respect to the mean values (xl, l, m, s, xs)? \n')
  if(mgnexperr=='xl'){
    sdfact=0.25
  }
  if(mgnexperr=='l'){
    sdfact=0.1
  }
  if(mgnexperr=='m'){
    sdfact=0.05
  }
  if(mgnexperr=='s'){
    sdfact=0.01
  }
  if(mgnexperr=='xs'){
    sdfact=0.001
  }
  
  k1=NA
  k2=NA
  alpha=NA
  oneminusalpha=NA
  
  for(i in 1:Nexp){
    alpha[i]<-rbeta(1,6,0.1)
    if(Type[i]=='Monophasic'){
      alpha[i]<-rbinom(1,1,0.5)
    }    
    oneminusalpha[i]<-1-alpha[i]
    k1[i]<-k1_ref[Studies==Stud[i]]*exp(lambda1[Studies==Stud[i]]*(Temp[i]-Tempmin))+rnorm(1,0,k1_ref[Studies==Stud[i]]*sdfact)
    k2[i]<-k2_ref[Studies==Stud[i]]*exp(lambda2[Studies==Stud[i]]*(Temp[i]-Tempmin))+rnorm(1,0,k2_ref[Studies==Stud[i]]*sdfact)
  }
  
  expobs=as.numeric(readline(prompt='On average, how many observed time points should the experiments have? \n'))
  obsvar=readline(prompt='Should the number of observations vary by study (y or n)? \n')
  repobs=as.numeric(readline(prompt='How many repeated observations should be made at each time point? \n'))
  repvar=readline(prompt='Should the number of repeated observations vary by study (y or n)? \n')
  
  Tpts=NA
  if (obsvar=='y'){
    for(i in 1:Nstudy){
      Tpts[i]=rpois(1,expobs)
      while(Tpts[i]<3){
        Tpts[i]=rpois(1,expobs)
      }
    }
  }
  
  if (obsvar=='n'){
    for(i in 1:Nstudy){
      Tpts[i]=expobs
    }
  }
  
  reps=NA
  if (repvar=='y'){
    for(i in 1:Nstudy){
      reps[i]=rpois(1,repobs)
      while(reps[i]<2){
        reps[i]=rpois(1,repobs)
      }
    }
  }
  
  if (repvar=='n'){
    for(i in 1:Nstudy){
      reps[i]=repobs
    }
  }
  Studobs=reps*Tpts
  Exprep=NA
  Exptpt=NA
  Obsexp=NA
  Obsstud=NA
  for(i in 1:Nexp){
    Exprep[i]=reps[Studies==Stud[i]]
    Exptpt[i]=Tpts[Studies==Stud[i]]
  }
  Expobs=Exprep*Exptpt
  Nobs<-sum(Expobs)  
  for(i in 2:Nexp){
    Obsexp[1:(Expobs[1])]<-rep(Exp[1],Expobs[1])
    placehold<-length(Obsexp)
    Obsexp[(placehold+1):(placehold+Expobs[i])]<-rep(Exp[i],Expobs[i])
  }
  
  for(i in 1:Nobs){
    Obsstud[i]<-Stud[Exp==Obsexp[i]]
  }
  
  timerand=readline(prompt='Should the timing of observations be evenly distributed (y or n)? \n')
  timemax=as.numeric(readline(prompt='What is the maximum length of time an experiment should proceed in days? \n'))
  
  Timefactor1=k1/min(k1)
  Timefactor2=k2/min(k2)
  Exptmax=NA
  for(i in 1:Nexp){
    if(alpha[i]!=0){
      Exptmax[i]=timemax/Timefactor1[i]
    }else{
      Exptmax[i]=timemax/Timefactor2[i]
    }
  }
  
  Time=rep(NA,Nobs)
  
  if(timerand=='y'){
    for(i in 1:Nexp){
      Time[Obsexp==Exp[i]]<-rep(seq(0,Exptmax[i],by=Exptmax[i]/((Exptpt[i])-1)), each=Exprep[i])
    }
  }
  
  if(timerand=='n'){
    for(i in 1:Nexp){
      Time[Obsexp==Exp[i]]<-c(rep(0,Exprep[i]), rep(runif((Exptpt[i]-1),Exptmax[i]/((Exptpt[i])-1),Exptmax[i]), each=Exprep[i]))
    }
  }
  
  ln_Conc=NA
  ln_Conc0=NA
  
  for(i in 1:Nexp){
    ln_Conc0[i]=log(runif(1,1.E6,1.E12))
  }
  
  mgnexpderr=readline(prompt='How large should variance of log concentration estimates be relative to mean estimates (xl, l, m, s, xs)?')
  
  if(mgnexperr=='xl'){
    sdfact=0.01
  }
  if(mgnexperr=='l'){
    sdfact=0.0075
  }
  if(mgnexperr=='m'){
    sdfact=0.0025
  }
  if(mgnexperr=='s'){
    sdfact=0.001
  }
  if(mgnexperr=='xs'){
    sdfact=0.0005
  }
  
  
  for(i in 1:Nobs){
    ln_Conc[i]<-ln_Conc0[Exp==Obsexp[i]]+log(alpha[Exp==Obsexp[i]]*exp(-k1[Exp==Obsexp[i]]*Time[i])+
                                               oneminusalpha[Exp==Obsexp[i]]*exp(-k2[Exp==Obsexp[i]]*Time[i]))+
      rnorm(1,0,(sdfact*ln_Conc0[Exp==Obsexp[i]])^(1/(alpha[Exp==Obsexp[i]]+5e-1)))
  }
  
  uniquetimes=NA
  uniqueexp=NA
  uniquestud=NA
  
  for(i in 2:Nexp){
    uniquetimes[1:Exptpt[1]]=unique(Time[Obsexp==Exp[1]])
    placeholder<-length(uniquetimes)
    uniquetimes[(placeholder+1):(placeholder+Exptpt[i])]=unique(Time[Obsexp==Exp[i]])
    uniqueexp[1:Exptpt[1]]=rep(Exp[1],Exptpt[1])
    uniqueexp[(placeholder+1):(placeholder+Exptpt[i])]=rep(Exp[i],Exptpt[i])
    uniquestud[1:Exptpt[1]]=rep(Stud[1], Exptpt[1])
    uniquestud[(placeholder+1):(placeholder+Exptpt[i])]=rep(Stud[i], Exptpt[i])
  }
  
  Obstemp=NA
  for (i in 1:length(Obsstud)){
    Obstemp[i]=Temp[Exp==Obsexp[i]]
  }
  
  meanln_Conc=NA
  sdln_Conc=NA
  summtemp=NA
  
  for(i in 1:length(uniquetimes)){
    meanln_Conc[i]=mean(ln_Conc[Obsexp==uniqueexp[i]&Time==uniquetimes[i]])
    sdln_Conc[i]=sd(ln_Conc[Obsexp==uniqueexp[i]&Time==uniquetimes[i]])
    summtemp[i]=Temp[Exp==uniqueexp[i]]
  }
  
  
  
  TotalConcDat<<-data.frame('Stud'=Obsstud,'Exp'=Obsexp,'Temp'=Obstemp,ln_Conc,Time)
  SummConcDat<<-data.frame('Stud'=uniquestud,'Exp'=uniqueexp,'Temp'=summtemp,'ln_Conc'=meanln_Conc, 'Var_val'=sdln_Conc,'Time'=uniquetimes)
  KDat<<-data.frame(Stud,Exp,Temp,ln_Conc0)
  KansDat<<-data.frame(Stud,Exp,Temp,k1,k2,alpha,oneminusalpha)
  lambdaansDat<<-data.frame(Studies,lambda1, lambda2)
  
  dsetname<-readline(prompt='Supply a title for the generated dataset (Program will automatically save test and validation sets): \n')
  wd<-readline(prompt='Please paste a directory in which to store generated output: \n')
  
  setwd (paste(wd))
  
  write.csv(TotalConcDat, paste(dsetname, 'TotalConcDat.csv', sep='_'),row.names=FALSE)
  write.csv(SummConcDat, paste(dsetname, 'SummConcDat.csv', sep='_'),row.names=FALSE)
  write.csv(KDat, paste(dsetname, 'Kdat.csv', sep='_'),row.names=FALSE)
  write.csv(KansDat, paste(dsetname, 'Kansdat.csv', sep='_'),row.names=FALSE)
  write.csv(lambdaansDat, paste(dsetname, 'lambdaansdat.csv', sep='_'),row.names=FALSE)
  
}    

#run datagen() to generate test data!
