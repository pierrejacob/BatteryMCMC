rm(list = ls())
library(BatteryMCMC)
library(foreach)
library(doMC)
registerDoMC(cores=4)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")

# filenames <- c("u_mag1_size930", "u_mag1_size1890", "u_mag5_size930", "u_mag5_size1890")
# Ns <- c(128, 128, 256, 256)
filenames <- c("u_mag1_size635", "u_mag1_size762", "u_mag1_size1016")
Ns <- c(128, 128, 128)
n <- length(filenames)

niterations <- 20000

foreach(i = 1:n, .combine = c) %dopar% {
  nparticles <- Ns[i]
  # load(paste0("Data/", filenames[i], ".RData"))
  load(file = paste0("Results/", filenames[i], "_model1_uniformprior_preliminary.RData"))
  modellist1 <- list(model = "model1", prior = "uniform")
  algorithmic_parameters1 <- list(nparticles = nparticles, niterations = niterations, cholesky_proposal = cholesky_preliminary, initial_theta = theta_preliminary)
  inputs1 <- list(current = synthetic_data$current, observations = synthetic_data$observations_model1, theta = synthetic_data$parameters)
  results <- launch_pmmh(inputs1, modellist1, algorithmic_parameters1)
  save(results, file = paste0("Results/", filenames[i], "_model1_uniformprior_pmmh.RData"))

  load(file = paste0("Results/", filenames[i], "_model2_uniformprior_preliminary.RData"))
  modellist2 <- list(model = "model2", prior = "uniform")
  algorithmic_parameters2 <- list(nparticles = nparticles, niterations = niterations, cholesky_proposal = cholesky_preliminary, initial_theta = theta_preliminary)
  inputs2 <- list(current = synthetic_data$current, observations = synthetic_data$observations_model2, theta = synthetic_data$parameters)
  results <- launch_pmmh(inputs2, modellist2, algorithmic_parameters2)
  save(results, file = paste0("Results/", filenames[i], "_model2_uniformprior_pmmh.RData"))
  1
}

