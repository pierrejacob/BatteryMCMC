rm(list = ls())
library(BatteryMCMC)
setmytheme()
# set.seed(17)

module <- Module( "generate_data_module", PACKAGE = "BatteryMCMC");
parameters <- list(rho = 0.99, sigma = 0.01, tau = 0.01)
datalength <- 250
generated_data <- module$generate_data_LG(parameters, datalength)

matplot(cbind(generated_data$observations, generated_data$states), type = "l")


current <- matrix(read.csv(file = "~/Dropbox/Battery/Data/u_mag5_size1890.csv", header = FALSE)$V1, ncol = 1)
parameters <- list(
  Rinf = 0.01,
  R1 = 0.2,
  C1 = 3,
  C2 = 400,
  alpha1 = 0.8,
  alpha2 = 0.5,
  sigma_x = 0.0002,
  sigma_y = 0.0002,
  Ts = 1/2000)
a <- module$generate_data_battery(parameters, current, nrow(current))
matplot(a$states, type = "l")
a
plot(current, type = "l")
matplot(a$observations, type = "l")
matplot(a$states, type = "l")

