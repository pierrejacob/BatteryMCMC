rm(list = ls())
library(BatteryMCMC)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")

Prior <- new(Module( "batterymodeluniformprior_module", PACKAGE = "BatteryMCMC")$BatteryModelUniformPrior)
Prior$rprior()

NormalPrior <- new(Module( "batterymodelnormalprior_module", PACKAGE = "BatteryMCMC")$BatteryModelNormalPrior)
theta <- foreach( i = 1:10000, .combine = rbind) %dopar%{
  NormalPrior$rprior()
}

hist(theta[,1])
hist(theta[,2])
hist(theta[,3])
hist(theta[,4])
hist(theta[,5])
hist(theta[,6])

NormalPrior2 <- new(Module( "batterymodel2normalprior_module", PACKAGE = "BatteryMCMC")$BatteryModel2NormalPrior)
theta <- foreach( i = 1:10000, .combine = rbind) %dopar%{
  NormalPrior2$rprior()
}
hist(theta[,7])
summary(theta[,7])
