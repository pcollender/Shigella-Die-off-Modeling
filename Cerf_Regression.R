#This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License 
#<http://creativecommons.org/licenses/by-nc/4.0/> by Philip Collender, Christopher Hoover, Howard Chang,
#and Justin Remais. This work was supported in part by the National Institutes of Health/National Science 
#Foundation Ecology of Infectious Disease program funded by the Fogarty International Center (grant R01TW010286), 
#the National Institute of Allergy and Infectious Diseases (grant K01AI091864), and the National Science Foundation 
#Water Sustainability and Climate Program (grant 1360330).

#Per the terms of this license, if you are making derivative use of this work, you must identify that your work is a derivative work, 
#give credit to the original work, provide a link to the license, and indicate changes that were made.


CPest=function(alpha,k1,k2){
  log(alpha/(1-alpha))/(k1-k2)
}#Function to estimate changepoint time coordinate if nls trace is available but function doesnt converge

CerfReg=function(Data,Exper){
  layout(1)
  Time <- Data$Time[Data$Exp==Exper]
  lnConc <<- Data$ln_Conc[Data$Exp==Exper]
  plot(Time,lnConc)
  retry=1
  while(retry>0){  
    retry=retry-1
    Yest<-eval(parse(text=readline(prompt="At what Y value does the change in slope appear to take place? (Hit Enter if no changepoint is visible)")))
    Xest<-eval(parse(text=readline(prompt="At what X value does the change in slope appear to take place? (Hit Enter if no changepoint is visible)")))
    Xvals<-c(max(Time[Time<Xest]),min(Time[Time>Xest]))
    Yvals<-c(lnConc[Time==Xvals[1]],lnConc[Time==Xvals[2]])
    
    K1init<-(lnConc[Time==0]-Yvals[1])/Xvals[1]
    if (is.nan(K1init)){
      K1init<-(lnConc[Time==0]-Yest)/Xest
    }
    
    K2init<-(Yvals[2]-lnConc[length(lnConc)])/(max(Time)-Xvals[2])
    if (is.nan(K2init)){
      K2init<-(Yest-lnConc[length(lnConc)])/(max(Time)-Xest)
    }
    c=exp((K1init-K2init)*Xest)
    alphainit<-c/(c+1)
    
    
    saved.fits<-try(nlsLM(lnConc~Y0+log(alpha*exp(-K1*Time)+(1-alpha)*exp(-K2*Time)), algorithm='LM',
                           start=list(Y0=lnConc[Time==min(Time)], alpha=alphainit, K1=K1init, K2=K2init), lower=c(0,0,-Inf,-Inf), 
                           upper=c(Inf,1,Inf,Inf),trace=TRUE))
    Check2='n'
    newdat<-data.frame(seq(Time[1],Time[length(Time)],by=abs(Time[1]-Time[2]/40)))
    names(newdat)='Time'
    
    if (length(saved.fits)==1 & (!is.null(Xest) | !is.null(Yest))){
      plot(newdat$Time,lnConc[Time==0]+log(alphainit*exp(-K1init*newdat$Time)+(1-alphainit)*exp(-K2init*newdat$Time)),
           type='l',xlab='Time',ylab='Ln(Concentration)', main=paste('experiment',Exper, sep=' '), 
           sub=sprintf('INITIAL ESTIMATES'),ylim=c(min(lnConc),max(lnConc)))+points(Time,lnConc)
      Check1=readline(prompt='Retry? (y or n) \n')
      if(Check1=='y'){
        retry=1 
      }
      if(Check1=='n'){
        Check2=readline(prompt='Save initial guess parameters to pass on to MCMC? (y or n) \n')
      } 
    }
  }
  
  
  linear.fits=lm(lnConc~Time)
  
  
  newdat<<-newdat
  biphsave=NA
  if (!is.null(Xest) & !is.null(Yest)){
    layout(matrix(seq(1:2)))
    if(Check2!='y'){
      plot(newdat$Time,predict(saved.fits,newdata=newdat),type='l',xlab='Time',ylab='Ln(Concentration)', 
           main='experiment...', sub=sprintf('model error = %s',summary(saved.fits)$sigma),ylim=c(min(lnConc),max(lnConc)))+points(Time,lnConc)
      biphsave<-summary(saved.fits)$coefficients
    }else{
      plot(newdat$Time,lnConc[Time==0]+log(alphainit*exp(-K1init*newdat$Time)+(1-alphainit)*exp(-K2init*newdat$Time)),
           type='l',xlab='Time',ylab='Ln(Concentration)', main='experiment...', 
           sub=sprintf('INITIAL ESTIMATES'),ylim=c(min(lnConc),max(lnConc)))+points(Time,lnConc)
      biphsave<-cbind(c(lnConc[Time==0],alphainit,K1init,K2init))
    }
    plot(newdat$Time, predict(linear.fits,newdata=newdat),type='l',xlab='Time',ylab='Ln(Concentration)',
         main=Exper, sub=sprintf('model error = %s', summary(linear.fits)$sigma),ylim=c(min(lnConc),max(lnConc)))+points(Time,lnConc)
  }else(
    plot(newdat$Time, predict(linear.fits,newdata=newdat),type='l',xlab='Time',ylab='Ln(Concentration)',
         main=paste('experiment',Exper, sep=' '), sub=sprintf('model error = %s', summary(linear.fits)$sigma),ylim=c(min(lnConc),max(lnConc)))+points(Time,lnConc)
  )

  return(list(saved.fits,biphsave,linear.fits,summary(linear.fits)))
}
