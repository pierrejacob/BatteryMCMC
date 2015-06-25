rm(list = ls())
library(BatteryMCMC)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")
current <- matrix(read.csv(file = paste0("Data/u_mag1_size930.csv"), header = FALSE)$V1, ncol = 1)
parameters <- list(
  Rinf = 0.01,
  C1 = 3,
  R1 = 0.2,
  alpha1 = 0.8,
  C2 = 400,
  alpha2 = 0.5,
  sigma_x = 0.002,
  sigma_y = 0.02,
  Ts = 1/2000)

theta <- c(parameters$Rinf, parameters$C1, parameters$R1, parameters$alpha1, parameters$C2, parameters$alpha2)

Model <- new( Module( "battery_module", PACKAGE = "BatteryMCMC")$BatteryModel )
Model$set_input(current)
Model$set_parameters(parameters)
Model$alpha1
Model$alpha2
Model$A_0_1
Model$A_0_2
qplot(x = 1:length(Model$coeff1), y = abs(Model$coeff1)) + scale_y_log10()
qplot(x = 1:length(Model$coeff2), y = abs(Model$coeff2)) + scale_y_log10()
head(Model$coeff1)
head(Model$coeff2)

