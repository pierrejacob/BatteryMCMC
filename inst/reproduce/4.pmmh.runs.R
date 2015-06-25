rm(list = ls())
library(BatteryMCMC)
library(foreach)
library(doMC)
registerDoMC(cores=8)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")

# filenames <- c("u_mag1_size930", "u_mag5_size930", "u_mag1_size635", "u_mag1_size1890")
filenames <- c("u_mag5_size930", "u_mag1_size635", "u_mag1_size1890")
n <- length(filenames)
# Ns <- c(128, 128, 128, 256)
# Ns <- c(128, 128, 128)
Ns <- c(128, 128, 256)

niterations <- 20000
nruns <- 5
# run model 1 for each file, using the results from preliminary runs
foreach (irun = 1:nruns, .combine = c) %:%
  foreach(i = 1:n, .combine = c) %dopar% {
  nparticles <- Ns[i]
  load(file = paste0("Results/", filenames[i], "_model1_uniformprior_preliminary.RData"))
  modellist1 <- list(model = "model1", prior = "uniform")
  algorithmic_parameters1 <- list(nparticles = nparticles, niterations = niterations, cholesky_proposal = cholesky_preliminary, initial_theta = theta_preliminary)
  inputs1 <- list(current = synthetic_data$current, observations = synthetic_data$observations_model1, theta = synthetic_data$parameters)
  results <- launch_pmmh(inputs1, modellist1, algorithmic_parameters1)
  save(results, file = paste0("Results/", filenames[i], "_run", irun, "_model1_uniformprior.RData"))
  1
  }


