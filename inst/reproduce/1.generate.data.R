rm(list = ls())
library(BatteryMCMC)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")

# parameters used to generate the data
parameters <- list(
  Rinf = 0.01,
  C1 = 3,
  R1 = 0.2,
  R2 = 50,
  alpha1 = 0.8,
  C2 = 400,
  alpha2 = 0.5,
  sigma_x = 0.002,
  sigma_y = 0.02,
  Ts = 1/2000)

# another signal / noise ratio
parameters_SNR <- list(
  Rinf = 0.01,
  C1 = 3,
  R1 = 0.2,
  R2 = 50,
  alpha1 = 0.8,
  C2 = 400,
  alpha2 = 0.5,
  sigma_x = 0.002,
  sigma_y = 0.002,
  Ts = 1/2000)

# another signal / noise ratio
parameters_SNR2 <- list(
  Rinf = 0.01,
  C1 = 3,
  R1 = 0.2,
  R2 = 50,
  alpha1 = 0.8,
  C2 = 400,
  alpha2 = 0.5,
  sigma_x = 0.002,
  sigma_y = 0.0002,
  Ts = 1/2000)

# input file names
# filenames <- c("u_mag1_size930", "u_mag1_size1890", "u_mag5_size930", "u_mag5_size1890", "u_mag1_size635", "u_mag1_size762", "u_mag1_size1016")
filenames <- c("u_mag1_size930", "u_mag5_size930", "u_mag1_size635", "u_mag1_size1890")


# generate data given input and parameters
generate_data <- function(input_file, parameters){
  current <- matrix(read.csv(file = paste0("Data/", input_file, ".csv"), header = FALSE)$V1, ncol = 1)
  # model 1
  Model1 <- new(Module("battery_module", PACKAGE = "BatteryMCMC")$BatteryModel)
  Model1$set_input(current)
  Model1$set_parameters(parameters)
  Model1$generate_observations(nrow(current))
  states_model1 <- Model1$get_states()
  observations_model1 <- Model1$get_observations()
  # model 1 with another set of parameters
  Model1 <- new(Module("battery_module", PACKAGE = "BatteryMCMC")$BatteryModel)
  Model1$set_input(current)
  Model1$set_parameters(parameters_SNR)
  Model1$generate_observations(nrow(current))
  states_model1_SNR <- Model1$get_states()
  observations_model1_SNR <- Model1$get_observations()
  # and another set
  Model1 <- new(Module("battery_module", PACKAGE = "BatteryMCMC")$BatteryModel)
  Model1$set_input(current)
  Model1$set_parameters(parameters_SNR2)
  Model1$generate_observations(nrow(current))
  states_model1_SNR2 <- Model1$get_states()
  observations_model1_SNR2 <- Model1$get_observations()


  # model 2 with first set of parameters
  Model2 <- new(Module("battery2_module", PACKAGE = "BatteryMCMC")$BatteryModel2)
  Model2$set_input(current)
  Model2$set_parameters(parameters)
  Model2$generate_observations(nrow(current))

  return(list(current = current, states_model1 = states_model1, observations_model1 = observations_model1,
              states_model1_SNR = states_model1_SNR, observations_model1_SNR = observations_model1_SNR,
              states_model1_SNR2 = states_model1_SNR2, observations_model1_SNR2 = observations_model1_SNR2,
              states_model2 = Model2$get_states(), observations_model2 = Model2$get_observations(),
              parameters = parameters, parameters_SNR = parameters_SNR, parameters_SNR2 = parameters_SNR2))
}

for (i in 1:length(filenames)){
  synthetic_data <- generate_data(filenames[i], parameters)
  save(synthetic_data, file = paste0("Data/", filenames[i], ".RData"))
}

# i <- 4
# load(paste0("Data/", filenames[i], ".RData"))
# names(synthetic_data)
# matplot(synthetic_data$current, type = "l")
