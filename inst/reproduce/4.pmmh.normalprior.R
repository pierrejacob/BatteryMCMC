rm(list = ls())
library(BatteryMCMC)
library(foreach)
library(doMC)
registerDoMC(cores=4)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")

# run model 1 with normal prior for u_mag1_size930
nparticles <- 128
filename <- "u_mag1_size930"
niterations <- 20000
nruns <- 5

foreach (irun = 1:nruns, .combine = c) %dopar% {
  load(file = paste0("Results/", filename, "_model1_normalprior_preliminary.RData"))
  modellist1 <- list(model = "model1", prior = "normal")
  algorithmic_parameters1 <- list(nparticles = nparticles, niterations = niterations, cholesky_proposal = cholesky_preliminary, initial_theta = theta_preliminary)
  inputs1 <- list(current = synthetic_data$current, observations = synthetic_data$observations_model1, theta = synthetic_data$parameters)
  results <- launch_pmmh(inputs1, modellist1, algorithmic_parameters1)
  save(results, file = paste0("Results/", filename, "_run", irun, "_model1_normalprior.RData"))
  1
}

