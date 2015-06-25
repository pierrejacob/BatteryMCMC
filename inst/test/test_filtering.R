rm(list = ls())
library(BatteryMCMC)
setmytheme()
set.seed(17)

module <- Module( "generate_data_module", PACKAGE = "BatteryMCMC");
parameters <- list(rho = 0.99, sigma = 0.01, tau = 0.01)
datalength <- 250
generated_data <- module$generate_data_LG(parameters, datalength)

Y <- generated_data$observations

module <- Module( "filtering_module", PACKAGE = "BatteryMCMC");
filtering <- module$particle_filtering_LG

pfresults <- filtering(parameters, Y, 1000)
pfll <- pfresults$loglikelihood
pfmeans <- pfresults$filtering_means
library(Kalman)

### model
# set parameter values
parameters <- list(rho = 0.99,
                   eta = 1.0,
                   sdtransition = 0.01, # standard deviation of the Normal noise of the transition equation
                   sdmeasurement = 0.01) # standard deviation of the Normal noise of the measurement equation
parameters_vector <- c(0.99, 1, 0.01, 0.01)
# datalength <- 100
# Y <- rep(0, datalength)
# X <- rep(0, datalength+1)
# X[1] <- rnorm(1, mean = 0, sd = 1)
# for (t in 1:datalength){
#   X[t+1] <- rnorm(1, mean = parameters$rho * X[t], sd = parameters$sdtransition)
#   Y[t] <- rnorm(1, mean = parameters$eta * X[t+1], sd = parameters$sdmeasurement)
# }

# instead of using my own clunky package, should replace this by
# an existing R implementation of Kalman filters
kalman_module <- Module( "kalman_module", PACKAGE = "Kalman")
KF_means <- kalman_module$kalman_filtering_means(parameters, Y)
KF_ll <- kalman_module$kalman_loglikelihood(parameters_vector, Y)

matplot(cbind(diff(pfll), diff(KF_ll)), type = "l")
matplot(cbind(pfmeans, KF_means[2:(datalength+1)]), type = "l")


current <- matrix(read.csv(file = "~/Dropbox/Battery/Data/u_310.csv", header = FALSE)$V1, ncol = 1)
parameters <- list(
  Rinf = 0.01,
  R1 = 0.2,
  C1 = 3,
  C2 = 400,
  alpha1 = 0.8,
  alpha2 = 0.5,
  sigma_x = 0.002,
  sigma_y = 0.02,
  Ts = 1/2000)
module <- Module( "generate_data_module", PACKAGE = "BatteryMCMC")
battery_data <- module$generate_data_battery(parameters, current, nrow(current))
module <- Module( "filtering_module", PACKAGE = "BatteryMCMC")
filtering <- module$particle_filtering_battery
res <- filtering(parameters, current, battery_data$observations, 1000)

# res$loglikelihood

df <- data.frame(res$filtering_means)
head(df)
df$time <- 1:nrow(current)

matplot(cbind(battery_data$states[,1], res$filtering_means[,1]), type = "l")
matplot(cbind(battery_data$states[,2], res$filtering_means[,2]), type = "l")
dim(res$filtering_means)


res <- module$particle_filtering_battery_ntimes(parameters, current, battery_data$observations, 512, 10)
res
