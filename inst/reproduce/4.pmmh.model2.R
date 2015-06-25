rm(list = ls())
library(BatteryMCMC)
library(foreach)
library(doMC)
registerDoMC(cores=8)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")

# run model 2 for u_mag1_size930
nparticles <- 128
filename <- "u_mag1_size930"
niterations <- 20000
nruns <- 5

foreach (irun = 1:nruns, .combine = c) %dopar% {
    load(file = paste0("Results/", filename, "_model2_uniformprior_preliminary.RData"))
    modellist2 <- list(model = "model2", prior = "uniform")
    algorithmic_parameters2 <- list(nparticles = nparticles, niterations = niterations, cholesky_proposal = cholesky_preliminary, initial_theta = theta_preliminary)
    inputs2 <- list(current = synthetic_data$current, observations = synthetic_data$observations_model2, theta = synthetic_data$parameters)
    results <- launch_pmmh(inputs2, modellist2, algorithmic_parameters2)
    save(results, file = paste0("Results/", filename, "_run", irun, "_model2_uniformprior.RData"))
    1
  }

