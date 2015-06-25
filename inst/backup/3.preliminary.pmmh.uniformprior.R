rm(list = ls())
library(BatteryMCMC)
library(foreach)
library(doMC)
registerDoMC(cores=4)
setmytheme()
set.seed(17)
setwd("~/Dropbox/Battery/")

# filenames <- c("u_mag1_size930", "u_mag1_size1890", "u_mag5_size930", "u_mag5_size1890")
filenames <- c("u_mag1_size635", "u_mag1_size762", "u_mag1_size1016")
# Ns <- c(128, 128, 256, 256)
Ns <- c(128, 128, 128)
n <- length(filenames)

Prior <- new(Module( "batterymodeluniformprior_module", PACKAGE = "BatteryMCMC")$BatteryModelUniformPrior)
Prior2 <- new(Module( "batterymodel2uniformprior_module", PACKAGE = "BatteryMCMC")$BatteryModel2UniformPrior)
initial_thetas1 <- foreach( i = 1:n, .combine = rbind) %dopar%{
  Prior$rprior()
}
initial_thetas1 <- matrix(initial_thetas1, nrow = n, byrow = FALSE)
initial_thetas2 <- foreach( i = 1:n, .combine = rbind) %dopar%{
  Prior2$rprior()
}
initial_thetas2 <- matrix(initial_thetas2, nrow = n, byrow = FALSE)


variance_proposal1 <- diag(c(0.001**2, 0.1**2, 0.05**2, 0.05**2, 10**2, 0.05**2))
cholesky_proposal1 <- chol(variance_proposal1)
variance_proposal2 <- diag(c(0.001**2, 0.1**2, 0.05**2, 0.05**2, 10**2, 0.05**2, 5**2))
cholesky_proposal2 <- chol(variance_proposal2)

niterations <- 5000

foreach(i = 1:n, .combine = c) %dopar% {
  nparticles <- Ns[i]
  load(paste0("Data/", filenames[i], ".RData"))

  modellist1 <- list(model = "model1", prior = "uniform")
  algorithmic_parameters1 <- list(nparticles = nparticles, niterations = niterations, cholesky_proposal = cholesky_proposal1, initial_theta = initial_thetas1[i,])
  inputs1 <- list(current = synthetic_data$current, observations = synthetic_data$observations_model1, theta = synthetic_data$parameters)
  results <- launch_pmmh(inputs1, modellist1, algorithmic_parameters1)
  cholesky_preliminary <- try(chol(cov(results$chain[(results$niterations/2):results$niterations,])))
  theta_preliminary <- results$chain[results$niterations,]
  save(synthetic_data, cholesky_preliminary, theta_preliminary, results, file = paste0("Results/", filenames[i], "_model1_uniformprior_preliminary.RData"))

  modellist2 <- list(model = "model2", prior = "uniform")
  algorithmic_parameters2 <- list(nparticles = nparticles, niterations = niterations, cholesky_proposal = cholesky_proposal2, initial_theta = initial_thetas2[i,])
  inputs2 <- list(current = synthetic_data$current, observations = synthetic_data$observations_model2, theta = synthetic_data$parameters)
  results <- launch_pmmh(inputs2, modellist2, algorithmic_parameters2)
  cholesky_preliminary <- try(chol(cov(results$chain[(results$niterations/2):results$niterations,])))
  theta_preliminary <- results$chain[results$niterations,]
  save(synthetic_data, cholesky_preliminary, theta_preliminary, results, file = paste0("Results/", filenames[i], "_model2_uniformprior_preliminary.RData"))
  1
}
