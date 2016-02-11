#This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License 
#<http://creativecommons.org/licenses/by-nc/4.0/> by Philip Collender, Christopher Hoover, Howard Chang,
#and Justin Remais. This work was supported in part by the National Institutes of Health/National Science 
#Foundation Ecology of Infectious Disease program funded by the Fogarty International Center (grant R01TW010286), 
#the National Institute of Allergy and Infectious Diseases (grant K01AI091864), and the National Science Foundation 
#Water Sustainability and Climate Program (grant 1360330).

#Per the terms of this license, if you are making derivative use of this work, you must identify that your work is a derivative work, 
#give credit to the original work, provide a link to the license, and indicate changes that were made.

CerfReg=function(Data,Exper){
  layout(1)
  Time = Data$Time[Data$Exp==Exper]
  Conc = Data$ln_Conc[Data$Exp==Exper]
  plot(Time,Conc)
  retry=1
  while(retry>0){  
    retry=retry-1
    Yest<-as.double(readline(prompt="At what Y value does the change in slope appear to take place? "))
    Xest<-as.double(readline(prompt="At what X value does the change in slope appear to take place? "))
    Xvals<<-c(max(Time[Time<Xest]),min(Time[Time>Xest]))
    Yvals<<-c(Conc[Time==Xvals[1]],Conc[Time==Xvals[2]])
    
    K1init<<--(Conc[Time==0]-Yvals[1])/Xvals[1]
    if (is.nan(K1init)){
      K1init<<--(Conc[Time==0]-Yest)/Xest
    }
    
    K2init<<--(Yvals[2]-Conc[length(Conc)])/(max(Time)-Xvals[2])
    if (is.nan(K2init)){
      K2init<<--(Yest-Conc[length(Conc)])/(max(Time)-Xest)
    }
    c=exp((K2init-K1init)*Xest)
    alphainit<<-c/(c+1)
    
    
    saved.fits<<-try(nlsLM(Conc~Y0+log(alpha*exp(K1*Time)+(1-alpha)*exp(K2*Time)), algorithm='LM',
                           start=list(Y0=Conc[Time==min(Time)], alpha=alphainit, K1=K1init, K2=K2init), lower=c(0,0,-Inf,-Inf), 
                           upper=c(Inf,1,Inf,Inf),trace=TRUE))
    if (length(saved.fits)==1){
      Check1=readline(prompt='Retry? (y or n) \n')
      if(Check1=='y'){
        retry=1 
      }
      if(Check1=='n'){
        Check2=readline(prompt='Save initial guess parameters to pass on to MCMC? (y or n) \n')
      } 
    }
  }
  
  
  linear.fits=lm(Conc~Time)
  
  layout(matrix(seq(1:2)))
  newdat=data.frame(seq(Time[1],Time[length(Time)],by=abs(Time[1]-Time[2]/40)))
  names(newdat)='Time'
  if(Check2!='y'){
    plot(newdat$Time,predict(saved.fits,newdata=newdat),type='l',xlab='Time',ylab='Ln(Concentration)', 
         main='experiment...', sub=sprintf('model error = %s',summary(saved.fits)$sigma),ylim=c(min(Conc),max(Conc)))+points(Time,Conc)
    biphsave<<-summary(saved.fits)$coefficients
  }else{
    plot(newdat$Time,Conc[Time==0]+log(alphainit*exp(K1init*newdat$Time)+(1-alphainit)*exp(K2init*newdat$Time)),
         type='l',xlab='Time',ylab='Ln(Concentration)', main='experiment...', 
         sub=sprintf('initial estimates'),ylim=c(min(Conc),max(Conc)))+points(Time,Conc)
    biphsave<<-cbind(c(Conc[Time==0],alphainit,K1init,K2init))
  }
  
  plot(newdat$Time, predict(linear.fits,newdata=newdat),type='l',xlab='Time',ylab='Ln(Concentration)',
       main=Exper, sub=sprintf('model error = %s', summary(linear.fits)$sigma),ylim=c(min(Conc),max(Conc)))+points(Time,Conc)
  
  
  return(list(saved.fits,biphsave,linear.fits,summary(linear.fits)))
}
