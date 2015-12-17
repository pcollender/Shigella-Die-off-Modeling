#This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License 
#<http://creativecommons.org/licenses/by-nc/4.0/> by Philip Collender, Christopher Hoover, Howard Chang,
#and Justin Remais. This work was supported in part by the National Institutes of Health/National Science 
#Foundation Ecology of Infectious Disease program funded by the Fogarty International Center (grant R01TW010286), 
#the National Institute of Allergy and Infectious Diseases (grant K01AI091864), and the National Science Foundation 
#Water Sustainability and Climate Program (grant 1360330).

CerfReg=function(Data,Exper){
  layout(1)
  Time = Data$Time[Data$Exp==Exper]
  Conc = Data$ln_Conc[Data$Exp==Exper]
  plot(Time,Conc)
  Yest<-as.double(readline(prompt="At what Y value does the change in slope appear to take place? "))
  Xest<-as.double(readline(prompt="At what X value does the change in slope appear to take place? "))
  alphainit<-(1-exp(Yest)/exp(Conc[Time==0]))
  K1init<--(Conc[Time==0]-Yest)/Xest
  K2init<--(Yest-Conc[length(Conc)])/(max(Time)-Xest)
  
  saved.fits=try(nls(Conc~Y0+log(alpha*exp(K1*Time)+(1-alpha)*exp(K2*Time)), algorithm='port',
                     start=list(Y0=Conc[Time==min(Time)], alpha=alphainit, K1=K1init, K2=K2init), lower=c(0,0,-Inf,-Inf), 
                     upper=c(Inf,1,Inf,Inf)))
  
  linear.fits=lm(Conc~Time)
  
  layout(matrix(seq(1:2)))
  newdat=data.frame(seq(Time[1],Time[length(Time)],by=abs(Time[1]-Time[2]/40)))
  names(newdat)='Time'
  try(plot(newdat$Time,predict(saved.fits,newdata=newdat),type='l',xlab='Time',ylab='Ln(Concentration)', 
           main='experiment...', sub=sprintf('model error = %s',summary(saved.fits)$sigma),ylim=c(min(Conc),max(Conc)))+points(Time,Conc))
  plot(newdat$Time, predict(linear.fits,newdata=newdat),type='l',xlab='Time',ylab='Ln(Concentration)',
       main=Exper, sub=sprintf('model error = %s', summary(linear.fits)$sigma),ylim=c(min(Conc),max(Conc)))+points(Time,Conc)
  
  return(list(saved.fits,summary(saved.fits),linear.fits,summary(linear.fits)))
}
